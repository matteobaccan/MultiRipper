/*
Revisioni:
        1.0: dopo le varie à e á ora funziona (up & down)

        1.1: + aggiunti Shift, fine shift e top
             - migliorato l'output

        1.2: + aggiunto offset (dec + hex)

        1.3: - aggiunto scroll 1 riga alla volta....
             + Invio Per Dumpare la Schermata
             + Maggior bugfix (pi— di un'ora di CLD...)
             + Usate funzioni alternative per snellire il programma
             + passato da 196Kb (Getsys modificata, @...GET , memoread-writ)
                        a 148kb (Accept, fRead,Fwrite...)
             + Compilato con Clipper 5.01 per ulteriore snellezza!

        1.4: + BugFix (penso) Definitivo...
             - per un SEGNO Martin perse la capa... (fread(handle,-offset,2) )
                                                                  ^
             - Aggiunto END (ops!)                                ÀÄÄÄFUCK!
             - Linkato con Blinker 3.0 (1kb in meno!)
        1.41:- solo per bellezza... fade e logo

        1.42:+ Fixato bug per I file < bytes nello schermo con creazione di
        =1.0   file temporaneo... ora si pu• fare il fine-shift
             - Offset mostrato era l'ultimo della schermata, non il primo...
               fixato.
             + Aggiunto tasto SPACE per switch 25/50 righe
             + AGGIUNTO tasto F5 PER GOTO OFFSET
             + AGGIUNTO tasto CTRL-INVIO PER DUMP ASCII!
             + tolti /h /d sostitutiti da f6 e f7 (offset shown + dec or hex)
             - help [f1] + ianlogo.asm
             + minima compatibilit… vari modi testo
             - ottimizzazioni varie
             + rinumerata versione in 1.0 per rilascio ufficiale...
        1.10:+ Aggiunto Alt-invio per dump ANSI (BIN2ANS)
             - aggiunto [F2] per set blink
             - fade finale ora Š migliore (dfscrfade + CPU test)
        1.20 + Supporto wildcard per nome ESC skip next
                                          alt-x esce
                                          f4 browse list
                                          f3 display name
             - minori bugfix (nati per il reload della stessa immagine)
             - help system migliorato... per forza di cose! 8-)
             - uso dfsaybox e dfaliveget modificata
               per un miglior standard TWT!
         1.21- spero di fixare il bug del setblink... forzandolo a .t.!
               migliorato con + e - switch tra i files
               incorporata la DFWAR e modificata (dispbegin()/end())

         1.22- Fixwidth permette di vedere i blocchi ²²²²²²²±±±±±±±°°°°°°°°
               uniti come a 80x43 anche in 80x25/80x50
             - isblink corregge il bug di clipper che inizialmente pensa
               sia sempre .t.


*/

#include "mripper.ch"

#define BAV_VERSION  "1.22"

STATIC count := 0
STATIC y := 1
STATIC hand := 1
static nActual := 1, nOffset := 1, max := 1

*ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Procedure F_BAV(aStaticone,cFile)
*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
LOCAL cbuff , ex := .f. , Bytes_in ,flag:= .f.,flagsav,nomefile,n1
LOCAL typsav := .f.,TempCreate := .f., coff := "",offset := 0,oldblinkstat
LOCAL extension := "", newbuff,adirfiles,loopnext,RELOAD_FILE
LOCAL par2 := .t. ,count_temp,oldact,oldoff

