/******************************************************************************
Project     : TWT
Description : Hex View
Programmer  : Baccan Matteo
******************************************************************************/

#include "mripper.ch"

#define BUFFLEN2 4096

static nHandle, aDisp, nBuffLen1, nMaxRow, lFull := .F.
static nRowLen
static SCR := {} , CNT := 0  // for screen stack function

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
function F_hexview( aStaticone, cFileToView )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

local nkey, x, nFilePtr, nFileSize, nFileLast, cScreen, cScreen1
local xSrch, aDir, aDir2, string

NACTUAL := 1
NOFFSET := 1

nMaxRow := MaxRow()

//IF UPPER( cFull ) == '/F'
   //lfull := .T.
//ENDIF

nRowLen := iif( lFull, 64, 16 )

//setmode( nMaxRow + 1, 80 )

cScreen := SAVESCREEN( 0, 0, MAXROW(), MAXCOL() )

CLS
aDir := DIRECTORY(cFileToView)

set scoreboard off
set cursor off
setblink( .f. )

nBuffLen1 := ( nMaxRow - 3 ) * nRowLen

IF !NewFile( cFileToView, @nFilePtr, @nHandle, @nFileSize, @nFileLast )
   RESTSCREEN( 0, 0, MAXROW(), MAXCOL(), cScreen )
   Alert( cFileToView +"  File Open Error!!" )
   RETURN NIL
ENDIF

aDisp := Array( nMaxRow - 3, 2 )
fillarray( nFilePtr )

setcolor( 'N/W' )

@ 0,0 clear to 1, 79
@ nMaxRow-1,0 clear to nMaxRow, 79

@ 0,  1 SAY 'File: ' + ;
            Upper( IF( LEN( cFileToView ) < nRowLen, cFileToView, ;
            ".." + Right(cFileToView,13) ) ) COLOR 'N/W'
@ 0, 23 SAY TRANSFORM( nFileSize / 1000, "999,999" ) + 'kb' COLOR 'N/W'
@ 0, 35 SAY TRANSFORM( nFileSize, "9,999,999,999") + ' bytes' COLOR 'N/W'
@ 0, 55 SAY DTOC(aDir[1,3])+' '+aDir[1][4] COLOR 'N/W'

header( lFull )

setcolor( 'w+/b*' )

for x := 2 to nMaxRow - 2
   @ x,  0 say chr(219) color 'W/N'
   @ x, 79 say chr(219) color 'W/N'
next

@ 2,1 clear to nMaxRow - 2, 78

hex_disp( nFilePtr, nFileSize )

