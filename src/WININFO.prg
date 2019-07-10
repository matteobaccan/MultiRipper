/******************************************************************************
Project     : TWT
Description : Windows resource decompiler
Programmer  : Baccan Matteo
******************************************************************************/

#include "mRipper.ch"

STATIC aStaticone
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION F_ResDecomp( cExe, nRes, aParent )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandleIn, nHandleOut, cBuf, nResOff, nExeTyp
LOCAL nResType
LOCAL cName := SUBSTR( cExe, 1, AT(".",cExe)-1 )
LOCAL lRet  := .F., nExeHeader
LOCAL nResSiz, nExeType, cFile, nPas

DEFAULT nRes TO "0"
nRes := VAL(nRes)

aStaticone := aParent

nExeType  := dfExeType( cExe )
cFile     := EXTPATH +dfFindName( cExe ) +".rc"
STRINGPOS := 0

IF F_IsExeWin( cExe )
   F_Status()

   // Prepare delphi project
   ASIZE( DELPHISOURCE, 0 )

   // Open database and create .RC information
   nHandleIn  := F_FOPEN( cExe, FO_SHARED )
   nHandleOut := FCREATE( cFile )
   F_Header( nHandleOut )


   // Seek to the start of NEW Executable Header
   FSEEK( nHandleIn, dfHex2Dec("3C") )
   cBuf := SPACE(4)
   FREAD( nHandleIn, @cBuf, 4 )
   nExeHeader := BIN2L(cBuf)


   // Header Information
   F_ExeInfo( nHandleIn, nExeHeader, nHandleOut, cExe )

   // Resource Position
   IF nExeType==EXE_TYPE_NE
      FSEEK( nHandleIn, nExeHeader+dfHex2Dec("24") )
      cBuf := SPACE(2)
      FREAD( nHandleIn, @cBuf, 2 )
      nResOff := nExeHeader +BIN2W(cBuf)
   ENDIF

   IF nExeType==EXE_TYPE_LE .OR. ;
      nExeType==EXE_TYPE_LX
      FSEEK( nHandleIn, nExeHeader+dfHex2Dec("50") )
      cBuf := SPACE(4)
      FREAD( nHandleIn, @cBuf, 4 )
      nResOff := nExeHeader +BIN2L(cBuf)
   ENDIF

   IF nExeType==EXE_TYPE_PE
      FSEEK( nHandleIn, nExeHeader )
      cBuf := SPACE(1024)
      FREAD( nHandleIn, @cBuf, 1024 )
      IF (nResOff := AT( ".rsrc", cBuf ))>0
         nResOff := BIN2L( SUBSTR( cBuf, nResOff+20, 4 ) )
      ELSE
         nResOff := nExeHeader
      ENDIF
   ENDIF

   FWRITE( nHandleOut, CRLF +"Resource Definition" +CRLF )
   FWRITE( nHandleOut,       "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" +CRLF +CRLF )
   IF nResOff==nExeHeader
      FWRITE( nHandleOut, "   þ No Resource Available" +CRLF )
   ELSE
      FWRITE( nHandleOut, "   þ Resource Found at : " +dfLong2Hex( nResOff ) +CRLF +CRLF )
      DO CASE
         CASE nExeType==EXE_TYPE_PE
              lRet := F_ExePE( nHandleIn, nRes, nHandleOut, nResOff, 0, 0, 0 )

         CASE nExeType==EXE_TYPE_NE .OR.;
              nExeType==EXE_TYPE_LE
              lRet := F_ExeNE( nHandleIn, nRes, nHandleOut, nResOff )

      ENDCASE
   ENDIF

   FWRITE( nHandleOut, CRLF +"End of DUMP" )
   FCLOSE( nHandleOut )

   // Delphi project
   IF LEN(DELPHISOURCE) > 0
      cExe := F_ExtName( "DPR" )
      nHandleOut := FCREATE( cExe )
      IF nHandleOut>0
         FWRITE( nHandleOut, "{*****************************************************************************}" +CRLF )
         FWRITE( nHandleOut, "{*      -> Multi Ripper "+padr(RIPVERSION+" <-",8)+"     The Multi-Purpose File Extractor        *}" +CRLF )
         FWRITE( nHandleOut, "{******* To have the last release send an email to " +EMAIL +" *******}" +CRLF )
         FWRITE( nHandleOut, "program " +dfFindName( cExe ) +";" +CRLF )
         FWRITE( nHandleOut, "" +CRLF )
         FWRITE( nHandleOut, "uses" +CRLF )
         FWRITE( nHandleOut, "  Forms," +CRLF )

         FOR nPas := 1 TO LEN( DELPHISOURCE )
            //IF SUBSTR(DELPHISOURCE[nPas][1],1,4)=="DFM0"
               //FWRITE( nHandleOut, "  {"   +DELPHISOURCE[nPas][1] +;
                                   //" in '" +DELPHISOURCE[nPas][2] +;
                                   //"' "    +DELPHISOURCE[nPas][4] +;
                                   //"}" )
            //ELSE
               FWRITE( nHandleOut, "  "    +DELPHISOURCE[nPas][1] +;
                                   " in '" +DELPHISOURCE[nPas][2] +;
                                   "' {"   +DELPHISOURCE[nPas][4] +;
                                   "}" )
            //ENDIF
            IF nPas < LEN( DELPHISOURCE )
               FWRITE( nHandleOut, ","+CRLF )
            ELSE
               FWRITE( nHandleOut, ";"+CRLF )
            ENDIF
         NEXT

         FWRITE( nHandleOut, "" +CRLF )
         FWRITE( nHandleOut, "{$R *.RES}" +CRLF )
         FWRITE( nHandleOut, "" +CRLF )
         FWRITE( nHandleOut, "begin" +CRLF )
         FWRITE( nHandleOut, "  Application.Initialize;" +CRLF )

         FOR nPas := 1 TO LEN( DELPHISOURCE )
            //IF SUBSTR(DELPHISOURCE[nPas][1],1,4)=="DFM0"
               //FWRITE( nHandleOut, "  {*Application.CreateForm(" +DELPHISOURCE[nPas][3] +", " +DELPHISOURCE[nPas][4] +");*}" +CRLF )
            //ELSE
               FWRITE( nHandleOut, "  Application.CreateForm(" +DELPHISOURCE[nPas][3] +", " +DELPHISOURCE[nPas][4] +");" +CRLF )
            //ENDIF
         NEXT

         FWRITE( nHandleOut, "  Application.Run;" +CRLF )
         FWRITE( nHandleOut, "end." +CRLF )
         FCLOSE( nHandleOut )
      ENDIF
   ENDIF
ENDIF

FCLOSE( nHandleIn )

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION F_IsExeWin( cExe )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nType := dfExeType( cExe )
RETURN (nType==EXE_TYPE_NE .OR. ;
        nType==EXE_TYPE_LE .OR. ;
        nType==EXE_TYPE_LX .OR. ;
        nType==EXE_TYPE_W3 .OR. ;
        nType==EXE_TYPE_PE )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_ExeInfo( nHandle, nExeHeader, nHandleOut, cExe )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos := FSEEK( nHandle, 0, FS_RELATIVE )
LOCAL cBuff := SPACE(dfHex2Dec("C6")) // Max size between NE(40) and LE(C6)
LOCAL cSignature, nLen
LOCAL nLinkerHI, nLinkerLO, nFlags, nSeg, nOpe, nWinLO, nWinHI, nCpu

FSEEK( nHandle, nExeHeader )
FREAD( nHandle, @cBuff, dfHex2Dec("40") )

FWRITE( nHandleOut, CRLF )
FWRITE( nHandleOut, "Executable Information"  +CRLF )
FWRITE( nHandleOut, "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"  +CRLF +CRLF )
FWRITE( nHandleOut, "   þ DOS Name                 : " +cExe +CRLF )

nLen := dfFileSize(nHandle)
FWRITE( nHandleOut, "   þ File Size                : " +dfLong2Hex(nLen) +" (" +ALLTRIM(STR(nLen)) +")" +CRLF )

// Use only EXECUTABLE with resource NE/LE/W3/PE
cSignature := SUBSTR( cBuff,  0+1, 2 )
FWRITE( nHandleOut, "   þ Executable Type          : " )
DO CASE
 //MZ     old-style DOS executable (see #0935)
 //NE     Windows or OS/2 1.x segmented ("new") executable (see #0937)
 //LE     Windows virtual device driver (VxD) linear executable (see #0950)
 //LX     variant of LE used in OS/2 2.x (see #0950)
 //W3     Windows WIN386.EXE file; a collection of LE files
 //PE     Win32 (Windows NT and Win32s) portable executable based on Unix COFF
 //DL     HP 100LX/200LX system manager compliant executable (.EXM)
 //MP     old PharLap .EXP (see #0960)
 //P2     PharLap 286 .EXP (see #0961)
 //P3     PharLap 386 .EXP (see #0961)
   CASE cSignature == "NE"; FWRITE( nHandleOut, "WIN16/OS2 Executable" +CRLF )
   CASE cSignature == "LE"; FWRITE( nHandleOut, "Linear Executable"    +CRLF )
   CASE cSignature == "LX"; FWRITE( nHandleOut, "Linear OS2 Executable"+CRLF )
   CASE cSignature == "W3"; FWRITE( nHandleOut, "W3 Executable"        +CRLF )
   CASE cSignature == "PE"; FWRITE( nHandleOut, "Portable Executable"  +CRLF )
ENDCASE

