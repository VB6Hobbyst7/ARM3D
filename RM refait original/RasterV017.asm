REM aim to support 4, 8, 16 or 32 changes per line + 2 MEMC per interrupt!
REM v0.12 allows 3 VIDC tables and 1 MEMC table, one IRQ/line = 16 changes+2
REM v0.13 first attempt at VGA monitor-compatible rasters
REM v0.14 first attempt at a keyboard handler...
REM v0.15 need a direct SWI call address, to avoid SWIs turning on IRQs?
REM v0.16 everything from v0.15 but back to TV res
REM v0.17 add support for Arthur and RISC OS 2 (0.17a - fixed Arthur bug)

REM - check whether SWI calls enable interrupts and which ones
REM   (use wurzel)
REM - handler sometimes returns &C0C0 when pressing z x " ? ret shift etc
REM   ..why? byte order wrong? can we fix this somehow?

REM RasterMan for RiscOS3.1 v0.16 15th April 2015
REM
REM � Pnx/QTM 2013-5
REM
REM Thanks to Xavier Tardy for the encouragement to make this happen :-)
:
REM RISC OS 2 version removes use of RO3-only SWI OS_FindMemMapEntries
REM Arthur version removes use of RO2+ SWI OS_ReadMemMapInfo / ReadMemMapEntries
REM   "       "    also enables interrupts on SWI (next need to patch SWI vector)
REM ...Arthur version now with SWI vector patch!
:
ONERROR ON ERROR OFF:ERROR 255,REPORT$+" at line "+STR$ERL:END
:
irqtest=FALSE
alphatest%=TRUE
ver$="0.17"
ver%=1000*EVAL(ver$)
date$=MID$(TIME$,5,11)
vga%=FALSE
SYS "OS_Byte",129,0,255 TO ,assemble_os%
IF assemble_os%>=&A3 THEN PRINT"Assembling on RISC OS 3+" ELSE PRINT"Assembling on RISC OS2/Arthur"
:
QTMblock=44+128
:
IF vga% THEN
 :
 PRINT"Assembling VGA version";
 :
 hsyncline=64-1          :REM 63 = timing for 1 line (decreases at 2MHz)
 :                       :REM (latch+1)/2uS = 64/2 = 32 uS = 0.000032 S
 :                       :REM 1/0.000032 = 31250 Hz = LCDgm VGA line rate :)
 :
 IF irqtest THEN
  ylines=1               :REM only 1 line for the test
  synctest=(hsyncline+1)*0:REM counts include 0? so add one if multiplying lines
  syncoffset=48/2
  :                      :REM -48/2 is ~ time from end of prev to start of next
  vsyncreturn=12160+16/2-1:REM 12160=190 lines=exact time to start of top line (VCR 446-VDER 294+VDSR 38=190)
  :                      :REM          +16/2 is time from start of line to start of first pixel
  :
  vsyncreturn+=synctest  :REM move a few lines down, so we can see easily...
  vsyncreturn-=syncoffset:REM -48/2 = end of previous line
 ELSE
  ylines=256             :REM skip last few
  vsyncreturn=12160+16/2-1-48/2:REM 7168+16-1-48 = end of previous line (Arm2)
  vsyncreturn+=6/2       :REM was 7/2 .. 12 = either side of 1/2 way v0.07 fudge to shift colours right a bit
 ENDIF
 :
ELSE
 :
 PRINT"Assembling TV resolution version";
 :
 hsyncline=128-1         :REM 127 = timing for 1 line (decreases at 2MHz)
 :                       :REM (latch+1)/2uS = 128/2 = 64 uS = 0.000064 S
 :                       :REM 1/0.000064 = 15625 Hz = TV line rate :)
 :
 IF irqtest THEN
  ylines=1               :REM only 1 line for the test
  synctest=(hsyncline+1)*0:REM counts include 0? so add one if multiplying lines
  syncoffset=48
  :                      :REM -48 is ~ time from end of prev to start of next
  vsyncreturn=7168+16-1  :REM 7168 = 56 lines = exact time to start of top line (VCR-VDER+VDSR = 56)
  :                      :REM        +16 is time from start of line to start of first pixel
  :
  vsyncreturn+=synctest  :REM move a few lines down, so we can see easily...
  vsyncreturn-=syncoffset:REM -48 = end of previous line
 ELSE
  ylines=256             :REM skip last few
  vsyncreturn=7168+16-1-48:REM 7168+16-1-48 = end of previous line (Arm2)
  vsyncreturn+=7         :REM 12 = either side of 1/2 way v0.07 fudge to shift colours right a bit
 ENDIF
 :
ENDIF
:
REM A440 MEMC1 timings: vsyncreturn = 7175-127-43 (works ok)
REM                     hsyncline = 127
REM A5000 Arm3 25MHz timings: vsyncreturn = 7175-127-40 (tested ok A5000, A3020 and A440)
:
PROCinit
PROCassm
:
:
REM PRINT~startofFIQcode
REM PRINT~endofFIQcode
REM PRINT~vsyncbyte
:
PRINT
*.
OSCLI"FX 138,0,"+STR$(ASC"R"):OSCLI"FX 138,0,"+STR$(ASC"a"):OSCLI"FX 138,0,"+STR$(ASC"s")
OSCLI"FX 138,0,"+STR$(ASC"t"):OSCLI"FX 138,0,"+STR$(ASC"e"):OSCLI"FX 138,0,"+STR$(ASC"r")
OSCLI"FX 138,0,"+STR$(ASC"M"):OSCLI"FX 138,0,"+STR$(ASC"a"):OSCLI"FX 138,0,"+STR$(ASC"n")
IF vga% THEN OSCLI"FX 138,0,"+STR$(ASC"V")
:
INPUT"Filename: "fn$
OSCLI"Save "+fn$+" "+STR$~code%+" "+STR$~O%
OSCLI"Settype  "+fn$+" module"
END


DEF PROCinit
ENDPROC


