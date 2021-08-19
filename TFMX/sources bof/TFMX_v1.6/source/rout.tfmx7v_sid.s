	opt	o-,d-
TfmxFileBase	=	*-$20

	bra	NULL
	bra	IRQIN
	bra	ALLOFF
	bra	SONGPLAY

	bra	NOTEPORT
	bra	INITDATA
	bra	VBION
	bra	VBIOFF

	bra	CHANNELOFF
	bra	XPLAYNOQUIET
	bra	FADE
	bra	INFO

	bra	XINFO
	bra	ALLOFF		playpatt1
	bra	ALLOFF		playpatt2
	bra	PROSFX

	bra	PLAYCONT
	bra	NULL		record
	bra	NULL		record2
	bra	NULL

	bra	XSETRECORD	setrecord
	bra	ALLOFF
	bra	ALLOFF
	bra	ALLOFF

	bra	PLAYSPEED

mdb_LongStore	=	12
mdb_SmplBase	=	4

cdb_AddBeginTime =	3
cdb_CurAddr	=	$2C
cdb_CurrLength	=	$34

cdb_SIDSrcSample	=	$64
cdb_SIDSrcLength	=	$68
cdb_SIDSize		=	$6A
cdb_SIDVib2Ofs		=	$6C

cdb_SIDVib2Time		=	$70
cdb_SIDVib2Reset	=	$72
cdb_SIDVib2Width	=	$74
cdb_SIDFilterTC		=	$76
cdb_SIDVibOfs		=	$78
cdb_SIDFilterTime	=	$7C
cdb_SIDFilterReset	=	$7E

cdb_SIDFilterWidth	=	$80
cdb_SIDVibWidth		=	$82
cdb_SIDVibTime		=	$84
cdb_SIDVibReset		=	$86
cdb_WorkBase		=	$88
cdb_SIDSaveState	=	$8C

MacroNamesTable
	dc.l	MacrDMAOffMsg-TfmxFileBase
	dc.l	MacrDMAOnMsg-TfmxFileBase
	dc.l	MacrSetBeginMsg-TfmxFileBase
	dc.l	MacrSetLenMsg-TfmxFileBase

	dc.l	MacrWaitMsg-TfmxFileBase
	dc.l	MacrLoopMsg-TfmxFileBase
	dc.l	MacrContMsg-TfmxFileBase
	dc.l	MacrSTOPMsg-TfmxFileBase

	dc.l	MacrAddNoteMsg-TfmxFileBase
	dc.l	MacrSetNoteMsg-TfmxFileBase
	dc.l	MacrResetVPEMsg-TfmxFileBase
	dc.l	MacrPortaMsg-TfmxFileBase

	dc.l	MacrVibratoMsg-TfmxFileBase
	dc.l	MacrAddVolMsg-TfmxFileBase
	dc.l	MacrSetVolMsg-TfmxFileBase
	dc.l	MacrEnvelopeMsg-TfmxFileBase

	dc.l	MacrLoopKUpMsg-TfmxFileBase
	dc.l	MacrAddBeginMsg-TfmxFileBase
	dc.l	MacrAddLenMsg-TfmxFileBase
	dc.l	MacrDMAOffNoClrMsg-TfmxFileBase

	dc.l	MacrWaitKUpMsg-TfmxFileBase
	dc.l	MacrGosubMsg-TfmxFileBase
	dc.l	MacrReturnMsg-TfmxFileBase
	dc.l	MacrSetPerMsg-TfmxFileBase

	dc.l	MacrSampleLoopMsg-TfmxFileBase
	dc.l	MacrOneShotMsg-TfmxFileBase
	dc.l	MacrWaitDMAMsg-TfmxFileBase
	dc.l	MacrNoEntry0Msg-TfmxFileBase

	dc.l	MacrSplitkeyMsg-TfmxFileBase
	dc.l	MacrSplitvolMsg-TfmxFileBase
	dc.l	MacrNoEntry0Msg-TfmxFileBase
	dc.l	MacrSetPrevNoteMsg-TfmxFileBase

	dc.l	MacrCueMsg-TfmxFileBase
	dc.l	MacrPlayMacroMsg-TfmxFileBase
	dc.l	MacrSIDSampleMsg-TfmxFileBase
	dc.l	MacrSIDLengthMsg-TfmxFileBase

	dc.l	MacrSID2OfsMsg-TfmxFileBase
	dc.l	MacrSID2VibMsg-TfmxFileBase
	dc.l	MacrSID1OfsMsg-TfmxFileBase
	dc.l	MacrSID1VibMsg-TfmxFileBase

	dc.l	MacrSIDFilterMsg-TfmxFileBase
	dc.l	MacrSIDStopMsg-TfmxFileBase
	dc.l	MacrNoEntry0Msg-TfmxFileBase
	dc.l	MacrNoEntry1Msg-TfmxFileBase

	dc.l	MacrNoEntry2Msg-TfmxFileBase
	dc.l	MacrNoEntry2Msg-TfmxFileBase
	dc.l	MacrNoEntry2Msg-TfmxFileBase
	dc.l	MacrNoEntry2Msg-TfmxFileBase

	dc.l	MacrNoEntry2Msg-TfmxFileBase
	dc.l	MacrNoEntry2Msg-TfmxFileBase
	dc.l	MacrNoEntry2Msg-TfmxFileBase
	dc.l	MacrNoEntry2Msg-TfmxFileBase

	dc.l	$FFFFFFFF
MacrDMAOffMsg		dc.b	'DMAoff+Resetxx/xx/xx flag/addset/vol   ',0
MacrDMAOnMsg		dc.b	'DMAon (start sample at selected begin) ',0
MacrSetBeginMsg		dc.b	'SetBegin    xxxxxx   sample-startadress',0
MacrSetLenMsg		dc.b	'SetLen      ..xxxx   sample-length     ',0
MacrWaitMsg		dc.b	'Wait        ..xxxx   count (VBI''s)     ',0
MacrLoopMsg		dc.b	'Loop        xx/xxxx  count/step        ',0
MacrContMsg		dc.b	'Cont        xx/xxxx  macro-number/step ',0
MacrSTOPMsg		dc.b	'-------------STOP----------------------',0
MacrAddNoteMsg		dc.b	'AddNote     xx/xxxx  note/detune       ',0
MacrSetNoteMsg		dc.b	'SetNote     xx/xxxx  note/detune       ',0
MacrResetVPEMsg		dc.b	'Reset   Vibrato-Portamento-Envelope    ',0
MacrPortaMsg		dc.b	'Portamento  xx/../xx count/speed       ',0
MacrVibratoMsg		dc.b	'Vibrato     xx/../xx speed/intensity   ',0
MacrAddVolMsg		dc.b	'AddVolume   ....xx   volume 00-3F      ',0
MacrSetVolMsg		dc.b	'SetVolume   ....xx   volume 00-3F      ',0
MacrEnvelopeMsg		dc.b	'Envelope    xx/xx/xx speed/count/endvol',0
MacrLoopKUpMsg		dc.b	'Loop key up xx/xxxx  count/step        ',0
MacrAddBeginMsg		dc.b	'AddBegin    xx/xxxx  count/add to start',0
MacrAddLenMsg		dc.b	'AddLen      ..xxxx   add to sample-len ',0
MacrDMAOffNoClrMsg	dc.b	'DMAoff stop sample but no clear        ',0
MacrWaitKUpMsg		dc.b	'Wait key up ....xx   count (VBI''s)     ',0
MacrGosubMsg		dc.b	'Go submacro xx/xxxx  macro-number/step ',0
MacrReturnMsg		dc.b	'--------Return to old macro------------',0
MacrSetPerMsg		dc.b	'Setperiod   ..xxxx   DMA period        ',0
MacrSampleLoopMsg	dc.b	'Sampleloop  ..xxxx   relative adress   ',0
MacrOneShotMsg		dc.b	'-------Set one shot sample-------------',0
MacrWaitDMAMsg		dc.b	'Wait on DMA ..xxxx   count (Wavecycles)',0
;MacrRandomMsg		dc.b	'Random play xx/xx/xx macro/speed/mode  ',0
MacrSplitkeyMsg		dc.b	'Splitkey    xx/xxxx  key/macrostep     ',0
MacrSplitvolMsg		dc.b	'Splitvolume xx/xxxx  volume/macrostep  ',0
;MacrAddVolNoteMsg	dc.b	'Addvol+note xx/fe/xx note/CONST./volume',0
MacrSetPrevNoteMsg	dc.b	'SetPrevNote xx/xxxx  note/detune       ',0
MacrCueMsg		dc.b	'Signal      xx/xxxx  signalnumber/value',0
MacrPlayMacroMsg	dc.b	'Play macro  xx/.x/xx macro/chan/detune ',0
MacrSIDSampleMsg	dc.b	'SID setbeg  xxxxxx   sample-startadress',0
MacrSIDLengthMsg	dc.b	'SID setlen  xx/xxxx  buflen/sourcelen  ',0
MacrSID2OfsMsg		dc.b	'SID op3 ofs xxxxxx   offset            ',0
MacrSID2VibMsg		dc.b	'SID op3 frq xx/xxxx  speed/amplitude   ',0
MacrSID1OfsMsg		dc.b	'SID op2 ofs xxxxxx   offset            ',0
MacrSID1VibMsg		dc.b	'SID op2 frq xx/xxxx  speed/amplitude   ',0
MacrSIDFilterMsg	dc.b	'SID op1     xx/xx/xx speed/amplitude/TC',0
MacrSIDStopMsg		dc.b	'SID stop    xx....   flag (1=clear all)',0
MacrNoEntry0Msg		dc.b	'No Entry - - - - - - - - - - - - - - - ',0
MacrNoEntry1Msg		dc.b	'No Entry - - - - - - - - - - - - - - - ',0
MacrNoEntry2Msg		dc.b	'- No Entry - - - - - - - - - - - - - - ',0

NoteNamesTable
	dc.l	Note00Msg-TfmxFileBase
	dc.l	Note01Msg-TfmxFileBase
	dc.l	Note02Msg-TfmxFileBase
	dc.l	Note03Msg-TfmxFileBase
	dc.l	Note04Msg-TfmxFileBase
	dc.l	Note05Msg-TfmxFileBase
	dc.l	Note06Msg-TfmxFileBase
	dc.l	Note07Msg-TfmxFileBase
	dc.l	Note08Msg-TfmxFileBase
	dc.l	Note09Msg-TfmxFileBase
	dc.l	Note0AMsg-TfmxFileBase
	dc.l	Note0BMsg-TfmxFileBase
	dc.l	Note0CMsg-TfmxFileBase
	dc.l	Mote0DMsg-TfmxFileBase
	dc.l	Note0EMsg-TfmxFileBase
	dc.l	Note0FMsg-TfmxFileBase
	dc.l	Note10Msg-TfmxFileBase
	dc.l	Note11Msg-TfmxFileBase
	dc.l	Note12Msg-TfmxFileBase
	dc.l	Note13Msg-TfmxFileBase
	dc.l	Note14Msg-TfmxFileBase
	dc.l	Note15Msg-TfmxFileBase
	dc.l	Note16Msg-TfmxFileBase
	dc.l	Note17Msg-TfmxFileBase
	dc.l	Note18Msg-TfmxFileBase
	dc.l	Note19Msg-TfmxFileBase
	dc.l	Note1AMsg-TfmxFileBase
	dc.l	Note1BMsg-TfmxFileBase
	dc.l	Note1CMsg-TfmxFileBase
	dc.l	Note1DMsg-TfmxFileBase
	dc.l	Note1EMsg-TfmxFileBase
	dc.l	Note1FMsg-TfmxFileBase
	dc.l	Note20Msg-TfmxFileBase
	dc.l	Note21Msg-TfmxFileBase
	dc.l	Note22Msg-TfmxFileBase
	dc.l	Note23Msg-TfmxFileBase
	dc.l	Note24Msg-TfmxFileBase
	dc.l	Note25Msg-TfmxFileBase
	dc.l	Note26Msg-TfmxFileBase
	dc.l	Note27Msg-TfmxFileBase
	dc.l	Note28Msg-TfmxFileBase
	dc.l	Note29Msg-TfmxFileBase
	dc.l	Note2AMsg-TfmxFileBase
	dc.l	Note2BMsg-TfmxFileBase
	dc.l	Note2CMsg-TfmxFileBase
	dc.l	Note2DMsg-TfmxFileBase
	dc.l	Note2EMsg-TfmxFileBase
	dc.l	Note2FMsg-TfmxFileBase
	dc.l	Note30Msg-TfmxFileBase
	dc.l	Note31Msg-TfmxFileBase
	dc.l	Note32Msg-TfmxFileBase
	dc.l	Note33Msg-TfmxFileBase
	dc.l	Note34Msg-TfmxFileBase
	dc.l	Note35Msg-TfmxFileBase
	dc.l	Note36Msg-TfmxFileBase
	dc.l	Note37Msg-TfmxFileBase
	dc.l	Note38Msg-TfmxFileBase
	dc.l	Note39Msg-TfmxFileBase
	dc.l	Note3AMsg-TfmxFileBase
	dc.l	Note3BMsg-TfmxFileBase
	dc.l	Note3CMsg-TfmxFileBase
	dc.l	Note3DMsg-TfmxFileBase
	dc.l	Note3EMsg-TfmxFileBase
	dc.l	Note3FMsg-TfmxFileBase
	dc.l	$FFFFFFFF
