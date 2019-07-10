/******************************************************************************
Project     : TWT
Description : Check the right size
Programmer  : Baccan Matteo
******************************************************************************/

#include "mripper.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION CheckMore( aStaticone,name,ext,length,filelen )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle,cBuff,lenout:=0,patt,t1,t2,nSizeImage:=0,nbit
LOCAL nOff := 0,patterntable:=0
LOCAL title:="",aSampl:={},ctemp:="",slength:=0,nPosit:=0,bigtotal:=0
LOCAL highpatt
LOCAL Is_ok := .T.
LOCAL nComp, nCol, nRow, nPlanes, nPaletteSize

IF !FCHECKMORE   // DO NOT PERFORM OTHER CHECKS...
   RETURN .T.
ENDIF

nHandle:=F_Fopen(name,2)
DO CASE


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="LBM" .or. ext=="AIF" .or. ext=="IFF" // guess
        cBuff := space(16)
        lenout:=fread(nHandle,@cBuff,16)
        IF lenout < 16
           Is_ok := .F.
        ELSE
           patt:= substr(cBuff,9,8)
           IF (EXT=="LBM".AND.( left(PATT,4)$"PBM ILBM".and.right(patt,4)$"BMHDANNO"   )) .or.;
              (EXT=="AIF".AND.(PATT=="AIFFCOMM")) .or.;
              (EXT=="IFF".AND.(PATT=="8SVXVHDR".OR.PATT=="8SVXNAME"))
              lenout:=bin2l(substr(cBuff,8,1)+;
                            substr(cBuff,7,1)+;
                            substr(cBuff,6,1)+;
                            substr(cBuff,5,1) ) +8
              IF length >= lenout
                 fseek(nHandle,0,0)
                 fseek(nHandle,lenout,0)
                 fwrite(nHandle,"")
              ELSE
                 Is_ok := .F. // incontrata sporcizia dopo FORM
              ENDIF
           ELSE
              Is_ok := .F.
           ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="XMI"                  // guess
        cBuff := space(128)
        lenout:=fread(nHandle,@cBuff,128)
        IF lenout < 128
           Is_ok := .F.
        ELSE
           IF substr(cbuff,23,4)+;
              substr(cbuff,31,8)+;
              substr(cbuff,43,8)=="CAT XMIDFORMXMIDTIMB"
              lenout:=bin2l(substr(cBuff,30,1)+;
                            substr(cBuff,29,1)+;
                            substr(cBuff,28,1)+;
                            substr(cBuff,27,1) ) +30

              IF length >= lenout
                 fseek(nHandle,0,0)
                 fseek(nHandle,lenout,0)
                 fwrite(nHandle,"")
              ELSE
                 is_ok:=.F.
              ENDIF
           ELSE
              is_ok:=.F.
           ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="SAT"   // Routine in FMEXT 2.1 molto bacata e rivista da me...
        cBuff := space(3000) // minimum ???
        lenout:=fread(nHandle,@cBuff,3000)
        if lenout == 3000
           nbit := asc(substr(cbuff,5,1))
           do case

              case left(cbuff,4)=="SAdT" .and. nbit < 5
                patt := bin2w(substr(cbuff,1098,2))
                lenout := (patt*2880) + 1103

              case left(cbuff,4)=="SAdT" .and. nbit >= 5 .and. nbit <= 7
                patt := bin2w(substr(cbuff,1095,2))
                lenout := (patt*2880) + 1612

              case left(cbuff,4)=="SAdT" .and. nbit >= 7 .and. nbit <= 9
                patt := bin2w(substr(cbuff,1095,2))
                nPosit:=ctemp:=0
                for t1 := 1 to patt
                  for t2 := 1 to 9
                      noff := 1613+(9*(t1-1))+(t2-1)
                      ctemp:= asc(substr(cbuff,noff,1))
                      nposit:=max(nposit,ctemp)
                  next
                next
                lenout := 2190 + (nposit * 192)
                if nbit # 9
                   lenout -= 2 // i pattern iniziano da 2188 e non da 2190
                endif

              case left(cbuff,4)=="SAdT" .and. nbit > 9
                   is_ok:=.f.
              case left(cbuff,4)=="CSAT"
                lenout := length        //// ehm... da rivedere!


           endcase
           IF lenout <= length .and. is_ok
              fseek(nHandle,0,0)
              fseek(nHandle,lenout,0)
              fwrite(nHandle,"")
           ELSE
              is_ok:=.F.
           ENDIF

        else
           is_ok:=.F.
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="D00"                  // guess
        cBuff := space(128)
        lenout:=fread(nHandle,@cBuff,128)
        IF lenout < 128
           Is_ok := .F.
        ELSE
           lenout:=bin2w(substr(cBuff ,114,2))
           IF lenout <= length
              fseek(nHandle,0,0)
              fseek(nHandle,lenout,0)
              fwrite(nHandle,"")
           ELSE
              is_ok:=.F.
           ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="MID"                  // guess + dox
        cBuff := space(14)
        NBIT  :=fread(nHandle,@cBuff,14)
        bigtotal:=14
        IF nbit < 14
           Is_ok := .F.
        ELSE
           t1:= bin2w(substr(cBuff,12,1)+substr(cBuff,11,1))
           IF t1 < 1
              Is_ok := .F.
           ELSE
              FOR T2 := 1 TO T1
                  cBuff := space(8)
                  NBIT  := fread(nHandle,@cBuff,8)
                  bigtotal+=8
                  IF NBIT < 8 .OR. LEFT(CBUFF,4) # "MTrk"
                     Is_ok := .F.
                     EXIT
                  ELSE
                     NPOSIT:=bin2l(substr(cBuff,8,1)+;
                                   substr(cBuff,7,1)+;
                                   substr(cBuff,6,1)+;
                                   substr(cBuff,5,1) )
                     bigtotal+=nposit
                     IF bigtotal > length
                        is_ok:=.F.
                        exit
                     ELSE
                        fseek(nHandle,nposit,1)
                     ENDIF

                  ENDIF
              NEXT
              IF is_ok
                 fwrite(nHandle,"")
                 lenout :=bigtotal
              ENDIF

           ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="RA"                  // guess

        Cbuff := space(22)
        if (lenout:=fread(nHandle,@cBuff,22)) == 22
           BIGTOTAL :=lenout
           t1 :=  bin2l(substr(cBuff,22,1)+;
                        substr(cBuff,21,1)+;
                        substr(cBuff,20,1)+;
                        substr(cBuff,19,1) )  // data len ???

           for ctemp := 1 to 3 // maybe @ off 5 -> chr(3)
               cbuff:=chr(0)
               if (lenout:=fread(nHandle,@cBuff,1)) == 1 .and.;
                  cbuff # chr(0)
                  ++BIGTOTAL
                  t2:=asc(cbuff)
                  cbuff:=space(t2)
                  if (lenout:=fread(nHandle,@cBuff,t2)) == t2
                     BIGTOTAL +=t2
                  else
                     is_ok:=.f.
                     exit
                  endif

               else
                  is_ok:=.f.
                  exit
               endif
           next
           if is_ok
              BIGTOTAL += 2+t1  // after the 3 texts there are 2 chr(0)
              if BIGTOTAL<=length .and. BIGTOTAL > 22
                 lenout := BIGTOTAL
                 fseek(nhandle,0,0)
                 fseek(nhandle,BIGTOTAL,0)
                 fwrite(nhandle,"")
              else
                 is_ok:=.f.
              endif
           endif
        else
           is_ok:=.f.
        endif


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="PAT"                  // guess (pur avendone il doc!)
                                    // 0c6h = n. samples in patch
                                    // 0efh = 060h byte dati
                                    //        +8 = sample length

        cBuff := space(239)
        lenout:=fread(nHandle,@cBuff,239)
        BIGTOTAL :=0
        IF lenout < 239
           Is_ok := .F.
        ELSE
           BIGTOTAL+=239
           PATT:=bin2W(substr(CBUFF,199,2))
           WHILE PATT>0
                 cBuff := space(96)
                 lenout:=fread(nHandle,@cBuff,96)
                 IF LENOUT=96
                    BIGTOTAL+=96
                    T1:=BIN2L(SUBSTR(CBUFF,9,4))
                    IF T1>0 .AND. T1<1048576     // GUSSES HAVE 1Mb MAX MEM!
                       FSEEK(nHandle,T1,1)
                       BIGTOTAL+=T1
                       patt--
                    ELSE
                       PATT=0
                       Is_ok := .F.
                    ENDIF

                 ENDIF

           ENDDO
           IF Is_Ok
              FWRITE(nHandle,"")
              lenout:=bigtotal
           endif

        endif

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="MED"                  // guess
        cBuff := space(2000)
        lenout:=fread(nHandle,@cBuff,2000)
        IF lenout < 2000
           Is_ok := .F.
        ELSE
           IF substr(cbuff,4,1) $ "01" .and. substr(cbuff,5,1)==chr(0)
              lenout:=bin2l(substr(cBuff,8,1)+;
                            substr(cBuff,7,1)+;
                            substr(cBuff,6,1)+;
                            substr(cBuff,5,1) )

              IF length >= lenout
                 fseek(nHandle,0,0)
                 fseek(nHandle,lenout,0)
                 fwrite(nHandle,"")
              ELSE
                 // trovato un MMD che conteneva MMD all'interno...
                 IF filelen-START_POS >= lenout
                    t1:=F_fopen( PARM )
                    fseek(nHandle,0,2)
                    fseek(t1,START_POS+length,0)
                    t2:= lenout-length          // quanti byte mancano
                    IF t2 >  BUFLEN // non Š che servirebbe, pero'...
                       for ctemp := 1 to int( t2 / BUFLEN )
                           cbuff:=space( BUFLEN )
                           nbit := fread(t1,@cbuff,BUFLEN)
                           nbit := fwrite(nHandle,cbuff,BUFLEN)
                       next
                    ENDIF
                    ctemp := int(t2 % BUFLEN)
                    IF ctemp > 0  // ops...
                       cbuff:= space( ctemp )
                       nbit := fread(t1,@cbuff,ctemp)
                       nbit := fwrite(nHandle,cbuff,ctemp)
                    ENDIF
                    fclose(t1)
                    length := lenout
                 ELSE
                    Is_ok := .F.
                 ENDIF
              ENDIF
           ELSE
              is_ok:=.F.
           ENDIF
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="MTR"                  // guess
        cBuff := space(6)
        fread(nHandle,@cBuff,6)
        do case
           case cbuff== "MDRAW "

                fseek(nhandle,24,0)
                cBuff := space(8)
                if fread(nHandle,@cBuff,8) == 8
                   if left(cbuff,1) <= "7"
                      if (lenout:= (dfhex2dec(left(cbuff,4))*65536+dfhex2dec(right(cbuff,4))) ) > 0
                         lenout+=818
                      else
                         is_ok:=.F.
                      endif
                   else
                      is_ok:=.F.
                   endif
                else
                   is_ok:=.F.
                endif


           case cbuff== "MTRACK"
                fseek(nhandle,33,0)
                cBuff := space(8)
                if fread(nHandle,@cBuff,8) == 8
                   if left(cbuff,1) <= "7"
                      if (lenout:= (dfhex2dec(left(cbuff,4))*65536+dfhex2dec(right(cbuff,4))) ) > 0
                         lenout+=50
                      else
                         is_ok:=.F.
                      endif
                   else
                      is_ok:=.F.
                   endif
                else
                   is_ok:=.F.
                endif

           otherwise
                is_ok:=.F.
        endcase
        if is_ok .and. length >= lenout
           fseek(nHandle,0,0)
           fseek(nHandle,lenout,0)
           fwrite(nHandle,"")
        endif


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="BMP"                  // from teo
        cBuff := space(60)
        lenout:=fread(nHandle,@cBuff,60)
        // new check  3-05-96
        IF lenout < 60                   .or. ;
           bin2l(substr(cbuff, 6,4))# 0  .or. ;
           bin2w(substr(cbuff,15,2))# 40
           Is_ok := .F.
        ELSE
           t1 := bin2l(substr(cBuff,3,4)) // lunghezza dichiarata dopo BM
           cBuff:="  "
           FSEEK( nHandle, dfHex2Dec("001C"), 0 )
           FREAD( nHandle, @cBuff, 2 )
           nBit := BIN2I( cBuff )
           cBuff:="    "
           FSEEK( nHandle, dfHex2Dec("0022"),0 )
           FREAD( nHandle, @cBuff, 4 )
           nSizeImage := BIN2L( cBuff )

           cBuff:="  "
           FSEEK( nHandle, dfHex2Dec("001E"), 0 )
           FREAD( nHandle, @cBuff, 2 )
           nComp := BIN2I( cBuff )*256*256

           FSEEK( nHandle, dfHex2Dec("0020"), 0 )
           FREAD( nHandle, @cBuff, 2 )
           nComp += BIN2I( cBuff )

           IF nComp==0
              Is_ok := (nbit == 1 .or. ;
                        nbit == 4 .or. ;
                        nbit == 8 .or. ;
                        nbit == 24 )
              IF Is_ok
                 cBuff:="    "
                 FSEEK( nHandle, dfHex2Dec("0012"), 0 )
                 FREAD( nHandle, @cBuff, 4 )
                 nCol := BIN2L( cBuff )

                 FSEEK( nHandle, dfHex2Dec("0016"), 0 )
                 FREAD( nHandle, @cBuff, 4 )
                 nRow := BIN2L( cBuff )

                 cBuff:="  "
                 FSEEK( nHandle, dfHex2Dec("001A"), 0 )
                 FREAD( nHandle, @cBuff, 2 )
                 nPlanes := BIN2I( cBuff )

                 // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                 // Sempre giusto tranne che per le RLE bitmap                              //³
                 //                                                                         //³
                 nPaletteSize := INT(2^nBit)*4 +54                                          //³
                 IF nBit==24 // La palette e' troppo grossa e NON viene messa nel bitmap    //³
                    nPaletteSize := 54 // 54 e' la grandezza dell'header                    //³
                 ENDIF                                                                      //³
                 t1 := nRow * INT(((nPlanes*nBit*nCol)+31)/32) *4 +nPaletteSize             //³
                 // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                 Is_ok := t1>=60
              ENDIF
           ELSE
       //       IF t1 < 0 .or. t1 > 4096^2 // errata?
                 IF (nbit == 1 .or. ;
                     nbit == 4 .or. ;
                     nbit == 8 .or. ;
                     nbit == 24 ) .and. ;
                    nSizeImage >0 //.and. nSizeImage < length

                    t1:=INT(nSizeImage +(2^nBit)*4 +54) // ricalcolo
                 ELSE
                    t1:=length+1 //forzo il prossimo check a .F.
                 ENDIF
       //       ELSE
       //        IF !(nbit == 1 .or. ;
       //             nbit == 4 .or. ;
       //             nbit == 8 .or. ;
       //             nbit == 24 )      // anche se la lungh. sembra giusta
       //                               // devo controllare che abbia nBit ok
       //            t1 := length+1
       //        ENDIF
       //       ENDIF
           ENDIF
           IF t1 <= length
              fseek(nHandle,0,0)
              fseek(nHandle,t1,0)
              fwrite(nHandle,"")

              lenout := t1
              Is_ok  := lenout>=60
           ELSE
              lenout := t1
              IF filelen-START_POS >= lenout
                 t1:=F_fopen( PARM )
                 fseek(nHandle,0,2)
                 fseek(t1,START_POS+length,0)
                 t2:= lenout-length
                 IF t2 >  BUFLEN
                    for ctemp := 1 to int( t2 / BUFLEN )
                        cbuff:=space( BUFLEN )
                        nbit := fread(t1,@cbuff,BUFLEN)
                        nbit := fwrite(nHandle,cbuff,BUFLEN)
                    next
                 ENDIF
                 ctemp := int(t2 % BUFLEN)
                 IF ctemp > 0  // ops...
                    cbuff:= space( ctemp )
                    nbit := fread(t1,@cbuff,ctemp)
                    nbit := fwrite(nHandle,cbuff,ctemp)
                 ENDIF
                 fclose(t1)
                 length := lenout
              ELSE
                 Is_ok := .F.
              ENDIF
           ENDIF
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*
   // Questo filtro estrae correttamente oltre al 90% dei font
   case ext=="F16" .OR. ;   // 16/8 bits font by $åŸçW­zàâë
        ext=="F8"

        T1 := VAL(SUBSTR(EXT,2,2))
        T2 := T1 * 256
        patt := REPLICATE(CHR(0),T1)

        cBuff := space(t2)
        lenout:= fread(nHandle,@cBuff,t2)
        Is_ok := !(lenout < t2                         .OR. ;
                   !(SUBSTR(cBuff, 1    ,T1) == patt ) .OR. ;
                   !(SUBSTR(cBuff, 32*T1,T1) == patt ) .OR. ;
                   !(SUBSTR(cBuff,255*T1,T1) == patt )      )

        IF Is_ok
           Is_ok := !(patt $ SUBSTR(cBuff,97*T1,26*T1))
        ENDIF

        IF Is_ok
           fseek(nHandle,t2,0)
           fwrite(nHandle,"")
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="TIF"                  // dox

        is_ok := .F.
        cbuff:=space(8)
        t1  := fread(nHandle,@cbuff,8 )
        noff := bin2l( right(cbuff,4) )
        IF noff > length
           nSizeImage := -1
        ELSE
           while noff > 0
                 fseek(nHandle,noff,0)
                 cbuff := space(2)
                 t1 := fread(nHandle,@cbuff,2 )
                 IF t1 # 2
                    //? "Invalid Offset: additional IFD"
                    // Warning: GDS 3.1f doesn't create regular TIFFs!!!
                    nSizeImage := -1
                    exit
                 ENDIF

                 nbit := bin2w(cbuff) // tag Counter
                 IF nbit < 1
                    //? "Invalid IFD Tag counter (0)"
                    nSizeImage := -1
                    exit
                 ELSE
                    for t2 := 1 to nbit
                        cbuff := space(12)
                        t1 := fread(nHandle,@cbuff,12 )
                        IF t1 # 12
                           //? "Incomplete IFD Tag"
                           nSizeImage := -1
                           exit
                        ELSE
                           slength := bin2w(substr(cbuff,3,2))  // tagtype
                           bigtotal:= bin2l(substr(cbuff,5,4))   // taglen
                           nPosit  := bin2l(right(cbuff,4))      // tagoffs
                           /*
                           tagtypes:
                           1 = BYTE     8-bit unsigned integer.
                           2 = ASCII    8-bit bytes that store ASCII codes; the last byte must be null.
                           3 = SHORT    16-bit (2-byte) unsigned integer.
                           4 = LONG     32-bit (4-byte) unsigned integer.
                           5 = RATIONAL Two LONG's:  the first represents the numerator of a fraction,
                                        the second the  denominator.
                           */
                           IF slength > 5
                              //? "Invalid tag type"
                              nSizeImage := -1
                              exit
                           ELSE
                              IF slength >= 3
                                 bigtotal := int(bigtotal*(2^(slength-2)))
                              ENDIF
                              IF bigtotal <= 4 // tagoffs conterrebbe gi… il valore, non l'offset
                                 loop        // dove andarlo a cercare...
                              ENDIF
                              nposit += bigtotal
                              IF nposit > length
                                 //?"Tag would exceed EOF"
                                 nSizeImage := -1
                                 exit
                              ELSE

                                 nsizeimage := max (nsizeimage,nposit )

                              ENDIF
                           ENDIF

                        ENDIF

                    next
                    IF nSizeImage = -1
                       exit
                    ENDIF
                    cbuff := space(4)
                    t1 := fread(nHandle,@cbuff,4 )
                    noff := bin2l( cbuff )

                 ENDIF
                 IF nSizeImage = -1
                    exit
                 ENDIF

            enddo
            IF nSizeImage # -1
               is_ok := .T.
               lenout := nSizeImage
               fseek(nHandle,0,0)
               fseek(nHandle,nSizeImage,0)
               fwrite(nHandle,"")
            ENDIF

        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="PCX"                  // decoder from 2obj... "slightly" modified
        is_ok:=.T.
        cBuff := space(128)
        lenout:=fread(nHandle,@cBuff,128)
        IF lenout < 128 //.or. left(cbuff,3) # chr(10)+chr(5)+chr(1)
           Is_ok := .F.
        ELSE
           //IF substr(cBuff,5,4) == chr(0)+chr(0)+chr(0)+chr(0)  // ho trovato un PCX con XMIN a 1, cazzo!
           IF (bin2w(substr(cBuff,5,2)) <= bin2w(substr(cBuff, 9,2)) .and. ;
               bin2w(substr(cBuff,7,2)) <= bin2w(substr(cBuff,11,2)) )
              IF !(substr(cBuff,4,1) $ chr(8)+chr(4)+chr(2)+chr(1))
                 Is_ok := .F.
              ELSE
                 //BPL = BytesPerLine * Planes
                 slength := bin2w( substr(cbuff,67,2)) * ;
                            asc(   substr(cbuff,66,1))
                 //Height = (YMax - YMin) + 1;
                 highpatt :=bin2w( substr(cbuff,11,2)) - ;
                            bin2w( substr(cbuff, 7,2))
                 IF highpatt > 0 .and. highpatt < 4096
                    highpatt++
                    is_ok := DecodePCX( nHandle, slength, highpatt )
                    //       ^^^^^^^^^ yes! 1st C Func
                 ELSE
                    is_ok := .F.
                 ENDIF
                 IF is_ok

                    cbuff:=" "
                    IF fread(nHandle,@cbuff,1) == 1
                       IF asc(cbuff) == 12  // palette flag
                          cbuff:=Space(768)
                          fread(nHandle,@cbuff,768) // e non un fseek!
                       ELSE
                          fseek(nHandle,-1,1) // mi riposiziono
                       ENDIF
                    ENDIF
                    lenout := fseek(nhandle,0,1)
                    IF length > lenout
                       fwrite(nHandle,"")
                    ENDIF
                 ENDIF
              ENDIF
           ELSE
              Is_ok := .F.
           ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="GIF"                  // taken decoder from 2OBJ.ZIP (TYPES.C)
        cBuff := space(13)
        is_ok:=.F.
        NBIT  :=fread(nHandle,@cBuff,13)
        IF nbit = 13 .and. substr(cBuff,5,2) $ "7a9a"

           nbit:=3*int(2^(dfand(asc(substr(cbuff,11,1)),7)+1)) // palette
           fseek(nHandle,nbit,1)
           bigtotal := 0
           while .T.
                 cbuff:=" "
                 IF (fread(nHandle,@cbuff,1)) # 1
                    exit
                 ENDIF
                 DO CASE
                    CASE cbuff == "," // image descriptor
                         cbuff:=space(9)
                         IF (fread(nHandle,@cbuff,9)) # 9
                            exit
                         ENDIF
                         IF dfand(asc(right(cbuff,1)),128) == 128 // LOCAL color map
                            nbit:=3*int(2^(dfand(asc(right(cbuff,1)),7)+1)) // palette
                            fseek(nHandle,nbit,1)
                         ENDIF
                         bigtotal++
                         IF !ReadGIFDataBlock(nHandle)
                            exit
                         ENDIF

                    CASE cbuff == ";"  // I'll be back... (Terminator)
                         IF bigtotal > 0
                            is_ok := .T.
                         ENDIF
                         exit

                    CASE cbuff == "!"
                         IF !ReadGIFDataBlock(nHandle)
                            exit
                         ENDIF

                ENDCASE
           enddo
           IF is_ok
              lenout := fseek(nhandle,0,1)
              fwrite(nHandle,"")
           ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="PNG"                  // 1st chunk scanner in MRIP!  7-29-95  9:51pm
        Is_ok := .F.
        noff:=t1:=0
        fseek(nHandle,0,0)
        fseek(nHandle,8,0)
        noff+=8
        while .T.
              ++t1
              cbuff:=Space(8)
              slength:=fread(nHandle,@cbuff,8)
              noff+=8
              IF slength # 8
                 exit
              ELSE
                 IF t1 == 1 .and. right(cbuff,4) # "IHDR" // 1st chunk name
                    exit
                 ENDIF
                 IF right(cbuff,4) == "IEND"
                    Is_ok := .T.   // terminator reached: truncate here!
                    exit
                 ELSE
                    ctemp  :=bin2l(substr(cbuff,4,1)+;
                                   substr(cbuff,3,1)+;
                                   substr(cbuff,2,1)+;
                                   substr(cbuff,1,1) )+4 // 4 chars of chunk crc...
                    noff+=ctemp
                    IF  noff > filelen
                        exit
                    ELSE
                        fseek(nHandle,ctemp,1)
                    ENDIF

                 ENDIF

              ENDIF
        enddo
        IF is_ok
           IF filelen >= noff+4
              fseek(nHandle,4,1) // fixx: 4 byte CRC
              lenout:=noff+4
              fwrite(nHandle,"")
           ELSE
              is_ok  := .F.
           ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="MOD"                  // dox + guess
        cBuff := space(2112)        // 4ch*1pattern*1position+sample di 2bytes!
        lenout:=fread(nHandle,@cBuff,2112)
        IF lenout < 2112
           Is_ok := .F.
        ELSE
            patt:=0
            IF "M.K." $ cBuff
               patt++
            ENDIF
            IF "FLT4" $ cBuff
               patt++
            ENDIF
            IF "FLT8" $ cBuff
               patt++
            ENDIF
            IF "6CHN" $ cBuff
               patt++
            ENDIF
            IF "8CHN" $ cBuff
               patt++
            ENDIF
            IF "12CH" $ cBuff
               patt++
            ENDIF
            IF "16CH" $ cBuff
               patt++
            ENDIF
            IF "32CH" $ cBuff
               patt++
            ENDIF
            IF "SCRM" $ cBuff
               patt++
            ENDIF
            IF patt >1
               Is_ok := .F.
            ELSE
               cbuff:=left(cbuff,1084)
               for nOff:= 0 to 30  // 31 samples
                   t1:=( (asc(substr(cbuff, 21+(30*nOff)+22, 1))*256)+;
                          asc(substr(cbuff, 21+(30*nOff)+23, 1)) )*2
                   IF t1 > 65535
                      exit
                   ENDIF
                   slength+=t1
               next
               IF t1 > 65534 .OR. SLENGTH = 0
                  Is_ok := .F.
               ELSE
                  nPosit:=asc(substr(cbuff,951,1)) // quanti posistion devo leggere?
                  IF nposit > 0 .and. nposit < 129
                     bigtotal:=0
                     for noff:= 1 to nPosit
                         highpatt:=asc(substr(cbuff,952+noff,1))
                         IF highpatt > bigtotal
                            bigtotal:= highpatt
                         ENDIF
                     next
                     highpatt:=bigtotal+1 // anche il pattern 0 conta...
                     ctemp:=right(cbuff,4)
                     DO CASE
                        CASE ctemp $ "M.K.M!K!FLT4"
                             noff:=4
                        CASE ctemp == "6CHN"
                             noff:=6
                        CASE ctemp $ "8CHNFLT8CD81OCTA"
                             noff:=8
                        CASE right(ctemp,2) == "CH"  // 10CH, 12CH,...32CH
                             noff:=val( left(ctemp,2) )
                        OTHERWISE
                             noff:=0
                     ENDCASE
                     IF noff > 0
                        patterntable := 4*noff*highpatt*64
                        bigtotal:=lenout:=1084+patterntable+slength
                        IF length < bigtotal
                           Is_ok := .F.
                        ELSE
                           // es. un 16CH falso (M.K.) si espanderebbe anche
                           // se la lunghezza Š gi… giusta
                           fseek(nHandle,0,0)
                           fseek(nHandle,bigtotal,0)
                           fwrite(nHandle,"")
                        ENDIF
                     ELSE
                        Is_ok := .F.
                     ENDIF
                  ELSE
                     Is_ok := .F.
                  ENDIF

               ENDIF
            ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="S3M"                  // dox
        cBuff := space(96)
        NBIT  :=fread(nHandle,@cBuff,96)
        bigtotal:=96
        IF nbit < 96
           Is_ok := .F.
        ELSE
           t1 := bin2w(substr(cBuff,33,2)) // ordnum
           t2 := bin2w(substr(cBuff,35,2)) // insnum
           patt:=bin2w(substr(cBuff,37,2)) // patnum
           IF t1 > 1 .and. t1 < 256 .and. t2 <= 100 .and. patt <= 100
              fseek(nHandle,t1,1) // posiziono sul primo ins. pointer
              for ctemp := 1 to t2*2 step 2
                  cbuff:= "  "
                  nbit := fread( nHandle,@cbuff,2)
                  IF nbit # 2
                     is_ok:=.F.
                     exit
                  ELSE
                     aadd(aSampl,(bin2w(cbuff)*16))
                  ENDIF
              next
              IF is_ok   // patterns
                 highpatt:={}
                 for ctemp := 1 to patt*2 step 2
                     cbuff:= "  "
                     nbit := fread( nHandle,@cbuff,2)
                     IF nbit # 2
                        is_ok:=.F.
                        exit
                     ELSE
                        aadd(highpatt,(bin2w(cbuff)*16))
                     ENDIF
                 next
              ENDIF
              IF is_ok
                 for ctemp := 1 to t2
                     fseek(nHandle,0,0)             // per la verit… sarebbero
                     fseek(nHandle,aSampl[ctemp],0) // contigui...ma faccio le
                                                    // cose come vanno fatte!
                     cbuff:=space(80)
                     nbit := fread( nHandle,@cbuff,80)
                     IF nbit # 80
                        is_ok:=.F.
                        exit
                     ELSE
                        IF left(cbuff,1) == chr(1) .and. right(cbuff,4) == "SCRS"
                           noff := int(bin2l(substr(cbuff,14,3)+chr(0) ) /16)
                           IF noff > 0 // non si sa mai
                              noff+= bin2w(substr(cbuff,17,2))
                              bigtotal := max( bigtotal, noff )
                              IF bigtotal > length
                                 is_ok:=.F.
                                 exit
                              ENDIF
                           ENDIF
                        ENDIF
                     ENDIF
                 next
                 IF is_ok
                    for ctemp := 1 to patt
                        IF highpatt[ctemp] == 0 // possono essercene e vanno skippati
                           loop
                        ENDIF
                        fseek(nHandle,0,0)               // per la verit… sarebbero
                        fseek(nHandle,highpatt[ctemp],0) // contigui...ma faccio le
                                                         // cose come vanno fatte!
                        cbuff:=space(2)
                        nbit := fread( nHandle,@cbuff,2)
                        IF nbit # 2
                           is_ok:=.F.
                           exit
                        ELSE
                           noff := highpatt[ctemp] + bin2w(cbuff)
                           bigtotal := max( bigtotal, noff )
                           IF bigtotal > length
                              is_ok:=.F.
                              exit
                           ENDIF

                        ENDIF
                    next
                 ENDIF
                 IF is_ok
                    fseek(nHandle,0,0)
                    fseek(nHandle,bigtotal,0)
                    fwrite(nHandle,"")
                    lenout := bigtotal
                 ENDIF
              ENDIF
           ELSE
              is_ok:=.F.
           ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="XM"                   // dox
        cBuff := space(80)
        NBIT  :=fread(nHandle,@cBuff,80)
        IF nbit < 80 .or.; // substr(cbuff,39,16) # "FastTracker v2.0" .or.;
           asc(substr(cbuff,60,1)) # 1 // maj. version 1.
           Is_ok := .F.
        ELSE
           noff := bin2w(substr(cBuff,61,2)) // header length -> start patterndata
           t2 := bin2w(substr(cBuff,73,2)) // insnum
           patt:=bin2w(substr(cBuff,71,2)) // patnum
           IF t2 <= 128 .and. t2 >0 .and. patt <= 256 .and. noff = 276 // fissi
              fseek(nHandle,336,0) // posiziono sul primo pattern pointer
              bigtotal:= 336
              for ctemp := 1 to patt
                  cbuff:= space(9)
                  nbit := fread( nHandle,@cbuff,9)
                  IF nbit # 9 .or. asc(left(cbuff,1)) # 9
                     is_ok:=.F.
                     exit
                  ELSE
                     bigtotal+=9
                     nbit := bin2w( right(cbuff,2) )
                     IF (bigtotal+=nbit) < length
                        fseek(nHandle,nbit,1)
                     ELSE
                       is_ok:=.F.
                       exit
                     ENDIF
                  ENDIF
              next
              IF is_ok   // instr+samples
                 FOR ctemp := 1 TO t2
                     cbuff:= space(4)
                     nbit := fread( nHandle,@cbuff,4)
                     IF nbit # 4
                        is_ok:=.F.
                        EXIT
                     ELSE
                        bigtotal+=4
                        IF (slength := bin2w(left(cbuff,2))-4) > 0 // tolgo i 4 bytes gi… letti
                           cbuff:= space(slength)
                           nbit := fread( nHandle,@cbuff,slength)
                           IF nbit # slength
                              is_ok:=.F.
                              EXIT
                           ELSE
                              bigtotal+=slength
                              highpatt:=bin2w(substr(cbuff,24,2))
                              noff:=0
                              WHILE highpatt > 0
                                    cbuff:=space(40)
                                    nbit := fread( nHandle,@cbuff,40)
                                    IF nbit # 40
                                       is_ok:=.F.
                                       exit
                                    ELSE
                                       bigtotal+=40
                                       noff+=bin2l(left(cbuff,4)) // sample length
                                       highpatt--
                                       IF (bigtotal+noff) > length
                                          is_ok:=.F.
                                          exit
                                       ENDIF
                                    ENDIF

                              ENDDO
                              IF !is_ok
                                 exit
                              ELSE
                                 fseek(nHandle,noff,1)
                                 bigtotal+=noff
                              ENDIF
                           ENDIF
                        ELSE
                           /* guess: */
                           /* uno strumento non pu• avere lunghezza 0*/
                           /* pu• solo avere 0 samples o 1 sample lungo 0*/
                           is_ok:=.F.
                           exit
                        ENDIF
                     ENDIF
                 next
              ENDIF
              IF is_ok
                 fseek(nHandle,0,0)
                 fseek(nHandle,bigtotal,0)
                 fwrite(nHandle,"")
                 lenout := bigtotal
              ENDIF
           ELSE
              is_ok:=.F.
           ENDIF

        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="AMF"                  // still waiting 4 dox
        cBuff := space(16)
        lenout:=fread(nHandle,@cBuff,16)
        IF lenout < 16 .or. length < 3000
           Is_ok := .F.
        ELSE
           t1:= asc(substr(cBuff,4,1))
           IF t1 < 9 .or. t1 > 16 // e speriamo non vada avanti...
              Is_ok := .F.
           ENDIF
           //lenout := length
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="STM"                  // maybe..
        cBuff := space(3000)
        lenout:=fread(nHandle,@cBuff,3000)
        IF lenout < 3000 .or. length < 3000
           Is_ok := .F.
        ELSE
           IF !(substr(cBuff,21,8) $ "!Scream!BMOD2STM")
              Is_ok := .F.
           ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="DMF"                  // 2nd chunk scanner in MRIP!   7-29-95 10:35pm
        Is_ok := .F.
        noff:=0
        //t1:=1 // 1st chunk = 66 bytes
        fseek(nHandle,0,0)
        fseek(nHandle,66,0)
        noff+=66
        while .T.
              //++t1
              cbuff:=Space(4)
              slength:=fread(nHandle,@cbuff,4)
              noff+=4
              IF slength # 4
                 exit
              ELSE
                 IF !(cbuff $ "INFO CMSG SEQU PATT SMPI SMPD ENDE")
                            // ^^^^ not sure if it exists anymore...
                    exit
                 ENDIF
                 IF cbuff=="ENDE"
                    Is_ok := .T.   // terminator reached: truncate here!
                    exit
                 ELSE
                    cbuff:=Space(4)
                    slength:=fread(nHandle,@cbuff,4)
                    noff+=4
                    IF slength # 4
                       exit
                    ELSE
                       ctemp := bin2l(cbuff)
                       noff+=ctemp
                       IF  noff > filelen
                           exit
                       ELSE
                           fseek(nHandle,ctemp,1)
                       ENDIF
                    ENDIF

                 ENDIF

              ENDIF
        enddo
        IF is_ok
           lenout:=noff
           fwrite(nHandle,"")
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="ULT"                  // dox but incomplete
        cBuff := space(15)
        lenout:=fread(nHandle,@cBuff,15)
        IF lenout < 15 .or. length < 3000
           Is_ok := .F.
        ELSE
           t1:= val(right(cBuff,1))
           IF t1 < 1 .or. t1 > 4  // e speriamo non vada avanti...
              Is_ok := .F.
           ENDIF
           //lenout := length
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="FAR"                  // dox but incomplete
        cBuff := space(50)
        lenout:=fread(nHandle,@cBuff,50)
        IF lenout < 50 .or. length < 3000
           Is_ok := .F.
        ELSE
           IF !(right(cbuff,1) == chr(16) .and.;  // revision = 10h
                substr(cbuff,45,3) == chr(13)+chr(10)+chr(26) )  // eof after title
              Is_ok := .F.
           ENDIF
           //lenout := length
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="DSM"                  // guess
        cBuff := space(38)
        lenout:=fread(nHandle,@cBuff,38)
        IF lenout < 38 .or. length < 3000
           Is_ok := .F.
        ELSE
           patt:= substr(cBuff,1,4)
           IF patt == "RIFF"  // NEW 2.0
              lenout:=bin2l(substr(cBuff,5,4) )+8
              IF length >= lenout
                 fseek(nHandle,0,0)
                 fseek(nHandle,lenout,0)
                 fwrite(nHandle,"")
              ELSE
                 Is_ok := .F.
              ENDIF
           ELSE

              IF !(substr(cbuff,37,1) == chr(26) .and.;
                 str(asc(right(cbuff,1)),2,0) $ " 4- 8-16-32"  )
                 Is_ok := .F.
              ENDIF
           ENDIF
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="PTM"                  // dox but incomplete... no file 4 test
        cBuff := space(31)
        lenout:=fread(nHandle,@cBuff,31)
        IF lenout < 31 .or. length < 3000
           Is_ok := .F.
        ELSE
           IF right(cbuff,3) # chr(26)+chr(3)+chr(2) // eof + rev# (0203h)
              Is_ok := .F.
           ENDIF
           //lenout := length
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="PSM"                  // dox but incomplete... no file 4 test
        cBuff := space(86)
        lenout:=fread(nHandle,@cBuff,86)
        IF lenout < 86 .or. length < 3000
           Is_ok := .F.
        ELSE
           do case
              case left(cbuff,4)=="PSMş"
                   IF !(substr(cbuff,64,1) == chr(26) .and.;
                        substr(cbuff,66,1) == chr(10))
                      Is_ok := .F.

                   ENDIF

              case left(cbuff,4)=="PSM "  // guess
                   if substr(cbuff,9,4)=="FILE"
                      lenout := bin2l(substr(cbuff,5,4))+12
                      if lenout <= length .and. lenout > 3000
                         fseek(nhandle,0,0 )
                         fseek(nhandle,lenout,0)
                         fwrite(nhandle,"")
                      else
                         Is_ok := .F.
                      ENDIF
                   else
                      Is_ok := .F.
                   ENDIF

              case left(cbuff,4)=="PS16"
                   IF !(substr(cbuff,80,1) == chr(26) .and.;
                        substr(cbuff,81,1) == chr(0)  .and.;
                        substr(cbuff,86,1) == chr(0) )
                      Is_ok := .F.
                   ENDIF
           endcase
           //lenout := length
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="UNI"                  // no dox ... found UN04 and UN05
        cBuff := space(4)
        lenout:=fread(nHandle,@cBuff,4)
        IF lenout < 4  .or. length < 3000
           Is_ok := .F.
        ELSE
           t1 := val(substr(cbuff,4,1))
           IF t1 < 4 .or. t1 > 5  // da ampliare
              Is_ok := .F.
           ENDIF
           //lenout := length
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="OKT"                  // dox
        Is_ok := .F.
        noff:=nbit:=t1:=t2:=0
        fseek(nHandle,0,0)
        fseek(nHandle,24,0)
        noff+=24
        while .T.
              cbuff:=Space(4)
              slength:=fread(nHandle,@cbuff,4)
              noff+=4
              IF slength # 4
                 exit
              ELSE
                 IF !(cbuff $ "SAMP SPEE SLEN PLEN PATT PBOD SBOD")

                    exit
                 ENDIF
                 IF cbuff=="SAMP"
                    cbuff:=Space(4)
                    slength:=fread(nHandle,@cbuff,4)
                    noff+=4
                    IF slength # 4
                       exit
                    ELSE
                       ctemp := bin2l( substr (cbuff, 4,1)+;
                                       substr (cbuff, 3,1)+;
                                       substr (cbuff, 2,1)+;
                                       substr (cbuff, 1,1) ) /32

                       for t2 := 1 to ctemp
                           cbuff:=Space(32)
                           slength:=fread(nHandle,@cbuff,32)
                           noff+=32
                           IF slength # 32
                              nbit:=-1
                              exit
                           ELSE
                              IF bin2l(substr (cbuff,24,1)+;
                                       substr (cbuff,23,1)+;
                                       substr (cbuff,22,1)+;
                                       substr (cbuff,21,1) ) > 0

                                 t1++ // se ha una lunghezza Š un sample
                              ENDIF
                           ENDIF
                       next
                       IF nbit == -1
                          exit
                       ELSE
                          loop // leggo il prossimo chunk
                       ENDIF
                    ENDIF
                 ELSE
                    IF cbuff=="SBOD"
                       --t1
                    ENDIF
                    cbuff:=Space(4)
                    slength:=fread(nHandle,@cbuff,4)
                    noff+=4
                    IF slength # 4
                       exit
                    ELSE
                       ctemp := bin2l(substr (cbuff, 4,1)+;
                                      substr (cbuff, 3,1)+;
                                      substr (cbuff, 2,1)+;
                                      substr (cbuff, 1,1) )

                       noff+=ctemp
                       IF  noff > filelen
                           exit
                       ELSE
                           fseek(nHandle,ctemp,1)
                       ENDIF
                       IF t1 = 0 // ho letto tutti gli SBOD
                          is_ok := .T.
                          exit

                       ENDIF
                    ENDIF

                 ENDIF

              ENDIF
        enddo
        IF is_ok
           lenout := noff
           fwrite(nHandle,"")
        ENDIF