do while .t.

   cnt( 'F2 to Jump  F3 to Search  F7/F8 Dec/Inc Xor [' +RIGHT(dfDec2Hex(XORPATTERN),2) +']  F9 Toggle View  F10 New File', ;
        nMaxRow - 1 )
   cnt( CHR( 24 ) + ' ' + CHR( 25 ) + ' ' + CHR( 27 ) + ' ' + CHR( 26 ) + ;
        '   <Page Up>    <Page Down>    <Ctrl-Home>  '+;
        '  <Ctrl-End>    <Esc>', nMaxRow )

   nKey := inkey( 0 )

   do case
   case nKey == K_ESC
      exit

   case nKey == K_PGUP
      nFilePtr := MAX( 0, nFilePtr - nBuffLen1 )

   case nKey == K_PGDN
      nFilePtr := MIN( nFileLast, nFilePtr + nBuffLen1 )

   case nKey == K_UP
      IF nFilePtr> 0
         nFilePtr := MAX( 0, nFilePtr - nRowLen )
         fillarray( nFilePtr )
         DISPBEGIN()
         SCROLL( 2, 1, nMaxRow-2, 78, -1 )
         hex_disp( nFilePtr, nFileSize, ,.T. )
         DISPEND()
      ENDIF
      LOOP

   case nKey == K_DOWN
      IF nFilePtr<nFileLast
         nFilePtr := MIN( nFileLast, nFilePtr + nRowLen )
         fillarray( nFilePtr )
         DISPBEGIN()
         SCROLL( 2, 1, nMaxRow-2, 78, 1 )
         hex_disp( nFilePtr, nFileSize, .T. )
         DISPEND()
      ENDIF
      LOOP

   case nKey == K_LEFT
      nFilePtr := MAX( 0, nFilePtr - 1 )

   case nKey == K_RIGHT
      nFilePtr := MIN( nFileLast, nFilePtr + 1 )

   case nKey == K_CTRL_HOME .or. nKey == K_CTRL_PGUP
      nFilePtr := 0

   case nKey == K_CTRL_END .or. nKey == K_CTRL_PGDN
      nFilePtr := nFileLast

   case nKey == K_F2
      cScreen1 := SAVESCREEN( 0, 0, 0, maxcol() )

      xSrch   := 0
      @ 0, 36 SAY "Jump to:" COLOR "B/W, W/B"
      xSrch := VAL(dfAliveGet( 0, 44, 9, "B/W, W/B" ))
      nFilePtr := MAX(0,MIN(nFileLast, xSrch))

      RESTSCREEN( 0, 0, 0, maxcol(), cScreen1 )

   case nKey == K_F3
      cScreen1 := SAVESCREEN( 0, 0, 0, maxcol() )
      xSrch   := SPACE(10)
      @ 0, 36 SAY "Search for:" COLOR "B/W,W/B"
      xSrch := UPPER(ALLTRIM(dfAliveGet( 0, 47, 10, "B/W, W/B" )))
      If !EMPTY( xSrch )
         nFilePtr := ;
         MySearch( nFilePtr, nFileSize, nFileLast, TRIM( xSrch ) )
      Endif
      RESTSCREEN( 0, 0, 0, maxcol(), cScreen1 )

   case nKey == K_F4
      cScreen1 := SAVESCREEN( 0, 0, 0, maxcol() )
      F_DFM2SRC( cFileToView, aStaticone )
      RESTSCREEN( 0, 0, 0, maxcol(), cScreen1 )

   case nKey == K_F7
      IF --XORPATTERN<0
         XORPATTERN := 255
      ENDIF

   case nKey == K_F8
      IF ++XORPATTERN>255
         XORPATTERN := 0
      ENDIF

   case nKey == K_F9
      lFull := !lFull
      nRowLen := iif( lFull, 64, 16 )
      nBuffLen1 := ( nMaxRow - 3 ) * nRowLen
      nFileLast := nFileSize - ( nFileSize % nRowLen )
      nFileLast -= MIN( INT( nFileSize / nRowLen ), nMaxRow - 4 ) * nRowLen
      header( lFull )
      @ 2,1 clear to nMaxRow - 2, 78

   case nKey == K_F10
        setcolor( 'W/B' )
        hex_disp( nFilePtr, nFileSize )
        setcolor( 'W+/B*' )

        fClose( nHandle )
        F_CngFile()
        aDir := DIRECTORY( PARM )
        cFileToView := PARM

        /*
        dfShade( 5, 19, 20, 60 )
        @ 5, 19, 20, 61 BOX replicate( chr( 219 ), 8 ) + ' ' COLOR 'W+/B*'
        aDir := DIRECTORY( "*.*" )
        string := ' *.* '
        @ 5, 40 - LEN( string ) / 2 SAY string COLOR 'W+/B'
        aDir2 := {}
        aEval( aDir, {| x | aadd( aDir2, PADR( UPPER( x[1] ), 12 ) + ' ' + ;
                                         PADL( STR( x[2] ), 10 )   + ' ' + ;
                                         DTOC( x[3] ) + ' ' + x[4] ) } )
        x := nOpt
        nOpt := dfWar( 6, 20, 19, 60, aDir2,.F.,"BG+/B","gr+/r" )
        IF !EMPTY( nOpt )
            fClose( nHandle )
            cFileToView := aDir[ nOpt ][1]
            */
            IF !NewFile( cFileToView, @nFilePtr, @nHandle, ;
                         @nFileSize, @nFileLast )
               RESTSCREEN( 0, 0, MAXROW(), MAXCOL(), cScreen )
               Alert( cFileToView +"  File Open Error!!" )
               RETURN NIL
            ENDIF
            @ 0,  1 SAY 'File: ' + ;
                        PADR( Upper( IF( LEN( cFileToView ) < 16, ;
                        cFileToView, ".." + ;
                        Right( cFileToView, 13 ) ) ), 15 ) COLOR 'N/W'
            @ 0, 23 SAY TRANSFORM( nFileSize / 1024, "999,999" ) + ;
                        ' Kb' COLOR 'N/W'
            @ 0, 35 SAY TRANSFORM( nFileSize, "9,999,999,999") + ;
                        ' bytes' COLOR 'N/W'
            @ 0, 55 SAY DTOC( aDir[ 1, 3 ] ) + ' ' + ;
                        aDir[ 1 ][4] COLOR 'N/W'
                        /*
        ELSE
            nOpt := x
        ENDIF
        */

   otherwise
      loop

   endcase

   fillarray( nFilePtr )
   hex_disp( nFilePtr, nFileSize )

