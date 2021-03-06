\ ========== Copyright Header Begin ==========================================
\ 
\ Hypervisor Software File: probehub.fth
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
id: @(#)probehub.fth 1.1 07/01/24
purpose: USB hub probing code to support USB 1.1 devices downstream
\ See license at end of file

hex

\ There are two properties to support 1.1 hubs and devices:
\      hub20-dev
\      hub20-port
\
\ hub20-dev   is an integer property containing the assigned-address of
\             a USB 2.0 hub.
\ hub20-port  is an integer property containing the downstream port# (based 1)
\             of a USB 2.0 hub if the device attached to it is a 1.1 device.
\
\ For example, if we have the following physical topology:
\     USB 2.0 hub:   port 1:  2.0 disk
\                    port 2:  1.1 hub       port 1: disk
\                                           port 2: disk
\                    port 3:  1.1 mouse
\                    port 4:  none
\
\ Then /usb/hub has the "hub20-dev" property.
\      /usb/hub/hub has the "hub20-port" property of value 2.
\      /usb/hub/mouse has the "hub20-port" property of value 3.
\
\ In order to correctly communicate with the 1.1 hub and all the devices behind
\ it, the /usb/hub hub20-dev value and the /usb/hub/hub hub20-port value are
\ used in the Transaction Descriptor (qTD).
\
\ Likewise, to correctly communicate with the mouse, the /usb/hub hub20-dev
\ value and the /usb/hub/mouse hub20-port value are used in the qTD.

: ?set-hub20-port  ( speed dev port -- )
   " hub20-dev" my-parent ihandle>phandle get-package-property 0=  if
      2drop nip swap speed-high <>  if
         " hub20-port" int-property
      else
         drop
      then
   else
      3drop
   then
;
' ?set-hub20-port to make-dev-property-hook

: get-hub20-dev  ( -- hub-dev )
   " hub20-dev" get-inherited-property 0=  if
      decode-int nip nip
   else
      1
   then
;

: get-hub20-port  ( port -- port' )
   " hub20-port" get-inherited-property 0=  if
      rot drop				( $ )
      decode-int nip nip
   then
;

\ Initialize USB 2.0 specific characteristics in di
: set-usb20-char  ( port dev -- )
        get-hub20-dev  over di-hub!
   swap get-hub20-port swap di-port!
;

headers

\ LICENSE_BEGIN
\ Copyright (c) 2006 FirmWorks
\ 
\ Permission is hereby granted, free of charge, to any person obtaining
\ a copy of this software and associated documentation files (the
\ "Software"), to deal in the Software without restriction, including
\ without limitation the rights to use, copy, modify, merge, publish,
\ distribute, sublicense, and/or sell copies of the Software, and to
\ permit persons to whom the Software is furnished to do so, subject to
\ the following conditions:
\ 
\ The above copyright notice and this permission notice shall be
\ included in all copies or substantial portions of the Software.
\ 
\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
\ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
\ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
\ NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
\ LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
\ OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
\ WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
\
\ LICENSE_END