Note00Msg	dc.b	'F#0 ',0
Note01Msg	dc.b	'G-0 ',0
Note02Msg	dc.b	'G#0 ',0
Note03Msg	dc.b	'A-0 ',0
Note04Msg	dc.b	'A#0 ',0
Note05Msg	dc.b	'B-0 ',0
Note06Msg	dc.b	'C-1 ',0
Note07Msg	dc.b	'C#1 ',0
Note08Msg	dc.b	'D-1 ',0
Note09Msg	dc.b	'D#1 ',0
Note0AMsg	dc.b	'E-1 ',0
Note0BMsg	dc.b	'F-1 ',0
Note0CMsg	dc.b	'F#1 ',0
Mote0DMsg	dc.b	'G-1 ',0
Note0EMsg	dc.b	'G#1 ',0
Note0FMsg	dc.b	'A-1 ',0
Note10Msg	dc.b	'A#1 ',0
Note11Msg	dc.b	'B-1 ',0
Note12Msg	dc.b	'C-2 ',0
Note13Msg	dc.b	'C#2 ',0
Note14Msg	dc.b	'D-2 ',0
Note15Msg	dc.b	'D#2 ',0
Note16Msg	dc.b	'E-2 ',0
Note17Msg	dc.b	'F-2 ',0
Note18Msg	dc.b	'F#2 ',0
Note19Msg	dc.b	'G-2 ',0
Note1AMsg	dc.b	'G#2 ',0
Note1BMsg	dc.b	'A-2 ',0
Note1CMsg	dc.b	'A#2 ',0
Note1DMsg	dc.b	'B-2 ',0
Note1EMsg	dc.b	'C-3 ',0
Note1FMsg	dc.b	'C#3 ',0
Note20Msg	dc.b	'D-3 ',0
Note21Msg	dc.b	'D#3 ',0
Note22Msg	dc.b	'E-3 ',0
Note23Msg	dc.b	'F-3 ',0
Note24Msg	dc.b	'F#3 ',0
Note25Msg	dc.b	'G-3 ',0
Note26Msg	dc.b	'G#3 ',0
Note27Msg	dc.b	'A-3 ',0
Note28Msg	dc.b	'A#3 ',0
Note29Msg	dc.b	'B-3 ',0
Note2AMsg	dc.b	'C-4 ',0
Note2BMsg	dc.b	'C#4 ',0
Note2CMsg	dc.b	'D-4 ',0
Note2DMsg	dc.b	'D#4 ',0
Note2EMsg	dc.b	'E-4 ',0
Note2FMsg	dc.b	'F-4 ',0
Note30Msg	dc.b	'F#3!',0
Note31Msg	dc.b	'G-3!',0
Note32Msg	dc.b	'G#3!',0
Note33Msg	dc.b	'A-3!',0
Note34Msg	dc.b	'A#3!',0
Note35Msg	dc.b	'B-3!',0
Note36Msg	dc.b	'C-4!',0
Note37Msg	dc.b	'C#4!',0
Note38Msg	dc.b	'D-4!',0
Note39Msg	dc.b	'D#4!',0
Note3AMsg	dc.b	'E-4!',0
Note3BMsg	dc.b	'F-4!',0
Note3CMsg	dc.b	'!f#!',0
Note3DMsg	dc.b	'!g-!',0
Note3EMsg	dc.b	'!g#!',0
Note3FMsg	dc.b	'!a-!',0

PattNamesTable
	dc.l	PattEndMsg-TfmxFileBase
	dc.l	PattLoopMsg-TfmxFileBase
	dc.l	PattContMsg-TfmxFileBase
	dc.l	PattWaitMsg-TfmxFileBase
	dc.l	PattStopMsg-TfmxFileBase
	dc.l	PattKupMsg-TfmxFileBase
	dc.l	PattVibrMsg-TfmxFileBase
	dc.l	PattEnveMsg-TfmxFileBase
	dc.l	PattGsPtMsg-TfmxFileBase
	dc.l	PattRoPtMsg-TfmxFileBase
	dc.l	PattFadeMsg-TfmxFileBase
	dc.l	PattPPatMsg-TfmxFileBase
	dc.l	PattFCMsg-TfmxFileBase
	dc.l	PattFDMsg-TfmxFileBase
	dc.l	PattStCuMsg-TfmxFileBase
	dc.l	PattNOPMsg-TfmxFileBase
	dc.l	Patt0040Msg-TfmxFileBase
	dc.l	Patt40C0Msg-TfmxFileBase
	dc.l	PattC0EFMsg-TfmxFileBase
	dc.l	$FFFFFFFF
PattEndMsg	dc.b	'End >>>>>>>>--Next track  step--',0
PattLoopMsg	dc.b	'Loop>>>>>>>>[count     / step.w]',0
PattContMsg	dc.b	'Cont>>>>>>>>[patternno./ step.w]',0
PattWaitMsg	dc.b	'Wait>>>>>>>>[count 00-FF--------',0
PattStopMsg	dc.b	'Stop>>>>>>>>--Stop this pattern-',0
PattKupMsg	dc.b	'Kup^>>>>>>>>-Set key up/channel]',0
PattVibrMsg	dc.b	'Vibr>>>>>>>>[speed     / rate.b]',0
PattEnveMsg	dc.b	'Enve>>>>>>>>[speed /endvolume.b]',0
PattGsPtMsg	dc.b	'GsPt>>>>>>>>[patternno./ step.w]',0
PattRoPtMsg	dc.b	'RoPt>>>>>>>>-Return old pattern-',0
PattFadeMsg	dc.b	'Fade>>>>>>>>[speed /endvolume.b]',0
PattPPatMsg	dc.b	'PPat>>>>>>>>[patt./track+transp]',0
PattFCMsg	dc.b	'Lock>>>>>>>>---------ch./time.b]',0
PattFDMsg	dc.b	'---->>>>>>>>------No entry------',0
PattStCuMsg	dc.b	'Stop>>>>>>>>-Stop custompattern-',0
PattNOPMsg	dc.b	'NOP!>>>>>>>>-no operation-------',0
Patt0040Msg	dc.b	'                    ',0
Patt40C0Msg	dc.b	'Note+wait-----VBI''s]',0
PattC0EFMsg	dc.b	'[portcount/ch+speed]',0
	even

VectorDataBlock
	rsreset
vdb_Voice0	rs.b	14
vdb_Voice0Data	rs.l	1
vdb_Voice0Code	rs.l	1
vdb_Voice0Save	rs.l	1

	dc.l	0,0
	dc.b	0,0
	dc.l	0
	dc.l	0,0,0

vdb_Voice1	rs.b	14
vdb_Voice1Data	rs.l	1
vdb_Voice1Code	rs.l	1
vdb_Voice1Save	rs.l	1

	dc.l	0,0
	dc.b	0,0
	dc.l	0
	dc.l	0,0,0

vdb_Voice2	rs.b	14
vdb_Voice2Data	rs.l	1
vdb_Voice2Code	rs.l	1
vdb_Voice2Save	rs.l	1

	dc.l	0,0
	dc.b	0,0
	dc.l	0
	dc.l	0,0,0

vdb_Voice3	rs.b	14
vdb_Voice3Data	rs.l	1
vdb_Voice3Code	rs.l	1
vdb_Voice3Save	rs.l	1

	dc.l	0,0
	dc.b	0,0
	dc.l	0
	dc.l	0,0,0

vdb_VertB	rs.b	14
vdb_VertBData	rs.l	1
vdb_VertBCode	rs.l	1

	dc.l	0,0
	dc.b	0,-5
	dc.l	0
	dc.l	0,0

vdb_CIA		rs.b	14
vdb_CIAData	rs.l	1
vdb_CIACode	rs.l	1

vdb_CIATimer	=	vdb_CIAData

	dc.l	0,0
	dc.b	0,5
	dc.l	0
	dc.l	0,0

vdb_RBF		rs.b	14
vdb_RBFData	rs.l	1
vdb_RBFCode	rs.l	1
vdb_RBFSave	rs.l	1

	dc.l	0,0
	dc.b	0,5
	dc.l	0
	dc.l	0,0,0

vdb_CIAResource	rs.l	1
vdb_CIAControl	rs.l	1

	dc.l	0,0

_LVODisable=-$78
_LVOEnable=-$7e
_LVOForbid=-$84
_LVOPermit=-$8a
_LVOSetIntVector=-$a2
_LVOOpenResource=-498
_LVOAddIntServer=-$a8
_LVORemIntServer=-$ae
_LVOAddICRVector	=   -6
_LVORemICRVector	=  -12

VBION
	movem.l	d0-d1/a0-a1/a4-a6,-(a7)
	lea	VectorDataBlock(pc),a5
	lea	VoiceInt(pc),a0
	move.l	a0,vdb_Voice0Code(a5)
	move.l	a0,vdb_Voice1Code(a5)
	move.l	a0,vdb_Voice2Code(a5)
	lea	VoiceInt3(pc),a0
	move.l	a0,vdb_Voice3Code(a5)

	lea	VertBInt(pc),a0
	move.l	a0,vdb_VertBCode(a5)
	lea	NULL(pc),a0
	move.l	a0,vdb_VertBData(a5)
	lea	CIAInt(pc),a0
	move.l	a0,vdb_CIACode(a5)
	lea	RBFInt(pc),a0
	move.l	a0,vdb_RBFCode(a5)

	lea	TfmxPro.MSG(pc),a1
	move.l	a1,vdb_Voice0+10(a5)
	move.l	a1,vdb_Voice1+10(a5)
	move.l	a1,vdb_Voice2+10(a5)
	move.l	a1,vdb_Voice3+10(a5)
	move.l	a1,vdb_VertB+10(a5)
	move.l	a1,vdb_RBF+10(a5)
	move.l	a1,vdb_CIA+10(a5)

	lea	Voice0Data(pc),a0
	move.l	a0,vdb_Voice0Data(a5)
	lea	Voice1Data(pc),a0
	move.l	a0,vdb_Voice1Data(a5)
	lea	Voice2Data(pc),a0
	move.l	a0,vdb_Voice2Data(a5)
	lea	Voice3Data(pc),a0
	move.l	a0,vdb_Voice3Data(a5)

	move.l	4.w,a6

	lea	vdb_Voice0(a5),a1
	moveq	#7,d0
	bsr	.SetOurIntVector
	lea	vdb_Voice1(a5),a1
	moveq	#8,d0
	bsr	.SetOurIntVector
	lea	vdb_Voice2(a5),a1
	moveq	#9,d0
	bsr	.SetOurIntVector
	lea	vdb_Voice3(a5),a1
	moveq	#10,d0
	bsr	.SetOurIntVector
;	lea	vdb_RBF(a5),a1
;	moveq	#11,d0
;	bsr	.SetOurIntVector

	lea	vdb_VertB(a5),a1
	moveq	#5,d0
	tst.b	8(a1)
	bne.s	.gotvb
	move.b	#2,8(a1)
	jsr	_LVOAddIntServer(a6)
.gotvb

	jsr	_LVODisable(a6)

	tst.l	vdb_CIAControl(a5)
	bne.s	.gotcia

	tst.l	vdb_CIAResource(a5)
	bne.s	.gotciar
	lea	CIAResource.MSG(pc),a1
	moveq	#0,d0
	jsr	_LVOOpenResource(a6)
	move.l	d0,vdb_CIAResource(a5)
.gotciar
	move.l	vdb_CIAResource(a5),a6

	move.l	#$BFD400,vdb_CIATimer(a5)
	lea	vdb_CIA(a5),a1
	moveq	#0,d0
	jsr	_LVOAddICRVector(a6)
	lea	$BFDE00,a4
	tst.l	d0
	beq.s	.claimcia

	move.l	#$BFD600,vdb_CIATimer(a5)
	lea	vdb_CIA(a5),a1
	moveq	#0,d0
	jsr	_LVOAddICRVector(a6)
	lea	$BFDF00,a4
	tst.l	d0
	beq.s	.claimcia

	clr.l	vdb_CIATimer(a5)
	moveq	#0,d0
	bra.s	.exit
.claimcia
	moveq	#125,d0
	bsr	SetCIATempo

	move.l	a4,vdb_CIAControl(a5)
	bset	#0,(a4)
.gotcia
	moveq	#-1,d0
.exit
	move.l	4.w,a6
	jsr	_LVOEnable(a6)

	movem.l	(a7)+,d0-d1/a0-a1/a4-a6
	rts

.SetOurIntVector
	tst.b	8(a1)
	bne.s	.gotv
	move.b	#2,8(a1)
	move.l	a1,-(a7)
	jsr	_LVOSetIntVector(a6)
	move.l	(a7)+,a1
	move.l	d0,vdb_Voice0Save-vdb_Voice0(a1)
.gotv
	rts

VBIOFF
	movem.l	d0-d1/a0-a1/a4-a6,-(a7)
	lea	VectorDataBlock(pc),a5
	move.l	4.w,a6

	lea	vdb_Voice0(a5),a1
	moveq	#7,d0
	bsr	.RemOurIntVector
	lea	vdb_Voice1(a5),a1
	moveq	#8,d0
	bsr	.RemOurIntVector
	lea	vdb_Voice2(a5),a1
	moveq	#9,d0
	bsr	.RemOurIntVector
	lea	vdb_Voice3(a5),a1
	moveq	#10,d0
	bsr	.RemOurIntVector
;	lea	vdb_RBF(a5),a1
;	moveq	#11,d0
;	bsr	.RemOurIntVector

	lea	vdb_VertB(a5),a1
	moveq	#5,d0
	tst.b	8(a1)
	beq.s	.gotvb
	jsr	_LVORemIntServer(a6)
	sf	vdb_VertB+8(a5)
.gotvb

	move.l	vdb_CIAControl(a5),d0
	beq.s	.gotcia
	move.l	d0,a4
	moveq	#0,d0
	move.b	vdb_CIAControl+2(a5),d0
	and.w	#$1,d0
	lea	vdb_CIA(a5),a1
	move.l	vdb_CIAResource(a5),a6
	jsr	_LVORemICRVector(a6)
	clr.l	vdb_CIAControl(a5)
.gotcia

	movem.l	(a7)+,d0-d1/a0-a1/a4-a6
	rts

.RemOurIntVector
	tst.b	8(a1)
	bne.s	*+4
	rts
	move.l	a1,-(a7)
	move.l	vdb_Voice0Save-vdb_Voice0(a1),a1
	jsr	_LVOSetIntVector(a6)
	move.l	(a7)+,a1
	sf	8(a1)
	rts

CIAResource.MSG
	dc.b	"ciab.resource",0
TfmxPro.MSG
	dc.b	"TFMX-Pro",0
	even


SetCIATempo
	movem.l	d0-d1/a0,-(a7)
	move.l	#$1B51F8,d1
	cmp.w	#32,d0
	bhs.s	*+4
	moveq	#125,d0
	divu	d0,d1
	lea	VectorDataBlock(pc),a0
	move.l	vdb_CIATimer(a0),a0
	move.w	d1,-(a7)
	move.b	d1,(a0)
	move.b	(a7)+,$100(a0)
	movem.l	(a7)+,d0-d1/a0
	rts

