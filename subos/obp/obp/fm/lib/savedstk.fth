\ ========== Copyright Header Begin ==========================================
\ 
\ Hypervisor Software File: savedstk.fth
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
\ savedstk.fth 2.2 90/09/03
\ Copyright 1985-1990 Bradley Forthware

\ Converts stack addresses to the address of the corresponding location
\ in the stack save areas.

decimal
only forth also hidden also forth definitions

headerless
: rssave-end  ( -- adr )  rssave rs-size +  ;
: pssave-end  ( -- adr )  pssave ps-size +  ;

: in-return-stack?  ( adr -- flag )  rp0 @ rs-size -  rp0 @   between  ;
: in-data-stack?  ( adr -- flag )  sp0 @ ps-size -  sp0 @   between  ;

headers
\ Given an address within the stack, translate it to the corresponding
\ address within the saved stack area.
: >saved  ( adr -- save-adr )
   dup  in-data-stack?               ( adr flag )
   if  sp0 @ -  pssave-end +  then   ( adr' )
   dup  in-return-stack?             ( adr flag )
   if  rp0 @ -  rssave-end +  then   ( adr'' )
;