SET CURSOR On
SET CURSOR OFF
oldblinkstat:=IsBlink()
setblink(oldblinkstat) // 1.22
while .t.
    RELOAD_FILE := .F.
    /*
    if maxrow()<24 .or. maxcol() < 79
       cls
       setmode(25,80)
       setmode(50,80)
       setmode(25,80)
    endif
    */
    if maxrow() > 24 .and. maxrow() < 49
       y := 1
    else
       if maxrow() >= 49
          y := 2
       else
          y := 1
       endif
    endif
    count := 4000*y
    hand := fopen(cfile,32)
    if hand < 0
       Alert("Unable to open file "+cFile+" for reading!")
       return
    endif
    max := fseek (hand,0,2)
    fseek(hand,0)
    Bytes_in := 1
    loopnext := .t.
    WHILE bytes_in >0
          cBuff := replicate(CHR(0), 4000*y )
          Bytes_in := fread(hand,@cbuff,4000*y)
          if (Bytes_in < 4000*y .or. max = 4000*y) .and. tempcreate = .f.
             fseek( hand,0 )
             Bytes_in := fread(hand,@cbuff,4000*y)
             cbuff := padr( cbuff, 8000*y ,chr(0) )
             TempCreate := .t.
             fclose( hand )
             cFile:="~~Temp~~.~~~"
             hand := fcreate(cfile)
             if hand < 0
                setcolor("w/n");cls;?"Unable to create tempfile!"
                return
             endif
             fwrite(hand,cbuff)
             max := fseek (hand,0,2)
             fseek(hand,0)
             count := 4000*y
             Bytes_in := 1
             LOOP
          endif
          tempcreate := .t.
          RESTSCREEN(0,0,int(24.5*y),79,CBUFF)
          if flagSav == .t.
              cbuff := savescreen(0,0,int(24.5*y),79)
              do case

                 case typsav == 1
                      dfSayBox( 0,0,2 ,21, "W+/b", "N/b", "W+/b" )
                      @ 1,2 say "*Converting Ascii*" color "W+/b*"
                      newbuff := ""
                      extension := ".asc"
                      for n1 := 1 to len (cbuff) -1 step 2
                          newbuff += substr( cbuff,n1,1 )
                          if ((n1+1)/2)/80 == INT(((n1+1)/2)/80)
                             newbuff += Chr(13)+Chr(10)
                          ENDIF

                      next

                 case typsav == 2
                      dfSayBox( 0,0,2 ,33, "W+/r", "N/r", "W+/r" )
                      setcolor( "W+/r*" )
                      @ 1,1 say " *Converting Ansi* "
                      setcolor( "W+/r" )
                      bin2ans(cbuff,nomefile,.t.,row(),col())
                      setcolor( "W/n" )

                 otherwise
                      extension := ".bin"
                      newbuff := cbuff
              endcase
              if typsav < 2
                 n1 := fcreate( left( nomefile , if( "." $ nomefile,at(".", nomefile)-1,8))+extension )
                 if n1 < 0
                    setcolor("w/n");cls;?"Unable to create file "+nomefile+" !"
                    return
                 endif
                 fwrite( n1, newbuff )
                 fclose( n1 )
              endif
              restscreen( 0,0,int(24.5*y),79,cbuff)
          endif
          flagSav := .f.
          EX := .f.
          WHILE !EX
                IF flag
                   devpos(0,0)
                   IF par2
                      devout( dfLong2hex( int( count-4000*y ) ))
                   ELSE
                      devout( int( count-4000*y ))
                   ENDIF
                ENDIF
                ex := .t.
                ** __keyboard()
                inkey(0)
                DO CASE
                   CASE lastkey() == K_PGDN
                        count += 4000*y
                        IF count > max
                           Endfile()
                        ENDIF
                   CASE lastkey() == K_PGUP
                        count -= 4000*y
                        IF count <= 4000*y
                           home()
                        ELSE
                           fseek(hand,-8000*y,1)
                        ENDIF

                   CASE lastkey() == K_UP
                        count-= 160
                        IF count <= 4000*y
                           home()
                        ELSE
                           fseek(hand,-(4000*y+160),1)
                        ENDIF

                   CASE lastkey() == K_DOWN
                        count+=160
                        IF count > max
                           Endfile()
                        ELSE
                           fseek(hand,-(4000*y-160),1)
                        ENDIF

                   CASE lastkey() == K_LEFT
                        count--
                        count--
                        IF count <= 4000*y
                           home()
                        ELSE
                           fseek(hand,-(4000*y+2),1)
                        ENDIF

                   CASE lastkey() == K_RIGHT
                        count++
                        count++
                        IF count > max
                           Endfile()
                        ELSE
                           fseek(hand,-(4000*y-2),1)
                        ENDIF

                   CASE lastkey() == K_CTRL_LEFT
                        count--
                        IF count <= 4000*y
                           home()
                        ELSE
                           fseek(hand,-(4000*y+1),1)
                        ENDIF

                   CASE lastkey() == K_CTRL_RIGHT
                        count++
                        IF count > max
                           Endfile()
                        ELSE
                           fseek(hand,-(4000*y-1),1)
                        ENDIF

                   CASE lastkey() == K_HOME
                        home()

                   CASE Lastkey() == K_END
                        Endfile()

                   CASE lastkey() == K_ALT_X  .or. lastkey() == K_ESC
                        Bytes_in := 0
                        loopnext = .f.

                   case lastkey() == K_ALT_A .or. lastkey() == K_ALT_B .or. lastkey() == K_ALT_I
                        DO CASE
                           CASE lastkey() == K_ALT_I
                                typsav := 1
                                setcolor("bg+/r")
                                dfSayBox( 0,0,2 ,79, "w+/r", "rb/r", "bg+/r" )
                           CASE lastkey() == K_ALT_A
                                typsav := 2
                                setcolor("RB+/r")
                                dfSayBox( 0,0,2 ,79, "GR+/R", "N+/R", "RB+/r" )
                           OTHERWISE
                                typsav := 0
                                setcolor("GR+/r")
                                dfSayBox( 0,0,2 ,79, "W+/r", "N/R", "GR+/r" )
                        ENDCASE
                        @ 1,1 say "Save file "+;
                                    if(typsav=0,"[Binary]",;
                                      if( typsav=1, "[Ascii]", "[Ansi]"))+;
                                      " :"
                        nomefile := dfaliveget( row(),col(),55,"gr+/r")
                        setcolor("w/n")
                        if !empty(nomefile)
                           flagSav := .t.
                        else
                           flagSav := .f.
                        endif
                        Still()

                   case lastkey() == K_F5
                        setcolor("gr+/b")
                        //SET CURSOR ON
                        //devpos(1,0); ??Space(79)
                        dfSayBox( 0,0,2 ,79, "BG/b", "N/B", "gr+/B" )
                        @ 1,1 say "Goto offset [prefix '0x' for hex] :"
                        coff:=dfaliveget( row(),col(),20,"gr+/B")
                        setcolor("w/n")
                        //SET CURSOR Off
                        Still()
                        coff := alltrim(coff)
                        if !empty( coff )
                           if upper(left( coff,2 )) ="0X"
                              offset := dfhex2dec(substr(coff,3) )
                           else
                              offset := val( coff )
                           endif
                           if offset >= 0
                              if offset <= max-(4000*y)
                                 fseek( hand,offset,0)
                                 count := offset+(4000*y)
                              else
                                 Endfile()
                              endif
                           else
                              tone(100,1)

                           endif

                        endif

                   case lastkey() == K_F6
                        flag := !flag
                        Still()

                   case lastkey() == K_F7
                        par2 := !par2
                        Still()

                   case lastkey() == K_F1
                        bavhelp()
                        inkey(20)
                        Still()

                   case lastkey() == K_F2
                        setblink( !setblink() )
                        Still()

                   case lastkey() == 45
                        if F_DecName()
                           RELOAD_FILE := .T.
                           tempcreate := .f.
                           bytes_in := 0
                           cfile := PARM
                        endif

                   case lastkey() == 43
                        if F_IncName()
                           RELOAD_FILE := .T.
                           tempcreate := .f.
                           bytes_in := 0
                           cfile := PARM
                        endif

                   case lastkey() == K_F3
                        dfSayBox( int((24.5*y)/2)-1,25, int((24.5*y)/2)+1,55, "W+/BG", "N+/BG", "B+/BG" )
                        @ int((24.5*y)/2) ,27 say "Current file : "+PARM color "B/BG"
                        inkey(10)
                        still()

                   case lastkey() == K_F10
                        F_CngFile()
                        RELOAD_FILE := .T.
                        tempcreate := .f.
                        bytes_in := 0
                        cfile := PARM

                   OTHERwise
                   tone(100,1)
                   __keyboard()
                   ex := .f.
                ENDCASE
                if !loopnext .OR. RELOAD_FILE
                   ex := .t.
                endif
          ENDDO
    enddo
    if !loopnext
       exit
    endif
    fclose(hand)
    if RELOAD_FILE
       loop
    endif
