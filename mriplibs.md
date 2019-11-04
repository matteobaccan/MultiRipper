<pre>
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
▒    ▒ ▒▒ ▒   ▒▒ ▒▒▒ ▒    ▒   ▒▒   ▒▒▒   ▒   ▒▒   ▒ ▒▒ ▒ ▒▒    ▒   ▒▒  ▒▒  ▒  ▒
▓▓▓▓ ▓ ▓▓ ▓ ▓▓▓▓ ▓▓▓ ▓ ▓▓ ▓ ▓▓ ▓ ▓▓ ▓▓ ▓▓▓ ▓▓ ▓ ▓▓▓ ▓▓ ▓ ▓▓▓▓▓ ▓ ▓▓▓ ▓▓ ▓ ▓ ▓ ▓
████ █ ██ █ ████ █ █ █ ██ █ ██ █ ███ █ ███ █ ██ ███ ██ █ █████ █ ███ ██ █ █ █ █
    ░ ░░░░ ░░░  ░ ░ ░ ░  ░ ░  ░ ░   ░ ░░░ ░ ░░ ░░░ ░  ░ ░     ░ ░░░ ░░░░ ░ ░ ░
    ▓ ▓  ▓ ▓    ▓ ▓ ▓ ▓  ▓ ▓  ▓ ▓   ▓ ▓   ▓  ▓ ▓   ▓  ▓ ▓     ▓ ▓   ▓  ▓ ▓   ▓
    █ █  █ ███  ██ ██ ████ █  █ ████  ███ █  █ █   ████ ███   █ ███ █  █ █   █
≡≡≡≡▒≡▒≡≡▒≡▒▒▒≡≡▒▒≡▒▒≡▒▒▒▒≡▒≡≡▒≡▒▒▒▒≡≡▒▒▒≡▒≡≡▒≡▒≡≡≡▒▒▒▒≡▒▒▒≡≡≡▒≡▒▒▒≡▒≡≡▒≡▒≡≡≡▒≡
====▒=▒▒▒▒=▒====▒=▒=▒=▒==▒=▒==▒=▒===▒=▒===▒==▒=▒===▒==▒=▒=====▒=▒===▒▒▒▒=▒===▒=
----▒-▒--▒-▒▒---▒-▒-▒-▒--▒-▒--▒-▒---▒-▒▒--▒-▒--▒▒▒-▒--▒-▒-----▒-▒▒--▒--▒-▒-▒-▒-
-▒▒▒▒-▒--▒-▒▒▒--▒---▒-▒▒▒▒-▒▒▒--▒▒▒▒--▒▒▒-▒▒▒▒-▒▒▒-▒--▒-▒--▒▒▒▒-▒▒▒--▒▒--▒▒-▒▒-
···············································································

                              Library Structures
                         Figured out by IAN of T(/\)T
                                 Revision 2.1
                                 jan 31, 2000

 This document has been written only because there isn't any about these
 structures... and writing down things helps remembering them!!

 Use these informations in any way you want, e.g. make your own ripper,
 like I have done (MultiRipper 2.80 already extract these!)

 Libraries are found on EXE files ,tipically on demos.
 These files are made of several files linked together to form a single EXE.
 The main program searches every part needed inside itself using an index,
 made at least with names and lengths of every single file that forms the
 main EXE.
 Sometimes library are not linked to the main EXE but are separate huge
 data files, actually containing all necessary files. In demos this is
 quite unused, I found only few ones using external libs, and they're almost
 older versions of the EXE type libs. External libs are mostly found on games
 like DOOM and DARK FORCES (ever heard of *.WAD files???)
 Well, not surprisingly, also these external libs contain an index.
 The structure of this index, the Lib structure index, can also be used to
 rip off the single files.
 Unluckily, not all structures all identical, but there are few programmers
 that make standard libraries to reduce the hassle of linking demoparts
 together , so they're quite easy to decode...

 Lib Structures described in this document: (33)

 1)  Future Crew Lib
 2)  Realtech Lib (EXE)
 2a) Realtech Lib (DAT)
 3)  Psychic Link FLIB
 4)  ElectroMotive Force LIB
 5)  The Coexistence XLink 2.02
 6)  The Coexistence XLink 1.0
 7)  Pelusa Resource Compiler 0.1ß
 8)  ACME Virtual File System 1.0ß
 9)  LucasArts GOB files
 10) iD Software WAD files
 11) Cascada Resource file
 12) Iguana Lib
 13) 3DRealms GRP (Duke Nukem)
 14) Japotek Lib
 15) Digital Underground DfMake
 16) Champ Programming Library
 17) Deathstar CLAUDIA DEMO
 18) Frost installer
 19) Champ
 20) Quake map
 21) Chasm
 22) Coyote file library
 23) (B)ZIP file library (ASM98)
 24) FUSION file library (ASM98)
 25) PRIMITIVE file library (ASM98)
 26) TOUR file library (ASM98)
 27) Anonymous file library (ASM98)
 28) Bazar file library (Summer Encounter 98)
 29) LOUIS file library (Summer Encounter 98)
 30) Datalib file 1.0
 31) Japotek JPK Lib
 32) LABN Lib
 33) CRYO Lib


 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                          ┌─· ┌───────────────┐ ·─┐
                          ╘══[┤Future Crew Lib├]══╛
                              └───────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("Unreal" , "Panic" , "FishTro" , "The Party'92" tested)

