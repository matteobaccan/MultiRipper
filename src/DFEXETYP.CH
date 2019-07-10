/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³                                                                      ³
   ³                  (C) 2000 by TWT The Wonderful Team                  ³
   ³                                                                      ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

#ifndef _DFEXETYPE_CH
   #define _DFEXETYPE_CH

/* ÚÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  ³Description                                                        ³
   ÃÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
   ³MZ³old-style DOS executable                                           ³
   ³NE³Windows or OS/2 1.x segmented ("new") executable                   ³
   ³LE³Windows virtual device driver (VxD) linear executable              ³
   ³LX³variant of LE used in OS/2 2.x                                     ³
   ³W3³Windows WIN386.EXE file; a collection of LE files                  ³
   ³PE³Win32/Windows NT/Win32s portable executable based on Unix COFF     ³
   ³DL³HP 100LX/200LX system manager compliant executable (.EXM)          ³
   ³MP³old PharLap .EXP                                                   ³
   ³P2³PharLap 286 .EXP                                                   ³
   ³P3³PharLap 386 .EXP                                                   ³
   ÀÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

   #define EXE_TYPE_UNKNOWN 0
   #define EXE_TYPE_MZ      1
   #define EXE_TYPE_NE      2
   #define EXE_TYPE_LE      3
   #define EXE_TYPE_LX      4
   #define EXE_TYPE_W3      5
   #define EXE_TYPE_PE      6
   #define EXE_TYPE_DL      7
   #define EXE_TYPE_MP      8
   #define EXE_TYPE_P2      9
   #define EXE_TYPE_P3     10

#endif
