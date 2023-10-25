* SUBTTL 'Generic Parallel Device Handler Vector Table'

* GPDVV - Generic Parallel Device Handler Vector Table

 DTA A(GOP-1) ;perform generic parallel device OPEN
 DTA A(GCL-1) ;perform generic parallel device CLOSE
 DTA A(GGB-1) ;perform generic parallel device GET-BYTE
 DTA A(GPB-1) ;perform generic parallel device PUT-BYTE
 DTA A(GST-1) ;perform generic parallel device STATUS
 DTA A(GSP-1) ;perform generic parallel device SPECIAL
 JMP GIN      ;initialize generic parallel device
