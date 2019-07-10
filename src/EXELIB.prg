/******************************************************************************
Project     : TWT
Description : Library reconizer module
Programmer  : Baccan Matteo
******************************************************************************/

#include "mripper.ch"

STATIC aStaticone
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION CHKEXELIB( aMrip )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL H_IN,cbuff,t1,t2,lenout,arr:={},libfound:=0,nextr:=0
LOCAL nRecords,libStart,nexes ,jj,xx,nbit,temp,t3
local retval := .f., lExtract, nExtract, cNewFileName, cExt

aStaticone := aMrip

IF (h_in:= F_fopen( PARM, FO_SHARED )) == -1
   RipLog("Cannot open "+PARM )
   IF !FBATCH
      alert( BIG_ERROR +"Cannot open;"+PARM,{"Quit"})
   ENDIF
else
   cbuff:=space(22)
   fread(h_in,@cbuff,22)

   DO CASE
   CASE left(cbuff,2)=="MZ"
      t1:=bin2w( substr(cBuff,5,2) )
      IF t1 < 1279    // 0x04ff pagine da 512b = 640Kb >> impossibile
         t2 := bin2w( substr(cBuff,3,2) )
         IF t2 < 512  // bytes nell'ultima pagina
            lenout := t2+((t1-if(t2>0,1,0) )*512)

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *

            ///////// XLInk 1.0/2.02 \\\\\\\\\\\
            fseek(h_in,0,0)
            fseek(h_in,lenout,0)
            cbuff:=space(8)
            if (t1:=fread(h_in,@cbuff,8))==8
               if left(cbuff,2)=="XL" .and. right(cbuff,4)==chr(0)+chr(0)+chr(0)+chr(0)

                 if substr(cbuff,3,1) == chr(2) // v2.02
                    cbuff:=space(2)
                    if (t1:=fread(h_in,@cbuff,2))==2
                       nRecords := bin2w(cbuff)
                       cbuff:=space(2)
                       if (t1:=fread(h_in,@cbuff,2))==2
                          nexes := bin2w(cbuff)
                          fseek(h_in,4,1)
                          cbuff:=space(nRecords*32)
                          if (t1:=fread(h_in,@cbuff,nRecords*32))==nRecords*32
                             De_Xlink(cBuff)
                             if left(cbuff,12) =="_____XLC@SRT"

                                libfound := 1
                                msgbldndx(libfound)

                                arr:={}
                                for jj := 1 to nRecords-1 // 1st entry skipped
                                    gauge(jj,nrecords-1)
                                    t1:=normalize(substr(cbuff,(jj*32)+1,12))
                                    aadd(arr, {t1,0,0} ) // Filename
                                    t1:=bin2l(substr(cbuff,(jj*32)+1+16,4))
                                    arr[jj][3]:= t1  // Lenght
                                    t1:=bin2l(substr(cbuff,(jj*32)+1+20,4)) + lenout
                                    arr[jj][2]:= t1  // Start off (abs)
                                next
                                nrecords--
                                msgbldndx()
                             endif
                          endif
                       endif
                    endif

                 elseif substr(cbuff,3,1) == chr(0) // v1.0
                    cbuff:=space(2)
                    if (t1:=fread(h_in,@cbuff,2))==2
                       nRecords := bin2w(cbuff)
                       cbuff:=space(2)
                       if (t1:=fread(h_in,@cbuff,2))==2
                          nexes := bin2w(cbuff)
                          fseek(h_in,4,1)
                          cbuff:=space(nRecords*23)
                          if (t1:=fread(h_in,@cbuff,nRecords*23))==nRecords*23
                             if left(cbuff,12) =="_____XLC@SRT"
                                libfound := 2
                                msgbldndx(libfound)
                                arr:={}
                                for jj := 1 to nRecords-1 // 1st entry skipped
                                    gauge(jj,nrecords)
                                    t1:=normalize(substr(cbuff,(jj*23)+1,12))
                                    aadd(arr, {t1,0,0} ) // Filename
                                    t1:=bin2l(substr(cbuff,(jj*23)+1+15,4))
                                    arr[jj][3]:= t1  // Lenght
                                    t1:=bin2l(substr(cbuff,(jj*23)+1+19,4)) + lenout
                                    arr[jj][2]:= t1  // Start off (abs)
                                next
                                nrecords--
                                msgbldndx()
                             endif
                          endif
                       endif
                    endif
                 endif

               endif
            endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
            if libfound==0
            ///////// ACME VFS 1.0á \\\\\\\\\\\
               fseek(h_in,0,0)
               fseek(h_in,lenout,0)
               cbuff:=space(13)
               if (t1:=fread(h_in,@cbuff,13))==13
                  if right(cbuff,5)==chr(0)+chr(0)+"VFS"
                     nRecords := bin2l(substr(cbuff,7,4))
                     nextr    := bin2l(substr(cbuff,1,4))
                     jj       := bin2w(substr(cbuff,5,2))
                     if jj == nRecords * 27
                        cbuff:=space(jj)
                        fseek(h_in,0,0)
                        fseek(h_in,nextr ,0)
                        if (t1:=fread(h_in,@cbuff,jj))==jj
                           de_vfs( nRecords , cbuff )
                           libfound := 3
                           msgbldndx(libfound)
                           arr:={}
                           for jj := 0 to nRecords-1
                               gauge(jj,nrecords)
                               t1:=normalize(substr(cbuff,(jj*27)+1+14,12))
                               aadd(arr, {t1,0,0} ) // Filename
                               t1:=bin2l(substr(cbuff,(jj*27)+1+6,4))
                               arr[jj+1][3]:= t1    // Lenght
                               t1:=bin2l(substr(cbuff,(jj*27)+1+1,4))
                               arr[jj+1][2]:= t1    // Start off (abs)
                           next
                           msgbldndx()
                        endif
                     endif
                  endif
               endif
            endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *

            if libfound==0
            /////////// FC lib \\\\\\\\\\\\\\\
               fseek(h_in,0,2)
               fseek(h_in,-4,2)
               cbuff:=space(4)
               if (t1:=fread(h_in,@cbuff,4))== 4
                  nextr:=bin2l(cbuff)
                  if nextr < fseek(h_in,0,1) .and. nextr >= lenout
                     fseek(h_in,0,0)
                     fseek(h_in,nextr,0)
                     cbuff:=space(4)
                     if (t1:=fread(h_in,@cbuff,4))== 4
                        if cbuff== "À/È"+chr(0)
                           cbuff:=space(4)
                           fread(h_in,@cbuff,4)
                           nrecords:=bin2l(cbuff)
                           fread(h_in,@cbuff,4)
                           if bin2l(cbuff) > 0 .and. nrecords > 0
                             cbuff:=space(nRecords*24)
                             if (t1:=fread(h_in,@cbuff,nRecords*24))==nRecords*24
                               libfound := 4
                               msgbldndx(libfound)
                               arr:={}
                               for jj := 0 to nRecords-1
                                   gauge(jj,nrecords)
                                   t1:=normalize(substr(cbuff,(jj*24)+1,12))
                                   aadd(arr, {t1,0,0} ) // Filename
                                   t1:=bin2l(substr(cbuff,(jj*24)+1+20,4))
                                   arr[jj+1][3]:= t1    // Lenght
                                   t1:=bin2l(substr(cbuff,(jj*24)+1+16,4))
                                   arr[jj+1][2]:= t1    // Start off (abs)
                               next
                               msgbldndx()

                             endif
                           endif
                        endif
                     endif
                  endif
               endif
            endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *

            if libfound==0
            /////////// Realtech lib \\\\\\\\\\\\\\\
               fseek(h_in,0,2)
               fseek(h_in,-4,2)
               cbuff:=space(4)
               if (t1:=fread(h_in,@cbuff,4))== 4
                  nextr:=bin2l(cbuff)
                  if nextr < fseek(h_in,0,1) .and. nextr >= lenout
                     fseek(h_in,-nextr,2)
                     cbuff:=space(11)
                     if (t1:=fread(h_in,@cbuff,11))== 11
                        if left(cbuff,9)=="REALTECH9"
                           cbuff:=space(2)
                           if (t1:=fread(h_in,@cbuff,2))==2
                              nrecords:=bin2w(cbuff)
                              cbuff:=space(4)
                              fread(h_in,@cbuff,4)

                              cbuff:=space(nRecords*17)
                              if (t1:=fread(h_in,@cbuff,nRecords*17))==nRecords*17
                                 nextr:= fseek(h_in,0,1) //start of 1st file
                                 libfound := 5
                                 msgbldndx(libfound)
                                 arr:={}
                                 for jj := 0 to nRecords-1
                                     gauge(jj,nrecords)
                                     t1:=normalize(substr(cbuff,(jj*17)+1,12))
                                     aadd(arr, {t1,0,0} ) // Filename
                                     t1:=bin2l(substr(cbuff,(jj*17)+1+13,4))
                                     arr[jj+1][3]:= t1    // Lenght
                                     arr[jj+1][2]:= nextr // Start off (abs)
                                     nextr+=t1
                                 next
                                 msgbldndx()
                              endif
                           endif
                        endif
                     endif
                  endif
               endif
            endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *

            if libfound==0
            /////////// Psychic Link FLIB \\\\\\\\\\\\\\\
               fseek(h_in,0,2)
               fseek(h_in,-8,2)
               cbuff:=space(8)
               if (t1:=fread(h_in,@cbuff,8))== 8
                  if right(cbuff,4) == "FLIB"
                     if (nrecords:=bin2l(left(cbuff,4))) < 1000 // dummy check
                        nextr:=(nrecords*32)+8
                        if nextr < fseek(h_in,0,1)
                           fseek(h_in,0,2)
                           fseek(h_in,-(nextr),2)
                           cbuff:=space(nRecords*32)
                           if (t1:=fread(h_in,@cbuff,nRecords*32))==nRecords*32
                              libfound := 6
                              msgbldndx(libfound)
                              arr:={}
                              for jj := 0 to nRecords-1
                                  gauge(jj,nrecords)
                                  t1:=normalize(substr(cbuff,(jj*32)+1,12))
                                  aadd(arr, {t1,0,0} ) // Filename
                                  t1:=bin2l(substr(cbuff,(jj*32)+1+16,4))
                                  arr[jj+1][2]:= t1  // Start off (abs)
                                  t1:=bin2l(substr(cbuff,(jj*32)+1+20,4))
                                  arr[jj+1][3]:= t1  // Lenght
                              next
                              msgbldndx()
                           endif
                        endif
                     endif
                  endif
               endif
            endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *

            if libfound==0
            /////////// ElectroMotive Force LIB\\\\\\\\\\
               fseek(h_in,0,2)
               fseek(h_in,-12,2)
               cbuff:=space(12)
               if (t1:=fread(h_in,@cbuff,12))== 12
                  if right(cbuff,4) == "EMF!"
                     if (nrecords:=bin2l(left(cbuff,4))) < 1000 // dummy check
                        nextr:=bin2l(substr(cbuff,5,4))
                        if nextr < fseek(h_in,0,1)
                           fseek(h_in,0,0)
                           fseek(h_in,nextr,0)
                           cbuff:=space(nRecords*32)
                           if (t1:=fread(h_in,@cbuff,nRecords*32))==nRecords*32
                              libfound := 7
                              msgbldndx(libfound)
                              arr:={}
                              for jj := 0 to nRecords-1
                                  gauge(jj,nrecords)
                                  t1:=normalize(substr(cbuff,(jj*32)+1,12))
                                  aadd(arr, {t1,0,0} ) // Filename
                                  t1:=bin2l(substr(cbuff,(jj*32)+1+16,4))
                                  arr[jj+1][2]:= t1  // Start off (abs)
                                  t1:=bin2l(substr(cbuff,(jj*32)+1+20,4))
                                  arr[jj+1][3]:= t1  // Lenght
                              next
                              msgbldndx()
                           endif
                        endif
                     endif
                  endif
               endif
            endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *

            if libfound==0
            /////////// Pelusa Resource Compiler \\\\\\\\\
               fseek(h_in,0,2)
               fseek(h_in,-4,2)
               cbuff:=space(4)
               if (t1:=fread(h_in,@cbuff,4))== 4
                  nextr:=bin2l(cbuff)
                  if nextr < fseek(h_in,0,1) .and. nextr >= lenout
                     fseek(h_in,0,0)
                     fseek(h_in,nextr,0)
                     cbuff:=space(4)
                     if (t1:=fread(h_in,@cbuff,4))== 4
                        if cbuff== "REZþ"
                           cbuff:=space(2)
                           fread(h_in,@cbuff,2)
                           nrecords:=bin2w(cbuff)
                           cbuff:=space(nRecords*24)
                           if (t1:=fread(h_in,@cbuff,nRecords*24))==nRecords*24
                             libfound := 8
                             msgbldndx(libfound)
                             arr:={}
                             for jj := 0 to nRecords-1
                                 gauge(jj,nrecords)
                                 t1:=normalize(substr(cbuff,(jj*24)+1,12))
                                 aadd(arr, {t1,0,0} ) // Filename
                                 t1:=bin2l(substr(cbuff,(jj*24)+1+20,4))
                                 arr[jj+1][3]:= t1    // Lenght
                                 t1:=bin2l(substr(cbuff,(jj*24)+1+16,4))
                                 arr[jj+1][2]:= t1    // Start off (abs)
                             next
                             msgbldndx()
                           endif
                        endif
                     endif
                  endif
               endif
            endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *

            if libfound==0
            /////////// Japotek \\\\\\\\\
               fseek(h_in,0,2)
               t3 := fseek(h_in,0,1)
               fseek(h_in,-12,2)
               cbuff:=space(12)
               if (t1:=fread(h_in,@cbuff,12))== 12
                  if left(cbuff,4) == "JPK0"
                     nextr:=bin2l(substr(cbuff,5,4))
                     fseek(h_in,0,2)
                     fseek(h_in,-nextr,1)
                     xx := fseek(h_in,0,1)
                     cbuff:=space(4)
                     if (t1:=fread(h_in,@cbuff,4))== 4
                        if cbuff== "JDIR"
                           cbuff:=space(6)
                           fread(h_in,@cbuff,6)
                           nrecords:=bin2w(cbuff)
                           cbuff:=space(nRecords*17)
                           if (t1:=fread(h_in,@cbuff,nRecords*17))==nRecords*17
                             libfound := 15
                             msgbldndx(libfound)
                             arr:={}
                             for jj := 0 to nRecords-1
                                 gauge(jj,nrecords)
                                 t1:=normalize(substr(cbuff,(jj*17)+1,12))
                                 aadd(arr, {t1,0,0} ) // Filename
                                 t1:=bin2l(substr(cbuff,(jj*17)+14,4))
                                 arr[jj+1][2]:= t3-t1 // Start off (abs)

                             next
                             aadd(arr,{"",xx,0})
                             for jj := 1 to nRecords  // Lenghts
                                 arr[jj][3]:=arr[jj+1][2] - arr[jj][2]
                             next

                             msgbldndx()
                           endif
                        endif
                     endif
                  endif
               endif
            endif


