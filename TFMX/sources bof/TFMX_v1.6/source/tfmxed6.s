	opt	o-

SmplSize	equ	$28000

id_DiskType	equ	$18
id_DiskState	equ	$8
tf_CharData	equ	$22
tf_Modulo	equ	$26
fc_FileName	equ	$0
pr_CurrentDir	equ	$98
pr_CLI		equ	$AC
pr_MsgPort	equ	$5C
do_ToolTypes	equ	$36

ERROR_NO_MORE_ENTRIES	equ	$E8

	include	devpacmacros.i

****************************************************************************
	SECTION	Tfmx_Editor,CODE

* some startup code to make a Workbench execute look like the CLI
* based loosely on RKM Vol 1 page 4-36

* Include this at the front of your program
* after any other includes
* note that this needs exec/exec_lib.i

Begin
	nop

	move.l	4.w,a6
	move.l	$114(a6),a4

	tst.l	pr_CLI(a4)
	bne.s	.end_startup		; do CLI setup

* we were called from the Workbench
.fromWorkbench
	lea	pr_MsgPort(a4),a0
	CALLEXEC WaitPort		; wait for a message
	lea	pr_MsgPort(a4),a0
	CALLEXEC GetMsg			; then get it
	move.l	d0,returnMsg		; save it for later reply

	pea	.do_main(pc)
	bra	ToolParse		; do WB setup

.end_startup
	bsr	DosParse

.do_main
	bsr	ProgStart		; call our program

* returns to here with exit code in d0
	move.l	d0,-(sp)		; save it

	move.l	returnMsg(pc),d2
	beq.s	.exitToDOS		; if I was a CLI

	move.l	4.w,a6
	jsr	_LVOForbid(a6)

	move.l	d2,a1
	move.l	4.w,a6
	jsr	_LVOReplyMsg(a6)
.exitToDOS
	move.l	(sp)+,d0		; exit code
	rts

* startup code variable
returnMsg	dc.l	0

DosParse
; Before initializing anything, get parameters and modify variables...
	sf	(a0,d0.w)
.varslp
	cmp.b	#'-',(a0)
	bne	.nextspace
	addq.l	#1,a0
.varslp2
	move.b	(a0)+,d0
	cmp.b	#$20,d0
	ble	.exit
	or.w	#$20,d0
	cmp.b	#'l',d0
	bne.s	.notl
; low memory switch... do 2 plane editor
	move.w	#2,NewScreenRec+8
	move.l	#$4380,PictSizeVal
	move.l	#mod2colp.MSG,lbL008170
	move.w	#$0A00,RedValues+2
	move.w	#$0A0F,GreenValues+2
	move.w	#$0A00,BlueValues+2
	bra.s	.varslp2
.notl
	cmp.b	#'s',d0
	bne.s	.nots
; sample buffer switch... completely adjustable
	bsr	Sgetnum
	moveq	#1,d2
	swap.w	d2
	cmp.l	d2,d1
	bge.s	.sisbig
	move.l	d2,d1
.sisbig
	move.l	d1,SmplSizeVal
	bra.s	.nextspace2
.nots
	cmp.b	#'p',d0
	bne.s	.notp
; playrate storage
	bsr	Sgetnum
	cmp.w	#28,d1
	ble.s	.ptoosmall
	moveq	#28,d1
.ptoosmall
	move.w	d1,PlayRate7V
	bra.s	.nextspace2
.notp
	cmp.b	#'f',d0
	bne.s	.notf
; turn off fastdir
	move.b	#$2A,FstdButtonImage
	clr.w	FstdFlag
	bra	.varslp2
.notf
	bra.s	.usage
.nextspace2
;	subq.l	#1,a0
	bra	.varslp2
.nextspace
	cmp.b	#$20,(a0)+
	beq	.varslp
	bgt.s	.nextspace
.exit
	rts

.usage
	lea	doslibrary.MSG,a1
	move.l	4.w,a6
	jsr	_LVOOldOpenLibrary(a6)
	move.l	d0,a5
	tst.l	d0
	beq.s	.reallyreturn
	exg	a5,a6
	jsr	_LVOOutput(a6)
	move.l	d0,d1
	move.l	#.usagetxt,d2
	move.l	d2,a0
	moveq	#-1,d3
.rrlp
	tst.b	(a0)+
	dbeq	d3,.rrlp
	not.l	d3
	jsr	_LVOWrite(a6)
	exg	a5,a6
.reallyreturn
	move.l	a5,d0
	beq.s	.byebye
	move.l	d0,a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)
.byebye
	rts
.usagetxt
	dc.b	"Usage: tfmxed [-flags]...",10
	dc.b	"where flags is one or more of:",10
	dc.b	" l       less colors and more memory",10
	dc.b	" s(num)  sample buffer size (default $28000)",10
	dc.b	" p(num)  sets 7v playrate in kHz (default 18, max 28)",10
	dc.b	" f       turns off fastdir function",10
	dc.b	0
	even

Sgetnum
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d0
	cmp.b	#'$',(a0)
	seq	d2
	bne.s	.nrloop
	addq.l	#1,a0
.nrloop
	move.b	(a0)+,d0
	cmp.b	#' ',d0
	bls.s	.nrnextspace2
	cmp.b	#'0',d0
	blo.s	.nrnextspace2
	cmp.b	#'a',d0
	ble.s	.nrnotlc
	sub.b	#$20,d0
.nrnotlc
	cmp.b	#'F',d0
	bhi.s	.nrnextspace2
	tst.b	d2
	beq.s	.nrdecimal
	cmp.b	#'9',d0
	bls.s	.nrgoth
	sub.b	#'A'-10,d0
	blo.s	.nrnextspace2
.nrgoth
	and.b	#$F,d0
	lsl.l	#4,d1
	add.l	d0,d1
	bra.s	.nrloop
.nrdecimal
	cmp.b	#'9',d0
	bhi.s	.nrnextspace2
	and.b	#$F,d0
	add.l	d1,d1
	move.l	d1,d3
	add.l	d3,d3
	add.l	d3,d3
	add.l	d3,d1
	add.l	d0,d1
	bra.s	.nrloop
.nrnextspace2
	rts
	rts

ToolParse
	lea	doslibrary.MSG(pc),a1
	moveq	#34,d0
	move.l	4.w,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_DosBase
	beq	.ouch
	move.l	returnMsg,a2
	move.l	$24(a2),a3		sm_ArgList

	move.l	_DosBase,a6
	move.l	(a3),d1			wa_Lock
	move.l	d1,d2
;	jsr	_LVOParentDir(a6)
;	move.l	d0,currentDirLock
;	move.l	d0,d1
	jsr	_LVOCurrentDir(a6)	nice for the editor itself

	move.l	4(a3),a0
	lea	tfmxed.info.MSG,a1
	move.b	(a0)+,d0
.copynmlp
	move.b	d0,(a1)+
	move.b	(a0)+,d0
	bne.s	.copynmlp

	movem.l	a0-a3,-(a7)
	move.l	d2,d1
	bsr	FixOurNames
	movem.l	(a7)+,a0-a3

	lea	tfmxed.info.MSG,a1
	moveq	#-1,d0
.findendlp
	tst.b	(a1)+
	dbeq	d0,.findendlp
	not.w	d0
	subq.w	#1,d0
	subq.w	#1,a1
.findnmendlp
	cmp.b	#' ',-(a1)
	dbne	d0,.findnmendlp
	sf	1(a1)

	move.l	4.w,a6
	lea	iconlibrary.MSG(pc),a1
	moveq	#34,d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IconBase
	beq	.ouch

	lea	tfmxed.info.MSG,a0
	move.l	_IconBase,a6
	jsr	_LVOGetDiskObject(a6)
	move.l	d0,a2
	tst.l	d0
	beq	.ouch

	move.l	do_ToolTypes(a2),a3
	move.l	a3,a0
	lea	.color(pc),a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	.nocolor
	move.l	d0,a1
	lea	.no(PC),a0		color off?
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	.nocolor
; color mode off
	move.w	#2,NewScreenRec+8
	move.l	#$4380,PictSizeVal
	move.l	#mod2colp.MSG,lbL008170
	move.w	#$0A00,RedValues+2
	move.w	#$0A0F,GreenValues+2
	move.w	#$0A00,BlueValues+2
.nocolor
	move.l	a3,a0
	lea	.fastdir(pc),a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	.nofastdir
	move.l	d0,a1
	lea	.no(PC),a0		fastdir off?
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	.nofastdir
	move.b	#$2A,FstdButtonImage
	clr.w	FstdFlag
.nofastdir
	move.l	a3,a0
	lea	.samplemem(pc),a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	.nosamplemem
	move.l	d0,a0
	bsr	Sgetnum
	moveq	#1,d2			ensure samplemem of >=64k
	swap.w	d2
	cmp.l	d2,d1
	bge.s	.sisbig
	move.l	d2,d1
.sisbig
	move.l	d1,SmplSizeVal		samplemem size is now...
.nosamplemem
	move.l	a3,a0
	lea	.playrate(pc),a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	.noplayrate
	move.l	d0,a0
	bsr	Sgetnum
	cmp.w	#28,d1			playrate must be <28kHz
	ble.s	.ptoosmall
	moveq	#28,d1
.ptoosmall
	move.w	d1,PlayRate7V
.noplayrate
	move.l	a2,a0
	jsr	_LVOFreeDiskObject(a6)
.ouch
	move.l	_IconBase,d0
	beq.s	.noiconlib
	move.l	d0,a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)
.noiconlib
	move.l	_DosBase,d0
	beq.s	.nodoslib
	move.l	d0,a1
;	move.l	currentDirLock,d1
;	bmi.s	.nounlock
;	jsr	_LVOUnLock(a6)		unlock our dir
;.nounlock
;	move.l	a6,a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)
.nodoslib
	rts

.color
	dc.b	"COLOR",0
.fastdir
	dc.b	"FASTDIR",0
.playrate
	dc.b	"PLAYRATE",0
.samplemem
	dc.b	"SAMPLEMEM",0
.no
	dc.b	"NO|OFF|0",0
;.yes
;	dc.b	"YES|ON|1",0

iconlibrary.MSG
	dc.b	"icon.library",0
tfmxed.info.MSG
	dc.b	"                                                  ",0
FixedNamesFlag
	dc.b	1
	even
currentDirLock
	dc.l	-1
_IconBase
	dc.l	0

FixOurNames
	bclr	#0,FixedNamesFlag
	bne.s	*+4
	rts
.ourlock

	move.l	_DosBase,A6
	jsr	_LVODupLock(a6)

	move.l	d0,a2
	tst.l	d0
	bne.s	*+4
	rts
	moveq	#0,d4

.treelp
	move.l	a2,d1
	move.l	#DiskInfoBlock,d2
	move.l	d2,a3
	jsr	_LVOExamine(a6)

	move.l	a2,d1
	jsr	_LVOParentDir(a6)
	move.l	d0,d2
	move.l	a2,d1
	jsr	_LVOUnLock(a6)
	move.l	d2,a2

	lea	8(a3),a0
	move.l	a0,a1
	moveq	#-1,d0
.getnamlp
	tst.b	(a0)+
	dbeq	d0,.getnamlp
	sf	(a0)
	moveq	#'/',d1
	move.l	a2,d3
	tst.l	d3
	bne.s	*+4
	moveq	#':',d1
	move.b	d1,-(a0)

	not.w	d0
	addq.w	#1,d0
	move.w	d0,d1

	add.w	d1,d4

	lea	.buffer(pc),a0
	bsr.s	.fixit

	tst.l	d3
	bne.s	.treelp

.fixem
	move.l	d4,d1
	lea	.buffer(pc),a1
	sf	(a1,d1.w)

	lea	DF0songs.MSG,a0
	bsr.s	.fixit
	lea	DF0samples.MSG,a0
	bsr.s	.fixit
	lea	DF0routines.MSG,a0
	bsr.s	.fixit
	lea	DF0pattern.MSG,a0
	bsr.s	.fixit
	lea	DF0macros.MSG,a0
	bsr.s	.fixit
	lea	tfmxed.info.MSG,a0
	bsr.s	.fixit

.unlock
	move.b	(a0)+,d0
	move.l	a2,d1
	jsr	_LVOUnLock(a6)
	rts

.fixit
	movem.l	d0-d2/a0-a2,-(a7)
	move.l	a0,d0
.fixlp3
	tst.b	(a0)+
	bne.s	.fixlp3
	subq.w	#1,a0
	move.l	a0,a2
	sub.w	d1,a2
.fixlp
	move.b	-(a2),-(a0)
	cmp.l	a2,d0
	bne.s	.fixlp
.fixlp2
	move.b	(a1)+,d0
	bne.s	*+8
	movem.l	(a7)+,d0-d2/a0-a2
	rts
	move.b	d0,(a2)+
	bra.s	.fixlp2

.buffer
	dc.b	"                                               ",0
	even


ProgStart
	move.l	SP,SaveSP
	move.l	#lbL00976E,lbL007C00
	clr.w	lbW007B66
	clr.w	CursorState
	move.w	#20,ButtonReptCtr
	move.l	#$FFFFFFFF,lbL007BA2
	move.l	#$FFFFFFFF,lbL007BAC
	move.l	#$FFFFFFFF,lbL007BB6
	lea	MainDecalList,A4
	move.l	A4,CurrentDecalListPtr
	move.w	#1,lbW007B6A
	move.w	#1,ActivePageNr
	move.w	#1,lbW007B72
	move.b	#$1F,ScrapVar
	move.l	#lbB007CAB,lbL007B6C
	move.l	#lbC00071C,KeyHexHook
	lea	$DFF101,A0
	move.l	#lbC000B10,KeyDownArrowHook
	move.l	#lbC000B4C,KeyUpArrowHook
	move.l	#TrackGadgetList,CurrentPageGList
	lea	MainGadgetList,A1
	move.l	A1,CurrentGadgetList
	move.l	#lbC000660,KeyGenericHook
	move.b	#6,lbB007CA4
	move.b	#7,lbB007CA5
	move.b	#0,lbB007D92
	move.w	#$FFFF,PatArrowOldY
	clr.w	lbW007B66
	move.l	4,A6
	lea	intuitionlibr.MSG(PC),A1
	jsr	_LVOOldOpenLibrary(A6)
	move.l	D0,_IntuitionBase
	beq	lbC000AEE
	lea	graphicslibra.MSG(PC),A1
	jsr	_LVOOldOpenLibrary(A6)
	move.l	D0,_GfxBase
	beq	lbC000AE0
	move.l	D0,A6
	lea	lbL007AAE,A0
	jsr	_LVOOpenFont(A6)
	move.l	D0,lbL007C7E
	beq	lbC000AC2
	move.l	D0,A0
	move.l	tf_CharData(A0),TopazData
	move.w	tf_Modulo(A0),lbW007C88
	move.l	4,A6
	lea	doslibrary.MSG(PC),A1
	jsr	_LVOOldOpenLibrary(A6)
	move.l	D0,_DosBase
	beq	lbC000AD2
	move.l	4,A6
	move.l	PictSizeVal,D0
	move.l	#2,D1
	jsr	_LVOAllocMem(A6)
	move.l	D0,PictBuffer
	beq	lbC000AAA
	move.l	#$11170,D0
	clr.l	D1
	jsr	_LVOAllocMem(A6)
	move.l	D0,ILBMUnpackBuffer
	beq	lbC000A94
	lea	lbL008170,A5
	bsr	LoadILBM
	beq	lbC000AF6
	move.l	4,A6
	move.l	ILBMUnpackBuffer,A1
	move.l	#$11170,D0
	jsr	_LVOFreeMem(A6)
	move.l	#$C800,D0
	move.l	#$10000,D1
	jsr	_LVOAllocMem(A6)
	move.l	D0,MdatBuffer
	beq	lbC000A94
	move.l	D0,MdatBufEndPtr
	add.l	#$3004,MdatBufEndPtr
	move.l	SmplSizeVal,D0
	move.l	#$10002,D1
	jsr	_LVOAllocMem(A6)
	move.l	D0,SmplBuffer
	beq	lbC000A7E
	add.l	#4,D0
	move.l	D0,SmplBufEndPtr
; ROUTINES: Replace me with LoadSeg!  Please?
	move.l	#$A000,D0
	clr.l	D1
	jsr	_LVOAllocMem(A6)
	move.l	D0,RoutBuffer
	beq	lbC000A68
	move.l	#$3A98,D0
	move.l	#$10000,D1
	jsr	_LVOAllocMem(A6)
	move.l	D0,InfoBuffer
	beq	lbC000A52
	move.l	D0,A0
	move.l	#$2800,$2400(A0)
	lea	lbL0081AC,A5
	bsr	ReadFile
	beq	lbC000A3C
	lea	lbL00817C,A5
	clr.b	D5
	bsr	ClearTracks
	move.l	_DosBase,A6
	move.l	#songsmdatempt.MSG,D1
	move.l	#$3ED,D2
	bsr	LoadMdat
	beq	lbC000A3C
	lea	$DFF002,A5
	move.l	_IntuitionBase(PC),A6
	lea	NewScreenRec,A0
	jsr	_LVOOpenScreen(A6)
	move.l	D0,ScreenPtr
	beq	lbC000A3C
	lea	NewWindowRec,A0
	jsr	_LVOOpenWindow(A6)
	move.l	D0,WindowPtr
	beq	lbC000A30
	bsr	GetPlaneAddrs
	move.l	4,A6
	move.l	$114(a6),a0
;	sub.l	A1,A1
;	jsr	_LVOFindTask(A6)
	move.l	a0,lbL007C98
	move.l	a0,Misc2TaskPtr
	move.l	a0,ConsoleTaskPtr
;	move.l	d0,a0
	move.l	pr_CurrentDir(a0),d1
	bsr	FixOurNames
	move.l	4.w,a6
	moveq.l	#-1,D0
	jsr	_LVOAllocSignal(A6)
	move.b	D0,Defunct3SigBit
	bmi	lbC0009FE
	move.b	D0,lbB0082E3
	move.l	GlobalSigMask,D1
	bset	D0,D1
	move.l	D1,GlobalSigMask
	moveq.l	#-1,D0
	jsr	_LVOAllocSignal(A6)
	move.b	D0,Defunct2SigBit
	bmi	lbC0009EC
	move.l	WindowPtr,A0
	move.l	$56(A0),A0
	move.b	D0,15(A0)
	move.l	GlobalSigMask,D1
	bset	D0,D1
	move.l	D1,GlobalSigMask
	moveq.l	#-1,D0
	jsr	_LVOAllocSignal(A6)
	move.b	D0,Defunct1SigBit
	bmi	lbC0009DA
	move.l	GlobalSigMask,D1
	bset	D0,D1
	move.l	D1,GlobalSigMask
	moveq.l	#-1,D0
	jsr	_LVOAllocSignal(A6)
	move.b	D0,MidiSigBit
	bmi	lbC0009C8
	move.l	GlobalSigMask,D1
	bset	D0,D1
	move.l	D1,GlobalSigMask
	lea	ConReadPort,A1
	jsr	_LVOAddPort(A6)
	lea	Misc2MsgPort,A1
	jsr	_LVOAddPort(A6)
	lea	ConsoleMsgPort,A1
	jsr	_LVOAddPort(A6)
	lea	lbL008334,A1
	move.l	#ConsoleMsgPort,14(A1)
	clr.l	D0
	clr.l	D1
	lea	ConsoleIOReq,A1
	move.l	WindowPtr,ConsoleIOReqWindowPtr
	move.l	#$30,lbL0083A8
	clr.l	D3
	lea	consoledevice.MSG,A0
	jsr	_LVOOpenDevice(A6)
	tst.l	d0
	bne	lbC0009AB
	move.l	PlanePtr0,A0
	move.l	PlanePtr1,A1
	move.l	a0,a2
	move.l	a1,a3
	cmp.l	#$10E00,PictSizeVal
	bne.s	.skip
	move.l	PlanePtr2,A2
	move.l	PlanePtr3,A3
.skip
	clr.w	D0
	moveq	#11,D2
lbC00040C
	move.w	D0,(A0)
	move.w	D0,(A1)
	move.w	D0,(A2)
	move.w	D0,(A3)
	add.l	#$50,A0
	add.l	#$50,A1
	add.l	#$50,A2
	add.l	#$50,A3
	dbra	D2,lbC00040C
	bsr	SetScreenColors
	bsr	SetMouseColors
	bsr	DrawCurrentGadgetList
	lea	TrackGadgetList,A0
	bsr	DrawGadgetList
	bsr	DrawTracks
	bsr	DrawSongInfo
	move.l	RoutBuffer,A0
	move.l	MdatBuffer,D0
	move.l	SmplBuffer,D1
	move.l	#ChipBuffer,d2
	move.w	PlayRate7V,d3
	jsr	$34(A0)
	move.l	RoutBuffer,A0
	jsr	$38(A0)
	move.l	RoutBuffer,A0
	jsr	$4C(A0)
	move.l	$10(A0),A1
	move.l	#lbC0012B2,2(A1)
	move.l	12(A0),A1
	move.l	A1,PlyrPatternBlock
	move.l	4(A0),A2
	move.l	A2,PlyrMasterBlock
	move.l	A0,PlyrInfoBlock
	lea	lbW0080F8,A1
	move.w	4(A1),D3
	move.w	2(A1),D4
	move.w	#1,D0
	move.l	RoutBuffer,A6
	jsr	$68(A6)
	move.b	#6,$47(A2)
	lea	lbC001BBE,A1
	move.l	RoutBuffer,A0
	jsr	$50(A0)
	move.l	A0,MacroCmdTablePtr
	move.l	A1,NoteNameTablePtr
	move.l	A2,PatternCmdTablePtr
	move.l	RoutBuffer,D0
	move.l	#$FFFFFFFF,MacroCmdNameCount
lbC0004F2
	cmp.l	#$FFFFFFFF,(A0)
	beq	lbC00050C
	add.l	D0,(A0)+
	add.l	#1,MacroCmdNameCount
	bra	lbC0004F2

lbC00050C
	cmp.l	#$FFFFFFFF,(A1)
	beq	lbC00051C
	add.l	D0,(A1)+
	bra	lbC00050C

lbC00051C
	cmp.l	#$FFFFFFFF,(A2)
	beq	lbC00052C
	add.l	D0,(A2)+
	bra	lbC00051C

lbC00052C
	move.l	lbL008398,lbL0083C8
	move.l	lbL00839C,lbL0083CC
lbC000540
	clr.b	KeyASCIIKeyCode
	bsr	lbC001B74
lbC00054A
	st	lbW007C8A
	move.l	4,A6
	move.l	GlobalSigMask,D0
	jsr	_LVOWait(A6)
	move.l	d0,d1
;	move.l	GlobalSigMask,D1
	clr.l	D0
	jsr	_LVOSetSignal(A6)
	tst.w	lbW007C94
	beq	lbC000580
	bsr	lbC001C40
	move.l	4,A6
lbC000580
	move.w	lbW007C96,D0
	beq	lbC0005C0
	clr.w	lbW007C96
	cmp.w	#1,D0
	bne	lbC0005A0
	bsr	lbC001A5E
	bra	lbC0005C0

lbC0005A0
	cmp.w	#2,D0
	bne	lbC0005B0
	bsr	lbC0019E4
	bra	lbC0005C0

lbC0005B0
	cmp.w	#3,D0
	bne	lbC0005C0
	bsr	lbC005BD0
	bra	lbC0005C0

lbC0005C0
	move.l	4,A6
	move.l	WindowPtr,A0
	move.l	$56(A0),A0
	jsr	_LVOGetMsg(A6)
	tst.l	D0
	bne	lbC000952
ConBackIn
	lea	ConReadPort,A0
	jsr	_LVOGetMsg(A6)
	tst.l	D0
	beq	lbC00054A
	cmp.b	#0,KeyASCIIKeyCode
	beq	lbC00054A
	cmp.b	#$9B,KeyASCIIKeyCode
	beq	lbC0007A0
	move.l	KeyGenericHook,A6
	jmp	(A6)

lbC00060A
	move.l	SaveSP,a7
	bra	lbC000540

lbC00060E
	cmp.b	#$7E,KeyASCIIKeyCode	~
	beq	lbC00060A
	moveq.l	#$35,D1
	moveq.l	#0,D2
	bsr	ClearButton
	moveq.l	#10,D0
	moveq.l	#$35,D1
	moveq.l	#0,D2
	bsr	RenderStuff
	clr.w	lbW007BA0
	clr.w	lbW007BAA
	clr.w	lbW007BB4
	move.l	#lbC000660,KeyGenericHook
;	bra	lbC000660

lbC000660
	cmp.b	#$5B,KeyASCIIKeyCode	[
	beq	KeyToggleMetFlag
	cmp.b	#$2E,KeyASCIIKeyCode	.
	beq	lbC001476
	cmp.b	#$2C,KeyASCIIKeyCode	,
	beq	lbC001482
	cmp.b	#$70,KeyASCIIKeyCode	p
	beq	KeyGotoPattPage
	cmp.b	#$74,KeyASCIIKeyCode	t
	beq	KeyGotoTrackPage
	cmp.b	#$6D,KeyASCIIKeyCode	m
	beq	KeyGotoMacroPage
	cmp.b	#$6C,KeyASCIIKeyCode	l
	beq	KeyGotoSmpLstPage
	cmp.b	#$72,KeyASCIIKeyCode	r
	beq	KeyGotoRecordPage
	cmp.b	#9,KeyASCIIKeyCode	tab
	beq	KeyPlayStop
	cmp.b	#$20,KeyASCIIKeyCode	sp
	beq	KeyPlayCont
	cmp.b	#13,KeyASCIIKeyCode	cr
	beq	lbC001538
	clr.w	D0
	move.b	KeyASCIIKeyCode,D0
	cmp.b	#$2F,D0
	bcs	lbC00060A
	cmp.b	#$3A,D0
	bcs.s	lbC000710
	cmp.b	#$60,D0
	bcs	lbC00060A
	cmp.b	#$67,D0
	bcc	lbC00060A
	subq.b	#$7,D0
lbC000710
	and.b	#$F,D0
	move.l	KeyHexHook,A6
	jmp	(A6)

lbC00071C
	clr.w	D1
	move.b	lbB007D92,D1
	lsr.w	#1,D1
	and.w	#$1E,D1
	move.l	MdatBuffer,A0
	clr.l	D2
	move.b	lbB007CA5,D2
	subq.l	#7,D2
	add.l	lbL007B62,D2
	asl.l	#4,D2
	add.l	D2,A0
	add.l	#$800,A0
	move.w	#$FFF0,D3
	move.b	lbB007D92,D4
	and.w	#3,D4
	eor.w	#3,D4
	beq	lbC000770
	subq.w	#1,D4
lbC000768
	asl.w	#4,D0
	rol.w	#4,D3
	dbra	D4,lbC000768
lbC000770
	move.w	0(A0,D1.W),D2
	and.w	D3,D2
	or.w	D2,D0
	move.w	D0,0(A0,D1.W)
	bsr	lbC005D46
	move.b	lbB007D92,D0
	cmp.b	ScrapVar,D0
	beq	lbC000798
	addq.b	#1,lbB007D92
lbC000798
	bsr	DrawTracks
	bra	lbC000934

lbC0007A0			; csi
	bsr	lbC001B74
	lea	ConReadPort,A0
	jsr	_LVOGetMsg(A6)
	tst.l	D0
	beq	lbC0007A0
	tst.l	SampleRoutBuffer
	beq	lbC0007C6
	move.l	lbL007C72,A0
	jmp	(A0)

lbC0007C6
	cmp.b	#$30,KeyASCIIKeyCode		f1
	beq	KeyDoCut
	cmp.b	#$31,KeyASCIIKeyCode		f2
	beq	KeyDoPas
	cmp.b	#$32,KeyASCIIKeyCode		f3
	beq	KeyDoClr
	cmp.b	#$38,KeyASCIIKeyCode		f9
	beq	lbC001562
	cmp.b	#$39,KeyASCIIKeyCode		f10
	beq	lbC00156E
	cmp.b	#$41,KeyASCIIKeyCode		up
	beq	KeyUpArrow
	cmp.b	#$42,KeyASCIIKeyCode		dn
	beq	KeyDownArrow
	cmp.b	#$43,KeyASCIIKeyCode		lf
	beq	lbC0008C8
	cmp.b	#$44,KeyASCIIKeyCode		rt
	beq	lbC0008D0
	cmp.b	#$54,KeyASCIIKeyCode		scrldn
	beq	lbC0008B4
	cmp.b	#$53,KeyASCIIKeyCode		scrlup
	beq	lbC0008A0
	tst.l	SampleRoutBuffer
	bne	lbC00060A
	cmp.b	#$33,KeyASCIIKeyCode		f4
	beq	lbC00148E
	cmp.b	#$34,KeyASCIIKeyCode		f5
	beq	lbC0014C4
	cmp.b	#$3F,KeyASCIIKeyCode		help
	beq	lbC0008D8
	bra	lbC00060A

KeyDownArrow
	bsr	lbC00088C
	bra	lbC00060A

KeyUpArrow
	bsr	lbC000896
	bra	lbC00060A

lbC00088C
	move.l	KeyDownArrowHook,A6
	jsr	(A6)
	rts

lbC000896
	move.l	KeyUpArrowHook,A6
	jsr	(A6)
	rts

lbC0008A0
	bsr	lbC00088C
	bsr	lbC00088C
	bsr	lbC00088C
	bsr	lbC00088C
	bra	lbC00060A

lbC0008B4
	bsr	lbC000896
	bsr	lbC000896
	bsr	lbC000896
	bsr	lbC000896
	bra	lbC00060A

lbC0008C8
	bsr	lbC0008EA
	bra	lbC00060A

lbC0008D0
	bsr	lbC00091E
	bra	lbC00060A

lbC0008D8
	tst.w	ActivePageNr
	bmi	lbC00060A
	bsr	SetupHelpPage
	bra	lbC00060A

lbC0008EA	;rt
	move.b	lbB007D92,D0
	cmp.b	ScrapVar,D0
	beq.s	lbC00091C
	addq.b	#1,lbB007D92

lbC000902
	clr.w	D0
	move.b	lbB007D92,D0
	move.l	lbL007B6C,A0
	bsr	lbC005D46
	move.b	0(A0,D0.W),lbB007CA4
lbC00091C
	rts

lbC00091E	;lf
	tst.b	lbB007D92
	beq.s	lbC00094E
	subq.b	#1,lbB007D92
	bra	lbC000902

lbC000934
	clr.w	D0
	move.b	lbB007D92,D0
	move.l	lbL007B6C,A0
	bsr	lbC005D46
	move.b	0(A0,D0.W),lbB007CA4
lbC00094E
	bra	lbC00060A

lbC000952
	move.l	D0,TmpMessage
	move.l	D0,A0
	move.w	$18(A0),D7
	move.l	WindowPtr,A0
	move.l	12(A0),D1
;	sub.l	#$140000,D1
	move.l	D1,lbL007BC6
	move.l	4,A6
	move.l	TmpMessage,A1
	jsr	_LVOReplyMsg(A6)
	cmp.w	#$68,D7
	bne	lbC00060A
	move.l	lbL007BC6,D1
	move.l	CurrentGadgetList,A0
	bsr	lbC001718
	move.l	CurrentPageGList,A0
	bsr	lbC001718
	bra	lbC00060A

MainQuitOK
	bsr	lbC001A5E
	move.l	RoutBuffer(PC),A0
	jsr	$28(A0)			alloff
	move.l	RoutBuffer(PC),A0
	jsr	$3C(A0)			vbioff
lbC0009AB
	move.l	4,A6
	clr.l	D0
	move.b	MidiSigBit,D0
	jsr	_LVOFreeSignal(A6)
lbC0009C8
	move.l	4,A6
	clr.l	D0
	move.b	Defunct1SigBit,D0
	jsr	_LVOFreeSignal(A6)
lbC0009DA
	move.l	4,A6
	clr.l	D0
	move.b	Defunct2SigBit,D0
	jsr	_LVOFreeSignal(A6)
lbC0009EC
	move.l	4,A6
	clr.l	D0
	move.b	Defunct3SigBit,D0
	jsr	_LVOFreeSignal(A6)
lbC0009FE
	move.l	4,A6
	lea	ConsoleIOReq(PC),A1
	jsr	_LVOCloseDevice(A6)
	lea	ConsoleMsgPort(PC),A1
	jsr	_LVORemPort(A6)
	lea	ConReadPort(PC),A1
	jsr	_LVORemPort(A6)
	lea	Misc2MsgPort(PC),A1
	jsr	_LVORemPort(A6)
lbC0009FF
	move.l	_IntuitionBase(PC),A6
	move.l	WindowPtr(PC),A0
	jsr	_LVOCloseWindow(A6)
lbC000A30
	move.l	_IntuitionBase(PC),A6
	move.l	ScreenPtr(PC),A0
	jsr	_LVOCloseScreen(A6)
lbC000A3C
	move.l	4,A6
	move.l	InfoBuffer,A1
	move.l	#$3A98,D0
	jsr	_LVOFreeMem(A6)
lbC000A52
	move.l	4,A6
	move.l	RoutBuffer,A1
	move.l	#$A000,D0
	jsr	_LVOFreeMem(A6)
lbC000A68
	move.l	4,A6
	move.l	SmplBuffer,A1
	move.l	SmplSizeVal,D0
	jsr	_LVOFreeMem(A6)
lbC000A7E
	move.l	4,A6
	move.l	MdatBuffer,A1
	move.l	#$C800,D0
	jsr	_LVOFreeMem(A6)
lbC000A94
	move.l	4,A6
	move.l	PictBuffer,A1
	move.l	PictSizeVal,D0
	jsr	_LVOFreeMem(A6)
lbC000AAA
;	move.l	#setmapmenu.MSG,D1
;	bsr	Execute
lbC000AB4
	move.l	4,A6
	move.l	_DosBase(PC),A1
	jsr	_LVOCloseLibrary(A6)
lbC000AC2
	move.l	_GfxBase,A6
	move.l	lbL007C7E,A1
	jsr	_LVOCloseFont(A6)
lbC000AD2
	move.l	4,A6
	move.l	_GfxBase(PC),A1
	jsr	_LVOCloseLibrary(A6)
lbC000AE0
	move.l	4,A6
	move.l	_IntuitionBase(PC),A1
	jsr	_LVOCloseLibrary(A6)
lbC000AEE
	move.l	SaveSP,SP
	rts

lbC000AF6
	move.l	4,A6
	move.l	ILBMUnpackBuffer,A1
	move.l	#$11170,D0
	jsr	_LVOFreeMem(A6)
	bra	lbC000A94




lbC000B10
	cmp.b	#14,lbB007CA5
	beq.s	lbC000B2A
	bsr	lbC005D46
	addq.b	#1,lbB007CA5
	rts
lbC000B2A
	cmp.l	#$1F8,lbL007B62
	beq.s	lbC000B4A
	addq.l	#1,lbL007B62
	bsr	lbC005D46
	bsr	DrawTracks
lbC000B4A
	rts


lbC000B4C
	cmp.b	#7,lbB007CA5
	beq.s	lbC000B66
	bsr	lbC005D46
	subq.b	#1,lbB007CA5
	rts
lbC000B66
	tst.l	lbL007B62
	beq.s	lbC000B4A
	subq.l	#1,lbL007B62
	bsr	lbC005D46
	bsr	DrawTracks
	rts

MainBeQuiet
	move.l	RoutBuffer,A0
	clr.l	D0
	jsr	$40(A0)
	move.l	RoutBuffer,A0
	moveq.l	#1,D0
	jsr	$40(A0)
	move.l	RoutBuffer,A0
	moveq.l	#2,D0
	jsr	$40(A0)
	move.l	RoutBuffer,A0
	moveq.l	#3,D0
	jsr	$40(A0)
	move.l	RoutBuffer,A0
	moveq.l	#4,D0
	jsr	$40(A0)
	move.l	RoutBuffer,A0
	moveq.l	#5,D0
	jsr	$40(A0)
	move.l	RoutBuffer,A0
	moveq.l	#6,D0
	jsr	$40(A0)
	move.l	RoutBuffer,A0
	moveq.l	#7,D0
	jsr	$40(A0)
	rts

MainPlayPrevTrackStep
	tst.w	lbW007BDC
	beq.s	.dont
	cmp.w	#$FFFD,ActivePageNr
	beq.s	.try
	tst.w	ActivePageNr
	bmi.s	.dont
.try
	bsr	GetSongStatsAddr
	move.w	$100(A0),D0
	move.l	PlyrPatternBlock,A0
	move.w	4(A0),D1
	cmp.w	D0,D1
	beq.s	.dont
	subq.w	#1,4(A0)
	move.l	RoutBuffer,A0
	move.w	CurrentSongNum,D0
	jsr	$60(A0)
.dont
	rts

MainPlayNextTrackStep
	tst.w	lbW007BDC
	beq.s	.dont
	cmp.w	#$FFFD,ActivePageNr
	beq.s	.try
	tst.w	ActivePageNr
	bmi.s	.dont
.try
	bsr	GetSongStatsAddr
	move.w	$140(A0),D0
	move.l	PlyrPatternBlock,A0
	move.w	4(A0),D1
	cmp.w	D0,D1
	beq.s	.dont
	addq.w	#1,4(A0)
	move.l	RoutBuffer,A0
	move.w	CurrentSongNum,D0
	jsr	$60(A0)
.dont
	rts

KeyToggleMetFlag
	eor.w	#1,MetronomeFlag
	lea	lbL009C80,A0
	eor.w	#3,4(A0)
	bra	lbC00060A

HelpRateSetter
	move.w	14(a0),d0
	add.w	PlayRate7V,d0
	cmp.w	#2,d0
	bhi.s	*+4
	moveq	#2,d0
	cmp.w	#28,d0
	bls.s	*+4
	moveq	#28,d0
	move.w	d0,PlayRate7V
	tst.w	lbW007BDC
	beq.s	HelpDrawRate
	bsr	SetPlayRate7V
HelpDrawRate
	move.w	PlayRate7V,d0
	move.b	#$4,CharYPos
	move.b	#$6,CharXPos
	bsr	Draw2HexDigits
	rts

SetPlayRate7V
	move.l	RoutBuffer,a6
	move.w	#$6000,d1		bra.w xxxx
	cmp.w	$74(a6),d1
	bne.s	.rts
	cmp.w	$78(a6),d1
	bne.s	.rts
	cmp.w	$7C(a6),d1
	bne.s	.rts
	cmp.w	$80(a6),d1
	bne.s	.rts
	jmp	$80(a6)
