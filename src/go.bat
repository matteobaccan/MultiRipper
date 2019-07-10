..\gentoday\gentoday

harbour.exe mrip.prg HEXVIEW.PRG CHKMORE.PRG fexpand.prg bav.prg WININFO.prg EXELIB.prg library.prg _bin2ans.prg /n /W /I..\ /gc0

del ..\build\*.c
move *.c ..\build
copy *.lnk ..\build
cd ..\build

bcc32 /TP mrip.c @obj.lnk _bin2ans.c library.c BAV.c CHKMORE.c EXELIB.c fexpand.c HEXVIEW.c WININFO.c

cd ..\src
