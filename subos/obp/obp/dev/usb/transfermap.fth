\ ========== Copyright Header Begin ==========================================
\ 
\ Hypervisor Software File: transfermap.fth
\ 
\ Copyright (c) 2006 Sun Microsystems, Inc. All Rights Reserved.
\ 
\  - Do no alter or remove copyright notices
\ 
\  - Redistribution and use of this software in source and binary forms, with 
\    or without modification, are permitted provided that the following 
\    conditions are met: 
\ 
\  - Redistribution of source code must retain the above copyright notice, 
\    this list of conditions and the following disclaimer.
\ 
\  - Redistribution in binary form must reproduce the above copyright notice,
\    this list of conditions and the following disclaimer in the
\    documentation and/or other materials provided with the distribution. 
\ 
\    Neither the name of Sun Microsystems, Inc. or the names of contributors 
\ may be used to endorse or promote products derived from this software 
\ without specific prior written permission. 
\ 
\     This software is provided "AS IS," without a warranty of any kind. 
\ ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, 
\ INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A 
\ PARTICULAR PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. SUN 
\ MICROSYSTEMS, INC. ("SUN") AND ITS LICENSORS SHALL NOT BE LIABLE FOR 
\ ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR 
\ DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL SUN 
\ OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR 
\ FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE 
\ DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, 
\ ARISING OUT OF THE USE OF OR INABILITY TO USE THIS SOFTWARE, EVEN IF 
\ SUN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
\ 
\ You acknowledge that this software is not designed, licensed or
\ intended for use in the design, construction, operation or maintenance of
\ any nuclear facility. 
\ 
\ ========== Copyright Header End ============================================
id: @(#)transfermap.fth 1.8 04/05/25
purpose: 
copyright: Copyright 1997-2004 Sun Microsystems, Inc.  All Rights Reserved
copyright: Use is subject to license terms.

struct
    4 field transfer-control
    4 field curr-buffer
    4 field next-transfer
h# 14 field buffer-end		\ followed by pad to make general and isoc
				\ transfer sizes the same
   /n field my-endpoint		\ used only by software, virt
   /n field caller-data		\    ditto, for caller's buffer
   /n field caller-count
   /n field my-data
   h# 20 over h# 20 mod -	\ pad to next 32 byte boundary
     field endpad2

( general transfer descrip. size ) constant /transfer

\ We can't use curr-buffer and reverse index it to get back to the virt addr
\ of the data buffer because the controller will use that field and set it to
\ 0 to indicate a full transfer.  So we use my-data to hold the virt addr of
\ the associated buffer.  my-data can be used as a copy buffer that is
\ dma-able from the static pool.  0 in caller-data means no associated buffer.
\ caller-count is 0 if no data to transfer.

\ XXX will waste memory up to 32 bytes per descriptor if it is evenly
\ aligned before the calculation. can save the dict entry by pushing the
\ calculation into the size of my-data

\ isochronous transfer descriptor structure

struct
   4 field isoc-control
h# c field buff-page	\ followed by next-transfer & buffer-end, as above
   4 field offset0	\ and offset1; reused for psw0 and psw1
   4 field offset2	\ and offset3; reused for psw2 and psw3
   4 field offset4	\ and offset5; reused for psw4 and psw5
   4 field offset6	\ and offset7; reused for psw6 and psw7;
			\ followed by my-endpoint, as above
drop


: condition-code  ( transfer-d -- cc )
   le-l@ d# 28 rshift
;

\ For isochronous packets:
: packet-condition-code  ( n transfer-d -- cc )
   offset0 swap 4 * +  le-w@
   h# f000 and  d# 12 rshift
;

\ completion codes for transfers ( cc field of transfer descriptor):

0 constant no-error
1 constant crc-error
2 constant bit-error
3 constant toggle-error
4 constant stall-error
5 constant no-response-error
6 constant pid-error
7 constant unexpected-pid-error
8 constant data-overrun-error
9 constant data-underrun-error
\ a constant reserved1
\ b constant reserved2
c constant buf-overrun-error		\ isoc only
d constant buf-underrun-error		\ isoc only
e constant eno-access-error		\ XXX isoc only?
f constant fno-access-error		\ XXX isoc only?

\ These are generated by the code:
11 constant time-out-error
12 constant no-more-addresses

: .error  ( hw-err? -- hw-err? )
   cmn-error[ " USB " cmn-append
   dup
   case  1  of  " crc"              endof
         2  of  " bit"              endof
         3  of  " toggle"           endof
         4  of  " stall"            endof
         5  of  " no response"      endof
         6  of  " pid"              endof
         7  of  " unexpected pid"   endof
         8  of  " data overrun"     endof
         9  of  " data underrun"    endof
         c  of  " buffer overrun"   endof
         d  of  " buffer underrun"  endof
         e  of  " eno"              endof
         f  of  " fno"              endof
        11  of  " time out"         endof
        12  of  " no address"       endof
                " unknown %x" 2 pick 
   endcase
   ]cmn-end 
;

\ Maybe show hardware errors
: ?.error  ( hw-err? | stat 0 -- hw-err? | stat 0 )
   dup  if
      .error
   then
;

\ Some next-transfer bits must be 0
\ XXX should be done when next transfer is allocated
: next-transfer!  ( n e-addr -- )
\   swap h# f invert and swap
   next-transfer le-l!
;

\ XXX to retire the endpoint, use my-endpoint to look at transfer head and
\ tail.  if equal, the endpoint has no transfer q left, and can be retired.
\ not quite.  there could be transfer descriptors still on the done q's, or
\ maybe in process in the chip.

\ direction bits for transfer descriptors:

00 constant setup-bits
01 constant out-bits
02 constant in-bits