.rts
	rts

HelpToggleFlags
	move.w	14(A0),D0
	lea	FstdFlag,A1
	tst.w	0(A1,D0.W)
	beq	.on
	clr.w	0(A1,D0.W)
	move.w	#$812A,4(A0)
	move.b	7(A0),D1
	and.l	#$FF,D1
	move.l	#5,D2
	move.l	#$2A,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	rts
.on
	move.w	#1,0(A1,D0.W)
	move.w	#$8129,4(A0)
	move.b	7(A0),D1
	and.l	#$FF,D1
	move.l	#5,D2
	move.l	#$29,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	rts

KeyGotoRecordPage
	move.l	#4,D7
	bsr	DrawActivePage
	bra	lbC00060A

SetupHelpPage
	tst.w	ActivePageNr
	bmi	lbC000B4A
	bne	lbC000D62
	bsr	lbC002014
lbC000D62
	cmp.w	#2,ActivePageNr
	bne	lbC000D72
	bsr	lbC00207C
lbC000D72
	cmp.w	#7,ActivePageNr
	bne	lbC000D82
	bsr	lbC002014
lbC000D82
	move.w	ActivePageNr,lbW007BD0
	move.w	#$FFFD,ActivePageNr
	bsr	lbC005D46
	bsr	lbC005C32
	move.w	lbW007BD0,D1
	asl.w	#2,D1
	lea	lbL0044EC(PC),A0
	move.l	$20(A0,D1.W),D2
	move.l	0(A0,D1.W),D1
	move.l	#$2A,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	move.l	#$FFFFFFFF,lbL007BA2
	move.l	#$FFFFFFFF,lbL007BAC
	move.l	#$FFFFFFFF,lbL007BB6
	move.l	#lbC002404,KeyCutHook
	move.l	#lbC002404,KeyPasHook
	move.l	#lbC002404,KeyClrHook
	move.l	#lbC002404,lbL007C50
	move.l	#lbC002404,lbL007C4C
	move.l	#lbC002404,lbL007C54
	move.l	#lbC002404,lbL007C58
	move.l	#lbC002404,KeyDownArrowHook
	move.l	#lbC002404,KeyUpArrowHook
	move.w	lbW007BD0,D6
	lea	lbB00808D,A0
	move.b	lbB007CA4,0(A0,D6.W)
	move.b	lbB007CA5,8(A0,D6.W)
	move.b	lbB007D92,$10(A0,D6.W)
	move.w	#0,lbW007B72
	lea	HelpGadgetList,A0
	move.l	A0,CurrentPageGList
	bsr	DrawGadgetList
	move.l	#lbC0049FE,KeyGenericHook
	lea	TFMXEditorwas.MSG,A0
	bsr	DrawString
	move.l	MdatBuffer,D1
	add.l	#$C800,D1
	sub.l	MdatBufEndPtr,D1
	move.b	#$2C,CharXPos
	move.b	#6,CharYPos
	bsr	Draw4HexDigits
	move.l	SmplBuffer,D1
	add.l	SmplSizeVal,D1
	sub.l	SmplBufEndPtr,D1
	move.b	#$33,CharXPos
	bsr	lbC000F9E
	move.l	4,A6
	move.l	#$20002,D1
	jsr	_LVOAvailMem(A6)
	move.l	D0,D1
	move.b	#$3A,CharXPos
	bsr	lbC000F9E
	move.l	#2,D1
	move.l	4,A6
	jsr	_LVOAvailMem(A6)
	move.l	#$80000,D1		infantile assumption of 512k chip
	sub.l	D0,D1
	move.b	#$3A,CharXPos
	move.b	#5,CharYPos
	bsr	lbC000F9E
	move.l	SmplBufEndPtr,D1
	sub.l	SmplBuffer,D1
	move.b	#$33,CharXPos
	bsr	lbC000F9E
	move.l	MdatBufEndPtr,D1
	sub.l	MdatBuffer,D1
	move.b	#$2C,CharXPos
	bsr	Draw4HexDigits
lbC000F48
	bsr	HelpDrawRate
	move.b	#5,CharYPos
	move.b	#$1C,CharXPos
	move.l	PlyrInfoBlock,A0
	tst.w	2(A0)
	bne	lbC000F7A
	tst.w	lbW007BDC
	beq	lbC000F84
	lea	Running.MSG,A0
	bra	DrawString

lbC000F7A
	lea	TIMEOUT.MSG,A0
	bra	DrawString

lbC000F84
	lea	Stop.MSG,A0
	bra	DrawString

	rts

lbC000F90
	cmp.w	#$FFFD,ActivePageNr
	beq	lbC000F48
	rts

lbC000F9E
	move.b	CharXPos,-(SP)
	move.l	D1,-(SP)
	and.l	#$FFFF,D1
	bsr	Draw4HexDigits
	move.l	(SP)+,D0
	swap	D0
	and.l	#$FF,D0
	move.b	(SP)+,CharXPos
	sub.b	#5,CharXPos
	bsr	Draw2HexDigits
	rts

lbC000FCE
	move.l	lbL007B94,A0
	cmp.b	#$20,(A0)
	beq	lbC001128
	move.l	lbL007B98,A0
	move.w	#$2C,D0
lbC000FE6
	cmp.b	#$20,0(A0,D0.W)
	bne	lbC000FF4
	dbra	D0,lbC000FE6
lbC000FF4
	move.b	#0,1(A0,D0.W)
	move.l	lbL007B94,A0
	move.w	#$2C,D1
lbC001004
	cmp.b	#$20,0(A0,D1.W)
	bne	lbC001012
	dbra	D1,lbC001004
lbC001012
	move.b	#0,1(A0,D1.W)
	move.w	D0,-(SP)
	move.w	D1,-(SP)
	bsr	lbC002EF6
	move.w	(SP)+,D1
	move.w	(SP)+,D0
	move.l	lbL007B98,A0
	move.b	#$20,1(A0,D0.W)
	move.l	lbL007B94,A0
	move.b	#$20,1(A0,D1.W)
	lea	EraseFileAlert,A0
	add.l	#$1D,A0
	move.w	#$13,D0
	move.l	lbL007B94,A1
	add.l	#$14,A1
lbC001058
	cmp.b	#$20,-1(A1)
	bne	lbC001070
	sub.l	#1,A1
	move.b	#$5F,-(A0)
	dbra	D0,lbC001058
lbC001070
	move.b	-(A1),-(A0)
	dbra	D0,lbC001070
	lea	ascii.MSG2,A1
	lea	EraseFileAlert,A0
	move.b	0(A1),$23(A0)
	move.b	1(A1),$24(A0)
	move.b	2(A1),$25(A0)
	lea	EraseFileAlert,A0
	bsr	DisplayAlert25
	beq	lbC001128
	clr.l	D6
	bsr	GetDiskStatus
	bne	lbC001128
	move.b	#'m',(A4)
	move.b	#'d',1(A4)
	move.b	#'a',2(A4)
	move.b	#'t',3(A4)
	move.l	#ascii.MSG2,D1
	move.l	_DosBase,A6
	jsr	_LVODeleteFile(A6)
	move.b	#'i',(A4)
	move.b	#'n',1(A4)
	move.b	#'f',2(A4)
	move.b	#'o',3(A4)
	move.l	#ascii.MSG2,D1
	move.l	_DosBase,A6
	jsr	_LVODeleteFile(A6)
	move.b	#'s',(A4)
	move.b	#'m',1(A4)
	move.b	#'p',2(A4)
	move.b	#'l',3(A4)
	move.l	#ascii.MSG2,D1
	move.l	_DosBase,A6
	jsr	_LVODeleteFile(A6)
	jsr	lbC0035DE
	bra	lbC00228C

lbC001128
	rts

lbC00112A
	bsr	lbC005D46
	bsr	lbC004090
	move.l	#lbL009F04,lbL007BC2
	bsr	lbC00426A
	rts

lbC001142
	lea	lbB00808D,A0
	lea	lbB0080A5,A1
	move.w	#$17,D0
lbC001152
	move.b	(A1)+,(A0)+
	dbra	D0,lbC001152
	clr.l	lbL007B62
	clr.l	lbW007B78
	clr.l	lbW007B8A
	clr.w	CurrentMacroNum
	clr.w	CurrentPattNum
	clr.w	lbW007B7C
	rts

lbC00117E
	move.l	12(A0),D0
	move.b	D0,lbB007D92
	move.l	lbL007B6C,A0
	bsr	lbC005D46
	move.b	0(A0,D0.W),lbB007CA4
	rts

lbC00119C
	tst.w	lbW007BF6
	bne	lbC0011D4
	eor.w	#1,lbW007BF6
	move.w	#$8129,4(A0)
	move.l	#$33,D1
	move.l	#3,D2
	move.l	#$29,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	rts

lbC0011D4
	eor.w	#1,lbW007BF6
	move.w	#$812A,4(A0)
	move.l	#$33,D1
	move.l	#3,D2
	move.l	#$2A,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	rts

lbC001202
	eor.w	#1,RecordKeyuFlag
	move.l	#$33,D1
	move.l	#15,D2
	beq	lbC00123A
	move.w	#$8129,4(A0)
	moveq	#$29,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	rts

lbC00123A
	move.w	#$812A,4(A0)
	moveq	#$2A,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	rts

lbC001268
	move.b	#4,D7
	bsr	DrawActivePage
	move.l	#15,D2
	move.l	#$3D,D1
	move.l	#$29,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	bsr	lbC003226
	move.l	#15,D2
	move.l	#$3D,D1
	move.l	#$2A,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	rts

lbC0012B2
	bsr	lbC005CE4
	move.b	CharYPos,-(SP)
	move.b	CharXPos,-(SP)
	move.l	PlyrPatternBlock,A0
	move.w	4(A0),D1
	move.b	#0,CharYPos
	move.b	#$4F,CharXPos
	bsr	Draw4HexDigits
	cmp.w	#4,ActivePageNr
	bne	lbC001358
	move.l	PlyrMasterBlock,A0
	move.l	$6C(A0),D1
	lsr.l	#8,D1
	move.b	#15,CharYPos
	move.b	#$24,CharXPos
	bsr	Draw4HexDigits
	moveq.l	#0,D0
	tst.w	lbW007C0E
	beq	lbC00132A
	move.l	PlyrMasterBlock,A0
	move.w	$74(A0),D0
	and.w	#15,D0
lbC00132A
	move.b	#$25,CharXPos
	bsr	Draw1HexDigit
	move.l	PlyrMasterBlock,A0
	move.w	$46(A0),D1
	asl.w	#2,D1
	move.l	NoteNameTablePtr,A0
	move.l	0(A0,D1.W),A0
	move.b	#15,CharXPos
	bsr	DrawString
lbC001358
	tst.w	ActivePageNr
	bne	lbC001438
	bsr	GetPatternAddr
	move.l	PlyrPatternBlock,A1
	move.w	#0,D1
	cmp.l	$28(A1),A0
	beq	lbC0013CC
	move.w	#4,D1
	cmp.l	$2C(A1),A0
	beq	lbC0013CC
	move.w	#8,D1
	cmp.l	$30(A1),A0
	beq	lbC0013CC
	move.w	#12,D1
	cmp.l	$34(A1),A0
	beq	lbC0013CC
	move.w	#$10,D1
	cmp.l	$38(A1),A0
	beq	lbC0013CC
	move.w	#$14,D1
	cmp.l	$3C(A1),A0
	beq	lbC0013CC
	move.w	#$18,D1
	cmp.l	$40(A1),A0
	beq	lbC0013CC
	move.w	#$1C,D1
	cmp.l	$44(A1),A0
	bne	lbC001438
lbC0013CC
	move.l	PlyrPatternBlock,A0
	move.w	$68(A0,D1.W),D6
	move.l	lbW007B78,D2
	sub.w	D2,D6
	cmp.w	#9,D6
	bge	lbC001446
	cmp.w	#1,D6
	blt	lbC001446
	cmp.w	PatArrowOldY,D6
	beq	lbC001438
	add.w	#6,D6
	move.b	#8,CharXPos
	move.b	D6,CharYPos
	move.b	#$5D,D0
	bsr	DrawChar
	move.w	PatArrowOldY,D1
	bmi	lbC00142E
	add.b	#6,D1
	move.b	D1,CharYPos
	move.b	#$20,D0
	bsr	DrawChar
lbC00142E
	subq.w	#6,D6
	move.w	D6,PatArrowOldY
lbC001438
	move.b	(SP)+,CharXPos
	move.b	(SP)+,CharYPos
	rts

lbC001446
	move.w	PatArrowOldY,D1
	bmi	lbC001438
	add.b	#6,D1
	move.b	#8,CharXPos
	move.b	D1,CharYPos
	move.b	#$20,D0
	bsr	DrawChar
	move.w	#$FFFF,PatArrowOldY
	bra	lbC001438

lbC001476
	move.l	lbL007C54,A6
	jsr	(A6)
	bra	lbC00060A

lbC001482
	move.l	lbL007C58,A6
	jsr	(A6)
	bra	lbC00060A

lbC00148E
	cmp.w	#1,ActivePageNr
	bne	lbC00060A
	bsr	GetSongStatsAddr
lbC00149E
	clr.l	D0
	move.b	lbB007CA5,D0
	subq.l	#7,D0
	add.l	lbL007B62,D0
	move.w	D0,$100(A0)
	and.w	#$1FF,$100(A0)
	bsr	DrawSongInfo
	bra	lbC00060A

lbC0014C4
	cmp.w	#1,ActivePageNr
	bne	lbC00060A
	bsr	GetSongStatsAddr
	add.l	#$40,A0
	bra	lbC00149E

KeyPlayStop
	tst.w	lbW007BDC
	beq	lbC0014F0
	bsr	lbC001A5E
	bra	lbC00060A
lbC0014F0
	bsr	lbC0019E4
	bra	lbC00060A

KeyPlayCont
	bsr	lbC001ABC
	bra	lbC00060A

KeyGotoPattPage
	move.l	#0,D7
	bsr	DrawActivePage
	bra	lbC00060A

KeyGotoTrackPage
	move.l	#1,D7
	bsr	DrawActivePage
	bra	lbC00060A

KeyGotoMacroPage
	move.l	#2,D7
	bsr	DrawActivePage
	bra	lbC00060A

KeyGotoSmpLstPage
	move.l	#5,D7
	bsr	DrawActivePage
	bra	lbC00060A

lbC001538
	bsr	lbC005D46
	bsr	lbC00088C
	clr.b	lbB007D92
	bra	lbC000934

KeyDoCut
	move.l	KeyCutHook,A6
	jsr	(A6)
	bra	lbC00060A

KeyDoPas
	move.l	KeyPasHook,A6
	jsr	(A6)
	bra	lbC00060A

lbC001562
	move.l	lbL007C4C,A6
	jsr	(A6)
	bra	lbC00060A

lbC00156E
	move.l	lbL007C50,A6
	jsr	(A6)
	bra	lbC00060A

KeyDoClr
	move.l	KeyClrHook,A6
	jsr	(A6)
	bra	lbC00060A

lbC001586
	move.b	lbB007CA5,D6
	cmp.b	#13,D6
	bne	lbC0015B6
	bsr	lbC005D46
	cmp.w	#$F6,lbW007B7C
	beq	lbC000B4A
	add.w	#1,lbW007B7C
	bsr	lbC005D46
	bsr	lbC005850
	rts

lbC0015B6
	bsr	lbC005D46
	add.b	#1,lbB007CA5
	rts

lbC0015C4
	move.b	lbB007CA5,D6
	cmp.b	#4,D6
	bne	lbC0015EE
	bsr	lbC005D46
	tst.w	lbW007B7C
	beq	lbC000B4A
	sub.w	#1,lbW007B7C
	bsr	lbC005850
	rts

lbC0015EE
	bsr	lbC005D46
	sub.b	#1,lbB007CA5
	rts

lbC0015FC
	clr.w	D6
	move.b	lbB007CA5,D6
	sub.w	#6,D6
	add.w	lbW007B7A,D6
	asl.w	#2,D6
	bsr	GetPatternAddr
	move.l	0(A0,D6.W),D0
	and.l	#$FF000000,D0
	cmp.l	#$F0000000,D0
	beq	lbC001640
	cmp.b	#14,lbB007CA5
	beq	lbC001642
	bsr	lbC005D46
	add.b	#1,lbB007CA5
lbC001640
	rts

lbC001642
	add.l	#1,lbW007B78
	bsr	lbC005D46
	bsr	DrawPatternLines
	rts

lbC001656
	bsr	lbC005D46
	cmp.b	#7,lbB007CA5
	beq	lbC001670
	sub.b	#1,lbB007CA5
	rts

lbC001670
	tst.l	lbW007B78
	beq	lbC000B4A
	sub.l	#1,lbW007B78
	bsr	DrawPatternLines
	rts

lbC00168A
	clr.w	D6
	move.b	lbB007CA5,D6
	sub.w	#6,D6
	add.w	lbW007B8C,D6
	asl.w	#2,D6
	bsr	GetMacroAddr
	move.l	0(A0,D6.W),D0
	and.l	#$FF000000,D0
	cmp.l	#$7000000,D0
	beq	lbC0016CE
	cmp.b	#14,lbB007CA5
	beq	lbC0016D0
	bsr	lbC005D46
	add.b	#1,lbB007CA5
lbC0016CE
	rts

lbC0016D0
	add.l	#1,lbW007B8A
	bsr	lbC005D46
	bsr	DrawMacroLines
	rts

lbC0016E4
	bsr	lbC005D46
	cmp.b	#7,lbB007CA5
	beq	lbC0016FE
	sub.b	#1,lbB007CA5
	rts

lbC0016FE
	tst.l	lbW007B8A
	beq	lbC000B4A
	sub.l	#1,lbW007B8A
	bsr	DrawMacroLines
	rts

lbC001718
	cmp.w	#$FFFF,4(A0)
	beq	lbC0017D6
	cmp.b	#0,4(A0)
	beq	lbC0017F6
	move.l	D1,D0
	move.w	2(A0),D2
	and.w	#$3FF,D2
	cmp.w	D0,D2
	bcc	lbC0017F6
	move.w	0(A0),D3
	lsr.w	#3,D3
	and.w	#$FF,D3
	add.w	D3,D2
	cmp.w	D2,D0
	bcc	lbC0017F6
	swap	D0
	move.l	0(A0),D2
	lsr.l	#8,D2
	lsr.l	#2,D2
	and.l	#$FF,D2
	cmp.w	D0,D2
	bcc	lbC0017F6
	move.w	0(A0),D3
	lsr.w	#8,D3
	lsr.w	#3,D3
	add.w	D3,D2
	cmp.w	D2,D0
	bcc	lbC0017F6
	move.l	A0,lbL007BD2
lbC00177A
	move.w	4(A0),D0
	lsr.w	#6,D0
	and.w	#$7C,D0
	lea	lbL001810(PC),A1
	move.l	0(A1,D0.W),A6
	jsr	(A6)
	bsr	lbC001B74
lbC001792
	sub.w	#1,ButtonReptCtr
	tst.w	ButtonReptCtr
	beq	lbC0017D8
	move.l	_GfxBase,a6
	jsr	_LVOWaitTOF(a6)
	move.l	4,A6
	move.l	WindowPtr,A0
	move.l	$56(A0),A0
	jsr	_LVOGetMsg(A6)
	tst.l	D0
	beq	lbC001792
.flush
	move.l	4,A6
	move.l	D0,A1
	jsr	_LVOReplyMsg(A6)
	move.l	WindowPtr,a0
	move.l	$56(a0),a0
	jsr	_LVOGetMsg(a6)
	tst.l	d0
	bne.s	.flush
	move.w	#20,ButtonReptCtr
lbC0017D6
	rts

lbC0017D8
	move.l	lbL007BD2,A0
	move.w	4(A0),D0
	btst	#15,D0
	bne	lbC001792
	move.w	#4,ButtonReptCtr
	bra	lbC00177A

lbC0017F6
	tst.l	(A0)
	beq	lbC001806
	addq.l	#8,A0
;	bra	lbC001718
lbC001806
	addq.l	#8,A0
	bra	lbC001718

lbL001810
	dc.l	0
	dc.l	lbC001842
	dc.l	lbC001894
	dc.l	lbC0018F0
	dc.l	lbC001824

lbC001824
	move.l	8(A0),A6
	move.w	4(A0),D0
	btst	#14,D0
	beq	lbC00183A
	add.l	SampleRoutBuffer,A6
lbC00183A
	move.l	12(A0),D7
	jsr	(A6)
	rts

lbC001842
	tst.b	lbW007C1E
	bne	lbC001850
	bra	lbC001824

lbC001850
	movem.l	A0,-(SP)
	move.l	#$35,D1
	move.l	#0,D2
	bsr	ClearButton
	move.l	#10,D0
	move.l	#$35,D1
	move.l	#0,D2
	bsr	RenderStuff
	movem.l	(SP)+,A0
	clr.w	lbW007BA0
	clr.w	lbW007BAA
	clr.w	lbW007BB4
	bra	lbC001824

lbC001894
	move.l	MdatBuffer,A1
	add.l	#$1C0,A1
	move.l	8(A0),D1
	tst.w	0(A1,D1.W)
	beq	lbC0018CE
	clr.w	0(A1,D1.W)
	move.l	12(A0),D1
	move.l	#2,D2
	move.l	#$28,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	rts

lbC0018CE
	st	1(A1,D1.W)
	move.l	12(A0),D1
	move.l	#2,D2
	move.l	#$27,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	rts

lbC0018F0
	move.w	lbW007C0E,D3
	cmp.w	10(A0),D3
	beq	lbC001958
	move.l	A0,-(SP)
	clr.l	D1
	tst.w	D3
	beq	lbC00192A
	lea	lbB008084,A1
	move.b	0(A1,D3.W),D1
	move.l	#15,D2
	move.l	#$26,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
lbC00192A
	move.l	(SP)+,A0
	move.l	12(A0),D1
	move.l	#15,D2
	and.l	#$FF,D1
	move.l	#$25,D0
	move.w	10(A0),lbW007C0E
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	rts

lbC001958
	move.l	12(A0),D1
	move.l	#15,D2
	and.l	#$FF,D1
	move.l	#$26,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	move.w	#0,lbW007C0E
	rts

lbC001984
	cmp.l	#4,lbL007B62
	bcc	lbC00199C
	move.l	#4,lbL007B62
lbC00199C
	sub.l	#4,lbL007B62
	bsr	DrawTracks
lbC0019AA
	rts

lbC0019AC
	cmp.l	#$1F5,lbL007B62
	bcs	lbC0019C4
	move.l	#$1F4,lbL007B62
lbC0019C4
	add.l	#4,lbL007B62
	bsr	DrawTracks
	rts

lbC0019D4
	move.w	#$FFF,D0
lbC0019D8
	move.w	D0,$DFF180
	dbra	D0,lbC0019D8
	rts

lbC0019E4
	tst.w	ActivePageNr
	bpl	lbC0019FA
	cmp.w	#$FFFD,ActivePageNr
	bne	lbC0019AA
lbC0019FA
	move.l	RoutBuffer,A0
	jsr	$28(A0)
	lea	lbW0080F8,A1
	move.w	4(A1),D3
	move.w	2(A1),D4
	move.w	MetronomeFlag,D0
	move.l	RoutBuffer,A0
	jsr	$68(A0)
	move.w	CurrentSongNum,D0
	move.l	RoutBuffer,A0
	jsr	$2C(A0)			songplay
	move.w	PlayRate7V,d0
	bsr	SetPlayRate7V
	move.l	#$3D,D1
	move.l	#13,D2
	move.l	#$29,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	move.w	#1,lbW007BDC
	bsr	lbC000F90
	rts

lbC001A5E
	cmp.w	#$FFFD,ActivePageNr
	beq	lbC001A74
	tst.w	ActivePageNr
	bmi	lbC0019AA
lbC001A74
	move.l	RoutBuffer,A0
	jsr	$28(A0)
	tst.l	SampleRoutBuffer
	bne	lbC001AB0
	tst.w	lbW007BDC
	beq	lbC001AB0
	move.l	#$3D,D1
	move.l	#13,D2
	move.l	#$2A,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
lbC001AB0
	clr.w	lbW007BDC
	bsr	lbC000F90
	rts

lbC001ABC
	cmp.w	#$FFFD,ActivePageNr
	beq	lbC001AD2
	tst.w	ActivePageNr
	bmi	lbC0019AA
lbC001AD2
	move.l	RoutBuffer,A0
	move.w	CurrentSongNum,D0
	jsr	$60(A0)
	move.w	PlayRate7V,d0
	bsr	SetPlayRate7V
	moveq	#$3D,D1
	moveq	#13,D2
	moveq	#$29,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	move.w	#1,lbW007BDC
	lea	lbW0080F8,A1
	move.w	4(A1),D3
	move.w	2(A1),D4
	move.w	MetronomeFlag,D0
	move.l	RoutBuffer,A6
	jsr	$68(A6)
	bsr	lbC000F90
	rts

Vsync
	movem.l	D0-D2,-(SP)
lbC001B30
	move.l	$DFF004,D0
	and.l	#$1FF00,D0
	cmp.l	#$1200,d0
	bcc.s	.islow
	cmp.l	#$E000,D0
	bcs	lbC001B30
.islow
	movem.l	(SP)+,D0-D2
	rts

DrawTracks
	move.b	#7,CharYPos
	move.l	lbL007B62,D0
	moveq	#7,D4
lbC001B5C
	bsr	DrawTrack
	add.l	#1,D0
	add.b	#1,CharYPos
	dbra	D4,lbC001B5C
	rts

lbC001B74
	move.l	4,A6
	lea	ConsoleIOReq,A1
	move.w	#2,$1C(A1)
	move.l	#KeyASCIIKeyCode,$28(A1)
	move.l	#1,$24(A1)
	move.l	#ConReadPort,14(A1)
	jsr	_LVOSendIO(A6)
	rts

lbC001BA4
	lea	EscapeEditorAlert,A0
	bsr	DisplayAlert25
	bne	lbC001BBC
	add.l	#12,SP
	bra	MainQuitOK

lbC001BBC
	rts

lbC001BBE
	movem.l	D0-D7/A0-A6,-(SP)
	cmp.w	#1,D0
	beq	lbC001BF6
	cmp.w	#2,D0
	beq	lbC001BF6
	cmp.w	#3,D0
	beq	lbC001BE0
lbC001BDA
	movem.l	(SP)+,D0-D7/A0-A6
	rts

lbC001BE0
	move.w	D1,CurrentMacroNum
	cmp.w	#2,ActivePageNr
	bne	lbC001BDA
	bra	lbC001BF6

lbC001BF6
	move.w	D0,lbW007C96
	move.b	MidiSigBit,D1
	clr.l	D0
	bset	D1,D0
	move.l	4,A6
	move.l	lbL007C98,A1
	jsr	_LVOSignal(A6)
	bra	lbC001BDA

	move.l	#$2A,D0
lbC001C20
	move.l	#$3D,D1
	move.l	#13,D2
	bsr	ClearButton
	bsr	RenderStuff
	rts

	move.l	#$29,D0
	bra	lbC001C20

lbC001C40
	move.l	SampleRoutBuffer,A0
	move.l	$24(A0),A0
	add.l	SampleRoutBuffer,A0
	move.l	(A0),A1
	add.l	SampleRoutBuffer,A1
	clr.w	$10(A1)
	move.w	#1,$12(A1)
	move.l	A1,-(SP)
	move.l	A0,-(SP)
	jsr	8(A0)
	move.l	(SP)+,A0
	jsr	4(A0)
	move.l	(SP)+,A1
	clr.w	$12(A1)
	clr.w	lbW007C94
	rts

lbC001C7E
	clr.l	D0
	move.w	CurrentPattNum,D0
	move.l	InfoBuffer,A0
lbC001C8C
	asl.l	#2,D0
	add.l	D0,A0
	asl.l	#2,D0
	add.l	D0,A0
	move.w	#$13,D0
	move.l	#ascii.MSG4,A1
lbC001C9E
	move.b	(A0)+,(A1)+
	bne	lbC001CAA
	move.b	#$20,-1(A1)
lbC001CAA
	dbra	D0,lbC001C9E
	move.l	#ascii.MSG4,A0
	move.b	#$1A,CharXPos
	move.b	#4,CharYPos
	bsr	DrawString
	rts

lbC001CCA
	clr.l	D0
	move.w	CurrentMacroNum,D0
	move.l	InfoBuffer,A0
	add.l	#$A00,A0
	bra	lbC001C8C

lbC001CE2
	bsr	lbC002FAA
	bsr	lbC005D46
	move.b	#4,lbB007CA5
	move.b	D6,lbB007CA4
	move.l	#lbB007D11,lbL007B6C
	sub.b	#$1A,D6
	move.b	D6,lbB007D92
	move.b	#$13,ScrapVar
	move.l	#lbC001F52,KeyGenericHook
	move.l	#lbC002404,KeyCutHook
	move.l	#lbC002404,KeyPasHook
	move.l	#lbC002404,KeyClrHook
	move.l	#lbC002404,lbL007C50
	move.l	#lbC001EC8,lbL007C4C
	move.l	#lbC002404,lbL007C54
	move.l	#lbC002404,lbL007C58
	move.l	#lbC0044E6,KeyDownArrowHook
	move.l	#lbC0044E6,KeyUpArrowHook
	move.l	#lbC00200E,lbL007C5C
	rts

lbC001D84
	bsr	lbC002FAA
	bsr	lbC005D46
	move.b	#4,lbB007CA5
	move.b	D6,lbB007CA4
	move.l	#lbB007D11,lbL007B6C
	sub.b	#$1A,D6
	move.b	D6,lbB007D92
	move.b	#$13,ScrapVar
	move.l	#lbC001F52,KeyGenericHook
	move.l	#lbC002404,KeyCutHook
	move.l	#lbC002404,KeyPasHook
	move.l	#lbC002404,KeyClrHook
	move.l	#lbC002404,lbL007C50
	move.l	#lbC001EC8,lbL007C4C
	move.l	#lbC002404,lbL007C54
	move.l	#lbC002404,lbL007C58
	move.l	#lbC0044E6,KeyDownArrowHook
	move.l	#lbC0044E6,KeyUpArrowHook
	move.l	#lbC002004,lbL007C5C
	rts

lbC001E26
	bsr	lbC002FAA
	bsr	lbC005D46
	move.b	#4,lbB007CA5
	move.b	D6,lbB007CA4
	move.l	#lbB007D11,lbL007B6C
	sub.b	#$1A,D6
	move.b	D6,lbB007D92
	move.b	#$13,ScrapVar
	move.l	#lbC001F52,KeyGenericHook
	move.l	#lbC002404,KeyCutHook
	move.l	#lbC002404,KeyPasHook
	move.l	#lbC002404,KeyClrHook
	move.l	#lbC002404,lbL007C50
	move.l	#lbC001EC8,lbL007C4C
	move.l	#lbC002404,lbL007C54
	move.l	#lbC002404,lbL007C58
	move.l	#lbC0044E6,KeyDownArrowHook
	move.l	#lbC0044E6,KeyUpArrowHook
	move.l	#lbC002076,lbL007C5C
	rts

lbC001EC8
	bsr	lbC001EE2
	move.b	#4,CharYPos
	move.b	#$1A,CharXPos
	bsr	DrawString
	rts

lbC001EE2
	clr.w	D0
	move.b	lbB007D92,D0
	cmp.w	#$13,D0
	beq	lbC001F0A
	move.l	#ascii.MSG4,A0
lbC001EF8
	move.b	1(A0,D0.W),0(A0,D0.W)
	add.w	#1,D0
	cmp.w	#$13,D0
	blt	lbC001EF8
lbC001F0A
	move.l	#ascii.MSG4,A0
	move.b	#$20,$13(A0)
	rts

lbC001F18
	tst.b	lbB007D92
	beq	lbC00060A
	sub.b	#1,lbB007D92
	bsr	lbC005D46
	sub.b	#1,lbB007CA4
	bsr	lbC001EE2
	move.b	#4,CharYPos
	move.b	#$1A,CharXPos
	bsr	DrawString
	bra	lbC00060A

lbC001F52
	cmp.b	#8,KeyASCIIKeyCode
	beq	lbC001F18
	cmp.b	#13,KeyASCIIKeyCode
	beq	lbC001FF2
	cmp.b	#$1F,KeyASCIIKeyCode
	blt	lbC00060A
	cmp.b	#$7D,KeyASCIIKeyCode
	bge	lbC00060A
	clr.w	D0
	move.b	lbB007D92,D0
	cmp.w	#$13,D0
	beq	lbC001FB4
	move.l	#ascii.MSG4,A0
	move.w	#$13,D1
lbC001F9C
	move.b	-1(A0,D1.W),0(A0,D1.W)
	sub.w	#1,D1
	cmp.w	D1,D0
	blt	lbC001F9C
	clr.w	D0
	move.b	lbB007D92,D0
lbC001FB4
	move.l	#ascii.MSG4,A0
	move.b	KeyASCIIKeyCode,0(A0,D0.W)
	move.b	#4,CharYPos
	move.b	#$1A,CharXPos
	bsr	DrawString
	move.b	ScrapVar,D0
	cmp.b	lbB007D92,D0
	beq	lbC00060A
	add.b	#1,lbB007D92
	bra	lbC000934

lbC001FF2
	move.l	lbL007C5C,A6
	jsr	(A6)
	move.l	D1,D7
	bsr	lbC00446E
	bra	lbC00060A

lbC002004
	move.l	#$1C,D1
	bra	lbC002014

lbC00200E
	move.l	#0,D1
lbC002014
	move.l	D1,-(SP)
	bsr	lbC005D46
	move.b	#9,lbB007CA4
	move.b	#7,lbB007CA5
	tst.w	ActivePageNr
	beq	lbC00203C
	move.b	#5,lbB007CA4
lbC00203C
	clr.b	lbB007D92
	move.l	#lbC000660,KeyGenericHook
	clr.l	D0
	move.w	CurrentPattNum,D0
	move.l	InfoBuffer,A0
	asl.l	#2,D0
	add.l	D0,A0
	asl.l	#2,D0
	add.l	D0,A0
	move.w	#$13,D0
	move.l	#ascii.MSG4,A1
lbC00206C
	move.b	(A1)+,(A0)+
	dbra	D0,lbC00206C
	move.l	(SP)+,D1
	rts

lbC002076
	move.l	#8,D1
lbC00207C			; copies macro name field to info
	move.l	D1,-(SP)
	bsr	lbC005D46
	move.b	#9,lbB007CA4
	move.b	#7,lbB007CA5
	clr.b	lbB007D92
	move.l	#lbC000660,KeyGenericHook
	clr.l	D0
	move.w	CurrentMacroNum,D0
	move.l	InfoBuffer,A0
	add.l	#$A00,A0
	asl.l	#2,D0
	add.l	D0,A0
	asl.l	#2,D0
	add.l	D0,A0
	move.w	#$13,D0
	move.l	#ascii.MSG4,A1
lbC0020C8
	move.b	(A1)+,(A0)+
	dbra	D0,lbC0020C8
	move.l	(SP)+,D1
	rts

DisplayAlert25
	clr.l	D0
	move.l	#$19,D1
	move.l	_IntuitionBase,A6
	jsr	_LVODisplayAlert(A6)
	rts

lbC0020E6
	st	D6
	bsr	GetDiskStatus
	tst.l	D0
	bne	lbC002404
	move.l	#$FFFFFFFF,lbL007BA2
	move.l	#$FFFFFFFF,lbL007BAC
	move.l	#$FFFFFFFF,lbL007BB6
	move.l	#lbC002404,KeyCutHook
	move.l	#lbC002404,KeyPasHook
	move.l	#lbC002404,KeyClrHook
	move.l	#lbC002404,lbL007C50
	move.l	#lbC0024EE,lbL007C4C
	move.l	#lbC002404,lbL007C54
	move.l	#lbC002404,lbL007C58
	move.b	#6,lbB007CA4
	move.b	#6,CharXPos
	lea	ascii.MSG8,A0
	move.l	A0,lbL007B94
	move.l	A0,lbL007B9C
	lea	DF0samples.MSG,A0
	move.l	A0,lbL007B98
	clr.b	lbB007D92
	tst.l	D0
	bne	lbC0025BC
	bra	lbC002334

lbC002194
	clr.w	lbW007C9C
lbC00219A
	move.l	D7,lbL007B90
	st	D6
	bsr	GetDiskStatus
	tst.l	D0
	bne	lbC002404
	move.l	#$FFFFFFFF,lbL007BA2
	move.l	#$FFFFFFFF,lbL007BAC
	move.l	#$FFFFFFFF,lbL007BB6
	move.l	#lbC002404,KeyCutHook
	move.l	#lbC002404,KeyPasHook
	move.l	#lbC002404,KeyClrHook
	move.l	#lbC002404,lbL007C50
	move.l	#lbC0024EE,lbL007C4C
	move.l	#lbC002404,lbL007C54
	move.l	#lbC002404,lbL007C58
	tst.w	ActivePageNr
	bmi	lbC00228C
	bne	lbC002222
	bsr	lbC002014
lbC002222
	cmp.w	#2,ActivePageNr
	bne	lbC002232
	bsr	lbC00207C
lbC002232
	cmp.w	#7,ActivePageNr
	bne	lbC002242
	bsr	lbC002014
lbC002242
	move.w	ActivePageNr,D6
	lea	lbB00808D,A0
	move.b	lbB007CA4,0(A0,D6.W)
	move.b	lbB007CA5,8(A0,D6.W)
	move.b	lbB007D92,$10(A0,D6.W)
	move.w	D6,lbW007BD0
	asl.w	#2,D6
	lea	lbL0044EC(PC),A0
	move.l	0(A0,D6.W),D1
	move.l	$20(A0,D6.W),D2
	move.l	#$2A,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
lbC00228C
	move.b	#6,lbB007CA4
	move.b	#6,CharXPos
	clr.b	lbB007D92
	st	D6
	bsr	GetDiskStatus
	tst.l	D0
	bne	lbC0025BC
	move.w	#$FFFF,ActivePageNr
	cmp.l	#0,lbL007B90
	beq	lbC002304
	cmp.l	#2,lbL007B90
	beq	lbC002304
	cmp.l	#3,lbL007B90
	beq	lbC002304
	cmp.l	#4,lbL007B90
	beq	lbC002304
	cmp.l	#7,lbL007B90
	beq	lbC002304
	move.w	#$FFFE,ActivePageNr