*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="PLM"                  // Guess
        cBuff := space(96) // header len = off 0x04 ("`")
        patt := "PLS"+chr(26)+"H"
        lenout:=fread(nHandle,@cBuff,96)
        is_ok:=.f.
        if lenout == 96
           t1 := asc(substr(cbuff,93,1)) // # of samples
           is_ok:=IllBeBack(patt,nHandle,length,@nposit,aStaticone)
           if is_ok
              fseek(nHandle, 0,0)
              fseek(nHandle, nposit-(len(patt)),0)
              while .t. // t1>0
                 cbuff:=space(72) // sample header len ("H")
                 lenout:=fread(nHandle,@cBuff,72)
                 if lenout == 72 .and. left(cbuff,len(patt))==patt
                    t2 := bin2l(substr(cbuff,68,4))
                    if t2 < length
                       fseek(nHandle,t2,1)
                       //t1-- // non serve, alcuni sample possono non esserci
                    else
                       is_ok := .f.  // sample too big 2 b true!
                       exit
                    endif

                 else
                    //is_ok := .f.
                    fseek(nhandle,-(lenout),1)
                    exit
                 endif
              enddo
              if is_ok //.and. t1 == 0
                 lenout:=fseek(nhandle,0,1)
                 fwrite(nhandle,"")

              endif
           endif
        endif

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="LIQ"                  // Guess
        cBuff := space(14)
        NBIT  :=fread(nHandle,@cBuff,14)
        if cbuff=="Liquid Module:"
           fseek(nHandle, 0,0)
           patt := "LDSS"+chr(0)
           is_ok:=IllBeBack(patt,nHandle,length,@nposit,aStaticone)
           if is_ok
              fseek(nHandle, 0,0)
              fseek(nHandle, nposit-(len(patt)),0)
              while .t. // t1>0
                 cbuff:=space(4)
                 lenout:=fread(nHandle,@cBuff,4)
                 if lenout==4
                    do case
                    case cbuff == "LDSS"
                       cbuff:=space(140)
                       if (lenout:=fread(nHandle,@cBuff,140)) == 140
                          t2 := bin2l(substr(cbuff,74,4))  // 0x4d
                          if t2 < length
                             fseek(nHandle,t2,1)
                          else
                             is_ok := .f.  // sample too big 2 b true!
                             exit
                          endif

                       else
                          is_ok := .f.
                          exit
                       endif

                    case cbuff == "????"
                         //loop because we can find this at the end of any sample
                    otherwise
                        fseek(nhandle,-(lenout),1)
                        exit

                    endcase
                 else
                    fseek(nhandle,-(lenout),1)
                    exit

                 endif

              enddo
              if is_ok //.and. t1 == 0
                 lenout:=fseek(nhandle,0,1)
                 fwrite(nhandle,"")

              endif
           endif
        endif

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="FNK"                  // guess
        cbuff:=space(16)
        fread(nHandle,@cbuff,16)
        if substr(cbuff,13,4)=="Fk08"
           lenout:=bin2l(substr(cbuff, 9,4))
           IF length > lenout
              fseek(nHandle,0,0)
              fseek(nHandle,lenout,0)
              fwrite(nHandle,"")

           ENDIF
        ELSE
           Is_ok := .F.
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="DLZ"                  // FMEXT 2.1
        cbuff := space(16)
        if (noff:=fread(nhandle,@cbuff,16))== 16
           t1 := (asc(substr(cbuff,10,1))*65536) + ;
                 bin2w(substr(cbuff,11,2))
           lenout:=t1+17
           if lenout <= length .and.  lenout > 50
              // patch: se diverso da "dlz" (ad es. "EOS")
              fseek(nhandle,0,0)
              fseek(nhandle,6,0)
              cbuff:="   "
              fread(nhandle,@cbuff,3)
              if cbuff#"dlz"
                 fseek(nhandle,0,0)
                 fseek(nhandle,6,0)
                 fwrite(nhandle ,"dlz",3)
              endif
              fseek(nhandle,lenout,0)
              fwrite(nhandle ,"")
           else
              is_ok:=.f.
           endif
        else
           is_ok:=.f.
        endif

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="MDL"                  // dox
        Is_ok := .F.
        noff:=t1:=0
        fseek(nHandle,0,0)
        fseek(nHandle,4,0)
        cbuff:=chr(0)
        fread(nHandle,@cbuff,1)
        if asc(cbuff)>=10
           noff+=5
           while .T.
                 ++t1
                 cbuff:=Space(6)
                 slength:=fread(nHandle,@cbuff,6)
                 noff+=6
                 IF slength # 6
                    exit
                 ELSE
                    t2 := left(cbuff,2)
                    IF t1 == 1 .and. t2 # "IN" // 1st chunk name
                       exit
                    ENDIF
                    if t2 $ "IN-ME-PA-PN-TR-II-VE-PE-FE-IS-SA"

                       ctemp  :=bin2l(right(cbuff,4))
                       noff+=ctemp
                       IF  noff > filelen
                           exit
                       ELSE
                           fseek(nHandle,ctemp,1)
                           if t2 == "SA" //era l'ultimo chunk?
                              is_ok:=.t.
                              exit

                           ENDIF
                       ENDIF
                    else
                       exit

                    ENDIF

                 ENDIF
           enddo
        endif
        IF is_ok
           lenout:=noff
           fwrite(nHandle,"")
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="CMF"                  // Guess
        cBuff := space(6)
        lenout:=fread(nHandle,@cBuff,6)
        patt := CHR(0)+CHR(255)+CHR(47)+CHR(0)
        is_ok:=.f.
        IF lenout = 6 .and. length > 100
           IF substr(cBuff,5,2) $ chr(0)+chr(1)+chr(1) // 0x0001 0x0101

              is_ok:=IllBeBack(patt,nHandle,length,@nposit,aStaticone)

              if is_ok
                 fseek(nHandle,nPosit,0)
                 cbuff:= " " // se dopo Terminator c'Š FF lasciamolo...
                 if fread(nHandle,@cbuff,1) == 1 .and. cbuff == chr(255)
                    nposit++
                 endif

                 fseek(nHandle,nPosit,0)
                 fwrite(nHandle,"")
                 lenout:=nPosit
              endif

           ENDIF
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="HMP"                  // Guess
        is_ok:=.f.
        fseek(nHandle,32,0)
        cbuff:=space(4)
        if (nposit:=fread(nHandle,@cBuff,4)) == 4
           lenout:=bin2l(cbuff)
           IF length > lenout  .and. lenout > 0
              fseek(nHandle,0,0)
              fseek(nHandle,lenout,0)
              fwrite(nHandle,"")
              is_ok:=.t.
           endif
        endif


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="MUS"                  // guess
        cBuff := space(64)
        lenout:=fread(nHandle,@cBuff,64)
        IF lenout < 64
           Is_ok := .F.
        ELSE
           IF asc(substr(cbuff,8,1)) = 0
              lenout := bin2w(substr(cbuff,5,2))+asc(substr(cbuff,7,1))
              IF length > lenout
                 fseek(nHandle,0,0)
                 fseek(nHandle,lenout,0)
                 fwrite(nHandle,"")

              ENDIF
           ELSE
              Is_ok := .F.
           ENDIF
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="SCX"                  // guess
        cBuff := space(16)
        lenout:=fread(nHandle,@cBuff,16)
        IF lenout < 16
           Is_ok := .F.
        ELSE
           ctemp:=substr(cbuff,9,2)
           slength:=bin2w(substr(cbuff,5,2))  // x
           t1     :=bin2w(substr(cbuff,7,2))  // y
           DO CASE
              CASE ctemp == chr(175)+chr(0) // 256 colori -> palette da 768b
                   lenout:=slength*t1+768+10
              CASE ctemp == chr(171)+chr(4) //  16 colori -> palette da  48b
                   lenout:=slength*t1/2+48+10 // come immagine occupano la met…
              OTHERWISE
                   Is_ok := .F.
           ENDCASE
           IF is_ok
              IF length > lenout
                 fseek(nHandle,0,0)
                 fseek(nHandle,lenout,0)
                 fwrite(nHandle,"")
              ENDIF
           ENDIF
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="TGA"                  // guess
        cBuff := space(18)
        lenout:=fread(nHandle,@cBuff,18)
        IF lenout < 18
           Is_ok := .F.
        ELSE
           t1 :=bin2w(substr(cbuff,13,2))  // x
           t2 :=bin2w(substr(cbuff,15,2))  // y
           slength := asc(substr(cbuff,17,1)) / 8
           if slength = int( slength )  .and. ;
              str(slength,1,0) $ "1234" .and. ; // 8/16/24/32 bits
              t1 > 10 .and. t1 <= 2048  .and. ; // minimum x/y check
              t2 > 10 .and. t2 <= 2048

              lenout:=(t1*t2*slength)+18
              if slength = 1
                 lenout +=768 // palette
              endif
              IF length > lenout
                 fseek(nHandle,0,0)
                 fseek(nHandle,lenout,0)
                 fwrite(nHandle,"")
              ENDIF
           ELSE
              Is_ok := .F.

           ENDIF
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="AU"                  // Dox
        cBuff := space(20)
        lenout:=fread(nHandle,@cBuff,20)
        IF lenout < 20
           Is_ok := .F.
        ELSE
           t1 :=bin2l(substr (cbuff, 8,1)+;
                      substr (cbuff, 7,1)+;
                      substr (cbuff, 6,1)+;
                      substr (cbuff, 5,1) )
           t2 :=bin2l(substr (cbuff,12,1)+;
                      substr (cbuff,11,1)+;
                      substr (cbuff,10,1)+;
                      substr (cbuff, 9,1) )

           if t1 > 0 .and. t2 > 0
              lenout:=t1+t2
              IF length > lenout
                 fseek(nHandle,0,0)
                 fseek(nHandle,lenout,0)
                 fwrite(nHandle,"")
              ENDIF
           ELSE
              Is_ok := .F.
           ENDIF
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="RAW"                  // dox + guess
        cBuff := space(64)
        lenout:=fread(nHandle,@cBuff,64)
        IF lenout < 64
           Is_ok := .F.
        ELSE
           t1:=bin2w(substr(cbuff,10,1)+substr(cbuff,9,1))
           t2:=bin2w(substr(cbuff,12,1)+substr(cbuff,11,1))
           slength:=bin2w(substr(cbuff,14,1)+substr(cbuff,13,1))
           lenout:=32 // header fisso
           IF slength >1 .and. slength <=256
              lenout+=slength*3
              lenout+=t1*t2
           ELSE
              lenout+=t1*t2*3 //true color
           ENDIF
           IF length > lenout
              fseek(nHandle,0,0)
              fseek(nHandle,lenout,0)
              fwrite(nHandle,"")
           ENDIF

        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="RAS"                  // guess
        cBuff := space(64)
        lenout:=fread(nHandle,@cBuff,64)
        IF lenout < 64
           Is_ok := .F.
        ELSE
           IF substr(cbuff,16,1) $ chr(8)+chr(24).and. ; // 8/24 bit
              substr(cbuff,24,1) $ chr(1)+chr(2) .and. ; // 1=uncompr. , 2=compr.
              substr(cbuff,28,1) $ chr(1)+chr(0)         // 1=palette  , 0=truecolor
              t1:=bin2l( substr(cbuff,20,1)+;
                         substr(cbuff,19,1)+;
                         substr(cbuff,18,1)+;
                         substr(cbuff,17,1) ) // Bitmap size

              t2:=bin2l( substr(cbuff,32,1)+;
                         substr(cbuff,31,1)+;
                         substr(cbuff,30,1)+;
                         substr(cbuff,29,1) ) // palette size

              lenout:=t1+t2+32 // header fisso
              IF length > lenout
                 fseek(nHandle,0,0)
                 fseek(nHandle,lenout,0)
                 fwrite(nHandle,"")
              ENDIF
           ELSE
              Is_ok := .F.
           ENDIF

        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="RMI" .or. ;           // guess
        ext=="WAV" .or.;
        ext=="SBK" .or.;
        ext=="AVI"
        cBuff := space(30)
        lenout:=fread(nHandle,@cBuff,30)
        IF lenout < 30
           Is_ok := .F.
        ELSE
           patt:= substr(cBuff,1,4)
           IF patt == "RIFF"
              lenout:=bin2l(substr(cBuff,5,4) )+8
              IF length >= lenout
                 fseek(nHandle,0,0)
                 fseek(nHandle,lenout,0)
                 fwrite(nHandle,"")
              ELSE
                 Is_ok := .F.
              ENDIF
           ELSE
              Is_ok := .F.
           ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="VOC"                  // dox + guess
        cBuff := space(26)
        lenout:=fread(nHandle,@cBuff,26)
        IF lenout < 26
           Is_ok := .F.
        ELSE
           IF substr(cbuff,17,6) == "ile"+chr(26)+chr(26)+chr(0)
              t1:=bin2w( substr(cbuff,23,2) )  // vers: 1.10 o 1.20
              t2:=bin2w( substr(cbuff,25,2) )  // compl a 2 + 1234h
              IF t2 == 65535-t1+4660-65536
                 // scanner dei vari chunk...
                 bigtotal:=26
                 while .T.
                       cbuff:= " "
                       nbit:= fread(nHandle,@cBuff,1)
                       IF nbit # 1
                          is_ok := .F.
                          exit
                       ELSE
                          bigtotal++
                          t1:=asc(cbuff)
                          cbuff:=space(3)
                          DO CASE
                             CASE t1 = 0 // Terminator      (NONE)
                                  exit
                             CASE t1 = 1 .or.;
                                  t1 = 2 .or.;
                                  t1 = 5 .or.;
                                  t1 = 9 //  <- Undocumented !!!!
                                         //     VocHdr puts this on VOC1.20
                                  nbit:= fread(nHandle,@cBuff,3)
                                  IF nbit # 3
                                     is_ok := .F.
                                     exit
                                  ELSE
                                     bigtotal+=3
                                     noff := bin2l(cbuff+chr(0))
                                     bigtotal+=noff
                                     IF bigtotal > length
                                        is_ok := .F.
                                        exit
                                     ELSE
                                        fseek(nHandle,noff,1)
                                     ENDIF
                                  ENDIF

                             CASE t1 = 3 // Silence = 3
                                  fseek(nHandle,6,1)
                                  bigtotal+=6
                             CASE t1 = 4 .or. t1 = 6 // Marker/repeat=  2
                                  fseek(nHandle,5,1)
                                  bigtotal+=5
                             CASE t1 = 7 // End repeat =  0
                                  fseek(nHandle,3,1)
                                  bigtotal+=3
                             CASE t1 = 8 // Extended   =  4
                                  fseek(nHandle,7,1)
                                  bigtotal+=7
                             OTHERWISE
                                  is_ok := .F.
                                  exit
                          ENDCASE


                       ENDIF
                 enddo
                 IF is_ok
                    fwrite(nHandle,"")
                    lenout:=bigtotal
                 ENDIF


              ELSE
                 Is_ok := .F.
              ENDIF
           ELSE
              Is_ok := .F.
           ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="FLI" .or. ext=="FLC"  // dox
        cBuff := space(2000)
        lenout:=fread(nHandle,@cBuff,2000)
        IF lenout < 2000
           Is_ok := .F.
        ELSE
           IF asc(SUBSTR(CBUFF,4,1)) < 32 // TENGO BUONI SOLO SE <= 1FFF:FFFF (53Mb)
              IF BIN2W(SUBSTR(CBUFF,7,2)) <= 4000 //Max Frames in FLI
                 t1:=bin2w(substr(cbuff,9,2))
                 t2:=bin2w(substr(cbuff,11,2))
                 IF ext=="FLI"
                    nbit:=( t1=320 .and. t2=200 )  // FIXED res.
                 ELSE
                    /*  non sono poi cosi' fissi...
                    nbit:=( t1=320 .and. (t2=200.or.t2=240.or.t2=400.or.t2=480) ) .or.;
                          ( (t1=360.or.t1=640).and. (t2=400.or.t2=480) ) .or.;
                          ( t1=800 .and. t2=600 ) .or.;
                          ( t1=1024.and. t2=768 ) .or.;
                          ( t1=1280.and. t2=1024)
                    */
                    nbit:=(t1=320 .or. t1=360 .or. t1=400 .or. t1=480 .or. t1=640 .or. t1=800 .or. t1=1024 .or. t1=1280) .and.;
                          (t2=200 .or. t2=240 .or. t2=360 .or. t2=400 .or. t2=480 .or. t2=600 .or. t2=768 .or. t2=1024 )
                 ENDIF
                 IF nbit
                    lenout:=bin2l(left(cbuff,4))
                    IF length >= lenout
                       fseek(nHandle,0,0)
                       fseek(nHandle,lenout,0)
                       fwrite(nHandle,"")
                    ELSE
                       /*
                       GRAVE BUG !!
                       siccome il pattern 11AF si trova spesso in mezzo
                       potrei aver estratto solo un pezzo di File, quindi
                       se il file originario Š abbastanza lungo estraggo
                       comunque copiando quello che manca
                       */

                       IF filelen-START_POS >= lenout
                          t1:=F_fopen( PARM )
                          fseek(nHandle,0,2)
                          fseek(t1,START_POS+length,0)
                          t2:= lenout-length          // quanti byte mancano
                          IF t2 >  BUFLEN // non Š che servirebbe, pero'...
                             for ctemp := 1 to int( t2 / BUFLEN )
                                 cbuff:=space( BUFLEN )
                                 nbit := fread(t1,@cbuff,BUFLEN)
                                 nbit := fwrite(nHandle,cbuff,BUFLEN)
                             next
                          ENDIF
                          ctemp := int(t2 % BUFLEN)
                          IF ctemp > 0  // ops...
                             cbuff:= space( ctemp )
                             nbit := fread(t1,@cbuff,ctemp)
                             nbit := fwrite(nHandle,cbuff,ctemp)
                          ENDIF
                          fclose(t1)
                          length := lenout
                       ELSE
                          Is_ok := .F.
                       ENDIF

                    ENDIF
                 ELSE
                    Is_ok := .F.
                 ENDIF
              ELSE
                 Is_ok := .F.
              ENDIF
           ELSE
              Is_ok := .F.
           ENDIF
        ENDIF


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   CASE ext=="3DS"                  //Dox
        cBuff := space(50)
        lenout:=fread(nHandle,@cBuff,50)
        Is_ok := .F.
        IF lenout = 50 .and. left(cbuff,2) == "MM" // real signature
           t1 := bin2l(substr(cBuff,3,4)) // lunghezza dichiarata dopo MM
           IF t1 > 50 .and. t1 <= length
              fseek(nHandle,t1,0)
              fwrite(nHandle,"")
              lenout:=t1
              is_ok:= .T.
           ENDIF
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   case ext=="JPG"                  // DJPEG SRC (cerco SOLO il Marker 0xFFD9)
        is_ok:=.f.
        nposit:=0
        patt := CHR(255)+CHR(217)
        // potrei prima cercare FFDA (Data stream) per essere sicuro dell'
        // integrita' del file oppure... nah!
        is_ok:=IllBeBack(patt,nHandle,length,@nposit,aStaticone)

        if is_ok
           fseek(nHandle,nPosit,0)
           fwrite(nHandle,"")
           lenout:=nPosit
        endif


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*

   case ext=="MPG"                  // Guess
        is_ok:=.f.
        nposit:=0
        patt := CHR(0)+CHR(0)+CHR(1)+CHR(183)
        is_ok:=IllBeBack(patt,nHandle,length,@nposit,aStaticone)

        if is_ok
           fseek(nHandle,nPosit,0)
           fwrite(nHandle,"")
           lenout:=nPosit
        endif