* ±±end of exe libs±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *

         endif
      endif


* ±±start of DAT libs±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

    // REALTECH 94 dat
   CASE Left(cBuff, 11) == "REALTECH94="
        fseek(h_in,11,0)
        cbuff:=space(2)
        if (t1:=fread(h_in,@cbuff,2))==2
           nrecords:=bin2w(cbuff)
           cbuff:=space(4)
           fread(h_in,@cbuff,4)

           cbuff:=space(nRecords*17)
           if (t1:=fread(h_in,@cbuff,nRecords*17))==nRecords*17
              nextr:= fseek(h_in,0,1) //start of 1st file
              libfound := 9
              msgbldndx(libfound)
              arr:={}
              for jj := 0 to nRecords-1
                  gauge(jj,nrecords)
                  t1:=normalize(substr(cbuff,(jj*17)+1,12))
                  aadd(arr, {t1,0,0} ) // Filename
                  t1:=bin2l(substr(cbuff,(jj*17)+1+13,4))
                  arr[jj+1][3]:= t1    // Lenght
                  arr[jj+1][2]:= nextr // Start off (abs)
                  nextr+=t1
              next
              msgbldndx()

           endif
        endif


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   // EA GOB (Dark Forces)
   CASE Left(cBuff, 4) == "GOB"+CHR(10)
        nextr:=bin2l(substr(cbuff,5,4))
        Fseek(h_in, 0, 0)
        Fseek(h_in, nextr, 0)
        cBuff := Space(4)
        IF (t1 := Fread(h_in, @cBuff, 4)) = 4
           IF bin2w(right(cbuff,2)) == 0 // solo valori < 64k ... e sono generoso
              nRecords := Bin2w(left(cbuff,2))
              cBuff := Space(nRecords * 21)
              IF (t1 := Fread(h_in, @cBuff, nRecords * 21)) == nRecords * 21
                 LIBFOUND := 10
                 msgbldndx(libfound)
                 arr := {}
                 FOR jj := 0 TO nRecords - 1
                     gauge(jj,nrecords)
                     t1 := normalize(Substr(cBuff, jj * 21 + 1+8, 12))
                     Aadd(arr, {t1, 0, 0})   // name
                     t1 := Bin2l(Substr(cBuff, jj * 21 + 1 + 4, 4))
                     arr[jj + 1, 3] := t1    // length
                     t1 := Bin2l(Substr(cBuff, jj * 21 + 1 , 4))
                     arr[jj + 1, 2] := t1    // abs. offset
                 NEXT
                 msgbldndx()
              ENDIF
           ENDIF
        ENDIF

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   // iD software WAD
   CASE Left(cBuff, 4) $ "IWAD PWAD"
        nrecords:=bin2l(substr(cbuff,5,4))
        nextr:=bin2l(substr(cbuff,9,4))
        if nrecords < 4000 .and. nrecords > 1
           Fseek(h_in, 0, 0)
           Fseek(h_in, nextr, 0)
           cbuff:=Space(nrecords*16)
           if (t1:=fread(h_in,@cbuff,nrecords*16 )) == nrecords*16
              temp := nrecords-1
              LIBFOUND:=11
              msgbldndx(libfound)
              arr := {}
              for jj := 0 to temp

                  gauge(jj,temp)
                  t1:=bin2l(    substr(cbuff,(jj*16)+1  ,4))  // Start off (abs)
                  t2:=Bin2l(    Substr(cBuff,(jj*16)+1+4,4))  // Lenght

                  if t1>11 .and. t2>8
                     t3:=incname(normalize(substr(cbuff,(jj*16)+1+8,8)),arr)  // Filename
                     aadd(arr, {t3,t1,t2} )
                  else
                     nrecords--
                  endif
              next
              msgbldndx()

           endif
        endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   // CASCADA res.
   CASE Left(cBuff, 8) == "CDADAT" +_2_CH0
        fseek(h_in, 8,0)
        cbuff:=space(4)
        if (t1:=fread(h_in,@cbuff,4))==4
           nrecords:=bin2w(cbuff)

           cbuff:=space(nRecords*24)
           if (t1:=fread(h_in,@cbuff,nRecords*24))==nRecords*24
              libfound := 12
              msgbldndx(libfound)
              arr:={}
              for jj := 0 to nRecords-1
                  gauge(jj,nrecords)
                  t1:=normalize(substr(cbuff,(jj*24)+1,12))
                  aadd(arr, {t1,0,0} ) // Filename
                  t1:=bin2l(substr(cbuff,(jj*24)+1+16,4))
                  arr[jj+1][2]:= t1 // Start off (abs)
                  t1:=Bin2l(Substr(cBuff,(jj*24)+1+20,4))
                  arr[jj+1][3]:= t1    // Lenght
                  nextr+=t1
              next
              msgbldndx()
           endif
        endif


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   // Duke Nukem 3d
   CASE Left(cBuff, 12) == "KenSilverman"
        fseek(h_in, 12,0)
        cbuff:=space(4)
        if (t1:=fread(h_in,@cbuff,4))==4
           nrecords:=bin2w(cbuff)
           t3:=(nrecords+1)*16  //start of 1st file
           cbuff:=space(nRecords*16)
           if (t1:=fread(h_in,@cbuff,nRecords*16))==nRecords*16
              libfound := 14
              msgbldndx(libfound)
              arr:={}
              for jj := 0 to nRecords-1
                  gauge(jj,nrecords)
                  t1:=normalize(substr(cbuff,(jj*16)+1,12))
                  aadd(arr, {t1,0,0} ) // Filename
                  t1:=Bin2l(Substr(cBuff,(jj*16)+1+12,4))
                  arr[jj+1][3]:= t1    // Lenght
                  arr[jj+1][2]:= t3 // Start off (abs)
                  t3+=t1
              next
              msgbldndx()
           endif
        endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   // Datalib file 1.0 (Found on "SEX2" japan XXX game
   CASE Left(cBuff, 21) == "<< dlb file Ver1.00>>"
        fseek(h_in, 22,0)
        cbuff:=space(2)
        if (t1:=fread(h_in,@cbuff,2))==2
           nrecords:=bin2w(cbuff)
           cbuff:=space(nRecords*21)
           if (t1:=fread(h_in,@cbuff,nRecords*21))==nRecords*21
              libfound := 18
              msgbldndx(libfound)
              arr:={}
              for jj := 0 to nRecords-1
                  gauge(jj,nrecords)
                  t1:=normalize(substr(cbuff,(jj*21)+1,12))
                  aadd(arr, {t1,0,0} ) // Filename
                  t1:=Bin2l(Substr(cBuff,(jj*21)+1+13,4))
                  arr[jj+1][2]:= t1 // Start off (abs)
                  t1:=Bin2l(Substr(cBuff,(jj*21)+1+17,4))
                  arr[jj+1][3]:= t1    // Lenght
              next
              msgbldndx()
           endif
        endif