lbC002304
	move.l	lbL007B90,D0
	asl.l	#2,D0
	lea	lbL002654,A0
	move.l	0(A0,D0.L),lbL007B94
	move.l	0(A0,D0.L),lbL007B9C
	lea	lbL00267C,A0
	move.l	0(A0,D0.L),lbL007B98
	bsr	lbC001A74
lbC002334
	bsr	lbC005D46
	bsr	lbC005C32
	lea	FselGadgetList(PC),A0
	move.l	A0,CurrentPageGList
	bsr	DrawGadgetList
	move.b	#15,lbW002406
	bsr	lbC004010
	move.l	#lbL009F04,lbL007BC2
	bsr	lbC00426A
	move.b	#15,CharYPos
	move.b	#15,lbB007CA5
	move.l	#lbC002408,KeyGenericHook
	move.l	#lbC002404,KeyUpArrowHook
	move.l	#lbC002404,KeyDownArrowHook
	move.w	#1,lbW007B72
	move.l	#lbB007CDB,lbL007B6C
	move.b	#$2C,ScrapVar
	move.l	lbL007B94,A0
	move.l	lbL007B98,A1
	move.w	#$2C,D0
lbC0023BC
	tst.b	0(A0,D0.W)
	bne	lbC0023CA
	move.b	#$20,0(A0,D0.W)
lbC0023CA
	tst.b	0(A1,D0.W)
	bne	lbC0023D8
	move.b	#$20,0(A1,D0.W)
lbC0023D8
	dbra	D0,lbC0023BC
	move.b	#6,CharXPos
	bsr	DrawString
	move.l	lbL007B98,A0
	move.b	#6,CharXPos
	move.b	#13,CharYPos
	bsr	DrawString
	rts

lbC002404
	rts

lbW002406
	dc.w	0

lbC002408
	move.b	KeyASCIIKeyCode,D0
	cmp.b	#$22,D0
	beq	lbC0044E8
	cmp.b	#13,D0
	beq	lbC00254C
	cmp.b	#8,D0
	beq	lbC00249C
	cmp.b	#$1F,D0
	bcs	lbC0044E8
	cmp.b	#$7B,D0
	bcc	lbC0044E8
	clr.w	D1
	move.b	lbB007D92,D1
	move.l	lbL007B9C,A0
	clr.w	D2
	move.b	#$2B,D2
	cmp.w	#$2C,D1
	beq	lbC00246A
lbC002452
	move.b	0(A0,D2.W),1(A0,D2.W)
	cmp.b	lbB007D92,D2
	beq	lbC00246A
	sub.b	#1,D2
	bra	lbC002452

lbC00246A
	move.b	D0,0(A0,D1.W)
	move.b	#6,CharXPos
	move.b	lbW002406,CharYPos
	bsr	DrawString
	cmp.b	#$2D,lbB007D92
	beq	lbC0044E8
	add.b	#1,lbB007D92
	bra	lbC000934

lbC00249C
	tst.b	lbB007D92
	beq	lbC0044E8
	clr.w	D1
	move.b	lbB007D92,D1
	move.l	lbL007B9C,A0
lbC0024B4
	move.b	0(A0,D1.W),-1(A0,D1.W)
	add.w	#1,D1
	cmp.w	#$2C,D1
	bne	lbC0024B4
	move.b	#$20,-1(A0,D1.W)
	move.b	#6,CharXPos
	move.b	lbW002406,CharYPos
	bsr	DrawString
	sub.b	#1,lbB007D92
	bra	lbC000934

lbC0024EE
	move.b	lbB007D92,D1
	move.l	lbL007B9C,A0
	cmp.b	#$2C,D1
	beq	lbC002514
lbC002502
	move.b	1(A0,D1.W),0(A0,D1.W)
	add.w	#1,D1
	cmp.w	#$2C,D1
	bne	lbC002502
lbC002514
	move.b	#$20,$2C(A0)
	move.b	#6,CharXPos
	move.b	lbW002406,CharYPos
	bsr	DrawString
	clr.w	D0
	move.b	lbB007D92,D0
	move.l	lbL007B6C,A0
	bsr	lbC005D46
	move.b	0(A0,D0.W),lbB007CA4
	rts

lbC00254C
	bsr	lbC005D46
	move.l	lbL007B98,A0
	cmp.l	lbL007B9C,A0
	beq	lbC00260C
	move.w	#$2C,D0
lbC002564
	move.l	lbL007B94,A0
	cmp.b	#$20,0(A0,D0.W)
	bne	lbC00257C
	dbra	D0,lbC002564
	bra	lbC0025BC

lbC00257C
	move.b	#0,1(A0,D0.W)
	move.w	#$2C,D0
lbC002586
	move.l	lbL007B98,A0
	cmp.b	#$20,0(A0,D0.W)
	bne	lbC00259A
	dbra	D0,lbC002586
lbC00259A
	cmp.b	#0,0(A0,D0.W)
	beq	lbC0025AA
	move.b	#0,1(A0,D0.W)
lbC0025AA
	move.l	lbL007B90,D0
	asl.l	#2,D0
	lea	lbL00262C(PC),A0
	move.l	0(A0,D0.L),A6
	jsr	(A6)
lbC0025BC
	tst.l	SampleRoutBuffer
	bne	lbC002614
	move.l	#lbC000660,KeyGenericHook
	move.w	lbW007BD0,D7
	move.w	D7,ActivePageNr
	asl.w	#2,D7
	lea	lbL0044EC(PC),A0
	move.l	0(A0,D7.W),D1
	move.l	$20(A0,D7.W),D2
	move.l	#$29,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	move.w	ActivePageNr,D7
	asl.w	#2,D7
	bsr	lbC00446E
	bra	lbC00060A

lbC00260C
	bsr	lbC00228C
	bra	lbC00060A

lbC002614
	move.l	SampleRoutBuffer,A0
	move.l	$24(A0),A0
	add.l	SampleRoutBuffer,A0
	jsr	$10(A0)
	bra	lbC00060A

lbL00262C
	dc.l	lbC0037D8
	dc.l	WriteAll
	dc.l	lbC003C58
	dc.l	lbC002DC6
	dc.l	lbC002E5E
	dc.l	lbC002E12
	dc.l	lbC002EAA
	dc.l	lbC002CBE
	dc.l	lbC003C0A
	dc.l	lbC003C38
lbL002654
	dc.l	ascii.MSG9
	dc.l	ascii.MSG9
	dc.l	ascii.MSG8
	dc.l	ascii.MSG10
	dc.l	ascii.MSG11
	dc.l	ascii.MSG10
	dc.l	ascii.MSG11
	dc.l	ascii.MSG12
	dc.l	ascii.MSG8
	dc.l	ascii.MSG8
lbL00267C
	dc.l	DF0songs.MSG
	dc.l	DF0songs.MSG
	dc.l	DF0samples.MSG
	dc.l	DF0pattern.MSG
	dc.l	DF0macros.MSG
	dc.l	DF0pattern.MSG
	dc.l	DF0macros.MSG
	dc.l	DF0routines.MSG
	dc.l	DF0samples.MSG
	dc.l	DF0samples.MSG

lbC0026A4
	move.l	#$38,D2
	move.l	#7,D3
	move.w	#8,D4
	bra	lbC002700

lbC0026B8
	move.l	#$38,D2
	move.l	#7,D3
	move.w	PatternStepNumber,D4
	bra	lbC002700

lbC0026CE
	move.l	#$38,D2
	move.l	#7,D3
	move.w	lbW007C92,D4
	bra	lbC002700

lbC0026E4
	move.l	#$20,D2
	move.l	#4,D3
	move.w	#10,D4
	move.w	#4,D5
	bsr	lbC005D46
	bra	lbC002736

lbC002700
	bsr	lbC005D46
	move.l	lbL007BC6,D0
	and.w	#$FFFF,D0
	lsr.w	#3,D0
	move.l	lbL007B6C,A0
	clr.w	D1
	move.b	ScrapVar,D1
lbC00271E
	cmp.b	0(A0,D1.W),D0
	beq	lbC00272C
	dbra	D1,lbC00271E
lbC00272A
	rts

lbC00272C
	move.b	0(A0,D1.W),D5
	move.b	D1,lbB007D92
lbC002736
	move.l	lbL007BC6,D0
	swap	D0
	and.w	#$FFFF,D0
	sub.w	D2,D0
	lsr.w	#3,D0
	cmp.b	D4,D0
	bge	lbC00272A
	add.b	D3,D0
	move.b	D0,lbB007CA5
	move.b	D5,lbB007CA4
	rts

lbC00275C
	bsr	lbC005D46
	move.b	#$10,lbB007CA5
	move.b	#8,lbB007CA4
	move.l	#lbB007D25,lbL007B6C
	clr.b	lbB007D92
	move.b	#12,ScrapVar
	move.l	#lbC0027EE,KeyGenericHook
	move.l	#lbC002404,KeyCutHook
	move.l	#lbC002404,KeyPasHook
	move.l	#lbC002404,KeyClrHook
	move.l	#lbC002404,lbL007C50
	move.l	#lbC002404,lbL007C4C
	move.l	#lbC002404,lbL007C54
	move.l	#lbC002404,lbL007C58
	move.l	#lbC0044E6,KeyDownArrowHook
	move.l	#lbC0044E6,KeyUpArrowHook
	rts

lbC0027EE
	cmp.b	#13,KeyASCIIKeyCode
	beq	lbC002958
	move.w	#0,D0
	cmp.b	#0,lbB007D92
	beq	lbC0028FC
	move.w	#1,D0
	cmp.b	#3,lbB007D92
	beq	lbC0028FC
	move.w	#2,D0
	cmp.b	#6,lbB007D92
	beq	lbC0028FC
	move.w	#3,D0
	cmp.b	#8,lbB007D92
	beq	lbC0028FC
	move.w	#4,D0
	cmp.b	#10,lbB007D92
	beq	lbC0028FC
	move.b	KeyASCIIKeyCode,D1
	cmp.b	#$30,D1
	blt	lbC00060A
	cmp.b	#$3A,D1
	blt	lbC002874
	cmp.b	#$67,D1
	bge	lbC00060A
	cmp.b	#$61,D1
	blt	lbC00060A
	sub.b	#$27,D1
lbC002874
	sub.b	#$30,D1
	clr.w	D0
	move.b	lbB007D92,D0
	sub.b	#1,D0
	cmp.b	#2,D0
	blt	lbC0028B4
	sub.b	#1,D0
	cmp.b	#4,D0
	blt	lbC0028B4
	sub.b	#1,D0
	cmp.b	#5,D0
	blt	lbC0028B4
	sub.b	#1,D0
	cmp.b	#6,D0
	blt	lbC0028B4
	sub.b	#1,D0
lbC0028B4
	move.w	D0,D2
	lsr.w	#1,D0
	lea	lbL008128,A0
	and.w	#1,D2
	beq	lbC0028E0
	move.b	0(A0,D0.W),D3
	and.b	#$F0,D3
	or.b	D1,D3
	move.b	D3,0(A0,D0.W)
	bsr	lbC002B92
	bsr	lbC0008EA
	bra	lbC00060A

lbC0028E0
	asl.b	#4,D1
	move.b	0(A0,D0.W),D3
	and.b	#15,D3
	or.b	D1,D3
	move.b	D3,0(A0,D0.W)
	bsr	lbC002B92
	bsr	lbC0008EA
	bra	lbC00060A

lbC0028FC
	move.b	KeyASCIIKeyCode,D1
	cmp.b	#$73,D1
	beq	lbC00293E
	cmp.b	#$69,D1
	beq	lbC00293E
	cmp.b	#$70,D1
	beq	lbC00293E
	cmp.b	#$2B,D1
	beq	lbC002942
	cmp.b	#$2D,D1
	beq	lbC002942
	cmp.b	#$6E,D1
	bne	lbC00060A
	cmp.b	#0,lbB007D92
	bne	lbC00060A
lbC00293E
	sub.b	#$20,D1
lbC002942
	lea	II.MSG0,A0
	move.b	D1,0(A0,D0.W)
	bsr	lbC002B92
	bsr	lbC0008EA
	bra	lbC00060A

lbC002958
	bsr	GetPatternAddr
lbC00295C
	move.l	(A0),D0
	cmp.l	#$F0000000,D0
	beq	lbC002B2E
	cmp.b	#'I',II.MSG0
	beq	lbC0029B8
	cmp.b	#'S',II.MSG0
	beq	lbC0029A0
	cmp.b	#'N',II.MSG0
	bne	lbC0029B8
	and.l	#$FF000000,D0
	cmp.l	#$F0000000,D0
	bcs	lbC0029B8
	bra	lbC002B24

lbC0029A0
	move.l	lbL008128,D1
	and.l	#$FF000000,D0
	and.l	#$FF000000,D1
	cmp.l	D0,D1
	bne	lbC002B24
lbC0029B8
	move.l	(A0),D0
	cmp.b	#'I',II.MSG1
	beq	lbC0029EA
	cmp.b	#'S',II.MSG1
	bne	lbC0029EA
	move.l	lbL008128,D1
	and.l	#$FF0000,D0
	and.l	#$FF0000,D1
	cmp.l	D0,D1
	bne	lbC002B24
lbC0029EA
	move.l	(A0),D0
	cmp.b	#'I',II.MSG2
	beq	lbC002A1C
	cmp.b	#'S',II.MSG2
	bne	lbC002A1C
	move.l	lbL008128,D1
	and.l	#$F000,D0
	and.l	#$F000,D1
	cmp.l	D0,D1
	bne	lbC002B24
lbC002A1C
	move.l	(A0),D0
	cmp.b	#'I',II.MSG
	beq	lbC002A4E
	cmp.b	#'S',II.MSG
	bne	lbC002A4E
	move.l	lbL008128,D1
	and.l	#$F00,D0
	and.l	#$F00,D1
	cmp.l	D0,D1
	bne	lbC002B24
lbC002A4E
	move.l	(A0),D0
	cmp.b	#'I',I.MSG
	beq	lbC002A80
	cmp.b	#'S',I.MSG
	bne	lbC002A80
	move.l	lbL008128,D1
	and.l	#$FF,D0
	and.l	#$FF,D1
	cmp.l	D0,D1
	bne	lbC002B24
lbC002A80
	move.b	II.MSG0,D0
	move.l	lbL008128,D1
	and.l	#$FF000000,D1
	move.l	#$FF000000,D3
	bsr	lbC002B3C
	move.l	(A0),D0
	and.l	#$FF000000,D0
	cmp.l	#$F0000000,D0
	bne	lbC002AB4
	move.l	#$F4000000,(A0)
lbC002AB4
	move.b	II.MSG1,D0
	move.l	lbL008128,D1
	and.l	#$FF0000,D1
	move.l	#$FF0000,D3
	bsr	lbC002B3C
	move.b	II.MSG2,D0
	move.l	lbL008128,D1
	and.l	#$F000,D1
	move.l	#$F000,D3
	bsr	lbC002B3C
	move.b	II.MSG,D0
	move.l	lbL008128,D1
	and.l	#$F00,D1
	move.l	#$F00,D3
	bsr	lbC002B3C
	move.b	I.MSG,D0
	move.l	lbL008128,D1
	and.l	#$FF,D1
	move.l	#$FF,D3
	bsr	lbC002B3C
lbC002B24
	add.l	#4,A0
	bra	lbC00295C

lbC002B2E
	move.l	#0,D7
	bsr	lbC00446E
	bra	lbC00060A

lbC002B3C
	cmp.b	#'P',D0
	beq	lbC002B56
	cmp.b	#'+',D0
	beq	lbC002B66
	cmp.b	#'-',D0
	beq	lbC002B7C
	rts

lbC002B56
	move.l	(A0),D7
	eor.l	#$FFFFFFFF,D3
	and.l	D3,D7
	or.l	D1,D7
	move.l	D7,(A0)
	rts

lbC002B66
	move.l	(A0),D7
	add.l	D1,D7
	and.l	D3,D7
	move.l	(A0),D6
	eor.l	#$FFFFFFFF,D3
	and.l	D3,D6
	or.l	D7,D6
	move.l	D6,(A0)
	rts

lbC002B7C
	move.l	(A0),D7
	sub.l	D1,D7
	and.l	D3,D7
	move.l	(A0),D6
	eor.l	#$FFFFFFFF,D3
	and.l	D3,D6
	or.l	D7,D6
	move.l	D6,(A0)
	rts

lbC002B92
	clr.w	PatternHitEnd
	move.b	#$10,CharYPos
	lea	lbL008128,A0
	clr.b	D6
	bsr	DrawPatternLine
	move.b	#8,CharXPos
	move.b	II.MSG0,D0
	bsr	DrawChar
	move.b	#$15,CharXPos
	move.b	II.MSG1,D0
	bsr	DrawChar
	move.b	#$2F,CharXPos
	move.b	II.MSG2,D0
	bsr	DrawChar
	move.b	#$33,CharXPos
	move.b	II.MSG,D0
	bsr	DrawChar
	move.b	#$38,CharXPos
	move.b	I.MSG,D0
	bsr	DrawChar
	rts

lbC002C08
	move.l	RoutBuffer,A0
	tst.w	lbW007BDC
	bne	lbC002C2C
	clr.w	D0
	jsr	$68(A0)
	move.l	RoutBuffer,A0
	move.w	#$1F,D0
	jsr	$44(A0)
lbC002C2C
	move.b	MacroNoteValue,ILBMUnpackBuffer
	move.b	lbB007B89,ILBMUnpackBuffer+1
	move.b	MacroVolChanValue,ILBMUnpackBuffer+2
	clr.b	ILBMUnpackBuffer+3
	move.l	ILBMUnpackBuffer,D0
	move.l	RoutBuffer,A0
	jsr	$30(A0)
	tst.w	RecordKeyuFlag
	bne.s	.releaselp
	rts
.releaselp
	move.l	_GfxBase,a6
	jsr	_LVOWaitTOF(a6)
	move.l	4,A6
	move.l	WindowPtr,A0
	move.l	$56(A0),A0
	lea	$14(a0),a0
	cmp.l	8(a0),a0
	beq	.releaselp
	move.b	#$F5,ILBMUnpackBuffer
	move.l	ILBMUnpackBuffer,D0
	move.l	RoutBuffer,A0
	jsr	$30(A0)
	rts

lbC002C68
	move.l	PlyrMasterBlock,A1
	move.b	$47(A1),D0
	add.b	15(A0),D0
	and.b	#$3F,D0
	move.b	D0,$47(A1)
	rts

MacroNoteSetter
	move.b	MacroNoteValue,D0
	add.b	15(A0),D0
	and.b	#$3F,D0
	move.b	D0,MacroNoteValue
DisplayMacroNote
	clr.w	D1
	move.b	MacroNoteValue,D1
	asl.w	#2,D1
	move.l	NoteNameTablePtr,A0
	move.l	0(A0,D1.W),A0
	move.b	#$10,CharYPos
	move.b	#$2F,CharXPos
	bsr	DrawString
	rts

MacroVolumeSetter
	moveq	#0,d0
	move.b	15(a0),d0
	add.b	MacroVolChanValue,D0
	move.b	D0,MacroVolChanValue
DisplayMacroVolume
	move.b	MacroVolChanValue,d0
	lsr.b	#4,d0
	move.b	#$10,CharYPos
	move.b	#$25,CharXPos
	bsr	Draw1HexDigit
	rts

MacroChanSetter
	move.b	15(a0),d0
	add.b	MacroVolChanValue,D0
	and.w	#$7,d0
	and.b	#$F0,MacroVolChanValue
	or.b	D0,MacroVolChanValue
DisplayMacroChan
	move.b	MacroVolChanValue,d0
	and.w	#$F,d0
	move.b	#$10,CharYPos
	move.b	#$1A,CharXPos
	bsr	Draw1HexDigit
	rts

lbC002CBE
	move.l	RoutBuffer,A0
	jsr	$3C(A0)
	bsr	lbC002EF6
; ROUTINES: Replace me with LoadSeg/UnloadSeg!  Please?
	move.b	#$72,(A4)+
	move.b	#$6F,(A4)+
	move.b	#$75,(A4)+
	move.b	#$74,(A4)+
	lea	lbL0081E8,A5
	bsr	ReadFile
	move.l	RoutBuffer,A0
	move.l	MdatBuffer,D0
	move.l	SmplBuffer,D1
	move.l	#ChipBuffer,d2
	move.w	PlayRate7V,d3
	jsr	$34(A0)
	move.l	RoutBuffer,A0
	jsr	$38(A0)
	move.l	RoutBuffer,A0
	jsr	$4C(A0)
	move.l	$10(A0),A1
	move.l	#lbC0012B2,2(A1)
	move.l	12(A0),A1
	move.l	A1,PlyrPatternBlock
	move.l	4(A0),A2
	move.l	A2,PlyrMasterBlock
	move.l	A0,PlyrInfoBlock
	lea	lbW0080F8,A1
	move.w	4(A1),D3
	move.w	2(A1),D4
	move.w	#1,D0
	move.l	RoutBuffer,A6
	jsr	$68(A6)
	move.b	#6,$47(A2)
	lea	lbC001BBE,A1
	move.l	RoutBuffer,A0
	jsr	$50(A0)
	move.l	A0,MacroCmdTablePtr
	move.l	A1,NoteNameTablePtr
	move.l	A2,PatternCmdTablePtr
	move.l	RoutBuffer,D0
	move.l	#$FFFFFFFF,MacroCmdNameCount
lbC002D8A
	cmp.l	#$FFFFFFFF,(A0)
	beq	lbC002DA4
	add.l	D0,(A0)+
	add.l	#1,MacroCmdNameCount
	bra	lbC002D8A

lbC002DA4
	cmp.l	#$FFFFFFFF,(A1)
	beq	lbC002DB4
	add.l	D0,(A1)+
	bra	lbC002DA4

lbC002DB4
	cmp.l	#$FFFFFFFF,(A2)
	beq	lbC002DC4
	add.l	D0,(A2)+
	bra	lbC002DB4

lbC002DC4
	rts

lbC002DC6
	lea	lbL0081DC,A0
	move.l	#$C00,8(A0)
	move.l	#PattTmpBuffer,lbL007BD8
	bsr	lbC002EF6
	move.b	#$70,(A4)+
	move.b	#$61,(A4)+
	move.b	#$74,(A4)+
	move.b	#$74,(A4)+
	lea	lbL0081DC,A5
	bsr	ReadFile
	tst.l	D0
	beq	lbC002E10
	lsr.l	#2,D0
	sub.l	#1,D0
	move.l	D0,lbL007BB6
lbC002E10
	rts

lbC002E12
	bsr	lbC002EF6
	move.b	#'p',(A4)+
	move.b	#'a',(A4)+
	move.b	#'t',(A4)+
	move.b	#'t',(A4)+
	lea	lbL0081DC,A5
	bsr	GetPatternAddr
	move.l	A0,lbL007BD8
lbC002E36
	cmp.l	#$F0000000,(A0)
	beq	lbC002E4A
	add.l	#4,A0
	bra	lbC002E36

lbC002E4A
	sub.l	lbL007BD8,A0
	move.l	A0,8(A5)
	bsr	WriteFile
	bsr	lbC0035DE
	rts

lbC002E5E
	lea	lbL0081DC,A0
	move.l	#$C00,8(A0)
	move.l	#lbL00A704,lbL007BD8
	bsr	lbC002EF6
	move.b	#'m',(A4)+
	move.b	#'a',(A4)+
	move.b	#'c',(A4)+
	move.b	#'r',(A4)+
	lea	lbL0081DC,A5
	bsr	ReadFile
	tst.l	D0
	beq	lbC002E10
	lsr.l	#2,D0
	sub.l	#1,D0
	move.l	D0,lbL007BAC
	rts

lbC002EAA
	bsr	lbC002EF6
	move.b	#'m',(A4)+
	move.b	#'a',(A4)+
	move.b	#'c',(A4)+
	move.b	#'r',(A4)+
	lea	lbL0081DC,A5
	bsr	GetMacroAddr
	move.l	A0,lbL007BD8
lbC002ECE
	cmp.l	#$7000000,(A0)
	beq	lbC002EE2
	add.l	#4,A0
	bra	lbC002ECE

lbC002EE2
	sub.l	lbL007BD8,A0
	move.l	A0,8(A5)
	bsr	WriteFile
	bsr	lbC0035DE
	rts

lbC002EF6
	lea	ascii.MSG2,A0
	move.l	lbL007B98,A1
lbC002F02
	cmp.b	#0,(A1)
	beq	lbC002F10
	move.b	(A1)+,(A0)+
	bra	lbC002F02

lbC002F10
	cmp.b	#$3A,-1(A0)
	beq	lbC002F1E
	move.b	#$2F,(A0)+
lbC002F1E
	move.l	A0,A4
	move.l	lbL007B94,A1
	add.l	#4,A0
	move.b	#$2E,(A0)+
lbC002F30
	cmp.b	#0,(A1)
	beq	lbC002F3E
	move.b	(A1)+,(A0)+
	bra	lbC002F30

lbC002F3E
	move.b	#0,(A0)
	rts

lbC002F44
	bsr	lbC005D46
	bsr	lbC002F84
	move.l	lbL007B98,D0
	cmp.l	lbL007B9C,D0
	bne	lbC002F82
	bra	lbC00228C

lbC002F60
	bsr	lbC005D46
	bsr	lbC002F84
	move.b	#13,lbW002406
	move.b	#13,lbB007CA5
	move.l	lbL007B98,lbL007B9C
lbC002F82
	rts

lbC002F84
	move.l	lbL007BC6,D0
	and.l	#$3FF,D0
	lsr.l	#3,D0
	move.b	D0,CharXPos
	move.b	D0,lbB007CA4
	sub.b	#6,D0
	move.b	D0,lbB007D92
	rts

lbC002FAA
	move.l	lbL007BC6,D6
	and.l	#$3FF,D6
	lsr.l	#3,D6
	rts

lbC002FBA
	clr.l	D0
	move.b	lbB007CA5,D0
	sub.w	#4,D0
	add.w	lbW007B7C,D0
	move.w	D0,lbW007C9E
	move.l	InfoBuffer,A0
	asl.l	#2,D0
	add.l	D0,A0
	tst.l	$1400(A0)
	beq	lbC002FF4
	st	lbW007C9C
	move.l	#2,D7
	bra	lbC00219A

lbC002FF4
	bsr	lbC0019D4
	rts

lbC002FFA
	tst.l	D1
	beq	lbC003040
lbC003000
	move.w	CurrentMacroNum,-(SP)
	move.w	#$7F,CurrentMacroNum
lbC00300E
	bsr	GetMacroAddr
lbC003012
	move.b	(A0),D0
	cmp.b	#2,D0
	beq	lbC003042
	cmp.b	#7,D0
	beq	lbC00302E
lbC003024
	add.l	#4,A0
	bra	lbC003012

lbC00302E
	sub.w	#1,CurrentMacroNum
	bpl	lbC00300E
	move.w	(SP)+,CurrentMacroNum
lbC003040
	rts

lbC003042
	move.l	(A0),D0
	and.l	#$FFFFFF,D0
	cmp.l	D5,D0
	blt	lbC003024
	sub.l	D6,D0
	move.l	(A0),D1
	and.l	#$FF000000,D1
	or.l	D1,D0
	move.l	D0,(A0)+
	bra	lbC003012

AlertConfirmClear
	lea	ConfirmClearAlert,A0
	bsr	DisplayAlert25
	bne.s	.yes
	move.l	(SP)+,A0
.yes
	rts

lbC003074
	move.w	lbW007C28,D0
	add.w	14(A0),D0
	and.l	#15,D0
	move.w	D0,lbW007C28
	move.b	#15,CharYPos
	move.b	#$29,CharXPos
	bsr	Draw1HexDigit
	rts

GetDiskStatus
	move.l	#0,lbL007C0A
lbC0030AA
	move.l	A4,-(SP)
	move.l	D6,-(SP)
	move.l	D7,-(SP)
	bsr	lbC003144
	move.l	(SP)+,D7
	move.l	(SP)+,D6
	move.l	(SP)+,A4
	lea	DiskInfoBlock,A0
	move.l	id_DiskType(A0),D0
	cmp.l	#$FFFFFFFF,D0
	bne	lbC0030D8
	lea	NoDiscAlert,A0
	bra	lbC003124

lbC0030D8
	cmp.l	#$444F5300,d0
	beq	lbC0030EE
	cmp.l	#$444F5301,d0		Thierolf, grow up! =:^)
	beq	lbC0030EE
	lea	DiscErrorAlert,A0
	bra	lbC003124

lbC0030EE
	tst.l	D6
	bne	lbC003108
	cmp.b	#$50,id_DiskState+3(A0)
	bne	lbC003108
	lea	WriteProtectedAlert,A0
	bra	lbC003124

lbC003108
	cmp.b	#$51,id_DiskState+3(A0)
	bne	lbC00311C
	lea	ValidatingAlert,A0
	bra	lbC003124

lbC00311C
	move.l	lbL007C0A,D0
	rts

lbC003124
	clr.l	D0
	move.l	#$2D,D1
	move.l	_IntuitionBase,A6
	jsr	_LVODisplayAlert(A6)
	tst.l	D0
	bne	lbC0030AA
	move.l	#1,D0
	rts

lbC003144
	move.l	lbL007B90,D0
	asl.l	#2,D0
	lea	lbL00267C,A0
	move.l	0(A0,D0.L),A0
	move.b	4(A0),-(SP)
	clr.b	4(A0)
	move.l	A0,D1
	move.l	A0,-(SP)
	move.l	#$FFFFFFFE,D2
	move.l	_DosBase,A6
	jsr	_LVOLock(A6)
	move.l	D0,lbL007C06
	move.l	lbL007C06,D1
	move.l	#DiskInfoBlock,D2
	move.l	_DosBase,A6
	jsr	_LVOInfo(A6)
	move.l	lbL007C06,D1
	move.l	_DosBase,A6
	jsr	_LVOUnLock(A6)
	move.l	(SP)+,A0
	move.b	(SP)+,4(A0)
	rts

	rts

	move.w	D0,-(SP)
	move.w	#$3E8,D0
lbC0031AE
	dbra	D0,lbC0031AE
	move.w	(SP)+,D0
	rts

lbC0031B6
	move.l	lbL007BD2,A0
	cmp.w	#$8129,4(A0)
	beq	lbC003224
	move.l	lbL007C00,A0
	move.w	#$812A,4(A0)
	moveq	#0,D1
	moveq	#0,D2
	move.b	7(A0),D1
	move.b	6(A0),D2
	move.l	#$2A,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	move.l	lbL007BD2,A0
	move.l	A0,lbL007C00
	move.w	#$8129,4(A0)
	move.b	7(A0),D1
	move.b	6(A0),D2
	move.w	14(A0),lbW007BFE
	move.l	#$29,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
lbC003224
	rts

lbC003226
	btst	#6,$BFE001
	beq	lbC003226
	move.w	#$50,D0
lbC003236
	dbra	D0,lbC003236
	btst	#6,$BFE001
	beq	lbC003226
	move.l	#$FFFFFFFF,lbL007BB6
	bsr	lbC001A74
	moveq	#0,D7
	move.w	lbW007C0E,D0
	tst.b	D0
	beq	lbC003278
	bset	#1,D7
	lea	lbW0080F8,A1
	tst.w	4(A1)
	beq	lbC003278
	bset	#0,D7
lbC003278
	move.w	RecordKeyuFlag,D0
	asl.w	#3,D0
	or.w	D0,D7
	lea	lbW0080F8,A1
	move.l	#PattTmpBuffer,A0
	move.w	8(A1),D0
	clr.l	D1
	move.b	lbW008096,D1
	subq.l	#7,D1
	add.l	lbL007B62,D1
	move.l	D1,D2
	asl.l	#4,D2
	move.l	MdatBuffer,A6
	add.l	#$800,A6
	add.l	D2,A6
	cmp.w	#$EFFE,(A6)
	beq	lbC00352C
	clr.l	ILBMUnpackBuffer
	move.b	lbB007B89,lbB007BFB
	move.b	#$80,lbB007BFC
	move.b	11(A1),D6
	or.b	D6,lbB007BFC
	move.l	PlyrMasterBlock,A3
	move.b	$47(A3),ILBMUnpackBuffer
	move.l	ILBMUnpackBuffer,D6
	move.w	(A1),D2
	move.w	4(A1),D3
	move.w	2(A1),D4
	move.w	6(A1),D5
	move.l	D7,-(SP)
	move.b	#$C0,$BFEC01
	move.l	RoutBuffer,A6
	jsr	$64(A6)			record
	move.w	#$12C,ILBMUnpackBuffer
lbC003320
	clr.b	KeyASCIIKeyCode
	bsr	lbC001B74
lbC00332A
	sub.w	#1,ILBMUnpackBuffer
	beq	lbC003364
	bsr	lbC005CE4
	bsr	Vsync
	move.l	4,A6
	lea	ConReadPort,A0
	jsr	_LVOGetMsg(A6)
	tst.l	D0
	beq	lbC00332A
	cmp.b	#0,KeyASCIIKeyCode
	beq	lbC00332A
	bra	lbC003320

lbC003364
	move.l	(SP)+,D7
	tst.l	D7
	beq	lbC003504
	move.b	#7,lbB007CA5
	move.b	#9,lbB007CA4
	lea	PattTmpBuffer,A0
	moveq.l	#0,D6
lbC003388
	cmp.l	#$FF000000,(A0)
	beq	lbC0033AC
	cmp.l	#$F0000000,(A0)
	beq	lbC003428
	add.l	#8,A0
	add.l	#2,D6
	bra	lbC003388

lbC0033AC
	cmp.l	#PattTmpBuffer,A0
	beq	lbC0033F6
	move.l	-4(A0),D0
	move.l	4(A0),D1
	and.l	#$FF0000,D1
	add.l	#$10000,D1
	add.l	D1,D0
	move.l	D0,-4(A0)
	move.l	A0,A1
	move.l	A0,A2
	add.l	#8,A1
lbC0033DA
	move.l	(A1),(A2)
	cmp.l	#$F0000000,(A1)
	beq	lbC003388
	add.l	#4,A1
	add.l	#4,A2
	bra	lbC0033DA

lbC0033F6
	move.l	A0,A1
	move.l	A0,A2
	add.l	#4,A0
	add.l	#1,D6
	add.l	#4,A1
lbC00340C
	move.l	(A1),(A2)
	cmp.l	#$F0000000,(A1)
	beq	lbC003388
	add.l	#4,A1
	add.l	#4,A2
	bra	lbC00340C

lbC003428
	move.l	D6,lbL007BB6
	sub.l	#1,lbL007BB6
	clr.l	D1
	move.b	lbW008096,D1
	sub.l	#7,D1
	add.l	lbL007B62,D1
	move.l	MdatBuffer,A0
	add.l	#$800,A0
	asl.l	#4,D1
	add.l	D1,A0
	move.w	lbW007C0E,D0
	beq	lbC003504
	sub.w	#1,D0
	asl.w	#1,D0
	clr.l	D1
	move.b	0(A0,D0.W),D1
	cmp.b	#$80,D1
	bcc	lbC003504
	move.w	D1,CurrentPattNum
	move.l	#0,D7
	bsr	DrawActivePage
	move.b	#9,lbB007CA4
	move.b	#7,lbB007CA5
	clr.b	lbB007D92
	clr.l	lbW007B78
	bsr	GetPatternAddr
	cmp.l	#$F4000000,(A0)
	bne	lbC003538
	cmp.l	#$F0000000,4(A0)
	bne	lbC003538
	clr.b	D5
	bsr	lbC00532A
	bsr	GetPatternAddr
	move.l	#0,lbW007B78
lbC0034D4
	cmp.l	#$F4000000,(A0)+
	beq	lbC0034EC
	add.l	#1,lbW007B78
	bra	lbC0034D4

lbC0034EC
	clr.b	D5
	bsr	PattDeletePattLine
	clr.l	lbW007B78
	bsr	DrawPatternLines
	bsr	PattPrintLength
	bsr	lbC002B92
lbC003504
	tst.w	MetronomeFlag
	beq	lbC00352A
	lea	lbW0080F8,A1
	move.w	4(A1),D3
	move.w	2(A1),D4
	move.w	#1,D0
	move.l	RoutBuffer,A6
	jsr	$68(A6)
lbC00352A
	rts

lbC00352C
	lea	SpclStatementAlert,A0
	bsr	DisplayAlert25
	rts

lbC003538
	lea	PattNotClearedAlert,A0
	bsr	DisplayAlert25
	rts

lbC003544
	lea	lbW008118,A0
	lea	lbW0080F8,A1
	move.w	0(A1,D7.W),D0
	cmp.w	0(A0,D7.W),D0
	beq	lbC0035DC
	add.w	#1,0(A1,D7.W)
	bsr	lbC00358C
	rts

lbC003568
	lea	lbW008108,A0
	lea	lbW0080F8,A1
	move.w	0(A1,D7.W),D0
	cmp.w	0(A0,D7.W),D0
	beq	lbC0035DC
	sub.w	#1,0(A1,D7.W)
	bsr	lbC00358C
	rts

lbC00358C
	lea	lbW0080F8,A6
	lea	RecordCursorLocations,A5
	move.w	#7,D7
lbC00359C
	move.b	0(A5,D7.W),CharXPos
	move.b	8(A5,D7.W),CharYPos
	tst.b	$10(A5,D7.W)
	bne	lbC0035C8
	move.w	D7,D0
	asl.w	#1,D0
	move.w	0(A6,D0.W),D0
	and.w	#$FF,D0
	bsr	Draw2HexDigits
	bra	lbC0035D8

lbC0035C8
	move.w	D7,D0
	asl.w	#1,D0
	move.w	0(A6,D0.W),D0
	and.w	#15,D0
	bsr	Draw1HexDigit
lbC0035D8
	dbra	D7,lbC00359C
lbC0035DC
	rts

lbC0035DE
	move.l	lbL007B98,A0
	move.w	#$2C,D0
lbC0035E8
	cmp.b	#$20,0(A0,D0.W)
	bne	lbC0035F6
	dbra	D0,lbC0035E8