Last 4 bytes in Future crew's (old) demos are an absolute offset;
if seeking to this offset there is "└/╚ " (C02FC800) we have a Future crew
library structure... and exactly:
---------------------------------------
0: Lib Header: (dWord) Magic C02FC800
4: # of records (dWord)
8: start of lib (dWord)
{ Record structure:
  Filename: 12 Bytes
  Filler  :  4 Bytes
  Start off  dWord (absolute offset)
  Length   dWord
} * # of records
start of header (dWord) , absolute offset in file
EOF




 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                     ┌─· ┌───────────────────────────┐ ·─┐
                     ╘══[┤Realtech Lib (in EXE files)├]══╛
                         └───────────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("DX Project" , "Aquaphobia" and "Countdown" tested )

Last 4 bytes in RealTech's Demos are a LIB dimension; seeking backwards
with this value will find "REALTECH95" (and now "REALTECH96" maybe...)
------------------
00h: Lib Magic "REALTECH95"
0Ah: "=" 03Dh (unknown)
0Bh: # of Records (Word)
0Dh: structure length (dWord) (from 00h to start of 1st file)
{ Record structure:
  Filename: 12 Bytes
  filler:    1 byte
  length:      dWord
} * # of Records
Start of file pointed by record #1
....
Start of last file
last4bytes  (lib off)
EOF

 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                     ┌─· ┌───────────────────────────┐ ·─┐
                     ╘══[┤Realtech Lib (in DAT files)├]══╛
                         └───────────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("Megamix" and "Dimension" tested)

The structure is the same but the file starts with "REALTECH94", so it's a
kinda older version of the EXE type (REALTECH95)
Please refer to the EXE type structure, assuming that lib magic is found
at offset 0 of file.



 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                         ┌─· ┌─────────────────┐ ·─┐
                         ╘══[┤Psychic Link FLIB├]══╛
                             └─────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("ACT1" and "Juice" tested)

Last 8 bytes in Psychic Link's Demos are a dWord + "FLIB"
This dWord is the # of Records , and every rec is 20h bytes long, so lib
start is (nRec*32)+8 bytes from EOF

{ Record structure:
  Filename: 12 Bytes
  filler:    4 bytes
  Start off  dWord (absolute offset)
  length     dWord
  Unknown    dWord
  Unknown    dWord
} * # of Records
# of Records
Lib Magic "FLIB"
EOF



 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                      ┌─· ┌───────────────────────┐ ·─┐
                      ╘══[┤ElectroMotive Force LIB├]══╛
                          └───────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("Verses" , "ASM95 InvTro" and "Caero" tested)

Last 12 bytes in EMF demos are 2 dWords + "EMF!"
The 1st dWord is the # of Records
The 2nd dWord is Abs offset of start of lib