* ±± end of data libs
   ENDCASE

* ±±Special: Iguana Lib (EXE + DAT)±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *

   if libfound==0
   /////////// Iguana LIB \\\\\\\\\
      fseek(h_in,0,2)
      fseek(h_in,-16,2)
      cbuff:=space(16)
      if (t1:=fread(h_in,@cbuff,16))== 16
         if left(cbuff,4) == "‰´sß"
            nrecords:=bin2l(substr(cbuff,9,4))
            nextr:=   bin2l(substr(cbuff,13,4))
            if (nextr-16)/nrecords == 32 .and.;
               nextr < fseek(h_in,0,1)
               fseek(h_in,0,2)
               fseek(h_in,-nextr,2)
               nextr:= fseek(h_in,0,1) // start of lib
               cbuff:=space(nRecords*32)
               if (t1:=fread(h_in,@cbuff,nRecords*32))==nRecords*32
                  libfound := 13
                  msgbldndx(libfound)
                  arr:={}

                  for jj := 0 to nRecords-1
                      gauge(jj,nrecords)
                      t1:=normalize(substr(cbuff,(jj*32)+1,12))
                      aadd(arr, {t1,0,0} ) // Filename
                      t1:=bin2l(substr(cbuff,(jj*32)+1+28,4))
                      arr[jj+1][3]:= t1    // Lenght
                      t1:=bin2l(substr(cbuff,(jj*32)+1+24,4))
                      t1:=nextr-t1 // t1=seek back from start of lib
                      arr[jj+1][2]:= t1    // Start off (abs)
                  next
                  msgbldndx()

               endif
            endif
         endif
      endif
   endif