XINFO
;	lea	MasterDataBlock(PC),A0
;	move.l	A1,$54(A0)		midi hook
	lea	MacroNamesTable(PC),A0
	lea	NoteNamesTable(PC),A1
	lea	PattNamesTable(PC),A2
	rts

lbL002338
	dc.w	0,0,$600,0,$800

XSETRECORD
	move.l	A6,-(SP)
	lea	lbL002338(PC),A0	xrec block
;	lea	lbL001E88(PC),A6	rec block
	move.w	(A6),(A0)
;	move.w	$1A(A6),2(A0)
;	move.l	$26(A6),4(A0)
	move.l	(SP)+,A6
	rts

CIAInt
	movem.l	d0-d7/a0-a6,-(a7)
	move.b	MasterDataBlock+$36(pc),d0
	bne.s	.nocall
	bsr	IRQIN
.nocall
	movem.l	(a7)+,d0-d7/a0-a6
	rts

RBFInt
	move.w	#$800,$DFF09A
	rts

VertBInt
	movem.l	d2-d7/a0/a2-a5,-(a7)
	jsr	(a1)
	moveq	#0,d0
	movem.l	(a7)+,d2-d7/a0/a2-a5
NULL
	rts

RECORD
;	lea	MasterDataBlock(PC),A6
;	lea	RecordBlock(PC),A3
;	cmp.w	#$41,D0
;	bne	lbC001946
;	bra	lbC001D46
;
;lbC001946
;	lea	lbL002090(PC),A5
;	move.w	D1,0(A5)
;	move.w	D1,2(A5)
;	move.w	D1,4(A5)
;	bsr	QUIET
;	move.w	#$FFFF,$3C(A6)
;	move.l	A0,$14(A3)
;	asl.w	#1,D0
;	move.w	D0,$18(A3)
;	sub.w	#1,D0
;lbC00196E
;	move.l	#$FF000000,(A0)+
;	move.l	#$F3000000,(A0)+
;	sub.w	#1,D0
;	dbmi	D0,lbC00196E
;	move.l	#$F0000000,(A0)+
;	move.w	D3,14(A3)
;	move.w	D4,$12(A3)
;	move.w	D5,6(A5)
;	clr.b	D6
;	lea	lbL002338(PC),A5
;	move.l	D6,$26(A3)
;	move.b	$26(A3),1(A3)
;	move.l	D6,4(A5)
;	move.b	4(A5),1(A5)
;	move.w	D7,$1A(A3)
;	btst	#1,D7
;	beq	lbC0019CE
;	move.w	D2,10(A3)
;	clr.w	12(A3)
;	move.w	#1,$10(A3)
;	move.w	#1,$1C(A3)
;lbC0019CE
;	move.l	4(A6),$DFF0A0
;	move.l	4(A6),$DFF0B0
;	move.l	4(A6),$DFF0C0
;	move.l	4(A6),$DFF0D0
;	move.w	#1,$DFF0A4
;	move.w	#1,$DFF0B4
;	move.w	#1,$DFF0C4
;	move.w	#1,$DFF0D4
;	move.w	#$820F,$DFF096
;	lea	lbL002090(PC),A5
;	move.w	#$1C,D0
;lbC001A1E
;	move.l	lbL002202(PC),$28(A5,D0.W)
;	move.w	#$FF00,$48(A5,D0.W)
;	clr.l	$68(A5,D0.W)
;	sub.w	#4,D0
;	bpl.s	lbC001A1E
;	move.l	0(A6),A4
;	bsr	lbC0005C6
;	clr.w	10(A6)
;	clr.w	$2C(A6)
;	move.w	#1,6(A3)
;	move.w	#1,$2E(A3)
;	move.w	#$FFFE,8(A3)
;	move.l	#$FFFFFFFF,$22(A3)
;	move.b	#1,$3F(A3)
;	clr.w	$38(A3)
;	clr.l	$34(A3)
;	move.b	#$40,$50(A6)
;	move.b	#$40,$51(A6)
;	clr.b	$1C(A6)
;	lea	lbL0021D8(PC),A4
;	clr.w	0(A4)
;	clr.w	2(A4)
;	move.b	#1,$2E(A6)
;	lea	RecordInfos(PC),A4
;	move.b	#1,$16(A4)
;lbC001AA0
;	cmp.b	#$74,$BFEC01		'x' key?
;	beq.s	lbC001AB4
;	btst	#6,$BFE001
;	bne.s	lbC001AA0
;lbC001AB4
;	lea	RecordInfos(PC),A4
;	clr.b	$16(A4)
;	bsr	QUIET
;	clr.w	$1C(A3)
;	clr.w	$1A(A3)
;	clr.l	$14(A3)
;	clr.w	$2E(A3)
;	move.b	#$7E,$BFEC01
;	move.b	$26(A3),1(A3)
	rts
;
;lbC001AE0
;	movem.l	D0/A0,-(SP)
;	move.w	#$C8,D0
;	movem.l	(SP)+,D0/A0
;	rts
;
;lbC001AEE
;	moveq	#0,d0
;	move.b	$BFEC01,D0
;	not.b	d0
;	ror.b	#1,D0
;	cmp.w	8(A3),D0
;	beq.s	lbC001B12
;	bsr.s	lbC001AE0
;	move.w	D0,8(A3)			backup key
;	move.w	D0,$32(A3)
;	rts
;
;lbC001B12
;	move.w	#$FFFF,D0
;	move.w	D0,$32(A3)			use only once
;	rts
;
;lbC001B1C
;	cmp.w	#$4E,D0				rt
;	bne.s	lbC001B30
;	add.w	#1,0(A3)
;	and.w	#$3F,0(A3)
;	rts
;
;lbC001B30
;	cmp.w	#$4F,D0				lf
;	bne.s	lbC001B44
;	sub.w	#1,0(A3)
;	and.w	#$3F,0(A3)
;	rts
;
;lbC001B44
;	cmp.w	#$5F,D0				help
;	bne.s	lbC001B52
;	move.b	$28(A3),D0
;	bra	CHANNELOFF
;
;lbC001B52
;	cmp.w	#$4C,D0				up
;	bne.s	lbC001B66
;	add.b	#1,$27(A3)
;	and.b	#$7F,$27(A3)
;	rts
;
;lbC001B66
;	cmp.w	#$4D,D0				dn
;	bne.s	lbC001B7A
;	sub.b	#1,$27(A3)
;	and.b	#$7F,$27(A3)
;	rts
;
;lbC001B7A
;	cmp.w	#$50,D0				fctn keys (chan sel)
;	bcs.s	lbC001B96
;	cmp.w	#$5A,D0
;	bcc.s	lbC001B96
;	and.w	#15,D0
;	and.b	#$F0,$28(A3)
;	or.b	D0,$28(A3)
;	rts
;
;lbC001B96
;	cmp.w	#$1D,D0				k1
;	bne.s	lbC001BAE
;	cmp.w	#12,0(A3)
;	bcs	lbC001C8A
;	sub.w	#12,0(A3)
;	rts
;
;lbC001BAE
;	cmp.w	#$1E,D0				k2
;	bne.s	lbC001BC6
;	cmp.w	#$24,0(A3)
;	bcc	lbC001C8A
;	add.w	#12,0(A3)
;	rts
;
;lbC001BC6
;	cmp.w	#$62,D0				caps dn
;	bne.s	lbC001BD2
;	clr.w	$2E(A3)
;	rts
;
;lbC001BD2
;	cmp.w	#$E2,D0				caps up
;	bne.s	lbC001BE8
;	move.w	#1,$2E(A3)
;	move.l	#$FFFFFFFF,$22(A3)
;	rts
;
;lbC001BE8
;	cmp.w	#$3E,D0				k8
;	bne.s	lbC001BFA
;	lea	lbL002090(PC),A0
;	add.w	#1,6(A0)
;	rts
;
;lbC001BFA
;	cmp.w	#$3D,D0				k7
;	bne.s	lbC001C0C
;	lea	lbL002090(PC),A0
;	sub.w	#1,6(A0)
;	rts
;
;lbC001C0C
;	move.w	D0,D1
;	and.w	#$7F,D0				must be piano
;	lea	lbL0022A2(PC),A0
;	move.l	$26(A3),$1E(A3)
;	move.b	0(A0,D0.W),D0
;	bmi.s	lbC001C8A			not piano
;	move.b	D0,$1E(A3)			note #
;	move.w	0(A3),D0			xpose
;	add.b	D0,$1E(A3)
;	bclr	#7,d1
;	beq.s	lbC001C60			if down
;	cmp.w	$3A(A3),D1
;	bne.s	lbC001C8A			key != last
;	move.b	#$F5,$1E(A3)			kup^
;	btst	#3,$1B(A3)			flags.3
;	beq.s	lbC001C8A
;	move.l	$1E(A3),D0			if on, play note
;	bsr	NOTEPORT
;	tst.w	$2E(A3)
;	beq.s	lbC001C7E
;	move.l	$1E(A3),$34(A3)			last up key
;	bra.s	lbC001C7E
;
;lbC001C60
;	cmp.l	#$FFFFFFFF,$22(A3)
;	bne.s	lbC001C8A
;	move.l	$1E(A3),D0
;	bsr	NOTEPORT
;	tst.w	$2E(A3)
;	beq.s	lbC001C7E
;	move.l	$1E(A3),$22(A3)			last dn key
;lbC001C7E
;	move.w	$32(A3),D0
;	and.w	#$7F,D0
;	move.w	D0,$3A(A3)			last key num
;lbC001C8A
;	rts

;lbC001C8C
;	move.b	$BFEC01,D0
;	eor.b	#$FF,D0
;	ror.b	#1,D0
;	and.l	#$FF,D0
;	cmp.w	#$46,D0				delete
;	bne.s	lbC001C8A
;	move.l	#$FF000000,$22(A3)		NOP!
;	rts
;
;lbC001CAE					tick
;	move.l	2(A3),A0
;	cmp.l	$40(A3),A0
;	beq	lbC001CE2
;	move.l	A0,$40(A3)
;	tst.b	(A0)
;	bmi	lbC001CCA
;	move.b	#1,$3F(A3)
;lbC001CCA
;	cmp.b	#$F5,(A0)
;	bne	lbC001CE2
;	sub.b	#1,$3F(A3)
;	bpl	lbC001CE2
;	move.l	#$FF000000,(A0)
;lbC001CE2
;	tst.w	$2E(A3)
;	beq.s	lbC001C8A
;	cmp.l	#$FFFFFFFF,$22(A3)
;	beq.s	lbC001D10
;	cmp.l	#$FF000000,$22(A3)
;	beq.s	lbC001D32
;	move.l	$22(A3),(A0)
;	move.l	#$FFFFFFFF,$22(A3)
;	move.b	#1,$3F(A0)
;	rts
;
;lbC001D10
;	tst.l	$34(A3)
;	beq	lbC001C8A
;	cmp.l	#$FF000000,(A0)
;	bne	lbC001C8A
;	move.l	$34(A3),(A0)
;	clr.l	$34(A3)
;	move.b	#1,$3F(A0)
;	rts
;
;lbC001D32
;	move.l	$22(A3),(A0)
;	move.w	#6,$38(A3)
;	move.l	#$FFFFFFFF,$22(A3)
;	rts
;
;lbC001D46
;	btst	#6,$BFE001
;	beq.s	lbC001D46
;	move.b	#1,$2F(A6)
;	clr.b	$3E(A3)
;	move.w	D4,D0
;	bsr	SONGPLAY
;lbC001D60
;	btst	#6,$BFE001
;	beq	lbC001E24
;	lea	MasterDataBlock(PC),A6
;	lea	RecordInfos(PC),A0
;	lea	lbB001EDF(PC),A1
;	lea	lbL002338(PC),A2
;	move.w	#$1E,D2
;lbC001D80
;	move.w	6(A0),D0
;	cmp.w	8(A0),D0
;	beq	lbC001E1C
;	move.b	12(A0),D3
;	move.b	0(A1,D0.W),D1
;	btst	#7,D1
;	bne	lbC001DDA
;	cmp.b	#$90,D3
;	bne	lbC001E02
;	cmp.b	#2,$10(A0)
;	beq	lbC001DBA
;	bcc	lbC001E06
;	move.b	D1,14(A0)
;	bra	lbC001E06
;
;lbC001DBA
;	move.b	D1,15(A0)
;	move.b	14(A0),D0
;	sub.b	#$24,D0
;	move.b	15(A0),D5
;	beq	lbC001DD6
;	bsr	PROSFX
;	clr.b	$10(A0)
;lbC001DD6
;	bra	lbC001E06
;
;lbC001DDA
;	and.b	#15,D1
;	cmp.b	13(A0),D1
;	bcc	lbC001E06
;	and.b	#$F0,6(A2)
;	or.b	D1,6(A2)
;	move.b	0(A1,D0.W),D1
;	and.b	#$F0,D1
;	move.b	D1,12(A0)
;	clr.b	$10(A0)
;	bra.s	lbC001E06
;
;lbC001E02
;	clr.b	12(A0)
;lbC001E06
;	add.w	#1,6(A0)
;	and.w	#$3F,6(A0)
;	add.b	#1,$10(A0)
;	bra	lbC001D80
;
;lbC001E1C
;	dbra	D2,lbC001D80
;	bra	lbC001D60
;
;lbC001E24
;	clr.b	$2F(A6)
;	rts

IRQIN
	movem.l	D0-D7/A0-A6,-(SP)
	lea	MasterDataBlock(PC),A6
	tst.b	$1F(A6)
	beq.s	lbC0003DA
	move.w	#$F66,$DFF180
	bra	lbC0004C2

lbC0003DA
	move.b	#1,$1F(A6)
	move.l	12(A6),-(SP)
	move.w	$34(A6),D0
	beq.s	lbC000426
	move.w	D0,$DFF096
	moveq	#9,D1
	btst	#0,D0
	beq.s	lbC0003FE
	move.w	D1,$DFF0A6
lbC0003FE
	btst	#1,D0
	beq.s	lbC00040A
	move.w	D1,$DFF0B6
lbC00040A
	btst	#2,D0
	beq.s	lbC000416
	move.w	D1,$DFF0C6
lbC000416
	btst	#3,D0
	beq.s	lbC000422
	move.w	D1,$DFF0D6
lbC000422
	clr.w	$34(A6)
lbC000426
	move.w	$4C(A6),$DFF096
	tst.b	$12(A6)
	bne.s	lbC000438
	bra	lbC0004BA