{ Record structure:
  Filename: 12 Bytes
  filler:    4 bytes                        ┌
  Start off  dWord (absolute offset)────────┤not very accurate!!
  length     dWord                          │sometimes is 1 byte
  Filler     dWord                          │after realstart !!
  Unknown    dWord (Start off duplicate?)   │(at least in Verses)
} * # of Records                            └
# of Records
start of Lib abs Offset
Lib Magic "EMF!"
EOF



 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                     ┌─· ┌──────────────────────────┐ ·─┐
                     ╘══[┤The Coexistence XLink 2.02├]══╛
                         └──────────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("TC-BABES" (T.C.),"Groove" (Fudge),"Hurtless" (TFL-TDV),"BLUES" (sYmptom),
 "The Party 95" and many more tested)

First of all, this lib is NOT standard, but having thoughly tested it I can
surely admit it's the best available! (... actually it's the ONLY one
available because other Lib linkers have never been released!)

XLC 2.02 adds a standard loader of 2392 Bytes, already pklited+optimized
This loader can be unpacked without problems, so we cannot use fixed offsets.
If exelength varies from 2300 to 2800 (original=2392; max unpacked=2750)
is worth checking...
Overlay starts with "XLé    " (0x584C0282 0x00000000)
this is the header of lib (off 0)

Then a word indicates the # of records (nrec)
another word is the # of exes to be executed (nexe)

then at off 16 starts the encrypted part of lib.

Decompiling the loader we can see it allocates (nrec << 5 = nrec*32) bytes
then makes a simple decrypting using these instructions:

------------------------------------
           mov     cx,Number_of_rec
           shl     cx,5
           xor     bl,bl
           les     si,Encrypted_data

locloop::  sub     es:[si],bl
           inc     bl
           inc     si
           loop    locloop
------------------------------------

after (nrec*32) bytes, (nexe*0x8d) bytes are the executable names that are
executed and can be decrypted also, but we can skip this.

Then we have the complete Structure:

00 : 0x584C0282 ("XLé")  Start of lib
04 : 0x00000000
08 : # of records (1 word)
10 : # of exes    (1 word)
12 : header len?? (1 word) == 0x0010
14 : Unknown      (1 word)
16 : Begin of structure:
{ Filename: 12 Bytes  (1st entry: "_____XLC@SRT" -> EXE struct)
  filler:    4 bytes
  length     1 dWord  (1st entry: Pointer to EXE struct)
  Start off  1 dWord  (relative offset from Start of lib)
  Filler     2 dWords
} * # of Records
{ 0x8d bytes (seems to be fixed) of filenames+parameters
  Filename: 12 bytes
  filler 1 byte
  Parameters: (PASCAL) len+string

} * # of exes
Start of file pointed by record #2
....
EOF

 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                     ┌─· ┌─────────────────────────┐ ·─┐
                     ╘══[┤The Coexistence XLink 1.0├]══╛
                         └─────────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("Contagion" tested)

This lib is the Prototype of v2.02, and the structure is simplier...
Overlay starts with 0x584C0081 0x00000000
Then a word indicates the # of records (nrec)
another word is the # of exes to be executed (nexe)
there is no encryption like in 2.02
Then we have the complete Structure:

00 : 0x584C0081  Start of lib
04 : 0x00000000
08 : # of records (1 word)
10 : # of exes    (1 word)
12 : header len?? (1 word) == 0x0010
14 : Unknown      (1 word)
16 : Begin of structure:
{ Filename: 12 Bytes  (1st entry: "_____XLC@SRT" -> EXE struct)
  filler:    3 bytes
  length     1 dWord  (1st entry: Pointer to EXE struct)
  Start off  1 dWord  (relative offset from Start of lib)
} * # of Records
{ 0x8d bytes (seems to be fixed) of filenames+parameters
  Filename: 12 bytes
  filler 1 byte
  Parameters: (PASCAL) len+string

} * # of exes
Start of file pointed by record #2
....
EOF




 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                    ┌─· ┌─────────────────────────────┐ ·─┐
                    ╘══[┤Pelusa Resource Compiler 0.1ß├]══╛
                        └─────────────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("Fake Demo" tested)