lbC0035F6
	move.b	#0,1(A0,D0.W)
	move.w	D0,-(SP)
	bsr	lbC002EF6
	move.w	(SP)+,D0
	move.l	lbL007B98,A0
	move.b	#$20,1(A0,D0.W)
	move.b	#'f',(A4)+
	move.b	#'s',(A4)+
	move.b	#'t',(A4)+
	move.b	#'d',(A4)+
	move.b	#0,1(A4)
	move.l	#ascii.MSG2,D1
	move.l	_DosBase,A6
	jsr	_LVODeleteFile(A6)
	rts

lbC003638
	move.l	lbL007BC6,D0
	swap	D0
	sub.w	#$18,D0
	lsr.w	#3,D0
	move.w	D0,D7
	bra	lbC00364C

lbC00364C
	move.l	lbL007BC2,A0
	cmp.b	#$FE,(A0)
	beq	lbC00375C
	tst.w	D7
	beq	lbC00367E
	sub.w	#1,D7
lbC003664
	cmp.b	#$FE,(A0)
	beq	lbC00375C
	add.l	#2,A0
lbC003672
	cmp.b	#0,(A0)+
	bne	lbC003672
	dbra	D7,lbC003664
lbC00367E
	cmp.b	#$FE,(A0)
	beq	lbC00375C
	clr.w	D0
	move.b	(A0)+,D0
	cmp.b	#2,(A0)+
	beq	lbC0036FE
	move.l	lbL007B94,A1
	clr.w	D0
lbC00369A
	tst.b	0(A0,D0.W)
	beq	lbC0036B6
	move.b	0(A0,D0.W),D1
	cmp.b	0(A1,D0.W),D1
	bne	lbC0036CC
	add.w	#1,D0
	bra	lbC00369A

lbC0036B6
	cmp.w	#$FFFE,ActivePageNr
	beq	lbC00375C
	move.l	(SP)+,D0
	move.l	(SP)+,D0
	move.l	(SP)+,D0
	bra	lbC00254C

lbC0036CC
	move.w	#$2C,D0
lbC0036D0
	move.b	#$20,0(A1,D0.W)
	dbra	D0,lbC0036D0
lbC0036DA
	move.b	(A0)+,(A1)+
	tst.b	(A0)
	bne	lbC0036DA
	move.b	#15,CharYPos
	move.b	#6,CharXPos
	move.l	lbL007B94,A0
	bsr	DrawString
	rts

lbC0036FE
	move.l	lbL007B98,A1
	move.w	#$2B,D0
lbC003708
	tst.b	0(A1,D0.W)
	bne	lbC003716
	move.b	#$20,0(A1,D0.W)
lbC003716
	dbra	D0,lbC003708
	add.l	#4,A1
	move.w	#$28,D0
lbC003724
	cmp.b	#$20,0(A1,D0.W)
	bne	lbC003736
	dbra	D0,lbC003724
	bra	lbC003740

lbC003736
	cmp.b	#':',-1(a1,d0.w)
	beq.s	lbC003740
	addq.w	#1,D0
	move.b	#$2F,0(A1,D0.W)
lbC003740
	add.w	D0,A1
	addq.l	#1,A1
lbC00374A
	move.b	(A0)+,(A1)+
	tst.b	(A1)
	beq	lbC003758
	tst.b	(A0)
	bne	lbC00374A
lbC003758
	bra	lbC00228C

lbC00375C
	rts

lbC00375E
	move.l	lbL007B98,A0
	addq.l	#4,A0
	moveq.w	#$28,D0
lbC00376E
	cmp.b	#$2F,0(A0,D0.W)
	beq	lbC003786
	cmp.b	#':',(a0,d0.w)
	beq	lbC00228C
	move.b	#$20,0(A0,D0.W)
	dbra	D0,lbC00376E
	bra	lbC00228C

lbC003786
	move.b	#$20,0(A0,D0.W)
	bra	lbC00228C

lbC003790
	tst.w	ActivePageNr
	bpl	lbC002F82
	cmp.w	#$FFFD,ActivePageNr
	beq	lbC002F82
	lea	DF0DF1DF2DF3D.MSG,A0
	add.w	d7,a0
	move.l	lbL007B98,A1
	move.l	a1,a2
	moveq	#1,d1
.lp
	subq.b	#1,d1
	move.b	(a2)+,d0
	beq.s	.sk
	cmp.b	#':',d0
	bne.s	.lp
.lp2
	move.b	(a2)+,(a1)+
	bne.s	.lp2
	subq.w	#1,a1
	moveq	#' ',d2
.lp3
	move.b	d2,(a1)+
	tst.b	(a1)
	bne.s	.lp3
.sk
	subq.w	#1,a2
	lea	-4(a2),a1
	move.l	lbL007B98,d0
.lp4
	move.b	-(a1),-(a2)
	cmp.l	lbL007B98,a1
	bne.s	.lp4
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	bra	lbC00228C

DF0DF1DF2DF3D.MSG
	dc.b	'DF0:DF1:DF2:DF3:DH0:DH1:RAM:'

lbC0037D8
	st	D6
	bsr	GetDiskStatus
	tst.l	D0
	bne	lbC002404
	lea	ascii.MSG2,A0
	lea	DF0songs.MSG,A1
lbC0037F0
	cmp.b	#0,(A1)
	beq	lbC0037FE
	move.b	(A1)+,(A0)+
	bra	lbC0037F0

lbC0037FE
	cmp.b	#$3A,-1(A0)
	beq	lbC00380C
	move.b	#$2F,(A0)+
lbC00380C
	move.l	A0,-(SP)
	lea	ascii.MSG9,A1
	move.b	#'m',(A0)+
	move.b	#'d',(A0)+
	move.b	#'a',(A0)+
	move.b	#'t',(A0)+
	move.b	#'.',(A0)+
lbC003828
	cmp.b	#0,(A1)
	beq	lbC003836
	move.b	(A1)+,(A0)+
	bra	lbC003828

lbC003836
	move.b	#0,(A0)
	clr.b	D5
	bsr	ClearTracks
	move.l	_DosBase,A6
	move.l	#ascii.MSG2,D1
	move.l	#$3ED,D2
	bsr	LoadMdat
	beq	lbC003920
	move.l	(SP)+,A0
	move.l	A0,-(SP)
	move.b	#'s',(A0)+
	move.b	#'m',(A0)+
	move.b	#'p',(A0)+
	move.b	#'l',(A0)+
	move.l	SmplBufEndPtr,-(SP)
	lea	lbL0081A0(PC),A5
	bsr	ReadFile
	add.l	SmplBuffer,D0
	move.l	D0,SmplBufEndPtr
	move.l	(SP)+,D1
	cmp.l	D0,D1
	ble	lbC00389A
	move.l	D0,A0
lbC003892
	clr.b	(A0)+
	cmp.l	A0,D1
	bne	lbC003892
lbC00389A
	move.l	(SP)+,A0
	move.b	#'i',(A0)+
	move.b	#'n',(A0)+
	move.b	#'f',(A0)+
	move.b	#'o',(A0)+
	move.l	InfoBuffer,A0
	move.w	#$EA5,D0
lbC0038B6
	clr.l	(A0)+
	dbra	D0,lbC0038B6
	move.l	InfoBuffer,A0
	move.l	#$2800,$2400(A0)
	lea	lbL0081D0(PC),A5
	bsr	ReadFile
	move.w	#0,CurrentSongNum
lbC0038DA
	bsr	DrawSongInfo
	bsr	lbC001142
	move.l	RoutBuffer,A0
	move.l	MdatBuffer,D0
	move.l	SmplBuffer,D1
	move.l	#ChipBuffer,d2
	move.w	PlayRate7V,d3
	jsr	$34(A0)
	bsr	lbC005596
	rts

lbC003920
	move.l	(SP)+,A0
	bra	lbC0038DA

LoadMdat
	jsr	_LVOOpen(A6)
	beq	lbC0039EC
	move.l	D0,TmpFileHandle
	move.l	D0,D1
	move.l	MdatBuffer,D2
	move.l	#$200,D3
	jsr	_LVORead(A6)
	move.l	#$C600,D3
	move.l	MdatBuffer,A0
	tst.l	$1D0(a0)
	bne	LoadPro2Mdat
	move.l	MdatBuffer,D2
	add.l	#$200,D2
	move.w	10(A0),ILBMUnpackBuffer
	beq	lbC0039C2
	clr.w	10(A0)
	move.l	12(A0),D3
	move.l	MdatBuffer,D2
	add.l	#$200,D2
	sub.l	#$1F0,d3
	move.l	TmpFileHandle,D1
	jsr	_LVORead(A6)
	move.l	MdatBuffer,A5
	move.l	#$2800,D0
	move.l	12(A5),D1
	clr.l	12(A5)
	add.l	#$10,D1
	sub.l	D1,D0
	add.l	#$400,A5
	move.w	#$FF,D1
lbC0039AA
	add.l	D0,(A5)+
	dbra	D1,lbC0039AA
	move.l	MdatBuffer,D2
	add.l	#$2800,D2
	move.l	#$A000,D3
lbC0039C2
	move.l	TmpFileHandle,D1
	move.l	D2,-(SP)
	jsr	_LVORead(A6)
	addq.l	#4,D0
	add.l	(SP)+,D0
	move.l	D0,MdatBufEndPtr
	move.l	_DosBase,A6
	move.l	TmpFileHandle,D1
	jsr	_LVOClose(A6)
lbC0039EC
	rts

LoadPro2Mdat
	move.l	MdatBuffer,a5
	move.l	#$C600,d0
	moveq	#1,d1
	swap.w	d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq	.endit
	move.l	d0,a3
	move.l	TmpFileHandle,d1
	move.l	a3,d2
	move.l	#$C600,d3
	move.l	_DosBase,a6
	jsr	_LVORead(a6)
	move.l	TmpFileHandle,d1
	jsr	_LVOClose(a6)
	lea	-$200(a3),a3

; Let's copy the tracks....
	lea	$800(a5),a0
	move.l	a5,d1
	add.l	#$2800,d1
	move.l	$1D4(a5),a2
	add.l	a3,a2
	move.l	(a2),d2
	move.l	a2,d5
	add.l	a3,d2
	move.l	$1D0(a5),a1
	add.l	a3,a1
.copytrklp
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	cmp.l	a0,d1
	ble.s	.nulltrksk
	cmp.l	a1,d2
	bgt.s	.copytrklp
	move.l	#$FF00FF00,d0
.nulltrklp
	move.l	d0,(a0)+
	cmp.l	a0,d1
	bgt.s	.nulltrklp
.nulltrksk
	lea	(a0),a2
	lea	$400(a5),a0
	move.l	a1,d3
	sub.l	#$2800,d3
	move.l	$1D8(a5),d4
	sub.l	$1D4(a5),d4
	add.l	a0,d4
.copypatlp1
	move.l	a1,(a0)
	sub.l	d3,(a0)+
	moveq	#0,d0
	cmp.l	#$F0,(a1)
	bne.s	.copypatlp2
	move.l	#$F4000000,(a2)+
	subq.l	#4,d3
.copypatlp2
	cmp.b	#$F0,(a1)
	sne	d0
	move.l	(a1)+,(a2)+
	dbf	d0,.copypatlp2
	cmp.l	a0,d4
	bgt.s	.copypatlp1
	move.l	a5,d4
	add.l	#$600,d4
.nullpatlp
	move.l	a1,(a0)
	sub.l	d3,(a0)+
	subq.l	#8,d3
	move.l	#$F4000000,(a2)+
	move.l	#$F0000000,(a2)+
	cmp.l	a0,d4
	bgt.s	.nullpatlp
; copy macros
.copymaclp1
	move.l	a1,(a0)
	sub.l	d3,(a0)+
	moveq	#0,d0
	cmp.b	#$07,(a1)
	bne.s	.copymaclp2
	subq.l	#4,d3
	move.l	#$04000000,(a2)+
.copymaclp2
	cmp.b	#$07,(a1)
	sne	d0
	move.l	(a1)+,(a2)+
	dbf	d0,.copymaclp2
	cmp.l	a1,d5
	bgt.s	.copymaclp1
	move.l	a5,d4
	add.l	#$800,d4
.nullmaclp
	move.l	a1,(a0)
	sub.l	d3,(a0)+
	subq.l	#8,d3
	move.l	#$04000000,(a2)+
	move.l	#$07000000,(a2)+
	cmp.l	a0,d4
	bgt.s	.nullmaclp
	lea	$200(a3),a1
	move.l	#$C600,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	clr.l	(a2)+
	move.l	a2,MdatBufEndPtr
	moveq	#0,d0
	move.l	d0,$1D0(a5)
	move.l	d0,$1D4(a5)
	move.l	d0,$1D8(a5)
	moveq	#1,d0
	rts
.endit
	moveq	#0,d0
	rts

WriteAll
	clr.l	D6
	bsr	GetDiskStatus
	tst.l	D0
	bne	lbC002404
	lea	ascii.MSG2,A0
	lea	DF0songs.MSG,A1
lbC003A06
	cmp.b	#0,(A1)
	beq	lbC003A14
	move.b	(A1)+,(A0)+
	bra	lbC003A06

lbC003A14
	cmp.b	#$3A,-1(A0)
	beq	lbC003A22
	move.b	#$2F,(A0)+
lbC003A22
	move.l	A0,-(SP)
	lea	ascii.MSG9,A1
	move.b	#'m',(A0)+
	move.b	#'d',(A0)+
	move.b	#'a',(A0)+
	move.b	#'t',(A0)+
	move.b	#'.',(A0)+
lbC003A3E
	cmp.b	#0,(A1)
	beq	lbC003A4C
	move.b	(A1)+,(A0)+
	bra	lbC003A3E

lbC003A4C
	move.b	#0,(A0)
	move.l	MdatBuffer,A0
	move.w	SongCompressFlag,10(A0)
	add.l	#$800,A0
	move.w	#$1FF0,D0
lbC003A68
	cmp.l	#$FF00FF00,0(A0,D0.W)
	bne	lbC003AA0
	cmp.l	#$FF00FF00,4(A0,D0.W)
	bne	lbC003AA0
	cmp.l	#$FF00FF00,8(A0,D0.W)
	bne	lbC003AA0
	cmp.l	#$FF00FF00,12(A0,D0.W)
	bne	lbC003AA0
	sub.w	#$10,D0
	bne	lbC003A68
lbC003AA0
	add.w	#$810,D0
	and.l	#$FFFF,D0
	move.l	D0,ILBMUnpackBuffer
	move.l	MdatBuffer,A0
	move.l	#$2800,D1
	sub.l	D0,D1
	sub.l	#$10,D0
	move.l	D0,12(A0)
	move.l	MdatBuffer,A6
	add.l	#$400,A6
	move.w	#$FF,D0
lbC003AD8
	sub.l	D1,(A6)+
	dbra	D0,lbC003AD8
	move.l	D1,-(SP)
	move.l	_DosBase,A6
	move.l	#ascii.MSG2,D1
	move.l	#$3EE,D2
	jsr	_LVOOpen(A6)
	move.l	D0,TmpFileHandle
	move.l	D0,D1
	move.l	ILBMUnpackBuffer,D3
	move.l	MdatBuffer,D2
	jsr	_LVOWrite(A6)
	move.l	(SP)+,D1
	move.l	MdatBuffer,A6
	add.l	#$400,A6
	move.w	#$FF,D0
lbC003B20
	add.l	D1,(A6)+
	dbra	D0,lbC003B20
	move.l	_DosBase,A6
	move.l	TmpFileHandle,D1
	move.l	MdatBuffer,D2
	add.l	#$2800,D2
	move.l	MdatBufEndPtr,D3
	sub.l	MdatBuffer,D3
	sub.l	#$2804,D3
	jsr	_LVOWrite(A6)
	move.l	D0,D7
	bsr	CloseFile
	bra	lbC003B88

	move.l	MdatBuffer,A0
	bclr	#0,15(A0)
	lea	lbL008194(PC),A5
	move.l	MdatBufEndPtr,D0
	sub.l	MdatBuffer,D0
	sub.l	#4,D0
	move.l	D0,8(A5)
	bsr	WriteFile
lbC003B88
	move.l	(SP)+,A0
	tst.w	lbB007C14
	beq	lbC003C00
	move.l	A0,-(SP)
	move.b	#'s',(A0)+
	move.b	#'m',(A0)+
	move.b	#'p',(A0)+
	move.b	#'l',(A0)+
	lea	lbL0081B8(PC),A5
	move.l	SmplBufEndPtr,D0
	sub.l	SmplBuffer,D0
	move.l	D0,8(A5)
	bsr	WriteFile
	move.l	(SP)+,A0
	move.b	#'i',(A0)+
	move.b	#'n',(A0)+
	move.b	#'f',(A0)+
	move.b	#'o',(A0)+
	move.l	#$3A98,A0
	move.l	InfoBuffer,A0
	add.l	#$3C00,A0
lbC003BE2
	tst.b	-(A0)
	beq	lbC003BE2
	sub.l	InfoBuffer,A0
	add.l	#1,A0
	lea	lbL0081D0(PC),A5
	move.l	A0,8(A5)
	bsr	WriteFile
lbC003C00
	bsr	lbC0035DE
	bsr	lbC005596
	rts

lbC003C0A
	clr.l	D6
	bsr	GetDiskStatus
	bne	lbC003C36
	bsr	lbC005596
	bsr	lbC003D76
	move.l	SampleRoutBuffer,A0
	move.l	$24(A0),A0
	add.l	SampleRoutBuffer,A0
	lea	ascii.MSG2,A1
	jsr	12(A0)
lbC003C36
	rts

lbC003C38
	st	D6
	bsr	GetDiskStatus
	bne	lbC003C36
	move.l	SampleRoutBuffer,A0
	move.l	$24(A0),A0
	add.l	SampleRoutBuffer,A0
	jsr	$14(A0)
	rts

lbC003C58
	clr.l	lbL007C20
	clr.l	lbL007C24
	st	D6
	bsr	GetDiskStatus
	tst.l	D0
	bne	lbC002404
	bsr	lbC005596
	move.l	SmplBuffer,A0
	add.l	SmplSizeVal,A0
	cmp.l	SmplBufEndPtr,A0
	bcs	DisplayMemoryAlert
	bsr	lbC003D76
	bne	lbC003DA4
	move.b	#0,(A0)
	cmp.w	#1,lbW007BFE
	beq	Read8SVX
	cmp.w	#2,lbW007BFE
	beq	lbC003DC8
	tst.w	lbW007C9C
	bne	lbC003F42
	move.l	SmplBufEndPtr,D1
	sub.l	SmplBuffer,D1
	move.l	SmplSizeVal,D0
	sub.l	D1,D0
	beq	DisplayMemoryAlert
	lea	lbL0081C4(PC),A5
	move.l	D0,8(A5)
	bsr	ReadFile
lbC003CDC
	tst.l	SampleRoutBuffer
	bne	lbC003D74
	tst.l	D0
	beq	lbC003D74
	cmp.l	#$80000,D0
	bcc	lbC003D74
	move.l	InfoBuffer,A0
	add.l	#$1400,A0
lbC003D02
	tst.l	(A0)+
	bne	lbC003D02
	move.l	SmplBufEndPtr,D1
	sub.l	SmplBuffer,D1
	move.l	D1,-4(A0)
	move.l	D0,$3FC(A0)
	tst.l	lbL007C20
	beq	lbC003D3A
	move.l	D1,D5
	add.l	lbL007C20,D5
	move.l	D5,$7FC(A0)
	move.l	lbL007C24,$BFC(A0)
lbC003D3A
	move.l	$FFC(A0),A2
	add.l	InfoBuffer,A2
	move.w	#$13,D1
	lea	ascii.MSG8,A1
lbC003D4E
	sub.w	#1,D1
	beq	lbC003D60
	move.b	(A1)+,(A2)+
	cmp.b	#0,(A1)
	bne	lbC003D4E
lbC003D60
	move.b	#0,(A2)+
	sub.l	InfoBuffer,A2
	move.l	A2,$1000(A0)
	add.l	D0,SmplBufEndPtr
lbC003D74
	rts

lbC003D76
	lea	ascii.MSG2,A0
	lea	DF0samples.MSG,A1
lbC003D82
	cmp.b	#0,(A1)
	beq	lbC003D90
	move.b	(A1)+,(A0)+
	bra	lbC003D82

lbC003D90
	cmp.b	#$3A,-1(A0)
	beq	lbC003D9E
	move.b	#$2F,(A0)+
lbC003D9E
	lea	ascii.MSG8,A1
lbC003DA4
	move.b	(A1)+,(A0)+
	cmp.b	#$5C,-1(A1)
	beq	lbC003DBE
lbC003DB0
	cmp.b	#0,(A1)
	bne	lbC003DA4
	move.b	#0,(A0)
	rts

lbC003DBE
	move.b	#$20,-1(A0)
	bra	lbC003DB0

lbC003DC8
	move.l	SmplBufEndPtr,D1
	sub.l	SmplBuffer,D1
	move.l	SmplSizeVal,D0
	sub.l	D1,D0
	lea	lbL0081C4(PC),A5
	move.l	D0,8(A5)
	move.l	_DosBase,A6
	move.l	0(A5),D1
	move.l	#$3ED,D2
	jsr	_LVOOpen(A6)
	beq	lbC003D74
	move.l	D0,TmpFileHandle
	move.l	TmpFileHandle,D1
	move.l	#lbW0080D6,D2
	move.l	#6,D3
	jsr	_LVORead(A6)
	tst.l	D0
	beq	CloseFile
	lea	lbL0081C4(PC),A5
	bsr	ReadCloseFile
	bra	lbC003CDC

Read8SVX
	move.l	SmplBufEndPtr,D1
	sub.l	SmplBuffer,D1
	move.l	SmplSizeVal,D0
	sub.l	D1,D0
	lea	lbL0081C4(PC),A5
	move.l	D0,8(A5)
	move.l	_DosBase,A6
	move.l	0(A5),D1
	move.l	#$3ED,D2
	jsr	_LVOOpen(A6)
	beq	lbC003D74
	move.l	D0,TmpFileHandle
	bsr	ReadLongword
	beq	CloseFile
	cmp.l	#'FORM',LongValue
	bne	CloseFile
	bsr	ReadLongword
	bsr	ReadLongword
	cmp.l	#'8SVX',LongValue
	bne	CloseFile
lbC003E90
	bsr	ReadLongword
	beq	CloseFile
	cmp.l	#'BODY',LongValue
	beq	lbC003EDC
	cmp.l	#'VHDR',LongValue
	beq	lbC003EF0
	bsr	ReadLongword
	beq	CloseFile
	move.l	LongValue,D2
	addq.l	#1,D2
	bclr	#0,D2
	move.l	#0,D3
	move.l	TmpFileHandle,D1
	jsr	_LVOSeek(A6)
	bra	lbC003E90

lbC003EDC
	bsr	ReadLongword
	beq	CloseFile
	lea	lbL0081C4(PC),A5
	bsr	ReadCloseFile
	bra	lbC003CDC

lbC003EF0
	bsr	ReadLongword
	bsr	ReadLongword
	move.l	LongValue,lbL007C20
	bsr	ReadLongword
	move.l	LongValue,D0
	lsr.l	#1,D0
	move.l	D0,lbL007C24
	bsr	ReadLongword
	bsr	ReadLongword
	bsr	ReadLongword
	bra	lbC003E90

ReadLongword
	move.l	_DosBase,A6
	move.l	TmpFileHandle,D1
	move.l	#LongValue,D2
	move.l	#4,D3
	jsr	_LVORead(A6)
	rts

lbC003F42
	bsr	GetFileSize
	tst.l	D7
	beq	lbC003D74
	move.l	SmplBuffer,D0
	add.l	SmplSizeVal,D0
	sub.l	SmplBufEndPtr,D0
	cmp.l	D0,D7
	bgt	DisplayMemoryAlert
	move.l	InfoBuffer,A0
	clr.l	D0
	move.w	lbW007C9E,D0
	asl.l	#2,D0
	add.l	D0,A0
	move.l	$1400(A0),A0
	move.l	A0,D5
	add.l	SmplBuffer,A0
	bsr	lbC003FFC
	lea	lbL00820C,A5
	move.l	D7,8(A5)
	move.l	A0,lbL007BD8
	move.l	D7,D6
	neg.l	D6
	bsr	lbC003000
	lea	lbL00820C,A5
	bsr	ReadFile
	bra	lbC003CDC

GetFileSize
	clr.l	D7
	lea	lbL0081C4(PC),A5
	move.l	D0,8(A5)
	move.l	_DosBase,A6
	move.l	0(A5),D1
	move.l	#$3ED,D2
	jsr	_LVOOpen(A6)
	tst.l	D0
	beq	lbC003FFA
	move.l	D0,TmpFileHandle
	move.l	D0,D1
	moveq	#0,D2
	moveq	#1,D3
	jsr	_LVOSeek(A6)
	move.l	TmpFileHandle,D1
	moveq	#0,D2
	moveq	#0,D3
	jsr	_LVOSeek(A6)
	move.l	D0,D7
	move.l	TmpFileHandle,D1
	jsr	_LVOClose(A6)
lbC003FFA
	rts

lbC003FFC
	move.l	SmplBufEndPtr,A1
	move.l	A1,A2
	add.l	D7,A2
lbC004006
	move.b	-(A1),-(A2)
	cmp.l	A0,A2
	bge	lbC004006
	rts

lbC004010
	lea	lbL009F04,A5
	move.w	#$300,D0
lbC00401A
	move.l	#$FEFEFEFE,(A5)+
	dbra	D0,lbC00401A
	move.l	lbL007B98,A0
	move.w	#$2C,D0
lbC00402E
	cmp.b	#$20,0(A0,D0.W)
	bne	lbC00403C
	dbra	D0,lbC00402E
lbC00403C
	move.b	#0,1(A0,D0.W)
	move.w	D0,-(SP)
	bsr	lbC002EF6
	move.w	(SP)+,D0
	move.l	lbL007B98,A0
	move.b	#$20,1(A0,D0.W)
	move.b	#'f',(A4)+
	move.b	#'s',(A4)+
	move.b	#'t',(A4)+
	move.b	#'d',(A4)+
	move.b	#0,1(A4)
	move.l	#lbL009F04,lbL007BD8
	lea	lbL0081DC,A5
	move.l	#$C00,8(A5)
	bsr	ReadFile
	tst.l	D0
	beq	lbC004090
	rts

lbC004090
	move.l	lbL007B98,A0
	move.w	#$2C,D0
lbC00409A
	cmp.b	#$20,0(A0,D0.W)
	bne	lbC0040A8
	dbra	D0,lbC00409A
lbC0040A8
	move.b	#0,1(A0,D0.W)
	move.w	D0,-(SP)
	lea	lbL009F04,A5
	move.l	A5,lbL007BC2
	move.l	_DosBase,A6
	move.l	lbL007B98,D1
	move.l	#$FFFFFFFE,D2
	movem.l	A5,-(SP)
	jsr	_LVOLock(A6)
	movem.l	(SP)+,A5
	move.l	D0,lbL007BBE
	tst.l	D0
	beq	lbC0041B6
	move.l	_DosBase,A6
	move.l	lbL007BBE,D1
	move.l	#DiskInfoBlock,D2
	movem.l	A5,-(SP)
	jsr	_LVOExamine(A6)
	movem.l	(SP)+,A5
	tst.l	D0
	beq	lbC0041B6
lbC00410A
	move.l	_DosBase,A6
	move.l	lbL007BBE,D1
	move.l	#DiskInfoBlock,D2
	movem.l	A5,-(SP)
	jsr	_LVOExNext(A6)
	movem.l	(SP)+,A5
	tst.l	D0
	beq	lbC0041B6
	move.l	#DiskInfoBlock+6,A4
	move.b	(A4)+,(A5)+
	move.b	(A4)+,(A5)+
	cmp.b	#2,-1(A4)
	beq	lbC00418E
	move.l	(A4),d0
	or.l	#$20202020,d0
	cmp.l	#'fstd',d0
	beq	lbC004198
	cmp.l	#'rout',d0
	beq	lbC0041AC
	cmp.l	#'smpl',d0
	beq	lbC004198
	cmp.l	#'info',d0
	beq	lbC004198
	cmp.l	#'mdat',d0
	beq	lbC0041A2
	cmp.l	#'macr',d0
	beq	lbC004188
	cmp.l	#'patt',d0
	bne	lbC00418E
lbC004188
	addq.l	#5,A4
lbC00418E
	move.b	(A4)+,(A5)+
	bne	lbC00418E
	bra	lbC00410A

lbC004198
	sub.l	#2,A5
	bra	lbC00410A

lbC0041A2
	move.b	#3,-1(A5)
	bra	lbC004188

lbC0041AC
	move.b	#4,-1(A5)
	bra	lbC004188

lbC0041B6
	move.l	lbL007B98,A0
	move.w	(SP)+,D0
	move.b	#$20,1(A0,D0.W)
	move.l	A5,A4
	sub.l	#lbL009F04,A4
	move.w	A4,D0
lbC0041CE
	move.b	#$FE,(A5)+
	dbra	D0,lbC0041CE
	move.l	_DosBase,A6
	move.l	lbL007BBE,D1
	jsr	_LVOUnLock(A6)
	move.l	_DosBase,A6
	jsr	_LVOIoErr(A6)
	cmp.w	#ERROR_NO_MORE_ENTRIES,D0
	beq	lbC00424A
	move.b	#$80,(A5)+
	lea	DirectoryErro.MSG,A4
	move.w	#$10,D7
lbC004206
	move.b	(A4)+,(A5)+
	dbra	D7,lbC004206
	move.b	#0,(A5)+
	move.b	#$FE,(A5)+
	rts

	bsr	lbC0019D4
	move.l	lbL007B98,A0
	cmp.b	#$20,4(A0)
	beq	lbC004240
lbC00422A
	add.l	#4,A0
	move.w	#$28,D0
lbC004234
	move.b	#$20,(A0)+
	dbra	D0,lbC004234
	bra	lbC004010

lbC004240
	move.l	#'DF0:',(A0)
	bra	lbC00422A

lbC00424A
	tst.w	FstdFlag
	beq	lbC004268
	lea	lbL0081DC(PC),A4
	sub.l	#lbL009F04,A5
	move.l	A5,8(A4)
	move.l	A4,A5
	bsr	WriteFile
lbC004268
	rts

lbC00426A
	move.b	#6,CharXPos
	move.b	#3,CharYPos
	move.l	lbL007BC2,A0
lbC004280
	move.l	A0,-(SP)
	lea	ascii.MSG14,A0
	bsr	DrawString
	move.b	#6,CharXPos
	move.l	(SP)+,A0
	clr.w	D0
	move.b	(A0)+,D0
	cmp.b	#4,(A0)+
	beq	lbC004308
	cmp.b	#3,-1(A0)
	beq	lbC0042F6
	cmp.b	#2,-1(A0)
	bne	lbC0042C4
	move.l	A0,-(SP)
	lea	DIR.MSG,A0
	bsr	DrawString
	move.l	(SP)+,A0
lbC0042C4
	move.b	#12,CharXPos
	cmp.b	#$FE,(A0)
	beq	lbC0042F4
	bsr	DrawString
	move.b	#6,CharXPos
	add.b	#1,CharYPos
	cmp.b	#12,CharYPos
	bne	lbC004280
lbC0042F4
	rts

lbC0042F6
	move.l	A0,-(SP)
	lea	SONG.MSG,A0
	bsr	DrawString
	move.l	(SP)+,A0
	bra	lbC0042C4

lbC004308
	move.l	A0,-(SP)
	lea	PLR.MSG,A0
	bsr	DrawString
	move.l	(SP)+,A0
	bra	lbC0042C4

DIR.MSG
	dc.b	'(DIR)',0
SONG.MSG
	dc.b	'SONG]',0
PLR.MSG
	dc.b	' PLR.',0
ascii.MSG14
	dc.b	'                                     ',0

lbC004352
	bsr	lbC00426A
	cmp.b	#$FE,(A0)
	beq	lbC0042F4
	move.l	lbL007BC2,A0
	add.l	#2,A0
lbC00436A
	cmp.b	#0,(A0)+
	bne	lbC00436A
	move.l	A0,lbL007BC2
	bsr	lbC00426A
	rts

lbC00437E
	cmp.l	#lbL009F04,lbL007BC2
	bcs	lbC0042F4
	beq	lbC0042F4
	move.l	lbL007BC2,A0
	sub.l	#1,A0
lbC00439C
	cmp.b	#0,-(A0)
	bne	lbC00439C
	cmp.b	#2,1(A0)
	beq	lbC0043B4
	add.l	#1,A0
lbC0043B4
	move.l	A0,lbL007BC2
	bsr	lbC00426A
	rts

DrawActivePage
	bsr	lbC005D46
	cmp.w	ActivePageNr,D7
	beq	lbC0044E6
	move.w	ActivePageNr,D1
	bmi	lbC004444
	tst.w	ActivePageNr
	bne	lbC0043E6
	bsr	lbC002014
lbC0043E6
	cmp.w	#2,ActivePageNr
	bne	lbC0043F6
	bsr	lbC00207C
lbC0043F6
	cmp.w	#7,ActivePageNr
	bne	lbC004406
	bsr	lbC002014
lbC004406
	lea	lbB00808D,A0
	move.b	lbB007CA4,0(A0,D1.W)
	move.b	lbB007CA5,8(A0,D1.W)
	move.b	lbB007D92,$10(A0,D1.W)
	asl.w	#2,D1
	lea	lbL0044EC(PC),A0
	move.l	$20(A0,D1.W),D2
	move.l	0(A0,D1.W),D1
	move.l	#$2A,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
lbC004444
	move.w	D7,ActivePageNr
	asl.w	#2,D7
	lea	lbL0044EC(PC),A0
	move.l	0(A0,D7.W),D1
	move.l	$20(A0,D7.W),D2
	move.l	#$29,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	bsr	Vsync
lbC00446E
	bsr	lbC005C32
	bsr	lbC005D46
	move.w	D7,D6
	lsr.w	#2,D6
	lea	lbB00808D,A0
	move.b	0(A0,D6.W),lbB007CA4
	move.b	8(A0,D6.W),lbB007CA5
	move.b	$10(A0,D6.W),lbB007D92
	lea	lbL0044EC(PC),A0
	move.l	$40(A0,D7.W),A6
	move.l	$60(A0,D7.W),lbL007C50
	add.w	#$80,A0
	move.l	0(A0,D7.W),lbL007C4C
	move.l	$20(A0,D7.W),KeyCutHook
	move.l	$40(A0,D7.W),KeyPasHook
	move.l	$60(A0,D7.W),KeyClrHook
	add.w	#$80,A0
	move.l	0(A0,D7.W),lbL007C54
	move.l	$20(A0,D7.W),lbL007C58
	jmp	(A6)

lbC0044E6
	rts

lbC0044E8
	bra	lbC00060A

lbL0044EC
;x
	dcb.l	$4,$31
	dcb.l	$4,$46
;y
	dc.l	$11
	dc.l	$13
	dc.l	$15
	dc.l	$17
	dc.l	$11
	dc.l	$13
	dc.l	$15
	dc.l	$17
;setup
	dc.l	SetupPattPage
	dc.l	SetupTrackPage
	dc.l	SetupMacroPage
	dc.l	SetupIntroPage
	dc.l	SetupRecordPage
	dc.l	SetupSmpLstPage
	dc.l	SetupSamplerPage
	dc.l	SetupEasyPage
;ins
	dc.l	PattDrawInsertPattLine
	dc.l	lbC004F1A
	dc.l	MacrDrawInsertMacroLine
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
;del
	dc.l	PattDrawDeletePattLine
	dc.l	lbC004F62
	dc.l	MacrDrawDeleteMacroLine
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
;cut
	dc.l	lbC005256
	dc.l	lbC004FCC
	dc.l	lbC005108
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
;pas
	dc.l	lbC005328
	dc.l	lbC0050AC
	dc.l	lbC0051DA
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
;clr
	dc.l	lbC006652
	dc.l	AskClearTracks
	dc.l	lbC0066AE
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404

	dc.l	PattSetPattUp
	dc.l	SetSongUp
	dc.l	lbC005BD8
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404

	dc.l	PattSetPattDown
	dc.l	SetSongDn
	dc.l	lbC005C22
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404
	dc.l	lbC002404

SetupPattPage
	move.l	#lbB007CCB,lbL007B6C
	move.b	#7,ScrapVar
	move.w	#1,lbW007B72
	move.l	#lbC005AAC,KeyHexHook
	move.l	#lbC0015FC,KeyDownArrowHook
	move.l	#lbC001656,KeyUpArrowHook
	lea	PattGadgetList(PC),A0
	move.l	A0,CurrentPageGList
	bsr	DrawGadgetList
	move.w	CurrentPattNum,D0
	move.b	#12,CharXPos
	move.b	#4,CharYPos
	bsr	Draw2HexDigits
	bsr	DrawPatternLines
	bsr	PattPrintLength
	move.w	PatternStepNumber,-(SP)
	bsr	lbC002B92
	move.w	(SP)+,PatternStepNumber
	move.l	#lbC000660,KeyGenericHook
	move.w	#1,lbW007B72
	bsr	lbC001C7E
	rts

SetupTrackPage
	bsr	Vsync
	lea	TrackGadgetList(PC),A0
	move.l	A0,CurrentPageGList
	bsr	DrawGadgetList
	move.l	#15,D2
	move.w	lbW007C0E,D3
	clr.l	D1
	tst.w	D3
	beq	lbC004704
	lea	lbB008084,A1
	move.b	0(A1,D3.W),D1
	move.l	#15,D2
	move.l	#$25,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
lbC004704
	move.l	#$36,D1
	move.w	#7,D6
	move.l	MdatBuffer,A0
	add.l	#$1C0,A0
lbC00471A
	move.w	D6,D7
	asl.w	#1,D7
	tst.w	0(A0,D7.W)
	beq	lbC004746
	move.l	#2,D2
	movem.l	D0-D7/A0/A1,-(SP)
	move.l	#$27,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	movem.l	(SP)+,D0-D7/A0/A1
lbC004746
	sub.l	#7,D1
	dbra	D6,lbC00471A
	bsr	DrawTracks
	move.w	#1,lbW007B72
	move.l	#lbB007CAB,lbL007B6C
	move.b	#$1F,ScrapVar
	move.l	#lbC000B10,KeyDownArrowHook
	move.l	#lbC000B4C,KeyUpArrowHook
	move.l	#lbC00071C,KeyHexHook
	move.l	#lbC000660,KeyGenericHook
	rts