lbC000438
	bsr	Synthesizer
	tst.b	10(A6)
	bmi.s	lbC000446
	bsr	Sequencer
lbC000446
	lea	Voice0Data(PC),A5
	move.w	$58(A5),$DFF0A6
	lea	Voice1Data(PC),A5
	move.w	$58(A5),$DFF0B6
	lea	Voice2Data(PC),A5
	move.w	$58(A5),$DFF0C6
	lea	Voice3Data(PC),A5
	move.w	$58(A5),$DFF0D6
	lea	Voice4Data(PC),A5
	lea	lbL002612(PC),A4
	move.w	$58(A5),6(A4)
	lea	Voice5Data(PC),A5
	lea	lbL002622(PC),A4
	move.w	$58(A5),6(A4)
	lea	Voice6Data(PC),A5
	lea	lbL002632(PC),A4
	move.w	$58(A5),6(A4)
	lea	Voice7Data(PC),A5
	lea	lbL002642(PC),A4
	move.w	$58(A5),6(A4)
	move.w	$32(A6),$DFF096
	clr.w	$32(A6)
lbC0004BA
	clr.b	$1F(A6)
	move.l	(SP)+,12(A6)
lbC0004C2
	movem.l	(SP)+,D0-D7/A0-A6
lbC0004C6
	rts

Sequencer
	lea	PatternDataBlock(PC),A5
	move.l	0(A6),A4
	lea	$1C0(a4),a0
	move.w	(a0)+,$AA(a5)
	move.w	(a0)+,$AE(a5)
	move.w	(a0)+,$B2(a5)
	move.w	(a0)+,$B6(a5)
	move.w	(a0)+,$BA(a5)
	move.w	(a0)+,$BE(a5)
	move.w	(a0)+,$C2(a5)
	move.w	(a0),$C6(a5)
	subq.w	#1,$10(A6)
	bpl.s	lbC0004C6
	move.w	6(A5),$10(A6)
lbC0004DC
	move.l	A5,A0
	clr.b	9(A6)
	bsr.s	lbC000526
	tst.b	9(A6)
	bne.s	lbC0004DC
	bsr.s	lbC000524
	tst.b	9(A6)
	bne.s	lbC0004DC
	bsr.s	lbC000524
	tst.b	9(A6)
	bne.s	lbC0004DC
	bsr.s	lbC000524
	tst.b	9(A6)
	bne.s	lbC0004DC
	bsr.s	lbC000524
	tst.b	9(A6)
	bne.s	lbC0004DC
	bsr.s	lbC000524
	tst.b	9(A6)
	bne.s	lbC0004DC
	bsr.s	lbC000524
	tst.b	9(A6)
	bne.s	lbC0004DC
	bsr.s	lbC000524
	tst.b	9(A6)
	bne.s	lbC0004DC
	rts

lbC000524
	addq.l	#4,A0
lbC000526
	move.w	#16,-2(a6)
	cmp.b	#$90,$48(A0)
	bcs.s	lbC000542
	cmp.b	#$FE,$48(A0)
	bne.s	lbC00054C
	st	$48(A0)
	move.b	$49(A0),D0
	bra	CHANNELOFF

lbC000542
	tst.b	$6A(A0)
	beq.s	lbC00054E
	subq.b	#1,$6A(A0)
lbC00054C
	rts

lbC00054E
	subq.w	#1,-2(a6)
	beq	PattTimeout
	move.w	$68(A0),D0
	add.w	D0,D0
	add.w	D0,D0
	move.l	$28(A0),A1
	move.l	0(A1,D0.W),12(A6)
	move.b	12(A6),D0
	cmp.b	#$F0,D0
	bcc.s	.iscmd
	move.b	D0,D7
	cmp.b	#$C0,D0
	bcc.s	.notqwait
	cmp.b	#$7F,D0
	bcs.s	.notqwait
	move.b	15(A6),$6A(A0)
	clr.b	15(A6)
.notqwait
	move.b	$49(A0),D1
	add.b	D1,D0
	cmp.b	#$C0,D7
	bcc.s	.isporta
	and.b	#$3F,D0
.isporta
	move.b	D0,12(A6)
	move.l	12(A6),D0
	tst.w	$AA(a0)
	bne.s	.ismute
	bsr	NOTEPORT
.ismute
	cmp.b	#$C0,D7
	bcc.s	PattNOP
	cmp.b	#$7F,D7
	bcs.s	PattNOP
	bra	PattExit

.iscmd
	and.w	#15,D0
	add.w	D0,D0
	add.w	D0,D0
	jmp	.patt(PC,D0.W)

.patt
	bra	PattEnd
	bra	PattLoop
	bra	PattJump
	bra	PattWait

	bra	PattStop
	bra	PattNotePort
	bra	PattNotePort
	bra	PattNotePort

	bra	PattGsPt
	bra	PattRoPt
	bra	PattFade
	bra	PattPPat

	bra	PattNotePort
	bra	PattNOP
	bra	PattStop

PattNOP
	addq.w	#1,$68(A0)
	bra	lbC00054E

PattEnd
	st	$48(A0)
	move.w	4(A5),D0
	cmp.w	2(A5),D0
	bne.s	.nonewsong
	move.w	0(A5),4(A5)
	bra.s	.gotnext
.nonewsong
	addq.w	#1,4(A5)
.gotnext
	bsr	NewTrackStep
	st	9(A6)
	rts

PattLoop
	tst.b	$4A(A0)
	beq.s	.next
	cmp.b	#$FF,$4A(A0)
	beq.s	.newloop
	subq.b	#1,$4A(A0)
	bra.s	.loop
.next
	st	$4A(A0)
	bra.s	PattNOP
.newloop
	move.b	13(A6),D0
	subq.b	#1,D0
	move.b	D0,$4A(A0)
.loop
	move.w	14(A6),$68(A0)
	bra	lbC00054E

PattPPat
	move.w	14(a6),-(a7)
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a7),d0
	move.b	13(a6),d1
	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d1
	add.w	d1,d1
	move.l	$26(a6),a1
	add.w	d1,a1
	move.l	(a1),d1
	add.l	a4,d1
	lea	(a5,d0.w),a1
	clr.l	$68(a1)
	st	$4A(a1)
	move.l	d1,$28(a1)
	move.w	(a7)+,$48(a1)
	bra	PattNOP
	
PattJump
	move.b	13(A6),D0
	move.b	D0,$48(A0)
	add.w	D0,D0
	add.w	D0,D0
	move.l	$26(A6),A1
	move.l	0(A1,D0.W),D0
	add.l	A4,D0
	move.l	D0,$28(A0)
	move.w	14(A6),$68(A0)
	bra	lbC00054E

PattWait
	move.b	13(A6),$6A(A0)
PattExit
	addq.w	#1,$68(A0)
	rts

PattTimeout
	lea	InfoBlock(pc),a1
	move.w	#1,2(a1)
PattStop
	st	$48(A0)
	rts

PattNotePort
	move.l	12(A6),D0
	bsr	NOTEPORT
	bra	PattNOP

PattGsPt
	move.l	$28(A0),$88(A0)
	move.w	$68(A0),$A8(A0)
	move.b	13(A6),D0
	move.b	D0,$48(A0)
	add.w	D0,D0
	add.w	D0,D0
	move.l	$26(A6),A1
	move.l	0(A1,D0.W),D0
	add.l	A4,D0
	move.l	D0,$28(A0)
	move.w	14(A6),$68(A0)
	bra	lbC00054E

PattRoPt
	move.l	$88(A5),$28(A5)
	move.w	$A8(A5),$68(A5)
	bra	PattNOP

PattFade
	move.b	15(A6),$1B(A6)
	move.b	13(A6),$1C(A6)
	move.b	13(A6),$1D(A6)
	beq.s	.setvol
	move.b	#1,11(A6)
	move.b	$1A(A6),D0
	cmp.b	$1B(A6),D0
	beq.s	.nofade
	bcs	PattNOP
	neg.b	11(A6)
	bra	PattNOP
.setvol
	move.b	$1B(A6),$1A(A6)
.nofade
	clr.b	11(A6)
	bra	PattNOP

NewTrackStep
	move.w	#8,-2(a6)
	movem.l	A0/A1,-(SP)
NewTrackStep_
	subq.w	#1,-2(a6)
	beq	trkTimeout
	move.w	4(A5),D0
	lsl.w	#4,D0
	move.l	$22(A6),A0
	add.w	D0,A0
	move.l	$26(A6),A1
	move.w	(A0)+,D0
	cmp.w	#$EFFE,D0
	bne.s	.istrack
	move.w	(A0)+,D0
	cmp.w	#5,d0
	blo.s	.effeok
	addq.w	#1,4(a5)
	bra.s	NewTrackStep_
.effeok
	add.w	D0,D0
	add.w	D0,D0
	jmp	.effe(PC,D0.W)

.effe
	bra	effe_Stop
	bra	effe_Loop
	bra	effe_Tempo
	bra	effe_7Voice
	bra	effe_Fade

.istrack
	move.w	D0,$48(A5)
	bmi.s	.no0
	clr.b	d0
	lsr.w	#6,D0
	move.l	0(A1,D0.W),D0
	add.l	A4,D0
	move.l	D0,$28(A5)
	clr.l	$68(A5)
	st	$4A(A5)
.no0
	movem.w	(A0)+,D0-D6
	move.w	D0,$4C(A5)
	bmi.s	.no1
	clr.b	D0
	lsr.w	#6,D0
	move.l	0(A1,D0.W),D0
	add.l	A4,D0
	move.l	D0,$2C(A5)
	clr.l	$6C(A5)
	st	$4E(A5)
.no1
	move.w	D1,$50(A5)
	bmi.s	.no2
	clr.b	D1
	lsr.w	#6,D1
	move.l	0(A1,D1.W),D0
	add.l	A4,D0
	move.l	D0,$30(A5)
	clr.l	$70(A5)
	st	$52(A5)
.no2
	move.w	D2,$54(A5)
	bmi.s	.no3
	clr.b	D2
	lsr.w	#6,D2
	move.l	0(A1,D2.W),D0
	add.l	A4,D0
	move.l	D0,$34(A5)
	clr.l	$74(A5)
	st	$56(A5)
.no3
	move.w	D3,$58(A5)
	bmi.s	.no4
	clr.b	D3
	lsr.w	#6,D3
	move.l	0(A1,D3.W),D0
	add.l	A4,D0
	move.l	D0,$38(A5)
	clr.l	$78(A5)
	st	$5A(A5)
.no4
	move.w	D4,$5C(A5)
	bmi.s	.no5
	clr.b	D4
	lsr.w	#6,D4
	move.l	0(A1,D4.W),D0
	add.l	A4,D0
	move.l	D0,$3C(A5)
	clr.l	$7C(A5)
	st	$5E(A5)
.no5
	move.w	D5,$60(A5)
	bmi.s	.no6
	clr.b	D5
	lsr.w	#6,D5
	move.l	0(A1,D5.W),D0
	add.l	A4,D0
	move.l	D0,$40(A5)
	clr.l	$80(A5)
	st	$62(A5)
.no6
	move.w	D6,$64(A5)
	bmi.s	.no7
	clr.b	D6
	lsr.w	#6,D6
	move.l	0(A1,D6.W),D0
	add.l	A4,D0
	move.l	D0,$44(A5)
	clr.l	$84(A5)
	st	$66(A5)
.no7
	movem.l	(SP)+,A0/A1
	rts

trkTimeout
	lea	InfoBlock(pc),a0
	move.w	#1,2(a0)
effe_Stop
	clr.b	$12(A6)
	movem.l	(SP)+,A0/A1
	rts

effe_Loop
	tst.w	$20(A6)
	beq.s	.nextstep
	bmi.s	.newloop
	subq.w	#1,$20(A6)
	bra.s	.loop
.nextstep
	move.w	#$FFFF,$20(A6)
	addq.w	#1,4(A5)
	bra	NewTrackStep_
.newloop
	move.w	2(A0),D0
	subq.w	#1,D0
	move.w	D0,$20(A6)
.loop
	move.w	(A0),4(A5)
	bra	NewTrackStep_

effe_Tempo
	addq.w	#1,4(A5)
	move.w	(A0),d0
	move.w	d0,6(A5)
	move.w	d0,$10(A6)
	move.w	2(a0),d0
	bmi	NewTrackStep_
	move.w	d0,-2(a5)
	bsr	SetCIATempo
	bra	NewTrackStep_

effe_7Voice
	addq.w	#1,4(A5)
	cmp.w	#1,(a0)			ignore old timeshare cmd
	bls	NewTrackStep_
	tst.w	(A0)
	bmi	.noplayspd
	move.w	(A0),$38(A6)
.noplayspd
	tst.w	2(A0)
	bmi	.no7tempo
	move.w	2(A0),D0
	ext.w	D0
	move.w	D0,$3A(A6)
	move.b	#$EF,-2(a5)
	move.b	d0,-1(a5)
.no7tempo
	bsr	RawSetSpeed
	bra	NewTrackStep_

effe_Fade
	addq.w	#1,4(A5)
	move.b	3(A0),$1B(A6)
	move.b	1(A0),$1C(A6)
	move.b	1(A0),$1D(A6)
	beq.s	.setvol
	move.b	#1,11(A6)
	move.b	$1A(A6),D0
	cmp.b	$1B(A6),D0
	beq.s	.nofade
	bcs	NewTrackStep_
	neg.b	11(A6)
	bra	NewTrackStep_
.setvol
	move.b	$1B(A6),$1A(A6)
.nofade
	move.b	#0,11(A6)
	bra	NewTrackStep_

Synthesizer
	lea	Voice0Data(PC),A5
	bsr.s	.syn1
	lea	Voice1Data(PC),A5
	bsr.s	.syn1
	lea	Voice2Data(PC),A5
	bsr.s	.syn1
	tst.b	$36(A6)
	beq.s	.dovoice3
	lea	Voice4Data(PC),A5
	bsr.s	.syn1
	lea	Voice5Data(PC),A5
	bsr.s	.syn1
	lea	Voice6Data(PC),A5
	bsr.s	.syn1
	lea	Voice7Data(PC),A5
	bra.s	.syn1
.dovoice3
	lea	Voice3Data(PC),A5
.syn1
	move.w	#15,-2(a6)
	move.l	$4C(A5),A4
	tst.w	$3E(A5)
	bmi.s	.clrdefer
	subq.w	#1,$3E(A5)
	bra.s	.trydefer