enddo //next
fclose(hand)
cls
setblink(oldblinkstat) // 1.22
ferase("~~Temp~~.~~~")
return

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROC bavhelp()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dispbegin()
setcolor("W+/n")
CLS
bannerone()
SETCOLOR("r+/N");?" Controls:"
SETCOLOR("Gr+/N");?" [UP]+[DOWN] ............... ";SETCOLOR("W+/N");??"Scroll up'n'down"
SETCOLOR("Gr+/N");?" [PGUP]+[PGDN] ............. ";SETCOLOR("W+/N");??"Paging up'n'down"
SETCOLOR("Gr+/N");?" [LEFT]+[RIGHT] ............ ";SETCOLOR("W+/N");??"Shift (2 bytes)"
SETCOLOR("Gr+/N");?" [CTRL-LEFT]+[CTRL-RIGHT] .. ";SETCOLOR("W+/N");??"Fine Shift (1 byte)"
SETCOLOR("Gr+/N");?" [HOME]+[END] .............. ";SETCOLOR("W+/N");??"Top/End of file"
SETCOLOR("Gr+/N");?" [F1] ...................... ";SETCOLOR("W+/N");??"This Help on Usage"
SETCOLOR("Gr+/N");?" [F2] ...................... ";SETCOLOR("W+/N");??"Blink/intense backgr. toggle"
SETCOLOR("Gr+/N");?" [F3] ...................... ";SETCOLOR("W+/N");??"Display current viewed file"
SETCOLOR("Gr+/N");?" [F5] ...................... ";SETCOLOR("W+/N");??"Goto offset (Dec. or Hex.)"
SETCOLOR("Gr+/N");?" [F6] ...................... ";SETCOLOR("W+/N");??"Show offset Toggle"
SETCOLOR("Gr+/N");?" [F7] ...................... ";SETCOLOR("W+/N");??"Dec. or Hex. offset"
SETCOLOR("Gr+/N");?" [F10] ..................... ";SETCOLOR("W+/N");??"Change File"
SETCOLOR("Gr+/N");?" [ALT+B] ................... ";SETCOLOR("W+/N");??"Dump Screen in Binary format"
SETCOLOR("Gr+/N");?" [ALT+A] ................... ";SETCOLOR("W+/N");??"Dump Screen in Ansi format"
SETCOLOR("Gr+/N");?" [ALT+I] ................... ";SETCOLOR("W+/N");??"Dump Screen in Ascii format"
SETCOLOR("Gr+/N");?" [+/-] ..................... ";SETCOLOR("W+/N");??"Next/Previous File"
SETCOLOR("Gr+/N");?" [ESC/ALT-X] ............... ";SETCOLOR("W+/N");??"Return to ripper"
setcolor("W/n")
dispend()

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC proc still(  )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF count <= 4000*y
   home()