SetupMacroPage
	move.w	#1,lbW007B72
	lea	MacroGadgetList(PC),A0
	move.l	A0,CurrentPageGList
	bsr	DrawGadgetList
	move.l	#lbB007CD3,lbL007B6C
	move.b	#7,ScrapVar
	move.l	#lbC00168A,KeyDownArrowHook
	move.l	#lbC0016E4,KeyUpArrowHook
	move.l	#lbC0059E0,KeyHexHook
	bsr	DrawMacroLines
	move.w	CurrentMacroNum,D0
	move.b	#12,CharXPos
	move.b	#4,CharYPos
	bsr	Draw2HexDigits
	move.l	#lbC000660,KeyGenericHook
	bsr	DisplayMacroNote
	bsr	DisplayMacroVolume
	bsr	DisplayMacroChan
	bsr	lbC001CCA
	rts

SetupIntroPage
	move.w	#1,lbW007B72
	lea	IntroGadgetList(PC),A0
	move.l	A0,CurrentPageGList
	bsr	DrawGadgetList
	move.l	#lbC005530,KeyGenericHook
	move.l	#lbC0054F8,KeyUpArrowHook
	move.l	#lbC005514,KeyDownArrowHook
	bsr	lbC0054B4
	move.l	#lbB007D32,lbL007B6C
	move.b	#$27,ScrapVar
	rts

SetupSamplerPage
	moveq	#$3D,D1
	moveq	#13,D2
	moveq	#$2A,D0
	bsr	Vsync
	bsr	ClearButton
	bsr	lbC001A74
	move.l	4,A6
	move.l	#$4E20,D0
	clr.l	D1
	jsr	_LVOAllocMem(A6)
	move.l	D0,SampleRoutBuffer
	beq	lbC0048EA
	lea	lbL008200,A5
	bsr	ReadFile
	tst.l	D0
	beq	lbC0048EA
	move.l	SampleRoutBuffer,A0
	lea	lbL007AC2,A4
	jsr	$20(A0)
	clr.l	lbL007C6A
	move.l	RoutBuffer,A0
	move.l	MdatBuffer,D0
	move.l	SmplBuffer,D1
	move.l	#ChipBuffer,d2
	move.w	PlayRate7V,d3
	jsr	$34(A0)
	move.l	RoutBuffer,A0
	jsr	$38(A0)
	move.l	RoutBuffer,A0
	jsr	$4C(A0)
	move.l	$10(A0),A1
	move.l	#lbC0012B2,2(A1)
	move.l	12(A0),A1
	move.l	A1,PlyrPatternBlock
	move.l	4(A0),A2
	move.l	A2,PlyrMasterBlock
	move.l	A0,PlyrInfoBlock
lbC0048EA
	move.l	4,A6
	move.l	SampleRoutBuffer,A1
	move.l	a1,d0
	bne.s	.nofree
	move.l	#$4E20,D0
	jsr	_LVOFreeMem(A6)
	clr.l	SampleRoutBuffer
.nofree
	lea	MainGadgetList(PC),A0
	move.l	A0,CurrentGadgetList
	bsr	DrawGadgetList
	bsr	DrawSongInfo
	moveq	#1,D7
	bra	DrawActivePage

	rts

SetupEasyPage
	lea	EasyGadgetList(PC),A0
	move.l	A0,CurrentPageGList
	bsr	DrawGadgetList
lbC00492E
	move.w	#1,lbW007B72
	move.w	CurrentPattNum,D0
	move.b	#12,CharXPos
	move.b	#4,CharYPos
	bsr	Draw2HexDigits
	move.b	#$27,ScrapVar
	cmp.w	#6,lbW007C76
	bne	lbC00496C
	move.b	#$1D,ScrapVar
lbC00496C
	move.l	#lbB007D5A,lbL007B6C
	move.l	#lbC00611E,KeyDownArrowHook
	move.l	#lbC0060E4,KeyUpArrowHook
	move.l	#EasyKeyboard,KeyGenericHook
lbC004994
	bsr	lbC0062CA
	bne	lbC0049AA
	bsr	lbC006196
	bsr	lbC001C7E
	bsr	EasyDisplayVolChn
	rts

lbC0049AA
	clr.w	lbW007B72
	bsr	lbC005DD6
	bsr	lbC001C7E
	move.l	#lbC0044E8,KeyGenericHook
	rts

SetupRecordPage
	move.w	#0,lbW007B72
	lea	RecordGadgetList(PC),A0
	move.l	A0,CurrentPageGList
	bsr	DrawGadgetList
	move.l	#lbC002404,KeyDownArrowHook
	move.l	#lbC002404,KeyUpArrowHook
	move.l	#lbC0049FE,KeyGenericHook
	bsr	lbC00358C
	rts

lbC0049FE
	cmp.b	#$6C,KeyASCIIKeyCode		l
	beq	KeyGotoSmpLstPage
	bra	lbC004A7C

SetupSmpLstPage
	move.w	#1,lbW007B72
	lea	SmpLstGadgetList(PC),A0
	move.l	A0,CurrentPageGList
	bsr	DrawGadgetList
	clr.b	lbB007D92
	move.b	#0,ScrapVar
	move.l	#lbC001586,KeyDownArrowHook
	move.l	#lbC0015C4,KeyUpArrowHook
	move.l	#lbC004A70,KeyGenericHook
	bsr	lbC005850
	move.w	lbW007C28,D0
	move.b	#15,CharYPos
	move.b	#$29,CharXPos
	bsr	Draw1HexDigit
	rts

lbC004A70
	cmp.b	#$72,KeyASCIIKeyCode		r
	beq	KeyGotoRecordPage
lbC004A7C
	cmp.b	#$5B,KeyASCIIKeyCode		\
	beq	KeyToggleMetFlag
	cmp.b	#$70,KeyASCIIKeyCode		p
	beq	KeyGotoPattPage
	cmp.b	#$74,KeyASCIIKeyCode		t
	beq	KeyGotoTrackPage
	cmp.b	#$6D,KeyASCIIKeyCode		m
	beq	KeyGotoMacroPage
	cmp.b	#9,KeyASCIIKeyCode		tab
	beq	KeyPlayStop
	cmp.b	#$20,KeyASCIIKeyCode		sp
	beq	KeyPlayCont
	bra	lbC00060A

DisplayMemoryAlert
	lea	OutOfMemoryAlert,A0
	bsr	DisplayAlert25
	move.l	#$81000009,D0
	rts

PattDrawInsertPattLine
	st	D5
PattInsertPattLine
	move.w	lbW007BDC,lbW007C04
	move.l	MdatBuffer,A0
	add.l	#$C800,A0
	cmp.l	MdatBufEndPtr,A0
	bcs.s	DisplayMemoryAlert
	bsr	lbC001A74
	bsr	GetPatternAddr
	moveq	#0,d0
	move.b	lbB007CA5,D0
	subq.l	#7,D0
	add.l	lbW007B78,D0
	asl.l	#2,D0
	add.l	D0,A0
	move.l	MdatBufEndPtr,A1
	move.l	A1,A2
	subq.l	#4,A2
.lp
	move.l	-(A2),-(A1)
	cmp.l	A2,A0
	bne.s	.lp
	addq.l	#4,MdatBufEndPtr
	moveq.l	#4,D7
	bsr	RelocatePatternPtrs
	moveq.l	#1,D6
	bsr	PattRelocateCont
	bsr	lbC005D46
	tst.b	D5
	beq.s	.nodraw
	bsr	DrawPatternLines
	bsr	PattPrintLength
.nodraw
	clr.l	D0
	bsr	lbC0055F6
	rts

RelocatePatternPtrs
	move.l	MdatBuffer,A0
	moveq	#0,d0
	move.w	CurrentPattNum,D0
	cmp.w	#$7F,D0
	beq.s	.mac
	move.w	D0,D1
	asl.w	#2,D0
	add.w	#$404,D0
	add.w	d0,a0
.patlp
	add.l	D7,(a0)+
	addq.w	#1,D1
	cmp.w	#$7F,D1
	bne.s	.patlp
.mac
	move.l	MdatBuffer,A0
	add.l	#$600,A0
	moveq	#$7F,D1
.maclp
	add.l	D7,(A0)+
	dbra	D1,.maclp
	rts

PattDrawDeletePattLine
	st	D5
PattDeletePattLine
	move.w	lbW007BDC,lbW007C04
	bsr	lbC005D46
	bsr	lbC001A74
	bsr	GetPatternAddr
	moveq	#0,d0
	move.b	lbB007CA5,D0
	subq.l	#7,D0
	add.l	lbW007B78,D0
	move.l	D0,D7
	asl.l	#2,D0
	add.l	D0,A0
	move.b	4(A0),D0
	cmp.b	#$F0,D0
	bne.s	.nobump
	tst.l	D7
	beq.s	.triv
	subq.b	#1,lbB007CA5
	cmp.b	#6,lbB007CA5
	bne.s	.nobump
	move.b	#7,lbB007CA5
	subq.l	#1,lbW007B78
.nobump
	move.l	MdatBufEndPtr,A2
	move.l	A0,A1
	addq.l	#4,A1
.lp
	move.l	(A1)+,(A0)+
	cmp.l	A2,A0
	bne.s	.lp
	subq.l	#4,MdatBufEndPtr
	moveq.l	#-4,D7
	bsr	RelocatePatternPtrs
	moveq.l	#-1,D6
	bsr.s	PattRelocateCont
	tst.b	D5
	beq.s	.nodraw
	bsr	DrawPatternLines
	bsr	PattPrintLength
.nodraw
	bsr	lbC0055F6
	rts
.triv
	move.l	#$F4000000,(A0)
	tst.b	D5
	beq.s	.nodraw
	bsr	DrawPatternLines
	bsr	PattPrintLength
	bsr	lbC0055F6
	rts

PattRelocateCont
	bsr	GetPatternAddr
	moveq	#0,d0
	move.b	lbB007CA5,D0
	subq.l	#7,D0
	add.l	lbW007B78,D0
	move.l	D0,D7
	asl.l	#2,D0
	add.l	D0,A0
.lp
	addq.l	#4,A0
	move.b	(A0),D1
	cmp.b	#$F1,D1
	beq.s	.cont
	cmp.b	#$F0,D1
	bne.s	.lp
	rts
.cont
	move.w	2(A0),D1
	cmp.w	D7,D1
	bcs.s	.lp
	add.w	D6,2(a0)
	bra.s	.lp

MacrDrawInsertMacroLine
	st	D5
lbC004D0A
	move.w	lbW007BDC,lbW007C04
	move.l	MdatBuffer,A0
	add.l	#$C800,A0
	cmp.l	MdatBufEndPtr,A0
	bcs	DisplayMemoryAlert
	bsr	lbC001A74
	bsr	GetMacroAddr
	move.b	lbB007CA5,D0
	and.l	#$FF,D0
	sub.l	#7,D0
	add.l	lbW007B8A,D0
	asl.l	#2,D0
	add.l	D0,A0
	move.l	MdatBufEndPtr,A1
	move.l	A1,A2
	sub.l	#4,A2
lbC004D5C
	move.l	-(A2),-(A1)
	cmp.l	A2,A0
	bne	lbC004D5C
	addq.l	#4,MdatBufEndPtr
	moveq.l	#4,D7
	bsr	lbC004D98
	moveq.l	#1,D6
	bsr	lbC004EB0
	bsr	lbC005D46
	tst.b	D5
	beq	lbC004D90
	bsr	DrawMacroLines
lbC004D90
	clr.l	D0
	bsr	lbC0055F6
	rts

lbC004D98
	move.l	MdatBuffer,A0
	move.w	CurrentMacroNum,D0
	and.l	#$FFFF,D0
	cmp.l	#$7F,D0
	beq	lbC004DDE
	addq.l	#1,D0
	move.l	D0,D1
	asl.l	#2,D0
	add.l	#$600,D0
lbC004DC4
	add.l	D7,0(A0,D0.L)
	addq.l	#4,D0
	addq.l	#1,D1
	cmp.l	#$80,D1
	bne	lbC004DC4
lbC004DDE
	rts

MacrDrawDeleteMacroLine
	st	D5
lbC004DE2
	move.w	lbW007BDC,lbW007C04
	bsr	lbC005D46
	bsr	lbC001A74
	bsr	GetMacroAddr
	move.b	lbB007CA5,D0
	and.l	#$FF,D0
	sub.l	#7,D0
	add.l	lbW007B8A,D0
	move.l	D0,D7
	asl.l	#2,D0
	add.l	D0,A0
	move.l	4(A0),D0
	and.l	#$FF000000,D0
	cmp.l	#$7000000,D0
	bne	lbC004E56
	tst.l	D7
	beq	lbC004E9A
	sub.b	#1,lbB007CA5
	cmp.b	#6,lbB007CA5
	bne	lbC004E56
	move.b	#7,lbB007CA5
	sub.l	#1,lbW007B8A
lbC004E56
	move.l	MdatBufEndPtr,A2
	move.l	A0,A1
	add.l	#4,A1
lbC004E64
	move.l	(A1)+,(A0)+
	cmp.l	A2,A0
	bne	lbC004E64
	sub.l	#4,MdatBufEndPtr
	move.l	#$FFFFFFFC,D7
	bsr	lbC004D98
	move.l	#$FFFFFFFF,D6
	bsr	lbC004EB0
	tst.b	D5
	beq	lbC004E94
	bsr	DrawMacroLines
lbC004E94
	bsr	lbC0055F6
	rts

lbC004E9A
	move.l	#$4000000,(A0)
	tst.b	D5
	beq	lbC004E94
	bsr	DrawMacroLines
	bsr	lbC0055F6
	rts

lbC004EB0
	bsr	GetMacroAddr
	move.b	lbB007CA5,D0
	and.l	#$FF,D0
	sub.l	#7,D0
	add.l	lbW007B8A,D0
	move.l	D0,D7
	asl.l	#2,D0
	add.l	D0,A0
lbC004ED2
	add.l	#4,A0
	move.l	(A0),D1
	and.l	#$FF000000,D1
	cmp.l	#$5000000,D1
	beq	lbC004EFA
	cmp.l	#$7000000,D1
	beq	lbC004EF8
	bra	lbC004ED2

lbC004EF8
	rts

lbC004EFA
	move.l	(A0),D1
	and.l	#$FF,D1
	cmp.l	D7,D1
	bcs	lbC004ED2
	add.l	D6,D1
	move.l	(A0),D2
	and.l	#$FFFFFF00,D2
	or.l	D1,D2
	move.l	D2,(A0)
	bra	lbC004ED2

lbC004F1A
	clr.l	D0
	move.b	lbB007CA5,D0
	sub.l	#7,D0
	add.l	lbL007B62,D0
	asl.l	#4,D0
	add.l	#$800,D0
	add.l	MdatBuffer,D0
	move.l	#$27F0,A0
	move.l	#$2800,A1
	add.l	MdatBuffer,A0
	add.l	MdatBuffer,A1
lbC004F54
	move.l	-(A0),-(A1)
	cmp.l	A0,D0
	bne	lbC004F54
	bsr	DrawTracks
	rts

lbC004F62
	clr.l	D0
	move.b	lbB007CA5,D0
	sub.l	#7,D0
	add.l	lbL007B62,D0
	asl.l	#4,D0
	add.l	#$800,D0
	add.l	MdatBuffer,D0
	move.l	D0,A0
	move.l	D0,A1
	move.l	#$2800,D0
	add.l	MdatBuffer,D0
	add.l	#$10,A1
lbC004F9A
	move.l	(A1)+,(A0)+
	cmp.l	D0,A0
	bne	lbC004F9A
	move.l	MdatBuffer,A0
	add.l	#$27F0,A0
	move.l	#$FF00FF00,(A0)+
	move.l	#$FF00FF00,(A0)+
	move.l	#$FF00FF00,(A0)+
	move.l	#$FF00FF00,(A0)+
	bsr	DrawTracks
	rts

lbC004FCC
	clr.l	D0
	move.b	lbB007CA5,D0
	sub.l	#7,D0
	add.l	lbL007B62,D0
	eor.w	#1,lbW007BA0
	beq	lbC00502A
	move.l	D0,lbL007BA6
	move.l	#$35,D1
	move.l	#0,D2
	bsr	ClearButton
	move.l	#$4D,D0
	move.l	#$35,D1
	move.l	#0,D2
	bsr	RenderStuff
	move.l	#lbC00060E,KeyGenericHook
	st	lbW007C1E
	rts

lbC00502A
	move.l	#lbC000660,KeyGenericHook
	clr.b	lbW007C1E
	sub.l	lbL007BA6,D0
	move.l	D0,lbL007BA2
	move.l	#$35,D1
	move.l	#0,D2
	bsr	ClearButton
	move.l	#10,D0
	move.l	#$35,D1
	move.l	#0,D2
	bsr	RenderStuff
	cmp.l	#$80,lbL007BA2
	bcc	lbC0050A8
	lea	lbL009F04(PC),A1
	move.l	lbL007BA6,D0
	asl.l	#4,D0
	add.l	#$800,D0
	add.l	MdatBuffer,D0
	move.l	D0,A0
	move.l	lbL007BA2,D0
lbC00509A
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	dbra	D0,lbC00509A
	rts

lbC0050A8
	bra	lbC0019D4

lbC0050AC
	move.l	lbL007BA2,D6
	cmp.l	#$80,D6
	bcc	lbC0050A8
lbC0050BC
	move.l	D6,-(SP)
	bsr	lbC004F1A
	move.l	(SP)+,D6
	dbra	D6,lbC0050BC
	lea	lbL009F04(PC),A1
	clr.l	D0
	move.b	lbB007CA5,D0
	sub.l	#7,D0
	add.l	lbL007B62,D0
	asl.l	#4,D0
	add.l	#$800,D0
	add.l	MdatBuffer,D0
	move.l	D0,A0
	move.l	lbL007BA2,D0
lbC0050F6
	move.l	(A1)+,(A0)+
	move.l	(A1)+,(A0)+
	move.l	(A1)+,(A0)+
	move.l	(A1)+,(A0)+
	dbra	D0,lbC0050F6
	bsr	DrawTracks
	rts

lbC005108
	clr.l	D0
	move.b	lbB007CA5,D0
	sub.l	#7,D0
	add.l	lbW007B8A,D0
	eor.w	#1,lbW007BAA
	beq	lbC005166
	move.l	D0,lbL007BB0
	move.l	#$35,D1
	move.l	#0,D2
	bsr	ClearButton
	move.l	#$4D,D0
	move.l	#$35,D1
	move.l	#0,D2
	bsr	RenderStuff
	move.l	#lbC00060E,KeyGenericHook
	st	lbW007C1E
	rts

lbC005166
	move.l	#lbC000660,KeyGenericHook
	clr.b	lbW007C1E
	sub.l	lbL007BB0,D0
	move.l	D0,lbL007BAC
	move.l	#$35,D1
	move.l	#0,D2
	bsr	ClearButton
	move.l	#10,D0
	move.l	#$35,D1
	move.l	#0,D2
	bsr	RenderStuff
	cmp.l	#$40,lbL007BAC
	bcc	lbC0051D6
	bsr	GetMacroAddr
	move.l	lbL007BB0,D0
	asl.l	#2,D0
	add.l	D0,A0
	lea	lbL00A704(PC),A1
	move.l	lbL007BAC,D0
lbC0051CE
	move.l	(A0)+,(A1)+
	dbra	D0,lbC0051CE
	rts

lbC0051D6
	bra	lbC0019D4

lbC0051DA
	st	D5
	move.l	lbL007BAC,D6
	cmp.l	#$40,D6
	bcc	lbC0051D6
	move.w	lbW007BDC,-(SP)
	clr.w	lbW007BDC
lbC0051F8
	move.l	D6,-(SP)
	move.b	D5,-(SP)
	clr.b	D5
	bsr	lbC004D0A
	move.b	(SP)+,D5
	move.l	(SP)+,D6
	tst.l	D0
	bne	lbC005240
	dbra	D6,lbC0051F8
	bsr	GetMacroAddr
	move.b	lbB007CA5,D0
	and.l	#$FF,D0
	sub.l	#7,D0
	add.l	lbW007B8A,D0
	asl.l	#2,D0
	add.l	D0,A0
	move.l	lbL007BAC,D0
	lea	lbL00A704(PC),A1
lbC00523A
	move.l	(A1)+,(A0)+
	dbra	D0,lbC00523A
lbC005240
	tst.b	D5
	beq	lbC00524A
	bsr	DrawMacroLines
lbC00524A
	move.w	(SP)+,lbW007C04
	bsr	lbC0055F6
	rts

lbC005256
	clr.l	D0
	move.b	lbB007CA5,D0
	sub.l	#7,D0
	add.l	lbW007B78,D0
	eor.w	#1,lbW007BB4
	beq	lbC0052B4
	move.l	D0,lbL007BBA
	move.l	#$35,D1
	move.l	#0,D2
	bsr	ClearButton
	move.l	#$4D,D0
	move.l	#$35,D1
	move.l	#0,D2
	bsr	RenderStuff
	move.l	#lbC00060E,KeyGenericHook
	st	lbW007C1E
	rts

lbC0052B4
	move.l	#lbC000660,KeyGenericHook
	clr.b	lbW007C1E
	sub.l	lbL007BBA,D0
	move.l	D0,lbL007BB6
	move.l	#$35,D1
	move.l	#0,D2
	bsr	ClearButton
	move.l	#10,D0
	move.l	#$35,D1
	move.l	#0,D2
	bsr	RenderStuff
	cmp.l	#$100,lbL007BB6
	bcc	lbC005324
	bsr	GetPatternAddr
	move.l	lbL007BBA,D0
	asl.l	#2,D0
	add.l	D0,A0
	lea	PattTmpBuffer(PC),A1
	move.l	lbL007BB6,D0
lbC00531C
	move.l	(A0)+,(A1)+
	dbra	D0,lbC00531C
	rts

lbC005324
	bra	lbC0019D4

lbC005328
	st	D5
lbC00532A
	move.l	lbL007BB6,D6
	cmp.l	#$100,D6
	bcc	lbC005324
	move.w	lbW007BDC,-(SP)
	clr.w	lbW007BDC
lbC005346
	move.l	D6,-(SP)
	move.b	D5,-(SP)
	clr.b	D5
	bsr	PattInsertPattLine
	move.b	(SP)+,D5
	move.l	(SP)+,D6
	tst.l	D0
	bne	lbC00538E
	dbra	D6,lbC005346
	bsr	GetPatternAddr
	move.b	lbB007CA5,D0
	and.l	#$FF,D0
	sub.l	#7,D0
	add.l	lbW007B78,D0
	asl.l	#2,D0
	add.l	D0,A0
	move.l	lbL007BB6,D0
	lea	PattTmpBuffer(PC),A1
lbC005388
	move.l	(A1)+,(A0)+
	dbra	D0,lbC005388
lbC00538E
	tst.b	D5
	beq	lbC00539C
	bsr	DrawPatternLines
	bsr	PattPrintLength
lbC00539C
	move.w	(SP)+,lbW007C04
	bsr	lbC0055F6
	rts

	move.l	D0,A1
	move.l	SmplBuffer,A0
	move.l	#lbB007D82,A2
	move.b	(A0)+,(A1)+
	move.b	-1(A0),D5
lbC0053BC
	move.b	D5,D0
	move.b	(A0)+,D1
	move.b	(A0)+,D1
	sub.b	D0,D1
	bsr	lbC005418
	add.b	0(A2,D2.W),D5
	move.b	D2,D3
	asl.b	#4,D3
	move.b	D5,D0
	move.b	(A0)+,D1
	move.b	(A0)+,D1
	sub.b	D0,D1
	bsr	lbC005418
	add.b	0(A2,D2.W),D5
	or.b	D2,D3
	move.b	D3,(A1)+
	or.b	D0,(A1)+
	cmp.l	SmplBufEndPtr,A0
	blt	lbC0053BC
	lea	lbL0081DC,A5
	move.l	SmplBufEndPtr,D0
	sub.l	SmplBuffer,D0
	lsr.l	#1,D0
	move.l	D0,8(A5)
	move.l	SmplBuffer,lbL007BD8
	bsr	WriteFile
	rts

lbC005418
	move.w	#5,D2
lbC00541C
	cmp.b	0(A2,D2.W),D1
	beq	lbC00542A
	dbra	D2,lbC00541C
	clr.w	D2
lbC00542A
	rts

	cmp.w	#15,D2
	beq	lbC00542A
	move.b	0(A2,D2.W),D7
	move.b	-1(A2,D2.W),D6
	sub.b	D1,D7
	sub.b	D1,D6
	cmp.b	D7,D6
	bge	lbC00542A
	add.w	#1,D2
	rts

	lea	lbL0081F4,A5
	move.l	SmplBuffer,D0
	add.l	#$20594,D0
	move.l	D0,lbL007BD8
	bsr	ReadFile
	move.l	D0,A3
	add.l	lbL007BD8,A3
	move.l	lbL007BD8,A0
	move.l	SmplBuffer,A1
	lea	lbB007D82,A2
	clr.l	D2
	clr.l	D3
	move.b	(A0)+,D0
	move.b	D0,(A1)+
lbC00548A
	move.b	(A0)+,D3
	move.w	D3,$DFF182
	move.b	D3,D2
	lsr.b	#4,D2
	add.b	0(A2,D2.W),D0
	move.b	D0,(A1)+
	and.b	#15,D3
	add.b	0(A2,D3.W),D0
	move.b	D0,(A1)+
	cmp.l	A0,A3
	bne	lbC00548A
	move.l	A1,SmplBufEndPtr
	rts

lbC0054B4
	move.l	MdatBuffer,A0
	add.l	#$10,A0
	move.w	#5,D6
	move.b	#7,CharYPos
lbC0054CC
	move.b	#10,CharXPos
	move.w	#$27,D7
lbC0054D8
	move.b	(A0)+,D0
	bsr	DrawChar
	add.b	#1,CharXPos
	dbra	D7,lbC0054D8
	add.b	#1,CharYPos
	dbra	D6,lbC0054CC
	rts

lbC0054F8
	cmp.b	#7,lbB007CA5
	beq	lbC00060A
	bsr	lbC005D46
	sub.b	#1,lbB007CA5
	bra	lbC00060A

lbC005514
	cmp.b	#12,lbB007CA5
	beq	lbC00060A
	bsr	lbC005D46
	add.b	#1,lbB007CA5
	bra	lbC00060A

lbC005530
	move.b	KeyASCIIKeyCode,D0
	cmp.b	#$20,D0
	blt	lbC00060A
	cmp.b	#$7E,D0
	bge	lbC00060A
	move.l	MdatBuffer,A0
	clr.w	D2
	move.b	lbB007CA5,D2
	sub.w	#7,D2
	asl.w	#3,D2
	move.w	D2,D1
	asl.w	#2,D2
	add.w	D2,D1
	add.b	lbB007CA4,D1
	sub.b	#10,D1
	move.b	D0,$10(A0,D1.W)
	bsr	lbC0054B4
	cmp.b	#$31,lbB007CA4
	beq	lbC00060A
	bsr	lbC005D46
	add.b	#1,lbB007D92
	add.b	#1,lbB007CA4
	bra	lbC00060A

lbC005596
	st	lbB007C15
	lea	lbL00973E,A5
	move.w	#$8129,4(A5)
	rts

lbC0055AA
	tst.w	lbB007C14
	beq	lbC0055CA
	clr.w	lbB007C14
	move.w	#$812A,4(A0)
	move.l	#$2A,D0
	bra	lbC0055DC

lbC0055CA
	move.w	#$8129,4(A0)
	move.l	#$29,D0
	st	lbB007C15
lbC0055DC
	move.l	#$33,D1
	move.l	#4,D2
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	rts

lbC0055F6
	move.l	D0,-(SP)
	tst.w	lbW007C04
	beq	lbC005606
	bsr	lbC001ABC
lbC005606
	move.l	(SP)+,D0
	rts

lbC00560A
	bsr	lbC005D46
	move.l	InfoBuffer,A0
	clr.l	D0
	move.b	lbB007CA5,D0
	sub.w	#4,D0
	add.w	lbW007B7C,D0
	asl.w	#2,D0
	add.l	#$1400,A0
	tst.l	0(A0,D0.W)
	beq	lbC005724
	clr.l	D1
	clr.l	D6
	move.l	0(A0,D0.W),A1
	add.l	SmplBuffer,A1
	move.l	4(A0,D0.W),A2
	move.l	A2,D5
	add.l	SmplBuffer,A2
	move.l	A2,D6
	sub.l	A1,D6
	cmp.l	SmplBuffer,A2
	bne	lbC00566A
	move.l	SmplBufEndPtr,D6
	sub.l	A1,D6
	bra	lbC005678

lbC00566A
	move.l	D6,D1
lbC00566C
	move.b	(A2)+,(A1)+
	cmp.l	SmplBufEndPtr,A2
	bne	lbC00566C
lbC005678
	clr.b	(A1)+
	cmp.l	SmplBufEndPtr,A1
	bne	lbC005678
	add.l	D0,A0
	move.l	$1000(A0),A1
	move.l	$1004(A0),A2
	move.l	A2,D2
	sub.l	A1,D2
lbC005692
	move.l	4(A0),(A0)
	move.l	$404(A0),$400(A0)
	move.l	$804(A0),$800(A0)
	move.l	$C04(A0),$C00(A0)
	move.l	$1004(A0),$1000(A0)
	tst.l	(A0)
	beq	lbC0056B6
	sub.l	D1,(A0)
lbC0056B6
	tst.l	$800(A0)
	beq	lbC0056C2
	sub.l	D1,$800(A0)
lbC0056C2
	tst.l	$1000(A0)
	beq	lbC0056CE
	sub.l	D2,$1000(A0)
lbC0056CE
	add.l	#4,A0
	add.w	#1,D0
	cmp.w	#$FF,D0
	bne	lbC005692
	clr.l	(A0)
	clr.l	$400(A0)
	clr.l	$800(A0)
	clr.l	$C00(A0)
	clr.l	$1000(A0)
	add.l	InfoBuffer,A1
	add.l	InfoBuffer,A2
	move.l	InfoBuffer,A3
	add.l	#$3A98,A3
lbC00570A
	move.b	(A2)+,(A1)+
	cmp.l	A2,A3
	bne	lbC00570A
	clr.b	-1(A3)
	sub.l	D6,SmplBufEndPtr
	bsr	lbC002FFA
	bsr	lbC005850
lbC005724
	rts

lbC005726
	move.l	#$19000000,D3
	move.l	#1,D4
	clr.w	D0
	move.b	lbB007CA5,D0
	sub.w	#4,D0
	add.w	lbW007B7C,D0
	asl.w	#2,D0
	move.l	InfoBuffer,A1
	add.l	#$1400,A1
	move.l	0(A1,D0.W),D1
	add.l	#$400,A1
	move.l	0(A1,D0.W),D2
	move.l	D2,D7
	lsr.l	#1,D2
	tst.w	lbW007C28
	beq	lbC0057DA
	move.w	lbW007C28,D5
	sub.w	#1,D5
	add.l	#$400,A1
	move.l	A1,A2
	add.l	#$400,A2
	tst.l	0(A1,D0.W)
	beq	lbC0057DA
	move.l	0(A1,D0.W),D3
	move.l	0(A2,D0.W),D4
	sub.l	D1,D3
	move.l	D4,D2
	asl.l	#1,D2
	add.l	D3,D2
	lsr.l	#1,D2
lbC0057A0
	tst.w	D5
	beq	lbC0057BC
	move.l	D2,D6
	asl.l	#1,D6
	add.l	D6,D1
	asl.l	#1,D3
	asl.l	#1,D4
	asl.l	#1,D2
	cmp.l	D3,D7
	bcs	lbC0057C4
	dbra	D5,lbC0057A0
lbC0057BC
	or.l	#$18000000,D3
	rts

lbC0057C4
	move.l	#$19000000,D3
	move.l	#1,D4
	clr.l	D1
	move.l	#1,D2
	rts

lbC0057DA
	rts

lbC0057DC
	move.l	_IntuitionBase,A6
	sub.l	A0,A0
	jsr	_LVODisplayBeep(A6)
	bsr	lbC005726
	lea	lbL00A704,A0
	move.l	#0,(A0)+
	or.l	#$2000000,D1
	move.l	D1,(A0)+
	or.l	#$3000000,D2
	move.l	D2,(A0)+
	move.l	#$D000014,(A0)+
	move.l	#$8000000,(A0)+
	move.l	#$1000000,(A0)+
	move.l	#$4000000,(A0)+
	move.l	D3,(A0)+
	cmp.l	#$19000000,D3
	beq	lbC005844
	move.l	#$14000000,(A0)+
	move.l	#$F040100,(A0)+
	move.l	#9,lbL007BAC
	rts

lbC005844
	move.l	#7,lbL007BAC
	rts

lbC005850
	move.b	#4,CharYPos
	move.w	#9,D7
	move.w	lbW007B7C,D0
lbC005862
	move.b	#7,CharXPos
	move.w	D0,D1
	bsr	Draw4HexDigits
	move.w	D0,D1
	asl.w	#2,D1
	move.l	InfoBuffer,A0
	add.l	#$1400,A0
	move.w	D0,-(SP)
	move.b	#10,CharXPos
	cmp.l	#0,0(A0,D1.W)
	beq	lbC0058C6
	move.l	A0,A1
	add.l	#$1000,A1
	move.l	0(A1,D1.W),A0
	add.l	InfoBuffer,A0
	move.l	A0,-(SP)
	lea	ascii.MSG20,A0
	bsr	DrawString
	move.l	(SP)+,A0
	move.b	#10,CharXPos
	bsr	DrawString
	bra	lbC0058D0

lbC0058C6
	lea	ascii.MSG21,A0
	bsr	DrawString
lbC0058D0
	move.w	(SP)+,D0
	move.w	D0,D1
	asl.w	#2,D1
	move.l	InfoBuffer,A0
	add.l	#$1400,A0
	move.l	0(A0,D1.W),D1
	move.b	#$22,CharXPos
	move.l	D1,-(SP)
	bsr	Draw4HexDigits
	move.l	(SP)+,D1
	swap	D1
	and.l	#$FF,D1
	move.l	D0,-(SP)
	move.l	D1,D0
	bsr	Draw1HexDigit
	move.l	(SP)+,D0
	move.w	D0,D1
	asl.w	#2,D1
	move.l	InfoBuffer,A0
	add.l	#$1800,A0
	move.l	0(A0,D1.W),D1
	lsr.l	#1,D1
	move.b	#$28,CharXPos
	bsr	Draw4HexDigits
	move.w	D0,D1
	asl.w	#2,D1
	move.l	InfoBuffer,A0
	add.l	#$1C00,A0
	move.l	0(A0,D1.W),D1
	move.b	#$2E,CharXPos
	move.l	D1,-(SP)
	bsr	Draw4HexDigits
	move.l	(SP)+,D1
	swap	D1
	and.l	#$FF,D1
	move.l	D0,-(SP)
	move.l	D1,D0
	bsr	Draw1HexDigit
	move.l	(SP)+,D0
	move.w	D0,D1
	asl.w	#2,D1
	move.l	InfoBuffer,A0
	add.l	#$2000,A0
	move.l	0(A0,D1.W),D1
	move.b	#$34,CharXPos
	bsr	Draw4HexDigits
	add.w	#1,D0
	add.b	#1,CharYPos
	dbra	D7,lbC005862
	rts

lbC005992
	cmp.w	#$F3,lbW007B7C
	bcc	lbC0059AC
	add.w	#4,lbW007B7C
	bsr	lbC005850
	rts

lbC0059AC
	move.w	#$F6,lbW007B7C
	bsr	lbC005850
	rts

lbC0059BA
	cmp.w	#4,lbW007B7C
	bcs	lbC0059D4
	sub.w	#4,lbW007B7C
	bsr	lbC005850
	rts

lbC0059D4
	clr.w	lbW007B7C
	bsr	lbC005850
	rts

lbC0059E0
	move.l	D0,D7
	and.l	#15,D7
	bsr	GetMacroAddr
	clr.w	D6
	move.b	lbB007CA5,D6
	sub.w	#7,D6
	add.w	lbW007B8C,D6
	asl.w	#2,D6
	cmp.b	#2,lbB007D92
	bcc	lbC005A5E
	tst.b	lbB007D92
	beq	lbC005A38
	move.l	0(A0,D6.W),D5
	and.l	#$F0000000,D5
	cmp.l	#0,D5
	bne	lbC005A5E
	cmp.l	#7,D7
	beq	lbC00060A
	bra	lbC005A5E

lbC005A38
	move.l	0(A0,D6.W),D5
	and.l	#$F000000,D5
	cmp.l	#$7000000,D5
	bne	lbC005A5E
	cmp.l	#0,D7
	bne	lbC005A5E
	and.l	#$F0FFFFFF,0(A0,D6.W)
lbC005A5E
	clr.w	D1
	move.l	#$FFFFFFF0,D2
	move.b	lbB007D92,D1
	eor.w	#7,D1
	beq	lbC005A80
	sub.w	#1,D1
lbC005A78
	asl.l	#4,D7
	rol.l	#4,D2
	dbra	D1,lbC005A78
lbC005A80
	and.l	D2,0(A0,D6.W)
	or.l	D7,0(A0,D6.W)
	bsr	lbC005D46
	bsr	DrawMacroLines
	cmp.b	#7,lbB007D92
	beq	lbC005AA8
	add.b	#1,lbB007D92
	bra	lbC000934

lbC005AA8
	bra	lbC00060A

lbC005AAC
	move.l	D0,D7
	and.l	#15,D7
	bsr	GetPatternAddr
	clr.w	D6
	move.b	lbB007CA5,D6
	sub.w	#7,D6
	add.w	lbW007B7A,D6
	asl.w	#2,D6
	cmp.b	#2,lbB007D92
	bcc	lbC005B20
	tst.b	lbB007D92
	beq	lbC005B00
	move.l	0(A0,D6.W),D5
	and.l	#$F0000000,D5
	cmp.l	#$F0000000,D5
	bne	lbC005B20
	tst.l	D7
	beq	lbC00060A
	bra	lbC005B20