.clrdefer
	clr.b	$3C(A5)
	clr.b	$3D(A5)
.trydefer
	move.l	$54(A5),D0
	beq.s	.nodefer
	clr.l	$54(A5)
	clr.b	$3C(A5)
	bsr	NOTEPORT
	move.b	$3D(A5),$3C(A5)
.nodefer
	tst.b	0(A5)
	beq	MacDoEfx
	tst.w	$12(A5)
	beq.s	MacProcess
	subq.w	#1,$12(A5)
	bra	MacDoEfx

MacProcess
	subq.w	#1,-2(a6)
	bmi	MacTimeout
	move.l	12(A5),A0
	move.w	$10(A5),D0
	cmp.w	#$7F,d0
	bhs	MacNull
	add.w	D0,D0
	add.w	D0,D0
	lea	0(A0,D0.W),A0
	move.l	(A0),12(A6)
	moveq	#0,D0
	move.b	12(A6),D0
	cmp.w	#$29,d0
	bhs	MacNull
	clr.b	12(A6)
	add.w	D0,D0
	add.w	D0,D0
	jmp	.mac(PC,D0.W)

.mac
	bra	MacDmaOffReset
	bra	MacDmaOn
	bra	MacSetStart
	bra	MacSetLength

	bra	MacWait
	bra	MacLoop
	bra	MacCont
	bra	MacSTOP

	bra	MacAddNote
	bra	MacSetNote
	bra	MacReset
	bra	MacPorta

	bra	MacVibrato
	bra	MacAddVol
	bra	MacSetVol
	bra	MacEnvelope

	bra	MacLoopKeyUp
	bra	MacAddBegin
	bra	MacAddLen
	bra	MacDmaOff

	bra	MacWaitKeyUp
	bra	MacGoSubmacro
	bra	MacReturnOldMacro
	bra	MacSetPeriod

	bra	MacSampleLoop
	bra	MacSetOneShot
	bra	MacWaitOnDma
	bra	MacNull

	bra	MacSplitNote
	bra	MacSplitVol
	bra	MacNull
	bra	MacSetPrvNote

	bra	MacNull
	bra	MacPlayNote
	bra	mac_22
	bra	mac_23

	bra	mac_24
	bra	mac_25
	bra	mac_26
	bra	mac_27

	bra	mac_28
	bra	mac_29
	bra	MacNull

MacTryDeferWait
	tst.b	$5A(A5)
	beq.s	.dontwait
	addq.w	#1,$10(A5)
	bra	MacDoEfx
.dontwait
	st	$5A(A5)
MacNull
	addq.w	#1,$10(A5)
	bra	MacProcess

MacDmaOffReset
	clr.b	3(A5)
	clr.b	$1C(A5)
	clr.b	$26(A5)
	clr.w	$30(A5)
	clr.w	cdb_SIDSize(A5)
	sf	cdb_SIDSaveState(a5)
	move.w	$16(A5),$DFF096		kill dma but do normal timing
	move.b	15(A6),d1
	tst.b	14(a6)
	bne.s	.SetVol
.AddVol
	move.w	8(A5),D0
	add.w	D0,D0
	add.w	8(A5),D0
	add.b	D0,d1
.SetVol
	move.b	d1,$18(A5)
MacDmaOff
	addq.w	#1,$10(A5)
	move.l	$5C(A5),A0
	cmp.l	#0,A0
	beq.s	.ishdwe
	clr.b	(A0)
	clr.b	$5A(A5)
	move.l	$60(A5),A0
	jsr	(A0)
	bra	MacProcess
.ishdwe
	tst.b	13(A6)
	bne.s	.defer
	move.w	$16(A5),$DFF096
	bra	MacProcess
.defer
	move.w	$16(A5),D0
	or.w	D0,$34(A6)
	clr.b	$5A(A5)
	bra	MacDoEfx

MacDmaOn
	move.w	$46(A5),$DFF09A
	move.w	$46(A5),$DFF09C
	move.b	13(A6),1(A5)
	addq.w	#1,$10(A5)
	move.l	$5C(A5),A0
	cmp.l	#0,A0
	beq.s	.ishdwe
	st	(A0)
	move.l	$60(A5),A0
	jsr	(A0)
	bra	MacDoEfx
.ishdwe
	move.w	$14(A5),D0
	or.w	D0,$32(A6)
	bra	MacProcess

MacSetStart
	clr.b	3(A5)
	move.l	12(A6),D0
	add.l	4(A6),D0
.setbeg
	move.l	D0,$2C(A5)
	move.l	D0,(A4)
	addq.w	#1,$10(A5)
	bra	MacProcess
.addbeg
	move.b	13(A6),3(A5)
	move.b	13(A6),$1B(A5)
	move.w	14(A6),D1
	ext.l	D1
	move.l	D1,$50(A5)
	move.l	$2C(A5),D0
	add.l	D1,D0
	bra.s	.setbeg

MacAddBegin	=	.addbeg

MacAddLen
	move.w	14(A6),D0
	move.w	$34(A5),D1
	add.w	D0,D1
	move.w	D1,$34(A5)
	move.w	D1,4(A4)
	addq.w	#1,$10(A5)
	bra	MacProcess

MacSetLength
	move.w	14(A6),$34(A5)
	move.w	14(A6),4(A4)
	addq.w	#1,$10(A5)
	bra	MacProcess

MacWait
	move.w	14(A6),$12(A5)
	bra	MacTryDeferWait

MacWaitOnDma
	move.w	14(A6),6(A5)
	clr.b	0(A5)
	move.w	$44(A5),$DFF09A
	bra	MacTryDeferWait

VoiceInt3
	move.b	MasterDataBlock+$36(pc),d0
	bne	lbC002040
VoiceInt
	move.w	$46(A1),$9C(a0)
	subq.w	#1,6(A1)
	bpl.s	.notend
	move.b	#$FF,(A1)
	move.w	$46(A1),$9A(a0)
.notend
	rts

MacSplitNote
	move.b	13(A6),D0
	cmp.b	5(A5),D0
	bcc	MacNull
	move.w	14(A6),$10(A5)
	bra	MacProcess

MacSplitVol
	move.b	13(A6),D0
	cmp.b	$18(A5),D0
	bcc	MacNull
	move.w	14(A6),$10(A5)
	bra	MacProcess

MacLoop
	tst.b	$1A(A5)
	beq.s	.next
	cmp.b	#$FF,$1A(A5)
	beq.s	.new
	subq.b	#1,$1A(A5)
	bra.s	.loop
.next
	st	$1A(A5)
	addq.w	#1,$10(A5)
	bra	MacProcess
.new
	move.b	13(A6),D0
	subq.b	#1,D0
	move.b	D0,$1A(A5)
.loop
	move.w	14(A6),$10(A5)
	bra	MacProcess

MacLoopKeyUp
	tst.b	$36(A5)
	bne.s	MacLoop
	addq.w	#1,$10(A5)
	bra	MacProcess

MacTimeout
	lea	InfoBlock(pc),a0
	move.w	#1,2(a0)
MacSTOP
	clr.b	0(A5)
	bra	MacDoEfx

MacAddVol
	move.w	8(A5),D0
	add.w	D0,D0
	add.w	8(A5),D0
	add.w	14(A6),D0
	move.b	D0,$18(A5)
	addq.w	#1,$10(A5)
	bra	MacProcess

MacSetVol
	move.b	15(A6),$18(A5)
	addq.w	#1,$10(A5)
	bra	MacProcess

MacPlayNote
	move.b	5(A5),12(A6)
	move.b	9(A5),D0
	lsl.b	#4,D0
	or.b	D0,14(A6)
	move.l	12(A6),D0
	bsr	NOTEPORT
	bra	MacNull

MacSetPrvNote
	move.b	4(A5),D2
	lea	MacTryDeferWait(PC),A1
	bra.s	MacDoNote

MacSetNote
	moveq	#0,D2
	lea	MacTryDeferWait(PC),A1
	bra.s	MacDoNote

MacAddNote
	move.b	5(A5),D2
	lea	MacTryDeferWait(PC),A1
MacDoNote
	move.b	13(A6),D0
	add.b	D2,D0
	and.b	#$3F,D0
	ext.w	D0
	add.w	D0,D0
	lea	NoteTable(PC),A0
	move.w	0(A0,D0.W),D0
	move.w	10(A5),D1
	add.w	14(A6),D1
	beq.s	.nodetune
	add.w	#$100,D1
	mulu	D1,D0
	lsr.l	#8,D0
.nodetune
	move.w	D0,$28(A5)
	tst.w	$30(A5)
	bne.s	.isporta
	move.w	D0,$58(A5)
.isporta
	jmp	(A1)

MacSetPeriod
	move.w	14(A6),$28(A5)
	tst.w	$30(A5)
	bne	MacNull
	move.w	14(A6),$58(A5)
	bra	MacNull

MacPorta
	move.b	13(A6),$22(A5)
	move.b	#1,$23(A5)
	tst.w	$30(A5)
	bne.s	.already
	move.w	$28(A5),$32(A5)
.already
	move.w	14(A6),$30(A5)
	bra	MacNull

MacVibrato
	move.b	13(A6),D0
	move.b	D0,$26(A5)
	lsr.b	#1,D0
	move.b	D0,$27(A5)
	move.b	15(A6),$20(A5)
	move.b	#1,$21(A5)
	tst.w	$30(A5)
	bne	MacNull
	move.w	$28(A5),$58(A5)
	clr.w	$24(A5)
	addq.w	#1,$10(A5)
	bra	MacProcess

MacEnvelope
	move.b	14(A6),$1C(A5)
	move.b	13(A6),$1F(A5)
	move.b	14(A6),$1D(A5)
	move.b	15(A6),$1E(A5)
	addq.w	#1,$10(A5)
	bra	MacProcess

MacReset
	clr.b	3(A5)
	clr.b	$1C(A5)
	clr.b	$26(A5)
	clr.w	$30(A5)
	clr.w	cdb_SIDSize(A5)
	sf	cdb_SIDSaveState(a5)
	bra	MacNull

MacWaitKeyUp
	tst.b	$36(A5)
	beq	MacNull
	tst.b	$1A(A5)
	beq.s	.next
	cmp.b	#$FF,$1A(A5)
	beq.s	.new
	subq.b	#1,$1A(A5)
	bra.s	.loop
.next
	st	$1A(A5)
	bra	MacNull
.new
	move.b	15(A6),D0
	subq.b	#1,D0
	move.b	D0,$1A(A5)
.loop
	bra	MacDoEfx

MacGoSubmacro
	move.l	12(A5),$38(A5)
	move.w	$10(A5),$40(A5)
MacCont
	move.b	13(A6),D0
	and.l	#$7F,D0
	move.l	$2A(A6),A0
	add.w	D0,D0
	add.w	D0,D0
	add.w	D0,A0
	move.l	(A0),D0
	add.l	0(A6),D0
	move.l	D0,12(A5)
	move.w	14(A6),$10(A5)
	st	$1A(A5)
	bra	MacProcess

MacReturnOldMacro
	move.l	$38(A5),12(A5)
	move.w	$40(A5),$10(A5)
	bra	MacNull

MacSampleLoop
	move.l	12(A6),D0
	add.l	D0,$2C(A5)
	move.l	$2C(A5),(A4)
	lsr.w	#1,D0
	sub.w	D0,$34(A5)
	move.w	$34(A5),4(A4)
	addq.w	#1,$10(A5)
	bra	MacProcess

MacSetOneShot
	clr.b	3(A5)
	move.l	4(A6),$2C(A5)
	move.l	4(A6),(A4)
	move.w	#1,$34(A5)
	move.w	#1,4(A4)
	addq.w	#1,$10(A5)
	bra	MacProcess

	dc.b "BREAKPOINT ME HERE"
	even
mac_22	; set source sample and start filter
	clr.b	cdb_AddBeginTime(A5)
	move.l	mdb_LongStore(A6),D0
	add.l	mdb_SmplBase(A6),D0
	move.l	D0,cdb_SIDSrcSample(A5)
	move.l	D0,cdb_CurAddr(A5)
	move.l	mdb_SmplBase(A6),D0
	add.l	cdb_WorkBase(A5),D0
	move.l	D0,(A4)
	bra	MacNull

mac_23	; set sid filter stuff length
	move.w	mdb_LongStore(A6),D0
	bne.s	.not100
	move.w	#$100,D0
.not100
	lsr.w	#1,D0
	move.w	D0,4(A4)
	move.w	mdb_LongStore(A6),D0
	subq.w	#1,D0
	and.w	#$FF,D0
	move.w	D0,cdb_SIDSize(A5)
	move.w	mdb_LongStore+2(A6),cdb_SIDSrcLength(A5)
	move.w	mdb_LongStore+2(A6),cdb_CurrLength(A5)	;saved sample len
	bra	MacNull

mac_24	; sid vib 2 ofs
	move.l	mdb_LongStore(A6),D0
	lsl.l	#8,D0
	move.l	D0,cdb_SIDVib2Ofs(A5)
	bra	MacNull

mac_26	; sid vib ofs
	move.l	mdb_LongStore(A6),cdb_SIDVibOfs(A5)
	bra	MacNull

mac_25	; sid vib 2 speed/width
	move.w	mdb_LongStore(A6),cdb_SIDVib2Time(A5)
	move.w	mdb_LongStore(A6),cdb_SIDVib2Reset(A5)
	move.w	mdb_LongStore+2(A6),cdb_SIDVib2Width(A5)
	bra	MacNull

mac_27	; sid vib speed/width
	move.w	mdb_LongStore(A6),cdb_SIDVibTime(A5)
	move.w	mdb_LongStore(A6),cdb_SIDVibReset(A5)
	move.w	mdb_LongStore+2(A6),cdb_SIDVibWidth(A5)
	bra	MacNull

mac_28	; sid filter time constant
	move.b	mdb_LongStore+3(A6),cdb_SIDFilterTC(A5)
	move.b	mdb_LongStore+2(A6),D0
	ext.w	D0
	lsl.w	#4,D0
	move.w	D0,cdb_SIDFilterWidth(A5)
	move.w	mdb_LongStore(A6),cdb_SIDFilterTime(A5)
	move.w	mdb_LongStore(A6),cdb_SIDFilterReset(A5)
	bra	MacNull