IF cSignature=="NE"
   // Linker Version
   nLinkerHI := ALLTRIM(STR(ASC  (SUBSTR( cBuff,  2+1, 1 ))))
   nLinkerLO := ALLTRIM(STR(ASC  (SUBSTR( cBuff,  3+1, 1 ))))
   FWRITE( nHandleOut, "   þ Linker Version           : " +nLinkerHI +"." +nLinkerLO +CRLF )

   // Program Flags
   nFlags := ASC(SUBSTR( cBuff, dfHex2Dec("0C")+1, 1 ))
   FWRITE( nHandleOut, "   þ Program Flags            : " )
   DO CASE
      CASE dfAnd(nFlags,3)==0; FWRITE( nHandleOut, "DGroup none"          )
      CASE dfAnd(nFlags,3)==1; FWRITE( nHandleOut, "DGroup single shared" )
      CASE dfAnd(nFlags,3)==2; FWRITE( nHandleOut, "DGroup multiple"      )
      CASE dfAnd(nFlags,3)==3; FWRITE( nHandleOut, "DGroup (null)"        )
   ENDCASE
   IF dfAnd(nFlags,  4)==  4; FWRITE( nHandleOut, " - Global initialization" ); ENDIF
   IF dfAnd(nFlags,  8)==  8; FWRITE( nHandleOut, " - Protected mode only"   ); ENDIF
   IF dfAnd(nFlags, 16)== 16; FWRITE( nHandleOut, " - 8086 instructions"     ); ENDIF
   IF dfAnd(nFlags, 32)== 32; FWRITE( nHandleOut, " - 80286 instructions"    ); ENDIF
   IF dfAnd(nFlags, 64)== 64; FWRITE( nHandleOut, " - 80386 instructions"    ); ENDIF
   IF dfAnd(nFlags,128)==128; FWRITE( nHandleOut, " - 80x87 instructions"    ); ENDIF
   FWRITE( nHandleOut, CRLF )

   // Application Flags
   nFlags := ASC(SUBSTR( cBuff, dfHex2Dec("0D")+1, 1 ))
   FWRITE( nHandleOut, "   þ Application Flags        : " )
   DO CASE
      CASE dfAnd(nFlags,3)==1; FWRITE( nHandleOut, "full screen (not aware of Windows/P.M. API)" )
      CASE dfAnd(nFlags,3)==2; FWRITE( nHandleOut, "compatible with Windows/P.M. API"            )
      CASE dfAnd(nFlags,3)==3; FWRITE( nHandleOut, "uses Windows/P.M. API"                       )
   ENDCASE
   IF dfAnd(nFlags,  8)==  8; FWRITE( nHandleOut, " is a Family Application (OS/2)"                          ); ENDIF
   IF dfAnd(nFlags, 32)== 32; FWRITE( nHandleOut, " errors in image"                                         ); ENDIF
   IF dfAnd(nFlags, 64)== 64; FWRITE( nHandleOut, " non-conforming program (valid stack is not maintained) " ); ENDIF
   IF dfAnd(nFlags,128)==128; FWRITE( nHandleOut, " DLL or driver rather than application"                   ); ENDIF
   FWRITE( nHandleOut, CRLF )

   // Segment Count
   nSeg := BIN2W(SUBSTR( cBuff, dfHex2Dec("1C")+1, 2 ))
   FWRITE( nHandleOut, "   þ Segment Count            : " +ALLTRIM(STR(nSeg)) +CRLF )

   // Target Operating System
   nOpe := ASC(SUBSTR( cBuff, dfHex2Dec("36")+1, 1 ))
   FWRITE( nHandleOut, "   þ Target Operating System  : " )
   DO CASE
      CASE nOpe==dfHex2Dec("00"); FWRITE( nHandleOut, "unknown"                                  )
      CASE nOpe==dfHex2Dec("01"); FWRITE( nHandleOut, "OS/2"                                     )
      CASE nOpe==dfHex2Dec("02"); FWRITE( nHandleOut, "Windows"                                  )
      CASE nOpe==dfHex2Dec("03"); FWRITE( nHandleOut, "European MS-DOS 4.x"                      )
      CASE nOpe==dfHex2Dec("04"); FWRITE( nHandleOut, "Windows 386"                              )
      CASE nOpe==dfHex2Dec("05"); FWRITE( nHandleOut, "BOSS (Borland Operating System Services)" )
      CASE nOpe==dfHex2Dec("81"); FWRITE( nHandleOut, "PharLap 286|DOS-Extender, OS/2"           )
      CASE nOpe==dfHex2Dec("82"); FWRITE( nHandleOut, "PharLap 286|DOS-Extender, Windows"        )
   ENDCASE
   FWRITE( nHandleOut, CRLF )

   // Other EXE Flags
   nFlags := ASC(SUBSTR( cBuff, dfHex2Dec("37")+1, 1 ))
   FWRITE( nHandleOut, "   þ Other Program Flags      : " )
   IF dfAnd(nFlags,  1)==  1; FWRITE( nHandleOut, "supports long filenames" ); ENDIF
   IF dfAnd(nFlags,  2)==  2; FWRITE( nHandleOut, "2.X protected mode"      ); ENDIF
   IF dfAnd(nFlags,  4)==  4; FWRITE( nHandleOut, "2.X proportional font"   ); ENDIF
   IF dfAnd(nFlags,  8)==  8; FWRITE( nHandleOut, "gangload area"           ); ENDIF
   FWRITE( nHandleOut, CRLF )

   // Expected Windows Version (Minor Version First)
   nWinLO := ALLTRIM(STR(ASC  (SUBSTR( cBuff,  dfHex2Dec("3E")+1, 1 ))))
   nWinHI := ALLTRIM(STR(ASC  (SUBSTR( cBuff,  dfHex2Dec("3F")+1, 1 ))))
   FWRITE( nHandleOut, "   þ Expected Windows Version : " +nWinHI +"." +nWinLO +CRLF )
ENDIF

IF cSignature$"LELX"
   // Cpu type
   nCpu := BIN2W(SUBSTR( cBuff, dfHex2Dec("08")+1, 2 ))
   FWRITE( nHandleOut, "   þ CPU Type                 : " )
   DO CASE
      CASE nCpu==dfHex2Dec("01"); FWRITE( nHandleOut, "Intel 80286 or upwardly compatible"           )
      CASE nCpu==dfHex2Dec("02"); FWRITE( nHandleOut, "Intel 80386 or upwardly compatible"           )
      CASE nCpu==dfHex2Dec("03"); FWRITE( nHandleOut, "Intel 80486 or upwardly compatible"           )
      CASE nCpu==dfHex2Dec("04"); FWRITE( nHandleOut, "Intel Pentium (80586) or upwardly compatible" )
      CASE nCpu==dfHex2Dec("20"); FWRITE( nHandleOut, "Intel i860 (N10) or compatible"               )
      CASE nCpu==dfHex2Dec("21"); FWRITE( nHandleOut, [Intel "N11" or compatible]                    )
      CASE nCpu==dfHex2Dec("40"); FWRITE( nHandleOut, "MIPS Mark I (R2000, R3000) or compatible"     )
      CASE nCpu==dfHex2Dec("41"); FWRITE( nHandleOut, "MIPS Mark II (R6000) or compatible"           )
      CASE nCpu==dfHex2Dec("42"); FWRITE( nHandleOut, "MIPS Mark III (R4000) or compatible"          )
   ENDCASE
   FWRITE( nHandleOut, CRLF )

   // Target Operating System
   nOpe := ASC(SUBSTR( cBuff, dfHex2Dec("0A")+1, 1 ))
   FWRITE( nHandleOut, "   þ Target Operating System  : " )
   DO CASE
      CASE nOpe==dfHex2Dec("01"); FWRITE( nHandleOut, "OS/2"             )
      CASE nOpe==dfHex2Dec("02"); FWRITE( nHandleOut, "Windows"          )
      CASE nOpe==dfHex2Dec("03"); FWRITE( nHandleOut, "European DOS 4.0" )
      CASE nOpe==dfHex2Dec("04"); FWRITE( nHandleOut, "Windows 386"      )
   ENDCASE
   FWRITE( nHandleOut, CRLF )
ENDIF

IF cSignature=="PE"
   // Cpu type
   nCpu := BIN2W(SUBSTR( cBuff, dfHex2Dec("04")+1, 2 ))
   FWRITE( nHandleOut, "   þ CPU Type                 : " )
   DO CASE
      CASE nCpu==dfHex2Dec("14c"); FWRITE( nHandleOut, "Intel 386"                           +CRLF )
      CASE nCpu==dfHex2Dec("162"); FWRITE( nHandleOut, "MIPS little-endian, 0540 big-endian" +CRLF )
      CASE nCpu==dfHex2Dec("166"); FWRITE( nHandleOut, "MIPS little-endian"                  +CRLF )
      CASE nCpu==dfHex2Dec("184"); FWRITE( nHandleOut, "Alpha_AXP"                           +CRLF )
      CASE nCpu==dfHex2Dec("1F0"); FWRITE( nHandleOut, "IBM PowerPC Little-Endian"           +CRLF )
   ENDCASE
ENDIF

FSEEK( nHandle, nPos, FS_SET )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_ExeNE( nHandle, nRes, nHandleOut, nResOff )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cBuf, nAllign, nResType, temp, nResCnt, nResOfs, nResLen, lRet := .F.

// alignment shift count for resource data
FSEEK( nHandle, nResOff )
cBuf := SPACE(2)
FREAD( nHandle, @cBuf, 2 )
nAllign := INT(2^BIN2W(cBuf))
IF nAllign==0
   nAllign := 512
ENDIF

WHILE .T.
   cBuf := SPACE(8)
   IF FREAD( nHandle, @cBuf, 8 )==0
      EXIT
   ENDIF
   nResType := BIN2W( SUBSTR(cBuf,1,2) )
   IF dfAnd( nResType, dfHex2Dec("8000") )==0
      EXIT
   ENDIF

   //IF nRes==nResType .OR. nRes==0
      //F_ResIni( nResType, nHandleOut )
   //ENDIF

   nResCnt := BIN2W( SUBSTR(cBuf,3,2) )
   WHILE nResType!=0 .AND. nResCnt>0

      cBuf := SPACE(12)
      IF FREAD( nHandle, @cBuf, 12 )!=12
         EXIT
      ENDIF
      nResOfs := BIN2W( SUBSTR(cBuf,1,2) ) *nAllign
      // Da ricontrollare perche' cambia un po' di cose
      nResLen := BIN2W( SUBSTR(cBuf,3,2) ) *nAllign

      IF nRes==nResType .OR. nRes==0
         //F_ResIni( nResType, nHandleOut )
         lRet := .T.
         temp := F_Res2Desc( nResType ) +" " +" AT " +dfLong2Hex( nResOfs )
         RipLogSay( " ... Extracted "+temp )
         F_SubRes( nHandle, nResType, nResOfs, nResLen, nHandleOut )
      ENDIF

      nResCnt--
   ENDDO
ENDDO

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_ExePE( nHandle, nRes, nHandleOut, nResOff, nResAdd, nLevel, nResType, aRes )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC nLastRes

//LOCAL MajorVersion
//LOCAL MinorVersion
LOCAL nPos := FSEEK( nHandle, 0, FS_RELATIVE )
LOCAL cBuf, cBuffRes
LOCAL Characteristics
LOCAL TimeDateStamp
LOCAL NumberOfNamedEntries
LOCAL NumberOfIdEntries
LOCAL nIdEntries, nNameEntries
//LOCAL cString
LOCAL lRet := .F.

DEFAULT nLevel   TO 0
DEFAULT nResType TO 0
DEFAULT aRes     TO {}

if nLevel>3 .OR. len(aRes)>=1024
   return .f.
endif

F_StepWait()

FSEEK( nHandle, nResOff+nResAdd )
cBuffRes := SPACE( 16 )
IF FREAD( nHandle, @cBuffRes, 16 )==16
   Characteristics      := BIN2L( SUBSTR( cBuffRes, 1, 4 ) )
   TimeDateStamp        := BIN2L( SUBSTR( cBuffRes, 5, 4 ) )
   //MajorVersion         := BIN2W( SUBSTR( cBuffRes, 9, 2 ) )
   //MinorVersion         := BIN2W( SUBSTR( cBuffRes,11, 2 ) )
   NumberOfNamedEntries := BIN2W( SUBSTR( cBuffRes,13, 2 ) )
   NumberOfIdEntries    := BIN2W( SUBSTR( cBuffRes,15, 2 ) )
   IF NumberOfIdEntries>=32768
      NumberOfIdEntries := 0
   ENDIF
   IF NumberOfNamedEntries>=32768
      NumberOfNamedEntries := 0
   ENDIF

   //cString := SPACE(nLevel*4)