lbC005B00
	move.l	0(A0,D6.W),D5
	and.l	#$F000000,D5
	bne	lbC005B20
	cmp.l	#15,D7
	bne	lbC005B20
	or.l	#$1000000,0(A0,D6.W)
lbC005B20
	clr.w	D1
	moveq.l	#$FFFFFFF0,D2
	move.b	lbB007D92,D1
	eor.w	#7,D1
	beq	lbC005B42
	sub.w	#1,D1
lbC005B3A
	asl.l	#4,D7
	rol.l	#4,D2
	dbra	D1,lbC005B3A
lbC005B42
	and.l	D2,0(A0,D6.W)
	or.l	D7,0(A0,D6.W)
	bsr	lbC005D46
	bsr	DrawPatternLines
	bsr	PattPrintLength
	cmp.b	#7,lbB007D92
	beq	lbC005B6E
	add.b	#1,lbB007D92
	bra	lbC000934

lbC005B6E
	bra	lbC00060A

PattSetPattUp
	bsr	lbC002014
	addq.w	#1,CurrentPattNum
.set
	and.w	#$7F,CurrentPattNum
	bsr	lbC005D46
	move.b	#7,lbB007CA5
	clr.l	lbW007B78
	bsr	DrawPatternLines
	bsr	PattPrintLength
	move.w	CurrentPattNum,D0
	move.b	#12,CharXPos
	move.b	#4,CharYPos
	bsr	Draw2HexDigits
	bsr	lbC001C7E
	rts
.dn
	bsr	lbC002014
	subq.w	#1,CurrentPattNum
	bra.s	.set

PattSetPattDown	=	.dn

lbC005BD0
	bsr	lbC00207C
	bra	lbC005BE4

lbC005BD8
	bsr	lbC00207C
	addq.w	#1,CurrentMacroNum
lbC005BE4
	and.w	#$7F,CurrentMacroNum
	bsr	lbC005D46
	move.b	#7,lbB007CA5
	clr.l	lbW007B8A
	bsr	DrawMacroLines
	move.w	CurrentMacroNum,D0
	move.b	#12,CharXPos
	move.b	#4,CharYPos
	bsr	Draw2HexDigits
	bsr	lbC001CCA
	rts

lbC005C22
	bsr	lbC00207C
	subq.w	#1,CurrentMacroNum
	bra	lbC005BE4

lbC005C32
	bsr	lbC005D46
	move.l	_GfxBase,A6
	jsr	_LVOOwnBlitter(A6)
	jsr	_LVOWaitBlit(A6)
	move.l	PlanePtr0,A0
	bsr	.blit
	move.l	PlanePtr1,A0
	bsr	.blit
	cmp.l	#$10E00,PictSizeVal
	bne.s	.skip
	move.l	PlanePtr2,A0
	bsr	.blit
	move.l	PlanePtr3,A0
	bsr	.blit
.skip
	move.l	_GfxBase,A6
	jsr	_LVODisownBlitter(A6)
	move.l	PlanePtr0,A0
	move.l	PlanePtr1,A1
	move.l	a0,a2
	move.l	a1,a3
	cmp.l	#$10E00,PictSizeVal
	bne.s	.skip2
	move.l	PlanePtr2,A2
	move.l	PlanePtr3,A3
.skip2
	move.w	#$500,D0
	moveq.w	#$77,D1
.lp
	clr.b	$3C(A0,D0.W)
	clr.b	$3C(A1,D0.W)
	clr.b	$3C(A2,D0.W)
	clr.b	$3C(A3,D0.W)
	add.w	#$50,D0
	dbra	D1,.lp
	rts
.blit
	move.l	_GfxBase,A6
	jsr	_LVOWaitBlit(A6)
	lea	$DFF000,A5
	add.l	#$500,A0
	move.l	A0,$54(A5)
	move.w	#$14,$66(A5)
	move.w	#$100,$40(A5)
	move.w	#0,$42(A5)
	move.w	#$1E5E,$58(A5)
	rts

lbC005CE4
	tst.w	lbW007C8A
	beq	lbC005D44
	subq.w	#1,lbW007B6A
	bne	lbC005D44
	move.w	#$14,lbW007B6A
	bsr	ConsiderFlashCursor
	tst.l	lbL007C6A
	beq	lbC005D44
	subq.l	#1,lbL007C6A
	bne	lbC005D44
	move.w	#1,lbW007C94
	move.l	4,A6
	clr.l	D0
	clr.l	D1
	move.b	Defunct1SigBit,D1
	bset	D1,D0
	move.l	D0,D1
	move.l	lbL007C98,A1
	jsr	_LVOSignal(A6)
lbC005D44
	rts

lbC005D46
	clr.w	lbW007C8A
	tst.w	CursorState
	beq	.noflash
	bsr	ConsiderFlashCursor
.noflash	;lbC005D5A
	move.w	#1,lbW007B6A
	rts

ConsiderFlashCursor
	tst.w	lbW007B72
	beq	lbC005DCC
	eor.w	#$FFFF,CursorState
	moveq	#0,d1
	move.b	lbB007CA4+1(PC),D1
	asl.w	#2,D1
	lea	TextYOffsetTable(PC),A1
	add.w	d1,a1
	move.l	(a1),a2
	move.b	lbB007CA4(PC),D1
	add.l	D1,A2
	cmp.l	#$10E00,PictSizeVal
	beq.s	.skip
	add.l	PlanePtr1,A2
	bra.s	.noskip
.skip
	add.l	PlanePtr3,A2
.noskip
	not.b	(A2)
	not.b	$50(A2)
	not.b	$A0(A2)
	not.b	$F0(A2)
	not.b	$140(A2)
	not.b	$190(A2)
	not.b	$1E0(A2)
	not.b	$230(A2)
	not.b	$280(A2)
	rts

lbC005DCC
	move.w	#10,D0
	dbra	D0,*
	rts

lbC005DD6
	move.w	#0,D0
	move.b	#7,CharYPos
	move.b	#1,CharXPos
	bsr	Draw2HexDigits
	move.b	#5,CharXPos
	lea	Youcantusethi.MSG,A0
	bsr	DrawString
	move.b	#8,CharYPos
	move.w	#6,D7
lbC005E0C
	move.b	#1,CharXPos
	lea	ascii.MSG22,A0
	bsr	DrawString
	add.b	#1,CharYPos
	dbra	D7,lbC005E0C
	rts

EasyKeyboard
	bsr	GetPatternAddr
	clr.l	D0
	move.w	lbW007C78,D0
	asl.l	#3,D0
	add.l	D0,A0
	clr.l	D7
	move.b	KeyASCIIKeyCode,D7
	cmp.b	#13,D7
	beq	lbC006044
	clr.l	D1
	clr.w	D0
	move.b	lbB007D92,D0
lbC005E56
	cmp.w	#5,D0
	blt	lbC005E6C
	addq.l	#1,D1
	subq.w	#5,D0
	bra	lbC005E56

lbC005E6C
	clr.l	D2
	move.b	lbB007CA5,D2
	sub.l	#7,D2
	move.l	D2,D6
	asl.l	#3,D2
	cmp.w	#6,lbW007C76
	bne	lbC005E8E
	asl.l	#1,D6
	sub.l	D6,D2
lbC005E8E
	add.l	D2,D1
	asl.l	#3,D1
	add.l	D1,A0
	cmp.w	#3,D0
	bge	lbC005FC4
	bsr	lbC00605A
	cmp.w	#1,D0
	beq	lbC005F12
	cmp.w	#2,D0
	beq	lbC005FA0
	cmp.b	#'^',D7
	beq	.kup
	cmp.b	#'-',D7
	beq.s	.nop
	cmp.b	#'a',D7
	blt	lbC00060A
	beq.s	.a
	cmp.b	#'h',D7
	beq	.doit
	bgt	lbC00060A
	cmp.b	#'b',D7
	beq.s	.ish
	subq.b	#1,D7
	bra.s	.doit
.ish
	moveq	#'h',d7
.doit
	sub.b	#$62,D7
	asl.w	#2,D7
	lea	lbL0080DC,A1
	move.l	0(A1,D7.W),D2
	bsr	lbC00609A
	bra	lbC006020
.nop
	or.l	#$FF000000,(A0)
	bra	lbC006020
.kup
	move.l	#$F5000000,d0
	bsr	lbC0060C6
	move.l	d0,(a0)
	bra	lbC006020
.a
	moveq.l	#'g',D7
	bra	.doit

lbC005F12
	cmp.l	#4,D2
	beq	lbC00060A
	cmp.l	#12,D2
	beq	lbC00060A
	cmp.b	#'-',D7
	beq	lbC005F6E
	cmp.b	#'#',D7
	bne	lbC00060A
	move.l	#1,D4
	cmp.b	#0,D2
	beq	lbC005F64
	cmp.b	#2,D2
	beq	lbC005F64
	cmp.b	#5,D2
	beq	lbC005F64
	cmp.b	#7,D2
	beq	lbC005F64
	cmp.b	#9,D2
	bne	lbC00060A
lbC005F64
	add.l	D4,D2
	bsr	lbC00609A
	bra	lbC006020

lbC005F6E
	moveq.l	#$FFFFFFFF,D4
	cmp.b	#1,D2
	beq	lbC005F64
	cmp.b	#3,D2
	beq	lbC005F64
	cmp.b	#6,D2
	beq	lbC005F64
	cmp.b	#8,D2
	beq	lbC005F64
	cmp.b	#10,D2
	beq	lbC005F64
	bra	lbC00060A

lbC005FA0
	cmp.l	#'1',D7
	blt	lbC00060A
	cmp.l	#'3',D7
	bgt	lbC00060A
	sub.l	#'1',D7
	move.l	D7,D3
	bsr	lbC00609A
	bra	lbC006020

lbC005FC4
	cmp.l	#'0',D7
	blt	lbC00060A
	cmp.l	#':',D7
	ble	lbC005FF2
	cmp.l	#'a',D7
	blt	lbC00060A
	cmp.l	#'g',D7
	bge	lbC00060A
	sub.l	#$27,D7
lbC005FF2
	sub.l	#'0',D7
	sub.w	#3,D0
	bne.s	lbC00600E
	asl.l	#4,D7
	move.l	(A0),D0
	and.l	#$FF0FFFFF,D0
	bra	lbC006016

lbC00600E
	move.l	(A0),D0
	and.l	#$FFF0FFFF,D0
lbC006016
	swap	D7
	or.l	D7,D0
	bsr	lbC0060C6
	move.l	D0,(A0)
lbC006020
	bsr	lbC005D46
	bsr	lbC006196
	move.b	lbB007D92,D0
	cmp.b	ScrapVar,D0
	beq	lbC00060A
	addq.b	#1,lbB007D92
	bra	lbC000934

lbC006044
	bsr	lbC005D46
	clr.b	lbB007D92
	move.b	#5,lbB007CA4
	bra	lbC00611E

lbC00605A
	moveq	#0,d3
	moveq	#0,d2
	move.b	(A0),D2
	cmp.b	#$FF,D2
	beq.s	.nop
	subq.b	#6,D2
.lp
	sub.b	#12,D2
	bmi.s	.neg
	addq.l	#1,D3
	bra.s	.lp
.neg
	add.b	#12,d2
	rts
.nop
	clr.l	D2
	clr.l	D3
	rts

lbC00609A
	addq.l	#6,D2
	asl.l	#2,D3
	move.l	D3,D4
	asl.l	#1,D3
	add.l	D4,D3
	add.l	D2,D3
	and.l	#$3F,D3
	move.l	(A0),D0
	and.l	#$FFFFFF,D0
	swap	D3
	asl.l	#8,D3
	or.l	D3,D0
	bsr.s	lbC0060C6
	move.l	D0,(A0)
	rts

lbC0060C6
	clr.l	D3
	move.w	lbW007C7A,D3
	swap	D3
	lsr.l	#4,D3
	or.l	D3,D0
	clr.l	D3
	move.w	lbW007C7C,D3
	swap	D3
	lsr.l	#8,D3
	or.l	D3,D0
	rts

lbC0060E4
	cmp.b	#7,lbB007CA5
	beq	lbC006100
	bsr	lbC005D46
	sub.b	#1,lbB007CA5
	bra	lbC00060A

lbC006100
	tst.w	lbW007C78
	beq	lbC00060A
	move.w	lbW007C76,D0
	sub.w	D0,lbW007C78
	bsr	lbC006196
	bra	lbC00060A

lbC00611E
	bsr	GetPatternAddr
	clr.l	D0
	move.w	lbW007C78,D0
	asl.l	#3,D0
	add.l	D0,A0
	clr.l	D0
	move.b	lbB007CA5,D0
	sub.b	#7,D0
	asl.l	#1,D0
	move.l	D0,D1
	asl.l	#2,D0
	cmp.w	#6,lbW007C76
	bne	lbC00614E
	sub.l	D1,D0
lbC00614E
	asl.l	#3,D0
	add.l	D0,A0
	move.w	lbW007C76,D0
	asl.l	#3,D0
	add.l	D0,A0
	cmp.l	#$F0000000,(A0)
	beq	lbC00060A
	cmp.b	#14,lbB007CA5
	beq	lbC006182
	bsr	lbC005D46
	add.b	#1,lbB007CA5
	bra	lbC00060A

lbC006182
	move.w	lbW007C76,D0
	add.w	D0,lbW007C78
	bsr	lbC006196
	bra	lbC00060A

lbC006196
	move.b	#7,CharYPos
	bsr	GetPatternAddr
	clr.l	D0
	move.w	lbW007C78,D0
	asl.l	#3,D0
	add.l	D0,A0
	move.w	#7,D5
	move.w	lbW007C78,D7
lbC0061B8
	move.b	#1,CharXPos
	move.b	D7,D0
	and.l	#$FF,D0
	bsr	Draw2HexDigits
	move.b	#5,CharXPos
	move.w	lbW007C76,D6
	subq.w	#1,D6
lbC0061DE
	move.b	(A0),D0
	and.w	#$FF,D0
	move.l	A0,-(SP)
	lea	HypHypHyp.MSG,A0
	cmp.b	#$FF,D0
	beq.s	lbC00621C
	cmp.b	#$F5,D0
	bne.s	lbC006210
	lea	KUP.MSG,A0
	bra.s	lbC00621C
lbC006210
	move.l	NoteNameTablePtr,A0
	asl.w	#2,D0
	move.l	0(A0,D0.w),A0
lbC00621C
	bsr	DrawString
	move.l	(SP)+,A0
	moveq	#0,d0
	move.b	(A0),D0
	bsr	Draw2HexDigits
	addq.b	#1,CharXPos
	addq.l	#8,A0
	dbra	D6,lbC0061DE
	cmp.l	#$F0000000,(A0)
	beq	lbC00627A
	cmp.w	#6,lbW007C76
	bne	lbC006266
	move.l	A0,-(SP)
	lea	ascii.MSG24,A0
	bsr	DrawString
	move.l	(SP)+,A0
lbC006266
	addq.b	#1,CharYPos
	add.w	lbW007C76,D7
	dbra	D5,lbC0061B8
	rts

lbC00627A
	cmp.w	#1,D5
	bge	lbC006284
	rts

lbC006284
	subq.w	#1,D5
lbC006288
	addq.b	#1,CharYPos
	lea	ascii.MSG22,A0
	move.w	D5,-(SP)
	move.b	#1,CharXPos
	bsr	DrawString
	move.w	(SP)+,D5
	dbra	D5,lbC006288
	rts

lbC0062AC
	bsr	lbC005D46
	move.w	CurrentPattNum,D0
	add.w	14(A0),D0
	and.w	#$7F,D0
	move.w	D0,CurrentPattNum
	bsr	lbC00492E
	rts

lbC0062CA
	bsr	GetPatternAddr
	cmp.l	#$F4000000,(A0)
	bne	lbC006382
	cmp.l	#$F0000000,4(A0)
	bne	lbC006382
	bsr	lbC005D46
	lea	PleaseWait.MSG,A0
	bsr	DrawString
	move.b	lbB007CA5,-(SP)
	move.b	#7,lbB007CA5
	clr.l	lbW007B78
	bsr	GetPatternAddr
	move.l	#$F3000000,(A0)
	move.w	#15,D0
	lea	PattTmpBuffer,A0
lbC00631A
	move.l	#$F3000000,(A0)+
	move.l	#$FF000000,(A0)+
	dbra	D0,lbC00631A
	move.l	#15,lbL007BB6
	clr.l	D5
	bsr	lbC00532A
	clr.l	D5
	bsr	lbC00532A
	clr.l	D5
	bsr	lbC00532A
	clr.l	D5
	bsr	lbC00532A
	clr.l	D5
	bsr	lbC00532A
	clr.l	D5
	bsr	lbC00532A
	cmp.w	#6,lbW007C76
	beq	lbC006370
	clr.l	D5
	bsr	lbC00532A
	clr.l	D5
	bsr	lbC00532A
lbC006370
	clr.l	D5
	bsr	PattDeletePattLine
	move.b	(SP)+,lbB007CA5
	bsr	lbC001C7E
	rts

lbC006382
	clr.b	D5
	bsr	PattFigureLength
	move.w	PattLgLength,D0
	beq	lbC0063CE
	move.w	lbW007C76,D1
lbC006398
	sub.w	D1,D0
	bpl	lbC006398
	add.w	D1,D0
	bne	lbC0063CE
	bsr	GetPatternAddr
lbC0063A8
	move.b	(A0),D1
	addq.l	#4,a0
	cmp.b	#$FF,D1
	beq.s	lbC0063D4
	cmp.b	#$2F,D1
	bls.s	lbC0063D4
	cmp.b	#$AF,d1
	ble.s	lbC0063EA
	cmp.b	#$F3,D1
	beq.s	lbC0063EA
lbC0063CE
	move.b	#1,D0
	rts

lbC0063D4
	move.b	(A0)+,D1
	addq.l	#4,a0
	cmp.b	#$F3,D1
	beq.s	lbC0063EA
	bra.s	lbC0063CE

lbC0063EA
	cmp.l	#$F0000000,(A0)
	bne.s	lbC0063A8
	bsr.s	lbC0063FC
	clr.l	D0
	rts

lbC0063FC
	lea	PattTmpBuffer,A0
	move.l	#$FF000000,(A0)+
	move.l	#$F3000000,(A0)+
	move.l	#1,lbL007BB6
	bsr	lbC005D46
	lea	PleaseWait.MSG,A0
	bsr	DrawString
	move.b	lbB007CA5,-(SP)
	move.b	#7,lbB007CA5
	clr.l	lbW007B78
	bsr	GetPatternAddr
lbC00643E
	move.b	(A0),D1
	cmp.b	#$F0,D1
	beq	lbC0064D6
	cmp.b	#$F3,D1
	beq.s	lbC00648A
	cmp.b	#$FF,D1
	beq.s	lbC006476

	move.b	2(A0),D1
	and.w	#$F,D1
	move.w	D1,lbW007C7C

	cmp.b	#$AF,d1
	bgt.s	lbC006476

	move.l	a0,-(a7)
	moveq	#0,d5
	bsr	PattInsertPattLine
	move.l	(a7)+,a0

	sf	-1(a0)
	move.l	#$F300,d0
	move.b	3(a0),d0
	swap.w	d0
	move.l	d0,(a0)
	bra.s	lbC00648A
lbC006476
	addq.l	#4,A0
	addq.l	#1,lbW007B78
	bra	lbC00643E
lbC00648A
	move.w	(A0),D1
	and.w	#$FF,D1
	beq	lbC006476
	move.w	D1,-(SP)
	move.l	#$F3000000,(A0)
	move.l	A0,-(SP)
	clr.l	D5
	bsr	PattInsertPattLine
	move.l	(SP)+,A0
	move.l	#$FF000000,(A0)
	move.w	(SP)+,D1
	subq.w	#1,D1
lbC0064B6
	move.w	D1,-(SP)
	move.l	A0,-(SP)
	clr.l	D5
	bsr	lbC00532A
	move.l	(SP)+,A0
	move.w	(SP)+,D1
	dbra	D1,lbC0064B6
	clr.l	D5
	move.l	A0,-(SP)
	bsr	PattDeletePattLine
	move.l	(SP)+,A0
	bra	lbC006476

lbC0064D6
	clr.w	D7
	move.b	(SP)+,lbB007CA5
	bsr	lbC001C7E
	clr.l	lbW007B78
	rts

EasyDisplayVolChn
	move.w	lbW007C7C,D0
	move.b	#$10,CharYPos
	move.b	#$28,CharXPos
	bsr	Draw1HexDigit
	move.w	lbW007C7A,D0
	move.b	#$10,CharYPos
	move.b	#$33,CharXPos
	bsr	Draw1HexDigit
	rts

EasySetVolChn
	move.w	12(A0),D0
	lea	lbW007C7A,A1
	move.w	0(A1,D0.W),D1
	add.w	14(A0),D1
	and.w	#15,D1
	move.w	D1,0(A1,D0.W)
	bsr	EasyDisplayVolChn
	rts

EasyOptimizePatt
	bsr	lbC005D46
	bsr	GetPatternAddr
	move.b	#7,lbB007CA5
	clr.l	lbW007B78
.lp
	move.b	(A0),D0
	cmp.b	#$F0,D0
	beq.s	.end
	cmp.b	#$FF,D0
	bne.s	.skip
	moveq	#0,d5
	move.l	A0,-(SP)
	bsr	PattDeletePattLine
	move.l	(SP)+,A0
	tst.l	lbW007B78
	beq.s	.skip
	move.w	(A0),D0
	and.w	#$FF,D0
	addq.w	#$1,D0
	add.w	D0,-4(A0)
	moveq	#0,d5
	move.l	A0,-(SP)
	bsr	PattDeletePattLine
	move.l	(SP)+,A0
	bra.s	.lp
.skip
	addq.l	#4,A0
	addq.l	#1,lbW007B78
	bra.s	.lp
.end
	moveq	#0,d7
	bra	DrawActivePage

EasyToggleTimeSig
	bsr	lbC005D46
	move.w	#$9B,D0
	move.w	#6,lbW007C76
	cmp.w	#$19C,4(A0)
	beq.s	.three
	move.w	#8,lbW007C76
	move.w	#$9C,D0
.three
	move.w	D0,D3
	or.w	#$100,D3
	move.w	D3,4(A0)
	moveq.l	#15,D2
	moveq.l	#$39,D1
	bsr	Vsync
	bsr	ClearButton
	moveq.l	#$38,D1
	bsr	RenderStuff
	bra	lbC004994

;Execute
;	clr.l	D2
;	clr.l	D3
;	move.l	_DosBase,A6
;	jsr	_LVOExecute(A6)
;	rts

AskClearTracks
	st	D5
	bsr	AlertConfirmClear
ClearTracks
	move.l	MdatBuffer,A0
	add.l	#$800,A0
	move.w	#$7FF,D0
	move.l	#$FF00FF00,d1
.lp
	move.l	d1,(A0)+
	dbra	D0,.lp
	tst.b	D5
	beq	.nodraw
	bsr	DrawTracks
.nodraw
	rts

lbC006652
	st	D5
	move.w	lbW007BDC,-(SP)
	clr.w	lbW007BDC
lbC006660
	bsr	GetPatternAddr
	cmp.l	#$F0000000,4(A0)
	beq	lbC00668A
lbC006670
	bsr	lbC005D46
	move.b	#7,lbB007CA5
	move.b	D5,-(SP)
	clr.b	D5
	bsr	PattDeletePattLine
	move.b	(SP)+,D5
	bra	lbC006660
lbC00668A
	cmp.l	#$F4000000,(A0)
	bne	lbC006670
	tst.b	D5
	beq	lbC0066A2
	bsr	DrawPatternLines
	bsr	PattPrintLength
lbC0066A2
	move.w	(SP)+,lbW007C04
	bsr	lbC0055F6
	rts

lbC0066AE
	st	D5
	move.w	lbW007BDC,-(SP)
	clr.w	lbW007BDC
lbC0066BC
	bsr	GetMacroAddr
	cmp.l	#$7000000,4(A0)
	beq	lbC0066E6
lbC0066CC
	bsr	lbC005D46
	move.b	#7,lbB007CA5
	move.b	D5,-(SP)
	clr.b	D5
	bsr	lbC004DE2
	move.b	(SP)+,D5
	bra	lbC0066BC
lbC0066E6
	cmp.l	#$4000000,(A0)
	bne	lbC0066CC
	tst.b	D5
	beq	lbC0066FA
	bsr	DrawMacroLines
lbC0066FA
	move.w	(SP)+,lbW007C04
	bsr	lbC0055F6
	rts

PattPrintLength
	st	D5
PattFigureLength
	move.b	D5,-(SP)
	bsr	GetPatternAddr
	clr.w	PattLgLength
	move.b	#$FF,PattLgLoopCtr
	move.w	#$C00,D4
.pattlp
	subq.w	#1,D4
	beq	.err
	move.b	(A0),D0
	bpl.s	.null
	cmp.b	#$F4,D0
	beq	.done
	cmp.b	#$F2,D0
	beq	.done
	cmp.b	#$F0,D0
	beq	.done
	cmp.b	#$F1,D0
	beq.s	.loop
	cmp.b	#$C0,D0
	bge.s	.not80
	move.w	2(A0),D0
	bra.s	.add1
.not80
	cmp.b	#$F3,D0
	bne.s	.null
	move.w	(A0),D0
.add1
	and.w	#$FF,D0
	addq.w	#1,D0
	add.w	D0,PattLgLength
.null
	addq.l	#4,A0
	bra.s	.pattlp
.loop
	move.w	(A0),D0
	and.w	#$FF,D0
	beq.s	.endl
	tst.b	PattLgLoopCtr
	beq	.lpnext
	cmp.b	#$FF,PattLgLoopCtr
	bne	.lpnoload
	move.b	D0,PattLgLoopCtr
.lpnoload
	move.w	2(A0),D6
	move.w	D6,D5
	bsr	GetPatternAddr
.lplp
	tst.w	D6
	beq.s	.lpisok
	move.l	(A0)+,D0
	cmp.l	#$F0000000,D0
	beq	.err
	subq.w	#1,D6
	bra.s	.lplp
.lpisok
	subq.b	#1,PattLgLoopCtr
	bra	.pattlp
.lpnext
	move.b	#$FF,PattLgLoopCtr
	bra.s	.null
.err
	move.b	(SP)+,D5
	beq.s	.noprint
	lea	Err.MSG,A0
	bsr	DrawString
.noprint
	rts
.endl
	move.b	(SP)+,D5
	beq.s	.noprint
	lea	Endl.MSG,A0
	bsr	DrawString
	rts
.done
	move.b	(SP)+,D5
	beq.s	.noprint
	move.w	PattLgLength,D1
	move.b	#$3B,CharXPos
	move.b	#4,CharYPos
	bsr	Draw4HexDigits
	rts

DrawPatternLines
	clr.w	PatternHitEnd
	clr.w	PatternStepNumber
	move.b	#7,CharYPos
	move.w	#7,D4
	bsr	GetPatternAddr
	move.l	lbW007B78,D0
	move.w	lbW007B7A,D5
	asl.l	#2,D0
	add.l	D0,A0
.lp
	st	D6
	bsr	DrawPatternLine
	add.l	#4,A0
	add.b	#1,CharYPos
	add.w	#1,D5
	dbra	D4,.lp
	move.w	#$FFFF,PatArrowOldY
	rts

DrawPatternLine
	tst.w	PatternHitEnd
	bne	.blank
	addq.w	#1,PatternStepNumber
	move.b	(A0),D0
	cmp.b	#$F0,D0
	bne.s	.notend
	move.w	#1,PatternHitEnd
	subq.w	#1,PatternStepNumber
.notend
	tst.b	D6
	beq.s	.nostepnr
	move.b	#5,CharXPos
	move.w	D5,D1
	bsr	Draw4HexDigits
.nostepnr
	move.l	(A0),D0
	move.b	#8,CharXPos
	move.l	D0,-(SP)
	move.b	#$20,D0
	bsr	DrawChar
	move.l	(SP)+,D0
	move.b	#9,CharXPos
	swap	D0
	move.w	D0,D7
	and.l	#$FFFF,D0
	lsr.l	#8,D0
	move.l	D0,D6
	bsr	Draw2HexDigits
	move.l	D6,D0
	move.l	A0,A4
	move.b	#14,CharXPos
	move.l	NoteNameTablePtr,A0
	cmp.w	#$F0,D0
	bcc.s	.iscmd
	and.l	#$3F,D0
	bra	.gotdesc
.iscmd
	and.w	#15,D0
	move.l	PatternCmdTablePtr,A0
.gotdesc
	asl.w	#2,D0
	move.l	0(A0,D0.w),A0
	bsr	DrawString
	move.l	A4,A0
	and.w	#$FF,D7
	move.w	D7,D0
	move.b	#$16,CharXPos
	bsr	Draw2HexDigits
	move.l	(A0),D0
	move.l	D0,D7
	rol.w	#4,D0
	and.w	#$F,d0
	move.b	#$30,CharXPos
	bsr	Draw1HexDigit
	move.w	D7,-(a7)
	move.b	(a7)+,d0
	and.w	#15,D0
	move.b	#$34,CharXPos
	bsr	Draw1HexDigit
	move.w	D7,D0
	and.w	#$FF,D0
	move.b	#$39,CharXPos
	bsr	Draw2HexDigits
	move.w	(A0),D0
	cmp.w	#$C000,D0
	bcc.s	.isportorcmd
	move.w	(A0),D0
	and.w	#$7F,D0
	move.w	D0,D2
	asl.w	#4,D0
	asl.w	#2,D2
	add.w	D0,D2
	move.l	InfoBuffer,A5
	add.l	#$A00,A5
	moveq	#$13,D3
	move.b	#$1A,CharXPos
	add.w	d2,a5
.macnmlp
	move.b	(A5)+,D0
	bne.s	.mnnotnull
	move.b	#$20,D0
.mnnotnull
	bsr	DrawChar
	addq.b	#1,CharXPos
	dbra	D3,.macnmlp
	rts
.isportorcmd
	cmp.w	#$F000,D0
	bcc.s	.iscmd2
	rol.w	#4,d0
	and.w	#$C,d0
	add.w	#$3C,d0
	move.l	PatternCmdTablePtr,A5
	add.w	D0,A5
	move.l	A0,-(SP)
	move.l	(A5),A0
	move.b	#$1A,CharXPos
	bsr	DrawString
	move.l	(SP)+,A0
.iscmd2
	rts
.blank
	move.b	#2,CharXPos
	lea	ascii.MSG25,A0
	bsr	DrawString
	rts

GetPatternAddr
	move.w	CurrentPattNum,D0
	asl.w	#2,D0
	move.l	MdatBuffer,A0
	add.l	#$400,A0
	move.l	0(A0,D0.W),A0
	add.l	MdatBuffer,A0
	rts

DrawMacroLines
	clr.w	MacroHitEnd
	clr.w	lbW007C92
	move.b	#7,CharYPos
	move.w	#7,D4
	bsr	GetMacroAddr
	move.l	lbW007B8A,D0
	move.w	lbW007B8C,D5
	asl.l	#2,D0
	add.l	D0,A0
.lp
	bsr	DrawMacroLine
	add.l	#4,A0
	add.b	#1,CharYPos
	add.w	#1,D5
	dbra	D4,.lp
	rts

DrawMacroLine
	tst.w	MacroHitEnd
	bne	.blank
	add.w	#1,lbW007C92
	move.l	(A0),D0
	and.l	#$FF000000,D0
	cmp.l	#$7000000,D0
	bne.s	.notstop
	move.w	#1,MacroHitEnd
	sub.w	#1,lbW007C92
.notstop
	move.b	#5,CharXPos
	move.w	D5,D1
	bsr	Draw4HexDigits
	move.l	(A0),D0
	move.b	#9,CharXPos
	swap	D0
	move.w	D0,D7
	and.l	#$FFFF,D0
	lsr.l	#8,D0
	move.l	D0,D6
	bsr	Draw2HexDigits
	move.l	D6,D0
	cmp.l	MacroCmdNameCount,D0
	bcs.s	.isentry
	move.l	MacroCmdNameCount,D0
.isentry
	asl.l	#2,D0
	move.l	A0,-(SP)
	move.l	MacroCmdTablePtr,A0
	move.l	0(A0,D0.L),A0
	move.b	#13,CharXPos
	bsr	DrawString
	move.l	(SP)+,A0
	and.w	#$FF,D7
	move.w	D7,D0
	move.b	#$35,CharXPos
	bsr	Draw2HexDigits
	move.l	(A0),D0
	move.l	D0,D7
	lsr.w	#8,D0
	bsr	Draw2HexDigits
	move.w	D7,D0
	and.w	#$FF,D0
	bsr	Draw2HexDigits
	rts
.blank
	move.b	#2,CharXPos
	lea	ascii.MSG26,A0
	bsr	DrawString
	rts

GetMacroAddr
	move.w	CurrentMacroNum,D0
	asl.w	#2,D0
	move.l	MdatBuffer,A0
	add.l	#$600,A0
	add.w	d0,a0
	move.l	(A0),A0
	add.l	MdatBuffer,A0
	rts

RenderStuff
	movem.l	D0-D7/A0-A6,-(SP)
	move.l	_GfxBase(PC),A6
	jsr	_LVOWaitBlit(A6)
	jsr	_LVOOwnBlitter(A6)
	lea	$DFF000,A5
	move.w	D0,D3
	asl.w	#3,D3
	move.l	CurrentDecalListPtr,A4
	move.w	2(A4,D3.w),D4
	and.w	#$3F,D4
	move.w	#$28,D5
	sub.w	D4,D5
	move.w	D5,D4
	asl.w	#1,D4
	move.w	D4,$64(A5)
	move.w	D4,$66(A5)
	move.w	D4,$62(A5)
	lea	TextYOffsetTable(PC),A3
	asl.l	#2,D2
	move.l	0(A3,D2.w),A0
	move.l	D1,D4
	and.l	#$FFFE,D4
	add.l	D4,A0
	move.l	A0,lbL007B4A
	cmp.l	#$10E00,PictSizeVal
	bne.s	.is2c
	add.l	PlanePtr0,A0
	bra.s	.gotpp
.is2c
	add.l	PlanePtr1,A0
.gotpp
	move.l	A0,$4C(A5)
	move.l	A0,$54(A5)
	clr.w	D2
	move.b	1(A4,D3.w),D2
	asl.w	#2,D2
	move.l	0(A3,D2.W),A0
	clr.l	D2
	move.b	0(A4,D3.w),D2
	asl.l	#1,D2
	add.l	D2,A0
	add.l	PictBuffer,A0
	move.l	A0,lbL007B46
	move.l	A0,$50(A5)
	move.w	#$DFC,$40(A5)
	move.w	#0,$42(A5)
	move.w	4(A4,D3.w),$44(A5)
	move.w	6(A4,D3.w),$46(A5)
	move.w	2(A4,D3.w),D7
	and.w	#1,D1
	beq.s	.noshift
	move.w	#$8DFC,$40(A5)
	move.w	4(A4,D3.w),$44(A5)
	move.w	6(A4,D3.w),D1
	move.w	D1,$46(A5)
	cmp.w	4(A4,D3.w),D1
	bne.s	.noshift
	move.w	2(A4,D3.w),D7
	add.w	#1,D7
	move.w	D7,D1
	and.w	#$3F,D1
	neg.w	D1
	add.w	#$28,D1
	asl.w	#1,D1
	move.w	D1,$62(A5)
	move.w	D1,$64(A5)
	move.w	D1,$66(A5)
	move.w	#0,$46(A5)
.noshift
	move.w	D7,$58(A5)
	cmp.l	#$10E00,PictSizeVal
	bne	.disown

	jsr	_LVOWaitBlit(A6)
	move.l	lbL007B4A,D0
	add.l	PlanePtr1,D0
	move.l	D0,$4C(A5)
	move.l	D0,$54(A5)
	add.l	#$4380,lbL007B46
	move.l	lbL007B46,$50(A5)
	move.w	D7,$58(A5)

	jsr	_LVOWaitBlit(A6)
	move.l	lbL007B4A,D0
	add.l	PlanePtr2,D0
	move.l	D0,$4C(A5)
	move.l	D0,$54(A5)
	add.l	#$4380,lbL007B46
	move.l	lbL007B46,$50(A5)
	move.w	D7,$58(A5)

	jsr	_LVOWaitBlit(A6)
	move.l	lbL007B4A,D0
	add.l	PlanePtr3,D0
	move.l	D0,$4C(A5)
	move.l	D0,$54(A5)
	add.l	#$4380,lbL007B46
	move.l	lbL007B46,$50(A5)
	move.w	D7,$58(A5)
.disown
	jsr	_LVODisownBlitter(A6)
	movem.l	(SP)+,D0-D7/A0-A6
	rts

ClearButton
	movem.l	D0-D2,-(SP)
	lea	TextYOffsetTable(PC),A0
	asl.l	#2,D2
	move.l	0(A0,D2.L),A0
	add.l	D1,A0
	move.l	A0,A1
	move.l	A0,A2
	move.l	A0,A3
	add.l	PlanePtr0,A0
	add.l	PlanePtr1,A1
	add.l	PlanePtr2,A2
	add.l	PlanePtr3,A3
	cmp.l	#$10E00,PictSizeVal
	beq.s	.skip
	move.l	a0,a2
	move.l	a1,a3
.skip
	moveq	#15,D1
.lp
	clr.b	(A0)+
	clr.b	(A1)+
	clr.b	(A2)+
	clr.b	(A3)+
	clr.b	(A0)+
	clr.b	(A1)+
	clr.b	(A2)+
	clr.b	(A3)+
	clr.b	(A0)+
	clr.b	(A1)+
	clr.b	(A2)+
	clr.b	(A3)+
	clr.b	(A0)+
	clr.b	(A1)+
	clr.b	(A2)+
	clr.b	(A3)+
	add.l	#$4C,A0
	add.l	#$4C,A1
	add.l	#$4C,A2
	add.l	#$4C,A3
	dbra	D1,.lp
	movem.l	(SP)+,D0-D2
	rts

ReadFile
	move.l	_DosBase,A6
	move.l	0(A5),D1
	move.l	#$3ED,D2
	jsr	_LVOOpen(A6)
	beq	ReadFileRTS
	move.l	D0,TmpFileHandle
