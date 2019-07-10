/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³                                                                      ³
   ³                  (C) 2000 by TWT The Wonderful Team                  ³
   ³                                                                      ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

#ifndef _WININFO_CH
   #define _WININFO_CH
   // From windows.h

   #define MAKEINTRESOURCE(a)      dfHex2Dec("8000")+a // 32768

   #define RT_CURSOR               MAKEINTRESOURCE(1)  // 32769
   #define RT_BITMAP               MAKEINTRESOURCE(2)  // 32770
   #define RT_ICON                 MAKEINTRESOURCE(3)  // 32771
   #define RT_MENU                 MAKEINTRESOURCE(4)  // 32772
   #define RT_DIALOG               MAKEINTRESOURCE(5)  // 32773
   #define RT_STRING               MAKEINTRESOURCE(6)  // 32774
   #define RT_FONTDIR              MAKEINTRESOURCE(7)  // 32775
   #define RT_FONT                 MAKEINTRESOURCE(8)  // 32776
   #define RT_ACCELERATOR          MAKEINTRESOURCE(9)  // 32777
   #define RT_RCDATA               MAKEINTRESOURCE(10) // 32778
   #define RT_MESSAGETABLE         MAKEINTRESOURCE(11)
   #define RT_GROUP_CURSOR         MAKEINTRESOURCE(12) // 32780
   #define RT_GROUP_ICON           MAKEINTRESOURCE(14) // 32782
   #define NAMETABLE               MAKEINTRESOURCE(15) // 32783
   #define RT_VERSION              MAKEINTRESOURCE(16) // 32784
   #define RT_DLGINCLUDE           MAKEINTRESOURCE(17)
   #define RT_PLUGPLAY             MAKEINTRESOURCE(19)
   #define RT_VXD                  MAKEINTRESOURCE(20)
   #define RT_ANICURSOR            MAKEINTRESOURCE(21)
   #define RT_ANIICON              MAKEINTRESOURCE(22)

   #define PE_RES_0                 0
   #define PE_CURSOR                1
   #define PE_BITMAP                2
   #define PE_ICON                  3
   #define PE_MENU                  4
   #define PE_DIALOG                5
   #define PE_STRING                6
   #define PE_FONTDIR               7
   #define PE_FONT                  8
   #define PE_ACCELERATORS          9
   #define PE_RCDATA               10
   #define PE_MESSAGETABLE         11
   #define PE_GROUP_CURSOR         12
   #define PE_RES_13               13
   #define PE_GROUP_ICON           14
   #define PE_RES_15               15
   #define PE_VERSION              16

   #define VK_LWIN                 dfHex2Dec("5B")
   #define VK_RWIN                 dfHex2Dec("5C")
   #define VK_APPS                 dfHex2Dec("5D")

   #define VK_LBUTTON              dfHex2Dec("01")
   #define VK_RBUTTON              dfHex2Dec("02")
   #define VK_CANCEL               dfHex2Dec("03")
   #define VK_MBUTTON              dfHex2Dec("04")
   #define VK_BACK                 dfHex2Dec("08")
   #define VK_TAB                  dfHex2Dec("09")
   #define VK_CLEAR                dfHex2Dec("0C")
   #define VK_RETURN               dfHex2Dec("0D")
   #define VK_SHIFT                dfHex2Dec("10")
   #define VK_CONTROL              dfHex2Dec("11")
   #define VK_MENU                 dfHex2Dec("12")
   #define VK_PAUSE                dfHex2Dec("13")
   #define VK_CAPITAL              dfHex2Dec("14")
   #define VK_ESCAPE               dfHex2Dec("1B")
   #define VK_SPACE                dfHex2Dec("20")
   #define VK_PRIOR                dfHex2Dec("21")
   #define VK_NEXT                 dfHex2Dec("22")
   #define VK_END                  dfHex2Dec("23")
   #define VK_HOME                 dfHex2Dec("24")
   #define VK_LEFT                 dfHex2Dec("25")
   #define VK_UP                   dfHex2Dec("26")
   #define VK_RIGHT                dfHex2Dec("27")
   #define VK_DOWN                 dfHex2Dec("28")
   #define VK_SELECT               dfHex2Dec("29")
   #define VK_PRINT                dfHex2Dec("2A")
   #define VK_EXECUTE              dfHex2Dec("2B")
   #define VK_SNAPSHOT             dfHex2Dec("2C")
   #define VK_INSERT               dfHex2Dec("2D")
   #define VK_DELETE               dfHex2Dec("2E")
   #define VK_HELP                 dfHex2Dec("2F")
   #define VK_NUMPAD0              dfHex2Dec("60")
   #define VK_NUMPAD1              dfHex2Dec("61")
   #define VK_NUMPAD2              dfHex2Dec("62")
   #define VK_NUMPAD3              dfHex2Dec("63")
   #define VK_NUMPAD4              dfHex2Dec("64")
   #define VK_NUMPAD5              dfHex2Dec("65")
   #define VK_NUMPAD6              dfHex2Dec("66")
   #define VK_NUMPAD7              dfHex2Dec("67")
   #define VK_NUMPAD8              dfHex2Dec("68")
   #define VK_NUMPAD9              dfHex2Dec("69")
   #define VK_MULTIPLY             dfHex2Dec("6A")
   #define VK_ADD                  dfHex2Dec("6B")
   #define VK_SEPARATOR            dfHex2Dec("6C")
   #define VK_SUBTRACT             dfHex2Dec("6D")
   #define VK_DECIMAL              dfHex2Dec("6E")
   #define VK_DIVIDE               dfHex2Dec("6F")
   #define VK_F1                   dfHex2Dec("70")
   #define VK_F2                   dfHex2Dec("71")
   #define VK_F3                   dfHex2Dec("72")
   #define VK_F4                   dfHex2Dec("73")
   #define VK_F5                   dfHex2Dec("74")
   #define VK_F6                   dfHex2Dec("75")
   #define VK_F7                   dfHex2Dec("76")
   #define VK_F8                   dfHex2Dec("77")
   #define VK_F9                   dfHex2Dec("78")
   #define VK_F10                  dfHex2Dec("79")
   #define VK_F11                  dfHex2Dec("7A")
   #define VK_F12                  dfHex2Dec("7B")
   #define VK_F13                  dfHex2Dec("7C")
   #define VK_F14                  dfHex2Dec("7D")
   #define VK_F15                  dfHex2Dec("7E")
   #define VK_F16                  dfHex2Dec("7F")
   #define VK_F17                  dfHex2Dec("80")
   #define VK_F18                  dfHex2Dec("81")
   #define VK_F19                  dfHex2Dec("82")
   #define VK_F20                  dfHex2Dec("83")
   #define VK_F21                  dfHex2Dec("84")
   #define VK_F22                  dfHex2Dec("85")
   #define VK_F23                  dfHex2Dec("86")
   #define VK_F24                  dfHex2Dec("87")
   #define VK_NUMLOCK              dfHex2Dec("90")
   #define VK_SCROLL               dfHex2Dec("91")

#endif
