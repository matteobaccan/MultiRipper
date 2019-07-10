#include "common.ch"
_3dalert(  ,  ,  ,  ,{"úÄÍþ³’ïþÍÄú","of","TWT","Proudly","Presents"})
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION _3dalert(y1,x1,y2,x2,aMessage,cColBox,cColup,cColdown,cColMes,cColbut,aBut  )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
local sav
local counter:=0
default amessage to {""}
default aBut to {"Ok"}
default y1 to (maxrow()/2)-(len(amessage)/2)-2
default y2 to (maxrow()/2)+(len(amessage)/2)+3
default x1 to (maxcol()/2)-10
default x2 to (maxcol()/2)+10
default cColBox  to "bg+/r"
default cColup   to "w+/r"
default cColdown to "n/r"
default cColMes  to "w+/r"
default cColBut  to "w+/B"
sav:=savescreen(y1,x1,y2+2,x2+2)
dfpushcursor()
setcursor(0)
dfShade( y1,x1,y2,x2 )
dfSayBox( y1,x1,y2,x2, cColup, cColdown, cColBox )
setcolor(cColMes)
aeval( aMessage,{|scritta| counter++,;
                           devpos( y1+1+counter,(maxcol()/2-len(scritta)/2) ),;
                           devout(scritta) } )

setcolor( cColBut )
devpos(y2-2,(maxcol()/2)-(len(abut[1])+4)/2)
devout ( "[ "+abut[1]+" ]" )

inkey(0)

dfpopcursor()
restscreen(y1,x1,y2+2,x2+2,sav)
RETURN NIL

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION alert(  )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

RETURN NIL