Last 4 bytes in Pelusa demo are an absolute offset;
if seeking to this offset there is "REZ■" (52455AFE) we have a Pelusa Res.
library structure... and exactly:
---------------------------------------
0: Lib Header: (dWord) Magic 52455AFE
4: # of records (Word)
{ Record structure:
  Filename: 12 Bytes
  Filler  :  4 Bytes
  Start off  dWord (absolute offset)
  length     dWord
} * # of records
start of header (dWord) , absolute offset in file
EOF



 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                    ┌─· ┌─────────────────────────────┐ ·─┐
                    ╘══[┤ACME Virtual File System 1.0ß├]══╛
                        └─────────────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("BIG Deal","Bug-fixed","Peek-a-Boo" tested; "Bug-fixed" contains only
 encrypted files...)

ACME VFS is similar to Xlink. The Header is a loader of variable size, but
never exceeding 2050 bytes. However Overlay starts with some magic bytes:

1 dWord is the Lib offset  (Abs. offset)
1 Word  is the lib length  (in bytes)
1 dWord is the # of Records
and 3 bytes are the Lib Magic: "VFS"

The lib structure index is encrypted using this method:
------------------------------------------------------
        mov     cx,Number_of_rec
        les     si,Encrypted_data
        cld
@loop:
        push    cx

        mov     cx,0Eh       ; 1st 0Eh bytes = Offset + length
        mov     bl,56h       ; Encr. value
locloop_1:
        xor     es:[si],bl
        inc     si
        loop    locloop_1

        mov     cx,0Dh       ; 2nd 0Dh bytes = FileName
        mov     bl,9Dh       ; Encr. value
locloop_2:
        xor     es:[si],bl
        inc     si
        loop    locloop_2

        pop     cx
        loop    @loop
------------------------------------------------------

then we have the complete structure:

