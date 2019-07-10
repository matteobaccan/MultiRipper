/******************************************************************************
Project     : Expander
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "mripper.ch"

STATIC aStaticone
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE F_Expand( aLocal )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle, cBuff, nPack, cSearch, cBuff1

aStaticone := aLocal

F_DeAlterEXE()
nHandle := F_FOPEN( PARM, FO_READ+FO_SHARED )
IF nHandle>0
   cBuff := SPACE(1024)
   FREAD( nHandle, @cBuff, 1024 )
   FCLOSE( nHandle )

   IF UPPER(SUBSTR(cBuff,1,2))=="MZ" .OR.;
      UPPER(SUBSTR(cBuff,1,2))=="ZM" .OR.;
      ".COM"$UPPER(PARM)
      FOR nPack := 1 TO LEN(FILELIST)
         cSearch := FILELIST[nPack][1]
         cBuff1  := cBuff
         IF LEFT(cSearch,1)=="*"
            cSearch := UPPER(SUBSTR(cSearch,2))
            cBuff1  := UPPER(       cBuff1    )
         ENDIF
         IF cSearch$cBuff1
            IF F_Unpack( PARM, FILELIST[nPack][2] )
               EXIT
            ENDIF
         ENDIF
      NEXT
   ENDIF
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_Unpack( cPack, cPackerList )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T., nPack, nPackNum, cTemp, cPacker,cScr

IF EMPTY(cPackerList)
   RETURN .F.
ENDIF
nPackNum := dfNumToken( cPackerList, "," )

FOR nPack := 1 TO nPackNum
   cPacker := F_GetUnpack( dfToken(cPackerList,",",nPack) )
   IF !EMPTY(cPacker)
      IF FILE( dfToken(cPacker," ",1) )
         cTemp   := F_ExtName( "tmp" )
         IF !EMPTY(cTemp)
            cPacker := UPPER( cPacker )
            cPacker := STRTRAN( cPacker, " SOURCE", " "+cPack )
            cPacker := STRTRAN( cPacker, " DEST"  , " "+cTemp )

            cScr := SAVESCREEN(0,0,MAXROW(),MAXCOL())
            SET COLOR TO
            CLS
            @ 0,0 SAY "Unpacking with " +dfToken(cPacker," ",1)
            ? ""
            ? ""
            IF FILE(cTemp)
               FERASE(cTemp)
            ENDIF
            F_SWPRUNCMD(cPacker,0,"","")
            IF !FBATCH
               INKEY(2)
            ENDIF
            RESTSCREEN(0,0,MAXROW(),MAXCOL(),cScr)
         ENDIF

         lRet := FILE( cTemp )
         IF lRet
            IF ASCAN(AFILE2DEL, {|cFile|cFile==cTemp})==0
               AADD( AFILE2DEL, cTemp )
            ENDIF
            PARM := cTemp
            RipLogSay("Successful unpacking "+cPack +" with " +dfToken(cPacker," ",1))
            EXIT
         ELSE
            RipLogSay("Error unpacking "+cPack +" with " +dfToken(cPacker," ",1))
         ENDIF
      ELSE
         IF !FBATCH
            Alert("Unknown "+dfToken(cPacker," ",1))
         ELSE
            F_say( "Unknown "+dfToken(cPacker," ",1),"gr+/b*" )
         ENDIF
         RipLog( "Unknown "+dfToken(cPacker," ",1) )
      ENDIF
   ENDIF
NEXT

RETURN lRet


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_GetUnpack( cPack )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cPacker := "", nPack

nPack := ASCAN( PACKLIST, {|cSub|UPPER(cSub[1])==UPPER(cPack)} )
IF nPack>0
   cPacker := PACKLIST[nPack][2]
ENDIF

RETURN cPacker

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
EXIT PROCEDURE F_DelTemp()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF aStaticone!=NIL
   AEVAL( AFILE2DEL, {|cFile|FERASE(cFile)} )
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE F_DeAlterEXE()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle := F_FOPEN( PARM, FO_READ+FO_SHARED ), cTemp, cBuff, cStr := ""
LOCAL nHandle1, nPos, cLZExe, cPar, cBuff1

IF nHandle>0
   cBuff := SPACE(1024)
   FREAD( nHandle, @cBuff, 1024 )
   IF UPPER(SUBSTR(cBuff,29,2))=="HS"
      cStr  := " with HackStop "+ ALLTRIM(STR(ASC(SUBSTR(cBuff,32,1)))) +"." +;
                                  ALLTRIM(STR(ASC(SUBSTR(cBuff,31,1))))
   ENDIF
   DO CASE // Ignore file that aren't exe
      CASE !(UPPER(SUBSTR(cBuff,1,2))=="MZ" .OR.;
             UPPER(SUBSTR(cBuff,1,2))=="ZM" .OR.;
             ".COM"$UPPER(PARM))
      CASE UPPER(SUBSTR(cBuff,33,4))=="LITE" .AND.;
           !(UPPER(SUBSTR(cBuff,20,4))==CHR(0)+CHR(1)+CHR(240)+CHR(255))
           IF FBATCH .OR. ALERT( "Altered Pklite file" +cStr +" Found", {"Try correction","Skip"})==1
              RipLogSay("Adjust altered PKLITE")
              cTemp := F_ExtName( "PKL" )
              IF !EMPTY(cTemp)
                 F_DUMP_FILE( cTemp, nHandle, 0, "", dfFileSize(nHandle) )
                 LOCCOUNTER--
                 TOTCOUNTER--
                 IF HACKSTOPERASE
                    IF ASCAN(AFILE2DEL, {|cFile|cFile==cTemp})==0
                       AADD( AFILE2DEL, cTemp )
                    ENDIF
                 ENDIF
                 PARM := cTemp

                 nHandle1 := F_FOPEN( cTemp, FO_READ+FO_WRITE )
                 IF nHandle1>0
                    FSEEK( nHandle1, 20 )
                    FWRITE( nHandle1, CHR(0) +CHR(1) +CHR(240) +CHR(255) )
                    FSEEK( nHandle1, 30 )
                    FWRITE( nHandle1, "PK" )
                    FCLOSE( nHandle1 )
                 ENDIF
              ENDIF
           ENDIF

      CASE UPPER(SUBSTR(cBuff,29,4))=="LZ91"
           nPos :=   ASC(SUBSTR(cBuff, 9,1))*16
           nPos += BIN2W(SUBSTR(cBuff,21,2))
           nPos += BIN2W(SUBSTR(cBuff,23,2))*16
           cLZExe := "‹" +CHR(0) +"‹ñN‰÷ŒÛ"
           cPar := ASC(SUBSTR(cBuff,9,1))
           FSEEK( nHandle, nPos )
           cBuff1 := SPACE(20)
           IF FREAD( nHandle, @cBuff1, 20 )==20 .AND.;
              !(cLZExe==LEFT(cBuff1,LEN(cLZExe)))
              IF FBATCH .OR. ALERT( "Altered LZExe file" +cStr +" Found", {"Try correction","Skip"})==1
                 FSEEK( nHandle, 0 )
                 IF (nPos:=dfPatternPos( nHandle, cLZExe ))>0
                    RipLogSay("Adjust altered LZEXE")
                    cTemp := F_ExtName( "LZE" )
                    IF !EMPTY(cTemp)
                       F_DUMP_FILE( cTemp, nHandle, 0, "", dfFileSize(nHandle) )
                       LOCCOUNTER--
                       TOTCOUNTER--
                       IF HACKSTOPERASE
                          IF ASCAN(AFILE2DEL, {|cFile|cFile==cTemp})==0
                             AADD( AFILE2DEL, cTemp )
                          ENDIF
                       ENDIF
                       PARM := cTemp

                       nHandle1 := F_FOPEN( cTemp, FO_READ+FO_WRITE )
                       IF nHandle1>0
                          nPos -= cPar*16
                          FSEEK( nHandle1, 20 )
                          FWRITE( nHandle1, I2BIN( nPos-INT(nPos/16)*16 ) )
                          FWRITE( nHandle1, I2BIN(      INT(nPos/16)    ) )
                          FCLOSE( nHandle1 )
                       ENDIF
                    ENDIF
                 ENDIF
              ENDIF
           ENDIF
   ENDCASE
   FCLOSE( nHandle )
ENDIF

RETURN