//f_saymsg( str(nLevel)+"-"+str(len(ares))+"-"+str(NumberOfIdEntries)+"-"+str(nResOff+nResAdd), "GR+/B" )
//inkey(0.1)
   IF nLevel==1
      nLastRes := nResType
   ENDIF

   IF nLevel==3
      AADD( aRes, { nLastRes, Characteristics, TimeDateStamp } )
   ENDIF

   FOR nNameEntries := 1 TO NumberOfNamedEntries
      cBuffRes := SPACE( 8 )
      IF FREAD( nHandle, @cBuffRes, 8 )==8
         nResAdd  := BIN2W( SUBSTR( cBuffRes, 5, 2 ) )
         nResType := BIN2L( SUBSTR( cBuffRes, 1, 4 ) )
         F_ExePE( nHandle, nRes, nHandleOut, nResOff, nResAdd, nLevel+1, nResType, aRes )
      ENDIF
   NEXT

   FOR nIdEntries := 1 TO NumberOfIdEntries
      cBuffRes := SPACE( 8 )
      IF FREAD( nHandle, @cBuffRes, 8 )==8
         nResAdd  := BIN2W( SUBSTR( cBuffRes, 5, 2 ) )
         nResType := BIN2L( SUBSTR( cBuffRes, 1, 4 ) )
         F_ExePE( nHandle, nRes, nHandleOut, nResOff, nResAdd, nLevel+1, nResType, aRes )
      ENDIF
   NEXT
ENDIF
IF nLevel==0
   lRet := F_ResPE( aRes, nHandle, nHandleOut, nResOff )
ENDIF

FSEEK( nHandle, nPos )

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_ResPE( aRes, nHandle, nHandleOut, nResOff )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nVer  := ASCAN( aRes, {|aSub|aSub[1]==PE_VERSION} )
LOCAL nPos
LOCAL nPatternLen
LOCAL nError := 0
LOCAL temp
LOCAL cBuff := SPACE(10)
LOCAL nRes
LOCAL lDump := .T., nSize
LOCAL lRet := .F.

// Version Pattern
LOCAL cPatternV := CHR(dfHex2Dec("56")) +CHR(0) +;
                   CHR(dfHex2Dec("53")) +CHR(0) +;
                   CHR(dfHex2Dec("5F")) +CHR(0) +;
                   CHR(dfHex2Dec("56")) +CHR(0) +;
                   CHR(dfHex2Dec("45"))

// Icon Pattern
LOCAL cPatternI := "(" +CHR(0) +CHR(0) +CHR(0) +" " +CHR(0) +CHR(0) +CHR(0)

// Cursor Pattern
LOCAL cPatternC := "(" +CHR(0) +CHR(0) +CHR(0) +;
                   " " +CHR(0) +CHR(0) +CHR(0) +;
                   "@" +CHR(0) +CHR(0) +CHR(0) +CHR(1) +CHR(0) +CHR(1)

// Bitmap Pattern
LOCAL cPatternB := CHR(0) +CHR(0) +CHR(0) +CHR(0) +"(" +CHR(0) +CHR(0) +CHR(0)

IF LEN(aRes)>0
   // Determino la posizione della versione e da quella risalgo
   // alla correzione da dover effettuare
   FSEEK( nHandle, nResOff )
   IF nVer!=0
      f_saystatus("Search for version ...")
      nError := dfPatternPos( nHandle, cPatternV )
   ENDIF
   IF nError==0 .OR. nVer==0
      lDump := .F.
   ELSE
      nError := -( aRes[nVer][2] -nError +6 )
   ENDIF
ENDIF

IF !lDump
   IF LEN(aRes)>0
      // Determino la posizione di un bitmap o di un icona, e da quella risalgo
      // alla correzione da dover effettuare
      DO CASE
         CASE (f_saystatus("Search for Icon ..."),.T.) .AND.;
              F_FindRes( nHandle, cPatternI, aRes, PE_ICON, @nError, @nVer, 0, nResOff )
              lDump := .T.
              FWRITE( nHandleOut, "   Icon dump Method" +CRLF +CRLF )

         CASE (f_saystatus("Search for Cursor ..."),.T.) .AND.;
              F_FindRes( nHandle, cPatternC, aRes, PE_CURSOR, @nError, @nVer, -4, nResOff )
              lDump := .T.
              FWRITE( nHandleOut, "   Cursor dump Method" +CRLF +CRLF )

         CASE (f_saystatus("Search for bitmap ..."),.T.) .AND.;
              F_FindRes( nHandle, cPatternB, aRes, PE_BITMAP, @nError, @nVer, 4, nResOff )
              lDump := .T.
              FWRITE( nHandleOut, "   Bitmap dump Method" +CRLF +CRLF )
      ENDCASE
   ENDIF
ELSE
   FWRITE( nHandleOut, "   Version dump Method" +CRLF +CRLF )
ENDIF

IF lDump
   f_saystatus("Found Resources")
   AEVAL( aRes, {|aSub|aSub[2]:=aSub[2]+nError} )
   nSize := dfFileSize( nHandle )
   lRet := .T.
   FOR nPos := 1 TO LEN(aRes)
      temp := F_Res2DePE( aRes[nPos][1] ) +" " +" AT " +dfLong2Hex( aRes[nPos][2] )
      IF aRes[nPos][2] > nSize
         RipLogSay( " ... Resource " +temp +" out of EXE ! " )
      ELSE
         F_SubResPE( nHandle, aRes[nPos][1], aRes[nPos][2], aRes[nPos][3], nHandleOut )
         RipLogSay( " ... Extracted "+temp )
      ENDIF
      gauge(nPos,LEN(aRes))
   NEXT
ELSE
   FOR nRes := 1 TO LEN(aRes)
      IF aRes[nRes][1]==PE_BITMAP        .OR.;
         aRes[nRes][1]==PE_ICON          .OR.;
         aRes[nRes][1]==PE_VERSION
         lDump := .T.
      ENDIF
   NEXT

   IF lDump
      FWRITE( nHandleOut, "   Found ABNORMAL executable !!! " +CRLF +;
                          "   Send it to TWT (" +EMAIL +") for more details" +CRLF )
   ELSE
      FWRITE( nHandleOut, "   No graphics resources" +CRLF )
   ENDIF
ENDIF

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_FindRes( nHandle, cPattern, aRes, nResType, nError, nVer, nDif, nResOff )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, lDump := .F.

FOR nPos := 1 TO LEN(aRes)
   IF aRes[nPos][1]==nResType
      FSEEK( nHandle, nResOff )
      nError := dfPatternPos( nHandle, cPattern ) +nDif
      nError := aRes[nPos][2]-nError
      lDump  := INT(nError/256)*256==nError
      nError := -nError
      nVer   := nPos
      EXIT
   ENDIF
NEXT