ReadCloseFile
	move.l	TmpFileHandle,D1
	move.l	4(A5),A0
	move.l	(A0),D2
	move.l	8(A5),D3
	jsr	_LVORead(A6)
	move.l	D0,D7
CloseFile
	move.l	_DosBase,A6
	move.l	TmpFileHandle,D1
	jsr	_LVOClose(A6)
	move.l	D7,D0
ReadFileRTS
	rts

WriteFile
	move.l	_DosBase,A6
	move.l	0(A5),D1
	move.l	#$3EE,D2
	jsr	_LVOOpen(A6)
	beq	lbC006E1E
	move.l	D0,TmpFileHandle
	move.l	D0,D1
	move.l	4(A5),A0
	move.l	(A0),D2
	move.l	8(A5),D3
	jsr	_LVOWrite(A6)
	move.l	D0,D7
	move.l	_DosBase,A6
	move.l	TmpFileHandle,D1
	jsr	_LVOClose(A6)
	move.l	D7,D0
lbC006E1E
	rts

LoadILBM
	move.l	_DosBase,A6
	move.l	0(A5),D1
	move.l	#$3ED,D2
	jsr	_LVOOpen(A6)
	bne.s	*+4
	rts
	move.l	D0,TmpFileHandle
	bsr	ReadLongword
	beq	.close
	cmp.l	#'FORM',LongValue
	bne	.close
	bsr	ReadLongword
	beq	.close
	bsr	ReadLongword
	beq	.close
	cmp.l	#'ILBM',LongValue
	bne	.close
.findbody
	bsr	ReadLongword
	beq	.close
	cmp.l	#'BODY',LongValue
	beq	.body
	bsr	ReadLongword
	beq	.close
	move.l	TmpFileHandle,D1
	move.l	LongValue,D2
	addq.l	#1,D2
	bclr	#0,D2
	moveq	#0,D3
	jsr	_LVOSeek(A6)
	bra	.findbody
.body
	bsr	ReadLongword
	beq	.close
	move.l	TmpFileHandle,D1
	move.l	PictBuffer,D2
	move.l	PictSizeVal,D3
	jsr	_LVORead(A6)
	move.l	PictBuffer,A5
	move.l	ILBMUnpackBuffer,A6
	move.l	A6,A4
	add.l	PictSizeVal,A4
	bsr	.unpack
.close
	move.l	_DosBase,A6
	move.l	TmpFileHandle,D1
	jsr	_LVOClose(A6)
	move.l	#$FFFF,D0
	rts

.unpack
	cmp.l	A6,A4
	ble.s	.unravel
	moveq	#0,d0
	move.b	(A5)+,D0
	bmi.s	.repeat
.copy
	move.b	(A5)+,(A6)+
	dbra	D0,.copy
	bra.s	.unpack
.repeat
	neg.b	d0
	move.b	(A5)+,D1
.reptlp
	move.b	D1,(A6)+
	dbra	D0,.reptlp
	bra.s	.unpack

.unravel
	move.l	PictBuffer,A5
	move.l	ILBMUnpackBuffer,A6
	move.w	#$D7,D0
.unravlp
	move.l	A5,A0
	moveq	#$4F,D1
.unrav1lp
	move.b	(A6)+,(A0)+
	dbra	D1,.unrav1lp
	cmp.l	#$10E00,PictSizeVal
	bne.s	.skip
	lea	$4380(a5),a0
	moveq	#$4F,D1
.unrav2lp
	move.b	(A6)+,(A0)+
	dbra	D1,.unrav2lp
	move.l	A5,A0
	add.l	#$8700,A0
	moveq	#$4F,D1
.unrav3lp
	move.b	(A6)+,(A0)+
	dbra	D1,.unrav3lp
	move.l	A5,A0
	add.l	#$CA80,A0
	moveq	#$4F,D1
.unrav4lp
	move.b	(A6)+,(A0)+
	dbra	D1,.unrav4lp
.skip
	add.l	#$50,A5
	dbra	D0,.unravlp
	rts

.unrav1
	rts

DrawCurrentGadgetList
	move.l	CurrentGadgetList,A0
DrawGadgetList
	cmp.w	#$FFFF,4(A0)
	beq.s	.end
	moveq	#0,d0
	moveq	#0,d1
	move.w	4(A0),D0
	and.w	#$FF,D0
	move.w	6(A0),D1
	and.w	#$7F,D1
	moveq	#0,d2
	move.b	6(A0),D2
	bsr	RenderStuff
	tst.l	(A0)
	beq.s	.decal
	addq.l	#8,A0
.decal
	addq.l	#8,A0
	bra	DrawGadgetList
.end
	rts

FselChangeCompFlag
	cmp.w	#$7B,-4(A0)
	beq.s	.red
	cmp.w	#$7C,-4(A0)
	bne.s	.green
	move.l	#$7B,D0
	move.w	D0,-4(A0)
	move.w	#1,SongCompressFlag
	bra.s	.draw
.green
	move.l	#$7C,D0
	move.w	D0,-4(A0)
	clr.w	SongCompressFlag
	bra.s	.draw
.red
	move.l	#$29,D0
	move.w	D0,-4(A0)
	move.w	#$FFFF,SongCompressFlag
.draw
	move.l	#$33,D1
	move.l	#15,D2
	bsr	Vsync
	bsr	ClearButton
	bsr	RenderStuff
	rts

DrawSongInfo
	move.l	MdatBuffer,A0
	add.l	#$100,A0
	move.w	CurrentSongNum,D0
	asl.w	#1,D0
	move.w	0(A0,D0.W),D1
	move.b	#$45,CharXPos
	move.b	#6,CharYPos
	bsr	Draw4HexDigits
	add.l	#$40,A0
	move.w	0(A0,D0.W),D1
	move.b	#$4A,CharXPos
	bsr	Draw4HexDigits
	add.l	#$40,A0
	move.w	0(A0,D0.W),D1
	move.b	#$4F,CharXPos
	bsr	Draw4HexDigits
	move.w	CurrentSongNum,D0
	move.b	#$48,CharXPos
	move.b	#2,CharYPos
	bsr	Draw2HexDigits
	rts

GetSongStatsAddr
	move.l	MdatBuffer,A0
	clr.l	D0
	move.w	CurrentSongNum,D0
	asl.w	#1,D0
	add.l	D0,A0
	rts

SetSong1stStepUp
	bsr	GetSongStatsAddr
	addq.w	#1,$100(A0)
	and.w	#$1FF,$100(A0)
	bsr	DrawSongInfo
	rts

SetSong1stStepDn
	bsr	GetSongStatsAddr
	subq.w	#1,$100(A0)
	and.w	#$1FF,$100(A0)
	bsr	DrawSongInfo
	rts

SetSongLastStepUp
	bsr	GetSongStatsAddr
	addq.w	#1,$140(A0)
	and.w	#$1FF,$140(A0)
	bsr	DrawSongInfo
	rts

SetSongLastStepDn
	bsr	GetSongStatsAddr
	subq.w	#1,$140(A0)
	and.w	#$1FF,$140(A0)
	bsr	DrawSongInfo
	rts

SetSongSpeedUp
	bsr	GetSongStatsAddr
	addq.w	#1,$180(A0)
	and.w	#$1FF,$180(A0)
	bsr	DrawSongInfo
	rts

SetSongSpeedDn
	bsr	GetSongStatsAddr
	subq.w	#1,$180(A0)
	and.w	#$1FF,$180(A0)
	bsr	DrawSongInfo
	rts

SetSongUp
	addq.w	#1,CurrentSongNum
	and.w	#$1F,CurrentSongNum
	bsr	DrawSongInfo
	rts

SetSongDn
	subq.w	#1,CurrentSongNum
	and.w	#$1F,CurrentSongNum
	bsr	DrawSongInfo
	rts

DrawString
	move.b	(A0)+,D0
	beq.s	.end
	cmp.b	#$FF,D0
	beq.s	.goto
	cmp.b	#$3E,D0
	beq.s	.skip
	bsr.s	DrawChar
.skip
	add.b	#1,CharXPos
	bra.s	DrawString
.end
	rts
.goto
	move.b	(A0)+,CharXPos
	move.b	(A0)+,CharYPos
	bra.s	DrawString

DrawChar
	and.w	#$FF,D0
	move.l	d2,-(SP)
	move.l	TopazModulo,d2
	moveq	#0,d1
	move.b	CharYPos,D1
	asl.l	#2,D1
	lea	TextYOffsetTable(PC),A1
	move.l	0(A1,D1.W),A2
	move.b	CharXPos(PC),D1
	add.l	D1,A2
	cmp.b	#'[',D0
	bne.s	.notlfsq
	move.l	#LeftArrowImagery,A3
	moveq	#1,d2
	bra.s	.gotchar
.notlfsq
	cmp.b	#']',D0
	bne.s	.notrtsq
	move.l	#RightArrowImagery,A3
	moveq	#1,d2
	bra.s	.gotchar
.notrtsq
	sub.w	#$20,D0
	move.w	D0,A3
	add.l	TopazData,A3
.gotchar
	add.l	PlanePtr0,A2
	add.l	#$50,A2
	move.b	(A3),(A2)
	add.l	d2,A3
	move.b	(A3),$50(A2)
	add.l	d2,A3
	move.b	(A3),$A0(A2)
	add.l	d2,A3
	move.b	(A3),$F0(A2)
	add.l	d2,A3
	move.b	(A3),$140(A2)
	add.l	d2,A3
	move.b	(A3),$190(A2)
	add.l	d2,A3
	move.b	(A3),$1E0(A2)
	add.l	d2,A3
	move.b	(A3),$230(A2)
	move.l	(SP)+,d2
	rts

DrawTrack
	move.l	D0,-(SP)
	move.b	#4,CharXPos
	move.l	D0,D1
	move.l	D0,D7
	bsr	Draw4HexDigits
	move.b	#6,CharXPos
	asl.l	#4,D7
	move.l	MdatBuffer,A6
	add.l	#$800,A6
	move.w	#7,D6
.lp
	move.w	0(A6,D7.L),D0
	lsr.w	#8,D0
	bsr.s	Draw2HexDigits
	add.b	#1,CharXPos
	move.w	0(A6,D7.L),D0
	and.w	#$FF,D0
	bsr.s	Draw2HexDigits
	add.l	#2,D7
	add.b	#2,CharXPos
	dbra	D6,.lp
	move.l	(SP)+,D0
	rts

Draw2HexDigits
	move.w	D0,-(SP)
	lsr.b	#4,D0
	bsr.s	Draw1HexDigit
	addq.b	#1,CharXPos
	move.w	(SP)+,D0
	and.w	#15,D0
	bsr.s	Draw1HexDigit
	addq.b	#1,CharXPos
	rts

Draw4HexDigits
	move.l	D0,-(SP)
	move.w	D1,D0
	and.w	#15,D0
	bsr.s	Draw1HexDigit
	subq.b	#1,CharXPos
	lsr.w	#4,D1
	move.w	D1,D0
	and.w	#15,D0
	bsr.s	Draw1HexDigit
	subq.b	#1,CharXPos
	lsr.w	#4,D1
	move.w	D1,D0
	and.w	#15,D0
	bsr.s	Draw1HexDigit
	subq.b	#1,CharXPos
	lsr.w	#4,D1
	move.w	D1,D0
	bsr.s	Draw1HexDigit
	subq.b	#1,CharXPos
	move.l	(SP)+,D0
	rts

Draw1HexDigit
	add.b	#$30,D0
	cmp.b	#$3A,D0
	bcs.s	.isnum
	addq.b	#7,D0
.isnum
	move.l	D1,-(SP)
	bsr	DrawChar
	move.l	(SP)+,D1
	rts

SetScreenColors
	move.l	D1,-(SP)
	move.l	_GfxBase,A6
	moveq	#15,D5
.lp
	lea	RedValues(PC),A1
	lea	GreenValues(PC),A2
	lea	BlueValues(PC),A3
	move.l	ViewPortPtr,A0
	move.b	0(A1,D5.W),D1
	move.b	0(A2,D5.W),D2
	move.b	0(A3,D5.W),D3
	move.w	D5,D0
	jsr	_LVOSetRGB4(A6)
	dbra	D5,.lp
	move.l	(SP)+,D1
	rts

SetMouseColors
	move.l	D1,-(SP)
	move.l	_GfxBase,A6
	move.l	ViewPortPtr,A0
	move.b	#15,D1
	move.b	D1,D2
	move.b	D2,D3
	move.b	#$11,D0
	move.l	A1,-(SP)
	move.l	A2,-(SP)
	jsr	_LVOSetRGB4(A6)
	move.l	ViewPortPtr,A0
	move.b	#5,D1
	move.b	D1,D2
	move.b	D2,D3
	move.b	#$12,D0
	jsr	_LVOSetRGB4(A6)
	move.l	(SP)+,A2
	move.l	(SP)+,A1
	move.l	ViewPortPtr,A0
	move.b	#8,D1
	move.b	D1,D2
	move.b	D2,D3
	move.b	#$13,D0
	jsr	_LVOSetRGB4(A6)
	move.l	(SP)+,D1
	rts

GetPlaneAddrs
	move.l	_IntuitionBase(PC),A6
	move.l	WindowPtr,A0
	jsr	_LVOViewPortAddress(A6)
	move.l	D0,ViewPortPtr
	move.l	ViewPortPtr,A0
	move.l	$24(A0),A1
	move.l	4(A1),A0
	move.l	#$C20354,A4
	move.l	8(A0),PlanePtr0
	move.l	12(A0),PlanePtr1
	move.l	$10(A0),PlanePtr2
	move.l	$14(A0),PlanePtr3
	rts

intuitionlibr.MSG
	dc.b	'intuition.library',0
graphicslibra.MSG
	dc.b	'graphics.library',0
doslibrary.MSG
	dc.b	'dos.library',0
modprof.MSG
	dc.b	'mod.prof',0
mod2colp.MSG
	dc.b	'mod.2colp',0
songsmdatempt.MSG
	dc.b	'songs/mdat.empty',0
routinesroutt.MSG
	dc.b	'routines/rout.tfmx.obj_v3.0',0
sampler.MSG
	dc.b	'sampler',0
ascii.MSG2
	dc.b	'                                            '
	dc.b	'                                            '
	dc.b	'             ',0
DF0songs.MSG
	dc.b	'songs                                        ',0
DF0samples.MSG
	dc.b	'samples                                      ',0
DF0pattern.MSG
	dc.b	'pattern                                      ',0
DF0macros.MSG
	dc.b	'macros                                       ',0
DF0routines.MSG
	dc.b	'routines                                     ',0
ascii.MSG4
	dc.b	'                    ',0,0
	even
ascii.MSG9
	dc.b	'                                            '
	dc.b	' ',0
ascii.MSG8
	dc.b	'                                            '
	dc.b	' ',0
ascii.MSG10
	dc.b	'                                            '
	dc.b	' ',0
ascii.MSG11
	dc.b	'                                            '
	dc.b	' ',0
ascii.MSG12
	dc.b	'                                            '
	dc.b	' ',0
consoledevice.MSG
	dc.b	'console.device',0
	dc.b	'trackdisk.device',0
setmaped.MSG
	dc.b	'setmap ed',0
setmapmenu.MSG
	dc.b	'setmap menu',0
OutOfMemoryAlert
	dc.b	0
	dcb.b	$2,15
	dc.b	'Tfmx-editor ran out of memory! Click mouse t'
	dc.b	'o Continue. No Guru Meditations!',0,0
EraseFileAlert
	dc.b	0
	dc.b	$1E
	dc.b	15
	dc.b	'Erase ____________________ from ___ ?   Left'
	dc.b	' = Yeah.  /  Right = Oh no !',0,0
EscapeEditorAlert
	dc.b	0
	dc.b	$1E
	dc.b	15
	dc.b	'Do you want to escape from tfmx-editor? Left'
	dc.b	' = Never! / Right = Pleazze',0,0
SpclStatementAlert
	dc.b	0
	dc.b	13
	dc.b	15
	dc.b	'There''s a special-statement in the selected'
	dc.b	' trackstep! Click mouse to cancel.',0,0
PattNotClearedAlert
	dc.b	0
	dc.b	'<'
	dc.b	15
	dc.b	'The Pattern, you selected, is not cleared. C'
	dc.b	'lick mouse to cancel.',0,0
WriteProtectedAlert
	dc.b	0
	dc.b	'#'
	dc.b	15
	dc.b	'You should not think, that this program can '
	dc.b	'write on a protected disc!',0
	dc.b	1
	dc.b	0
	dc.b	15
	dc.b	$1E
	dc.b	'Left = Retry',0
	dcb.b	$2,1
	dc.b	$E0
	dc.b	$1E
	dc.b	'Right = Forget it!',0,0
ValidatingAlert
	dc.b	0
	dc.b	'#'
	dc.b	15
	dc.b	'On the accessed disc is a validate in progre'
	dc.b	'ss. I can''t work on it !',0
	dc.b	1
	dc.b	0
	dc.b	15
	dc.b	$1E
	dc.b	'Left = Retry',0
	dcb.b	$2,1
	dc.b	$E0
	dc.b	$1E
	dc.b	'Right = Forget it!',0,0
NoDiscAlert
	dc.b	0
	dc.b	'('
	dc.b	15
	dc.b	'No disk in the accessed drive. Tell me, how '
	dc.b	'I should work with NO disc',0
	dc.b	1
	dc.b	0
	dc.b	15
	dc.b	$1E
	dc.b	'Left = Retry',0
	dcb.b	$2,1
	dc.b	$E0
	dc.b	$1E
	dc.b	'Right = Forget it!',0,0
DiscErrorAlert
	dc.b	0
	dc.b	'}'
	dc.b	15
	dc.b	'Warning !  The disc, you accessed has an err'
	dc.b	'or!',0
	dc.b	1
	dc.b	0
	dc.b	15
	dc.b	$1E
	dc.b	'Left = Retry',0
	dcb.b	$2,1
	dc.b	$E0
	dc.b	$1E
	dc.b	'Right = Forget it!',0,0
ConfirmClearAlert
	dc.b	0
	dc.b	'I'
	dc.b	15
	dc.b	'Click left button to use CLEAR Option , righ'
	dc.b	't button to CANCEL!',0,0
	dc.b	0
;	dc.b	'df0:',0
	even
lbL007AAE
	dc.l	topazfont.MSG
	dc.w	8
	dc.w	1
topazfont.MSG
	dc.b	'topaz.font',0
	even
lbL007AC2
	dc.l	TmpFileHandle

	bra	DrawGadgetList
	bra	ReadFile
	bra	WriteFile
	bra	lbC005C32
	bra	RenderStuff
	bra	ClearButton
	bra	DisplayAlert25
	bra	DrawActivePage
	bra	lbC000540
	bra	Draw2HexDigits
	bra	Draw1HexDigit
	bra	Draw4HexDigits
	bra	DrawChar
	bra	DrawString
	bra	Vsync
	bra	lbC0020E6
	bra	lbC0007C6
	bra	lbC005D46
	bra	lbC003C58
	bra	lbC005CE4


	dc.l	$10100110

TmpFileHandle
	dc.l	0
TmpMessage
	dc.l	0
_IntuitionBase
	dc.l	0
_GfxBase
	dc.l	0
_DosBase
	dc.l	0
WindowPtr
	dc.l	0
ViewPortPtr
	dc.l	0
PlanePtr0
	dc.l	0
PlanePtr1
	dc.l	0
PlanePtr2
	dc.l	0
PlanePtr3
	dc.l	0
lbL007B46
	dc.l	0
lbL007B4A
	dc.l	0
PictBuffer
	dc.l	0
MdatBuffer
	dc.l	0
SmplBuffer
	dc.l	0
InfoBuffer
	dc.l	0
RoutBuffer
	dc.l	0
lbL007B62
	dc.l	0
lbW007B66
	dc.w	0
CursorState
	dc.w	0
lbW007B6A
	dc.w	0
lbL007B6C
	dc.l	0
ActivePageNr
	dc.w	1
lbW007B72
	dc.w	0
PatternHitEnd
	dc.w	0
CurrentPattNum
	dc.w	0
lbW007B78
	dc.w	0
lbW007B7A
	dc.w	0
lbW007B7C
	dc.w	0
CurrentPageGList
	dc.l	0
MdatBufEndPtr
	dc.l	0
MacroHitEnd
	dc.w	0
CurrentMacroNum
	dc.b	0
lbB007B89
	dc.b	0
lbW007B8A
	dc.w	0
lbW007B8C
	dc.w	0
CurrentSongNum
	dc.w	0
lbL007B90
	dc.l	0
lbL007B94
	dc.l	0
lbL007B98
	dc.l	0
lbL007B9C
	dc.l	0
lbW007BA0
	dc.w	0
lbL007BA2
	dc.l	0
lbL007BA6
	dc.l	0
lbW007BAA
	dc.w	0
lbL007BAC
	dc.l	0
lbL007BB0
	dc.l	0
lbW007BB4
	dc.w	0
lbL007BB6
	dc.l	0
lbL007BBA
	dc.l	0
lbL007BBE
	dc.l	0
lbL007BC2
	dc.l	0
lbL007BC6
	dc.l	0
SmplBufEndPtr
	dc.l	0
PattLgLength
	dc.w	0
lbW007BD0
	dc.w	0
lbL007BD2
	dc.l	0
ButtonReptCtr
	dc.w	0
lbL007BD8
	dc.l	0
lbW007BDC
	dc.w	0
SaveSP
	dc.l	0
MacroCmdTablePtr
	dc.l	0
NoteNameTablePtr
	dc.l	0
PatternCmdTablePtr
	dc.l	0
MacroCmdNameCount
	dc.l	0
PlyrPatternBlock
	dc.l	0
lbW007BF6
	dc.w	0
RecordKeyuFlag
	dc.w	0
ILBMUnpackBuffer
	dc.b	0
lbB007BFB
	dc.b	0
lbB007BFC
	dc.b	0
lbB007BFD
	dc.b	0
lbW007BFE
	dc.w	1
lbL007C00
	dc.l	0
lbW007C04
	dc.w	0
lbL007C06
	dc.l	0
lbL007C0A
	dc.l	0
lbW007C0E
	dc.w	0
PlyrMasterBlock
	dc.l	0
lbB007C14
	dc.b	0
lbB007C15
	dc.b	1
PlyrInfoBlock
	dc.l	0
FstdFlag
	dc.w	1
MetronomeFlag
	dc.w	0
lbW007C1E
	dc.w	0
lbL007C20
	dc.l	0
lbL007C24
	dc.l	0
lbW007C28
	dc.w	1
CurrentDecalListPtr
	dc.l	0
PatArrowOldY
	dc.w	0
KeyGenericHook
	dc.l	0
KeyHexHook
	dc.l	0
KeyDownArrowHook
	dc.l	0
KeyUpArrowHook
	dc.l	0
KeyCutHook
	dc.l	lbC004FCC
KeyPasHook
	dc.l	lbC0050AC
KeyClrHook
	dc.l	AskClearTracks
lbL007C4C
	dc.l	lbC004F62
lbL007C50
	dc.l	lbC004F1A
lbL007C54
	dc.l	SetSongUp
lbL007C58
	dc.l	SetSongDn
lbL007C5C
	dc.l	lbC002014
SongCompressFlag
	dc.w	1
CurrentGadgetList
	dc.l	0
SampleRoutBuffer
	dc.l	0
lbL007C6A
	dc.l	0
	dc.l	KeyASCIIKeyCode
lbL007C72
	dc.l	0
lbW007C76
	dc.w	8
lbW007C78
	dc.w	0
lbW007C7A
	dc.w	8
lbW007C7C
	dc.w	0
lbL007C7E
	dc.l	0
TopazData
	dc.l	0
TopazModulo
	dc.w	0
lbW007C88
	dc.w	0
lbW007C8A
	dc.w	0
GlobalSigMask
	dc.l	0
PatternStepNumber
	dc.w	0
lbW007C92
	dc.w	0
lbW007C94
	dc.w	0
lbW007C96
	dc.w	0
lbL007C98
	dc.l	0
lbW007C9C
	dc.w	0
lbW007C9E
	dc.w	0
MacroNoteValue
	dc.b	$1B
MacroVolChanValue
	dc.b	$F0
CharXPos
	dc.b	0
CharYPos
	dc.b	0
lbB007CA4
	dc.b	6
lbB007CA5
	dc.b	6
PattLgLoopCtr
	dc.b	0
Defunct3SigBit
	dc.b	-1
Defunct2SigBit
	dc.b	-1
Defunct1SigBit
	dc.b	-1
MidiSigBit
	dc.b	-1
lbB007CAB
	dc.b	6,7,9,10,13,14,$10,$11,$14,$15,$17,$18,$1B,$1C
	dc.b	$1E,$1F,$22,$23,$25,$26,$29,$2A,$2C,$2D,$30,$31
	dc.b	$33,$34,$37,$38,$3A,$3B
lbB007CCB
	dc.b	9,10,$16,$17,$30,$34,$39,$3A
lbB007CD3
	dc.b	9,10
	dc.b	$35,$36,$37,$38,$39,$3A
lbB007CDB
	dc.b	6,7,8,9,10,11,12,13,14,15,$10,$11,$12,$13,$14,$15
	dc.b	$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21
	dc.b	$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D
	dc.b	$2E,$2F,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39
	dc.b	$3A,$3B
lbB007D11
	dc.b	$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$25
	dc.b	$26,$27,$28,$29,$2A,$2B,$2C,$2D
lbB007D25
	dc.b	8,9,10,$15,$16,$17,$2F,$30,$33,$34,$38,$39,$3A
lbB007D32
	dc.b	10,11,12,13,14,15,$10,$11,$12,$13,$14,$15,$16,$17
	dc.b	$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23
	dc.b	$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
	dc.b	$30,$31
lbB007D5A
	dc.b	5,6,7,9,10,12,13,14,$10,$11,$13,$14,$15,$17,$18
	dc.b	$1A,$1B,$1C,$1E,$1F,$21,$22,$23,$25,$26,$28,$29
	dc.b	$2A,$2C,$2D,$2F,$30,$31,$33,$34,$36,$37,$38,$3A
	dc.b	$3B
lbB007D82
	dc.b	$DE,$EB,$F3,$F8,$FB,$FD,$FE,$FF,1,2,3,5,8,13,$15
	dc.b	$22
lbB007D92
	dc.b	0
ScrapVar
	dc.b	0
	dc.b	$FF
	dcb.b	$2,6
	dc.b	'Dies ist die HELP-PAGE!!',0
ascii.MSG25
	dc.b	'    >>   >>>     >>>  >>                    '
	dc.b	'>> >>> >>>>  ',0
ascii.MSG26
	dc.b	'    >>>  >>                                 '
	dc.b	'      >      ',0
ascii.MSG21
	dc.b	'-------------------',0
ascii.MSG20
	dc.b	'                   ',0
TFMXEditorwas.MSG
	dc.b	$FF,2,8
	dc.b	'TFMX-Editor was developed 1988 to 1989 by A.U.D.I.O.S.'
	dc.b	$FF,2,9
	dc.b	'Editorprogramming by Peter W. Thierolf, concept, graphics'
	dc.b	$FF,2,10
	dc.b	'by Chris Huelsbeck, player by C. Huelsbeck and J. Hippel.'
	dc.b	$FF,2,11
	dc.b	'Enhancements and V37 fixes by Marx Marvelous/TPPI 1Mar95.'
;	dc.b	$FF,2,12
;	dc.b	'Watch out for other soundprograms written by A.U.D.I.O.S.'
	dc.b	$FF,$12,13
	dc.b	'(C) 1988,89 by Demonware.'
	dc.b	$FF,11,14
	dc.b	'Art Under Design, Imaginations Of Sound',0
HypHypHyp.MSG
	dc.b	'--- ',0
KUP.MSG
	dc.b	'KUP ',0
DirectoryErro.MSG
	dc.b	'Directory Error !'
Running.MSG
	dc.b	'Running.',0
TIMEOUT.MSG
	dc.b	'TIMEOUT!',0
Stop.MSG
	dc.b	'--Stop--',0
Youcantusethi.MSG
	dc.b	'You   >cant  >use   >this  >ptt.  >in the>easy- >page. ',0
ascii.MSG22
	dc.b	'..>>... ..>... ..>... ..>... ..>... ..>... ..>'
ascii.MSG24
	dc.b	'... ..>... ..',0
PleaseWait.MSG
	dc.b	$FF
	dc.b	$1A
	dc.b	4
	dc.b	'[    Please Wait   ]',0
Endl.MSG
	dc.b	$FF
	dc.b	'8'
	dc.b	4
	dc.b	'Endl',0
Err.MSG
	dc.b	$FF
	dc.b	'8'
	dc.b	4
	dc.b	'Err!',0
lbB008084
	dc.b	0
	dc.b	5
	dc.b	12
	dc.b	$13
	dc.b	$1A
	dc.b	$21
	dc.b	$28
	dc.b	$2F
	dc.b	$36
lbB00808D
	dc.b	9
	dc.b	6
	dc.b	9
	dc.b	10
	dc.b	0
	dc.b	4
	dc.b	0
	dc.b	5
	dc.b	7
lbW008096
	dc.w	$707
	dc.w	$700
	dc.w	$400
	dc.w	$700
	dcb.w	$3,0
	dc.b	0
lbB0080A5
	dc.b	9
	dc.b	6
	dc.b	9
	dc.b	10
	dc.b	0
	dc.b	4
	dc.b	0
	dc.b	5
	dcb.b	$4,7
	dc.b	0
	dc.b	4
	dc.b	0
	dc.b	7
	dcb.b	$8,0
RecordCursorLocations
	dc.b	$10,$23,$37,$10,$23,$37,$1A,$2C

	dc.b	6,6,6,10,10,10,2,2

	dc.b	0,0,1,0,0,1,1,1
	even

lbW0080D6
	dcb.w	$3,0
lbL0080DC
	dc.l	0,2,4,5,7,9,11
lbW0080F8
	dc.w	$20,8,2,5,$40
	dc.b	0
lbB008103
	dcb.b	$4,0
	dc.b	8
lbW008108
	dc.w	0
	dc.w	1
	dcb.w	$2,0
	dc.w	4
	dcb.w	$3,0
lbW008118
	dc.w	$C0
	dc.w	$20
	dc.w	15
	dc.w	$FF
	dc.w	$100
	dcb.w	$3,15
lbL008128
	dc.l	0
II.MSG0
	dc.b	'I'
II.MSG1
	dc.b	'I'
II.MSG2
	dc.b	'I'
II.MSG
	dc.b	'I'
I.MSG
	dc.b	'I',0
LongValue
	dc.l	0
	dc.w	0
	even

RedValues
	dc.l	$0000060B,$07040700,$020F0B0F,$06040C0F
;	dc.b	0,0,6,11,7,4,7,0,2,15,11,15,6,4,12,15
	dc.l	$29840376
GreenValues
	dc.l	$000F0D0B,$07040708,$05010008,$00000F0F
;	dc.b	0,15,13,11,7,4,7,8,5,1,0,8,0,0,15,15
	dc.l	$D2
BlueValues
	dc.l	$00000A0B,$07040F00,$0D010000,$0000000F
;	dc.b	0,0,10,11,7,4,15,0,13,1,0,0,0,0,0,15
	even
PlayRate7V
	dc.w	18
lbL008170
	dc.l	modprof.MSG
	dc.l	PictBuffer
PictSizeVal
	dc.l	$10E00
lbL00817C
	dc.l	songsmdatempt.MSG
	dc.l	MdatBuffer
	dc.l	$C800
	dc.l	ascii.MSG2
	dc.l	MdatBuffer
	dc.l	$C800
lbL008194
	dc.l	ascii.MSG2
	dc.l	MdatBuffer
	dc.l	0
lbL0081A0
	dc.l	ascii.MSG2
	dc.l	SmplBuffer
SmplSizeVal
	dc.l	SmplSize
lbL0081AC
	dc.l	routinesroutt.MSG
	dc.l	RoutBuffer
	dc.l	$A000
lbL0081B8
	dc.l	ascii.MSG2
	dc.l	SmplBuffer
	dc.l	0
lbL0081C4
	dc.l	ascii.MSG2
	dc.l	SmplBufEndPtr
	dc.l	0
lbL0081D0
	dc.l	ascii.MSG2
	dc.l	InfoBuffer
	dc.l	$3A98
lbL0081DC
	dc.l	ascii.MSG2
	dc.l	lbL007BD8
	dc.l	0
lbL0081E8
	dc.l	ascii.MSG2
	dc.l	RoutBuffer
	dc.l	$A000
lbL0081F4
	dc.l	ascii.MSG2
	dc.l	lbL007BD8
	dc.l	$20594
lbL008200
	dc.l	sampler.MSG
	dc.l	SampleRoutBuffer
	dc.l	$4E20
lbL00820C
	dc.l	ascii.MSG2
	dc.l	lbL007BD8
	dc.l	0
NewScreenRec
	dc.w	0,0
	dc.w	$280,$DC
	dc.w	$4
	dc.w	$900
	dc.l	$80000001
	dcb.l	$4,0
NewWindowRec
	dc.l	0
	dc.w	$280,$DC
	dc.l	0
	dc.l	$2080001
	dc.l	$18000000
	dcb.l	$2,0
	dc.w	0
ScreenPtr
	dc.l	0
	dc.l	0
	dc.l	$320032
	dc.l	$640064
	dc.w	1
TextYOffsetTable
	dc.l	0
	dc.l	$280
	dc.l	$500
	dc.l	$780
	dc.l	$A00
	dc.l	$C80
	dc.l	$F00
	dc.l	$1180
	dc.l	$1400
	dc.l	$1680
	dc.l	$1900
	dc.l	$1B80
	dc.l	$1E00
	dc.l	$2080
	dc.l	$2300
	dc.l	$2580
	dc.l	$2800
	dc.l	$2A80
	dc.l	$2D00
	dc.l	$2F80
	dc.l	$3200
	dc.l	$3480
	dc.l	$3700
	dc.l	$3980
	dc.l	$3C00
	dc.l	$3E80
	dc.l	$4100
ConReadPort
	dcb.l	$3,0
	dc.w	0
	dc.b	0
lbB0082E3
	dc.b	0
Misc2TaskPtr
	dcb.l	$4,0
Misc2MsgPort
	dcb.l	$8,0
ConsoleMsgPort
	dcb.l	$4,0
ConsoleTaskPtr
	dcb.l	$4,0
lbL008334
	dcb.l	$14,0
ConsoleIOReq
	dcb.l	$5,0
lbL008398
	dc.l	0
lbL00839C
	dcb.l	$3,0
lbL0083A8
	dc.l	0
ConsoleIOReqWindowPtr
	dcb.l	$7,0
lbL0083C8
	dc.l	0
lbL0083CC
	dcb.l	$6,0
KeyASCIIKeyCode
	dcb.l	$14,0

	cnop	0,4
DiskInfoBlock
	dcb.l	$104,0
LeftArrowImagery
	dc.b	%00010000
	dc.b	%00110000
	dc.b	%01110000
	dc.b	%11111111
	dc.b	%01110000
	dc.b	%00110000
	dc.b	%00010000
	dc.b	%00000000
RightArrowImagery
	dc.b	%00001000
	dc.b	%00001100
	dc.b	%00001110
	dc.b	%11111111
	dc.b	%00001110
	dc.b	%00001100
	dc.b	%00001000
	dc.b	%00000000