mac_29	; clear sid
	clr.w	cdb_SIDSize(A5)
	tst.b	mdb_LongStore+1(A6)
	beq	MacNull
	clr.l	cdb_SIDVib2Ofs(A5)
	clr.w	cdb_SIDVib2Time(A5)
	clr.w	cdb_SIDVib2Reset(A5)
	clr.w	cdb_SIDVib2Width(A5)
	clr.l	cdb_SIDVibOfs(A5)
	clr.w	cdb_SIDVibTime(A5)
	clr.w	cdb_SIDVibReset(A5)
	clr.w	cdb_SIDVibWidth(A5)
	clr.b	cdb_SIDFilterTC(A5)
	clr.w	cdb_SIDFilterWidth(A5)
	clr.w	cdb_SIDFilterTime(A5)
	clr.w	cdb_SIDFilterReset(A5)
	clr.b	cdb_SIDSaveState(A5)
	bra	MacNull

MacDoEfx
	tst.b	1(A5)
	bmi.s	lbC000E36
	bne.s	lbC000E3A
	move.b	#1,1(A5)
lbC000E36
	bra	lbC000F56

lbC000E3A
	tst.b	3(A5)
	beq.s	lbC000E60
	move.l	$2C(A5),D0
	add.l	$50(A5),D0
	move.l	D0,$2C(A5)
	move.l	D0,(A4)
	sub.b	#1,3(A5)
	bne.s	lbC000E60
	move.b	$1B(A5),3(A5)
	neg.l	$50(A5)
lbC000E60

	tst.w	cdb_SIDSize(A5)
	beq	.nosid
; SID simulator stuff

	move.l	cdb_SIDSrcSample(A5),A0
	move.l	cdb_SIDVib2Ofs(A5),D4
	move.l	cdb_SIDVibOfs(A5),D5
	move.l	cdb_WorkBase(A5),A1
	add.l	mdb_SmplBase(A6),A1
	move.w	cdb_SIDSize(A5),D7
	move.w	cdb_SIDSrcLength(A5),D6
	move.b	cdb_SIDFilterTC(A5),D3
	moveq	#0,D0
	move.b	cdb_SIDSaveState(A5),D1
.sidlp
	add.l	D5,D4
	swap	D0
	add.l	D4,D0
	swap	D0
	and.w	D6,D0
	move.b	0(A0,D0.W),D2
	tst.b	D3
	beq.s	.copy
	cmp.b	D1,D2
	beq.s	.copy2
	bgt.s	.filter
	subx.b	D3,D1
	bvs.s	.copy2
	cmp.b	D1,D2
	bge.s	.copy2
.put1
	move.b	D1,(A1)+
	dbra	D7,.sidlp
	bra.s	.sidfinish
.filter
	addx.b	D3,D1
	bvs.s	.copy2
	cmp.b	D1,D2
	bgt.s	.put1
.copy2
	move.b	D2,D1
.copy
	move.b	D2,(A1)+
	dbra	D7,.sidlp

.sidfinish
	move.b	D1,cdb_SIDSaveState(A5)
	tst.b	D3
	beq.s	.noflip
	move.w	cdb_SIDFilterWidth(A5),D0
	add.w	D0,cdb_SIDFilterTC(A5)
	subq.w	#1,cdb_SIDFilterTime(A5)
	bne.s	.noflip
	move.w	cdb_SIDFilterReset(A5),cdb_SIDFilterTime(A5)
	neg.w	cdb_SIDFilterWidth(A5)
.noflip
	move.w	cdb_SIDVib2Width(A5),D0
	ext.l	D0
	add.l	D0,cdb_SIDVib2Ofs(A5)
	subq.w	#1,cdb_SIDVib2Time(A5)
	bne.s	.noflip2
	move.w	cdb_SIDVib2Reset(A5),cdb_SIDVib2Time(A5)
	beq.s	.noflip2
	neg.w	cdb_SIDVib2Width(A5)
.noflip2
	move.w	cdb_SIDVibWidth(A5),D0
	ext.l	D0
	add.l	D0,cdb_SIDVibOfs(A5)
	subq.w	#1,cdb_SIDVibTime(A5)
	bne.s	.nosid
	move.w	cdb_SIDVibReset(A5),cdb_SIDVibTime(A5)
	beq.s	.nosid
	neg.w	cdb_SIDVibWidth(A5)
.nosid

	tst.b	$26(A5)
	beq.s	lbC000EAA
	move.b	$20(A5),D0
	ext.w	D0
	add.w	D0,$24(A5)
	move.w	$28(A5),D0
	move.w	$24(A5),D1
	beq.s	lbC000E8A
	and.l	#$FFFF,D0
	add.w	#$800,D1
	mulu	D1,D0
	lsl.l	#5,D0
	swap	D0
lbC000E8A
	tst.w	$30(A5)
	bne.s	lbC000E94
	move.w	D0,$58(A5)
lbC000E94
	subq.b	#1,$27(A5)
	bne.s	lbC000EAA
	move.b	$26(A5),$27(A5)
	eor.b	#$FF,$20(A5)
	addq.b	#1,$20(A5)
lbC000EAA
	tst.w	$30(A5)
	beq.s	lbC000F08
	subq.b	#1,$23(A5)
	bne.s	lbC000F08
	move.b	$22(A5),$23(A5)
	move.w	$28(A5),D1
	moveq	#0,D0
	move.w	$32(A5),D0
	cmp.w	D1,D0
	beq.s	lbC000EDE
	bcs.s	lbC000EF4
	move.w	#$100,D2
	sub.w	$30(A5),D2
	mulu	D2,D0
	lsr.l	#8,D0
	cmp.w	D1,D0
	beq.s	lbC000EDE
	bcc.s	lbC000EE6
lbC000EDE
	clr.w	$30(A5)
	move.w	$28(A5),D0
lbC000EE6
	and.w	#$7FF,D0
	move.w	D0,$32(A5)
	move.w	D0,$58(A5)
	bra.s	lbC000F08

lbC000EF4
	move.w	$30(A5),D2
	add.w	#$100,D2
	mulu	D2,D0
	lsr.l	#8,D0
	cmp.w	D1,D0
	beq.s	lbC000EDE
	bcc.s	lbC000EDE
	bra.s	lbC000EE6

lbC000F08
	tst.b	$1C(A5)
	beq.s	lbC000F56
	tst.b	$1D(A5)
	beq.s	lbC000F1A
	subq.b	#1,$1D(A5)
	bra.s	lbC000F56

lbC000F1A
	move.b	$1C(A5),$1D(A5)
	move.b	$1E(A5),D0
	cmp.b	$18(A5),D0
	bgt.s	lbC000F48
	move.b	$1F(A5),D1
	sub.b	D1,$18(A5)
	bmi.s	lbC000F3C
	cmp.b	$18(A5),D0
	bge.s	lbC000F3C
	bra.s	lbC000F56

lbC000F3C
	move.b	$1E(A5),$18(A5)
	clr.b	$1C(A5)
	bra.s	lbC000F56

lbC000F48
	move.b	$1F(A5),D1
	add.b	D1,$18(A5)
	cmp.b	$18(A5),D0
	ble.s	lbC000F3C
lbC000F56
	tst.b	11(A6)
	beq.s	lbC000F7E
	subq.b	#1,$1C(A6)
	bne.s	lbC000F7E
	move.b	$1D(A6),$1C(A6)
	move.b	11(A6),D0
	add.b	D0,$1A(A6)
	move.b	$1B(A6),D0
	cmp.b	$1A(A6),D0
	bne.s	lbC000F7E
	clr.b	11(A6)
lbC000F7E
	moveq	#0,D1
	move.b	$1A(A6),D1
	moveq	#0,D0
	move.b	$18(A5),D0
	tst.b	$36(A6)
	beq.s	lbC000FA2
	tst.l	$5C(A5)
	beq.s	lbC000FA2
	move.w	D1,$DFF0D8
	move.w	D0,8(A4)
	bra.s	lbC000FBA

lbC000FA2
	tst.w	$3E(A5)
	bpl.s	lbC000FB6
	btst	#6,D1
	bne.s	lbC000FB6
	add.w	D0,D0
	add.w	D0,D0
	mulu	D1,D0
	lsr.w	#8,D0
lbC000FB6
	move.w	D0,8(A4)
lbC000FBA
	rts

NOTEPORT
	movem.l	D0/A4-A6,-(SP)
	lea	MasterDataBlock(PC),A6
	move.l	12(A6),-(SP)
	lea	VoiceIndirects(PC),A5
	move.l	D0,12(A6)
	move.b	14(A6),D0
	and.w	#15,D0
	cmp.w	#3,D0
	beq.s	lbC000FF2
	ble.s	lbC000FFC
	cmp.w	#7,D0
	bgt.s	lbC000FFC
	tst.b	$36(A6)
	bne.s	lbC000FFC
	bsr	RawSetSpeed
	bra.s	lbC000FFC

lbC000FF2
	tst.b	$36(A6)
	beq.s	lbC000FFC
	bsr	lbC001DD8
lbC000FFC
	add.w	D0,D0
	add.w	D0,D0
	move.l	0(A5,D0.W),A5
	move.b	12(A6),D0
	cmp.b	#$FC,D0
	bne.s	lbC001020
	move.b	13(A6),$3C(A5)
	move.b	15(A6),D0
	move.w	D0,$3E(A5)
	bra	lbC0010FA

lbC001020
	tst.b	$3C(A5)
	bne	lbC0010FA
	tst.b	D0
	bpl	lbC001090
	cmp.b	#$F7,D0
	bne.s	lbC001054
	move.b	13(A6),$1F(A5)
	move.b	14(A6),D0
	lsr.b	#4,D0
	addq.b	#1,D0
	move.b	D0,$1D(A5)
	move.b	D0,$1C(A5)
	move.b	15(A6),$1E(A5)
	bra	lbC0010FA

lbC001054
	cmp.b	#$F6,D0
	bne.s	lbC00107E
	move.b	13(A6),D0
	and.b	#$FE,D0
	move.b	D0,$26(A5)
	lsr.b	#1,D0
	move.b	D0,$27(A5)
	move.b	15(A6),$20(A5)
	move.b	#1,$21(A5)
	clr.w	$24(A5)
	bra.s	lbC0010FA

lbC00107E
	cmp.b	#$F5,D0
	bne.s	lbC00108A
	clr.b	$36(A5)
	bra.s	lbC0010FA

lbC00108A
	cmp.b	#$BF,D0
	bcc.s	lbC001104
lbC001090
	move.b	15(A6),D0
	ext.w	D0
	move.w	D0,10(A5)
	move.b	14(A6),D0
	lsr.b	#4,D0
	and.w	#15,D0
	move.b	D0,9(A5)
	move.b	13(A6),D0
	move.b	5(A5),4(A5)
	move.b	12(A6),5(A5)
	move.l	$2A(A6),A4
	add.w	D0,D0
	add.w	D0,D0
	add.w	D0,A4
	move.l	(A4),A4
	add.l	0(A6),A4
	move.l	A4,12(A5)
	clr.w	$10(A5)
	clr.w	$12(A5)
	clr.b	1(A5)
	st	$1A(A5)
	st	0(A5)
	clr.w	6(A5)
	move.w	$46(A5),$DFF09A
	move.w	$46(A5),$DFF09C
	move.b	#1,$36(A5)
lbC0010FA
	move.l	(SP)+,12(A6)
	movem.l	(SP)+,D0/A4-A6
	rts

lbC001104
	move.b	13(A6),$22(A5)
	move.b	#1,$23(A5)
	tst.w	$30(A5)
	bne.s	lbC00111C
	move.w	$28(A5),$32(A5)
lbC00111C
	clr.w	$30(A5)
	move.b	15(A6),$31(A5)
	move.b	12(A6),D0
	and.w	#$3F,D0
	move.b	D0,5(A5)
	add.w	D0,D0
	lea	NoteTable(PC),A4
	move.w	0(A4,D0.W),$28(A5)
	bra.s	lbC0010FA

CHANNELOFF
	move.l	A5,-(SP)
	lea	VoiceIndirects(PC),A5
	and.w	#15,D0
	add.w	D0,D0
	add.w	D0,D0
	move.l	0(A5,D0.W),A5
	tst.b	$3C(A5)
	bne.s	lbC001184
	move.w	$46(A5),$DFF09A
	move.w	$16(A5),$DFF096
	clr.b	0(A5)
	move.l	A0,-(SP)
	move.l	$5C(A5),A0
	cmp.l	#0,A0
	beq.s	lbC001182
	clr.b	(A0)
	move.l	$60(A5),A0
	jsr	(A0)
lbC001182
	move.l	(SP)+,A0
lbC001184
	move.l	(SP)+,A5
	rts

FADE
	movem.l	A5/A6,-(SP)
	lea	MasterDataBlock(PC),A6
	move.b	D0,$1B(A6)
	swap	D0
	move.b	D0,$1C(A6)
	move.b	D0,$1D(A6)
	beq.s	lbC0011B8
	move.b	$1A(A6),D0
	move.b	#1,11(A6)
	cmp.b	$1B(A6),D0
	beq.s	lbC0011BE
	bcs.s	lbC0011C2
	neg.b	11(A6)
	bra.s	lbC0011C2

lbC0011B8
	move.b	$1B(A6),$1A(A6)
lbC0011BE
	clr.b	11(A6)
lbC0011C2
	movem.l	(SP)+,A5/A6
	rts

INFO
	move.l	A1,-(SP)
	lea	InfoBlock(PC),A0
	lea	PseudoMasterDataBlock(PC),A1
	move.l	A1,4(A0)
	lea	VoiceIndirects(PC),A1
	move.l	A1,8(A0)
	lea	PatternDataBlock(PC),A1
	move.l	A1,12(A0)
	lea	VectorDataBlock+vdb_VertBData-2(PC),A1
	move.l	A1,$10(A0)
	move.l	(SP)+,A1
	rts

PROSFX
	movem.l	D1-D3/A4-A6,-(SP)
	lea	MasterDataBlock(PC),A6
	lea	VoiceIndirects(PC),A4
	move.w	D0,D2
	move.l	0(A6),A5
	tst.l	$1D0(A5)
	bne.s	lbC0011EA
	move.l	$5FC(A5),A5
	add.l	0(A6),A5
	bra.s	lbC0011EE