RETURN lDump

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_Header( nHandleOut )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF nHandleOut>0
   FWRITE( nHandleOut, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" +CRLF )
   FWRITE( nHandleOut, "³ ²±°          Multi Ripper Windows Resource Decompiler " +PADR(RIPVERSION,8)+"        °±² ³" +CRLF )
   FWRITE( nHandleOut, "³ ²±°                  (C) 2000 by The Wonderful Team                   °±² ³" +CRLF )
   FWRITE( nHandleOut, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ" +CRLF )
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_SubResPE( nHandle, nResType, nResOfs, nResLen, nHandleOut )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos := FSEEK( nHandle, 0, FS_RELATIVE ), cBuff, nChr
LOCAL cBuf := SPACE(80)

FWRITE( nHandleOut, "   þ Resource : " +ALLTRIM(F_Res2DePE( nResType )) +CRLF )

FSEEK( nHandle, nResOfs, FS_SET )
DO CASE
   CASE nResType == PE_RES_0
   CASE nResType == PE_CURSOR      ; F_RT_CURSOR      ( nHandle, nHandleOut, nResOfs, nResLen )
   CASE nResType == PE_BITMAP      ; F_RT_BITMAP      ( nHandle, nHandleOut, nResOfs, nResLen )
   CASE nResType == PE_ICON        ; F_RT_ICON        ( nHandle, nHandleOut, nResOfs, nResLen )
   CASE nResType == PE_MENU        ; F_RT_MENU        ( nHandle, nHandleOut, nResOfs, nResLen, .T. )
   CASE nResType == PE_DIALOG
   CASE nResType == PE_STRING      ; F_RT_STRING      ( nHandle, nHandleOut, nResOfs, nResLen, .T. )
   CASE nResType == PE_FONTDIR
   CASE nResType == PE_FONT
   CASE nResType == PE_ACCELERATORS; F_RT_ACCELERATOR ( nHandle, nHandleOut, nResOfs, nResLen, .T. )
   CASE nResType == PE_RCDATA      ; F_RT_GENERIC     ( nHandle, nHandleOut, nResOfs, nResLen )
   CASE nResType == PE_MESSAGETABLE
   CASE nResType == PE_GROUP_CURSOR
   CASE nResType == PE_RES_13
   CASE nResType == PE_GROUP_ICON
   CASE nResType == PE_RES_15
   CASE nResType == PE_VERSION     ; F_RT_VERSION     ( nHandle, nHandleOut, nResOfs, nResLen )
   OTHERWISE                       ; F_RT_GENERIC     ( nHandle, nHandleOut, nResOfs, nResLen )
ENDCASE

FSEEK( nHandle, nPos, FS_SET )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_SubRes( nHandle, nResType, nResOfs, nResLen, nHandleOut )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos := FSEEK( nHandle, 0, FS_RELATIVE ), cBuff:= SPACE(80), nChr

FWRITE( nHandleOut, "   þ Resource : " +ALLTRIM(F_Res2Desc( nResType )) +CRLF )

FSEEK( nHandle, nResOfs, FS_SET )
DO CASE
   CASE nResType == RT_CURSOR      ; F_RT_CURSOR      ( nHandle, nHandleOut, nResOfs, nResLen )
   CASE nResType == RT_BITMAP      ; F_RT_BITMAP      ( nHandle, nHandleOut, nResOfs, nResLen )
   CASE nResType == RT_ICON        ; F_RT_ICON        ( nHandle, nHandleOut, nResOfs, nResLen )
   CASE nResType == RT_MENU        ; F_RT_MENU        ( nHandle, nHandleOut, nResOfs, nResLen, .F. )
   CASE nResType == RT_DIALOG
   CASE nResType == RT_STRING      ; F_RT_STRING      ( nHandle, nHandleOut, nResOfs, nResLen, .F. )
   CASE nResType == RT_FONTDIR
   CASE nResType == RT_FONT
   CASE nResType == RT_ACCELERATOR ; F_RT_ACCELERATOR ( nHandle, nHandleOut, nResOfs, nResLen, .F. )
   CASE nResType == RT_RCDATA      ; F_RT_GENERIC     ( nHandle, nHandleOut, nResOfs, nResLen )
   CASE nResType == RT_MESSAGETABLE; F_RT_GENERIC     ( nHandle, nHandleOut, nResOfs, nResLen ) // NEW
   CASE nResType == RT_GROUP_CURSOR
   CASE nResType == RT_GROUP_ICON
   CASE nResType == NAMETABLE
   CASE nResType == RT_VERSION     ; F_RT_VERSION     ( nHandle, nHandleOut, nResOfs, nResLen )
   CASE nResType == RT_DLGINCLUDE  ; F_RT_GENERIC     ( nHandle, nHandleOut, nResOfs, nResLen ) // NEW
   CASE nResType == RT_PLUGPLAY    ; F_RT_GENERIC     ( nHandle, nHandleOut, nResOfs, nResLen ) // NEW
   CASE nResType == RT_VXD         ; F_RT_GENERIC     ( nHandle, nHandleOut, nResOfs, nResLen ) // NEW
   CASE nResType == RT_ANICURSOR   ; F_RT_GENERIC     ( nHandle, nHandleOut, nResOfs, nResLen ) // NEW
   CASE nResType == RT_ANIICON     ; F_RT_GENERIC     ( nHandle, nHandleOut, nResOfs, nResLen ) // NEW
   OTHERWISE                       ; F_RT_GENERIC     ( nHandle, nHandleOut, nResOfs, nResLen )
ENDCASE

FSEEK( nHandle, nPos, FS_SET )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_RT_CURSOR( nHandle, nHandleOut, nResOfs, nResLen )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cBuff, cCur, cCurBuff, nNewHandle

IF ASCAN( ARESOURCE, {|cSub|cSub=="CUR"} )==0
   #ifdef DEBUG
      FWRITE( nHandleOut, "Offset : (" +dfLong2Hex(nResOfs) +") Len " +dfLong2Hex(nResLen) +CRLF )
   #endif

   cBuff := SPACE(308)
   FREAD( nHandle, @cBuff, 308 )

   cCurBuff := CHR(0) +CHR(0) +CHR(2) +CHR(0) +CHR(1) +CHR(0) +"  " +CHR(2) +CHR(0)
   cCurBuff += LEFT(cBuff,4)
   cCurBuff += "0" +CHR(1) +CHR(0) +CHR(0) +CHR(22) +CHR(0) +CHR(0) +CHR(0)
   cCurBuff += SUBSTR( cBuff, 5 )

   cCur := F_ExtName( "cur" )
   IF !EMPTY(cCur)
      nNewHandle := FCREATE( cCur )
      FWRITE( nNewHandle, cCurBuff )
      FCLOSE( nNewHandle )
      LOCCOUNTER++
      TOTCOUNTER++
      FWRITE( nHandleOut, "                Ripped Cursor : " +cCur +CRLF )
   ENDIF
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_RT_BITMAP( nHandle, nHandleOut, nResOfs, nResLen )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cBuff, cBitmap, nPaletteSize, nBit, nCol, nRow, nPlanes, nHeadLen
LOCAL t1, cBmp, nNewHandle, cNewPal, nPal, nBitmapSize, nRead, nAct, nColor
LOCAL nPalSize

IF ASCAN( ARESOURCE, {|cSub|cSub=="BMP"} )==0
   #ifdef DEBUG
      FWRITE( nHandleOut, "Offset : (" +dfLong2Hex(nResOfs) +") Len " +dfLong2Hex(nResLen) +CRLF )
   #endif

   cBuff:="    "
   FSEEK( nHandle, nResOfs +dfHex2Dec("000E") -14, 0 )
   FREAD( nHandle, @cBuff, 4 )
   nHeadLen := BIN2L( cBuff )

   IF nHeadLen==12 // OS/2 2.1
      cBuff:="  "
      FSEEK( nHandle, nResOfs +dfHex2Dec("0012") -14, 0 )
      FREAD( nHandle, @cBuff, 2 )
      nCol := BIN2I( cBuff )

      FSEEK( nHandle, nResOfs +dfHex2Dec("0014") -14, 0 )
      FREAD( nHandle, @cBuff, 2 )
      nRow := BIN2I( cBuff )

      FSEEK( nHandle, nResOfs +dfHex2Dec("0016") -14, 0 )
      FREAD( nHandle, @cBuff, 2 )
      nPlanes := BIN2I( cBuff )

      FSEEK( nHandle, nResOfs +dfHex2Dec("0018") -14, 0 )
      FREAD( nHandle, @cBuff, 2 )
      nBit := BIN2I( cBuff )

      nColor   := 0
      nPalSize := 3
   ELSE
      cBuff:="    "
      FSEEK( nHandle, nResOfs +dfHex2Dec("0012") -14, 0 )
      FREAD( nHandle, @cBuff, 4 )
      nCol := BIN2L( cBuff )

      FSEEK( nHandle, nResOfs +dfHex2Dec("0016") -14, 0 )
      FREAD( nHandle, @cBuff, 4 )
      nRow := BIN2L( cBuff )

      cBuff:="  "
      FSEEK( nHandle, nResOfs +dfHex2Dec("001A") -14, 0 )
      FREAD( nHandle, @cBuff, 2 )
      nPlanes := BIN2I( cBuff )

      cBuff:="  "
      FSEEK( nHandle, nResOfs +dfHex2Dec("001C") -14, 0 )
      FREAD( nHandle, @cBuff, 2 )
      nBit := BIN2I( cBuff )

      cBuff:="    "
      FSEEK( nHandle, nResOfs +dfHex2Dec("002E") -14, 0 )
      FREAD( nHandle, @cBuff, 4 )
      nColor := BIN2L( cBuff )

      nPalSize := 4
   ENDIF

   IF nColor<=0
      nColor := INT(2^nBit)
   ENDIF

   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   // Sempre giusto tranne che per le RLE bitmap                              //³
   nPaletteSize := nColor*nPalSize +nHeadLen +14                              //³
   IF nBit==24 // La palette e' troppo grossa e NON viene messa nel bitmap    //³
      nPaletteSize := nHeadLen +14 // 14 + Grandezza Header                   //³
   ENDIF                                                                      //³
   t1 := nRow * INT(((nPlanes*nBit*nCol)+31)/32) *4 +nPaletteSize             //³
   // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   cBitmap := "BM" +CHR(0)+CHR(0)+CHR(0)+CHR(0) +CHR(0)+CHR(0)+CHR(0)+CHR(0)
   // C'e' stato un caso in cui andava in errore: winrep.exe di Win 98
   IF nPaletteSize<1000000 // Controllo molto arbritrario
   cBitmap += L2BIN(nPaletteSize)

   nBitmapSize := t1-14

   cBmp := F_ExtName( "BMP" )
   IF !EMPTY(cBmp)
      F_DUMP_FILE( cBmp, nHandle, nResOfs, cBitmap, nBitmapSize )
      FWRITE( nHandleOut, "                Ripped Bitmap : " +cBmp +CRLF )
   ENDIF
   ENDIF
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_RT_VERSION( nHandle, nHandleOut, nResOfs, nResLen )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cBuff

#ifdef DEBUG
cBuff := SPACE(20)
FREAD( nHandle, @cBuff, 20 )
//F_WriteWord( nHandleOut, "Unknown          : ", cBuff )

cBuff := SPACE(4)
FREAD( nHandle, @cBuff,  4 )
//F_WriteWord( nHandleOut, "Signature        : ", cBuff )

FREAD( nHandle, @cBuff,  4 )
//F_WriteVer ( nHandleOut, "FileVersionMS    : ", cBuff )

cBuff := SPACE(8)
FREAD( nHandle, @cBuff,  8 )
FWRITE( nHandleOut, CRLF )
FWRITE( nHandleOut, "FILEVERSION " +ALLTRIM(STR(BIN2W(SUBSTR(cBuff,3,2)))) )
FWRITE( nHandleOut, ", "           +ALLTRIM(STR(BIN2W(SUBSTR(cBuff,1,2)))) )
FWRITE( nHandleOut, ", "           +ALLTRIM(STR(BIN2W(SUBSTR(cBuff,7,2)))) )
FWRITE( nHandleOut, ", "           +ALLTRIM(STR(BIN2W(SUBSTR(cBuff,5,2)))) +CRLF )

FREAD( nHandle, @cBuff,  8 )
FWRITE( nHandleOut, "PRODUCTVERSION " +ALLTRIM(STR(BIN2W(SUBSTR(cBuff,3,2)))) )
FWRITE( nHandleOut, ", "           +ALLTRIM(STR(BIN2W(SUBSTR(cBuff,1,2)))) )
FWRITE( nHandleOut, ", "           +ALLTRIM(STR(BIN2W(SUBSTR(cBuff,7,2)))) )
FWRITE( nHandleOut, ", "           +ALLTRIM(STR(BIN2W(SUBSTR(cBuff,5,2)))) +CRLF )

FREAD( nHandle, @cBuff,  4 )
DO CASE
   CASE BIN2W(cBuff)==dfHex2Dec( "0000003F" )
        FWRITE( nHandleOut, "VS_FF_DEBUG | VS_FF_PRERELEASE | VS_FF_PATCHED | VS_FF_PRIVATEBUILD | VS_FF_INFOINFERRED | VS_FF_SPECIALBUILD" +CRLF )

   OTHERWISE
        F_WriteWord( nHandleOut, "FILEFLAGSMASK : ", cBuff )
ENDCASE

FREAD( nHandle, @cBuff,  4 )
//F_WriteWord( nHandleOut, "FileFlags        : ", cBuff )

FREAD( nHandle, @cBuff,  4 )
DO CASE
   CASE BIN2W(cBuff)==dfHex2Dec( "00010001" )
        FWRITE( nHandleOut, "FILEOS           : VOS__WINDOWS16" +CRLF )

   OTHERWISE
        F_WriteWord( nHandleOut, "FILEOS           : ", cBuff )
ENDCASE

FREAD( nHandle, @cBuff,  4 )
DO CASE
   CASE BIN2W(cBuff)==1
        FWRITE( nHandleOut, "FILETYPE         : VFT_APP" +CRLF )
   OTHERWISE
        F_WriteWord( nHandleOut, "FILETYPE         : ", cBuff )
ENDCASE

//FREAD( nHandle, @cBuff,  4 )
//F_WriteWord( nHandleOut, "FileSubtype      : ", cBuff )
//FREAD( nHandle, @cBuff,  4 )
//F_WriteWord( nHandleOut, "FileDateMS       : ", cBuff )
//FREAD( nHandle, @cBuff,  4 )
//F_WriteWord( nHandleOut, "FileDateLS       : ", cBuff )

FWRITE( nHandleOut, CRLF )
#endif

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_RT_STRING( nHandle, nHandleOut, nResOfs, nResLen, l32 )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cBuff, nLen, lFirst := .T.
LOCAL nLenBuf

nLenBuf := IF( l32, 2, 1 )
WHILE .T.
   cBuff := SPACE(nLenBuf)
   FREAD( nHandle, @cBuff, nLenBuf )
   IF l32
      nLen := BIN2W(cBuff)
      IF cBuff=="PA"
         nLen := 0
      ENDIF
   ELSE
      nLen := ASC(cBuff)
   ENDIF
   IF nLen==0
      IF lFirst
         WHILE nLen==0
            FREAD( nHandle, @cBuff, nLenBuf )
            IF l32
               nLen := BIN2W(cBuff)
            ELSE
               nLen := ASC(cBuff)
            ENDIF
         ENDDO
      ELSE
         EXIT
      ENDIF
   ENDIF
   lFirst := .F.
   // Fir introdotto dalla 2.60
   IF (nLen*nLenBuf)>64000
      EXIT
   ENDIF
   cBuff  := SPACE( nLen*nLenBuf )
   IF FREAD( nHandle, @cBuff, nLen*nLenBuf )==nLen*nLenBuf
      IF LEFT(cBuff,1)!=CHR(0)
         cBuff := F_StrConvert( cBuff, l32 )
         FWRITE( nHandleOut, [		] +ALLTRIM(STR(STRINGPOS++)) +[, "] +cBuff +["] +CRLF )
      ELSE
         EXIT // Se il primo carattere Š 0
      ENDIF
   ELSE
      EXIT // Se non riesco a leggere
   ENDIF
ENDDO
FWRITE( nHandleOut, CRLF )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_RT_ICON( nHandle, nHandleOut, nResOfs, nResLen )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL bWidth         := SPACE(1) // Width in pixels
LOCAL bHeight        := SPACE(1) // Height in pixels
LOCAL bColorCount    := SPACE(1) // Number of colors
LOCAL bReserved      := SPACE(1) // Reserved
LOCAL wPlanes        := SPACE(2) // Number of color planes
LOCAL wBitsPerPel    := SPACE(2) // Number of bits per pixel
LOCAL dwBytesInRes   := SPACE(4) // size of resource in bytes
LOCAL wOrdinalNumber := SPACE(2) // Ordinal value
LOCAL cBuff := SPACE(8), cNewBuff, cSize, nNewHandle, cIco, lSkip := .F.

IF ASCAN( ARESOURCE, {|cSub|cSub=="ICO"} )==0
   FREAD( nHandle, @cBuff         , 8 )
   FREAD( nHandle, @bWidth        , 1 )
   FREAD( nHandle, @bHeight       , 1 )
   FREAD( nHandle, @bColorCount   , 1 )
   FREAD( nHandle, @bReserved     , 1 )
   FREAD( nHandle, @wPlanes       , 2 )
   FREAD( nHandle, @wBitsPerPel   , 2 )
   FREAD( nHandle, @dwBytesInRes  , 4 )
   FREAD( nHandle, @wOrdinalNumber, 2 )

   #ifdef DEBUG
      FWRITE( nHandleOut,CRLF +"bWidth         : " +STR(ASC  (bWidth        ))   )
      FWRITE( nHandleOut,CRLF +"bHeight        : " +STR(ASC  (bHeight       ))   )
      FWRITE( nHandleOut,CRLF +"bColorCount    : " +STR(ASC  (bColorCount   ))   )
      FWRITE( nHandleOut,CRLF +"bReserved      : " +STR(ASC  (bReserved     ))   )
      FWRITE( nHandleOut,CRLF +"wPlanes        : " +STR(BIN2W(wPlanes       ))   )
      FWRITE( nHandleOut,CRLF +"wBitsPerPel    : " +STR(BIN2W(wBitsPerPel   ))   )
      FWRITE( nHandleOut,CRLF +"dSize(bytes)   : " +STR(BIN2L(dwBytesInRes  ))   )
      FWRITE( nHandleOut,CRLF +"wOrdinalNumber : " +STR(BIN2W(wOrdinalNumber))   )
      FWRITE( nHandleOut,CRLF +"Offset : " +dfDec2Hex(nResOfs) +" Len " +STR(nResLen)  )
   #endif

   FSEEK( nHandle, nResOfs )
   cBuff := SPACE(BUFLEN)
   FREAD( nHandle, @cBuff, BUFLEN )

   cNewBuff := CHR(00) +CHR(00) +CHR(01) +CHR(00) +CHR(01) +CHR(00)
   DO CASE
      // _Mod_
      CASE ASC(bWidth)== 32 // trovato in WINCMD
           cNewBuff += CHR(16) +CHR(16)
           cSize := CHR(232)+CHR(02)

      CASE ASC(bWidth)== 48
           cNewBuff += CHR(32) +CHR(16)
           DO CASE
              CASE BIN2W(wBitsPerPel)==1; cSize := I2BIN(dfHex2Dec("00B0"))
              CASE BIN2W(wBitsPerPel)==3; cSize := I2BIN(dfHex2Dec("01A8"))
              CASE BIN2W(wBitsPerPel)==4; cSize := I2BIN(dfHex2Dec("01A8"))
              CASE BIN2W(wBitsPerPel)==8; cSize := I2BIN(dfHex2Dec("0668"))
              // MAX SIZE
              OTHERWISE                 ; cSize := I2BIN(dfHex2Dec("0668"))
           ENDCASE

      CASE ASC(bWidth)== 64
           cNewBuff += CHR(32) +CHR(32)
           DO CASE
              CASE BIN2W(wBitsPerPel)==1; cSize := I2BIN(dfHex2Dec("0130"))
              CASE BIN2W(wBitsPerPel)==3; cSize := I2BIN(dfHex2Dec("02E8"))
              CASE BIN2W(wBitsPerPel)==4; cSize := I2BIN(dfHex2Dec("02E8"))
              CASE BIN2W(wBitsPerPel)==8; cSize := I2BIN(dfHex2Dec("08A8"))
              // MAX SIZE
              OTHERWISE                 ; cSize := I2BIN(dfHex2Dec("08A8"))
           ENDCASE

      CASE ASC(bWidth)==128
           cNewBuff += CHR(64) +CHR(64)
           DO CASE
              CASE BIN2W(wBitsPerPel)==1; cSize := I2BIN(dfHex2Dec("0430"))
              CASE BIN2W(wBitsPerPel)==3; cSize := I2BIN(dfHex2Dec("0A68"))
              CASE BIN2W(wBitsPerPel)==4; cSize := I2BIN(dfHex2Dec("0A68"))
              CASE BIN2W(wBitsPerPel)==8; cSize := I2BIN(dfHex2Dec("1628"))
              // MAX SIZE
              OTHERWISE                 ; cSize := I2BIN(dfHex2Dec("1628"))
           ENDCASE

      OTHERWISE
           lSkip := .T.

   ENDCASE
   IF !lSkip
      cNewBuff += I2BIN(2^BIN2W(wBitsPerPel))
      cNewBuff += CHR(00) +CHR(00) +CHR(00) +CHR(00)
      cNewBuff += cSize
      cNewBuff += CHR(00) +CHR(00)
      cNewBuff += CHR(22) +CHR(00) +CHR(00) +CHR(00)
      cNewBuff += cBuff
      cNewBuff := PADR( cNewBuff, BIN2W(cSize)+22, CHR(0) )

      cIco := F_ExtName( "ico" )
      IF !EMPTY(cIco)

         nNewHandle := FCREATE( cIco )
         FWRITE( nNewHandle, cNewBuff )
         FCLOSE( nNewHandle )
         LOCCOUNTER++
         TOTCOUNTER++

         FWRITE( nHandleOut, "                Ripped Icon   : " +cIco )
         FWRITE( nHandleOut, " " +ALLTRIM(STR(ASC(SUBSTR(cNewBuff,7,1)))))
         FWRITE( nHandleOut, "x" +ALLTRIM(STR(ASC(SUBSTR(cNewBuff,8,1)))))
         FWRITE( nHandleOut, "x" +ALLTRIM(STR(INT(2^BIN2W(wBitsPerPel)))) +CRLF )
      ENDIF
   ELSE
      FWRITE( nHandleOut, "   þ Skipped NON STANDARD Icon" +CRLF )
   ENDIF
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_RT_MENU( nHandle, nHandleOut, nResOfs, nResLen, l32 )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cBuff,  aMenu := {}, nType, nKey, cStr, nPosMenu, nNumMenu, aClose := {}

IF l32
   RETURN
ENDIF

FSEEK( nHandle, 4, FS_RELATIVE )
nNumMenu := 0
WHILE .T. // NON FUNZA nResLen-->=0
   nKey  := 0
   cStr  := ""
   cBuff := SPACE(2)
   FREAD( nHandle, @cBuff, 2 )
   nType := BIN2W( cBuff )
   DO CASE
      CASE dfAnd( nType, 16 )>0  // Menu
           nPosMenu := FSEEK( nHandle, 0, FS_RELATIVE )
           cStr     := FREADSTR( nHandle, 256 )
           FSEEK( nHandle, nPosMenu+LEN(cStr)+1, FS_SET )
           nNumMenu++
           AADD( aClose, dfAnd( nType, 128 )>0 )

      CASE nNumMenu<=0
           EXIT

      OTHERWISE
           FREAD( nHandle, @cBuff, 2 )
           nKey := BIN2W( cBuff )
           nPosMenu := FSEEK( nHandle, 0, FS_RELATIVE )
           cStr := FREADSTR( nHandle, 256 )
           FSEEK( nHandle, nPosMenu+LEN(cStr)+1, FS_SET )
           IF dfAnd(nType,128)>0
              --nNumMenu
              WHILE LEN(aClose)>0 .AND. ATAIL( aClose )
                 --nNumMenu
                 ASIZE( aClose, LEN(aClose)-1 )
              ENDDO
              ASIZE( aClose, LEN(aClose)-1 )
           ENDIF

   ENDCASE
   AADD( aMenu, { nType, cStr, nKey, nNumMenu } )
ENDDO

FWRITE( nHandleOut, CRLF )
nNumMenu := 0
FOR nResLen := 1 TO LEN(aMenu)
   DO CASE
      CASE aMenu[nResLen][1]==0      .AND. ;
           LEN(aMenu[nResLen][2])==0 .AND. ;
           aMenu[nResLen][3]==0
           FWRITE( nHandleOut, REPLICATE("	",nNumMenu) +"		MENUITEM SEPARATOR" +CRLF )

      CASE dfAnd( aMenu[nResLen][1], 16 )>0 // Menu
           FWRITE( nHandleOut, REPLICATE("	",nNumMenu) +[		POPUP "] +F_StrConvert(aMenu[nResLen][2]) +["] +CRLF )
           FWRITE( nHandleOut, REPLICATE("	",nNumMenu) +[		BEGIN ] +CRLF )

      OTHERWISE
           FWRITE( nHandleOut, REPLICATE("	",nNumMenu) +[		MENUITEM "] +F_StrConvert(aMenu[nResLen][2]) +[", ] +ALLTRIM(STR(aMenu[nResLen][3])) )
           IF dfAnd( aMenu[nResLen][1], 8 )>0
              FWRITE( nHandleOut, ", CHECKED" )
           ENDIF
           FWRITE( nHandleOut, CRLF )
           IF aMenu[nResLen][4]!=nNumMenu
              FWRITE( nHandleOut, REPLICATE("	",aMenu[nResLen][4]) +[		END] +CRLF +CRLF )
           ENDIF
   ENDCASE
   nNumMenu := aMenu[nResLen][4]
NEXT
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_RT_ACCELERATOR( nHandle, nHandleOut, nResOfs, nResLen, l32 )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cBuff

IF l32
   RETURN
ENDIF

WHILE .T.
   cBuff := SPACE(5)
   FREAD( nHandle, @cBuff, 5 )
   IF SUBSTR(cBuff,2,1)==CHR(0)
      EXIT
   ENDIF
   FWRITE( nHandleOut, [		] +F_Key2Def( ASC( SUBSTR(cBuff,2,1) ) ) )
   FWRITE( nHandleOut, [, ] )
   FWRITE( nHandleOut, ALLTRIM(STR(ASC(SUBSTR(cBuff,4,1))+ASC(SUBSTR(cBuff,5,1))*256,5)) )
   IF dfAnd( ASC(SUBSTR(cBuff,1,1)), 1 )>0
      FWRITE( nHandleOut, ", VIRTKEY" )
   ENDIF
   IF dfAnd( ASC(SUBSTR(cBuff,1,1)), 8 )>0
      FWRITE( nHandleOut, ", CONTROL" )
   ENDIF
   IF dfAnd( ASC(SUBSTR(cBuff,1,1)), 4 )>0
      FWRITE( nHandleOut, ", SHIFT" )
   ENDIF
   FWRITE( nHandleOut, CRLF )
ENDDO
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_RT_GENERIC( nHandle, nHandleOut, nResOfs, nResLen )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aExt := { ;
                  {"RIFF","WAV", 5,"Wave"             } ,;
                  {"MSCF","CAB", 9,"Cab file"         } ,;
                  {"SZDD","EX_",-1,"MS Compress file" } ,;
                  {"?_"  ,"HLP",-1,"Windows Help"     } ,;
                  {"BM"  ,"BMP",-1,"Windows Bitmap"   } ,;
                  {"TPF0","DFM",-1,"Delphi Form"      }  ;
               }
LOCAL cBuff := SPACE(100), nSize, cFile, lRet := .F., nPos, cDesc

FSEEK( nHandle, nResOfs )
FREAD( nHandle, @cBuff, 100 )

nPos := ASCAN( aExt, {|aSub|LEFT(cBuff,LEN(aSub[1]))==aSub[1]} )
IF nPos>0
   IF ASCAN( ARESOURCE, {|cSub|cSub==aExt[nPos][2]} )>0
      nPos := 0
   ENDIF
ENDIF
IF nPos>0 .OR. GENERICDUMP
   nSize := nResLen
   IF nPos>0 .AND. aExt[nPos][3]>0
      nSize := BIN2L( SUBSTR(cBuff,aExt[nPos][3],4) )
   ENDIF

   cFile := "DMM"
   IF nPos>0
      cFile := aExt[nPos][2]
   ENDIF

   cDesc := "Generic File"
   IF nPos>0
      cDesc := aExt[nPos][4]
   ENDIF

   IF cFile=="DFM"
      nSize -= 8
   ENDIF

   IF cFile=="WAV" .AND. SUBSTR(cBuff,9,8)=="AVI LIST"
      cFile:="AVI"
      cDesc:="Windows AVI"
   ENDIF

   cFile := F_ExtName( cFile )
   IF !EMPTY(cFile)
      cDesc := " Generic Dumper Found a " +cDesc +" : " +cFile
      FWRITE( nHandleOut, "               " +cDesc +CRLF )
      RipLogSay( " ..." +cDesc )
                                            // Tolto il +8 : rimesso per le form delphi
      F_DUMP_FILE( cFile, nHandle, nResOfs, "", nSize+8 )

      // Update file if delphi FORM
      IF ".DFM"$UPPER(cFile)
         F_DFM( cFile, nHandle )
      ENDIF

      lRet  := .T.
   ENDIF
ENDIF

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_WriteVer( nHandleOut, cStr, cBuff )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FWRITE( nHandleOut, cStr )
FWRITE( nHandleOut, ALLTRIM(STR(BIN2W(SUBSTR(cBuff,3,2)))) )
FWRITE( nHandleOut, "."                           )
FWRITE( nHandleOut, ALLTRIM(STR(BIN2W(SUBSTR(cBuff,1,2)))) )
FWRITE( nHandleOut, CRLF )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_WriteWord( nHandleOut, cStr, cBuff )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FWRITE( nHandleOut, cStr )
FWRITE( nHandleOut, dfDec2Hex(BIN2W(SUBSTR(cBuff,3,2))) )
FWRITE( nHandleOut, dfDec2Hex(BIN2W(SUBSTR(cBuff,1,2))) )
FWRITE( nHandleOut, CRLF )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_Key2Def( nKey )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet := ""
DO CASE
   CASE nKey==VK_LBUTTON          ; cRet := "VK_LBUTTON"
   CASE nKey==VK_RBUTTON          ; cRet := "VK_RBUTTON"
   CASE nKey==VK_CANCEL           ; cRet := "VK_CANCEL"
   CASE nKey==VK_MBUTTON          ; cRet := "VK_MBUTTON"
   CASE nKey==VK_BACK             ; cRet := "VK_BACK"
   CASE nKey==VK_TAB              ; cRet := "VK_TAB"
   CASE nKey==VK_CLEAR            ; cRet := "VK_CLEAR"
   CASE nKey==VK_RETURN           ; cRet := "VK_RETURN"
   CASE nKey==VK_SHIFT            ; cRet := "VK_SHIFT"
   CASE nKey==VK_CONTROL          ; cRet := "VK_CONTROL"
   CASE nKey==VK_MENU             ; cRet := "VK_MENU"
   CASE nKey==VK_PAUSE            ; cRet := "VK_PAUSE"
   CASE nKey==VK_CAPITAL          ; cRet := "VK_CAPITAL"
   CASE nKey==VK_ESCAPE           ; cRet := "VK_ESCAPE"
   CASE nKey==VK_SPACE            ; cRet := "VK_SPACE"
   CASE nKey==VK_PRIOR            ; cRet := "VK_PRIOR"
   CASE nKey==VK_NEXT             ; cRet := "VK_NEXT"
   CASE nKey==VK_END              ; cRet := "VK_END"
   CASE nKey==VK_HOME             ; cRet := "VK_HOME"
   CASE nKey==VK_LEFT             ; cRet := "VK_LEFT"
   CASE nKey==VK_UP               ; cRet := "VK_UP"
   CASE nKey==VK_RIGHT            ; cRet := "VK_RIGHT"
   CASE nKey==VK_DOWN             ; cRet := "VK_DOWN"
   CASE nKey==VK_SELECT           ; cRet := "VK_SELECT"
   CASE nKey==VK_PRINT            ; cRet := "VK_PRINT"
   CASE nKey==VK_EXECUTE          ; cRet := "VK_EXECUTE"
   CASE nKey==VK_SNAPSHOT         ; cRet := "VK_SNAPSHOT"
   CASE nKey==VK_INSERT           ; cRet := "VK_INSERT"
   CASE nKey==VK_DELETE           ; cRet := "VK_DELETE"
   CASE nKey==VK_HELP             ; cRet := "VK_HELP"
   CASE nKey==VK_LWIN             ; cRet := "VK_LWIN"
   CASE nKey==VK_RWIN             ; cRet := "VK_RWIN"
   CASE nKey==VK_APPS             ; cRet := "VK_APPS"
   CASE nKey==VK_NUMPAD0          ; cRet := "VK_NUMPAD0"
   CASE nKey==VK_NUMPAD1          ; cRet := "VK_NUMPAD1"
   CASE nKey==VK_NUMPAD2          ; cRet := "VK_NUMPAD2"
   CASE nKey==VK_NUMPAD3          ; cRet := "VK_NUMPAD3"
   CASE nKey==VK_NUMPAD4          ; cRet := "VK_NUMPAD4"
   CASE nKey==VK_NUMPAD5          ; cRet := "VK_NUMPAD5"
   CASE nKey==VK_NUMPAD6          ; cRet := "VK_NUMPAD6"
   CASE nKey==VK_NUMPAD7          ; cRet := "VK_NUMPAD7"
   CASE nKey==VK_NUMPAD8          ; cRet := "VK_NUMPAD8"
   CASE nKey==VK_NUMPAD9          ; cRet := "VK_NUMPAD9"
   CASE nKey==VK_MULTIPLY         ; cRet := "VK_MULTIPLY"
   CASE nKey==VK_ADD              ; cRet := "VK_ADD"
   CASE nKey==VK_SEPARATOR        ; cRet := "VK_SEPARATOR"
   CASE nKey==VK_SUBTRACT         ; cRet := "VK_SUBTRACT"
   CASE nKey==VK_DECIMAL          ; cRet := "VK_DECIMAL"
   CASE nKey==VK_DIVIDE           ; cRet := "VK_DIVIDE"
   CASE nKey==VK_F1               ; cRet := "VK_F1"
   CASE nKey==VK_F2               ; cRet := "VK_F2"
   CASE nKey==VK_F3               ; cRet := "VK_F3"
   CASE nKey==VK_F4               ; cRet := "VK_F4"
   CASE nKey==VK_F5               ; cRet := "VK_F5"
   CASE nKey==VK_F6               ; cRet := "VK_F6"
   CASE nKey==VK_F7               ; cRet := "VK_F7"
   CASE nKey==VK_F8               ; cRet := "VK_F8"
   CASE nKey==VK_F9               ; cRet := "VK_F9"
   CASE nKey==VK_F10              ; cRet := "VK_F10"
   CASE nKey==VK_F11              ; cRet := "VK_F11"
   CASE nKey==VK_F12              ; cRet := "VK_F12"
   CASE nKey==VK_F13              ; cRet := "VK_F13"
   CASE nKey==VK_F14              ; cRet := "VK_F14"
   CASE nKey==VK_F15              ; cRet := "VK_F15"
   CASE nKey==VK_F16              ; cRet := "VK_F16"
   CASE nKey==VK_F17              ; cRet := "VK_F17"
   CASE nKey==VK_F18              ; cRet := "VK_F18"
   CASE nKey==VK_F19              ; cRet := "VK_F19"
   CASE nKey==VK_F20              ; cRet := "VK_F20"
   CASE nKey==VK_F21              ; cRet := "VK_F21"
   CASE nKey==VK_F22              ; cRet := "VK_F22"
   CASE nKey==VK_F23              ; cRet := "VK_F23"
   CASE nKey==VK_F24              ; cRet := "VK_F24"
   CASE nKey==VK_NUMLOCK          ; cRet := "VK_NUMLOCK"
   CASE nKey==VK_SCROLL           ; cRet := "VK_SCROLL"
   OTHERWISE
        cRet := ["] +CHR(nKey) +["]
ENDCASE
RETURN cRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_StrConvert( cBuff, l32 )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DEFAULT l32 TO .F.

IF l32
   cBuff := dfCharOdd(cBuff)
ENDIF

cBuff := STRTRAN( cBuff, CHR( 9), "\t" )
cBuff := STRTRAN( cBuff, CHR(10), "\n" )
cBuff := STRTRAN( cBuff, CHR(13), "\r" )

RETURN cBuff


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_Res2Desc( nRes )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet

DO CASE
   CASE nRes == RT_CURSOR      ; cRet := "RT_CURSOR       "
   CASE nRes == RT_BITMAP      ; cRet := "RT_BITMAP       "
   CASE nRes == RT_ICON        ; cRet := "RT_ICON         "
   CASE nRes == RT_MENU        ; cRet := "RT_MENU         "
   CASE nRes == RT_DIALOG      ; cRet := "RT_DIALOG       "
   CASE nRes == RT_STRING      ; cRet := "RT_STRING       "
   CASE nRes == RT_FONTDIR     ; cRet := "RT_FONTDIR      "
   CASE nRes == RT_FONT        ; cRet := "RT_FONT         "
   CASE nRes == RT_ACCELERATOR ; cRet := "RT_ACCELERATOR  "
   CASE nRes == RT_RCDATA      ; cRet := "RT_RCDATA       "
   CASE nRes == RT_MESSAGETABLE; cRet := "RT_MESSAGETABLE "
   CASE nRes == RT_GROUP_CURSOR; cRet := "RT_GROUP_CURSOR "
   CASE nRes == RT_GROUP_ICON  ; cRet := "RT_GROUP_ICON   "
   CASE nRes == NAMETABLE      ; cRet := "NAMETABLE       "
   CASE nRes == RT_VERSION     ; cRet := "RT_VERSION      "
   CASE nRes == RT_DLGINCLUDE  ; cRet := "RT_DLGINCLUDE   "
   CASE nRes == RT_PLUGPLAY    ; cRet := "RT_PLUGPLAY     "
   CASE nRes == RT_VXD         ; cRet := "RT_VXD          "
   CASE nRes == RT_ANICURSOR   ; cRet := "RT_ANICURSOR    "
   CASE nRes == RT_ANIICON     ; cRet := "RT_ANIICON      "
   OTHERWISE                   ; cRet := "UNKNOWN RE-" +dfDec2Hex(nRes) +" "
ENDCASE

RETURN cRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_Res2DePE( nRes )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet

DO CASE
   CASE nRes == PE_RES_0       ; cRet := "RES_0           "
   CASE nRes == PE_CURSOR      ; cRet := "CURSOR          "
   CASE nRes == PE_BITMAP      ; cRet := "BITMAP          "
   CASE nRes == PE_ICON        ; cRet := "ICON            "
   CASE nRes == PE_MENU        ; cRet := "MENU            "
   CASE nRes == PE_DIALOG      ; cRet := "DIALOG          "
   CASE nRes == PE_STRING      ; cRet := "STRING          "
   CASE nRes == PE_FONTDIR     ; cRet := "FONTDIR         "
   CASE nRes == PE_FONT        ; cRet := "FONT            "
   CASE nRes == PE_ACCELERATORS; cRet := "ACCELERATORS    "
   CASE nRes == PE_RCDATA      ; cRet := "RCDATA          "
   CASE nRes == PE_MESSAGETABLE; cRet := "MESSAGETABLE    "
   CASE nRes == PE_GROUP_CURSOR; cRet := "GROUP_CURSOR    "
   CASE nRes == PE_RES_13      ; cRet := "RES_13          "
   CASE nRes == PE_GROUP_ICON  ; cRet := "GROUP_ICON      "
   CASE nRes == PE_RES_15      ; cRet := "RES_15          "
   CASE nRes == PE_VERSION     ; cRet := "VERSION         "
   OTHERWISE                   ; cRet := "UNKNOWN PE-" +dfDec2Hex(nRes) +" "
ENDCASE

RETURN cRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_DFM( cFile, nHandleEXE )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC nForm := 0
LOCAL nHandle := F_Fopen( cFile ), cBuffer := SPACE(4096)
LOCAL cDmm, nDmm, nReaded, cUnit, aVar, nProc, cSourceName, cTempName
//LOCAL xx

nForm++
//IF SERTYPE==MRIPPER_SHAREWARE .AND. nForm>3
   //IF nForm==4
      //ALERT("Shareware version;Delphi decompilation reduced to 3 FORM;Register to remove this limit")
   //ENDIF
   //RETURN
//ENDIF

IF nHandle>0
   nReaded := FREAD( nHandle, @cBuffer, 4096 )

   // Create File
   cDmm := F_ExtName( "000" )
   nDmm := FCREATE( cDmm )

   // Unit
   // Eccezione per form di C++ Builder 3
   IF SUBSTR(cBuffer,5,1)$BCC3_F1
   // Eccezione per form di C++ Builder 3
      cUnit := SUBSTR( cBuffer, 7, ASC(SUBSTR(cBuffer,6,1)) )
   ELSE // DEFAULT
      cUnit := SUBSTR( cBuffer, 6, ASC(SUBSTR(cBuffer,5,1)) )
   ENDIF

   // Create Header
   FWRITE( nDmm, CHR(dfHex2Dec("FF"))        +;
                 CHR(dfHex2Dec("0A"))        +;
                 CHR(dfHex2Dec("00"))        +;
                 UPPER(cUnit)                +;
                 CHR(dfHex2Dec("00"))        +;
                 CHR(dfHex2Dec("30"))        +;
                 CHR(dfHex2Dec("10"))        +;
                 L2BIN( dfFileSize(nHandle) ) )

   // And now append the file
   FWRITE( nDmm, cBuffer, nReaded )
   IF nReaded==4096
      WHILE (nReaded:=FREAD( nHandle, @cBuffer, 4096 ))>0
         FWRITE( nDmm, cBuffer, nReaded )
         IF nReaded<4096
            EXIT
         ENDIF
      ENDDO
   ENDIF
   FCLOSE( nDmm    )
   FCLOSE( nHandle )

   FERASE( cFile )
   FRENAME( cDmm, cFile )

   cTempName := STRTRAN(cFile,".DFM",".PAS")
   nDmm := FCREATE( cTempName )
   IF nDmm>0
      cSourceName := F_DFMFile( nHandleEXE, cUnit, STRTRAN(cFile,".DFM","") )

      FWRITE( nDmm, "{*****************************************************************************}" +CRLF )
      FWRITE( nDmm, "{*      -> Multi Ripper "+padr(RIPVERSION+" <-",8)+"      The Multi-Purpose File Extractor       *}" +CRLF )
      FWRITE( nDmm, "{******* To have the last release send an email to " +EMAIL +" *******}" +CRLF )
      FWRITE( nDmm, "unit " +cSourceName +";" +CRLF )
      FWRITE( nDmm, CRLF )
      FWRITE( nDmm, "interface" +CRLF )
      FWRITE( nDmm, CRLF )
      FWRITE( nDmm, "uses" +CRLF )
      FWRITE( nDmm, "  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs," +CRLF )
      FWRITE( nDmm, "  ComCtrls, StdCtrls, Buttons, ExtCtrls, CommCtrl;" +CRLF )
      FWRITE( nDmm, CRLF )
      FWRITE( nDmm, "type" +CRLF )
      FWRITE( nDmm, "  " +cUnit +" = class(TForm)" +CRLF )

      aVar := F_DFMVal( nDmm, cFile )
      FOR nProc:=LEN(aVar[2]) TO 1 STEP -1
         FWRITE( nDmm, "    procedure " +F_Proc2Par(aVar[2][nProc]) +CRLF )
      NEXT

      FWRITE( nDmm, "  private" +CRLF )
      FWRITE( nDmm, "    { Private declarations }" +CRLF )
      FWRITE( nDmm, "  public" +CRLF )
      FWRITE( nDmm, "    { Public declarations }" +CRLF )
      FWRITE( nDmm, "  end;" +CRLF )
      FWRITE( nDmm, CRLF )
      FWRITE( nDmm, "var" +CRLF )
      FWRITE( nDmm, "  " +aVar[1] +": " +cUnit +";" +CRLF )
      FWRITE( nDmm, CRLF )
      FWRITE( nDmm, "implementation" +CRLF )
      FWRITE( nDmm, CRLF )
      FWRITE( nDmm, "{$R *.DFM}" +CRLF )
      FWRITE( nDmm, CRLF )

      FOR nProc:=LEN(aVar[2]) TO 1 STEP -1
         FWRITE( nDmm, "procedure " +cUnit +"." +F_Proc2Par(aVar[2][nProc]) +CRLF )
         FWRITE( nDmm, "begin" +CRLF )
         FWRITE( nDmm, "  { Sorry, MRipper is not able to decompile this method }" +CRLF )
         FWRITE( nDmm, "end;" +CRLF )
         FWRITE( nDmm, "" +CRLF )
      NEXT

      FWRITE( nDmm, "end." +CRLF )

      FCLOSE( nDmm )

      //xx := EXTPATH
      FRENAME( cTempName, EXTPATH+cSourceName+".PAS" )
      FRENAME( cFile    , EXTPATH+cSourceName+".DFM" )
      cTempName := EXTPATH+cSourceName+".PAS"

      AADD( DELPHISOURCE, { cSourceName, cTempName, cUnit, aVar[1] } )
   ENDIF
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_DFMFile( nHandleEXE, cUnit, cDmm )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cBuffer, nProc

FSEEK( nHandleEXE, 0 )
FSEEK( nHandleEXE, dfPatternPos( nHandleEXE, CHR(7)+CHR(LEN(cUnit))+cUnit )+LEN(cUnit)+2+10, 0 )

cBuffer := SPACE(1)
FREAD( nHandleEXE, @cBuffer, 1 )

nProc := ASC(cBuffer)
cBuffer := SPACE(nProc)
FREAD( nHandleEXE, @cBuffer, nProc )
IF LEN(ALLTRIM(cBuffer))==0 .OR. LEN(cBuffer)>10
   //ALERT( CHR(7)+CHR(LEN(cUnit))+cUnit+"-"+str(nProc)+"-" )
   cBuffer := cDmm
ENDIF

RETURN cBuffer

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION F_Proc2Par( cProc )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cDec := cProc[1] +"(Sender: TObject);"
DO CASE
   CASE cProc[2]=="OnClose"
        cDec := cProc[1]+"(Sender: TObject; var Action: TCloseAction);"
   CASE cProc[2]=="OnKeyDown"
        cDec := cProc[1]+"(Sender: TObject; var Key: Word; Shift: TShiftState);"
   CASE cProc[2]=="OnReceiveData"
        cDec := cProc[1]+"(Sender: TObject; DataPtr: Pointer; DataSize: Integer);"
ENDCASE
RETURN cDec

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_DFMVal( nDmm, cFile )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle := F_Fopen( cFile, FO_READWRITE ), cBuffer := SPACE(4096)
LOCAL nReaded, nPos, nLen, nProg := 0, nType, cType := "", aVar := {"",{}}
LOCAL lFirst := .T., cParType

IF nHandle>0
   nReaded := FREAD( nHandle, @cBuffer, 4096 )
   nPos := AT( "TPF0", cBuffer )

   // Eccezione per form di C++ Builder 3
   IF SUBSTR(cBuffer,nPos+4,1)$BCC3_F1
      nPos++
   ENDIF
   // Eccezione per form di C++ Builder 3

   FSEEK( nHandle, nPos+3 )

   F_Loop( @nProg, nHandle, nDmm, aVar, 1 )

   FCLOSE( nHandle )
ENDIF

RETURN aVar

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_Loop( nProg, nHandle, nDmm, aVar, nLev )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cBuffer, nReaded, nLen, cTye := ""
LOCAL lFirst := .T., cParType, nType, cType := ""
   WHILE .T.
      nProg++
      cBuffer := SPACE(1)
      nReaded := FREAD( nHandle, @cBuffer, 1 )

      IF ASC(cBuffer)>0 .OR. (ASC(cBuffer)==0 .AND. nProg==2)
         IF (ASC(cBuffer)==0 .AND. nProg==2)
            cBuffer := ""
         ELSE
            nLen    := ASC(cBuffer)

            // Eccezione per form di C++ Builder 3
            DO CASE
               CASE CHR(nLen)$BCC3_F1
                  cBuffer := SPACE( 1 )
                  nReaded := FREAD( nHandle, @cBuffer, 1 )
                  nLen    := ASC(cBuffer)
               CASE CHR(nLen)$BCC3_F2
                  cBuffer := SPACE( 3 )
                  nReaded := FREAD( nHandle, @cBuffer, 3 )
                  nLen    := ASC(SUBSTR(cBuffer,3,1))
               CASE CHR(nLen)$CHR(0)
                  cBuffer := SPACE( 1 )
                  nReaded := FREAD( nHandle, @cBuffer, 1 )
                  nLen    := ASC(cBuffer)
            ENDCASE
            // Eccezione per form di C++ Builder 3

            cBuffer := SPACE( nLen )
            nReaded := FREAD( nHandle, @cBuffer, nLen )
         ENDIF

         DO CASE
            CASE nProg==1
                 cType := cBuffer

            CASE nProg==2
                 IF lFirst
                    lFirst := .F.
                    aVar[1] := cBuffer
                 ELSE
                    IF EMPTY(cBuffer)
                       IF nDmm>0
                          FWRITE( nDmm, "    {*" +cType +"*}" +CRLF )
                       ENDIF
                    ELSE
                       IF nDmm>0
                          FWRITE( nDmm, "    " +cBuffer +": " +cType +";" +CRLF )
                       ENDIF
                    ENDIF
                 ENDIF
                 F_DFMRow( nDmm, "    {" +CRLF )

            OTHERWISE
                 cParType := cBuffer
                 F_DFMRow( nDmm, "    " +cParType +": " )

                 // Leggo il tipo di dato
                 cBuffer := SPACE(1)
                 nReaded := FREAD( nHandle, @cBuffer, 1 )
                 nType   := ASC( cBuffer )

                 DO CASE
                    CASE nType==14 // String = size - len, l'ultimo ha 0
                         // Ricorsione
                         cBuffer := SPACE(1)
                         nReaded := FREAD( nHandle, @cBuffer, 1 )
                         WHILE ASC(cBuffer)==1
                            F_DFMRow( nDmm, "    {" +CRLF )
                            F_Loop( @nProg, nHandle, nDmm, aVar, nLev+1 )
                            cBuffer := SPACE(1)
                            nReaded := FREAD( nHandle, @cBuffer, 1 )
                         ENDDO

                    CASE nType==1 // String = size - len, l'ultimo ha 0
                         WHILE .T.
                            cBuffer := SPACE(1)
                            nReaded := FREAD( nHandle, @cBuffer, 1 )
                            IF ASC(cBuffer)==0 .OR. nReaded<=0
                               F_DFMRow( nDmm, ";" +CRLF )
                               EXIT
                            ELSE
                               IF !F_Consume( nHandle, nDmm, ASC(cBuffer), cParType, aVar )
                                  EXIT
                               ENDIF
                            ENDIF
                         ENDDO

                    OTHERWISE
                         IF !F_Consume( nHandle, nDmm, nType, cParType, aVar )
                            EXIT
                         ENDIF
                 ENDCASE


         ENDCASE
      ELSE
         F_DFMRow( nDmm, "    }" +CRLF )

         IF nLev==1
            WHILE nReaded>0
               nProg   := FSEEK( nHandle, 0, FS_RELATIVE )
               cBuffer := SPACE(1)
               nReaded := FREAD( nHandle, @cBuffer, 1 )
               IF nReaded>0 .AND. ASC(cBuffer)>0
                  FSEEK( nHandle, nProg, FS_SET )
                  nProg := 0
                  EXIT
               ENDIF
            ENDDO

            IF nProg==0
               LOOP
            ENDIF
         ENDIF
         EXIT
      ENDIF
   ENDDO
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION F_Consume( nHandle, nDmm, nType, cParType, aVar )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL bRet := .T., cBuffer, nReaded, nLen

DO CASE
   CASE nType==2     // 1 byte
        cBuffer := SPACE(1)
        nReaded := FREAD( nHandle, @cBuffer, 1 )
        F_DFMRow( nDmm, ALLTRIM(STR(ASC(cBuffer))) +CRLF )

   CASE nType==3     // 2 byte
        cBuffer := SPACE(2)
        nReaded := FREAD( nHandle, @cBuffer, 2 )
        F_DFMRow( nDmm, ALLTRIM(STR(BIN2W(cBuffer))) +CRLF )

   CASE nType==4     // 4 byte
        cBuffer := SPACE(4)
        nReaded := FREAD( nHandle, @cBuffer, 4 )
        F_DFMRow( nDmm, ALLTRIM(STR(BIN2L(cBuffer))) +CRLF )

   CASE nType==5     // 4 byte
        cBuffer := SPACE( 10 )
        nReaded := FREAD( nHandle, @cBuffer, 10 )
        F_DFMRow( nDmm, cBuffer )

   CASE nType==6 .OR. nType==7 // c'e' la len
        cBuffer := SPACE(1)
        nReaded := FREAD( nHandle, @cBuffer, 1 )

        nLen    := ASC(cBuffer)
        cBuffer := SPACE( nLen )
        nReaded := FREAD( nHandle, @cBuffer, nLen )

        F_DFMRow( nDmm, cBuffer +CRLF )
        IF nType==7 .AND. LEFT(cParType,2)=="On"
           IF DELPHIMETHODS
              IF ASCAN( aVar[2], {|cSub|cSub[1]==cBuffer} )==0
                 AADD( aVar[2], {cBuffer, cParType} )
              ENDIF
           ENDIF
        ENDIF

   CASE nType==8 // 0 byte il fatto che ci sia Š gi… il dato
        F_DFMRow( nDmm, "False" +CRLF )

   CASE nType==9 // 0 byte il fatto che ci sia Š gi… il dato
        F_DFMRow( nDmm, "True" +CRLF )

   CASE nType==10    // 4 byte di size
        cBuffer := SPACE(4)
        nReaded := FREAD( nHandle, @cBuffer, 4 )
        FSEEK( nHandle, BIN2L(cBuffer), FS_RELATIVE )

        F_DFMRow( nDmm, "Image of 0x" +dfLong2Hex(BIN2L(cBuffer)) +" bytes " +CRLF )

   CASE nType==11 // Enumerate = size - len, l'ultimo ha 0
        WHILE .T.
           cBuffer := SPACE(1)
           nReaded := FREAD( nHandle, @cBuffer, 1 )
           IF ASC(cBuffer)==0 .OR. nReaded<=0
              F_DFMRow( nDmm, ";" +CRLF )
              EXIT
           ELSE
              nLen    := ASC(cBuffer)
              cBuffer := SPACE( nLen )
              nReaded := FREAD( nHandle, @cBuffer, nLen )
              F_DFMRow( nDmm, ["] +cBuffer +["] )
           ENDIF
        ENDDO

        // 23:56:05 marted 17 agosto 2004 new
   CASE nType==20 // c'e' la len da 4
        cBuffer := SPACE(4)
        nReaded := FREAD( nHandle, @cBuffer, 4 )

        nLen    := BIN2L(cBuffer)
        cBuffer := SPACE( nLen )
        nReaded := FREAD( nHandle, @cBuffer, nLen )

        F_DFMRow( nDmm, cBuffer +CRLF )

        // 23:56:05 marted 17 agosto 2004 new
   CASE nType==18 // c'e' la len da 4 (unicode)
        cBuffer := SPACE(4)
        nReaded := FREAD( nHandle, @cBuffer, 4 )

        nLen    := BIN2L(cBuffer)*2
        cBuffer := SPACE( nLen )
        nReaded := FREAD( nHandle, @cBuffer, nLen )

        F_DFMRow( nDmm, "UNICODE " +cBuffer +CRLF )
   OTHERWISE
        FWRITE( nDmm, "    {* OTHERWISE: unknown type (0x" +dfDec2Hex( nType ) +") send the exe to " +EMAIL +" *}" +CRLF )
        bRet = .F.
ENDCASE

RETURN bRet


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE F_DFMRow( nHandle, cBuffer )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF DELPHIVERBOSE
   IF nHandle>0
      FWRITE( nHandle, cBuffer )
   ENDIF
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION F_DFM2SRC( cDFM, aParent )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cDmm := STRTRAN( UPPER(cDFM), ".DFM", ".PAS" )
LOCAL nDmm

aStaticone := aParent

IF !(UPPER(cDmm)==UPPER(cDFM))
   nDmm := FCREATE( cDmm )
   IF nDmm>0
      F_DFMVal( nDmm, cDFM )
      FCLOSE(nDmm)
   ENDIF
ENDIF

RETURN NIL