ELSE
   fseek(hand,-4000*y,1)
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC proc home()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
count := 4000*y
fseek(hand,0)

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC proc Endfile()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
count := max
fseek(hand,-4000*y,2)

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Dfaliveget(_Def, _Def1, _Def2, _Def3)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

LOCAL nNum, cStr, _Def4, cStr1 := "ú"+Chr(7)+"þ"+Chr(4)+"Û²±°  "

IF _Def3 == NIL
   _Def3 := Setcolor()
ENDIF

Dfpushcursor()
Setcursor(0)
nNum := 0
cStr := ""
Devpos(_Def, _Def1)
Devout(Padr(cStr, _Def2), _Def3)

DO WHILE nNum <= _Def2

   DO WHILE .T.

      _Def4 := inkey(0.1)

      IF _Def4 == 27

         EXIT

      ELSEIF _Def4 == 13

         EXIT

      ELSEIF _Def4 >= 32 .AND. nNum < _Def2

         EXIT

      ELSEIF (_Def4 == 8 .OR. _Def4 == 19) .AND. nNum > 0

         Devpos(_Def, _Def1 + nNum)
         Devout(" ", _Def3)
         --nNum
         cStr := Left(cStr, Len(cStr) - 1)

      ELSE

         cStr1 := Substr(cStr1, 2) + Left(cStr1, 1)
         Devpos(_Def, _Def1 + nNum)
         Devout(Left(cStr1, 1), _Def3)

      ENDIF

   ENDDO

   IF _Def4 = 27
      cstr:=""
      EXIT

   ENDIF

   IF _Def4 = 13
         devpos(row(),col()-1)
         Devout(" ")

      EXIT

   ENDIF

   cStr := cStr + Chr(_Def4)
   Devpos(_Def, _Def1 + nNum)
   Devout(Chr(_Def4), _Def3)
   ++nNum

ENDDO

Devpos(_Def, _Def1)
Devout(cStr := Padr(cStr, _Def2), _Def3)
Dfpopcursor()

RETURN cStr
