   10 REM RasterMan example 4

   20 REM

   30 REM ** (c) 2017 Stephen A Harrison **

   40 :

   50 ON ERROR REPORT:PRINT" at line ";ERL:END

   60 :

   70 targetver=0.21

   80 :

   90 SYS"RasterMan_Version" TO ver:ver=ver/100

  100 IF ver<targetver OR ver>targetver THEN ERROR 255,"Incorrect version of RasterMan, this code may not be compatible"

  110 :

  120 REM set up default tables

  130 :

  140 PROCinitRMtables

  150 :

  160 REM change MODE

  170 :

  180 MODE 12

  190 :

  200 Vinit =%11011000000000000000000000

  201 Vstart=%11011000100000000000000000

  210 Vend=  %11011001000000000000000000

  220 :

  230 phys_scrstart=0           :REM MEMC uses physical memory addresses, screen start = 0

  240 phys_scrend  =640*256/2-16:REM MODE12 screen size                ...screen end   = 81920 (80k)

  250 :

  260 Vinit_reg=Vinit OR (phys_scrstart >> 2)

  261 Vstart_reg=Vstart OR (phys_scrstart >> 2)

  270 Vend_reg=Vend OR (phys_scrend >> 2)

  280 :

  290 REM prepare QTM after mode change (requires QTM v1.45 special edition)

  300 :

  310 SYS"QTM_SongStatus" TO stat :REM if not playing, switch on QTM so pitch recalc OK

  320 IF (stat AND %100)=0 THEN SYS"QTM_SoundControl",4,-1,-1

  330 :

  340 REM set up screen

  350 :

  360 COLOUR 11,&88,&00,&00

  370 COLOUR 12,&00,&88,&00

  380 COLOUR 13,&88,&88,&00

  390 COLOUR 14,&00,&00,&88

  400 GCOL 11:RECT FILL 0,0,320,1024

  410 GCOL 12:RECT FILL 320,0,320,1024

  420 GCOL 13:RECT FILL 640,0,320,1024

  430 GCOL 14:RECT FILL 960,0,320,1024

  440 VDU5

  450 FOR i=1 TO 75:MOVE RND(59*8*2),RND(32*8*4):GCOL(RND(8)-1):PRINT"RasterMan Mirror test":NEXT

  460 VDU4

  470 COLOUR 7

  480 GCOL 1:CIRCLE 640,512,320:CIRCLE 640,512,318

  700 :

  710 REM set up full mirrored MEMC table

  711 REM (remember to set Vinit if altering first line of screen!)

  720 :

  730 FOR i=0 TO 255

  740  y=255-i

  750  phys_thislinestart=(y)*(640/2)

  760  phys_thislineend=y*(640/2)+(640/2)-16

  770  :

  800  memctable!(i*8+0)=Vend OR (phys_thislineend >> 2)

  810  IF i=0 THEN memctable!(255*8+4)=Vinit OR (phys_thislinestart >> 2)

  811  IF i>0 THEN memctable!((i-1)*8+4)=Vstart OR (phys_thislinestart >> 2)

  820 NEXT

  851 :

  860 REM start RM

  870 :

  910 WAIT:WAIT:WAIT:WAIT:WAIT:WAIT :REM allow keyboard buffer to clear & QTM recalc

  920 ONERROR SYS"XRasterMan_Release":REPORT:PRINT" at line ";ERL:END

  930 SYS"RasterMan_Install"

  940 :

  950 PRINT''"RasterMan is running upside down!"

  960 PRINT'

  970 FOR I=0 TO 50*10

  980  SYS"RasterMan_Wait"

  990  IF (I MOD 50)=0 PRINTTAB(I/50,4);".";

 1000  PRINTTAB(40-LEN(STR$I)DIV2,16)STR$I

 1010 NEXT

 1020 :

 1030 REM exit RM

 1040 :

 1050 SYS"RasterMan_Release"

 1060 WAIT

 1061 SYS "RasterMan_SetMEMCRegister",Vinit_reg

 1070 SYS "RasterMan_SetMEMCRegister",Vstart_reg

 1080 SYS "RasterMan_SetMEMCRegister",Vend_reg

 1090 PRINT''"RasterMan stopped"

 1100 END

 1110 

 1120 

 1130 DEF PROCinitRMtables

 1140 PRINT"Initialising...";

 1150 :

 1160 DIM vidctable1 256*16   :REM  4 VIDC commands

 1170 DIM vidctable2 256*16   :REM +4 VIDC commands

 1180 DIM vidctable3 256*32   :REM +8 VIDC commands... = 16 VIDC commands/palette changes/etc. per line

 1190 DIM memctable  256*8    :REM default MEMC table, need to define

 1200 :

 1210 FOR line=0 TO 255

 1220  memctable!(line*8+0)=0

 1230  memctable!(line*8+4)=0

 1240  FOR word=0 TO 3

 1250   vidctable1!(word*4+line*16)=&40000000 :REM prefill VIDC table with &40000000 = border colour to black

 1260   vidctable2!(word*4+line*16)=&40000000 :REM prefill VIDC table with &40000000 = border colour to black

 1270   vidctable3!(word*8+0+line*32)=&40000000 :REM prefill VIDC table with &40000000 = border colour to black

 1280   vidctable3!(word*8+4+line*32)=&40000000 :REM prefill VIDC table with &40000000 = border colour to black

 1290  NEXT

 1300 NEXT

 1310 :

 1320 SYS"RasterMan_SetTables",vidctable1,vidctable2,vidctable3,memctable

 1330 PRINT

 1340 ENDPROC