DEF PROCassm
codelen%=4096*2
DIM code% codelen%
FOR fill=0 TO codelen%-4 STEP 4:code%!fill=0:NEXT
FOR opt%=12 TO 14 STEP 2
P%=0:O%=code%:L%=O%+codelen%
[OPT opt%
.modulebase
EQUD    0               ;00 start code
EQUD    init            ;04 init code
EQUD    exit            ;08 exit code
EQUD    service         ;0C service code
EQUD    title           ;10 title
EQUD    help            ;14 help
EQUD    commands        ;18 commands
EQUD    &47E80          ;1C SWI number QTM+64
EQUD    SWIcode         ;20 SWI handler code
EQUD    SWItable        ;24 SWI table
EQUD    0               ;28 SWI decoding code
EQUD    0               ;2C Messages



.title
EQUS    "RasterMan"
EQUB    0


.help
EQUS    "RasterMan"
EQUB    &09
EQUS    ver$+" ("+date$+") � Steve Harrison":]:IF alphatest% THEN [OPT opt%:EQUS " !TEST VERSION NOT FOR RELEASE!":]
[OPT opt%
EQUB    0


.commands
EQUS    "RasterMan"
EQUB    0
ALIGN
EQUD    0
EQUB    0
EQUB    0
EQUB    0
EQUB    0
EQUD    0
EQUD    help_rasterman
:
EQUD    0


.help_rasterman
EQUS    "Raster Manager v"+ver$+" adds more colour and music to your Archimedes, with true Raster Bars and HSync interrupt control for TV-resolution screen modes."
EQUB    0
ALIGN



.SWIcode                     ;note - Arthur enters with IRQs disabled, fix by patching SWI vec
CMP     R11,#(endSWItable-startSWItable)/4
ADDLO   PC,PC,R11,LSL#2
B       UnknownSWIerror
.startSWItable
B       swi_install          ;0
B       swi_release          ;1
B       swi_wait             ;2
B       swi_settables        ;3
B       swi_version          ;4
B       swi_readscanline     ;5
B       swi_setVIDCreg       ;6
B       swi_setMEMCreg       ;7
B       swi_QTMParamAddr     ;8
B       swi_scankeyboard     ;9
B       swi_clearkeybuffer   ;10
B       swi_readscanaddr     ;11

;B       swi_mode             ;2
;B       swi_offsettable      ;4
;B       swi_screenbank       ;7
;B       swi_screenstart      ;8
.endSWItable
.UnknownSWIerror
ADR     R0,swierror
ORRS    PC,R14,#1<<28
.swierror
EQUD    486
EQUS    "Unknown RasterMan operation"
EQUB    0
ALIGN


.SWItable
EQUS    "RasterMan"
EQUB    0
EQUS    "Install"
EQUB    0
EQUS    "Release"
EQUB    0
EQUS    "Wait"
EQUB    0
EQUS    "SetTables"
EQUB    0
EQUS    "Version"
EQUB    0
EQUS    "ReadScanline"
EQUB    0
EQUS    "SetVIDCRegister"
EQUB    0
EQUS    "SetMEMCRegister"
EQUB    0
EQUS    "QTMParamAddr"
EQUB    0
EQUS    "ScanKeyboard"
EQUB    0
EQUS    "ClearKeyBuffer"
EQUB    0
EQUS    "ReadScanAddr"
EQUB    0
;EQUS    "Mode"
;EQUB    0
;EQUS    "OffsetTable"
;EQUB    0
;EQUS    "ScreenBank"
;EQUB    0
;EQUS    "ScreenStart"
;EQUB    0
EQUB    0
ALIGN

; ***********************************************************************************
;
;                                 Code starts here...
;
; ***********************************************************************************


.init
STMFD   R13!,{R0-R6,R14}
MOV     R0,#129
MOV     R1,#0
MOV     R2,#&FF
SWI     "OS_Byte"
:
STRB    R1,os_version
CMP     R1,#&A5
LDMGEFD R13!,{R0-R6,R14}
ADRGE   R0,regtablerror
ORRGES  PC,R14,#1<<28     ;can't run on RISC OS 3.5 hardware
:
]:IF alphatest% THEN
 [OPT opt%
 SWI     "XOS_WriteS"
 EQUS    "RasterMan v"+ver$+" alpha-Test version loaded."+CHR$13+CHR$10+CHR$13+CHR$10
 EQUS    "** THIS IS A TEST VERSION AND IS NOT FOR PUBLIC RELEASE **"+CHR$13+CHR$10+CHR$0:]
 ENDIF
