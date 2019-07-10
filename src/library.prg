#include "common.ch"
#include "Fileio.ch"
#include "inkey.ch"

#INCLUDE "dfSet.ch"
#include "dfExeTyp.ch"
#include "dfStack.ch"
#include "dffile.ch"

#define CRLF                  CHR(13)+CHR(10)

STATIC aFL := {}, nFL := 0
STATIC aAll := {}

func SHELL()          ; SWPRUNCMD("COMMAND.com"); RETURN nil
PROCEDURE SWPRUNCMD(a); RUN(a)                  ; RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
func ISBLINK()   ; retu .T.
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
func dfexename(); return dfargv(0)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION  dfRow(  )         ; RETURN ROW()
FUNCTION  dfCol(  )         ; RETURN COL()
FUNCTION  dfSetPos(x,y)     ; RETURN SETPOS(x,y)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION BIN2HEX( cStr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet := "", nPos
FOR nPos := 1 TO 8
   cRet += dfDec2Hex( ASC(substr(cStr,nPos,1)) )
   IF nPos<8
      cRet += " "
   ENDIF
NEXT
RETURN cRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfExePath() // Torna il Path dell'exe
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN LEFT( dfExeName(), RAT( "\", dfExeName() ) )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFindName( cName )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, nPos1

nPos  := RAT(".",cName)
nPos1 := MAX( RAT("\",cName), RAT(":",cName) )

IF nPos>0 .AND. nPos>nPos1
   cName := LEFT( cName, nPos-1 )
ENDIF

IF nPos1>0
   cName := SUBSTR( cName, nPos1+1 )
ENDIF

RETURN cName

#define PATTERN_LEN  4096

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPatternPos( cFile, cPattern )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle, nRec := 0, cBuf := SPACE( PATTERN_LEN ), nPos, nRead
LOCAL nLen := LEN(cPattern)

IF VALTYPE( cFile )=="N"
   nHandle := cFile
ELSE
   nHandle := FOPEN( ALLTRIM(cFile), FO_READ+FO_SHARED )
ENDIF

IF nHandle>0
   WHILE ( nRead := FREAD( nHandle, @cBuf, PATTERN_LEN ) ) > 0
      IF ( nPos := AT( cPattern, cBuf ) ) > 0
         nRec := FSEEK( nHandle, 0, FS_RELATIVE )
         nRec -= ( nRead-nPos+1 )
         EXIT
      ENDIF
      IF nRead>nLen
         FSEEK( nHandle, -nLen, FS_RELATIVE )
      ENDIF
   ENDDO
   IF VALTYPE( cFile )!="N"
      FCLOSE( nHandle )
   ENDIF
ENDIF

RETURN nRec

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfInkey( nSeconds )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nKey
DEFAULT nSeconds TO 0
WHILE .T.
   nKey := INKEY(nSeconds)
   IF nKey==K_ALT_F1
      Shell()
      nKey := 0
   ENDIF
   IF nKey#0 .OR. nSeconds#0
      EXIT
   ENDIF
ENDDO
RETURN nKey

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFileSize( cFile )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nSize := 0, nHandle := -1, nCurrent

DO CASE
   CASE VALTYPE(cFile)="C"
        nHandle := FOPEN(cFile,FO_READ+FO_SHARED)

   CASE VALTYPE(cFile)="N"
        nHandle := cFile
ENDCASE

IF nHandle>0
   nCurrent := FSEEK(nHandle,0,FS_RELATIVE)
   nSize    := FSEEK(nHandle,0,FS_END)
   FSEEK(nHandle,nCurrent,FS_SET)
   IF VALTYPE(cFile)="C"
      FCLOSE(nHandle)
   END
ENDIF

RETURN nSize

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfStdEnd()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SET COLOR TO
CLS
? "                               THANX FOR USING A"
? ""
? "                        ÛÛÛÛÛÛÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛÛÛÛÛÛÛ"
? "                        ÛÛÛÛÛÛÛÛÛ ÛÛÛ ÛÛ ÛÛÛ ÛÛÛÛÛÛÛÛÛ"
? "                           ÛÛÛ    ÛÛÛ ÛÛ ÛÛÛ    ÛÛÛ"
? "                           ÛÛÛ    ÛÛÛÛÛÛÛÛÛÛ    ÛÛÛ"
? "                           ßßß     ßßßßßßßß     ßßß"
? ""
? "                                U T I L I T Y !"
? ""
? "                         ÄÍþ THe PeRFeCT SoLuTioN þÍÄ"
? ""
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfSec2Time( nSec )  // Converte i secondi in ora - HH:MM:SS
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nTmpSec := 0, cRet := "00:00:00"

DEFAULT nSec TO SECONDS()

nSec    := INT(nSec)
IF nSec>0
   nTmpSec := INT( nSec/3600 )
   cRet    := ALLTRIM(STR(nTmpSec))
   cRet    := PADL(cRet,MAX(2,LEN(cRet)),"0")+":"
   nSec    := nSec - nTmpSec*3600

   nTmpSec := INT( nSec/60 )
   cRet    += PADL(ALLTRIM(STR(nTmpSec)),2,"0")+":"
   nSec    := nSec - nTmpSec*60

   cRet    += PADL(ALLTRIM(STR(nSec)),2,"0")
ENDIF

RETURN cRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfExeType( cExe )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRet := EXE_TYPE_UNKNOWN, cBuf := SPACE(2), nExeTyp, nHandle, nExeHeader

nHandle := FOPEN( cExe )
FREAD( nHandle, @cBuf, 2 )

IF cBuf$"MZM"

   nRet := EXE_TYPE_MZ

   FSEEK( nHandle, dfHex2Dec("18") )
   FREAD( nHandle, @cBuf, 2 )
   nExeTyp := BIN2W(cBuf)

   IF (nExeTyp==dfHex2Dec("40"))
      FSEEK( nHandle, dfHex2Dec("3C") )
      cBuf := SPACE(4)
      FREAD( nHandle, @cBuf, 4 )
      nExeHeader := BIN2L(cBuf)
      FSEEK( nHandle, nExeHeader )

      cBuf := SPACE(2)
      FREAD( nHandle, @cBuf, 2 )

      DO CASE
         CASE (cBuf=="NE"); nRet := EXE_TYPE_NE
         CASE (cBuf=="LE"); nRet := EXE_TYPE_LE
         CASE (cBuf=="LX"); nRet := EXE_TYPE_LX
         CASE (cBuf=="W3"); nRet := EXE_TYPE_W3
         CASE (cBuf=="PE"); nRet := EXE_TYPE_PE
         CASE (cBuf=="DL"); nRet := EXE_TYPE_DL
         CASE (cBuf=="MP"); nRet := EXE_TYPE_MP
         CASE (cBuf=="P2"); nRet := EXE_TYPE_P2
         CASE (cBuf=="P3"); nRet := EXE_TYPE_P3
      ENDCASE

   ENDIF
ENDIF

FCLOSE( nHandle )

RETURN nRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfFTop()               // Si posiziona al TOP
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfFGoto( 0 )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfFSkip()               // Esegue uno Skip avanti di una riga
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos
LOCAL nLen
LOCAL cBuf
LOCAL nPosSep
LOCAL aActual := dfFActual()

IF !dfFEof()
   WHILE .T.
      IF (nPos := At( aActual[FL_SEPCHAR], aActual[FL_BUFFER] )) == 0    // nessuna riga

         aActual[FL_OFFSET] += aActual[FL_BUFPOS]

         fSeek( aActual[FL_HANDLE], aActual[FL_OFFSET], FS_SET )

         cBuf := SPACE(aActual[FL_RECLEN])
         nLen := fRead( aActual[FL_HANDLE], @cBuf, aActual[FL_RECLEN] ) // Leggo

         aActual[FL_BUFFER] := cBuf

         DO CASE
            CASE nLen == aActual[FL_RECLEN]
                 nPos := At( aActual[FL_SEPCHAR], aActual[FL_BUFFER] )

            CASE nLen > 0
                 aActual[FL_BUFFER] := Left( aActual[FL_BUFFER], nLen )

                 nPos := At( aActual[FL_SEPCHAR], aActual[FL_BUFFER] )
                 IF nPos == 0
                    nPos := nLen +1
                 ENDIF

            OTHERWISE
                 aActual[FL_BUFFER] := ""
                 aActual[FL_EOF] := .T.
                 nPos := 1
         ENDCASE
         IF (nPosSep := RAT( aActual[FL_SEPCHAR], aActual[FL_BUFFER] )) #0
            aActual[FL_BUFPOS] := nPosSep + aActual[FL_SEPLEN]
         ELSE
            aActual[FL_BUFPOS] := nPos
         ENDIF
         aActual[FL_BUFPOS]--
      ENDIF
      aActual[FL_LINE]   := Left( aActual[FL_BUFFER], nPos-1 )
      aActual[FL_BUFFER] := SubStr( aActual[FL_BUFFER], nPos+aActual[FL_SEPLEN] )
      IF aActual[FL_SKIPREM]
         IF aActual[FL_EOF] .OR. !dfFIsRem(aActual[FL_LINE])
            EXIT
         ENDIF
      ELSE
         EXIT
      ENDIF
   ENDDO
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFOpen( cFile, nMode, cSep, nLen, lSkipRem ) // Apertura file
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle

DEFAULT nMode    TO FO_READ +FO_EXCLUSIVE // Apro in lettura Esclusiva
DEFAULT cSep     TO CRLF
DEFAULT nLen     TO FL_BUFFERLEN
DEFAULT lSkipRem TO .F.

cFile := Upper( cFile )

nHandle := FOpen( cFile, nMode )

IF nHandle # F_ERROR
   aAdd( aFL, { cFile, nHandle, "", "", 0, 0, .F., cSep, LEN(cSep), nLen, lSkipRem  })
   nFL := LEN(aFl)
   dfFTop()
ENDIF

RETURN nHandle

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFCreate( cFile, nMode, cSep, nLen, lSkipRem ) // Creazione file
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle

DEFAULT nMode    TO FC_NORMAL              // Creo normale
DEFAULT cSep     TO CRLF
DEFAULT nLen     TO FL_BUFFERLEN
DEFAULT lSkipRem TO .F.

cFile := Upper( cFile )

nHandle := FCREATE( cFile, nMode )

IF nHandle # F_ERROR
   aAdd( aFL, { cFile, nHandle, "", "", 0, 0, .F., cSep, LEN(cSep), nLen, lSkipRem  })
   nFL := LEN(aFl)
ENDIF

RETURN nHandle

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFClose( nHandle )              // Chiude il file
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nErr := F_ERROR
LOCAL nAct := nFl

IF nHandle # NIL
   nAct := aScan( aFL, {|aSub| aSub[FL_HANDLE]==nHandle } )
ENDIF

IF nAct > 0
   nErr := FClose( aFL[nAct][FL_HANDLE] )
   aDel( aFL, nAct )
   aSize( aFL, Len(aFL)-1 )
   IF nFL == nAct
      nFl := 0
   ENDIF
ENDIF

RETURN nErr

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFSelect( nHandle )    // Seleziona il file attivo
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nOldHan := nFL
nFL := aScan( aFL, {|aSub| aSub[FL_HANDLE]==nHandle } )
IF nFL == 0                // Se non riesce a posizionarlo rimette il Vecchio
   nFL := nOldHan
ENDIF
RETURN nOldHan             // torna comunque il Vecchio

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFActual()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN aFL[nFL]

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFRead()               // Legge una riga
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN aFL[nFL][FL_LINE]

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFEof()                // Torna l'eof
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN aFL[nFL][FL_EOF]

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFPos()                // Torna la posizione attuale
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nActual := dfFActual()
RETURN FSEEK( nActual[FL_HANDLE], 0, FS_RELATIVE ) -;
        ( LEN(nActual[FL_BUFFER])+nActual[FL_SEPLEN]+LEN(nActual[FL_LINE]) )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfFGoto( nPos )        // Va all'offset
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nActual := dfFActual()
FSEEK( nActual[FL_HANDLE], nPos, FS_SET ) // Go Top
nActual[FL_LINE]   := ""
nActual[FL_OFFSET] := nPos
nActual[FL_EOF]    := .F.
nActual[FL_BUFFER] := SPACE(nActual[FL_RECLEN])
nActual[FL_BUFPOS] := 0
dfFSkip()
RETURN

// Da controllare
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfFUp()                // Va all'offset
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nActual := dfFActual()
LOCAL nPos    := MAX( dfFPos()-(nActual[FL_SEPLEN]+nActual[FL_RECLEN]), 0 )
LOCAL cBuf, nAT

FSEEK( nActual[FL_HANDLE], nPos, FS_SET )

cBuf := SPACE( nActual[FL_RECLEN] )
        FREAD( nActual[FL_HANDLE], @cBuf, nActual[FL_RECLEN] )
nAT  := RAT( nActual[FL_SEPCHAR], cBuf )
IF nAT>0
   nAT += nActual[FL_SEPLEN]
ENDIF
nPos := FSEEK( nActual[FL_HANDLE], 0, FS_RELATIVE )-(nActual[FL_RECLEN]-nAT+1)

dfFGoto( nPos )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfRight( cStr, nType, nSubType ) // Torna la destra di un'egualianza
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos := AT( "=", cStr )+1, uRet := "", nTok, aDmm, uSub

IF nPos > 0
   uRet := ALLTRIM(SUBSTR( cStr, nPos ))
ENDIF

DO CASE
   CASE nType == NIL .OR. nType == RT_CHARACTER

   CASE nType == RT_ARRAY
        nTok := dfNumToken( uRet, ",")
        aDmm := {}
        IF nTok>0
           FOR nPos := 1 TO nTok
              uSub := dfToken( uRet, ",", nPos)
              IF nSubType == NIL .OR. nSubType == RT_CHARACTER
                 AADD( aDmm, ALLTRIM( uSub ) )
              ELSE
                 AADD( aDmm, dfRight( "=" +uSub, nSubType ) )
              ENDIF
           NEXT
        ENDIF
        uRet := aDmm

   CASE nType == RT_LOGICAL
        uRet :=  !( EMPTY(uRet) .OR. UPPER(uRet) == "NO" )

   CASE nType == RT_NUMBER
        uRet := VAL( uRet )

ENDCASE

RETURN uRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPushCursor() // Salva l'All attuale
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
AADD( aAll, { SETCOLOR()  ,;
              dfRow()     ,;
              dfCol()     ,;
              SETCURSOR() })
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPopCursor() // Ristabilisce l'ultima All
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SET CURSOR OFF
SET CURSOR ON
SETCOLOR( ATAIL(aAll)[ALL_COLOR] )
dfSetPos( ATAIL(aAll)[ALL_ROW], ATAIL(aAll)[ALL_COL] )
SETCURSOR( ATAIL(aAll)[ALL_SHAPE] )

ASIZE( aAll, LEN(aAll)-1 )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPushCurNum(); RETURN LEN(aAll)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±




#pragma BEGINDUMP

#include "extend.api"
#include <Gt.api>
#include <fm.api>
#include <filesys.api>

HB_FUNC( DFAND ){
  _retni(_parni(1)&_parni(2));
}

HB_FUNC( DFXOR ){
  _retni(_parni(1)^_parni(2));
}

HB_FUNC( DFARGC ){
  _retni(__argc);
}

HB_FUNC( DFARGV ){
  _retc(__argv[_parni(1)]);
}


char * _dfDec2Hex( unsigned int iReg ){
  static char fpHexBuf[5];
  static char * fpChar ="0123456789ABCDEF";

  //fpHexBuf[0] = fpChar[iReg/(16*16*16) & 0x0f ];
  //fpHexBuf[1] = fpChar[iReg/(16*16)    & 0x0f ];
  fpHexBuf[0] = fpChar[iReg/(16)       & 0x0f ];
  fpHexBuf[1] = fpChar[iReg            & 0x0f ];
  fpHexBuf[2] = '\0';

  return fpHexBuf;
}

HB_FUNC( DFDEC2HEX ){
   _retc( _dfDec2Hex( _parni(1) ) );
}

int _dfFIsRem( char * fpString, int iLen ) {
   int iRet, iRem, iEmpty, iPos;

   iPos=0;
   iEmpty=1;
   iRem=0;
   iRet=0;

   while( iPos<iLen ){
      if( fpString[iPos]==';' && iEmpty==1 ) iRem=1;

      if( fpString[iPos]!='\x09' &&
          fpString[iPos]!='\x0a' &&
          fpString[iPos]!='\x0d' &&
          fpString[iPos]!='\x20' && iRem!=1 ) iEmpty=0;

      if( iRem==1 || iEmpty==0 ) iPos=iLen;
      iPos++;
   }

   if( iRem==1 || iEmpty==1 ) iRet=1;

   if( iLen==1 && fpString[0]=='\x1a' ) iRet=1; // Riga di EOF()

   return iRet;
}

HB_FUNC( DFFISREM ){
   _retl( _dfFIsRem(_parc(1), _parclen(1)) );
}


#define ISTRAILING( chr )    ( chr==9 || chr==10 || chr==13 || chr==32 )

HB_FUNC( DFLEFT ){
   char *fpStr=_parc(1);
   char fpRet[1024];
   int  iPos=0;
   int  iAdd=0;
   int  iLen=_parclen(1);

   while( ISTRAILING(fpStr[iPos]) && iPos<iLen ) iPos++; // Skip space

   while( iPos<iLen && fpStr[iPos]!='=' ) fpRet[iAdd++]=fpStr[iPos++];

   if( fpStr[iPos]=='=' && iAdd>0 ){
      fpRet[iAdd--]=0;
      while( iPos<iLen && iAdd>=0 && ISTRAILING(fpRet[iAdd]) ) fpRet[iAdd--]=0;
   }else fpRet[0]=0;

  _retc(fpRet);
}

unsigned int _dfHex2Dec( char * cpString ){
   int iLen, iMax, iChar;
   unsigned int iVal=0,iExp=1;

   iLen = iMax = strlen( cpString );
   while( iLen-->0 ){
      iChar=cpString[iLen];
      if(iMax==iLen+1) iExp = 1;
      else iExp*=16;
      if(iChar>=97 && iChar<=102) iChar-=32;
      if(iChar>=65 && iChar<=70)  iChar-=7;
      if(iChar>=48 && iChar<=63)  iChar-=48;
      if(iChar>=0  && iChar<=16)  iVal +=(iChar*iExp);
   }
   return iVal;
}

HB_FUNC( DFHEX2DEC ){
   _retnl( _dfHex2Dec( _parc(1) ) );
}

HB_ERRCODE _dfRectSize( USHORT  usTop    ,
                     USHORT  usLeft   ,
                     USHORT  usBottom ,
                     USHORT  usRight  ,
                     USHORTP usSize   ){

   HB_ERRCODE eRet=0;

   usSize[0]=0;
   if( usTop<=usBottom && usLeft<=usRight )
       usSize[0]= (usBottom-usTop+1)*(usRight-usLeft+1)*2;
   else eRet=1;

   return eRet;
}

USHORT _dfUpper( char *tpp )
{
USHORT i;

for( i = 0 ; tpp[i] != '\0' ; i++ ) {
    tpp[i] = tpp[i] >= 'a' && tpp[i] <= 'z' ? (char) ( tpp[i] - 32 ) : tpp[i];
}
return( i );
}

char * _dfLong2Hex( unsigned long lReg ){
  static char fpHexBuf[9];
  static char * fpChar ="0123456789ABCDEF";

  fpHexBuf[0] = fpChar[lReg/(65536*256*16) & 0x0f ];
  fpHexBuf[1] = fpChar[lReg/(65536*256)    & 0x0f ];
  fpHexBuf[2] = fpChar[lReg/(65536*16)     & 0x0f ];
  fpHexBuf[3] = fpChar[lReg/(65536)        & 0x0f ];
  fpHexBuf[4] = fpChar[lReg/(256*16)       & 0x0f ];
  fpHexBuf[5] = fpChar[lReg/(256)          & 0x0f ];
  fpHexBuf[6] = fpChar[lReg/(16)           & 0x0f ];
  fpHexBuf[7] = fpChar[lReg                & 0x0f ];
  fpHexBuf[8] = '\0';

  return fpHexBuf;
}

HB_FUNC( DFLONG2HEX ){
   _retc( _dfLong2Hex( _parnl(1) ) );
}

HB_FUNC( DFNUMTOKEN ){
        register short  Tok;
        register char           Delim;
        register char           TypTok;

        char                                    * String;


        if ( PCOUNT != 2 )
                {
                return;
                }

        String = _parc( 1 );                   /* legge i parametri */
        Delim  = _parc( 2 )[0];

        TypTok = (char) ( _parclen( 2 ) == 1 ? 0 : 1 );

        if( String[0] == '\0' )                /* stringa vuota: 0 token */
                {
                _retni( 0 );
                return;
                }

        Tok = 1;

        while( * String )                                                               /* conta i token */
                {
                if( *( String ++ ) == Delim )
                        {
                        Tok ++;

                        if( TypTok )
                                {
                                while( * String == Delim &&
                                                 * String
                                          )
                                        String ++;
                                }
                        }
                }

        _retni( Tok );                                                          /* ritorna il numero di token */
        return;
}

unsigned char _dfCol2Num( char * fpColor ){
   static char fpColorF[][4] = { "N" , "B" , "G" , "BG" , "R" , "RB" , "GR" , "W" ,
                                 "N+", "B+", "G+", "BG+", "R+", "RB+", "GR+", "W+" };

   static char fpColorB[][4] = { "N" , "B" , "G" , "BG" , "R" , "RB" , "GR" , "W" ,
                                 "N*", "B*", "G*", "BG*", "R*", "RB*", "GR*", "W*" };

   int iSlash=-1;
   char i;
   unsigned char iBios=0;

   _dfUpper( fpColor );

   i=0;
   while( fpColor[i] && fpColor[i] != '/' ) i++;
   if( fpColor[i] != '\0'){
      iSlash=i;
      fpColor[i]='\0';
   }

   i=0;
   while( i<16 && strcmp(fpColor,fpColorF[i]) ) i++;
   if(iSlash != -1) fpColor[iSlash] = '/';

   if(i<16){
      iBios=i;
      fpColor += strlen(fpColorF[i]);
      if(fpColor){
         fpColor++;
         i=0;
         while( i<16 && strcmp(fpColor,fpColorB[i]) ) i++;
         if(i<16)iBios += (i*16);
      }
   }
   return iBios;
}

void _dfPro( USHORT usTop,     // Top
             USHORT usLeft,    // Left
             USHORT usRight,   // Right
             LONG    lEle,     // Elemento attuale sul
             LONG    lTot,     // totale
             BYTEP  bpColor )  // Colore di visualizzazione
{
   BYTEP  fpVideo;
   USHORT uiBuffSize;
   USHORT uiBuffPos;
   ULONG  uiChar;
   char   cCol;

   if(_dfRectSize( usTop, usLeft, usTop, usRight, &uiBuffSize )==0){
      fpVideo = (BYTEP) _xgrab(uiBuffSize);    // Salvo lo screen

      _gtSave( usTop, usLeft, usTop, usRight, fpVideo );

      cCol=_dfCol2Num( (char*)bpColor );
      if( lTot==0 ) lTot=1;

      uiChar=(usRight-usLeft+1)*lEle/lTot;
      uiBuffPos=0;
      while( uiBuffPos<uiBuffSize){
         if(uiChar>0){
            fpVideo[uiBuffPos++]='Û';
            uiChar--;
         }else fpVideo[uiBuffPos++]='±';
         fpVideo[uiBuffPos++]=cCol;
      }

      _gtRest( usTop, usLeft, usTop, usRight, fpVideo );
      _xfree( fpVideo );
   }
}

HB_FUNC( DFPRO ){
   _dfPro( (USHORT) _parni(1),  // Top
           (USHORT) _parni(2),  // Left
           (USHORT) _parni(3),  // Right
           (LONG)   _parnl(4),  // Elemento attuale sul
           (LONG)   _parnl(5),  // totale
           (BYTEP)   _parc(6)); // Colore di visualizzazione
}

void _dfSayBox( USHORT usTop,     // Top
                USHORT usLeft,    // Left
                USHORT usBottom,  // Bottom
                USHORT usRight,   // Right
                BYTEP bpColorTL,  // Color TopLeft
                BYTEP bpColorBR,  // Color BottomRight
                BYTEP bpColorF ){ // Color FILL

   BYTE bpColorSaved[CLR_STRLEN];      // Color saved
   int nLoop, nColumn, nLine;

   _gtGetColorStr( (char*)bpColorSaved );               // save color
   _gtSetColorStr( (char*)bpColorTL );                  // set color TopLeft

   nLine=usBottom -usTop -1;
   nColumn=usRight-usLeft-1;

   if(usBottom==usTop){
      _gtRepChar( usTop, usLeft, 'Ä', nColumn+2 );
   }else if(usRight==usLeft) {
      nLoop=nLine+1;
      while( nLoop>=0 ){
         _gtWriteAt( usTop+nLoop, usLeft, (unsigned char*)"³", 1 );
         nLoop--;
      }
   }else{
      _gtWriteAt( usTop, usLeft, (unsigned char*)"Ú", 1 );          // Top/Left
      nLoop=nLine;
      while( nLoop>0 ){
         _gtWriteAt( usTop+nLoop, usLeft, (unsigned char*)"³", 1 );
         nLoop--;
      }
      _gtWriteAt( usBottom, usLeft, (unsigned char*)"À", 1 );
      _gtRepChar( usTop, usLeft+1, 'Ä', nColumn );

      _gtSetColorStr( (char*)bpColorBR );                  // set color BottomRight
      _gtWriteAt( usTop, usRight, (unsigned char*)"¿", 1 );         // Bottom/Right
      nLoop=nLine;
      while( nLoop>0 ){
         _gtWriteAt( usTop+nLoop, usRight, (unsigned char*)"³", 1 );
         nLoop--;
      }
      _gtWriteAt( usBottom, usRight, (unsigned char*)"Ù", 1 );
      _gtRepChar( usBottom, usLeft+1, 'Ä', nColumn );

      if(bpColorF!=NULL){
         _gtSetColorStr( (char*)bpColorF );                // set color BottomRight
         _gtBox( usTop+1, usLeft+1, usBottom-1, usRight-1, (unsigned char*)"         " );
      }
   }

   _gtSetColorStr( (char*)bpColorSaved );               // restore color
}

HB_FUNC( DFSAYBOX ){
   _dfSayBox( (USHORT) _parni(1), // Top
              (USHORT) _parni(2), // Left
              (USHORT) _parni(3), // Bottom
              (USHORT) _parni(4), // Right
              (BYTEP) _parc(5),   // Color TopLeft
              (BYTEP) _parc(6),   // Color BottomRight
              (BYTEP) _parc(7) ); // Color FILL
}

void _dfShade( SHORT Sfr,
               SHORT Sfc,
               SHORT Slr,
               SHORT Slc,
               unsigned char Col )
{
   BYTEP  fpVideo;
   USHORT uiBuffSize;
   USHORT uiBuffPos;
   SHORT  SNewlr;

   Sfr++;  Sfr=max(Sfr,0);
   Sfc+=2; Sfc=max(Sfc,0);
   Slr++;  SNewlr=Slr;
   Slr=min((USHORT)Slr,_gtMaxRow());

   if(_dfRectSize( Sfr, Slc+1, Slr, Slc+2, &uiBuffSize )==0){
      fpVideo = (BYTEP) _xgrab(uiBuffSize);    // Salvo lo screen Lato

      _gtSave( Sfr, Slc+1, Slr, Slc+2, (char*)fpVideo );

      uiBuffPos=1;
      while( uiBuffPos<uiBuffSize){
         fpVideo[uiBuffPos]=Col;
         uiBuffPos += 2;
      }

      _gtRest( Sfr, Slc+1, Slr, Slc+2, (char*)fpVideo );
      _xfree( fpVideo );
   }

   if(_dfRectSize( Slr, Sfc, Slr, Slc, &uiBuffSize )==0 && (USHORT)SNewlr<=_gtMaxRow()){
      fpVideo = (BYTEP) _xgrab(uiBuffSize);    // Salvo lo screen Fondo

      _gtSave( Slr, Sfc, Slr, Slc, (char*)fpVideo );

      uiBuffPos=1;
      while( uiBuffPos<uiBuffSize){
         fpVideo[uiBuffPos]=Col;
         uiBuffPos += 2;
      }

      _gtRest( Slr, Sfc, Slr, Slc, (char*)fpVideo );
      _xfree( fpVideo );
   }
}

HB_FUNC( DFSHADE ){
   if( PCOUNT > 3 )
      _dfShade( (SHORT) _parni(1),
                (SHORT) _parni(2),
                (SHORT) _parni(3),
                (SHORT) _parni(4),
                (unsigned char) ( PCOUNT < 5 ? 8 : _parni( 5 ) ) );
}

void dfCharGeneric( int iStart ){
   int punstr;                 /* puntatore stringa */
   int punret;                 /* puntatore stringa di ritorno */
   int lenstr;                 /* lunghezza stringa */

   char *strret;               /* lunghezza di ritorno */
   char *str;                  /* stringa di lavoro    */

   str = _parc(1);             /* assegno al puntatore la variabile clipper */

   punstr = iStart;            /* abblenko i puntatori */
   punret = 0;
   lenstr = _parclen(1);       /* prendo la lunghezza della variabile */

   strret = (char *) _xgrab( lenstr+1 ); /* alloco la memoria */

   while(punstr<lenstr){  /* finche' puntatore a stringa minore della lunghezza */
     strret[punret]=str[punstr];     /* seguo carattere per carattere la */
     punstr +=2;                     /* stringa e copio i dispari in quella */
     punret ++;                      /* destinazione */
   }

   strret[punret]='\0';            /* fine della stringa */
   _retc(strret);                  /* restituisco la stringa */
   _xfree(strret);                 /* disalloco la memoria */
}

HB_FUNC( DFCHAREVEN ){
   dfCharGeneric( 1 );
}

HB_FUNC( DFCHARODD ){
   dfCharGeneric( 0 );
}


HB_FUNC( DFCOL2NUM ){
   _retni( _dfCol2Num(_parc(1)));
}

HB_FUNC( DFTOKEN ){
   register short  TokNum;
   register char   Delim;
   register char   TypTok;

   char          * String;

   if( PCOUNT != 3 ) {
           return;
   }

   String = _parc( 1 );
   Delim  = _parc( 2 )[0];
   TokNum = _parni( 3 ) - 1;

   TypTok = (char) ( _parclen( 2 ) == 1 ? 0 : 1 );

   while( TokNum && * String )                  /* cerca il token */
           {
           if( *( String ++ ) == Delim )
                   {
                   TokNum --;

                   if( TypTok ) {
                      while( * String == Delim && * String ) String ++;
                   }
           }
   }

   TokNum = 0;

   while( String[TokNum] != Delim &&            /* cerca fine token */
                    String[TokNum] )
           TokNum ++;

   _retclen( String, TokNum );
   return;
}

HB_FUNC( DFXORPATTERN ){
   char *pOldBuf;
   int nPos;
   char cXor;

   if( PCOUNT==2 ){
      pOldBuf = _parc(1);
      nPos    = _parclen(1);
      cXor    = _parc(2)[0];

      while( nPos>=0 ){
         pOldBuf[nPos] = pOldBuf[nPos]^cXor;
         nPos--;
      }
   } else
      _retc("");
}

#define BUFFERLEN  4096
/*
BUFFERLEN era inizialmente 16384, ma facendo dei benchmark con un PCX di 2Mb
i tempi di decodifica sono stati:
- 6.80ñ0.10 secondi con BUFFERLEN >=32768
- 6.90ñ0.10 secondi con BUFFERLEN = 16384
- 7.20ñ0.10 secondi con BUFFERLEN = 4096   <- Miglior rapporto Kb/Sec
- 8.30ñ0.10 secondi con BUFFERLEN = 1024
quindi un'occupazione > 4k non vale un granche'...

*/
char PCXBUFF[ BUFFERLEN ];
unsigned int PCX_BUFPTR = 1;
unsigned int PCX_BUFLEN = 0;

unsigned char Get_byte( int hInFile )
{
    unsigned char ret;

    if ( PCX_BUFPTR >= PCX_BUFLEN )
    {

     PCX_BUFPTR = 0;
     PCX_BUFLEN = _fsRead( hInFile ,(char *)&PCXBUFF, BUFFERLEN );

    }
    ret = PCXBUFF[ PCX_BUFPTR ];
    PCX_BUFPTR++;
    return ret;

}

HB_FUNC( DECODEPCX ){
        int  Width, Count, hInFile, BPL, Height;
        int  Retval = 0;
        long FilePtr = 128; // Š da qui che incomincio a leggere
        unsigned char Data;

        if ( _parinfo(0) == 3 ) {

           hInFile = _parni(1);
           BPL     = _parni(2);
           Height  = _parni(3);
           Retval  = 1;
           Width = BPL;
           PCX_BUFPTR = 1;
           PCX_BUFLEN = 0;
           while(Height)
            {
                Count = 1;
                /*  L-E-E-E-E-N-T-O !!!!!
                if ( _fsRead( hInFile , (char *)&Data, 1 ) != 1 )
                {
                    Retval = 0;
                    break;
                }
                */
                Data = Get_byte( hInFile );
                if ( PCX_BUFLEN == 0 )
                {
                    Retval = 0;
                    break;
                }
                FilePtr++;
                if ((Data & 0xc0) == 0xc0)
                {
                   Count = Data & 0x3f;
                   Data = Get_byte( hInFile );
                   if ( PCX_BUFLEN == 0 )
                   {
                       Retval = 0;
                       break;
                   }
                   FilePtr++;

                }

                while(Count)
                {
                    Count--;
                    Width--;

                    if(Width == 0)
                     {
                       Height--;
                       Width = BPL;
                     }
                }
           }

           _fsSeek( hInFile, FilePtr , 0 );
        }
        _retl(Retval);
}

HB_FUNC( F_COYOTE ){
   char cAppo[4];
   char *pOldBuf;
   int nLen,nPos;

   if( PCOUNT==1 ){
      pOldBuf = _parc(1);
      nLen    = _parclen(1);
      nPos    = 0;

      while( nPos+4<=nLen ){
         cAppo[0]        = pOldBuf[nPos  ];
         cAppo[1]        = pOldBuf[nPos+1];
         cAppo[2]        = pOldBuf[nPos+2];
         cAppo[3]        = pOldBuf[nPos+3];
         pOldBuf[nPos  ] = cAppo[3];
         pOldBuf[nPos+1] = cAppo[2];
         pOldBuf[nPos+2] = cAppo[1];
         pOldBuf[nPos+3] = cAppo[0];
         nPos += 4;
      }
   }
}

/*****************************************************************************/
void de_vfs(int counter, char *buffer)
/*****************************************************************************/
{
    int i;
    char *p;
    p=buffer;
    while(counter>0)
    {
        for(i=0 ; i < 0x0E ; i++)
        {
            *p++ ^= 0x56 ;
        }
        for(i=0 ; i < 0x0D ; i++)
        {
            *p++ ^= 0x9D ;
        }
        --counter;
    }
    return ;
}

/*****************************************************************************/
void de_xlink(char *buffer,int buflen)
/*****************************************************************************/
{
    int i;
    char *p;
    p=buffer;
    for(i=0 ; i < buflen ; i++)
    {
        *p++ -= (i & 0xff) ;
    }
    return ;
}

HB_FUNC( DE_XLINK ){
   de_xlink( _parc(1), _parclen(1) );
}

HB_FUNC( DE_VFS ){
   de_vfs( _parni(1), _parc(2) );
}

#pragma ENDDUMP