lbC0011EA
	move.l	$2E(A6),A5
lbC0011EE
	lsl.w	#3,D2
	move.b	2(A5,D2.W),D3
	tst.b	10(A6)
	bpl.s	lbC0011FE
	move.b	4(A5,D2.W),D3
lbC0011FE
	and.w	#15,D3
	add.w	D3,D3
	add.w	D3,D3
	move.l	0(A4,D3.W),A4
	lsl.w	#6,D3
	move.b	5(A5,D2.W),D1
	bclr	#7,D1
	cmp.b	$3D(A4),D1
	bcc.s	lbC001220
	tst.w	$3E(A4)
	bpl.s	lbC001252
lbC001220
	cmp.b	$42(A4),D2
	bne.s	lbC001234
	tst.w	$3E(A4)
	bmi.s	lbC001234
	btst	#7,5(A5,D2.W)
	bne.s	lbC001252
lbC001234
	move.l	0(A5,D2.W),D0
	and.l	#$FFFFF0FF,D0
	or.w	D3,D0
	move.l	D0,$54(A4)
	move.b	D1,$3D(A4)
	move.w	6(A5,D2.W),$3E(A4)
	move.b	D2,$42(A4)
lbC001252
	movem.l	(SP)+,D1-D3/A4-A6
	rts

lbC001258
	clr.b	0(A6)
	clr.l	$3C(A6)
	rts

ALLOFF
	move.l	A6,-(SP)
	lea	InfoBlock(pc),a6
	clr.w	2(a6)
	lea	MasterDataBlock(PC),A6
	clr.b	$12(A6)
	clr.w	$32(A6)
	sf	$36(a6)
	lea	Voice0Data(PC),A6
	bsr.s	lbC001258
	lea	Voice1Data(PC),A6
	bsr.s	lbC001258
	lea	Voice2Data(PC),A6
	bsr.s	lbC001258
	lea	Voice3Data(PC),A6
	bsr.s	lbC001258
	lea	Voice4Data(PC),A6
	bsr.s	lbC001258
	lea	Voice5Data(PC),A6
	bsr.s	lbC001258
	lea	Voice6Data(PC),A6
	bsr.s	lbC001258
	lea	Voice7Data(PC),A6
	bsr.s	lbC001258
	bsr	lbC001DD8
	clr.w	$DFF0A8
	clr.w	$DFF0B8
	clr.w	$DFF0C8
	clr.w	$DFF0D8
	move.w	#15,$DFF096
	move.w	#$780,$DFF09C
	move.w	#$780,$DFF09A
	move.w	#$780,$DFF09C
	move.l	(SP)+,A6
	rts

SONGPLAY
	movem.l	D1-D7/A0-A6,-(SP)
	lea	MasterDataBlock(PC),A6
	move.l	#$40400000,$1A(A6)
	sf	11(A6)
	move.b	D0,$19(A6)
	clr.b	$1F(A6)
	bsr.s	lbC001314
	movem.l	(SP)+,D1-D7/A0-A6
	rts

XPLAYNOQUIET
	movem.l	D1-D7/A0-A6,-(SP)
	lea	MasterDataBlock(PC),A6
	move.b	D0,$19(A6)
	move.b	#2,$18(a6)
	clr.b	$1F(A6)
	bsr.s	lbC001314
	movem.l	(SP)+,D1-D7/A0-A6
	rts

PLAYCONT
	movem.l	D1-D7/A0-A6,-(SP)
	lea	MasterDataBlock(PC),A6
	or.w	#$100,D0
	move.w	D0,$18(A6)
	clr.b	$1F(A6)
	bsr.s	lbC001314
	movem.l	(SP)+,D1-D7/A0-A6
	rts

lbC001314
	btst	#1,$18(a6)
	bne.s	.noquiet
	bsr	ALLOFF
.noquiet
	clr.b	$12(A6)
	move.l	0(A6),A4
	move.b	$19(A6),D0
	and.w	#$1F,D0
	add.w	D0,D0
	add.w	D0,A4
	lea	PatternDataBlock(PC),A5
	move.b	10(A6),D1
	bmi	.cantcont
	and.w	#$1F,D1
	add.w	D1,D1
	lea	ContDataBlock(PC),A0
	add.w	D1,A0
	move.w	4(A5),(A0)
	move.b	7(A5),$41(A0)
	move.w	-2(A5),$C0(A0)
.cantcont
	move.w	$100(A4),4(A5)
	move.w	$100(A4),0(A5)
	move.w	$140(A4),2(A5)
	move.w	$180(A4),D2

	moveq	#125,d3

	btst	#0,$18(A6)
	beq.s	.nocont
	lea	ContDataBlock(PC),A0
	add.w	D0,A0
	move.w	(A0),4(A5)
	moveq	#0,D2
	moveq	#0,d0
	move.b	$41(A0),D2
	move.w	$C0(a0),d3
.nocont
	moveq.w	#$1C,D1
	lea	NullPat(PC),A4
.cleartrlp
	move.l	A4,$28(A5,D1.W)
	move.w	#$FF00,$48(A5,D1.W)
	clr.l	$68(A5,D1.W)
	subq.w	#4,D1
	bpl.s	.cleartrlp
	clr.w	6(A5)
	cmp.w	#$10,d2
	bhs.s	.iscia
	move.w	D2,6(A5)
	bra.s	.wascia
.iscia
	move.w	d2,d3
.wascia
	move.w	d3,-2(a5)
	cmp.b	#$EF,-2(a5)
	beq.s	.is7v
	move.w	d3,d0
	bsr	SetCIATempo
	bra.s	.gettrack
.is7v
	ext.w	d3
	move.w	d3,$3A(a6)
	bsr	RawSetSpeed
.gettrack
	tst.b	$19(A6)
	bmi.s	.notrack
	move.l	0(A6),A4
	bsr	NewTrackStep
.notrack
	clr.b	9(A6)
	clr.w	$10(A6)
	st	$20(A6)
	move.b	$19(A6),10(A6)
	clr.b	$18(A6)
	clr.w	$32(A6)
	bset	#1,$BFE001
	move.w	#$FF,$DFF09E
	move.b	#1,$12(A6)
	tst.b	$36(A6)
	beq.s	.nostart7v
	move.w	#$8208,$DFF096
	move.w	#$C400,$DFF09A
	move.w	#$8400,$DFF09C
.nostart7v
	rts

INITDATA
	movem.l	d0-d7/A0-A6,-(SP)
	lea	MasterDataBlock(PC),A6
	move.w	d3,$38(A6)
	move.l	#$40400000,$1A(A6)
	clr.b	11(A6)
	move.l	D0,0(A6)
	move.l	D1,4(A6)
	move.l	D2,$3C(A6)
	move.l	D1,A4
	clr.l	(A4)

	move.l	D0,A4
	move.l	#$800,D1
	add.l	D0,D1
	move.l	D1,$22(A6)
	move.l	#$400,D1
	add.l	D0,D1
	move.l	D1,$26(A6)
	move.l	#$600,D1
	add.l	D0,D1
	move.l	D1,$2A(A6)

	lea	PatternDataBlock(PC),A5
	move.w	#5,6(A5)
	move.w	#125,-2(a5)
	lea	ContDataBlock(PC),A6
	move.w	#$1F,D0
lbC00149C
	move.w	#$05,$40(A6)
	move.w	#$007D,$C0(a6)
	clr.w	$80(A6)
	clr.w	(A6)+
	dbra	D0,lbC00149C
	lea	MasterDataBlock(PC),A6
	lea	VoiceIndirects(PC),A4
	lea	Voice0Data(PC),A5
	move.l	A5,(A4)+
	lea	Voice1Data(PC),A5
	move.l	A5,(A4)+
	lea	Voice2Data(PC),A5
	move.l	A5,(A4)+
	lea	Voice3Data(PC),A5
	move.l	A5,(A4)+
	moveq	#11,D0
lbC0014CE
	move.l	-$10(A4),(A4)+
	dbra	D0,lbC0014CE
	lea	Voice4Indirect(PC),A4
	lea	Voice4Data(PC),A5
	lea	lbL002612(PC),A3
	move.l	A3,$4C(A5)
	lea	lbC001F0E(PC),A3
	move.l	A3,$60(A5)
	lea	lbL00268E(PC),A2
	move.l	A2,$5C(A5)
	move.l	A5,(A4)+
	lea	Voice5Data(PC),A5
	lea	lbL002622(PC),A3
	move.l	A3,$4C(A5)
	lea	lbC001F34(PC),A3
	move.l	A3,$60(A5)
	addq.l	#4,A2
	move.l	A2,$5C(A5)
	move.l	A5,(A4)+
	lea	Voice6Data(PC),A5
	lea	lbL002632(PC),A3
	move.l	A3,$4C(A5)
	lea	lbC001F5A(PC),A3
	move.l	A3,$60(A5)
	addq.l	#4,A2
	move.l	A2,$5C(A5)
	move.l	A5,(A4)+
	lea	Voice7Data(PC),A5
	lea	lbL002642(PC),A3
	move.l	A3,$4C(A5)
	lea	lbC001F80(PC),A3
	move.l	A3,$60(A5)
	addq.l	#4,A2
	move.l	A2,$5C(A5)
	move.l	A5,(A4)+
	move.l	$3C(A6),$40(A6)
	move.l	$3C(A6),$44(A6)
	move.l	$3C(A6),$48(A6)
	add.l	#$1E0,$44(A6)
	add.l	#$3C0,$48(A6)
	bsr	lbC001EA2
	movem.l	(SP)+,d0-d7/A0-A6
	rts

PseudoMasterDataBlock
	dcb.l	$40,0

	dc.w	0
MasterDataBlock
	dcb.l	4,0

	dcb.l	2,0
	dc.w	0
	dc.b	$40,$40
	dc.l	0

	dc.l	$FFFF0000
	dcb.l	$3,0

	dc.l	0
	dc.l	0
	dc.w	$10
	dc.w	0
	dc.l	0

	dcb.l	4,0

VoiceIndirects
	dcb.l	$4,0
Voice4Indirect
	dcb.l	$C,0

Voice0Data
	dcb.l	$5,0
	dc.l	$82010001
	dcb.l	$B,0
	dc.l	$80800080
	dc.l	Voice1Data-Voice0Data
	dc.l	$DFF0A0
	dcb.l	$2,0
	dc.l	$FF00
	dcb.l	$B,0
	dc.l	4,0
Voice1Data
	dcb.l	$5,0
	dc.l	$82020002
	dcb.l	$B,0
	dc.l	$81000100
	dc.l	Voice1Data-Voice0Data
	dc.l	$DFF0B0
	dcb.l	$2,0
	dc.l	$FF00
	dcb.l	$B,0
	dc.l	$104,0
Voice2Data
	dcb.l	$5,0
	dc.l	$82040004
	dcb.l	$B,0
	dc.l	$82000200
	dc.l	Voice1Data-Voice0Data
	dc.l	$DFF0C0
	dcb.l	$2,0
	dc.l	$FF00
	dcb.l	$B,0
	dc.l	$204,0
Voice3Data
	dcb.l	$5,0
	dc.l	$82080008
	dcb.l	$B,0
	dc.l	$84000400
	dc.l	Voice0Data-Voice1Data
	dc.l	$DFF0D0
	dcb.l	$2,0
	dc.l	$FF00
	dcb.l	$B,0
	dc.l	$304,0
Voice4Data
	dcb.l	$6,0
	dc.l	$40000000
	dcb.l	$B,0
	dc.l	Voice1Data-Voice0Data
	dc.l	$DFF0D0
	dcb.l	$2,0
	dc.l	$FF00
	dcb.l	$B,0
	dc.l	$404,0
Voice5Data
	dcb.l	$6,0
	dc.l	$40000000
	dcb.l	$B,0
	dc.l	Voice1Data-Voice0Data
	dc.l	$DFF0D0
	dcb.l	$2,0
	dc.l	$FF00
	dcb.l	$B,0
	dc.l	$504,0
Voice6Data
	dcb.l	$6,0
	dc.l	$40000000
	dcb.l	$B,0
	dc.l	Voice1Data-Voice0Data
	dc.l	$DFF0D0
	dcb.l	$2,0
	dc.l	$FF00
	dcb.l	$B,0
	dc.l	$604,0
Voice7Data
	dcb.l	$6,0
	dc.l	$40000000
	dcb.l	$B,0
	dc.l	Voice0Data-Voice1Data
	dc.l	$DFF0D0
	dcb.l	$2,0
	dc.l	$FF00
	dcb.l	$B,0
	dc.l	$704,0
InfoBlock
	dcb.l	10,0

	dc.w	$7D
PatternDataBlock
	dc.l	0
	dc.l	5
	dcb.l	$30,0
ContDataBlock
	dcb.l	$40,0
NullPat
	dc.l	$F4000000
	dc.l	$F0000000
NoteTable
	dc.w	$6AE
	dc.w	$64E
	dc.w	$5F4
	dc.w	$59E
	dc.w	$54D
	dc.w	$501
	dc.w	$4B9
	dc.w	$475
	dc.w	$435
	dc.w	$3F9
	dc.w	$3C0
	dc.w	$38C
	dc.w	$358
	dc.w	$32A
	dc.w	$2FC
	dc.w	$2D0
	dc.w	$2A8
	dc.w	$282
	dc.w	$25E
	dc.w	$23B
	dc.w	$21B
	dc.w	$1FD
	dc.w	$1E0
	dc.w	$1C6
	dc.w	$1AC
	dc.w	$194
	dc.w	$17D
	dc.w	$168
	dc.w	$154
	dc.w	$140
	dc.w	$12F
	dc.w	$11E
	dc.w	$10E
	dc.w	$FE
	dc.w	$F0
	dc.w	$E3
	dc.w	$D6
	dc.w	$CA
	dc.w	$BF
	dc.w	$B4
	dc.w	$AA
	dc.w	$A0
	dc.w	$97
	dc.w	$8F
	dc.w	$87
	dc.w	$7F
	dc.w	$78
	dc.w	$71
	dc.w	$D6
	dc.w	$CA
	dc.w	$BF
	dc.w	$B4
	dc.w	$AA
	dc.w	$A0
	dc.w	$97
	dc.w	$8F
	dc.w	$87
	dc.w	$7F
	dc.w	$78
	dc.w	$71
	dc.w	$D6
	dc.w	$CA
	dc.w	$BF
	dc.w	$B4

	even

	opt	o-

