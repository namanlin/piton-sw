\ ========== Copyright Header Begin ==========================================
\ 
\ Hypervisor Software File: ipreasm-h.fth
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
id: @(#)ipreasm-h.fth 1.1 04/09/07
purpose:
copyright: Copyright 2004 Sun Microsystems, Inc.  All Rights Reserved
copyright: Use is subject to license terms.

headerless

\ IP reassembly descriptor structure
struct
   /queue-entry	field  >iprd-link	\ Reassembly descriptor list 
   /queue-head  field  >iprd-hdlist	\ Frag hole descriptor list
   /n           field  >iprd-dgram	\ Reassembly buffer
   /w           field  >iprd-dgid	\ Datagram identifier
   /w           field  >iprd-dglen	\ Total length of datagram
   /ip-addr     field  >iprd-src	\ Source IP address
   /ip-addr     field  >iprd-dest	\ Destination IP address
   /timer       field  >iprd-ttl	\ TTL
   /c           field  >iprd-protocol	\ Datagram Protocol
constant /ipreasm-descriptor

d# 60000  constant  IP_REASM_TTL

\ Frag hole descriptor entry
struct
   /queue-entry field >ipfhd-link	\ frag hole descriptor list links
   /l           field >ipfhd-start	\ frag hole start
   /l           field >ipfhd-end	\ frag hole end
constant /ipf-hole-descriptor

: ipfhd-start@ ( ipfhd -- n )  >ipfhd-start l@ ;
: ipfhd-end@   ( ipfhd -- n )  >ipfhd-end   l@ ;

headers