(loader)
00: Lib offset   1 dWord (Abs. offset)
04: lib length   1 Word  (in bytes)
06: # of Records 1 dWord
0A: Lib Magic "VFS"
[File #1]
....
[File #x]
{Lib Structure: (Record Len = Liblen / nRec = 27)
 Unknown    1 byte
 Start off  1 dWord (abs)
 Unknown    1 byte  (always 20h, maybe file attribute??)
 length     1 dWord
 Unknown    1 dWord (Maybe file date/time packed ???)
 Filename  12 Bytes
 filler     1 byte
} * # of Rec
EOF



 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                            ┌─· ┌─────────────┐ ·─┐
                            ╘══[┤LucasArts GOB├]══╛
                                └─────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

 ("Dark Forces" tested)

This is an external lib, files have always a *.GOB extension and at least
can be found in the game "Dark Forces" by LucasArts and his additional
level files.

File starts with Magic "GOB"+ LF and a dWord, the Lib Abs. offset
this is the complete structure:

0: Lib Magic: "GOB"+LF (474F4210)
4: Lib Offset (dWord)
[File #1]
....
[File #x]
# of records  (dWord) Pointed by Lib offset
{Lib Structure: (Record Len = 21)
 Start off  1 dWord (abs)
 length     1 dWord
 Filename  12 Bytes
}



 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                           ┌─· ┌───────────────┐ ·─┐
                           ╘══[┤iD Software WAD├]══╛
                               └───────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("Doom","Doom ][","Heretic","Rise of The Triad" tested)

The structure is defined in "The Unofficial DOOM Specs" (DMSPCS10.ZIP)
by Hank Leukart <ap641@cleveland.freenet.edu>
------------------------------------------------------------------------------
[.......]

The first twelve bytes of a Doom *.WAD file (in the shareware version it is
DOOM1.WAD, the registered version's is DOOM.WAD) are as follows:

Bytes 0 to 3 - contain the ASCII letters "IWAD" or possibly "PWAD"
Bytes 4 to 7 - contain a long integer which is the number of entries in the
"directory"
Bytes 8 to 11 - contain a pointer to the first byte of the "directory"

(Bytes 12 to the start of the directory contain object data)

The directory referred to is a list, located at the end of the WAD file,
which contains the pointers, lengths, and names of all the "objects" in the
WAD file. "Objects" means data structures such as item pictures, enemies'
pictures (frames), floor and ceiling textures, wall textures, songs, sound
effects, map data, and many others.

For example, the first 12 bytes of the shareware DOOM1.WAD file are:

49 57 41 44 f6 04 00 00 6b e5 3f 00

This is "IWAD", then 4f6 hex (=1270 decimal) for # of directory entries, then
3fe56b (=4187500 decimal) for the first byte of the directory.

Each directory entry is 16 bytes long (10 hex), arranged this way:

First four bytes: pointer to start of object (a long integer)
Next four bytes: length of object (another long integer)
Last eight bytes: name of object, ending with 00s if not eight bytes.

[.......]
------------------------------------------------------------------------------

I must add that if "length of object" is 0 , as in "E1M1" etc. entries, this
object has to be skipped, since it's only a label indicating which level is
defined hereby.
Other skippable objects include shortest ones (sprites names= 8 bytes)
and some entries that have both length and start = 0 (found at least in
"Rise of the Triad")

00: Lib Magic  (dWord) "IWAD" or "PWAD"
04: # of Recs  (dWord)
08: Lib Offset (dWord)
[Files]
{ Start   :  1 dWord
  length  :  1 dWord
  Filename:  8 bytes
} * # of Recs



 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                        ┌─· ┌────────────────────┐ ·─┐
                        ╘══[┤Cascada VRS Resource├]══╛
                            └────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("Holistic" tested )

This is an external Lib. File starts with "CDADAT" +00h +00h and a dWord
indicating the # of recs.

This is the structure:

00: Lib Magic  (qWord) (4344414441540000)
08: # of Recs  (dWord)
{ Filename: 12 bytes
  Filler  :  4 bytes
  Start   :  1 dWord
  length  :  1 dWord
} * # of Recs



 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                             ┌─· ┌──────────┐ ·─┐
                             ╘══[┤Iguana LIB├]══╛
                                 └──────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("HeartQuake" (Iguana demo) "Speed Haste" (Game by Jare/Iguana) tested)

This type of lib is equvalent in EXE or DAT files
Last 16 bytes contain these bytes:
1 dWord is the Lib Magic "ë┤s▀" or 0x89B473DF
2 dWords (containing the same value) are the Number of records
1 dWord is the Start of Lib Relative offset

This is the complete structure:

[Loader]  <───>if EXE file
[Files]
LibStart
{ FileName: 12 bytes
  Filler  : 12 bytes
  Off     :  1 dWord Seek Back Off Bytes from Libstart to reach FileStart
  Length  :  1 dWord
} * # of Recs
Lib Magic    1 dWord
# of Recs    1 dWord <┐
# of Recs    1 dWord <┴─> The same values
LibOff       1 dWord Seek Back LibOff Bytes from EOF to reach LibStart
EOF



 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                     ┌─· ┌─────────────────────────┐ ·─┐
                     ╘══[┤3DRealms GRP (Duke Nukem)├]══╛
                         └─────────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("Duke Nukem 3D" both Shareware & Registered Tested)

This is a DAT Lib , similar to Doom WADs.
In the registered version there's an editor to make you own GRPs.

00: Lib Magic "KenSilverman" (12 Bytes)
0C: # of records (1 dWord)
{Record structure:
 FileName: 12 bytes
 Length  :  1 dWord
} * # of Recs
[file#1]
...
[file#x]
EOF

 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                             ┌─· ┌───────────┐ ·─┐
                             ╘══[┤Japotek LIB├]══╛
                                 └───────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("Fighting 4 Something" Tested)

Last 12 bytes contain these values:

1 dWord Lib Magic#1 "JPK0"
1 dWord StartLib absolute Offset
1 dWord (Filler?)

Seeking to StartLib we find:

1 dWord Lib Magic#2 "JDIR"
1 dWord # of records
1  Word (filler)

then the complete structure is:

[Loader]
[Files]
...
StartLib: Lib Magic#2
#ofrecs + filler
{Record structure:
 FileName: 12 bytes
 Filler  :  1 byte
 Offset  :  1 dWord  Seek Back Off Bytes from EOF to reach FileStart
} * # of Recs
Lib Magic#1
StartLib Abs Off
filler
EOF




 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                     ┌─· ┌──────────────────────────┐ ·─┐
                     ╘══[┤Digital Underground DFMAKE├]══╛
                         └──────────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

DfMake is a Public Domain external lib maker.
This is part of the original document from the author of DFMAKE,
Alessandro Job (S0IOB@uduniv.cc.uniud.it)

┌─────────────────────────┬─────────────────────────────────────────────────
│ DATAFILE library format │
└─────────────────────────┘

    This is the format of a datafile file made by DFMAKE.
    All offsets are positive offsets from the end of the datafile.

    File START->┌───────────────────────┐
                │ First file            │
                │ ...                   │
                │ ...                   │
                ├───────────────────────┤
                │ Second file           │
                │ ...                   │
                │ ...                   │
                ├───────────────────────┤
                │ ...                   │
                │ ...                   │
                │ ...                   │
                ├───────────────────────┤
                │ Nth file              │
                │ ...                   │
                │ ...                   │
                ├───────────────────────┤
    NFILES----->│ 2 BYTES               │
                │ Number of files in lib│
                ├───────────────────────┤
                │ 21 BYTES              │
                │ First file header     │
                │                       │
                │ 13 BYTES: file name   │
                │ 4 BYTES:  offset from │
                │           end of file │
                │ 4 BYTES:  file lenght │
                ├───────────────────────┤
                │ Second file header    │
                │ ...                   │
                │ ...                   │
                ├───────────────────────┤
                │ Nth file header       │
                │ ...                   │
                │ ...                   │
                ├───────────────────────┤
                │ 4 BYTES               │
                │ NFILES offset from end│
                │ of file               │
                ├───────────────────────┤
                │ 4 BYTES               │
                │ "DATA" signature      │
    File END--->└───────────────────────┘



 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                      ┌─· ┌─────────────────────────┐ ·─┐
                      ╘══[┤Champ Programming Library├]══╛
                          └─────────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

 This is a DAT library... found by Softwizard...


 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                       ┌─· ┌──────────────────────┐ ·─┐
                       ╘══[┤Deathstar CLAUDIA DEMO├]══╛
                           └──────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

 This is a DAT library... found by Softwizard...

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

                       ┌─· ┌──────────────────────┐ ·─┐
                       ╘══[┤   Frost installer    ├]══╛
                           └──────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

 This is an'installer library... found by Softwizard...

00: Lib Magic "TPAC1.6" (9 Bytes)
0A: some records with this structure
{Record structure:
 FileLen :  1 byte
 FileName: 12 bytes
 Length  :  1 dWord
 [file#1]
} * # of Recs
EOF


 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

                       ┌─· ┌──────────────────────┐ ·─┐
                       ╘══[┤      Quake map       ├]══╛
                           └──────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

00: Lib Magic "QMAP" (4 Bytes)
...
12: 1 dWord : Count
{Record structure:
 Position : 4 bytes
}

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*


                       ┌─· ┌──────────────────────┐ ·─┐
                       ╘══[┤        Chasm         ├]══╛
                           └──────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

00: Lib Magic "CSid" (4 Bytes)
04: 1 Word : Chunk number
{Record structure: 21 bytes
  Name : 12 byte from position 2
  Size : 4  byte from position 14
  Pos  : 4  byte from position 18
}

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

                       ┌─· ┌─────────────────────┐ ·─┐
                       ╘══[┤ Coyote File Library ├]══╛
                           └─────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("Nature - Vertigo" tested)

00: Lib Magic "COYOTE FILE LIBRARY " (20 Bytes)
14: 1 Word : ????????
18: 1 Word : ????????
{Record structure: 40 bytes Xored with 255
  Sig  : 19 bytes file signature "COYOTE PACKED FILE"
  Name : 13 bytes
  Size : 4  bytes
  ???? : 4  bytes
  ???? : Cripted file.
}

Coyote use this cripting method. Get the byte in 4 bytes group and change the
order in this way

  Byte 1  Position 4
  Byte 2  Position 3
  Byte 3  Position 2
  Byte 4  Position 1

For example "Matteo Baccan   " is changed in "ttaMB eoacca   n"

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

                       ┌─· ┌─────────────────────┐ ·─┐
                       ╘══[┤ (B)ZIP File Library ├]══╛
                           └─────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("Sexadelic (final release version, v2.0) - Byterapers, Inc." tested)

00: Lib Magic "(B)ZIP" (6 Bytes)
0B: Record count (4 Bytes)
{Record structure: 48 bytes starting from byte 0x0010
  Name : 32 bytes
  Pos  : 4  bytes
  Size : 4  bytes
  Size : 4  bytes
}

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

                       ┌─· ┌─────────────────────┐ ·─┐
                       ╘══[┤ FUSION File Library ├]══╛
                           └─────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("Fusion - Bad Karma" tested)

00: Number of files (4 Bytes)
{Record structure: 32 bytes starting from byte 0x0004
  Name : 20 bytes
  Pos  : 4  bytes
  Size : 4  bytes
}

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

                     ┌─· ┌────────────────────────┐ ·─┐
                     ╘══[┤ PRIMITIVE File Library ├]══╛
                         └────────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("i want to believe - primitive" tested)

00: Number of files (4 Bytes)
{Record structure: 20 bytes starting from byte 0x0004
  Name : 16 bytes
  Size : 4  bytes
}

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

                        ┌─· ┌───────────────────┐ ·─┐
                        ╘══[┤ TOUR File Library ├]══╛
                            └───────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("tour - pulse" tested)
("Vague Space - cncd" tested)

{Record structure: 24 bytes starting from byte 0x0000
  ????          : 4 bytes
  Size          : 4 bytes
  NameSize      : 4 bytes
  PosFile       : 4 bytes
  PosFileName+1 : 4 bytes
  PosNext       : 4 bytes - this is FF FF FF FF if the file is the last
}

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

                      ┌─· ┌────────────────────────┐ ·─┐
                      ╘══[┤ Anonymous File Library ├]══╛
                          └────────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("ANONYMOUS - CHEAT THE MACHINE" tested)

00: Lib Magic "CTMLIB1" (7 Bytes)
{Record structure: 64 bytes starting from 0x0009
  Name : 52 bytes
  Pos  : 4  bytes
  Size : 4  bytes
  ???? : 4  bytes
}

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

                        ┌─· ┌────────────────────┐ ·─┐
                        ╘══[┤ BAZAR File Library ├]══╛
                            └────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("BAZAR - IMPACT DK" tested)

{Record structure: 28 bytes starting from 0x0000
  ???? : 4  bytes
  ???? : 4  bytes
  Size : 4  bytes
  Name : 16 bytes
}

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

                        ┌─· ┌────────────────────┐ ·─┐
                        ╘══[┤ LOUIS File Library ├]══╛
                            └────────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

("LOUIS - blasphemy" tested)

The file ends with these bytes "OYZO" // 4F 59 5A 4F

{Record structure: 21 bytes starting from the end of file - 21 bytes
  Name : 13 bytes
  Size : 4  bytes    // Last record have the number of record without last
  Pos  : 4  bytes    // Last record have "OYZO" in the pos
} //

NB
  The file that you find is cripted with a XOR of 0x02A

 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                          ┌─· ┌────────────────┐ ·─┐
                          ╘══[┤Datalib file 1.0├]══╛
                              └────────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

(Found on "SEX 2" and others Japanese Hentai games)

This is a DAT type library.

00: Lib Magic "<< dlb file Ver1.00>>"+0x00 (22 bytes)
17: # of records (Word)
{ Record structure:
  Filename: 12 Bytes NULL terminated and padded with garbage (ignored)
  Startoff:  1 dWord (absolute offset)
  Length  :  1 dWord
} * # of records
[File 1]
...
[File nrec]
EOF

 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                          ┌─· ┌───────────────┐ ·─┐
                          ╘══[┤Japotek JPK Lib├]══╛
                              └───────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

(Found on "The Eternal Game" TRiP '999 The Real Italian Party)


 *■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■*

                           ┌─· ┌────────────┐ ·─┐
                           ╘══[┤LABN library├]══╛
                               └────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

00: Lib Magic "LABN" (4 bytes)


 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

                           ┌─· ┌────────────┐ ·─┐
                           ╘══[┤CRYO library├]══╛
                               └────────────┘

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

No lib magic

{Record of 40 byte
 Name : 32 bytes
 Size :  4 bytes
 Pos  :  4 bytes
}

 *■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■▀■▄■*

                             __ __ "
                               )  ) /
                              /  /  \

                              tsuduku

                          (to be continued)

****** End of Text ******
</pre>