MainDecalList
	dc.l	$41B
	dc.l	$FFFFFF00
	dc.l	$20402
	dc.l	$FFFFFFFF
	dc.l	$20402
	dc.l	$FFFFFFFF
	dc.l	$20402
	dc.l	$FFFFFFFF
	dc.l	$2020402
	dc.l	$FFFFFFFF
	dc.l	$4020402
	dc.l	$FFFFFFFF
	dc.l	$6020402
	dc.l	$FFFFFFFF
	dc.l	$8020402
	dc.l	$FFFFFFFF
	dc.l	$A020402
	dc.l	$FFFFFFFF
	dc.l	$C020402
	dc.l	$FFFFFFFF
	dc.l	$E020402
	dc.l	$FFFFFFFF
	dc.l	$14020402
	dc.l	$FFFFFFFF
	dc.l	$12020402
	dc.l	$FFFFFFFF
	dc.l	$1A030205
	dc.l	$FFFF0000
	dc.l	$1E020208
	dc.l	$FFFFFF00
	dc.l	$40405
	dc.l	$FFFFFFFF
	dc.l	$7040408
	dc.l	$FFFFFF
	dc.l	$F040408
	dc.l	$FFFFFF00
	dc.l	$16040408
	dc.l	$FFFFFF
	dc.l	$1E040408
	dc.l	$FFFFFF00
	dc.l	$60406
	dc.l	$FFFFFFFF
	dc.l	$6060406
	dc.l	$FFFFFFFF
	dc.l	$C060406
	dc.l	$FFFFFFFF
	dc.l	$12060406
	dc.l	$FFFFFFFF
	dc.l	$80406
	dc.l	$FFFFFFFF
	dc.l	$6080406
	dc.l	$FFFFFFFF
	dc.l	$C080406
	dc.l	$FFFFFFFF
	dc.l	$12080406
	dc.l	$FFFFFFFF
	dc.l	$18060408
	dc.l	$FFFFFFFF
	dc.l	$20060408
	dc.l	$FFFFFFFF
	dc.l	$18080408
	dc.l	$FFFFFFFF
	dc.l	$20080408
	dc.l	$FFFFFFFF
	dc.l	$E0408
	dc.l	$FFFFFFFF
	dc.l	$80E0408
	dc.l	$FFFFFFFF
	dc.l	$100408
	dc.l	$FFFFFFFF
	dc.l	$8100408
	dc.l	$FFFFFFFF
	dc.l	$A041C
	dc.l	$FFFFFFFF
	dc.l	$C0404
	dc.l	$FFFFFF00
	dc.l	$40C0404
	dc.l	$FFFFFF00
	dc.l	$80C0404
	dc.l	$FFFFFF00
	dc.l	$C0C0404
	dc.l	$FFFFFF00
	dc.l	$100C0402
	dc.l	$FFFFFFFF
	dc.l	$120C0402
	dc.l	$FFFFFFFF
	dc.l	$240A0402
	dc.l	$FFFFFFFF
	dc.l	$260A0402
	dc.l	$FFFFFFFF
	dc.l	$10020402
	dc.l	$FFFFFFFF
	dc.l	$16020402
	dc.l	$FFFFFFFF
	dc.l	$18020402
	dc.l	$FFFFFFFF
	dc.l	$220C1001
	dc.l	$FF00FF00
	dc.l	$220C1003
	dc.l	$FFFFFFFF
	dc.l	$220C1001
	dc.l	$FFFFFFFF
	dc.l	$220C0402
	dc.l	$FFFFFFFF
	dc.l	$1C010203
	dc.l	$FFFFFF00
	dc.l	$220C0206
	dc.l	$FFFFFFFF
	dc.l	$120E0A02
	dc.l	$FFFFFFFF
	dc.l	$170D0203
	dc.l	$FFFFFFFF
	dc.l	$140D0203
	dc.l	$FFFFFFFF
	dc.l	$18021A
	dc.l	$FFFFFF00
	dc.l	$140E0403
	dc.l	$FFFFFFFF
	dc.l	$14100403
	dc.l	$FFFFFFFF
	dc.l	$170E0403
	dc.l	$FFFFFFFF
	dc.l	$17100403
	dc.l	$FFFFFFFF
	dc.l	$1A0D0403
	dc.l	$FFFFFFFF
	dc.l	$23170405
	dc.l	$FFFFFFFF
	dc.l	$17021F
	dc.l	$FFFFFF00
	dc.l	$18021B
	dc.l	$FFFFFF00
	dc.l	$18021F
	dc.l	$FFFFFF00
	dc.l	$1C0B0206
	dc.l	$FFFFFF00
	dc.l	$F170203
	dc.l	$FFFFFF00
	dc.l	$180203
	dc.l	$FFFFFFFF
	dc.l	$1D0D0202
	dc.l	$FFFFFFFF
	dc.l	$180201
	dc.l	$FFFFFF00
	dc.l	$16021F
	dc.l	$FFFFFF00
	dc.l	$1C000206
	dc.l	$FFFFFF00
	dc.l	$12130602
	dc.l	$FFFFFFFF
	dc.l	$8140208
	dc.l	$FFFFFF
	dc.l	$1E030203
	dc.l	$FFFFFFFF
	dc.l	$100E0402
	dc.l	$FFFFFFFF
	dc.l	$120408
	dc.l	$FFFFFFFF
	dc.l	$180210
	dc.l	$FFFFFF00
	dc.l	$230E1604
	dc.l	$FFFFFFFF
	dc.l	$230E1601
	dc.l	$FFFFFFFF
	dc.l	$230E1602
	dc.l	$FFFFFFFF
	dc.l	$8150206
	dc.l	$FF0000
	dc.l	$D150202
	dc.l	$FFFFFFFF
	dc.l	$18020A
	dc.l	$FFFFFFFF
	dc.l	$20101008
	dc.l	$FFFFFFFF
	dc.l	$20010206
	dc.l	$FFFFFF00
	dc.l	$140C0206
	dc.l	$FFFFFF00
	dc.l	$14130204
	dc.l	$FFFFFFFF
	dc.l	$22000205
	dc.l	$FFFFFF00
	dc.l	$25040403
	dc.l	$FFFFFF
	dc.l	$22020205
	dc.l	$FFFFFF00
	dc.l	$21030205
	dc.l	$FFFFFF00
	dc.l	$1A0C0205
	dc.l	$FFFFFFFF
	dc.l	$1C0A0205
	dc.l	$FFFFFFFF
	dc.l	$18020B
	dc.l	$FFFFFFFF
	dc.l	$180205
	dc.l	$FFFFFF00
	dc.l	$23100401
	dc.l	$FF00FF00
	dc.l	$23100401
	dc.l	$FFFFFFFF
	dc.l	$23100202
	dc.l	$FFFFFFFF
	dc.l	$12020404
	dc.l	$FFFFFFFF
	dc.l	$1C0B0204
	dc.l	$FFFFFFFF
	dc.l	$23100202
	dc.l	$FFFFFF00
	dc.l	$230E1601
	dc.l	$FF00FF00
	dc.l	$1A020206
	dc.l	$FFFFFFFF
	dc.l	$210A0403
	dc.l	$FFFFFF
	dc.l	$F150203
	dc.l	$FFFFFF00
	dc.l	$1A0F0403
	dc.l	$FFFFFFFF
	dc.l	$140403
	dc.l	$FFFFFFFF
	dc.l	$3140404
	dc.l	$FFFFFFFF
	dc.l	$8130207
	dc.l	$FFFFFFFF
	dc.l	$10100402
	dc.l	$FFFFFFFF
	dc.l	$8120208
	dc.l	$FFFFFFFF
	dc.l	$23100602
	dc.l	$FFFFFFFF
	dc.l	$1A110403
	dc.l	$FFFFFFFF
	dc.l	$180212
	dc.l	$FFFFFF00
	dc.l	$18020A
	dc.l	$FFFFFFFF
	dc.l	$7140202
	dc.l	$FFFFFF00
	dc.l	$1D0E0204
	dc.l	$FFFFFF00
	dc.l	$1D010202
	dc.l	$FFFFFFFF
	dc.l	$8120201
	dc.l	$FFFFFF00
	dc.l	$1D0F0403
	dc.l	$FFFFFFFF
	dc.l	$1D110402
	dc.l	$FFFFFFFF
	dc.l	$18120402
	dc.l	$FFFFFFFF
	dc.l	$10120202
	dc.l	$FFFFFFFF
	dc.l	$20020202
	dc.l	$FFFFFFFF
	dc.l	$F130203
	dc.l	$FFFFFFFF
	dc.l	$25030203
	dc.l	$FFFFFF
	dc.l	$19140404
	dc.l	$FFFFFF00
	dc.l	$1D140404
	dc.l	$FFFFFF00
	dc.l	$260A0402
	dc.l	$FFFFFFFF
	dc.l	$190402
	dc.l	$FFFFFFFF
	dc.l	$2190402
	dc.l	$FFFFFFFF
	dc.l	$4190406
	dc.l	$FFFFFFFF
	dc.l	$A190408
	dc.l	$FFFFFF00
	dc.l	$12190409
	dc.l	$FFFFFF00
	dc.l	$8000413
	dc.l	$FFFFFF
	dc.l	$4170202
	dc.l	$FFFFFFFF
	dc.l	$10120202
	dc.l	$FFFFFFFF
	dc.l	$5040403
	dc.l	$FFFFFF00
	dc.l	$8130204
	dc.l	$FFFFFFFF
	dc.l	$190404
	dc.l	$FFFFFFFF
	dc.l	$220C0C01
	dc.l	$FF00FF00
	dc.l	$16040404
	dc.l	$FF0000
	dc.l	$19040403
	dc.l	$FFFFFF00
	dc.l	$14120204
	dc.l	$FFFFFF00
	dc.l	$1A190403
	dc.l	$FFFF00
	dc.l	$1C190403
	dc.l	$FFFF00
	dc.l	$1B000201
	dc.l	$FFFFFFFF
	dc.l	$1B010201
	dc.l	$FFFFFFFF
	dc.l	$1F010201
	dc.l	$FFFFFFFF
	dc.l	$1E190403
	dc.l	$FFFF00
	dc.l	$20190403
	dc.l	$FFFF00
	dc.l	$180209
	dc.l	$FFFFFFFF
	dc.l	$22190403
	dc.l	$FFFF00
	dc.l	$24190403
	dc.l	$FFFF00
	dc.l	$17170203
	dc.l	$FF0000
	dc.l	$19170202
	dc.l	$FFFFFF
	dc.l	$14140405
	dc.l	$FFFFFF00
	dc.l	$1D110403
	dc.l	$FFFFFFFF
	dc.l	$180207
	dc.l	$FFFFFFFF
	dc.l	$180207
	dc.l	$FFFFFF00
	dc.l	$1A020201
	dc.l	$FF00FF00
	dc.l	$10120201
	dc.l	$FFFFFFFF
	dc.l	$1D0A0204
	dc.l	$00FF0000
	dc.l	$180217
	dc.l	$FFFFFFFF
MainGadgetList
	dc.l	$87F80000
	dc.l	$81000000
	dc.l	SetupHelpPage
	dc.l	0
	dc.l	$855000FE
	dc.l	$8109003D
	dc.l	SetupHelpPage
	dc.l	0
	dc.l	0
	dc.l	$100940
	dc.l	$81016208
	dc.l	$1110B41
	dc.l	MainPlayPrevTrackStep
	dc.l	0
	dc.l	$81C16228
	dc.l	$1110B41
	dc.l	MainBeQuiet
	dc.l	0
	dc.l	$81016260
	dc.l	$1110B41
	dc.l	MainPlayNextTrackStep
	dc.l	0
	dc.l	0
	dc.l	$110B41
	dc.l	0
	dc.l	$120D40
	dc.l	$83C1E208
	dc.l	$1130F41
	dc.l	lbC001268
	dc.l	4
	dc.l	$83022000
	dc.l	$81181100
	dc.l	lbC002194
	dc.l	0
	dc.l	$83026000
	dc.l	$81191300
	dc.l	lbC002194
	dc.l	3
	dc.l	$8302A000
	dc.l	$811A1500
	dc.l	lbC002194
	dc.l	4
	dc.l	$8302E000
	dc.l	$811B1700
	dc.l	lbC002194
	dc.l	2
	dc.l	$83022060
	dc.l	$8114110C
	dc.l	lbC002194
	dc.l	1
	dc.l	$83026060
	dc.l	$8115130C
	dc.l	lbC002194
	dc.l	5
	dc.l	$8302A060
	dc.l	$8116150C
	dc.l	lbC002194
	dc.l	6
	dc.l	$8302E060
	dc.l	$8117170C
	dc.l	lbC002194
	dc.l	7
	dc.l	$810220C0
	dc.l	$81031118
	dc.l	lbC003790
	dc.l	0
	dc.l	$810220E0
	dc.l	$8104111C
	dc.l	lbC003790
	dc.l	4
	dc.l	$810260C0
	dc.l	$81051318
	dc.l	lbC003790
	dc.l	8
	dc.l	$810260E0
	dc.l	$8106131C
	dc.l	lbC003790
	dc.l	12
	dc.l	$8102A0C0
	dc.l	$81071518
	dc.l	lbC003790
	dc.l	$10
	dc.l	$8102A0E0
	dc.l	$8108151C
	dc.l	lbC003790
	dc.l	$14
	dc.l	$8102E0C0
	dc.l	$812B1718
	dc.l	lbC003790
	dc.l	$18
	dc.l	0
	dc.l	$33171C
	dc.l	0
	dc.l	$A0035
	dc.l	0
	dc.l	$2D0039
	dc.l	$84022108
	dc.l	$811C1121
	dc.l	DrawActivePage
	dc.l	0
	dc.l	$84026108
	dc.l	$811D1321
	dc.l	DrawActivePage
	dc.l	1
	dc.l	$8402A108
	dc.l	$811E1521
	dc.l	DrawActivePage
	dc.l	2
	dc.l	$8402E108
	dc.l	$81221721
	dc.l	DrawActivePage
	dc.l	3
	dc.l	$840221B0
	dc.l	$811F1136
	dc.l	DrawActivePage
	dc.l	4
	dc.l	$840261B0
	dc.l	$81201336
	dc.l	DrawActivePage
	dc.l	5
	dc.l	$8402A1B0
	dc.l	$81211536
	dc.l	DrawActivePage
	dc.l	6
	dc.l	$8402E1B0
	dc.l	$81231736
	dc.l	DrawActivePage
	dc.l	7
	dc.l	0
	dc.l	$2A1131
	dc.l	0
	dc.l	$291331
	dc.l	0
	dc.l	$2A1531
	dc.l	0
	dc.l	$2A1731
	dc.l	0
	dc.l	$2A1146
	dc.l	0
	dc.l	$2A1346
	dc.l	0
	dc.l	$2A1546
	dc.l	0
	dc.l	$2A1746
	dc.l	0
	dc.l	$2A093D
	dc.l	0
	dc.l	$2A0B3D
	dc.l	0
	dc.l	$2A0D3D
	dc.l	0
	dc.l	$2A0F3D
	dc.l	0
	dc.l	$301120
	dc.l	0
	dc.l	$301135
	dc.l	0
	dc.l	$31114A
	dc.l	$81008210
	dc.l	$10B0442
	dc.l	SetSong1stStepUp
	dc.l	0
	dc.l	$8100E210
	dc.l	$10C0742
	dc.l	SetSong1stStepDn
	dc.l	0
	dc.l	$81008238
	dc.l	$10B0447
	dc.l	SetSongLastStepUp
	dc.l	0
	dc.l	$8100E238
	dc.l	$10C0747
	dc.l	SetSongLastStepDn
	dc.l	0
	dc.l	$81008260
	dc.l	$10B044C
	dc.l	SetSongSpeedUp
	dc.l	0
	dc.l	$8100E260
	dc.l	$10C074C
	dc.l	SetSongSpeedDn
	dc.l	0
	dc.l	$81002210
	dc.l	$10C0142
	dc.l	SetSongDn
	dc.l	0
	dc.l	$81002260
	dc.l	$10B014C
	dc.l	SetSongUp
	dc.l	0
	dc.l	0
	dc.l	$30014B
	dc.l	0
	dc.l	$300146
	dc.l	$8141A258
	dc.l	$81300141
	dc.l	lbC001ABC
	dc.l	0
	dc.l	$8141A208
	dc.l	$81000000
	dc.l	lbC0019E4
	dc.l	0
	dc.l	$8141A230
	dc.l	$81000000
	dc.l	lbC001A5E
	dc.l	0
	dc.l	$C100C1E8
	dc.l	$814A063D
	dc.l	lbC001BA4
	dc.l	0
	dc.l	0
	dc.l	$4C0146
	dc.l	0
	dc.l	$4B0340
	dc.l	0
	dc.l	$570041
	dc.l	0
	dc.l	$FFFF0000
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
TrackGadgetList
	dc.l	$8101E040
	dc.l	$83260F05
	dc.l	1
	dc.l	$F05
	dc.l	$8101E078
	dc.l	$83260F0C
	dc.l	2
	dc.l	$F0C
	dc.l	$8101E0B0
	dc.l	$83260F13
	dc.l	3
	dc.l	$F13
	dc.l	$8101E0E8
	dc.l	$83260F1A
	dc.l	4
	dc.l	$F1A
	dc.l	$8101E120
	dc.l	$83260F21
	dc.l	5
	dc.l	$F21
	dc.l	$8101E158
	dc.l	$83260F28
	dc.l	6
	dc.l	$F28
	dc.l	$8101E190
	dc.l	$83260F2F
	dc.l	7
	dc.l	$F2F
	dc.l	$8101E1C8
	dc.l	$83260F36
	dc.l	8
	dc.l	$F36
	dc.l	$FFF8E830
	dc.l	$81240405
	dc.l	lbC0026A4
	dc.l	0
	dc.l	$81004040
	dc.l	$82280205
	dc.l	0
	dc.l	5
	dc.l	$81004078
	dc.l	$8228020C
	dc.l	2
	dc.l	12
	dc.l	$810040B0
	dc.l	$82280213
	dc.l	4
	dc.l	$13
	dc.l	$810040E8
	dc.l	$8228021A
	dc.l	6
	dc.l	$1A
	dc.l	$81004120
	dc.l	$82280221
	dc.l	8
	dc.l	$21
	dc.l	$81004158
	dc.l	$82280228
	dc.l	10
	dc.l	$28
	dc.l	$81004190
	dc.l	$8228022F
	dc.l	12
	dc.l	$2F
	dc.l	$810041C8
	dc.l	$82280236
	dc.l	14
	dc.l	$36
	dc.l	$81C08028
	dc.l	$810D0604
	dc.l	lbC00117E
	dc.l	0
	dc.l	$81C08060
	dc.l	$810D060B
	dc.l	lbC00117E
	dc.l	4
	dc.l	$81C08098
	dc.l	$810D0612
	dc.l	lbC00117E
	dc.l	8
	dc.l	$81C080D0
	dc.l	$810D0619
	dc.l	lbC00117E
	dc.l	12
	dc.l	$81C08108
	dc.l	$810D0620
	dc.l	lbC00117E
	dc.l	$10
	dc.l	$81C08140
	dc.l	$810D0627
	dc.l	lbC00117E
	dc.l	$14
	dc.l	$81C08178
	dc.l	$810D062E
	dc.l	lbC00117E
	dc.l	$18
	dc.l	$81C081B0
	dc.l	$810D0635
	dc.l	lbC00117E
	dc.l	$1C
	dc.l	$FD88E92F
	dc.l	$81300705
	dc.l	lbC0026A4
	dc.l	0
	dc.l	$FFF96430
	dc.l	$8132070B
	dc.l	lbC0026A4
	dc.l	0
	dc.l	$FD89652F
	dc.l	$81340600
	dc.l	lbC0026A4
	dc.l	0
	dc.l	0
	dc.l	$330F01
	dc.l	0
	dc.l	$320712
	dc.l	0
	dc.l	$320719
	dc.l	0
	dc.l	$320720
	dc.l	0
	dc.l	$320727
	dc.l	0
	dc.l	$32072E
	dc.l	0
	dc.l	$320735
	dc.l	$81004008
	dc.l	$10B0201
	dc.l	lbC001984
	dc.l	0
	dc.l	$81008008
	dc.l	$10C0401
	dc.l	lbC0019AC
	dc.l	0
	dc.l	0
	dc.l	$300200
	dc.l	0
	dc.l	$300900
	dc.l	$810001E8
	dc.l	$8130073C
	dc.l	AskClearTracks
	dc.l	0
	dc.l	$810041E8
	dc.l	$12E023D
	dc.l	lbC004F1A
	dc.l	0
	dc.l	$810081E8
	dc.l	$12F043D
	dc.l	lbC004F62
	dc.l	0
	dc.l	$810001C8
	dc.l	$812E023D
	dc.l	lbC0050AC
	dc.l	0
	dc.l	$810001A8
	dc.l	$842E023D
	dc.l	lbC004FCC
	dc.l	0
	dc.l	0
	dc.w	$FFFF
PattGadgetList
	dc.l	$8101E000
	dc.l	$10C0F00
	dc.l	PattSetPattDown
	dc.l	0
	dc.l	$8101E020
	dc.l	$10B0F04
	dc.l	PattSetPattUp
	dc.l	0
	dc.l	$FFF8E830
	dc.l	$81320700
	dc.l	lbC0026B8
	dc.l	0
	dc.l	$FD88E94A
	dc.l	$81320706
	dc.l	lbC0026B8
	dc.l	0
	dc.l	$FFF96430
	dc.l	$8130070C
	dc.l	lbC0026B8
	dc.l	0
	dc.l	$FD89654A
	dc.l	$81320713
	dc.l	lbC0026B8
	dc.l	0
	dc.l	0
	dc.l	$300719
	dc.l	0
	dc.l	$30072E
	dc.l	0
	dc.l	$300732
	dc.l	0
	dc.l	$320736
	dc.l	$810001E8
	dc.l	$8130073C
	dc.l	lbC006652
	dc.l	0
	dc.l	$810041E8
	dc.l	$1000000
	dc.l	PattDrawInsertPattLine
	dc.l	0
	dc.l	$810081E8
	dc.l	$1000000
	dc.l	PattDrawDeletePattLine
	dc.l	0
	dc.l	$810001C8
	dc.l	$812E023D
	dc.l	lbC005328
	dc.l	0
	dc.l	$810001A8
	dc.l	$842E023D
	dc.l	lbC005256
	dc.l	0
	dc.l	0
	dc.l	$400600
	dc.l	0
	dc.l	$410F08
	dc.l	$47FA0040
	dc.l	$8147100C
	dc.l	lbC00275C
	dc.l	0
	dc.l	0
	dc.l	$630F13
	dc.l	0
	dc.l	$471019
	dc.l	0
	dc.l	$47102E
	dc.l	0
	dc.l	$471032
	dc.l	0
	dc.l	$630F36
	dc.l	0
	dc.l	$47103C
	dc.l	0
	dc.l	$420500
	dc.l	$450080D0
	dc.l	$1430400
	dc.l	lbC001CE2
	dc.l	0
	dc.l	0
	dc.l	$420300
	dc.l	0
	dc.l	$420200
	dc.l	0
	dc.l	$440415
	dc.l	0
	dc.l	$45040F
	dc.l	0
	dc.l	$45042E
	dc.l	0
	dc.l	$460434
	dc.l	0
	dc.l	$47043C
	dc.l	0
	dc.w	$FFFF
MacroGadgetList
	dc.l	$8101E000
	dc.l	$10C0F00
	dc.l	lbC005C22
	dc.l	0
	dc.l	$8101E020
	dc.l	$10B0F04
	dc.l	lbC005BD8
	dc.l	0
	dc.l	$810041E8
	dc.l	$1000000
	dc.l	MacrDrawInsertMacroLine
	dc.l	0
	dc.l	$810081E8
	dc.l	$1000000
	dc.l	MacrDrawDeleteMacroLine
	dc.l	0
	dc.l	$FFF8E830
	dc.l	$81320700
	dc.l	lbC0026CE
	dc.l	0
	dc.l	$FD88E94A
	dc.l	$81320706
	dc.l	lbC0026CE
	dc.l	0
	dc.l	$FFF96430
	dc.l	$8130070C
	dc.l	lbC0026CE
	dc.l	0
	dc.l	$FD89654A
	dc.l	$81300734
	dc.l	lbC0026CE
	dc.l	0
	dc.l	$810001E8
	dc.l	$8132073B
	dc.l	lbC0066AE
	dc.l	0
	dc.l	$810001C8
	dc.l	$812E023D
	dc.l	lbC0051DA
	dc.l	0
	dc.l	$810001A8
	dc.l	$842E023D
	dc.l	lbC005108
	dc.l	0

	dc.l	0
	dc.l	$A20F08

	dc.l	$8181E1B8
	dc.l	$81730F37
	dc.l	lbC002C08
	dc.l	0

	dc.l	$8181E198
	dc.l	$010B0F33
	dc.l	MacroNoteSetter
	dc.l	1

	dc.l	0
	dc.l	$00640F2F

	dc.l	$8181E158
	dc.l	$010C0F2B
	dc.l	MacroNoteSetter
	dc.l	-1

	dc.l	$8181E138
	dc.l	$010B0F27
	dc.l	MacroVolumeSetter
	dc.l	$10

	dc.l	0
	dc.l	$9D0F23

	dc.l	$8181E100
	dc.l	$010C0F20
	dc.l	MacroVolumeSetter
	dc.l	-$10

	dc.l	$8181E0E0
	dc.l	$010B0F1C
	dc.l	MacroChanSetter
	dc.l	$1

	dc.l	0
	dc.l	$9E0F18

	dc.l	$8181E0A8
	dc.l	$010C0F15
	dc.l	MacroChanSetter
	dc.l	-1

	dc.l	0
	dc.l	$A21008
	dc.l	0
	dc.l	$480600
	dc.l	0
	dc.l	$420500
	dc.l	0
	dc.l	$420300
	dc.l	0
	dc.l	$420200
	dc.l	0
	dc.l	$490400
	dc.l	0
	dc.l	$45040F
	dc.l	0
	dc.l	$440415
	dc.l	0
	dc.l	$35042E

	dc.l	$450080D0
	dc.l	$81450437
	dc.l	lbC001E26
	dc.l	0

	dc.l	0
	dc.w	$FFFF
	dc.l	0
	dc.l	0
FselGadgetList
	dc.l	0
	dc.l	$300905
	dc.l	0
	dc.l	$300300
	dc.l	$47F9E030
	dc.l	$81391000
	dc.l	lbC002F44
	dc.l	0
	dc.l	$4341E130
	dc.l	$81300305
	dc.l	lbC002F44
	dc.l	0
	dc.l	$47F9A030
	dc.l	$81390200
	dc.l	lbC002F60
	dc.l	0
	dc.l	$4341A130
	dc.l	$81390C00
	dc.l	lbC002F60
	dc.l	0
	dc.l	0
	dc.l	$390E00
	dc.l	$81006008
	dc.l	$10B0301
	dc.l	lbC00437E
	dc.l	0
	dc.l	$81014008
	dc.l	$10C0A01
	dc.l	lbC004352
	dc.l	0
	dc.l	$F100A008
	dc.l	$81360501
	dc.l	lbC00375E
	dc.l	0
	dc.l	$51011808
	dc.l	$81370F00
	dc.l	lbC00375E
	dc.l	0
	dc.l	$FFF86030
	dc.l	$1380D00
	dc.l	lbC003638
	dc.l	0
	dc.l	$FB48612F
	dc.l	$13A0737
	dc.l	lbC003638
	dc.l	0
	dc.l	$FFF8D830
	dc.l	$13B0937
	dc.l	lbC003638
	dc.l	0
	dc.l	$FB48D92F
	dc.l	$13C0B37
	dc.l	lbC003638
	dc.l	0
	dc.l	$6FF95030
	dc.l	$13D0D37
	dc.l	lbC003638
	dc.l	0
	dc.l	$6B49512F
	dc.l	$1450637
	dc.l	lbC003638
	dc.l	0
	dc.l	$81404198
	dc.l	$810F0233
	dc.l	lbC00112A
	dc.l	0
	dc.l	$814041C0
	dc.l	$81450633
	dc.l	lbC000FCE
	dc.l	0
lbL00973E
	dc.l	$818081B8
	dc.l	$81290433
	dc.l	lbC0055AA
	dc.l	0
	dc.l	0
	dc.l	$6C0437
	dc.l	0
	dc.l	$7C0F33
	dc.l	$8181E1B8
	dc.l	$817A0F37
	dc.l	FselChangeCompFlag
	dc.l	0
lbL00976E
	dc.l	$8180E1B8
	dc.l	$81290733
	dc.l	lbC0031B6
	dc.l	1
	dc.l	$818121B8
	dc.l	$812A0933
	dc.l	lbC0031B6
	dc.l	0
	dc.l	$818161B8
	dc.l	$812A0B33
	dc.l	lbC0031B6
	dc.l	2
	dc.l	$8181A1B8
	dc.l	$812A0D33
	dc.l	lbC0031B6
	dc.l	3
	dc.l	0
	dc.l	$470B00
	dc.l	0
	dc.w	$FFFF
SmpLstGadgetList
	dc.l	$8101E000
	dc.l	$10C0F00
	dc.l	lbC005992
	dc.l	0
	dc.l	$8101E020
	dc.l	$10B0F04
	dc.l	lbC0059BA
	dc.l	0
	dc.l	$8181E040
	dc.l	$13E0F08
	dc.l	lbC00560A
	dc.l	0
	dc.l	$8181E070
	dc.l	$81A00F0E
	dc.l	lbC002FBA
	dc.l	0
	dc.l	$8401E0A0
	dc.l	$814E0F14
	dc.l	lbC0057DC
	dc.l	0
	dc.l	0
	dc.l	$420200
	dc.l	0
	dc.l	$420E00
	dc.l	$8101E120
	dc.l	$40C0F24
	dc.l	lbC003074
	dc.l	$FFFFFFFF
	dc.l	$8101E158
	dc.l	$40B0F2B
	dc.l	lbC003074
	dc.l	1
	dc.l	$FFF88020
	dc.l	$81761028
	dc.l	lbC0026E4
	dc.l	0
	dc.l	$FD88811F
	dc.l	$81A10F2F
	dc.l	lbC0026E4
	dc.l	0
	dc.l	$FFF8FC20
	dc.l	$81A1102F
	dc.l	lbC0026E4
	dc.l	0
	dc.l	$FD88FD1F
	dc.l	$81500335
	dc.l	lbC0026E4
	dc.l	0
	dc.l	$A7F97820
	dc.l	$81460331
	dc.l	lbC0026E4
	dc.l	0
	dc.l	$A589791F
	dc.l	$81460325
	dc.l	lbC0026E4
	dc.l	0
	dc.l	0
	dc.l	$340303
	dc.l	0
	dc.l	$37030A
	dc.l	0
	dc.l	$510308
	dc.l	0
	dc.l	$520300
	dc.l	0
	dc.l	$510323
	dc.l	0
	dc.l	$68031D
	dc.l	0
	dc.l	$680329
	dc.l	0
	dc.l	$47032E
	dc.l	0
	dc.l	$51032F
	dc.l	0
	dc.l	$350310
	dc.l	0
	dc.l	$53031A
	dc.l	0
	dc.l	$54032A
	dc.l	0
	dc.w	$FFFF
RecordGadgetList
	dc.l	0
	dc.l	$450200
	dc.l	0
	dc.l	$580206
	dc.l	0
	dc.l	$590211
	dc.l	0
	dc.l	$45021C
	dc.l	0
	dc.l	$5A0222
	dc.l	0
	dc.l	$35022E
	dc.l	0
	dc.l	$350231
	dc.l	$810060B0
	dc.l	$10C0316
	dc.l	lbC003568
	dc.l	12
	dc.l	$810060D8
	dc.l	$10B031B
	dc.l	lbC003544
	dc.l	12
	dc.l	$81006140
	dc.l	$10C0328
	dc.l	lbC003568
	dc.l	14
	dc.l	$81006168
	dc.l	$10B032D
	dc.l	lbC003544
	dc.l	14
	dc.l	0
	dc.l	$600400
	dc.l	0
	dc.l	$600300
	dc.l	0
	dc.l	$61031F
	dc.l	0
	dc.l	$61041F
	dc.l	0
	dc.l	$630331
	dc.l	$814061B8
	dc.l	$812A0333
	dc.l	lbC00119C
	dc.l	0
	dc.l	0
	dc.l	$5B0336
	dc.l	0
	dc.l	$62033C
	dc.l	0
	dc.l	$62032C
	dc.l	0
	dc.l	$62031A
	dc.l	0
	dc.l	$420500
	dc.l	0
	dc.l	$450600
	dc.l	0
	dc.l	$5C0606
	dc.l	0
	dc.l	$450613
	dc.l	0
	dc.l	$5D0619
	dc.l	0
	dc.l	$450626
	dc.l	0
	dc.l	$5E062C
	dc.l	0
	dc.l	$640639
	dc.l	0
	dc.l	$3F0700
	dc.l	0
	dc.l	$3F0703
	dc.l	$8100E068
	dc.l	$165070D
	dc.l	lbC003568
	dc.l	0
	dc.l	$8100E088
	dc.l	$13F0715
	dc.l	lbC003544
	dc.l	0
	dc.l	0
	dc.l	$62071F
	dc.l	$8100E100
	dc.l	$1650720
	dc.l	lbC003568
	dc.l	2
	dc.l	$8100E120
	dc.l	$13F0728
	dc.l	lbC003544
	dc.l	2
	dc.l	0
	dc.l	$620732
	dc.l	$8100E198
	dc.l	$10C0733
	dc.l	lbC003568
	dc.l	4
	dc.l	0
	dc.l	$620737
	dc.l	$8100E1C0
	dc.l	$10B0738
	dc.l	lbC003544
	dc.l	4
	dc.l	0
	dc.l	$30073C
	dc.l	0
	dc.l	$420900
	dc.l	0
	dc.l	$450A00
	dc.l	0
	dc.l	$5F0A06
	dc.l	0
	dc.l	$670A13
	dc.l	0
	dc.l	$660A16
	dc.l	0
	dc.l	$460A1E
	dc.l	0
	dc.l	$450A26
	dc.l	0
	dc.l	$640A2A
	dc.l	0
	dc.l	$590A2E
	dc.l	0
	dc.l	$640A39
	dc.l	0
	dc.l	$3F0B00
	dc.l	0
	dc.l	$3F0B03
	dc.l	$81016068
	dc.l	$1650B0D
	dc.l	lbC003568
	dc.l	6
	dc.l	$81016088
	dc.l	$13F0B15
	dc.l	lbC003544
	dc.l	6
	dc.l	0
	dc.l	$620B1F
	dc.l	$81016100
	dc.l	$1650B20
	dc.l	lbC003568
	dc.l	8
	dc.l	$81016120
	dc.l	$13F0B28
	dc.l	lbC003544
	dc.l	8
	dc.l	0
	dc.l	$620B32
	dc.l	$81016198
	dc.l	$10C0B33
	dc.l	lbC003568
	dc.l	10
	dc.l	$810161C0
	dc.l	$1620B37
	dc.l	lbC003544
	dc.l	10
	dc.l	0
	dc.l	$B0B38
	dc.l	0
	dc.l	$420D00
	dc.l	0
	dc.l	$6A0F36
	dc.l	$8141E1B8
	dc.l	$812A0F33
	dc.l	lbC001202
	dc.l	0
	dc.l	0
	dc.l	$3F0E00
	dc.l	0
	dc.l	$3F0F00
	dc.l	0
	dc.l	$620E0A
	dc.l	0
	dc.l	$47100A
	dc.l	0
	dc.l	$690E0B
	dc.l	$8101E058
	dc.l	$10C0F0B
	dc.l	lbC002C68
	dc.l	$FFFFFFFF
	dc.l	$8101E098
	dc.l	$10B0F13
	dc.l	lbC002C68
	dc.l	1
	dc.l	0
	dc.l	$64100F
	dc.l	0
	dc.l	$601017
	dc.l	0
	dc.l	$3F0E17
	dc.l	0
	dc.l	$6B0E21
	dc.l	0
	dc.l	$600E26
	dc.l	0
	dc.l	$3F0F29
	dc.l	0
	dc.l	$640F26
	dc.l	0
	dc.l	$620F3C
	dc.l	0
	dc.w	$FFFF
HelpGadgetList
	dc.l	0
	dc.l	$420200
	dc.l	0
	dc.l	$A6030F
	dc.l	$81806010
	dc.l	$810C0302
	dc.l	HelpRateSetter
	dc.l	-1
	dc.l	$81806058
	dc.l	$810B030B
	dc.l	HelpRateSetter
	dc.l	1
	dc.l	0
	dc.l	$A30408
	dc.l	0
	dc.l	$A40409
	dc.l	0
	dc.l	$A50305
	dc.l	0
	dc.l	$510400
	dc.l	0
	dc.l	$510300
	dc.l	0
	dc.l	$51043B
FstdButtonImage	=	*+5
	dc.l	$8180A030
	dc.l	$81290502
	dc.l	HelpToggleFlags
	dc.l	0
	dc.l	0
	dc.l	$6D0506
lbL009C80
	dc.l	$8200A080
	dc.l	$812A050C
	dc.l	HelpToggleFlags
	dc.l	2
	dc.l	0
	dc.l	$6E0510
	dc.l	0
	dc.l	$6F042D
	dc.l	0
	dc.l	$71041D
	dc.l	0
	dc.l	$420700
	dc.l	0
	dc.l	$700524
	dc.l	0
	dc.l	$620528
	dc.l	0
	dc.l	$62052D
	dc.l	0
	dc.l	$620534
	dc.l	0
	dc.l	$720418
	dc.l	0
	dc.l	$61040F
	dc.l	0
	dc.l	$47041C
	dc.l	0
	dc.l	$61061B
	dc.l	0
	dc.l	$420F00
	dc.l	0
	dc.l	$421000
	dc.l	0
	dc.w	$FFFF
IntroGadgetList
	dc.l	0
	dc.l	$420200
	dc.l	0
	dc.l	$420300
	dc.l	0
	dc.l	$420400
	dc.l	0
	dc.l	$420500
	dc.l	0
	dc.l	$420600
	dc.l	0
	dc.l	$500400
	dc.l	0
	dc.l	$510408
	dc.l	0
	dc.l	$500435
	dc.l	0
	dc.l	$520432
	dc.l	0
	dc.l	$420D00
	dc.l	0
	dc.l	$420E00
	dc.l	0
	dc.l	$420F00
	dc.l	0
	dc.l	$421000
	dc.l	0
	dc.w	$FFFF
EasyGadgetList
	dc.l	$450080D0
	dc.l	$1430400
	dc.l	lbC001D84
	dcb.l	$2,0
	dc.l	$440415
	dc.l	0
	dc.l	$45040F
	dc.l	0
	dc.l	$45042E
	dc.l	0
	dc.l	$610434
	dc.l	0
	dc.l	$420300
	dc.l	0
	dc.l	$420200
	dc.l	0
	dc.l	$420500
	dc.l	0
	dc.l	$9A0F08
	dc.l	0
	dc.l	$9A1008

	dc.l	$8101E1C8
	dc.l	$19B0F38
	dc.l	EasyToggleTimeSig
	dc.l	0

	dc.l	$8101E170
	dc.l	$10C0F2E
	dc.l	EasySetVolChn
	dc.l	$FFFF

	dc.l	0
	dc.l	$9D0F31

	dc.l	$8101E1A8
	dc.l	$10B0F35
	dc.l	EasySetVolChn
	dc.l	1

	dc.l	$8101E118
	dc.l	$10C0F23
	dc.l	EasySetVolChn
	dc.l	$2FFFF

	dc.l	0
	dc.l	$9E0F26

	dc.l	$8101E150
	dc.l	$10B0F2A
	dc.l	EasySetVolChn
	dc.l	$20001

	dc.l	$8241E0D0
	dc.l	$19F0F1A
	dc.l	EasyOptimizePatt
	dc.l	0
	dc.l	0
	dc.l	$770605
	dc.l	0
	dc.l	$77060C
	dc.l	0
	dc.l	$770613
	dc.l	0
	dc.l	$77061A
	dc.l	0
	dc.l	$770621
	dc.l	0
	dc.l	$770628
	dc.l	0
	dc.l	$77062F
	dc.l	0
	dc.l	$770636
	dc.l	0
	dc.l	$780601
	dc.l	0
	dc.l	$790600
	dc.l	$8101E000
	dc.l	$81650F00
	dc.l	lbC0062AC
	dc.l	$FFFFFFFF
	dc.l	$8101E020
	dc.l	$81300700
	dc.l	lbC0062AC
	dc.l	1
	dc.l	0
	dc.l	$320703
	dc.l	0
	dc.l	$30070B
	dc.l	0
	dc.l	$300712
	dc.l	0
	dc.l	$300719
	dc.l	0
	dc.l	$300720
	dc.l	0
	dc.l	$300727
	dc.l	0
	dc.l	$30072E
	dc.l	0
	dc.l	$300735
	dc.l	0
	dc.l	$30073C
	dc.l	0
	dc.w	$FFFF
	dc.w	0
lbL009F04
	dcb.l	$200,0
lbL00A704
	dcb.l	$80,0
PattTmpBuffer
	dcb.l	$200,0

	section	bss_c,bss_c
ChipBuffer
	ds.l	512