*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*
   CASE ext=="EXE"                  // dox + guess
        cBuff := space(22)
        lenout:=fread(nHandle,@cBuff,22) // 20 bytes di header + 2 bytes istruzione minima: int 20
        IF lenout < 22
           Is_ok := .F.
        ELSE
           patt:= substr(cBuff,1,2)
           IF patt == "MZ"
              t1:=bin2w( substr(cBuff,5,2) )
              IF t1 < 1279    // 0x04ff pagine da 512b = 640Kb >> impossibile
                 t2 := bin2w( substr(cBuff,3,2) )
                 IF t2 < 512  // bytes nell'ultima pagina
                    lenout := t2+((t1-if(t2>0,1,0) )*512)
                    /*                ^^^^^^^^^^^^
                    Non me ne ero reso conto!
                    devo sottrarre 1 al numero di pagine SOLO se i bytes
                    restanti nell'ultima pagina sono > 0 , se no tiro fuori
                    un pagina in meno....
                    */
                    IF length >= lenout .and. lenout >= 20
                       fseek(nHandle,0,0)
                       fseek(nHandle,lenout,0)
                       fwrite(nHandle,"")
                    ELSE
                       /* bug fix vedi FLI */
                       IF filelen-START_POS >= lenout .and. lenout >= 20
                          t1:=F_fopen( PARM )
                          fseek(nHandle,0,2)
                          fseek(t1,START_POS+length,0)
                          t2:= lenout-length          // quanti byte mancano
                          IF t2 >  BUFLEN // non Š che servirebbe, pero'...
                             for ctemp := 1 to int( t2 / BUFLEN )
                                 cbuff:=space( BUFLEN )
                                 nbit := fread(t1,@cbuff,BUFLEN)
                                 nbit := fwrite(nHandle,cbuff,BUFLEN)
                             next
                          ENDIF
                          ctemp := int(t2 % BUFLEN)
                          IF ctemp > 0
                             cbuff:= space( ctemp )
                             nbit := fread(t1,@cbuff,ctemp)
                             nbit := fwrite(nHandle,cbuff,ctemp)
                          ENDIF
                          fclose(t1)
                          length := lenout
                       ELSE
                          Is_ok := .F. // non sarebbe comunque eseguibile se manca del codice...
                       ENDIF
                    ENDIF
                 ELSE
                    Is_ok := .F.
                 ENDIF
              ELSE
                 Is_ok := .F.
              ENDIF
           ELSE
              Is_ok := .F.
           ENDIF
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*
   CASE ext=="USM"                  // USM Player v1.0
        slength := 2940
        FSEEK(nHandle,slength,0)

        Is_ok := .F.
        cBuff := SPACE(8)
        WHILE (lenout:=fread(nHandle,@cBuff,8))==8
           IF LEFT(cBuff,4)=="USLP"
              Is_ok := .T. // Almeno un USLP
              slength += BIN2W(RIGHT(cBuff,4))
              FSEEK(nHandle,slength,0)
           ELSE
              FSEEK(nHandle,slength,0)
              EXIT
           ENDIF
           cBuff := SPACE(8)
        ENDDO
        IF lenout!=0 .AND. Is_ok
           Is_ok := .F.
           cBuff := SPACE(62)
           WHILE (lenout:=fread(nHandle,@cBuff,62))==62
              IF LEFT(cBuff,4)=="SMPL"
                 Is_ok := .T. // Almenu un SMPL
                 slength += BIN2W(SUBSTR(cBuff,41,4)) +62
                 FSEEK(nHandle,slength,0)
              ELSE
                 EXIT
              ENDIF
              cBuff := SPACE(62)
           ENDDO
           FSEEK(nHandle,slength,0)
           FWRITE(nHandle,"")
        ENDIF

*şßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßşÜşßş*
   //CASE

ENDCASE

IF filelen = lenout .and. filelen = length .and. Is_ok
   IF PROCESS_ALL = 0
      IF !FBATCH
         IF Alert( BIG_WARN+;
                  "The extracted file is the same as;"+;
                  "the source file! What shall I do?",;
                  {"Leave","Delete"},"GR+/N*") = 2

            Is_ok := .F.
         ENDIF
      ENDIF
   ELSE
      ISTHESAME :=.T.
      Is_ok := .F.
   ENDIF
ENDIF

fclose(nHandle)

RETURN Is_ok

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION readgifdatablock( nhandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL read_ok:=.T.,Data:=" ",nData

Fread(nHandle,@Data,1)   // Code size, # of Bits to represent data
while .T.
      if(Fread(nHandle,@Data,1)) # 1
        read_ok := .F.
        exit
      ENDIF
      ndata:=asc(Data)
      IF nData = 0 // data stream terminator
         exit
      ENDIF
      fseek(nHandle,nData,1)

enddo

RETURN read_ok

* ±The quest 4 Terminator continues!±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION IllBeBack( patt,nHandle,length,nPosit,aStaticone)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL  is_ok:=.f.,Cbuff:="",nBit,Noff,t1,t2:=len(patt)

fseek(nHandle,0,0)
WHILE nposit < length
      cBuff := space(BUFLEN)

      NBIT  := fread(nHandle,@cBuff,BUFLEN)
      cbuff := left(cbuff,nbit)

      noff := at( patt , cbuff)
      if noff > 0 // found
         nPosit+=nOff+(t2-1)
         is_ok:=.t.
         exit
      else
         if nBit = t2 // se non ho trovato patt e i bytes rimanenti sono
                      // quanti patt... niente da fare!
            exit
         endif
         fseek(nHandle,-t2,1)
         nposit+=nBit-t2
      endif
ENDDO

RETURN is_ok

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ExactPattern( ext, hin, filepos, aStaticone )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .F.
/*
LOCAL aExt := { ext, filepos, 0 }, cFile, nCurPos, cBuff, nLen
LOCAL nFileSize, nActPos
DO CASE
   CASE ext=="BIK"
        // Memorizzo
        nCurPos := FSEEK( hin, 0, FS_RELATIVE )
        nFileSize := dfFileSize( hIn )

        // Lo scopo di quest'algoritmo Š quello di vedere se c'e'
        // un file oppure no a quell'offset, Se c'e' di calcolare la
        // giusta lunghezza

        // Praparo il buffer
        cBuff := SPACE( 8 )
        // Mi posiziono
        FSEEK( hin, filepos, FS_SET )

        //Inizio il ciclo di lettura
        WHILE fXorread(hin,@cbuff, 8)==8
           // Se sono al punto giusto
           IF SUBSTR( cBuff, 1, 3 )=="BIK"
              nLen := BIN2L( SUBSTR( cBuff, 5, 4 ) )

              IF nLen< 256*256 // Valore arbitrario
                 // Errore
                 EXIT
              ENDIF

              IF FSEEK( hin, nLen, FS_RELATIVE )>nFileSize
                 // Errore
                 EXIT
              ENDIF

              nActPos := FSEEK( hin, 0, FS_RELATIVE )
              IF nActPos==nFileSize
                 // Direi che Š giusto
                 aExt[3] := nActPos-aExt[2]
                 exit
              ENDIF
           ELSE
              // Corretto
              nActPos := FSEEK( hin, 0, FS_RELATIVE )
              aExt[3] := nActPos-aExt[2]
              EXIT
           ENDIF
        ENDDO

        // Riposiziono
        FSEEK( hin, nCurPos, FS_SET )
ENDCASE

// Se il size Š maggiore di 0 .. estraggo il file
IF aExt[3]>0
   cFile := F_ExtName( aExt[1] )
   F_DUMP_FILE( cFile, hIn, 0, aExt[2], aExt[3] )
   lRet := .T.
ENDIF

*/
RETURN lRet
