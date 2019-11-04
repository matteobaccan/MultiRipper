/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³                                                                      ³
   ³                  (C) 2000 by TWT The Wonderful Team                  ³
   ³                                                                      ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

#ifndef _MRIPPER_CH
   #define _MRIPPER_CH

   #define RIPVERSION   "3.01"

   #define FLUSHCACHE
   #define _2_CH0    chr(0)+chr(0)
   #define _3_CH0    chr(0)+chr(0)+chr(0)
   #define MPEGPATT  chr(0)+chr(0)+chr(1)+chr(179)+chr(10)
   #define TGA1PATT  chr(0)+chr(1)+chr(1)+chr(0)+chr(0)+chr(0)+chr(1)+chr(24)+chr(0)+chr(0)+chr(0)+chr(0)
   #define TGA2PATT  chr(0)+chr(0)+chr(2)+chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(0)
   #define CRLFEOFLF chr(13)+chr(10)+chr(26)+chr(10)
   #define EMAIL     "matteo@baccan.it"

   #define ARRCHOICE     aStaticone[1]
   #define NAMECOUNT     aStaticone[2]
   #define OLDSCREEN     aStaticone[3]
   #define PROCESS_ALL   aStaticone[4]
   #define BIG_DONE      aStaticone[5]
   #define BIG_WARN      aStaticone[6]
   #define BIG_ERROR     aStaticone[7]
   #define BIG_BREAK     aStaticone[8]
   #define NACTUAL       aStaticone[9]
   #define NOFFSET       aStaticone[10]
   #define PARM          aStaticone[11]
   #define EXTPATH       aStaticone[12]
   #define AFILE2EXT     aStaticone[13]
   #define FCHECKMORE    aStaticone[14]
   #define FBATCH        aStaticone[15]
   #define FFLUSH        aStaticone[16]
   #define PTRFILENAME   aStaticone[17]
   #define FALSEALARM    aStaticone[18]
   #define START_POS     aStaticone[19]
   #define ALTMEM        aStaticone[20]
   #define ISTHESAME     aStaticone[21]
   #define MINI_LOGO     aStaticone[22]
   #define OLDBLINK      aStaticone[23]
   #define OUTDEBUG      aStaticone[24]
   #define OLDPTR        aStaticone[25]
   #define HLOG          aStaticone[26]
   #define ARRLIBS       aStaticone[27]
   #define STRINGPOS     aStaticone[28]
   #define MULTIFONT     aStaticone[29]
   #define XORPATTERN    aStaticone[30]
   #define FASTSCAN      aStaticone[31]
   #define FBATCHFAST    aStaticone[32]
   #define TOTCOUNTER    aStaticone[33]
   #define SKIPIFLIB     aStaticone[34]
   #define BUFLEN        aStaticone[35]
   #define FILEMASK      aStaticone[36]
   #define RECOURSE      aStaticone[37]
   #define LOCCOUNTER    aStaticone[38]
   #define EXPAND        aStaticone[39]
   #define PACKLIST      aStaticone[40]
   #define FILELIST      aStaticone[41]
   #define AFILE2DEL     aStaticone[42]
   #define DEHACKSTOP    aStaticone[43]
   #define HACKSTOPERASE aStaticone[44]
   #define GENERICDUMP   aStaticone[45]
   #define GENPATH       aStaticone[46]
   #define MASTERFORMAT  aStaticone[47]
   #define ARESOURCE     aStaticone[48]
   #define DELPHIVERBOSE aStaticone[49]
   #define DELPHISOURCE  aStaticone[50]
   #define DELPHIMETHODS aStaticone[51]
   #define REGISTRATION  aStaticone[52]
   #define SERIAL        aStaticone[53]
   #define SERTYPE       aStaticone[54]
   #define TWEAKED80X50  aStaticone[55]
   #define INTROOUT      aStaticone[56]

   #define CRLF      chr(13)+chr(10)

   #include "inkey.ch"
   #include "fileio.ch"
   #include "common.ch"
   #include "directry.ch"
   #include "today.ch"
   #include "dfexetyp.ch"
   #include "dfSet.ch"
   #include "Wininfo.ch"

   #define BCC3_F1      CHR(16*15+1)
   #define BCC3_F2      CHR(16*15+2)

#endif