RawSetSpeed
	movem.l	D0-D7/A0-A6,-(SP)
	move.w	#$400,$DFF09A
	lea	MasterDataBlock(PC),A6
	lea	Voice3Data(PC),A4
	lea	EmulatorBlock(PC),A5
	move.w	$38(A6),D0
	cmp.w	#$16,D0
	ble.s	lbC001D1A
	moveq	#$16,D0
lbC001D1A
	move.w	D0,D1
	mulu	#$64,D1
	divu	#5,D1
	moveq	#$64,D3
	cmp.w	#$FFE0,$3A(A6)
	bge.s	lbC001D34
	move.w	#$FFE0,$3A(A6)
lbC001D34
	add.w	$3A(A6),D3
	mulu	D3,D1
	divu	#$64,D1
	addq.l	#1,D1
	and.b	#$FE,D1
	move.w	D1,D2
	lsr.w	#1,D2
	move.w	D2,$72(A5)
	subq.w	#1,D1
	move.w	D1,$70(A5)
	move.l	#(3579545+500)/1000,d1
	divu	d0,d1
	moveq	#0,d2
	move.w	d1,d2
	lsl.l	#8,D2
	lsl.l	#3,D2
	move.w	D1,$58(A4)
	move.w	D1,$DFF0D6
	and.w	#$FFF7,$34(A6)
	move.l	D2,$74(A5)
	move.l	$40(A6),$64(A5)
	move.l	$44(A6),$68(A5)
	move.l	$48(A6),$6C(A5)
	move.w	#0,$DFF0D8
	move.l	$64(A5),$DFF0D0
	move.w	#2,$DFF0D4
	move.w	#$8208,$4C(A6)
	move.w	#$C400,$DFF09A
	bsr	lbC001F0E
	bsr	lbC001F34
	bsr	lbC001F5A
	bsr	lbC001F80
	tst.b	$36(A6)
	bne.s	lbC001DD2
	move.w	#$8400,$DFF09C
	st	$36(A6)
lbC001DD2
	movem.l	(SP)+,D0-D7/A0-A6
	rts

lbC001DD8
	movem.l	D0-D7/A0-A6,-(SP)
	lea	MasterDataBlock(PC),A6
	clr.w	$4C(A6)
	lea	EmulatorBlock(PC),A5
	clr.b	$36(A6)
	clr.b	$37(A6)
	moveq	#3,D0
	bsr	CHANNELOFF
	lea	lbL00268E(PC),A5
	clr.l	(A5)+
	clr.l	(A5)+
	clr.l	(A5)+
	clr.l	(A5)+
	lea	EmulatorBlock(PC),A5
	move.w	#$D0,D0
	move.w	D0,$2E(A5)
	move.w	D0,$3E(A5)
	move.w	D0,$4E(A5)
	move.w	D0,$5E(A5)
	moveq	#0,D0
	move.l	D0,0(A5)
	move.l	D0,4(A5)
	move.l	D0,8(A5)
	move.l	D0,12(A5)
	sf	$60(A5)
	sf	$61(A5)
	sf	$62(A5)
	sf	$63(A5)
	move.l	#$FFF0,D0
	move.l	D0,D1
	move.l	D0,D2
	move.l	D0,D3
	move.l	$48(A6),A0
	move.l	A0,A1
	move.l	A0,A2
	move.l	A0,A3
	move.l	A0,$2A(A5)
	move.l	A0,$3A(A5)
	move.l	A0,$4A(A5)
	move.l	A0,$5A(A5)
	movem.l	D0-D3/A0-A3,$78(A5)
	bsr	lbC001F0E
	bsr	lbC001F34
	bsr	lbC001F5A
	bsr	lbC001F80
	move.l	$3C(A6),A5
	move.w	#$167,D6
lbC001E80
	clr.l	(A5)+
	dbra	D6,lbC001E80
	movem.l	(SP)+,D0-D7/A0-A6
	rts

PLAYSPEED
	movem.l	D0/A6,-(SP)
	lea	MasterDataBlock(PC),A6
	move.w	D0,$38(A6)
	tst.b	$36(a6)
	beq.s	.dont
	bsr	RawSetSpeed
.dont
	movem.l	(SP)+,D0/A6
	rts

lbC001EA2
	lea	MasterDataBlock(PC),A6
	lea	EmulatorBlock(PC),A5
	clr.b	$36(A6)
	clr.b	$37(A6)
	lea	lbL0021F2(PC),A0
	move.w	#$17F,D0
lbC001EBA
	move.b	#$80,(A0)+
	move.b	#$7F,$27F(A0)
	dbra	D0,lbC001EBA
	lea	lbL002372(PC),A0
	move.w	#$FF,D0
	move.b	#$80,D1
lbC001ED4
	move.b	D1,(A0)+
	addq.b	#1,D1
	dbra	D0,lbC001ED4
	lea	lbL00271E(PC),A0
	moveq	#0,D7
	moveq	#$3F,D0
lbC001EE4
	moveq	#0,D6
	move.w	#$FF,D1
lbC001EEA
	move.w	D6,D2
	ext.w	D2
	muls	D7,D2
	lsr.w	#6,D2
	eor.b	#$80,D2
	move.b	D2,(A0)+
	addq.w	#1,D6
	dbra	D1,lbC001EEA
	lea	$80(A0),A0
	addq.w	#1,D7
	dbra	D0,lbC001EE4
	bsr	lbC001DD8
	rts

lbC001F0E
	movem.l	D0/D1/A0-A5,-(SP)
	lea	EmulatorBlock(PC),A5
	lea	$20(A5),A0
	lea	$78(A5),A1
	lea	lbL00268E(PC),A2
	lea	0(A5),A3
	lea	$60(A5),A4
	bsr	lbC001FA6
	movem.l	(SP)+,D0/D1/A0-A5
	rts

lbC001F34
	movem.l	D0/D1/A0-A5,-(SP)
	lea	EmulatorBlock(PC),A5
	lea	$30(A5),A0
	lea	$7C(A5),A1
	lea	lbL002692(PC),A2
	lea	4(A5),A3
	lea	$61(A5),A4
	bsr	lbC001FA6
	movem.l	(SP)+,D0/D1/A0-A5
	rts

lbC001F5A
	movem.l	D0/D1/A0-A5,-(SP)
	lea	EmulatorBlock(PC),A5
	lea	$40(A5),A0
	lea	$80(A5),A1
	lea	lbL002696(PC),A2
	lea	8(A5),A3
	lea	$62(A5),A4
	bsr	lbC001FA6
	movem.l	(SP)+,D0/D1/A0-A5
	rts

lbC001F80
	movem.l	D0/D1/A0-A5,-(SP)
	lea	EmulatorBlock(PC),A5
	lea	$50(A5),A0
	lea	$84(A5),A1
	lea	lbL00269A(PC),A2
	lea	12(A5),A3
	lea	$63(A5),A4
	bsr	lbC001FA6
	movem.l	(SP)+,D0/D1/A0-A5
	rts

lbC001FA6
	tst.b	(A2)
	bne	lbC001FB2
	clr.l	(A3)
	st	(A4)
	rts

lbC001FB2
	move.l	(A0),D0
	move.w	4(A0),D1
	cmp.w	#$20,D1
	bge.s	lbC001FC6
	move.w	#$D0,D1
	move.l	$6C(A5),D0
lbC001FC6
	and.l	#$3FFF,D1
	add.l	D1,D1
	add.l	D1,D0
	move.l	D0,10(A0)
	move.w	D1,14(A0)
	tst.b	(A4)
	beq.s	lbC002004
	sf	(A4)
	move.l	(A0),D1
	move.w	4(A0),D0
	cmp.w	#$20,D0
	bge.s	lbC001FF2
	move.w	#$D0,D0
	move.l	$6C(A5),D1
lbC001FF2
	and.l	#$3FFF,D0
	add.w	D0,D0
	add.l	D0,D1
	move.l	D1,$10(A1)
	neg.l	D0
	move.l	D0,(A1)
lbC002004
	rts

lbC002006
	moveq	#0,D2
	move.w	6(A0),D0
	beq.s	lbC00203E
	move.w	8(A0),D2
	and.l	#$FF,D2
	cmp.w	#$40,D2
	blt.s	lbC002020
	moveq	#$3F,D2
lbC002020
	mulu	#$180,D2
	move.l	D3,D1
	divu	D0,D1
	and.l	#$FFFF,D1
	lsl.l	#5,D1
	swap	D1
	move.l	D1,(A2)
	add.l	A3,D2
	sub.l	A1,D2
	subq.w	#2,D2
	move.w	D2,2(A1)
lbC00203E
	rts

lbC002040
	lea	EmulatorBlock(PC),A5
	move.l	$68(A5),$DFF0D0
	move.w	$72(A5),$DFF0D4
	movem.l	D1-D7/A0-A4/A6,-(SP)
	lea	MasterDataBlock(PC),A6
	tst.b	$12(A6)
	beq	lbC002152
	lea	lbL00271E(PC),A3
	move.l	$74(A5),D3
	lea	$20(A5),A0
	lea	lbC002188(PC),A1
	lea	0(A5),A2
	bsr.s	lbC002006
	lea	$30(A5),A0
	lea	lbC002194(PC),A1
	lea	4(A5),A2
	bsr	lbC002006
	lea	$40(A5),A0
	lea	lbC0021A2(PC),A1
	lea	8(A5),A2
	bsr	lbC002006
	lea	$50(A5),A0
	lea	lbC0021B0(PC),A1
	lea	12(A5),A2
	bsr	lbC002006
	lea	$20(A5),A0
	lea	$78(A5),A1
	lea	lbL00268E(PC),A2
	lea	0(A5),A3
	lea	$60(A5),A4
	bsr	lbC001FA6
	lea	$30(A5),A0
	lea	$7C(A5),A1
	lea	lbL002692(PC),A2
	lea	4(A5),A3
	lea	$61(A5),A4
	bsr	lbC001FA6
	lea	$40(A5),A0
	lea	$80(A5),A1
	lea	lbL002696(PC),A2
	lea	8(A5),A3
	lea	$62(A5),A4
	bsr	lbC001FA6
	lea	$50(A5),A0
	lea	$84(A5),A1
	lea	lbL00269A(PC),A2
	lea	12(A5),A3
	lea	$63(A5),A4
	bsr	lbC001FA6
	move.l	$68(A5),A4
	move.l	$64(A5),$68(A5)
	move.l	A4,$64(A5)
	move.l	SP,$98(A5)
	movem.l	lbL00266A(PC),D0-D3/A0-A3
	movem.l	EmulatorBlock(PC),D6/D7/A5/A6
	moveq	#0,D4
	moveq	#0,D5
	move.w	lbW002662(PC),D5
	bra.s	lbC002182

lbC002132
	lea	EmulatorBlock(PC),A5
	movem.l	D0-D3/A0-A3,$78(A5)
	move.l	$98(A5),SP
	lea	MasterDataBlock(PC),A6
	tst.b	$1F(A6)
	bne.s	lbC002152
	st	$37(A6)
	bsr	IRQIN
lbC002152
	movem.l	(SP)+,D1-D7/A0-A4/A6
;	movem.l	(SP)+,D0/A5
	move.w	#$400,$DFF09C
	rts
;	rte

lbC002164
	move.l	lbL00261C(PC),A0
	sub.w	lbW002620(PC),D0
	bra.s	lbC0021C8

lbC00216E
	move.l	lbL00262C(PC),A1
	sub.w	lbW002630(PC),D1
	bra.s	lbC0021CE

lbC002178
	move.l	lbL00263C(PC),A2
	sub.w	lbW002640(PC),D2
	bra.s	lbC0021D4

lbC002182
	swap	D5
	move.b	0(A0,D0.W),D4
lbC002188
	lea	lbL00859E(PC),SP
	move.b	0(SP,D4.W),D4
	move.b	0(A1,D1.W),D5
lbC002194
	lea	lbL00859E(PC),SP
	move.b	0(SP,D5.W),D5
	add.w	D5,D4
	move.b	0(A2,D2.W),D5
lbC0021A2
	lea	lbL00859E(PC),SP
	move.b	0(SP,D5.W),D5
	add.w	D5,D4
	move.b	0(A3,D3.W),D5
lbC0021B0
	lea	lbL00859E(PC),SP
	move.b	0(SP,D5.W),D5
	add.w	D5,D4
	swap	D5
	move.b	lbL0021F2(PC,D4.W),(A4)+
	moveq	#0,D4
	add.l	D6,D0
	addx.w	D4,D0
	bpl.s	lbC002164
;	bcs.s	lbC002164
lbC0021C8
	add.l	D7,D1
	addx.w	D4,D1
	bpl.s	lbC00216E
;	bcs.s	lbC00216E
lbC0021CE
	add.l	A5,D2
	addx.w	D4,D2
	bpl.s	lbC002178
;	bcs.s	lbC002178
lbC0021D4
	add.l	A6,D3
	addx.w	D4,D3
	bpl.s	lbC0021E2
;	bcs.s	lbC0021E2
	dbra	D5,lbC002182
	bra	lbC002132

lbC0021E2
	move.l	lbL00264C(PC),A3
	sub.w	lbW002650(PC),D3
	dbra	D5,lbC002182
	bra	lbC002132

lbL0021F2
	dcb.l	$60,0
lbL002372
	dcb.l	$A0,0
EmulatorBlock
	dcb.l	$8,0
lbL002612
	dcb.l	$2,0
	dc.w	$3F
lbL00261C
	dc.l	0
lbW002620
	dc.w	0
lbL002622
	dcb.l	$2,0
	dc.w	$3F
lbL00262C
	dc.l	0
lbW002630
	dc.w	0
lbL002632
	dcb.l	$2,0
	dc.w	$3F
lbL00263C
	dc.l	0
lbW002640
	dc.w	0
lbL002642
	dcb.l	$2,0
	dc.w	$3F
lbL00264C
	dc.l	0
lbW002650
	dcb.w	$9,0
lbW002662
	dcb.w	$4,0
lbL00266A
	dcb.l	$9,0
lbL00268E
	dc.l	0
lbL002692
	dc.l	0
lbL002696
	dc.l	0
lbL00269A
	dcb.l	$21,0
lbL00271E
	dcb.l	$17A0,0
lbL00859E
	dcb.l	$40,0