* ±±Special: Dfmake Lib (EXE + DAT)±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *

   if libfound==0
   /////////// dfmake LIB \\\\\\\\\
      fseek(h_in,0,2)
      t3:= fseek(h_in,0,1)
      fseek(h_in,-8,2)
      cbuff:=space(8)
      if (t1:=fread(h_in,@cbuff,8))== 8
         if right(cbuff,4) == "DATA"
            nextr := bin2l(left(cbuff,4))
            if nextr < t3
               fseek(h_in,-nextr,2)
               cbuff:=space(2)
               if (t1:=fread(h_in,@cbuff,2))== 2
                  nrecords:= bin2w(cbuff)
                  if (nextr-10)/nrecords == 21
                     cbuff:=space(nRecords*21)
                     if (t1:=fread(h_in,@cbuff,nRecords*21))==nRecords*21
                        libfound := 16
                        msgbldndx(libfound)
                        arr:={}

                        for jj := 0 to nRecords-1
                            gauge(jj,nrecords)
                            t1:=normalize(substr(cbuff,(jj*21)+1,12))
                            aadd(arr, {t1,0,0} ) // Filename
                            t1:=bin2l(substr(cbuff,(jj*21)+1+17,4))
                            arr[jj+1][3]:= t1    // Lenght
                            t1:=bin2l(substr(cbuff,(jj*21)+1+13,4))
                            arr[jj+1][2]:= t3-t1 // Start off (abs)
                        next
                        msgbldndx()
                     endif
                  endif
               endif
            endif
         endif
      endif
   endif