enddo

fclose( nHandle )

RESTSCREEN( 0, 0, MAXROW(), MAXCOL(), cScreen )

PARM := cFileToView
NACTUAL := 1
NOFFSET := 1

return NIL

*!**************************************************************************
*!
*!       Function: FILLARRAY()
*!
*!**************************************************************************
static function fillarray( nFilePtr )

static cBuffer := ''

local y, x, cHex, n, xlen
local cVisable, bytesread
local nNumRows := nMaxRow - 4

if len( cBuffer ) <> nBuffLen1
   cBuffer := space( nBuffLen1 )
endif

fseek( nHandle, nFilePtr, FS_SET )

bytesread := fXorread( nHandle, @cBuffer, nBuffLen1 )

if bytesread <> nBuffLen1
   cBuffer := left( cBuffer, bytesread )
endif

for x := 0 to nNumRows
   n := x + 1

   xlen := (x*nRowLen)

   cVisable := substr( cBuffer, xlen+1, nRowLen )
   aDisp[n][2] := LEN( cVisable )
   cHex := ''

   if !lFull && if not in full screen mode
       cHex := bin2hex( pad( left( cVisable, 8 ), 8 ) ) + '  ' + ;
               bin2hex( pad( substr( cVisable, 9, 8 ), 8 ) ) + ' '
   endif

   aDisp[n][1] := dfLong2hex(nFilePtr+xlen) + ;
                  ': ' + iif( !lFull, cHex + '  ', '' ) + ;
                  pad( cVisable, nRowLen ) + ' '
next

return NIL

*!**************************************************************************
*!
*!       Function: HEX_DISP()
*!
*!**************************************************************************
static function hex_disp( nFilePtr, nFileSize, lLast, lFirst )

local x, n, lShowedEof := .f., nEol
local nLastRow := nMaxRow - 3
local nStart := 1

//DISPBEGIN()

IF lLast==TRUE
   nStart := nLastRow
ENDIF

IF lFirst==TRUE
   nLastRow := nStart
ENDIF