[OPT opt%
LDMFD   R13!,{R0-R6,PC}


.rman_error
EQUD      255
EQUS      "Sorry, RasterMan v"+ver$+" can only run on RISC OS 3.1 or earlier"
EQUB      0
ALIGN


.exit
STMFD   R13!,{R0-R6,R14}
LDMFD   R13!,{R0-R6,PC}


.service
;CMP       R1,#&50
;MOVNE     PC,R14
MOV       PC,R14


; SH decoded IRQ and FIQ masks
;
; to load/set/store IRQ and FIQ masks use:
;
; Rx=mask
; Ry=&3200000 (IOC base)
;
;
; LDRB Rx,[Ry,#&18+0]      ;load irqa mask (+0)
; STRB Rx,oldirqa          ;store original mask
; MOV  Rx,#%00100000       ;only allow timer 0 interrupt
; STRB Rx,[Ry,#&18+2]      ;(note +2 on storing)
;
; LDRB Rx,[Ry,#&28+0]      ;load irqb mask (+0)
; STRB Rx,oldirqb          ;store original mask
; MOV  Rx,#%00000010       ;only allow sound interrupt
; STRB Rx,[Ry,#&28+2]      ;(note +2 on storing)
;
;

;irqa mask = IOC (&3200000) + &18
;
;bit 0   - il6 0 printer busy / printer irq
;    1   - il7 0 serial port ringing / low battery
;    2   - if  0 printer ack / floppy index
;    3s  - ir  1 vsync
;    4   - por 0 power on
;    5c  - tm0 0 timer 0
;    6   - tm1 1 timer 1
;    7   - 1   0 n/c      (fiq downgrade?)
;
;irqb mask = IOC (&3200000) + &28
;
;bit 0   - il0 0 expansion card fiq downgrade
;    1   - il1 0 sound system buffer change
;    2   - il2 0 serial port controller
;    3   - il3 0 hdd controller / ide controller
;    4   - il4 0 floppy changed / floppy interrupt
;    5   - il5 0 expansion card interrupt
;    6   - stx 1 keyboard transmit empty
;    7cs - str 1 keyboard recieve full
;
; c = cmdline critical
; s = desktop critical
;
;fiq mask (none are critical) = IOC (&3200000) + &38
;
;bit 0  - fh0 0 floppy data request / floppy dma
;    1  - fh1 0 fdc interrupt / fh1 pin on ioc
;    2  - fl  0 econet interrupt
;    3  - c3  0 c3 on ioc
;    4  - c4  0 c4 on ioc / serial interrupt (also IRQB bit2)
;    5  - c5  0 c5 on ioc
;    6  - il0 0 expansion card interrupt
;    7  - 1   0 force fiq (always 1)
;
;cr
;
;bit 0 - c0 IIC data
;    1 - c1 IIC clock
;    2 - c2 floppy ready / density
;    3 - c3 reset enable / unique id
;    4 - c4 aux i/o connector / serial fiq
;    5 - c5 speaker
;    6 - if printer ack or floppy index
;    7 - ir vsync
;

.os_version
EQUD      0         ;1 byte &A0 for Arthur 0.3/1.2, &A1 for RO2, &A3 for RO3.0, &A4 for RO3.1
.rasterinstalled
EQUD      0
.fiqoriginal
EQUD      0         ;R8
EQUD      0         ;R9
EQUD      0         ;R10
EQUD      0         ;R11
EQUD      0         ;R12
EQUD      0         ;R13
EQUD      0         ;R14
.oldIRQa
EQUD      0
.oldIRQb
EQUD      0
.oldIRQbranch
EQUD      0
.oldIRQaddress
EQUD      0
.newIRQfirstinst
EQUD      0


.qtmseerror
EQUD      255
EQUS      "QTM_se failed to initialise correctly"
EQUB      0
ALIGN


; SWI RasterMan_Configure
;
; R0=0, 4, 8, 16 VIDC register changes per H-interrupt, -1 to read
; R1=0, 2, 4 MEMC register changes per H-interrupt, -1 to read
; R2=number of H-interrupts per screen draw (minimum 1, max 256)
; R3=number of lines from one H-interrupt to the next
;      * Default 1, for one H-interrupt on every line
;      * Increase to 2-255 for wider rasters
;      * ***Set to 0*** for 2 H-interrupts per line
;      * or use -1 to read
; R4=number of V-retrace lines from VSync pulse to first H-interrupt (default 55), -1 to read
; R5=time offset for first interrupt (0-127, default 0 = end of previous line), -1 to read
; R6=time offset for second interrupt (0-127, default is 64 = centre), -1 to read
;
;Note - You must call RasterMan_Wait, followed by RasterMan_ColourTable and
;RasterMan_VideoTable (if necessary) to ensure the correct tables are
;available, *before* making changes by calling RasterMan_Configure.
;
;Current version only - RasterMan_Configure will return an error if it is
;called while RasterMan is currently active (this restriction will be
;removed in future).
;

;.swi_configure
;STMFD     R13!,{R0-R12,R14}
;LDR       R14,rasterinstalled
;CMP       R14,#0
;LDMNEFD   R13!,{R0-R12,R14}
;ADRNE     R0,activeerror
;ORRNES    PC,R14,#1<<28       ;cannot call when active!
;:
;.setVIDC
;CMP       R0,#0
;BGT


.activeerror
EQUD      255
EQUS      "Cannot change configuration while RasterMan is active"
EQUB      0
ALIGN


.swi_version
MOV       R0,#ver%/10
MOVS      PC,R14


.swi_install                ;returns in USER mode, with IRQs and FIQs enabled but our code managing
:                           ;all IRQs and SWIs, disc access is now suspended and any call to
:                           ;a SWI which is not ours, or selected QTM SWIs, releases our FIQ
STMFD     R13!,{R0-R12,R14}
LDR       R0,rasterinstalled
CMP       R0,#0
LDMNEFD   R13!,{R0-R12,PC}  ;we're already enabled
:
FNlong_adr("",0,regtable)
LDMIA     R0,{R0-R3}
CMP       R0,#0
CMPGT     R1,#0
CMPGT     R2,#0
CMPGT     R3,#0
LDMLEFD   R13!,{R0-R12,R14}
ADRLE     R0,regtablerror
ORRLES    PC,R14,#1<<28     ;no colour table!
:
BL        checkQTMspecialrelease
LDMVSFD   R13!,{R0-R12,R14}
ADRVS     R0,qtmseerror
ORRVSS    PC,R14,#1<<28     ;qtm se error
:
MOV       R0,#&0C           ;claim FIQ
SWI       "XOS_ServiceCall"
STRVS     R0,[R13]
LDMVSFD   R13!,{R0-R12,PC}
:
; we own FIQs
:
TEQP      PC,#%11<<26 OR %01;disable IRQs and FIQs, change to FIQ mode
MOV       R0,R0
:
ADR       R0,fiqoriginal
STMIA     R0,{R8-R14}
:
MOV       R1,#&3200000
LDRB      R0,[R1,#&18]
STR       R0,oldIRQa
LDRB      R0,[R1,#&28]
STR       R0,oldIRQb
:
; When installing, we will start on the next VSync, so set IRQ for VSync only
; and set T1 to contain 'vsyncvalue', so everything in place for VSync int...
:
MOV       R0,#%00001000
STRB      R0,[R1,#&18+2]    ;set IRQA mask to %00001000 = VSync only
MOV       R0,#0
STRB      R0,[R1,#&28+2]    ;set IRQB mask to 0
STRB      R0,[R1,#&38+2]    ;set FIQ mask to 0 (disable FIQs)
:
MOV       R0,#&FF           ;*v0.14* set max T1 - ensure T1 doesn't trigger before first VSync!
STRB      R0,[R1,#&50+2]    ;T1 low byte, +2 for write
STRB      R0,[R1,#&54+2]    ;T1 high byte, +2 for write
STRB      R1,[R1,#&58+2]    ;T1_go = reset T1
:
MOV       R0,#(vsyncreturn AND &00FF)>>0;or ldr r8,vsyncval  - will reload with this on VSync...
STRB      R0,[R1,#&50+2]    ;T1 low byte, +2 for write
MOV       R0,#(vsyncreturn AND &FF00)>>8;or mov r8,r8,lsr#8
STRB      R0,[R1,#&54+2]    ;T1 high byte, +2 for write
:
; poke our IRQ/FIQ code into &1C-&FC
:
MOV       R0,#0
LDR       R1,[R0,#&18]      ;load current IRQ vector
STR       R1,oldIRQbranch
:
BIC       R1,R1,#&FF000000
MOV       R1,R1,LSL#2
ADD       R1,R1,#&18+8
STR       R1,oldIRQaddress
:
;copy IRQ/FIQ code to &18 onwards
:
FNlong_adr("",0,fiqbase)
MOV       R1,#&18
LDMIA     R0!,{R2-R12}
STMIA     R1!,{R2-R12}      ;11 pokey codey
LDMIA     R0!,{R2-R12}
STMIA     R1!,{R2-R12}      ;22 pokey codey
LDMIA     R0!,{R2-R12}
STMIA     R1!,{R2-R12}      ;33 pokey codey
LDMIA     R0!,{R2-R12}
STMIA     R1!,{R2-R12}      ;44 pokey codey
LDMIA     R0!,{R2-R12}
STMIA     R1!,{R2-R12}      ;55 pokey codey
LDMIA     R0!,{R2-R4}
STMIA     R1!,{R2-R4}       ;58 pokey codey (58 max)
:
FNlong_adr("",0,notHSync)   ;set up VSync code after copying
]
IF assemble_os%<&A3 THEN
 [OPT opt%
 MOV       R1,#&C0          ;should ref. FIQ_notHSync, but fails on RO2 assmbler
 ]
ELSE
 [OPT opt%
 MOV       R1,#FIQ_notHSync ;ref. works if assembling on RO3, note 'FIQ_notHSync' is 0-relative!
 ]
ENDIF
[OPT opt%
STR       R0,[R1]
:
MOV       R0,#0
LDR       R1,[R0,#&18]      ;first IRQ instruction from our code
STR       R1,newIRQfirstinst
:
; R8_FIQ=temp reg 1
; R9_FIQ=table 1
; R10_FIQ=table 2
; R11_FIQ=table 3 & table 4
; R12_FIQ=memc table
; R13_FIQ=line count
; R14_FIQ=temp reg 2/set to IOC addr &3200000 on entry/exit
:
; set up our FIQ mode registers
:
MOV       R8,#0
ADR       R9,regtable
LDMIA     R9,{R9,R10,R11,R12}
MOV       R13,#ylines       ;256
MOV       R14,#&3200000
:
; poke our SWI controller - N/R
:
MOV       R0,#1
STR       R0,rasterinstalled
:
LDRB      R2,os_version
CMP       R2,#&A1
BGE       notArthur_install
:
; Arthur version ONLY - patch SWI jump address to call our code and enable IRQs!
:
MOV       R0,#0
LDR       R1,[R0,#8]        ;load "B os_swi_code"
STR       R1,oldswivector
BIC       R1,R1,#&FF<<24    ;clear B instruction bits
MOV       R1,R1,LSL#2       ;shift 2 bits
ADD       R1,R1,#8+8        ;now R1 has addr of OS SWI routine
:
ADR       R2,os_swi_jump+8  ;destination addr +8 (for pipelining)
SUB       R1,R1,R2          ;make address into relative offset (+8)
MOV       R1,R1,LSR#2       ;shift 2 bits
ORR       R1,R1,#&EA<<24    ;add B (EA) [BL (EB)] instruction bits
STR       R1,os_swi_jump    ;store
:
ADR       R1,os_swi_patch   ;target addr
SUB       R1,R1,#8+8        ;subtract store addr +8 (pipelining)
MOV       R1,R1,LSR#2       ;shift 2 bits
ORR       R1,R1,#&EA<<24    ;add B (EA) instruction bits
STR       R1,[R0,#8]        ;store
:
.notArthur_install
TEQP      PC,#%00<<26 OR %11;enable IRQs and FIQs, change to SVC mode
MOV       R0,R0
:
LDMFD     R13!,{R0-R12,PC}^ ;exit in USER mode and with IRQs and FIQs on


.oldswivector
EQUD      0


.os_swi_patch               ;only use for Arthur, n/r for RISC OS 2+
TEQP      PC,#%11           ;enable IRQs and FIQs, stay in SVC mode (NOP n/r) [bug fixed 0.17a]
.os_swi_jump
B         os_swi_jump       ;(overwritten)


.regtablerror
EQUD      255
EQUS      "RasterMan VIDC/MEMC tables not defined"
EQUB      0
ALIGN


.checkQTMspecialrelease     ;*NOT* RO2 - SWI OS_FindMemMapEntries
STMFD     R13!,{R0-R8,R14}
SWI       "XQTM_SongStatus"
MOVVS     R0,#0             ;if error (no QTM module) then treat as no song playing
TST       R0,#%0100
MOVEQ     R0,#0
STREQB    R0,qtmcontrol     ;no music playing
LDMEQFD   R13!,{R0-R8,PC}
:
MVN       R0,#0
MVN       R1,#0
MVN       R2,#0
SWI       "XQTM_Debug"
MOVVS     R0,#0
STRVSB    R0,qtmcontrol     ;no QTM special release present
LDMVSFD   R13!,{R0-R8,PC}
:
CMP       R0,#0
CMPGE     R1,#0
MOVLT     R0,#0
STRLTB    R0,qtmcontrol     ;no QTM special release present
LDMLTFD   R13!,{R0-R8,R14}
ORRLTS    PC,R14,#1<<28
:
CMN       R2,#1
MOVNE     R0,#0
STRNEB    R0,qtmcontrol     ;no QTM special release present
LDMNEFD   R13!,{R0-R8,R14}
ORRNES    PC,R14,#1<<28
:
; if we get here, QTM_Debug works and has provided two values >=0
:
MVN       R0,#0
MVN       R1,#0
MVN       R2,#0
SWI       "XQTM_SoundControl"
CMP       R0,#0
STREQB    R0,qtmcontrol     ;QTM sound is off, so exit
LDMEQFD   R13!,{R0-R8,R14}
ORREQS    PC,R14,#1<<28
:
MOV       R0,R0             ;number of channels
STR       R0,qtmchannels
:
; if we get here, qtm sound is on and probably using v1.43
:
SWI       "XQTM_DMABuffer"
MOV       R6,R0
MOV       R7,#50            ;1 second max wait
.dmabuffer
MOV       R0,#19
SWI       "XOS_Byte"
:
SWI       "XQTM_DMABuffer"
CMP       R0,R6
MOVNE     R5,R0
BNE       gottwoDMAbuffers
:
SUBS      R7,R7,#1
BNE       dmabuffer
:
; if we get here, we failed to find two DMA buffers
:
MOV       R0,#0
STRB      R0,qtmcontrol
LDMFD     R13!,{R0-R8,R14}  ;***should really return an error***
ORRS      PC,R14,#1<<28
:
.gottwoDMAbuffers           ;in R5 and R6
STR       R6,qtmdmabuffer1
STR       R5,qtmdmabuffer2
:
SWI       "XQTM_Debug"
STR       R0,qtmdmahandler
STR       R1,qtmr12pointer
ADD       R1,R1,#QTMblock
STR       R1,dmaentry_r9
:
MOV       R0,#0
MOV       R1,#0
MOV       R2,#0
MOV       R3,#0
MOV       R4,#0
SWI       "Sound_Configure"
:
MUL       R0,R1,R0
STR       R0,qtmdmasize     ;should be 416x4 or x8
:
LDRB      R0,os_version     ;check OS version
CMP       R0,#&A3           ;RISC OS 3.0?
BGE       use_os_locate_DMA ;if so, do things properly... (probably of no value, but code works)
:
; for RISC OS 2.01 and below...
:
CMP       R5,R6             ;this is a fudge to use fixed physical addrs for sound buffer
MOVLT     R1,#&7E000        ;it avoids using RISC OS 2-only or RISC OS 3-only SWIs
MOVGE     R1,#&7F000        ;so works with Arthur, which doesn't have an (easy) method.
STR       R1,physicaldma2   ;got the correct phys addr of buf2 (R5)
RSB       R1,R1,#(&7E000+&7F000)
STR       R1,physicaldma1   ;got the correct phys addr of buf1 (R6)
B         got_DMA_addr
:
.use_os_locate_DMA
SWI       "OS_ReadMemMapInfo" ;not Arthur
STR       R0,pagesize
STR       R1,numpages
:
SUB       R4,R0,#1
BIC       R7,R5,R4          ;page for dmabuffer2
BIC       R8,R6,R4          ;page for dmabuffer1
:
SUB       R5,R5,R7          ;offset into page
SUB       R6,R6,R8          ;offset into page
:
ADR       R0,pagefindblk
MOV       R1,#0
STR       R1,[R0,#0]
STR       R1,[R0,#8]
MVN       R1,#0
STR       R1,[R0,#12]
STR       R7,[R0,#4]
SWI       "XOS_FindMemMapEntries" ;not RISC OS 2 or earlier
LDR       R1,[R0,#0]
LDR       R4,pagesize
MUL       R1,R4,R1
ADD       R1,R1,R5
STR       R1,physicaldma2 ;got the correct phys addr of buf2 (R7)
:
MOV       R1,#0
STR       R1,[R0,#0]
STR       R1,[R0,#8]
MVN       R1,#0
STR       R1,[R0,#12]
STR       R8,[R0,#4]
SWI       "XOS_FindMemMapEntries" ;not RISC OS 2 or earlier
LDR       R1,[R0,#0]
LDR       R4,pagesize
MUL       R1,R4,R1
ADD       R1,R1,R6
STR       R1,physicaldma1 ;got the correct phys addr of buf1 (R8)
;                          ...on RO2/Arthur we assume fixed sound DMA addr
:
.got_DMA_addr
MOV       R0,#1
STRB      R0,qtmcontrol
LDMFD     R13!,{R0-R8,PC}^


.swi_QTMParamAddr
FNlong_adr("",0,qtmcontrol)
MOVS      PC,R14


.qtmcontrol
EQUB      0
.vsyncbyte
EQUB      0
EQUB      0
EQUB      0
.pagesize
EQUD      0
.numpages
EQUD      0
.pagefindblk
EQUD      0 ;0
EQUD      0 ;4
EQUD      0 ;8
EQUD      0 ;12
.qtmdmabuffer1
EQUD      0
.qtmdmabuffer2
EQUD      0


.swi_release                  ;
STMFD     R13!,{R0-R3,R14}
LDR       R0,rasterinstalled
CMP       R0,#1
:
LDMNEFD   R13!,{R0-R3,R14}
ADRNE     R0,releaseerror
ORRNES    PC,R14,#1<<28       ;exit with error if we're not enabled
:
; we own FIQs
:
TEQP      PC,#%11<<26 OR %01            ;disable IRQs and FIQs, switch FIQ mode
MOV       R0,R0
:
MOV       R0,#0
LDR       R1,[R0,#&18]        ;load current IRQ vector
LDR       R2,newIRQfirstinst  ;our expected first instruction
CMP       R1,R2
LDMNEFD   R13!,{R0-R3,R14}
ADRNE     R0,releaseerror
ORRNES    PC,R14,#1<<28       ;preserves flags (IRQs on, FIQs off, SVC mode)
:
LDR       R1,oldIRQbranch
STR       R1,[R0,#&18]        ;restore original IRQ controller
:
MOV       R0,#0
MOV       R1,#&3200000
STRB      R0,[R1,#&38+2]      ;set FIQ mask to 0 (disable FIQs)
:
LDR       R0,oldIRQa
STRB      R0,[R1,#&18+2]
LDR       R0,oldIRQb
STRB      R0,[R1,#&28+2]      ;restore IRQ masks
:
FNlong_adr("",0,fiqoriginal)
LDMIA     R0,{R8-R14}
:
LDRB      R0,os_version
TEQ       R0,#&A0
:
; if running on Arthur, restore original SWI controller (n/r RISC OS 2+)
:
MOVEQ     R0,#0
LDREQ     R1,oldswivector
STREQ     R1,[R0,#8]          ;SWI jump restored (Arthur only)
:
TEQP      PC,#(%00<<26) OR %11          ;enable IRQs and FIQs, stay SVC mode
MOV       R0,R0
:
MOV       R0,#0
STR       R0,rasterinstalled
:
MOV       R0,#&0B             ;release FIQ
SWI       "XOS_ServiceCall"
STRVS     R0,[R13]
LDMFD     R13!,{R0-R3,PC}     ;restore flags (return USER mode, leave IRQs and FIQs on)


.releaseerror
EQUD    255
EQUS    "RasterMan not enabled"
EQUB    0
ALIGN


.swi_wait             ;can corrupt R11 and R12
LDR       R12,rasterinstalled
TEQ       R12,#0
BEQ       osbyte19    ;we're not enabled
:
LDRB      R11,vsyncbyte   ;load our byte from FIQ address, if enabled
.waitloop
LDRB      R12,vsyncbyte
TEQ       R12,R11
BEQ       waitloop
MOVS      PC,R14
:
.osbyte19
STMFD     R13!,{R0-R2,R14}
MOV       R0,#19
SWI       "OS_Byte"
LDMFD     R13!,{R0-R2,PC}^


.swi_settables        ;3 R0=colourtable 1, R1=ct2, R2=ct3, R3=memc
STMFD     R13!,{R4-R7,R14}
MOV       R4,R0
MOV       R5,R1
MOV       R6,R2
MOV       R7,R3
:
ADR       R12,regtable
LDMIA     R12,{R0-R3}          ;original values for return
:
CMP       R4,#0
STRGT     R4,table1addr        ;store if >0
CMP       R5,#0
STRGT     R5,table2addr        ;store if >0
CMP       R6,#0
STRGT     R6,table3addr        ;store if >0
CMP       R7,#0
STRGT     R7,memctable         ;store if >0
:
LDMFD     R13!,{R4-R7,PC}^


.swi_readscanline     ;5
LDR       R12,rasterinstalled
TEQ       R12,#0
ADREQ     R0,releaseerror
ORREQS    PC,R14,#1<<28       ;exit with error if we're not enabled
:
TEQP      PC,#%11<<26 OR %01  ;disable IRQs and FIQs, switch FIQ mode
MOV       R0,R0
MOV       R0,R13              ;put current line counter in R0 (256=retrace, 255=line0, 0=line255)
TEQP      PC,#(%00<<26) OR %11;enable IRQs and FIQs, stay SVC mode
RSB       R0,R0,#255          ;255-256=-1 = retrace, 255-255=0 line0, 255-0=255 line255
MOVS      PC,R14


.swi_setVIDCreg       ;6
MOV       R12,#&3400000       ;R12=VIDC address
STR       R0,[R12]            ;set register
MOVS      PC,R14


.swi_setMEMCreg       ;7
CMP       R0,#&3600000        ;is R0 a MEMC register?
STRGE     R0,[R0]             ;if so, set register
MOVGES    PC,R14
:
ADR       R0,memcerror
ORRS      PC,R14,#1<<28       ;exit with error if register is wildly incorrect


.memcerror
EQUD    255
EQUS    "MEMC register out of range"
EQUB    0
ALIGN


.swi_scankeyboard     ;9
STMFD     R13!,{R12,R14}
LDRB      R12,keybyte2
LDRB      R0,keybyte1
ORR       R0,R0,R12,LSL#8
LDMFD     R13!,{R12,PC};flags not preserved


.swi_clearkeybuffer   ;10 - temp SWI, probably not needed in future once full handler done
MOV       R12,#0
STRB      R12,keybyte1
STRB      R12,keybyte2
MOV       PC,R14      ;flags not preserved


.swi_readscanaddr     ;11
ADR       R0,swi_scankeyboard
MOV       PC,R14      ;flags not preserved


;.swi_mode             ;2
;.swi_offsettable      ;4
;.swi_vsync            ;6
;.swi_screenbank       ;7
;.swi_screenstart      ;8
MOV       PC,R14      ;flags not preserved


.regtable
.table1addr EQUD 0       ;r9
.table2addr EQUD 0       ;r10
.table3addr EQUD 0       ;r11
.memctable  EQUD 0       ;r12


.fiqbase              ;copy to &18 onwards, 57 instructions max
                      ;this pointer must be relative to module

:]:tempP%=P%:P%=&18
:[OPT opt%

.FIQ_startofcode
TEQP      PC,#%11<<26 OR %01  ; 1 18 keep IRQs and FIQs off, change to FIQ mode : irq et fiq OFF (status register dans le PC) + FIQ mode activ�
MOV       R0,R0               ; 2 1C nop to sync FIQ registers
:
; FIQ registers
;
; R8_FIQ=temp reg 1
; R9_FIQ=table 1
; R10_FIQ=table 2
; R11_FIQ=table 3 & table 4
; R12_FIQ=memc table
; R13_FIQ=line count
; R14_FIQ=temp reg 2/set to IOC addr on exit
:
LDRB      R8,[R14,#&14+0]     ; 3 20 load irq_A triggers ***BUG to v0.13*** v0.14 read &14+0
:                             ;      was reading status at &10, which ignores IRQ mask!!!
TST       R8,#%01000000       ; 4 24 bit 3 = Vsync, bit 6 = T1 trigger (HSync)
LDREQ     PC,FIQ_notHSync     ; 5 28 *v0.14 if not T1, then go to VSync/Keyboard code*
:
STRB      R8,[R14,#&14+2]     ; 6 2C (v0.14 moved past branch) clear all interrupt triggers
:
MOV       R14,#FIQ_tempstack  ; 7 30
STMIA     R14,{R4-R7}         ; 8 34
MOV       R8,#&3400000        ; 9 38
LDMIA     R9!,{R4-R7}         ;10 3C load 4 VIDC parameters
STMIA     R8,{R4-R7}          ;11 40 store 4
LDMIA     R10!,{R4-R7}        ;12 44
STMIA     R8,{R4-R7}          ;13 48 ...8
LDMIA     R11!,{R4-R7}        ;14 4C
STMIA     R8,{R4-R7}          ;15 50 ...12
LDMIA     R11!,{R4-R7}        ;16 54
STMIA     R8,{R4-R7}          ;17 58 ...16
:
LDMIA     R12!,{R4-R5}        ;18 5C load 2 MEMC paramters
CMP       R4,#&3600000        ;19 60
STRGE     R4,[R4]             ;20 64 it's a MEMC reg, so write
CMP       R5,#&3600000        ;21 68
STRGE     R5,[R5]             ;22 6C it's a MEMC reg, so write
:
LDMIA     R14,{R4-R7}         ;23 70
MOV       R14,#&3200000       ;24 74 reset R14 to IOC address
STRB      R14,[R14,#&28+2]    ;25 78 *v0.14* set IRQB mask to %00000000 = no STx, SRx IRQs now
;*************************************************************************
:
SUBS      R13,R13,#1             ;26 7C
TEQGTP    PC,#%000011<<26 OR %10 ;27 80 back to IRQ mode, maintain 'GT', Z clear
MOV       R0,R0                  ;28 84 sync IRQ registers
SUBGTS    PC,R14,#4              ;29 88 return to foreground
:
; only get here (EQ) if at last line on screen
:
MOV       R8,#%00001000       ;30 8C
STRB      R8,[R14,#&18+2]     ;31 90 set IRQA mask to %00001000 = VSync only n/r unless likely to do <256?
:
MOV       R8,#(vsyncreturn AND &00FF)>>0;32 94   or ldr r8,vsyncvalue
STRB      R8,[R14,#&50+2]               ;33 98 T1 low byte, +2 for write
MOV       R8,#(vsyncreturn AND &FF00)>>8;34 9C   or mov r8,r8,lsr#8
STRB      R8,[R14,#&54+2]               ;35 A0 T1 high byte, +2 for write
STRB      R8,[R14,#&58+2]               ;36 A4 T1_go = reset T1
:
.FIQ_exitcode
TEQP      PC,#%000011<<26 OR %10 ;37 A8 back to IRQ mode
MOV       R0,R0                  ;38 AC sync IRQ registers
SUBS      PC,R14,#4              ;39 90 return to foreground

EQUD      0                      ;40 &B4 n/r
EQUD      0                      ;41 &B8 n/r
EQUD      0                      ;42 &BC n/r

.FIQ_notHSync                    ;*NEED TO ADJUST REF. IN swi_install IF THIS MOVES FROM &C0*
EQUD      0                      ;43 &C0 pointer to notHSync ***quad aligned***

EQUD      0                      ;44 &C4 n/r
EQUD      0                      ;45 &C8 n/r
EQUD      0                      ;46 &CC n/r

.FIQ_tempstack
EQUD      0                      ;47 &D0 R4 ***quad aligned***
EQUD      0                      ;48 &D4 R5
EQUD      0                      ;49 &D8 R6
EQUD      0                      ;50 &DC R7

EQUD      0                      ;51 &E0 n/r
EQUD      0                      ;52 &E4 n/r
EQUD      0                      ;53 &E8 n/r
EQUD      0                      ;54 &EC n/r
EQUD      0                      ;55 &F0 n/r
EQUD      0                      ;56 &F4 n/r
EQUD      0                      ;57 &F8 n/r

EQUS      "RstM"                 ;58 &FC

.FIQ_endofcode


]:P%-=&18:P%=tempP%+P%
[OPT opt%

.fiqend


.kbd_stack
EQUD      0 ;R4
EQUD      0 ;R5
EQUD      0 ;R6
EQUD      0 ;R7


.checkkeyboard
;CMP       R13,#256            ;retrace? - this is a backup to disable STx SRx irqs, n/r
;MOVNE     R8,#%00000000       ;           n/r once everything is working
;STRNEB    R8,[R14,#&28+2]     ;set IRQB mask to %11000000 = STx or SRx
;BNE       exitVScode          ;back to IRQ mode and exit
:
ADR       R8,kbd_stack
STMIA     R8,{R4-R7}          ;some regs to play with
:
LDRB      R4,[R14,#&24+0]     ;load irq_B triggers
TST       R4,#%10000000       ;bit 7 = SRx, cleared by a read from 04
 LDMEQIA     R8,{R4-R7}          ;restore regs
 BEQ         exitVScode          ;back to IRQ mode and exit
;BNE       kbd_received
;:
;.kbd_trans
;TST       R4,#%01000000       ;bit 6 = STx, cleared by a write to 04
;LDRNEB    R5,nextkeybyte
;STRNEB    R5,[R14,#&04+2]     ;clear STx
;MOVNE     R5,#%10000000       ;set mask to wait for ok-to-read
;STRNEB    R5,[R14,#&28+2]     ;set IRQB mask to %10000000 = SRx
;:
;LDMIA     R8,{R4-R7}          ;restore regs
;B         exitVScode          ;back to IRQ mode and exit
;
;
.kbd_received
:
; process key byte, and put ack value in nextkeybyte
:
LDRB      R6,keycounter
RSBS      R6,R6,#1            ;if =1 (NE), then this is the first byte, else (EQ)=second byte
STRB      R6,keycounter
:
LDRB      R5,[R14,#&04+0]     ;load byte, clear SRx
STRNEB    R5,keybyte1
MOVNE     R6,#%00111111       ;if first byte, reply with bACK
:
STREQB    R5,keybyte2
MOVEQ     R6,#%00110001       ;if second byte, reply with sACK
:
STRB      R6,[R14,#&04+2] ;transmit
;STRB      R6,nextkeybyte
:
;MOV       R5,#%01000000       ;set mask to wait for ok-to-transmit
;STRB      R5,[R14,#&28+2]     ;set IRQB mask to %01000000 = STx
  LDMIA     R8,{R4-R7}          ;restore regs
  B         exitVScode          ;back to IRQ mode and exit
;B         kbd_trans


; bACK=%00111111
; sACK=%00110001


.keycounter  EQUB 0 ;1 or 0
.keybyte1    EQUB 0
.keybyte2    EQUB 0
.nextkeybyte EQUB 0

;currently have rem'd the disable STx SRx irqs in hsync code and checkkeyboard code

;next try only enabling receive, assume transmit is ok...

;something wrong - &FFFF (HRST) seems to be only byte received
;v0.14 worked when trying only enabling receive, assume transmit is ok...

.notHSync
TST       R8,#%00001000       ;retest R8 is it bit 3 = Vsync? (bit 6 = T1 trigger/HSync)
STRNEB    R14,[R14,#&58+2]    ;if VSync, reset T1 (latch should already have the vsyncvalue...)
:
; that's the high-priority stuff done, now we can check keyboard too...
:
BEQ       checkkeyboard       ;check IRQ_B for SRx/STx interrupts
:
STRB      R8,[R14,#&14+2]     ; ...and clear all IRQ_A interrupt triggers
:
MOV       R8,#%01000000       ;**removed VSync trigger v0.05
STRB      R8,[R14,#&18+2]     ;set IRQA mask to %01000000 = T1 only
MOV       R8,#%10000000       ;R8,#%11000000
STRB      R8,[R14,#&28+2]     ;set IRQB mask to %11000000 = STx or SRx
:
MOV       R8,#(hsyncline AND &00FF)>>0
STRB      R8,[R14,#&50+2]              ;T1 low byte, +2 for write
MOV       R8,#(hsyncline AND &FF00)>>8
STRB      R8,[R14,#&54+2]              ;T1 high byte, +2 for write
:
LDRB      R8,vsyncbyte
RSB       R8,R8,#3
STRB      R8,vsyncbyte
:
ADR       R8,regtable
LDMIA     R8,{R9,R10,R11,R12}          ;reset table registers to defaults
:
MOV       R13,#ylines                  ;reset yline counter
:
LDRB      R8,qtmcontrol
TEQ       R8,#1
BNE       exitVScode                   ;back to IRQ mode and exit
:
.rastersound                  ;entered in FIQ mode, must exit via IRQ mode with SUBS PC,R14,#4
TEQP      PC,#%11<<26 OR %10  ;enter IRQ mode, IRQs/FIQs off
MOV       R0,R0               ;sync
STMFD     R13!,{R14}          ;stack R13_IRQ
TEQP      PC,#%11<<26 OR %11  ;enter SVC mode, IRQs/FIQs off
MOV       R0,R0               ;sync
:
STR       R13,tempr13         ;
LDRB      R13,dma_in_progress ;
TEQ       R13,#0              ;
LDRNE     R13,tempr13         ;
BNE       exitysoundcode      ;
STRB      PC,dma_in_progress  ;
:
FNlong_adr("",13,startofstack);
STMFD     R13!,{R14}          ;stack R14_SVC
LDR       R14,tempr13         ;
STMFD     R13!,{R14}          ;stack R13_SVC - we are now reentrant!!!
BL        rastersound_1       ;call rastersound routine - enables IRQs
:
MOV       R14,#0              ;...on return IRQs/FIQs will be off
STRB      R14,dma_in_progress ;
LDMFD     R13,{R13,R14}       ;restore R14_SVC and R13_SVC
:
.exitysoundcode
TEQP      PC,#%11<<26 OR %10  ;back to IRQ mode
MOV       R0,R0               ;sync
:
LDMFD     R13!,{R14}
SUBS      PC,R14,#4           ;return to foreground


.exitVScode
TEQP      PC,#%000011<<26 OR %10 ;36 A4 back to IRQ mode
MOV       R0,R0                  ;37 A8 sync IRQ registers
SUBS      PC,R14,#4              ;38 AC return to foreground


.dma_in_progress
EQUB      0
EQUB      0
EQUB      0
EQUB      0


.tempr13
EQUD      0


.rastersound_1                ;entered in SVC mode, with IRQs/FIQs disabled
STMFD     R13!,{R0-R12,R14}   ;can enable IRQs, but must exit via MOVS PC,R14
:
   TEQP      PC,#%00<<26 OR %11  ;** IRQs/FIQs on
   MOV       R0,R0               ;** remove '**'d for 'NoIRQ'
   :
   ; ***** note calling QTM in SVC mode will crash TSS (uses TEQP to return to IRQ mode!)
   ; ***** and play code if speed 0 (stop song)
:
LDR       R9,dmaentry_r9      ;R9=ptr to initblock
LDR       R11,qtmchannels     ;R11=DMA gap
LDR       R12,dmabank_num     ;1 or 0
RSBS      R12,R12,#1
STR       R12,dmabank_num
:
LDREQ     R12,physicaldma2    ;R12=DMA start
LDRNE     R12,physicaldma1    ;R12=DMA start
ADD       R12,R12,#&2000000   ;physical ram start addr!
:
LDR       R10,qtmdmasize
ADD       R10,R10,R12         ;R10=DMA end
:
MOV       R14,PC
LDR       PC,qtmdmahandler    ;R13=stack *R12* preserved
:
SUB       R12,R12,#&2000000   ;Sstart
LDR       R10,qtmdmasize
ADD       R10,R10,R12         ;SendN
SUB       R10,R10,#16         ; fixit ;-)
:
MOV       R12,R12,LSR#2       ;(Sstart/16) << 2
MOV       R10,R10,LSR#2       ;(SendN/16) << 2
MOV          R0,#&3600000     ;memc base
ADD       R1,R0,#&0080000     ;Sstart
ADD       R2,R0,#&00A0000     ;SendN
ORR       R1,R1,R12           ;Sstart
ORR       R2,R2,R10           ;SendN
STR       R2,[R2]
STR       R1,[R1]
:
LDMFD     R13!,{R0-R12,PC}^   ;return to IRQ calling routine


.dmabank_num
EQUD      0
.physicaldma1
EQUD      0
.physicaldma2
EQUD      0
.qtmdmasize
EQUD      0
.qtmdmahandler
EQUD      0
.qtmr12pointer
EQUD      0
.dmaentry_r9
EQUD      0
.qtmchannels
EQUD      0


.addrtable
EQUD    &000fff ;1


.endofstack
]:P%+=1024:O%+=1024:[OPT opt%
.startofstack
]
NEXT
:
fiqinsts=(fiqend-fiqbase)/4
PRINT"Number of FIQ instructions: ";fiqinsts
IF fiqinsts>58 THEN ERROR 255,"FIQ code too large"
ENDPROC



REM A set of long addressing routines
REM v1.22 � 1993 Phoenix

REM v1.10 - worked ok
REM v1.20 - now re-aligns P%/O%, before coding (- works if OS_WriteS mis-aligns P%)
REM v1.21 - won't stop the assembly if the address is smaller than 256 (in FNlong_adr)
REM v1.22 - better range errors (now warnings) in both - errors now also give current P%

REM These routines can load the address of ANY location, using either 1,2 or
REM 3 ADD or SUB instructions - from 0K -> 16384K!!!

REM WARNING: You must use opt%, for the OPT code, or this routine will not
REM          work correctly

REM For addresses from 0 to 256bytes, just use Basic's 'ADR Rx,<addr>'

REM Syntax for addresses from 256bytes to 64K:
REM FNlong_adr("<condition>",<dest. reg>,<address>)

REM Syntax for addresses from 64K to 16384K:
REM FNmega_adr("<condition>",<dest. reg>,<address>)

REM An example:
REM .....
REM CMP R0,#65
REM FNmega_adr("NE",1,FarAway)
REM .....

DEF FNlong_adr(cond$,reg%,addr%)                :REM v1.23 � 1993 Phoenix
LOCAL cond%,gap%,bit1%,bit2%,optcode%,optcode1%,optcode2%
IF reg%<0 OR reg%>&F THEN ERROR 255,"FNadr: Bad register"
IF reg%=&F THEN ERROR 255,"FNadr: Can't handle PC/R15 as a register"
IF cond$="" OR cond$="  " THEN cond$="AL"
cond%=INSTR(" EQ NE CS CC MI PL VS VC HI LS GE LT GT LE AL NV",cond$)
IF cond%=0 THEN cond%=INSTR(" eq ne cs cc mi pl vs vc hi ls ge lt gt le al nv",cond$)
IF cond%=0 THEN ERROR 255,"FNadr: Bad condition"
IF (opt% AND 3)=0 OR (opt% AND 3)=1 THEN [OPT opt%:MOV R0,R0:MOV R0,R0:]:=opt%
:
[OPT opt%:MOV R0,R0:]   :REM sync P%/O% - make sure on a word boundary
P%=P%-4:O%=O%-4         :REM get back to last word boundary
:
cond%=(cond%+1-3)/3
gap%=ABS(addr%-P%-8)
IF gap%<&FF PRINT"FNadr: Range <256 in FNlong_adr at &";~P%;" - ADR would do..."
IF gap%>&FFFF ERROR 255,"FNadr: Address too large at &"+STR$~P%+", use FNmega_adr instead"
:
IF addr%<P% THEN
 optcode%=&02400000
ELSE
 optcode%=&02800000
ENDIF
:
bit1%=gap% AND &FF
bit2%=(gap% AND &FF00)>>>8
:
IF bit1%=0 THEN PRINT"FNadr: ADR would do... at &";~P%
:
optcode%=optcode% OR (cond%<<28)
optcode%=optcode% OR (reg%<<12)
optcode1%=optcode% OR (&F<<16)
optcode1%=optcode1% OR bit1%
:
optcode2%=optcode% OR &C<<8
optcode2%=optcode2% OR (reg%<<16)
optcode2%=optcode2% OR bit2%
:
[OPT opt%:EQUD optcode1%:EQUD optcode2%:]
=0

DEF FNmega_adr(cond$,reg%,addr%)                :REM v1.23 � 1993 Phoenix
LOCAL cond%,gap%,bit1%,bit2%,bit3%,optcode%,optcode1%,optcode2%,optcode3%
IF reg%<0 OR reg%>&F THEN ERROR 255,"FNadr: Bad register"
IF reg%=&F THEN ERROR 255,"FNadr: Can't handle PC/R15 as a register"
IF cond$="" OR cond$="  " THEN cond$="AL"
cond%=INSTR(" EQ NE CS CC MI PL VS VC HI LS GE LT GT LE AL NV",cond$)
IF cond%=0 THEN cond%=INSTR(" eq ne cs cc mi pl vs vc hi ls ge lt gt le al nv",cond$)
IF cond%=0 THEN ERROR 255,"FNadr: Bad condition"
IF (opt% AND 3)=0 OR (opt% AND 3)=1 THEN [OPT opt%:MOV R0,R0:MOV R0,R0:MOV R0,R0:]:=opt%
:
[OPT opt%:MOV R0,R0:]   :REM sync P%/O% - make sure on a word boundary
P%=P%-4:O%=O%-4         :REM get back to last word boundary
:
cond%=(cond%+1-3)/3
gap%=ABS(addr%-P%-8)
IF gap%<&FFFF PRINT"FNadr: Range <64K in FNmega_adr at &";~P%;" - FNlong_adr would do..."
IF gap%>&FFFFFF ERROR 255,"FNadr: Range >16384K!!! in FNmega_adr at &"+STR$~P%+" - check program..."
:
IF addr%<P% THEN
 optcode%=&02400000
ELSE
 optcode%=&02800000
ENDIF
:
bit1%=gap% AND &FF
bit2%=(gap% AND &FF00)>>>8
bit3%=(gap% AND &FF0000)>>>16
:
IF bit1%=0 AND bit2%=0 THEN PRINT"FNadr: ADR would do... at &";~P%
IF bit1%=0 AND bit2%>0 THEN PRINT"FNadr: FNlong_adr would do... at &";~P%
:
optcode%=optcode% OR (cond%<<28)
optcode%=optcode% OR (reg%<<12)
optcode1%=optcode% OR (&F<<16)
optcode1%=optcode1% OR bit1%
:
optcode2%=optcode% OR &C<<8
optcode2%=optcode2% OR (reg%<<16)
optcode2%=optcode2% OR bit2%
:
optcode3%=optcode% OR &8<<8
optcode3%=optcode3% OR (reg%<<16)
optcode3%=optcode3% OR bit3%
:
[OPT opt%:EQUD optcode1%:EQUD optcode2%:EQUD optcode3%:]
=0