* ±±Champ Programming Library (DAT no signature)±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// Champ LIB \\\\\\\\\
      arr := CHAMPLIB( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 17
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif


* ±±Deathstar CLAUDIA DEMO (DAT no signature)±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// CLAUDIA DEMO \\\\\\\\\
      arr := DEATHSTAR( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 19
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif


* ±±Quake±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// QUAKE MAP \\\\\\\\\
      arr := QUAKE( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 20
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±Chasm±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// Chasm \\\\\\\\\
      arr := CHASM( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 21
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±Frost±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// Frost \\\\\\\\\
      arr := FROST( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 22
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±Coyote±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// Coyote \\\\\\\\\
      arr := COYOTE( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 23
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±(B)ZIP±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// (B)ZIP \\\\\\\\\
      arr := BZIP( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 24
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±FUSION±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// FUSION \\\\\\\\\
      arr := FUSION( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 25
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±PRIMITIVE±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// PRIMITIVE \\\\\\\\\
      arr := PRIMITIVE( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 26
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±TOUR±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// TOUR \\\\\\\\\
      arr := TOUR( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 27
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±ANONYMOUS±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// ANONYMOUS \\\\\\\\\
      arr := ANONYMOUS( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 28
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±BAZAR±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// BAZAR \\\\\\\\\
      arr := BAZAR( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 29
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±LOUIS±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// LOUIS \\\\\\\\\
      arr := LOUIS( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 30
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±JAPOTEKJPK±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// JAPOTEKJPK \\\\\\\\\
      arr := JAPOTEKJPK( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 31
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±LABNSW1±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// LABNSW1 \\\\\\\\\
      arr := LABNSW1( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 32
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±CRYO±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound==0
   /////////// CRYO \\\\\\\\\
      arr := CRYO( h_in )
      IF (nRecords:=LEN(arr))>0
         libfound := 33
         msgbldndx(libfound)
         msgbldndx()
      ENDIF
   endif

* ±±found something?±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± *
   if libfound>0

      RipLog(" ("+alltrim(ARRLIBS[libfound])+" Detected)")

      lExtract := FBATCH
      IF !lExtract
         WHILE .T.
            nExtract := Alert("Found Standard Lib in File;;"+ARRLIBS[libfound]+";;"+;
                         "The number of items found is " +ALLTRIM(STR(nRecords)) +";;"+;
                         "What shall I Do ?",{"Extract","Ignore","Let me see..."},"W+/N*")
            DO CASE
               CASE nExtract==1
                    lExtract := .T.
               CASE nExtract==2 .OR. nExtract==0
                    lExtract := .F.
               CASE nExtract==3
                    F_DispArr(arr)
                    LOOP
            ENDCASE
            EXIT
         ENDDO
      ENDIF

      if lExtract
         //Big_wind()
         temp:= "Extracting "+alltrim(ARRLIBS[libfound])
         F_say(" ... "+temp,"w+/b*")
         F_saymsg( temp, "GR+/B" )
         nextr:=0
         for jj := 1 to nRecords
             t3:= EXTPATH+arr[jj][1]
             // Evito che si possano duplicare i file
             cNewFileName := t3
             IF FILE( EXTPATH+arr[jj][1] )
                cExt := ""
                IF RAT(".",EXTPATH+arr[jj][1])>0
                   cExt := SUBSTR( EXTPATH+arr[jj][1], RAT(".",EXTPATH+arr[jj][1])+1 )
                ENDIF
                IF EMPTY(cExt) .OR. LEN(cExt)!=3
                   cExt := "DMM"
                ENDIF
                cNewFileName := F_ExtName( cExt )
             ENDIF
             if (t1:=fcreate(cNewFileName))>0

                 t2:= arr[jj][3] // len
                 temp:= padr(upper(arr[jj][1]),12)+" @ "+dflong2hex(arr[jj][2])+" ("+str(t2,8)+" bytes)"

                 RipLogSay( " ... Extracted "+temp )
                 IF !(cNewFileName==t3)
                    RipLogSay( "     File already exist, renamed in " +cNewFileName )
                 ENDIF

                 fseek(h_in,arr[jj][2],0)
                 for xx := 1 to int( t2 / BUFLEN )
                    cbuff := space( BUFLEN )
                    nbit  := fread(h_in,@cbuff,BUFLEN)
                    IF libfound==23
                       dfXorPattern( @cBuff, CHR(255) )
                       F_Coyote( @cBuff )
                    ENDIF
                    IF libfound==30
                       dfXorPattern( @cBuff, CHR(42) )
                    ENDIF
                    nbit  := fwrite(t1,cbuff,BUFLEN)
                 next
                 temp := int(t2 % BUFLEN)
                 IF temp > 0
                    cbuff:= space( temp )
                    nbit := fread(h_in,@cbuff,temp)
                    IF libfound==23
                       dfXorPattern( @cBuff, CHR(255) )
                       F_Coyote( @cBuff )
                    ENDIF
                    IF libfound==30
                       dfXorPattern( @cBuff, CHR(42) )
                    ENDIF
                    nbit := fwrite(t1,cbuff,temp)
                 ENDIF
                 fclose(t1)
                 nextr++
             else
                 temp:=upper(EXTPATH+arr[jj][1])
                 RipLogSay( " ... Error Creating "+temp)
             endif

             if F_inkey() == K_ESC
                IF Alert( BIG_BREAK ,{"Continue","Stop"}) = 2
                   exit
                ENDIF
             endif
             if jj==4095 .and. LEN(arr)==4096
                arr := arr[4096]
                nRecords := len(arr)
                jj := 0
             endif
         next
         //flushcache()
         TOTCOUNTER += nextr

         temp:=" * * "+alltrim(str(nextr))+" Files extracted OK * *"

         RipLog(Replicate("Ä",79))
         RipLogSay(temp)
         RipLog(Replicate("Ä",79)+CRLF)

         IF !FBATCH
            tone(200,1)
            tone(200,1)
            inkey(0)
         ENDIF
         retval:=.t.
      endif
   endif
   fclose(h_in)
ENDIF

RETURN retval

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION incname(name,arr)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
local nc:=0,t_ex:="",nam1
if "." $ name
   nam1:=left(name,at(".",name)-1)
   nam1:=left(nam1,min(8,len(nam1)))
   name:=nam1+substr(name,at(".",name))
else
   name:=left(name,min(8,len(name)))
endif


if len(arr)>1
   while ascan(arr,{|x|x[1]==name+t_ex})>0
      nc++
      t_ex:="."+strtran(str(nc,3,0)," ","0")
   enddo
endif
RETURN name+t_ex


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION CHAMPLIB( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(2)
LOCAL cReadBuf := SPACE(2+13+4+4)
LOCAL lFound
LOCAL nSize    := dfFileSize( nHandle )
LOCAL nLastPos := 0

LOCAL nCurrentSize, nCurrentPos

FSEEK(nHandle,0,0)
FREAD( nHandle, @cRead, 2 )

WHILE (lFound:=(FREAD( nHandle, @cReadBuf, 23 )==23))
   nCurrentPos  := BIN2L(SUBSTR(cReadBuf,20,4))
   nCurrentSize := BIN2L(SUBSTR(cReadBuf,16,4))
   IF LEFT(cReadBuf,1)!=CHR(1) .OR.; // Non e' un segmento
      nCurrentPos>nSize        .OR.; // La posizione il size del file
      nCurrentPos<nLastPos           // L'ultima pos e' superiore
                                        // Alla penultima
      IF LEFT(cReadBuf,1)==CHR(0)
         lFound := (LEN(arr)==BIN2W(cRead))
      ELSE
         lFound := .F.
      ENDIF
      EXIT
   ENDIF
   nLastPos := nCurrentPos
   AADD( arr, { incname(normalize(ALLTRIM(SUBSTR(cReadBuf,3,13))),arr), nCurrentPos, nCurrentSize } )
ENDDO

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION deathstar( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(4)
LOCAL cReadBuf
LOCAL nSize    := dfFileSize( nHandle )
LOCAL nLastPos := 0
LOCAL nCount
LOCAL lFound   := .T.

LOCAL nCurrentSize, nCurrentPos

FSEEK(nHandle,0,0)
FREAD(nHandle,@cRead,4)

nCount := BIN2L( cRead )

WHILE LEN(cReadBuf := FREADSTR( nHandle, 13 ))>0
   FSEEK( nHandle, LEN(cReadBuf)-12, FS_RELATIVE )

   FREAD(nHandle,@cRead,4)
   nCurrentPos  := BIN2L(cRead)

   FREAD(nHandle,@cRead,4)
   nCurrentSize := BIN2L(cRead)

   IF nCurrentPos>nSize        .OR.; // La posizione il size del file
      nCurrentPos<nLastPos           // L'ultima pos e' superiore
                                     // Alla penultima
      lFound := .F.
      EXIT
   ENDIF
   nLastPos := nCurrentPos

   AADD( arr, { incname(normalize(cReadBuf),arr), nCurrentPos, nCurrentSize } )

   nCount--
ENDDO
IF lFound
   lFound := nCount==0
ENDIF

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION quake( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(4)
LOCAL cReadBuf
LOCAL nSize    := dfFileSize( nHandle )
LOCAL nLastPos := 0
LOCAL nCount
LOCAL lFound   := .F.
LOCAL nInc     := 0

LOCAL nCurrentSize, nCurrentPos

FSEEK(nHandle,0,0)
FREAD(nHandle,@cRead,4)

IF cRead=="QMAP"
   FSEEK(nHandle,12,0)
   FREAD(nHandle,@cRead,4)
   nLastPos := nCount := BIN2L( cRead )
   IF nCount>0
      msgbldndx(20)
      WHILE nCount-->0
         gauge(nCount,nLastPos)
         FREAD(nHandle,@cRead,4)
         AADD( arr, { "QUAKE."+PADL(nInc++,3,"0"), BIN2L(cRead)+12, 0 } )
      ENDDO
      FOR nCount := 1 TO nLastPos-1
         ARR[nCount][3] := ARR[nCount+1][2]-ARR[nCount][2]
      NEXT
      ARR[LEN(arr)][3] := nSize-ARR[LEN(arr)][2]
      msgbldndx()
      lFound := .T.
   ENDIF
ENDIF

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION chasm( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(4)
LOCAL cReadBuf
LOCAL nSize    := dfFileSize( nHandle )
LOCAL nLastPos := 0
LOCAL nCount
LOCAL lFound   := .F.
LOCAL nInc     := 0
LOCAL nFileLen := 0

LOCAL nCurrentSize, nCurrentPos

FSEEK(nHandle,0,0)
FREAD(nHandle,@cRead,4)

IF cRead=="CSid"
   FSEEK(nHandle,4,0)
   FREAD(nHandle,@cRead,2)
   nLastPos := nCount := MAX( MIN( BIN2W( cRead ), 4095 ), 0 )
   IF nCount>0
      msgbldndx(21)
      cRead := SPACE(21)
      WHILE nCount-->0
         gauge(nCount,nLastPos)
         FREAD(nHandle,@cRead,21)
         AADD( arr, { ALLTRIM(SUBSTR(cRead,2,12)), BIN2L(SUBSTR(cRead,18,4)), BIN2L(SUBSTR(cRead,14,4)) } )
      ENDDO
      msgbldndx()
      lFound := .T.
   ENDIF
ENDIF

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION frost( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(9)
LOCAL nSize    := dfFileSize( nHandle )
LOCAL lFound   := .F.
LOCAL cFile    := ""
LOCAL nNext    := 0

FSEEK(nHandle,0,0)
FREAD(nHandle,@cRead,9)

IF cRead=="TPAC1.6"
   cRead    := SPACE(17)
   msgbldndx(22)

   FSEEK(nHandle,9,0)
   WHILE FREAD(nHandle,@cRead,17)==17
      nNext := BIN2L( SUBSTR(cRead,14,4) )
      cFile := normalize( SUBSTR( cRead, 2, ASC(LEFT(cRead,1)) ) )
      gauge(FSEEK(nHandle,0,1),nSize)
      AADD( arr, { cFile, FSEEK(nHandle,0,1), nNext } )
      FSEEK( nHandle, nNext, 1 )
   ENDDO
   msgbldndx()
   lFound := .T.
ENDIF

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION Coyote( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(20)
LOCAL nSize    := dfFileSize( nHandle )
LOCAL lFound   := .F.
LOCAL cFile    := ""
LOCAL nNext    := 0

FSEEK(nHandle,0,0)
FREAD(nHandle,@cRead,20)
         //12345678901234567890
IF cRead=="COYOTE FILE LIBRARY "
   lFound := .T.
   cRead := SPACE(4)
   FREAD(nHandle,@cRead,4)
   nNext := BIN2L( SUBSTR(cRead,1.4) )

   cRead := SPACE(4)
   FREAD(nHandle,@cRead,4)
   nNext := BIN2L( SUBSTR(cRead,1.4) )

               // Head +Name +Size +????
               //   19 +13   +4    +4
   cRead := SPACE( 40 )
   msgbldndx(23)
   WHILE FREAD(nHandle,@cRead,40)==40
      dfXorPattern( @cRead, CHR(255) )
                          //12345678901234567890
      IF !(SUBSTR(cRead,1,18)=="COYOTE PACKED FILE")
         lFound := .F.
         EXIT
      ENDIF
      nNext := BIN2L( SUBSTR(cRead,33,4) )
      cFile := SUBSTR( cRead, 20, 13 )
      cFile := normalize( cFile )
      gauge(FSEEK(nHandle,0,1),nSize)
      AADD( arr, { cFile, FSEEK(nHandle,0,1), nNext } )
      FSEEK( nHandle, nNext, 1 )
   ENDDO
   msgbldndx()
ENDIF

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION BZIP( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(16)
LOCAL nSize    := dfFileSize( nHandle )
LOCAL lFound   := .F.
LOCAL cFile    := ""
LOCAL nNext    := 0
LOCAL nPos     := 0
LOCAL nOldPos  := 0

FSEEK(nHandle,0,0)
FREAD(nHandle,@cRead,16)
         //12345678901234567890
IF LEFT(cRead,6)=="(B)ZIP" //+CHR(0)+CHR(0)+CHR(2)+CHR(1)
   lFound := .T.

   nNext := BIN2L( SUBSTR(cRead,13.4) )
               // Name +Pos  +Size +Size +????
               //   32 +4    +4    +4    +4
   cRead := SPACE( 48 )
   msgbldndx(24)
   WHILE nNext>0
      FREAD(nHandle,@cRead,48)
      cFile := SUBSTR( cRead, 1, 32 )
      cFile := normalize( cFile )
      nPos  := BIN2L( SUBSTR( cRead, 33, 4 ) )
      IF nPos<nOldPos
         lFound := .F.
         EXIT
      ENDIF
      nOldPos := nPos
      AADD( arr, { cFile, nPos, BIN2L( SUBSTR( cRead, 37, 4 ) ) } )
      gauge(FSEEK(nHandle,0,1),nSize)
      nNext--
   ENDDO
   msgbldndx()
ENDIF

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION FUSION( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(4)
LOCAL nSize    := dfFileSize( nHandle )
LOCAL lFound   := .F.
LOCAL cFile    := ""
LOCAL nNext    := 0
LOCAL nPos     := 0
LOCAL nOldPos  := 0
LOCAL nLocalSize  := 0

FSEEK(nHandle,0,0)
FREAD(nHandle,@cRead,4)
nNext := BIN2L( SUBSTR(cRead,1.4) )
IF nNext<4096 .AND. nNext>0 //Arbitrarian numbers
   lFound := .T.
               // Name +Pos  +Size +Size +????
               //   32 +4    +4    +4    +4
   cRead := SPACE( 32 )
   msgbldndx(25)
   WHILE nNext>0
      IF FREAD(nHandle,@cRead,32)==32
         cFile := SUBSTR( cRead, 1, 20 )
         cFile := normalize( cFile )
         nPos  := BIN2L( SUBSTR( cRead, 21, 4 ) )
         IF nPos<nOldPos
            lFound := .F.
            EXIT
         ENDIF
         nLocalSize := BIN2L( SUBSTR( cRead, 25, 4 ) )
         IF nLocalSize>nSize
            lFound := .F.
            EXIT
         ENDIF
         nOldPos := nPos
         AADD( arr, { cFile, nPos, nLocalSize } )
         gauge(FSEEK(nHandle,0,1),nSize)
         nNext--
      ELSE
         lFound := .F.
         EXIT
      ENDIF
   ENDDO
   msgbldndx()
ENDIF

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION PRIMITIVE( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(4)
LOCAL nSize    := dfFileSize( nHandle )
LOCAL lFound   := .F.
LOCAL cFile    := ""
LOCAL nNext    := 0
LOCAL nPos     := 0
LOCAL nOldPos  := 0
LOCAL nLocalSize := 0

FSEEK(nHandle,0,0)
IF FREAD(nHandle,@cRead,4)==4
   nNext := BIN2L( SUBSTR(cRead,1.4) )
   IF nNext<4096 .AND. nNext>0 //Arbitrarian number
      lFound := .T.
      nPos := (nNext*20)+4
                  // Name +Size
                  //   16 +4
      cRead := SPACE( 20 )
      msgbldndx(26)
      WHILE nNext>0
         IF FREAD(nHandle,@cRead,20)==20
            cFile := SUBSTR( cRead, 1, 16 )
            cFile := normalize( cFile )
            nLocalSize := BIN2L( SUBSTR( cRead, 17, 4 ) )
            IF nPos<nOldPos
               lFound := .F.
               EXIT
            ENDIF
            nOldPos := nPos
            AADD( arr, { cFile, nPos, nLocalSize } )

            gauge(FSEEK(nHandle,0,1),nSize)
            nPos += nLocalSize
            nNext--
         ELSE
            lFound := .F.
            EXIT
         ENDIF
      ENDDO
      IF lFound .AND. nPos!=nSize
         lFound := .F.
      ENDIF
      msgbldndx()
   ENDIF
ENDIF

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION TOUR( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(24)
LOCAL nSize    := dfFileSize( nHandle )
LOCAL lFound   := .F.
LOCAL cFile    := ""
LOCAL nNext    := 0
LOCAL nPos     := 0
LOCAL nNameLen := 0
LOCAL nLocalSize := 0


FSEEK(nHandle,0,0)
msgbldndx(27)
WHILE FREAD(nHandle,@cRead,24)==24
   nLocalSize := BIN2L( SUBSTR(cRead, 5,4) )
   nPos       := BIN2L( SUBSTR(cRead,13,4) )
   nNameLen   := BIN2L( SUBSTR(cRead, 9,4) )
   nNext      := BIN2L( SUBSTR(cRead,21,4) )

   IF ABS(nNameLen)>256 .OR. nNext<FSEEK(nHandle,0,1)
      EXIT
   ENDIF

   cFile := SPACE(nNameLen)
   IF FREAD(nHandle,@cFile,nNameLen)==nNameLen
      cFile := normalize( cFile )
      AADD( arr, { cFile, nPos, nLocalSize } )
      IF nNext==-1
         lFound := .T.
         EXIT
      ENDIF
      FSEEK(nHandle,nNext,0)
   ELSE
      EXIT
   ENDIF
   gauge(FSEEK(nHandle,0,1),nSize)
ENDDO
msgbldndx()

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION ANONYMOUS( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(8)
LOCAL nSize    := dfFileSize( nHandle )
LOCAL lFound   := .F.
LOCAL cFile    := ""
LOCAL nPos     := 0
LOCAL nLen     := 0
LOCAL nFile    := 0

FSEEK(nHandle,0,0)
FREAD(nHandle,@cRead,8)

IF LEFT(cRead,7)=="CTMLIB1"
   cRead    := SPACE(64)
   msgbldndx(28)
   FREAD(nHandle,@cRead,4)
   nFile := BIN2L( SUBSTR(cRead,1,4) )

   WHILE nFile>0
      IF FREAD(nHandle,@cRead,64)==64
         cFile := normalize( SUBSTR( cRead, 1, 52 ) )
         nPos  := BIN2L( SUBSTR(cRead,53,4) )
         nLen  := BIN2L( SUBSTR(cRead,57,4) )
         IF nPos<=nSize
            gauge(nPos,nSize)
            AADD( arr, { cFile, nPos, nLen } )
         ENDIF
      ENDIF
      nFile--
   ENDDO
   msgbldndx()
   lFound := .T.
ENDIF
RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION BAZAR( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(28)
LOCAL nSize    := dfFileSize( nHandle )
LOCAL lFound   := .F.
LOCAL cFile    := ""
LOCAL nNameLen := 0
LOCAL nLocalSize := 0

FSEEK(nHandle,0,0)
msgbldndx(29)
WHILE FREAD(nHandle,@cRead,28)==28
   nLocalSize := BIN2L( SUBSTR(cRead, 9, 4) )
   cFile      :=        SUBSTR(cRead,13,16)
   cFile      := normalize( cFile )
   AADD( arr, { cFile, FSEEK(nHandle,0,1), nLocalSize } )

   DO CASE
      CASE FSEEK(nHandle,0,1)+nLocalSize>nSize
           EXIT
      CASE FSEEK(nHandle,0,1)+nLocalSize==nSize
           lFound := .T.
           EXIT
   ENDCASE

   FSEEK(nHandle, nLocalSize, FS_RELATIVE)
   gauge( FSEEK(nHandle,0,1) ,nSize)
ENDDO
msgbldndx()

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION LOUIS( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(21)
LOCAL nSize    := dfFileSize( nHandle )
LOCAL lFound   := .F.
LOCAL cFile    := ""
LOCAL nNameLen := 0
LOCAL nLocalSize := 0
LOCAL nCount   := 0
LOCAL nPos     := 0
LOCAL nLastPos := nSize

FSEEK(nHandle,nSize-21,0)
IF FREAD(nHandle,@cRead,21)==21
   IF SUBSTR(cRead,18,4)=="OYZO"
      lFound   := .T.
      msgbldndx(30)
      nCount := BIN2L( SUBSTR(cRead,14, 4) )
      WHILE nCount>0
         FSEEK(nHandle, -42, FS_RELATIVE)
         IF FREAD(nHandle,@cRead,21)!=21
            EXIT
         ENDIF
         cFile      :=        SUBSTR(cRead,1,13)
         cFile      := normalize( cFile )
         nLocalSize := BIN2L( SUBSTR(cRead,14, 4) )
         nPos       := BIN2L( SUBSTR(cRead,18, 4) )

         IF nPos>nLastPos .OR. nPos>nSize
            lFound   := .F.
            EXIT
         ENDIF
         nLastPos := nPos

         AADD( arr, { cFile, nPos, nLocalSize } )
         gauge( nPos, nSize )
         nCount--
      ENDDO
      msgbldndx()
   ENDIF
ENDIF

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION JAPOTEKJPK( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(40)
LOCAL nSize    := dfFileSize( nHandle )
LOCAL lFound   := .F.
LOCAL cFile    := ""
LOCAL nNameLen := 0
LOCAL nLocalSize := 0
LOCAL nPos     := 0
LOCAL nLastPos := 0

FSEEK(nHandle,nSize-12,0)
IF FREAD(nHandle,@cRead,12)==12
   IF SUBSTR(cRead,1,4)=="JPK1"
      lFound   := .T.
      msgbldndx(31)
      nPos := BIN2L( SUBSTR(cRead,5,4) )

      FSEEK(nHandle,nSize-nPos+12,0)
      cRead := SPACE(40)
      WHILE FSEEK(nHandle,0,1)<nSize-12
         IF FREAD(nHandle,@cRead,40)!=40
            lFound   := .F.
            EXIT
         ENDIF
         cFile      :=        SUBSTR(cRead,1,32)
         cFile      := normalize( cFile )
         nPos       := nSize-BIN2L( SUBSTR(cRead,33, 4) )
         nLocalSize :=       BIN2L( SUBSTR(cRead,37, 4) )

         IF nPos<nLastPos .OR. nPos>nSize
            lFound   := .F.
            EXIT
         ENDIF
         nLastPos := nPos

         AADD( arr, { cFile, nPos, nLocalSize } )
         gauge( nPos, nSize )
      ENDDO
      msgbldndx()
   ENDIF
ENDIF

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION LABNSW1( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}
LOCAL cRead    := SPACE(40)
LOCAL nSize    := dfFileSize( nHandle )
LOCAL lFound   := .F.
LOCAL cFile    := ""
LOCAL nNameLen := 0
LOCAL nLocalSize := 0
LOCAL nPos     := 0
LOCAL nNamePos := 0
LOCAL nFilePos     := 0
LOCAL nLastPos := 0
LOCAL nLastFilePos := 0
LOCAL nFile := 0

FSEEK(nHandle,0,0)
IF FREAD(nHandle,@cRead,16)==16
   IF SUBSTR(cRead,1,4)=="LABN"
      lFound   := .T.
      msgbldndx(32)
      nFile := BIN2L( SUBSTR(cRead,9,4) )

      nNamePos := (nFile+1)*16
      FSEEK(nHandle,16,0)
      cRead := SPACE(16)
      nLastPos := 16
      nLastFilePos := 0
      WHILE FREAD(nHandle,@cRead,16)==16
         IF --nFile<0
            EXIT
         ENDIF

         nPos      := BIN2L( SUBSTR(cRead,1,4) )
         nFilePos  := BIN2L( SUBSTR(cRead,5,4) )
         nLocalSize:= BIN2L( SUBSTR(cRead,9,4) )

         FSEEK( nHandle, nNamePos+nPos, 0 )

         cFile := FREADSTR( nHandle, 200 )
         cFile      := normalize( cFile )

         //nPos       := nSize-BIN2L( SUBSTR(cRead,33, 4) )
         //nLocalSize :=       BIN2L( SUBSTR(cRead,37, 4) )

         IF nPos<nLastFilePos .OR. nPos>nSize
            lFound   := .F.
            EXIT
         ENDIF
         nLastFilePos := nPos

         AADD( arr, { cFile, nFilePos, nLocalSize } )
         gauge( nFilePos, nSize )
         nLastPos += 16
         FSEEK(nHandle,nLastPos,0)
      ENDDO
      msgbldndx()
   ENDIF
ENDIF

RETURN IF( lFound, arr, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION CRYO( nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL arr      := {}, arr1
LOCAL cRead    := SPACE(40)
LOCAL nSize    := dfFileSize( nHandle )
LOCAL lFound   := .F.
LOCAL cFile    := ""
LOCAL nNameLen := 0
LOCAL nLocalSize := 0
LOCAL nPos     := 0
LOCAL nNamePos := 0
LOCAL nFilePos     := 0
LOCAL nLastPos := 0
LOCAL nLastFilePos := 0
LOCAL nFile := 0
LOCAL nOfs  := 0

FSEEK(nHandle,0,0)
IF FREAD(nHandle,@cRead,16)==16
   IF SUBSTR(cRead,9,5)==CHR(0)+CHR(0)+CHR(0)+CHR(0)+"0"
      nFile := BIN2L( SUBSTR(cRead,5,4) )

      IF nFile>0
         arr1 := arr
         nOfs = 16+(nFile*40)

         lFound   := .T.
         msgbldndx(33)

         nNamePos := (nFile+1)*16
         FSEEK(nHandle,16,0)
         cRead := SPACE(40)
         nLastFilePos := 0
         WHILE FREAD(nHandle,@cRead,40)==40
            IF --nFile<0
               EXIT
            ENDIF

            cFile     := ALLTRIM(SUBSTR(cRead,1,32))
            // Normalizzo
            IF RAT("\",cFile)>0 .AND. RAT("\",cFile)<LEN(cFile)
               cFile := ALLTRIM(SUBSTR( cFile, RAT("\",cFile)+1 ))
            ENDIF
            cFile    := normalize( cFile )
            nLocalSize:= BIN2L( SUBSTR(cRead,33,4) )
            nFilePos  := BIN2L( SUBSTR(cRead,37,4) )

            IF nFilePos<nLastFilePos
               lFound   := .F.
               EXIT
            ENDIF
            nLastFilePos := nFilePos

            AADD( arr, { cFile, nOfs+nFilePos, nLocalSize } )
            IF LEN(arr)==4095
               AADD( arr, {} )
               arr := arr[4096]
            ENDIF
            gauge( nFilePos, nSize )
         ENDDO
         msgbldndx()
      ENDIF
   ENDIF
ENDIF

RETURN IF( lFound, arr1, {} )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION normalize( cstr  )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
local x := at(Chr(0), cstr), cExt
if x > 0
   cstr := left(cstr, x-1)
endif
cstr := Strtran(cstr, Chr(0), "")
cstr := Strtran(cstr, " ", "_")
cstr := Strtran(cstr, "?", "_")
cstr := Strtran(cstr, "*", "_")

IF LEN(cstr)==0 .OR. LEN(cstr)>12
   cExt := ""
   IF RAT(".",cstr)>0
      cExt := SUBSTR( cstr, RAT(".",cstr)+1 )
   ENDIF
   IF EMPTY(cExt)
      cExt := "DMM"
   ENDIF
   cstr := F_ExtName( cExt )
   FERASE( cstr )
ENDIF

RETURN cstr

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE msgbldndx( lib )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
local ctmp :=""
if !empty(lib)
   ctmp:="Building Index for "+alltrim(ARRLIBS[lib])
else
   @ maxrow()-6,6 say space(68) color "GR+/B"
endif
F_saymsg( ctmp, "GR+/B" )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE F_DispArr(arr)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL string, aArr2, aDir, nOpt, cFileToView :="", cScr

cScr := SAVESCREEN(0,0,MAXROW(),MAXCOL())
NACTUAL := NOFFSET := 1
DISPBEGIN()
dfShade( 5, 19, 44, 59 )
@ 5, 19, 44, 60 BOX replicate( chr( 219 ), 8 ) + ' ' COLOR 'W+/B*'
aArr2 := {}
aEval( arr, {| x | aadd( aArr2, ;
      padr(upper(x[1]),12)+" @ "+dflong2hex(x[2])+" ("+str(x[3],8)+" bytes)") },,MIN(4095,LEN(arr)))
DISPEND()
dfWar( 6, 20, 43, 59, aArr2,.F.,"BG+/B","gr+/r" )
NACTUAL := NOFFSET := 1
RESTSCREEN(0,0,MAXROW(),MAXCOL(),cScr)

RETURN