for x := nStart to nLastRow
   n := x + 1

   do case
   case aDisp[x][2] == nRowLen
      @ n, 1 say aDisp[x][1]

   case aDisp[x][2] == 0
      if lShowedEof
         @ n, 1 clear to n, 78
      else
         @ n, 1 say aDisp[x][1]
         @ n, 11 say '<EOF>' color 'GB+/B*'
         @ n, 16 clear to n, 78
         lShowedEof := .t.
      endif

   case lFull .and. aDisp[x][2] < nRowLen
      @ n, 1 say aDisp[x][1]
      if !lShowedEof
         nEol := 11 + aDisp[x][2]
         @ n, nEol say '<EOF>' color 'GB+/B*'
         @ n, nEol + 5 clear to n, 60
         lShowedEof := .t.
      endif

   case aDisp[x][2] < 8
      @ n, 1 say aDisp[x][1]
      if !lShowedEof
         nEol := 11 + ( aDisp[x][2] * 3 )
         @ n, nEol say '<EOF>' color 'GB+/B*'
         @ n, nEol + 5 clear to n, 60
         lShowedEof := .t.
      endif

   case aDisp[x][2] < 16
      @ n, 1 say aDisp[x][1]
      if !lShowedEof
         nEol := 12 + ( aDisp[x][2] * 3 )
         @ n, nEol say '<EOF>' color 'GB+/B*'
         @ n, nEol + 5 clear to n, 60
         lShowedEof := .t.
      endif
   endcase

   @ n, 79 say chr( 219 ) color 'W/N'

next

@ ( ( nFilePtr / nFileSize ) * nLastRow ) + 2, 79 say chr( 254 ) color 'GB+/W'

//DISPEND()

return NIL

*!**************************************************************************
*!
*!       Function: CNT()
*!
*!**************************************************************************
static function cnt( cString, nRow )

cString := alltrim( cString )

@ nRow, ( 79 - len( cString ) ) / 2 say cString COLOR 'N/W'

return NIL

*!**************************************************************************
*!
*!       Function: MYSEARCH()
*!
*!**************************************************************************
static function MySearch( nPtr, nFileSize, nFileLast, cSrch)

local nLen := LEN( cSrch )
local cBuffer, nTmp, nRead, nFound, nFilePtr := 0, nKey := K_F3

nPtr := fseek( nHandle, nPtr, 0 )

While .T.
  nTmp := nPtr
  cBuffer := SPACE( BUFFLEN2 )
  nRead := fXorread( nHandle, @cBuffer, BUFFLEN2 )
  While ( nFound := AT( cSrch, UPPER( cBuffer ) ) ) > 0
     nTmp += nFound - 1
     @ 0, 60 Say "Found at :" +dfLong2Hex( nTmp ) Color "B/W"
     nFilePtr := MIN( nFileLast, INT( nTmp / nRowLen ) * nRowLen )
     fillarray( nFilePtr )
     hex_disp( nFilePtr, nFileSize )
     If ( nKey := Inkey( 0 ) ) != K_F3
        EXIT
     Endif
     cBuffer := SUBSTR( cBuffer, nFound + nLen )
     nTmp += nLen
  End
  If nRead < BUFFLEN2 .OR. nKey != K_F3
     EXIT
  Endif
  Fseek( nHandle, -nLen + 1, 1 )
  nPtr := fseek( nHandle, 0, 1 )
End

Return nFilePtr

*!**************************************************************************
*!
*!       Function: USAGE()
*!
*!**************************************************************************
STATIC FUNCTION NewFile( cFileToView, nFilePtr, nHandle, nFileSize, nFileLast )

nFilePtr := 0

IF ( nHandle := F_fopen( cFileToView, FO_SHARED ) ) < 0
    RETURN .F.
Endif

nFileSize := fseek( nHandle, 0, FS_END )
nFileLast := nFileSize - ( nFileSize % nRowLen )
nFileLast -= MIN( INT( nFileSize / nRowLen ), nMaxRow - 4 ) * nRowLen

RETURN .T.
*!**************************************************************************
*!
*!       Function: header()
*!
*!**************************************************************************
static function header( lFull )

if lFull
    @ 1, 11 SAY "0123456789ABCDEF0123456789ABCDEF" + ;
                "0123456789ABCDEF0123456789ABCDEF   " color 'N/W'
ELSE
    @ 1, 11 SAY "00 01 02 03 04 05 06 07 " + ;
                " 08 09 0A 0B 0C 0D 0E 0F   0123456789ABCDEF" color 'N/W'
ENDIF

return NIL
