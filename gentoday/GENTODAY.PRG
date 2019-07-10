#xtranslate ntrim( <x> ) => alltrim(str( <x> ))
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION gen_today_ch(  )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
local x:=fcreate("TODAY.CH")
local mese:= cmonth(date())
local giorno:=day(date())
local gsett:=cdow(date())
local ordinal:=""
local ora:=time()
local cbuff:=""
do case
   case giorno = 1 .or. giorno = 21 .or. giorno = 31
        ordinal:= "st"
   case giorno = 2 .or. giorno = 22
        ordinal:= "nd"
   case giorno = 3 .or. giorno = 23
        ordinal:= "rd"
   otherwise
        ordinal:= "th"
endcase
cbuff:="#define _COMPILE_DATE_ 'Compiled on "+gsett+", "+mese+" "+ntrim(giorno)+ordinal+", "+ntrim(Year(date()))+"'"
fwrite(x,cbuff)
fclose(x)

RETURN NIL

