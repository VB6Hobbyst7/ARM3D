**1.15***********************************************************************
*									    *
* Musicline Player							    *
* ????????????????							    *
* Copyright (C) by John Carehag <john@ziphoid.com>			    *
*									    *
* Authors of the work include Conny Cyreus, Christian Cyreus, John Carehag  *
* and Jimmy Fredriksson.						    *
*									    *
*****************************************************************************

	incdir	Include:
	include		Include:misc/DeliPlayer.i

	        include LVO3.0/exec_lib.i
                include dos/dos.i
                include LVO3.0/intuition_lib.i
                include exec/exec.i
                include intuition/intuition.i
                include LVO3.0/dos_lib.i
	
Version		macro
		dc.b	"1.02"
		endm

VerNum		macro
		dc.w	$0102
		endm

*****************************************************************************
* Musicline Editor Structures                    * Conny Cyr?us - Musicline *
*****************************************************************************

***** ChannelData *****
			RSRESET
ch_CustomAddress	rs.l	1
ch_DmaChannel		rs.w	1
ch_VoiceOff		rs.b	1
ch_ChannelOff		rs.b	1
ch_Spd			rs.b	1
ch_Grv			rs.b	1
ch_SpdPart		rs.b	1
ch_GrvPart		rs.b	1
ch_TuneSpd		rs.b	1
ch_TuneGrv		rs.b	1
ch_SpdCnt		rs.b	1
ch_ArpSpdCnt		rs.b	1
ch_PartGrv		rs.b	1
ch_ArpgGrv		rs.b	1
ch_WsNumber		rs.b	1
ch_WsNumberOld		rs.b	1
ch_InstPtr		rs.l	1
ch_WsPtr		rs.l	1
ch_PartNote		rs.b	1
ch_PartInst		rs.b	1
ch_PartEffectNum	rs.b	1
ch_PartEffectPar	rs.b	1
ch_PartEffects		rs.w	4
ch_Arp			rs.b	1
ch_ArpPos		rs.b	1
ch_ArpTab		rs.b	1
ch_ArpWait		rs.b	1
ch_ArpgNote		rs.b	1
ch_ArpVolSld		rs.b	1
ch_ArpPchSld		rs.b	1
ch_ArpPchSldType	rs.b	1
ch_ArpNote		rs.w	1

ch_TunePos		rs.b	1
ch_PartPos		rs.b	1
ch_PartPosWork		rs.b	1
			rs.b	1
ch_TuneJumpCount	rs.b	1
ch_PartJmpCnt		rs.b	1

ch_WsRepPtrOrg		rs.l	1
ch_WsPointer		rs.l	1
ch_WsLength		rs.w	1
ch_WsRepPointer		rs.l	1
ch_WsRepLength		rs.w	1

ch_Volume1		rs.w	1
ch_Volume2		rs.w	1
ch_Volume3		rs.w	1

ch_Note			rs.w	1
ch_Period1		rs.w	1
ch_Period2		rs.w	1

ch_VUAmp		rs.w	1
ch_VUOldAmp		rs.w	1
ch_VUPeriod		rs.w	1
ch_VUVolume		rs.w	1
ch_VUWsPointer		rs.l	1
ch_VUWsLength		rs.l	1
ch_VUWsRepPointer	rs.l	1
ch_VUWsRepLength	rs.l	1

ch_Transpose		rs.w	1
ch_SemiTone		rs.w	1
ch_FineTune		rs.w	1

ch_SmpOfs		rs.b	1
ch_SmplOfs		rs.b	1
ch_OldInst		rs.b	1
ch_Restart		rs.b	1

ch_VolAdd		rs.b	1
ch_VolSld		rs.b	1
ch_CVolSld		rs.b	1
ch_MVolSld		rs.b	1
ch_VolSet		rs.w	1
ch_CVolume		rs.w	1
ch_VolAddNum		rs.w	1
ch_CVolAddNum		rs.w	1
ch_MVolAddNum		rs.w	1
ch_VolSldSpd		rs.w	1
ch_CVolSldSpd		rs.w	1
ch_MVolSldSpd		rs.w	1

ch_VolSldVol		rs.w	1
ch_CVolSldVol		rs.w	1
ch_MVolSldVol		rs.w	1
ch_VolSldToVol		rs.w	1
ch_CVolSldToVol		rs.w	1
ch_MVolSldToVol		rs.w	1
ch_VolSldType		rs.b	1
ch_CVolSldType		rs.b	1
ch_MVolSldType		rs.b	1
ch_VolSldToVolOff	rs.b	1
ch_CVolSldToVolOff	rs.b	1
ch_MVolSldToVolOff	rs.b	1

ch_Vol			rs.b	1

ch_InstPchSld		rs.b	1
ch_MixResFilBoost	rs.b	1

ch_TransposeNum		rs.b	1
ch_PartNum		rs.w	1
ch_PchSld		rs.b	1
ch_PchSldType		rs.b	1
ch_PchSldSpd		rs.w	1
ch_PchSldNote		rs.w	1
ch_PchSldToNote		rs.w	1
ch_PchAdd		rs.w	1
ch_ArpVolSldSpd		rs.w	1
ch_ArpPchSldSpd		rs.w	1
ch_ArpPchSldToNote	rs.w	1
ch_ArpPchSldNote	rs.w	1

ch_PTPchSld		rs.b	1
ch_PTPchSldType		rs.b	1
ch_PTPchSldSpd		rs.w	1
ch_PTPchSldSpd2		rs.w	1
ch_PTPchSldNote		rs.w	1
ch_PTPchSldToNote	rs.w	1
ch_PTPchAdd		rs.w	1

ch_Effects1		rs.b	1
ch_Effects2		rs.b	1
ch_EffectsPar1		rs.b	1
ch_EffectsPar2		rs.b	1
ch_ADSRVolume		rs.w	1
ch_ADSRData		rs.w	12
ch_Play			rs.b	1
ch_WaveOrSample		rs.b	1
ch_PhaInit		rs.b	1
ch_FilInit		rs.b	1
ch_TraInit		rs.b	1
ch_TuneWait		rs.b	1

ch_Vib			rs.b	1
ch_VibDir		rs.b	1
ch_VibWaveNum		rs.b	1
ch_PartVibWaveNum	rs.b	1
ch_VibCount		rs.w	1
ch_VibCmdSpeed		rs.w	1
ch_VibCmdDepth		rs.w	1
ch_VibCmdDelay		rs.w	1
ch_VibAtkSpeed		rs.w	1
ch_VibAtkLength		rs.w	1
ch_VibDepth		rs.w	1
ch_VibNote		rs.w	1

ch_PTTrePos		rs.b	1
ch_PTTreCmd		rs.b	1
ch_PTTreWave		rs.b	1
ch_PTVibPos		rs.b	1
ch_PTVibCmd		rs.b	1
ch_PTVibWave		rs.b	1
ch_PTVibNote		rs.w	1

ch_Tre			rs.b	1
ch_TreDir		rs.b	1
ch_TreWaveNum		rs.b	1
ch_PartTreWaveNum	rs.b	1
ch_TreCount		rs.w	1
ch_TreCmdSpeed		rs.w	1
ch_TreCmdDepth		rs.w	1
ch_TreCmdDelay		rs.w	1
ch_TreAtkSpeed		rs.w	1
ch_TreAtkLength		rs.w	1
ch_TreDepth		rs.w	1

ch_FilLastSample	rs.b	1
ch_ResLastSample	rs.b	1
ch_FilLastInit		rs.b	1
ch_ResLastInit		rs.b	1
ch_ResAmp		rs.b	1
ch_ResInit		rs.b	1
ch_PhaType		rs.b	1
ch_FilType		rs.b	1
ch_TraData		rs.w	8
ch_TraSpd		rs.w	1
ch_PhaData		rs.w	8
ch_PhaSpd		rs.w	1
ch_MixData		rs.w	8
ch_MixSpd		rs.w	1
ch_ResData		rs.w	8
ch_ResSpd		rs.w	1
ch_FilData		rs.w	8
ch_FilSpd		rs.w	1
ch_MixWaveNum		rs.b	1
ch_MixInit		rs.b	1
ch_TraWsPtrs		rs.b	6
ch_PlayError		rs.b	1
ch_LooInit		rs.b	1
ch_LooRepeat		rs.w	1
ch_LooRepEnd		rs.w	1
ch_LooLength		rs.w	1
ch_LooStep		rs.l	1
ch_LooWait		rs.w	1
ch_LooWaitCounter	rs.w	1
ch_LooDelay		rs.w	1
ch_LooTurns		rs.w	1
ch_LooCounter		rs.w	1
ch_LooCounterSave	rs.w	1
ch_LooWsCounterMax	rs.w	1
ch_LooSpd		rs.w	1
ch_LooWsPointer		rs.l	1
ch_TraWaveBuffer	rs.b	256
ch_PhaWaveBuffer	rs.b	256
ch_MixWaveBuffer	rs.b	256
ch_ResWaveBuffer	rs.b	256
ch_FilWaveBuffer	rs.b	256
ch_WaveBuffer		rs.l	1
ch_MixVolTable		rs.l	1
ch_MixWsPointer		rs.l	1
ch_MixWsCounter		rs.l	1
ch_MixWsLength		rs.l	1
ch_MixSaveDec1		rs.l	1
ch_MixSaveDec2		rs.w	1
ch_MixSmplEnd		rs.b	1
ch_MixLoop		rs.b	1
ch_MixWsLen		rs.w	1
ch_MixAdd2		rs.w	1
ch_MixAdd1		rs.w	1
ch_SIZEOF		rs.b	0

***** TUNE *****
			RSRESET
tune_Title		rs.b	32
tune_Tempo		rs.w	1
tune_Speed		rs.b	1
tune_Groove		rs.b	1
tune_Volume		rs.w	1
tune_PlayMode		rs.b	1
tune_Channels		rs.b	1
tune_Ch1Ptr		rs.l	1
tune_Ch2Ptr		rs.l	1
tune_Ch3Ptr		rs.l	1
tune_Ch4Ptr		rs.l	1
tune_Ch5Ptr		rs.l	1
tune_Ch6Ptr		rs.l	1
tune_Ch7Ptr		rs.l	1
tune_Ch8Ptr		rs.l	1
tune_SIZEOF		rs.b	0

tune_LOADSIZE		=	tune_Ch1Ptr-tune_Title
tune_ChPtrs		=	tune_Ch1Ptr-tune_Title

***** VOICE *****
			RSRESET
chnl_Data		rs.b	2*256
chnl_SIZEOF		rs.b	0

***** PART *****
			RSRESET
part_Data		rs.b	12*128
part_SIZEOF		rs.b	0

***** ARPEGGIO *****
			RSRESET
arpg_Data		rs.b	6*128
arpg_SIZEOF		rs.b	0

***** INSTRUMENT *****
			RSRESET
inst_Title		rs.b	32
inst_SmplNumber		rs.b	1
inst_SmplType		rs.b	1
inst_SmplPointer	rs.l	1
inst_SmplLength		rs.w	1
inst_SmplRepPointer	rs.l	1
inst_SmplRepLength	rs.w	1
inst_FineTune		rs.w	1
inst_SemiTone		rs.w	1
inst_SmplStart		rs.w	1
inst_SmplEnd		rs.w	1
inst_SmplRepStart	rs.w	1
inst_SmplRepLen		rs.w	1
inst_Volume		rs.w	1
inst_Transpose		rs.b	1
inst_SlideSpeed		rs.b	1
inst_Effects1		rs.b	1
inst_Effects2		rs.b	1

WSLOOP			=	7	;Effects1

** EnvelopeGenerator **
ADSR			=	0	;Effects1
ADSRHOLDSUSTAIN		=	0	;inst_EnvTraPhaFilBits

inst_EnvAttLen		rs.w	1
inst_EnvDecLen		rs.w	1
inst_EnvSusLen		rs.w	1
inst_EnvRelLen		rs.w	1
inst_EnvAttSpd		rs.w	1
inst_EnvDecSpd		rs.w	1
inst_EnvSusSpd		rs.w	1
inst_EnvRelSpd		rs.w	1
inst_EnvAttVol		rs.w	1
inst_EnvDecVol		rs.w	1
inst_EnvSusVol		rs.w	1
inst_EnvRelVol		rs.w	1

** Vibrato **
VIBRATO			=	1	;Effects1

inst_VibDir		rs.b	1
inst_VibWaveNum		rs.b	1
inst_VibSpeed		rs.w	1
inst_VibDelay		rs.w	1
inst_VibAtkSpd		rs.w	1
inst_VibAttack		rs.w	1
inst_VibDepth		rs.w	1

** Tremolo **
TREMOLO			=	2	;Effects1

inst_TreDir		rs.b	1
inst_TreWaveNum		rs.b	1
inst_TreSpeed		rs.w	1
inst_TreDelay		rs.w	1
inst_TreAtkSpd		rs.w	1
inst_TreAttack		rs.w	1
inst_TreDepth		rs.w	1

** Arpeggio **
ARPEGGIO		=	3	;Effects1

inst_ArpTable		rs.w	1
inst_ArpSpeed		rs.b	1
inst_ArpGroove		rs.b	1

** Transform **
TRANSFORM		=	0	;Effects2
TRANSFORMINIT		=	1	;inst_EnvTraPhaFilBits
TRANSFORMSTEP		=	2	;inst_EnvTraPhaFilBits

inst_EnvTraPhaFilBits	rs.b	1
inst_TraWaveNums	rs.b	5
inst_TraStart		rs.w	1
inst_TraRepeat		rs.w	1
inst_TraRepEnd		rs.w	1
inst_TraSpeed		rs.w	1
inst_TraTurns		rs.w	1
inst_TraDelay		rs.w	1

** Phase **
PHASE			=	1	;Effects2
PHASEINIT		=	3	;inst_EnvTraPhaFilBits
PHASESTEP		=	4	;inst_EnvTraPhaFilBits
PHASEFILL		=	5	;inst_EnvTraPhaFilBits

inst_PhaStart		rs.w	1
inst_PhaRepeat		rs.w	1
inst_PhaRepEnd		rs.w	1
inst_PhaSpeed		rs.w	1
inst_PhaTurns		rs.w	1
inst_PhaDelay		rs.w	1
inst_PhaType		rs.w	1

** Mix **
MIX			=	2	;Effects2
MIXINIT			=	0	;inst_MixResLooBits
MIXSTEP			=	1       ;inst_MixResLooBits
MIXBUFF			=	2       ;inst_MixResLooBits
MIXCOUNTER		=	3       ;inst_MixResLooBits

inst_MixResLooBits	rs.b	1
inst_MixWaveNum		rs.b	1
inst_MixStart		rs.w	1
inst_MixRepeat		rs.w	1
inst_MixRepEnd		rs.w	1
inst_MixSpeed		rs.w	1
inst_MixTurns		rs.w	1
inst_MixDelay		rs.w	1

** Resonance **
RESONANCE		=	3	;Effects2
RESONANCEINIT		=	4       ;inst_MixResLooBits
RESONANCESTEP		=	5       ;inst_MixResLooBits

inst_ResStart		rs.w	1
inst_ResRepeat		rs.w	1
inst_ResRepEnd		rs.w	1
inst_ResSpeed		rs.w	1
inst_ResTurns		rs.w	1
inst_ResDelay		rs.w	1
inst_MixResFilBoost	rs.b	1
inst_ResAmp		rs.b	1

** Filter **
FILTER			=	4	;Effects2
FILTERINIT		=	6       ;inst_EnvTraPhaFilBits
FILTERSTEP		=	7       ;inst_EnvTraPhaFilBits

inst_FilStart		rs.w	1
inst_FilRepeat		rs.w	1
inst_FilRepEnd		rs.w	1
inst_FilSpeed		rs.w	1
inst_FilTurns		rs.w	1
inst_FilDelay		rs.w	1
inst_FilPadByte		rs.b	1
inst_FilType		rs.b	1

** Loop **
LOOP			=	4	;Effects1
LOOPSTOP		=	5	;Effects1
LOOPINIT		=	6       ;inst_MixResLooBits
LOOPSTEP		=	7       ;inst_MixResLooBits

inst_LooStart		rs.w	1
inst_LooRepeat		rs.w	1
inst_LooRepEnd		rs.w	1
inst_LooLength		rs.w	1
inst_LooLpStep		rs.w	1
inst_LooWait		rs.w	1
inst_LooDelay		rs.w	1
inst_LooTurns		rs.w	1

inst_SIZEOF		rs.b	0

***** SAMPLE *****
			RSRESET
smpl_Title		rs.b	32
smpl_PadByte2		rs.b	1
smpl_Type		rs.b	1
smpl_Pointer		rs.l	1
smpl_Length		rs.w	1
smpl_RepPointer		rs.l	1
smpl_RepLength		rs.w	1
smpl_FineTune		rs.w	1
smpl_SemiTone		rs.w	1
smpl_SampleData		rs.b	0

smpl_SIZEOF		=	smpl_SampleData-smpl_Title

*****************************************************************************
* Macros for library calls                       * Conny Cyr?us - Musicline *
*****************************************************************************

		RSRESET

CallAsl		macro
		move.l	dtg_AslBase(a5),a6
		jsr	_LVO\1(a6)
		endm

CallDOS		macro
		move.l	dtg_DOSBase(a5),a6
		jsr	_LVO\1(a6)
		endm

CallGadTools	macro
		move.l	dtg_GadToolsBase(a5),a6
		jsr	_LVO\1(a6)
		endm

CallGfx		macro
		move.l	dtg_GfxBase(a5),a6
		jsr	_LVO\1(a6)
		endm

CallIntuition	macro
		move.l	dtg_IntuitionBase(a5),a6
		jsr	_LVO\1(a6)
		endm

CallSys		macro
		move.l	4.w,a6
		jsr	_LVO\1(a6)
		endm

CallLib		macro
		jsr	_LVO\1(a6)
		endm

*****************************************************************************
* Musicline Player Main code                     * Conny Cyr?us - Musicline *
*****************************************************************************

		Section	MLCode,Code

		PLAYERHEADER PlayerTagArray			; define start of header

PlayerTagArray	dc.l	DTP_RequestDTVersion,16			; define all the tags
		dc.l	DTP_PlayerVersion,1<<16+02
		dc.l	DTP_PlayerName,PName			; for the player
		dc.l	DTP_Creator,CName
		dc.l	DTP_DeliBase,DeliBase
		dc.l	DTP_Check1,CheckModule
		dc.l	DTP_InitPlayer,InitPlayer
		dc.l	DTP_EndPlayer,EndPlayer
		dc.l	DTP_InitSound,InitSound
		dc.l	DTP_EndSound,EndSound
		dc.l	DTP_StartInt,StartPlay
		dc.l	DTP_StopInt,StopPlay
		dc.l	DTP_NewSubSongRange,SubSongRange
		dc.l	DTP_Volume,MasterVol
		dc.l	DTP_Process,Main
		dc.l	DTP_Priority,0
		dc.l	DTP_StackSize,4096
		dc.l	DTP_MsgPort,DeliPort
		dc.l	TAG_DONE

DeliBase	dc.l	0
DeliPort	dc.l	0
QuitFlag	dc.w	0

PName		dc.b	"MusiclineEditor",0
CName		dc.b	" ",10,"               Musicline",0

		dc.b	"$VER: Musicline Editor DeliPlayer "
		Version
		dc.b	" ()"
		even

*****************************************************************************
* Main                                           * Conny Cyr?us - Musicline *
*****************************************************************************

_Process	rs.l	1
_Signal		rs.l	1

Main		lea	Bss,a5
		lea	QuitFlag(pc),a0
		clr	(a0)

FindTask	sub.l	a1,a1
		CallSys FindTask
		move.l	d0,_Process(a5)
		bne.b	AllocSignal
		rts

AllocSignal	moveq	#-1,d0
		CallSys AllocSignal
		move.l	d0,_Signal(a5)
		bne.b	MainLoop
		rts

MainLoop	move.l	DeliPort(pc),a0
		move.b	MP_SIGBIT(a0),d1
		move.l	#SIGBREAKF_CTRL_C,d0
		bset	d1,d0
		move.l	_Signal(a5),d1
		bset	d1,d0

		CallSys Wait

		btst	#SIGBREAKB_CTRL_C,d0
		beq.b	.ok
		bsr.b	Exit

.ok		move.l	_Signal(a5),d1
		btst	d1,d0
		beq.b	DeliCollect
		move.l	DeliBase(pc),a5
		sub.l	a0,a0
		lea	EasyReqDefs(pc),a1
		move.l	#CpuSlow.Txt,12(a1)
		move.l	#Ok.Txt,16(a1)
		sub.l	a2,a2
		sub.l	a3,a3
		CallIntuition EasyRequestArgs

DeliCollect	move.l	DeliBase(pc),a5
		move.l	DeliPort(pc),a0
		CallSys GetMsg
		tst.l	d0
		beq.b	CollectDone

		move.l	d0,-(sp)
		move.l	d0,a0
		move.l	DTMN_Function(a0),a0
		jsr	(a0)
		move.l	(sp)+,a1
		move.l	d0,DTMN_Result(a1)
		CallSys ReplyMsg
		bra.b	DeliCollect

CollectDone	lea	Bss,a5
		lea	QuitFlag(pc),a0
		tst	(a0)
		beq	MainLoop

FreeSignal	move.l	_Signal(a5),d0
		CallSys FreeSignal
		rts

Exit		lea	QuitFlag(pc),a0
		move	#-1,(a0)
		rts

*****************************************************************************
* Check if it's a Mline module                   * Conny Cyr?us - Musicline *
*****************************************************************************

CheckModule	move.l	dtg_ChkData(a5),a0
		moveq	#-1,d0
		cmp.l	#"MLED",(a0)
		bne.b	CheckEnd
		cmp.l	#"MODL",4(a0)
		bne.b	CheckEnd
		moveq	#0,d0
CheckEnd	rts

*****************************************************************************
* Init Mline player                              * Conny Cyr?us - Musicline *
*****************************************************************************

SndBufSize	=	2560
_SndFBuf	rs.l	1
_SndCBuf	rs.l	1

InitPlayer	lea	Bss,a5

.allocsndcbuf	move.l	#(4*(2*SndBufSize)),d0
		move.l	#MEMF_CHIP,d1
		CallSys AllocMem
		move.l	d0,_SndCBuf(a5)
		bne.b	.sndcok
		moveq	#-1,d0
		rts
.sndcok		move.l	#FreeSndCBuf,_FreeSndCBuf(a5)

.allocsndfbuf	move.l	#(4*(2*SndBufSize)),d0
		move.l	#MEMF_FAST,d1
		CallSys AllocMem
		move.l	d0,_SndFBuf(a5)
		bne.b	.sndfok
		move.l	_SndCBuf(a5),_SndFBuf(a5)
		bra.b	.opencia
.sndfok		move.l	#FreeSndFBuf,_FreeSndFBuf(a5)

.opencia	bsr	OpenCIAResource

		lea	Bss,a5
		move.l	DeliBase(pc),a4
		move.l	dtg_GfxBase(a4),a0
		move	206(a0),d0
		btst	#2,d0
		beq.b	.ntsc
		move.l	#1773448,_TimerValue1(a5)
		move.l	#3546895,_TimerValue2(a5)
		move.l	#709378,_TimerValue3(a5)
		bra.b	.audioalloc
.ntsc		move.l	#1789773,_TimerValue1(a5)
		move.l	#3579545,_TimerValue2(a5)
		move.l	#715909,_TimerValue3(a5)

.audioalloc	move.l	DeliBase(pc),a5
		move.l	dtg_AudioAlloc(a5),a0		; Function
		jsr	(a0)				; returncode is already set !
		beq	LoadModule
		rts

FreeSndCBuf	move.l	_SndCBuf(a5),a1
		move.l	#(4*(2*SndBufSize)),d0
		CallSys FreeMem
		rts

FreeSndFBuf	move.l	_SndFBuf(a5),a1
		move.l	#(4*(2*SndBufSize)),d0
		CallSys FreeMem
		rts

*****************************************************************************
* End Mline player                               * Conny Cyr?us - Musicline *
*****************************************************************************

_ExitList		rs.l	1
_FreeSndFBuf		rs.l	1
_FreeSndCBuf		rs.l	1
_RemTimers		rs.l	1
_ClrAudInt		rs.l	1
_ExitListEnd		rs.b	0

EndPlayer	move.l	TuneList(pc),d0
		beq.b	.skip
		bsr	FreeModule
.skip		lea	Bss,a5
		move.l	#-1,_ExitList(a5)
		lea	_ExitListEnd(a5),a4
.loop		move.l	-(a4),d0
		beq	.loop
		bmi.b	.exit
		move.l	d0,a6
		jsr	(a6)
		bra	.loop
.exit		move.l	DeliBase(pc),a5
		move.l	dtg_AudioFree(a5),a0		; Function
		jsr	(a0)
		rts

*****************************************************************************
* End Sound                                      * Conny Cyr?us - Musicline *
*****************************************************************************

EndSound	clr	$dff0a8
		clr	$dff0b8
		clr	$dff0c8
		clr	$dff0d8
		rts

*****************************************************************************
* Master Volume                                  * Conny Cyr?us - Musicline *
*****************************************************************************

_MasterVol	rs.w	1

MasterVol	move	dtg_SndVol(a5),d0
		lsl	#4,d0
		lea	Bss,a5
		move	d0,_MasterVol(a5)
		rts

*****************************************************************************
* Sub Song Range                                 * Conny Cyr?us - Musicline *
*****************************************************************************

NewSubSongRange	moveq	#0,d0				; min.
		move	TuneNum(pc),d1			; max.
		subq	#1,d1
		bpl.b	.ok
		moveq	#0,d1
.ok		lea	SubSongMax(pc),a0
		move	d1,(a0)
		rts

SubSongRange	dc.w	0
		dc.w	0
SubSongMax	dc.w	0

*****************************************************************************
* Requesters                                     * Conny Cyr?us - Musicline *
*****************************************************************************

EasyReqDefs	dc.l	EasyStruct_SIZEOF
		dc.l	0
		dc.l	MlRequester.Txt
		dc.l	0
		dc.l	0

MlRequester.Txt	dc.b	" Musicline Editor Requester",0
RetryCares.Txt	dc.b	"Retry|Override",0
RetryCancel.Txt	dc.b	"Retry|Cancel",0
Exit.Txt	dc.b	"Exit",0
Ok.Txt		dc.b	"Ok",0
Resource.Txt	dc.b	"Can?t open ciab.resource",0
TimerA.Txt	dc.b	"Can?t allocate CIAB Timer A",0
TimerB.Txt	dc.b	"Can?t allocate CIAB Timer B",0
CpuSlow.Txt	dc.b	"You need more CPU POWER!",0
		even

LoadError	dc.l	0
Lock		dc.l	0
Filehandle	dc.l	0
LoadBuffer	dc.l	0
TuneList	dc.l	0
PartList	dc.l	0
ArpgList	dc.l	0
InstList	dc.l	0
SmplList	dc.l	0
ZeroChannel	dc.l	0
ZeroBuffer	dc.l	0
TuneNum		dc.w	0
PartNum		dc.w	0
ArpgNum		dc.w	0
InstNum		dc.w	0
SmplNum		dc.w	0

*****************************************************************************
* Load Mline module                              * Conny Cyr?us - Musicline *
*****************************************************************************

LoadModule	lea	LoadError(pc),a0
		move.l	#-1,(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr	(a0)+
		clr	(a0)+
		clr	(a0)+
		clr	(a0)+
		clr	(a0)+

		move.l	#(256+1024+256+256+256+128+512)*4,d0
		move.l	#MEMF_ANY,d1
		CallSys AllocMem
		lea	TuneList(pc),a0
		move.l	d0,(a0)
		beq	LoadError1
		add.l	#256*4,d0
		move.l	d0,4(a0)
		add.l	#1024*4,d0
		move.l	d0,8(a0)
		add.l	#256*4,d0
		move.l	d0,12(a0)
		add.l	#256*4,d0
		move.l	d0,16(a0)
		add.l	#256*4,d0
		move.l	d0,20(a0)
		add.l	#128*4,d0
		move.l	d0,24(a0)

		move.l	TuneList(pc),a1
		move	#256+1024+256+256+256-1,d1
		move.l	ZeroBuffer(pc),d2
.initloop	move.l	d2,(a1)+
		dbf	d1,.initloop

		move	#128-1,d1
		move.l	#$00100010,d2
.chnlloop	move.l	d2,(a1)+
		dbf	d1,.chnlloop

		move	#512-1,d1
.clrloop	clr.l	(a1)+
		dbf	d1,.clrloop

		move.l	DeliBase(pc),a5
		move.l	dtg_PathArrayPtr(a5),d1
		move.l	#ACCESS_READ,d2
		CallDOS Lock
		lea	Lock(pc),a0
		move.l	d0,(a0)
		beq	LoadError1

		move.l	dtg_PathArrayPtr(a5),d1
		move.l	#MODE_OLDFILE,d2
		CallLib Open
		lea	Filehandle(pc),a0
		move.l	d0,(a0)
		beq	LoadError2

		move.l	#4096,d0
		move.l	#MEMF_ANY,d1
		CallSys AllocMem
		lea	LoadBuffer(pc),a0
		move.l	d0,(a0)
		beq	LoadError3

		move.l	Filehandle(pc),d1
		move.l	LoadBuffer(pc),d2
		move.l	#1024,d3
		CallDOS Read
		tst.l	d0
		ble	LoadError4

		move.l	LoadBuffer(pc),a0
		cmp.l	#"MLED",(a0)+
		bne	LoadError4
		cmp.l	#"MODL",(a0)+
		bne	LoadError4
		cmp.l	#"VERS",(a0)
		beq.b	.version
		add.l	(a0)+,a0
		cmp.l	#"VERS",(a0)
		bne	LoadError4

.version	addq	#4,a0
		add.l	(a0)+,a0

		move.l	Filehandle(pc),d1
		move.l	a0,d2
		sub.l	LoadBuffer(pc),d2
		moveq	#OFFSET_BEGINNING,d3
		CallDOS Seek

LoadHeader	move.l	Filehandle(pc),d1
		move.l	LoadBuffer(pc),d2
		moveq	#8,d3
		CallDOS Read
		tst.l	d0
		ble.b	.done

		move.l	LoadBuffer(pc),a0
		cmp.l	#"TUNE",(a0)
		beq	LoadTune
		cmp.l	#"PART",(a0)
		beq	LoadPart
		cmp.l	#"ARPG",(a0)
		beq	LoadArpg
		cmp.l	#"INST",(a0)
		beq	LoadInst
		cmp.l	#"SMPL",(a0)
		beq	LoadSmpl
		cmp.l	#"INFO",(a0)
		beq	LoadInfo

.done		move.l	TuneList(pc),a0
		move.l	(a0),a0
		move.l	ZeroBuffer(pc),a1
		cmp.l	a0,a1
		beq.b	LoadError4
		lea	TunePtr(pc),a1
		move.l	a0,(a1)
		lea	Bss,a5
		move.b	tune_PlayMode(a0),_PlayMode(a5)
		move.l	DeliBase(pc),a5
		lea	Tune(pc),a0
		clr	(a0)
		lea	LoadError(pc),a0
		clr.l	(a0)
		bsr	NewSubSongRange

LoadError4	move.l	LoadBuffer(pc),a1
		move.l	#4096,d0
		CallSys	FreeMem

LoadError3	move.l	Filehandle(pc),d1
		CallDOS Close

LoadError2	move.l	Lock(pc),d1
		CallLib UnLock

LoadError1	move.l	LoadError(pc),d0
		bne.b	FreeModule
		rts
FreeModule

FreeAllTunes	move.l	4.w,a6
		move	#256-1,d6
		move.l	TuneList(pc),a4
		move.l	ZeroChannel(pc),a3
.loop		moveq	#7,d7
		move.l	(a4)+,a0
		move.l	ZeroBuffer(pc),a1
		cmp.l	a0,a1
		beq.b	.notune
		move.l	a0,d2
		lea	tune_Ch1Ptr(a0),a2
.free		cmp.l	(a2),a3
		beq.b	.zero
		move.l	(a2),a1
		move.l	#chnl_SIZEOF,d0
		CallLib FreeMem
.zero		addq	#4,a2
		dbf	d7,.free
		move.l	d2,a1
		move.l	#tune_SIZEOF,d0
		CallLib FreeMem
.notune		dbf	d6,.loop

FreeAllParts	move.l	4.w,a6
		move	#1024-1,d6
		move.l	PartList(pc),a2
		move.l	ZeroBuffer(pc),a3
.loop		move.l	(a2)+,a1
		cmp.l	a3,a1
		beq.b	.zero
		move.l	#part_SIZEOF,d0
		CallLib FreeMem
.zero		dbf	d6,.loop
		lea	PartList(pc),a0
		clr.l	(a0)

FreeAllArpgs	move.l	4.w,a6
		move	#256-1,d6
		move.l	ArpgList(pc),a2
		move.l	ZeroBuffer(pc),a3
.loop		move.l	(a2)+,a1
		cmp.l	a3,a1
		beq.b	.zero
		move.l	#arpg_SIZEOF,d0
		CallLib FreeMem
.zero		dbf	d6,.loop
		lea	ArpgList(pc),a0
		clr.l	(a0)

FreeAllInsts	move.l	4.w,a6
		move	#256-1,d6
		move.l	InstList(pc),a2
		move.l	ZeroBuffer(pc),a3
.loop		move.l	(a2)+,a1
		cmp.l	a3,a1
		beq.b	.zero
		move.l	#inst_SIZEOF,d0
		CallLib FreeMem
.zero		dbf	d6,.loop
		lea	InstList(pc),a0
		clr.l	(a0)

FreeAllSmpls	move.l	4.w,a6
		move	#256-1,d6
		move.l	SmplList(pc),a4
		move.l	ZeroBuffer(pc),a3
.loop		move.l	(a4)+,a1
		cmp.l	a1,a3
		beq.b	.zero
		moveq	#0,d0
		move	smpl_Length(a1),d0
		cmp.l	#128,d0
		bne.b	.ok
		add	#120,d0
.ok		add.l	d0,d0
		add.l	#smpl_SampleData,d0
		CallLib FreeMem
.zero		dbf	d6,.loop
		lea	SmplList(pc),a0
		clr.l	(a0)

FreeAllTables	move.l	TuneList(pc),a1
		move.l	#(256+1024+256+256+256+128+512)*4,d0
		CallSys	FreeMem
		lea	TuneList(pc),a0
		clr.l	(a0)

		move.l	LoadError(pc),d0
		rts

LoadInfo	move.l	Filehandle(pc),d1
		move.l	LoadBuffer(pc),a0
		move.l	a0,d2
		move.l	4(a0),d3
		CallDOS Read
		tst.l	d0
		ble	LoadError4

*		move.l	_LoadBuffer(pc),a0
*		lea	TitleStr(pc),a1
*		moveq	#64-1,d0
*		bsr.b	.getstring
*		lea	AuthorStr(pc),a1
*		moveq	#64-1,d0
*		bsr.b	.getstring
*		lea	DateStr(pc),a1
*		moveq	#16-1,d0
*		bsr.b	.getstring
*		lea	DurationStr(pc),a1
*		moveq	#16-1,d0
*		bsr.b	.getstring
*		lea	Info1Str(pc),a1
*		moveq	#64-1,d0
*		bsr.b	.getstring
*		lea	Info2Str(pc),a1
*		moveq	#64-1,d0
*		bsr.b	.getstring
*		lea	Info3Str(pc),a1
*		moveq	#64-1,d0
*		bsr.b	.getstring
*		lea	Info4Str(pc),a1
*		moveq	#64-1,d0
*		bsr.b	.getstring
*		lea	Info5Str(pc),a1
*		moveq	#64-1,d0
*		bsr.b	.getstring
.exit		bra	LoadHeader
*
*.getstring	move.b	(a0)+,(a1)+
*		dbeq	d0,.getstring
*		rts

LoadTune	move.l	#tune_SIZEOF,d0
		move.l	#MEMF_ANY!MEMF_CLEAR,d1
		CallSys AllocMem
		move.l	d0,d5
		beq	LoadError4

		move.l	TuneList(pc),a0
		move	TuneNum(pc),d0
		lsl	#2,d0
		move.l	d5,(a0,d0.w)

		move.l	Filehandle(pc),d1
		move.l	d5,d2
		move.l	#tune_LOADSIZE,d3
		CallDOS Read
		tst.l	d0
		ble	LoadError4

		add.l	#tune_ChPtrs,d2
		move.l	d2,a2
		move.l	d5,a0
		moveq	#0,d6
		moveq	#8,d7
		tst.b	tune_Channels(a0)
		beq.b	.done
		move.b	tune_Channels(a0),d7

		move.l	Filehandle(pc),d1
		move.l	a2,d2
		move.l	d7,d3
		lsl.l	#2,d3
		CallDOS Read
		tst.l	d0
		ble	LoadError4

.loop		move.l	(a2)+,d3
		beq.b	.zero
		move.l	#chnl_SIZEOF,d0
		move.l	#MEMF_ANY,d1
		CallSys AllocMem
		tst.l	d0
		beq	LoadError4
		move.l	d0,a1
		move	#127,d1
		move.l	#$00100010,d2
.tloop		move.l	d2,(a1)+
		dbf	d1,.tloop
		move.l	d0,-4(a2)
		move.l	Filehandle(pc),d1
		move.l	d0,d2
		CallDOS Read
		tst.l	d0
		ble	LoadError4
.loopa		addq	#1,d6
		cmp	d6,d7
		bhi.b	.loop
		cmp	#8,d6
		beq.b	.skip
.done		move.l	ZeroChannel(pc),a0
		moveq	#8,d7
.null		move.l	a0,(a2)+
		addq	#1,d6
		cmp	d6,d7
		bhi.b	.null
.skip		lea	TuneNum(pc),a0
		addq	#1,(a0)
		bra	LoadHeader
.zero		move.l	ZeroChannel(pc),-4(a2)
		bra.b	.loopa

LoadPart	move.l	#part_SIZEOF,d0
		move.l	#MEMF_ANY!MEMF_CLEAR,d1
		CallSys AllocMem
		move.l	d0,d5
		beq	LoadError4

		move.l	Filehandle(pc),d1
		move.l	LoadBuffer(pc),a0
		move.l	a0,d2
		move.l	4(a0),d3
		CallDOS Read
		tst.l	d0
		ble	LoadError4

		move.l	PartList(pc),a0
		move.l	LoadBuffer(pc),a1
		move	(a1)+,d0
		lsl	#2,d0
		move.l	d5,(a0,d0.w)
		move.l	a1,a0
		move.l	d5,a1
.ploop		move.b	(a0)+,d6
		bmi.b	.pok
		moveq	#6-1,d7
.pnextloop	lsr.b	#1,d6
		bcc.b	.pnext
		move.b	(a0)+,(a1)
		move.b	(a0)+,1(a1)
.pnext		addq	#2,a1
		dbf	d7,.pnextloop
		bra.b	.ploop
.pok		lea	PartNum(pc),a0
		addq	#1,(a0)
		bra	LoadHeader

LoadArpg	move.l	#arpg_SIZEOF,d0
		move.l	#MEMF_ANY!MEMF_CLEAR,d1
		CallSys AllocMem
		move.l	d0,d5
		beq	LoadError4

		move.l	d5,a2
		move.l	Filehandle(pc),d1
		move.l	d5,d2
		moveq	#2,d3
		CallDOS Read
		tst.l	d0
		ble	LoadError4

		move.l	ArpgList(pc),a0
		move	(a2),d0
		lsl	#2,d0
		move.l	d5,(a0,d0.w)
		move.l	Filehandle(pc),d1
		move.l	d5,d2
		move.l	LoadBuffer(pc),a0
		move.l	4(a0),d3
		subq.l	#2,d3
		CallDOS Read
		tst.l	d0
		ble	LoadError4
		lea	ArpgNum(pc),a0
		addq	#1,(a0)
		bra	LoadHeader

LoadInst	move.l	#inst_SIZEOF,d0
		move.l	#MEMF_ANY!MEMF_CLEAR,d1
		CallSys AllocMem
		move.l	d0,d5
		beq	LoadError4

		lea	InstNum(pc),a0
		addq	#1,(a0)
		move.l	InstList(pc),a0
		move	InstNum(pc),d0
		lsl	#2,d0
		move.l	d5,(a0,d0.w)

		move.l	Filehandle(pc),d1
		move.l	d5,d2
		move.l	LoadBuffer(pc),a0
		move.l	4(a0),d3
		CallDOS Read
		tst.l	d0
		ble	LoadError4
		bra	LoadHeader

LoadSmpl	move.l	LoadBuffer(pc),d2
		addq.l	#8,d2
		moveq	#6,d3
		move.l	Filehandle(pc),d1
		CallDOS Read
		tst.l	d0
		ble	LoadError4

		move.l	LoadBuffer(pc),a0
		move.l	8(a0),d0
		cmp.l	#256,d0
		bne.b	.not
		add.l	#240,d0
.not		add.l	#smpl_SampleData,d0
		move.l	#MEMF_CHIP!MEMF_CLEAR,d1
		CallSys AllocMem
		move.l	d0,d5
		beq	LoadError4

		move.l	Filehandle(pc),d1
		move.l	d5,d2
		move.l	#smpl_SIZEOF,d3
		CallDOS Read
		tst.l	d0
		ble	LoadError4

		move.l	d5,a2
		move.l	LoadBuffer(pc),a0
		move.l	4(a0),d3
		sub.l	#smpl_SIZEOF,d3
		move.l	8(a0),d0
		cmp.l	d0,d3
		bne.b	.depack

		lea	smpl_SampleData(a2),a1		Read UnPacked Sample
		move.l	a1,d2
		move.l	Filehandle(pc),d1
		CallDOS Read
		tst.l	d0
		ble	LoadError4
		bra	.continue

.depack		move.l	d3,d7				Packed Sample Length / DeltaDePacker
.alloc		move.l	d3,d0
		move.l	#MEMF_ANY,d1
		CallSys AllocMem
		tst.l	d0
		beq.b	.again
		lea	DeltaPackBuffer(pc),a4
		move.l	d0,(a4)
		move.l	d3,4(a4)
		lea	smpl_SampleData(a2),a1		Dest Beg Pointer / DeltaDePacker
		move.l	LoadBuffer(pc),a0
		move.b	12(a0),8(a4)			DeltaCommand Byte
		bsr	DeltaDePacker			Uses	d0,d1,d2,d3,d5,d6,d7,a0,a1
		tst.l	d4
		bne	LoadError4
		move.l	DeltaPackBuffer(pc),a1
		move.l	DeltaPackBufferLen(pc),d0
		CallSys	FreeMem
		bra.b	.continue

.again		lsr.l	#1,d3
		cmp.l	#4096,d3
		bhi.b	.alloc
		move.l	LoadBuffer(pc),a0
		move.l	(a0),-(sp)
		move.l	4(a0),-(sp)
		move.l	8(a0),-(sp)
		move	12(a0),-(sp)
		move.l	a0,d0
		lea	DeltaPackBuffer(pc),a4
		move.l	d0,(a4)
		move.l	#4096,4(a4)
		lea	smpl_SampleData(a2),a1		Dest Beg Pointer / DeltaDePacker
		move.b	12(a0),8(a4)			DeltaCommand Byte
		bsr	DeltaDePacker			Uses	d0,d1,d2,d3,d5,d6,d7,a0,a1
		tst.l	d4
		bne	LoadError4
		move.l	LoadBuffer(pc),a0
		move	(sp)+,12(a0)
		move.l	(sp)+,8(a0)
		move.l	(sp)+,4(a0)
		move.l	(sp)+,(a0)

.continue	move.l	LoadBuffer(pc),a0
		move.l	8(a0),d0
		cmp.l	#256,d0
		bne.b	.notwave
		lea	smpl_SampleData(a2),a0
		move	#256-1,d0
.convertwave	cmp.b	#$80,(a0)+
		bne.b	.conok
		move.b	#$81,-1(a0)
.conok		dbf	d0,.convertwave
		lea	smpl_SampleData(a2),a0
		lea	256(a0),a1
		move	#240-1,d0
.makewaves	move.b	(a0)+,(a1)+
		addq	#1,a0
		dbf	d0,.makewaves
.notwave	lea	SmplNum(pc),a0
		addq	#1,(a0)
		move.l	SmplList(pc),a0
		move	SmplNum(pc),d0
		lsl	#2,d0
		move.l	a2,(a0,d0.w)
		move	SmplNum(pc),d7
		move.l	InstList(pc),a1
		lea	smpl_SampleData(a2),a3
		addq	#4,a1
		move	#255-1,d6
		move.l	ZeroBuffer(pc),d2
.loop		move.l	(a1)+,a0
		cmp.l	a0,d2
		beq.b	.setwsptrs
		cmp.b	inst_SmplNumber(a0),d7
		bne.b	.zero
.setsndptrs	move.l	a3,d1
		moveq	#0,d0
		move	inst_SmplStart(a0),d0
		add.l	d0,d0
		add.l	d0,d1
		move.l	d1,inst_SmplPointer(a0)
		move.l	a3,d1
		moveq	#0,d0
		move	inst_SmplRepStart(a0),d0
		add.l	d0,d0
		add.l	d0,d1
		move.l	d1,inst_SmplRepPointer(a0)
.zero		dbf	d6,.loop
.setwsptrs	move.l	smpl_RepPointer(a2),d0
		sub.l	smpl_Pointer(a2),d0
		bpl.b	.noadd1
		moveq	#0,d0
.noadd1		move.l	a3,smpl_Pointer(a2)
		move.l	a3,d1
		add.l	d0,d1
		move.l	d1,smpl_RepPointer(a2)
.exit		bra	LoadHeader

DeltaPackBuffer		dc.l	0
DeltaPackBufferLen	dc.l	0
DeltaCommand		dc.w	0

*******	Delta DePacker ********************************************************
*	by Christian Cyreus of Musicline				      *
*******************************************************************************
*******	File Format ***********************************************************
*									      *
*	Backwards							      *
*	BYTE - Crunch Command						      *
*	BYTE - Data Begin Byte						      *
*	BYTE - Data Field Length in Bytes ( 8  most significant bits )	      *
*	BYTE - Data Field Length in Bytes ( 8 least significant bits )	      *
*									      *
*******************************************************************************
*									      *
*	Uses	d0,d1,d2,d3,d6,d7,a0,a1					      *
*									      *
*	a1.l <- Destination Beg Pointer					      *
*	d7.l <- Packed Sample Length					      *
*									      *
*******************************************************************************

ext_b		MACRO
		btst	#3,\1
		beq.b	.skip\@
		or.b	#$f0,\1
.skip\@
		ENDM

DeltaReadCheck	MACRO
		subq.l	#1,d6
		bgt.b	.not\@
		tst	d7
		beq.\0	.done
		bsr.\0	DeltaReadBuffer
.not\@	
		ENDM

DeltaDePacker	moveq	#0,d6
.loop		DeltaReadCheck
		move.b	(a0)+,d0
		cmp.b	8(a4),d0
		beq.b	.command
		move.b	d0,(a1)+
		bra.b	.loop

.command	DeltaReadCheck.b
		move.b	(a0)+,d0
		DeltaReadCheck.b
		move.b	(a0)+,d1
		lsl	#8,d1
		DeltaReadCheck.b
		move.b	(a0)+,d1
		move.b	d0,(a1)+
		tst	d1
		beq.b	.loop

.decrunch1	DeltaReadCheck
		move.b	(a0)+,d2
		lsr.b	#4,d2
		ext_b	d2
		add.b	d2,d0
		move.b	d0,(a1)+
		subq	#1,d1
		beq	.loop

.decrunch2	move.b	-1(a0),d2
		and	#$f,d2
		ext_b	d2
		add.b	d2,d0
		move.b	d0,(a1)+
		subq	#1,d1
		bne.b	.decrunch1
		bra	.loop
		
.done		moveq	#0,d4
		rts

DeltaReadBuffer
.readagain	movem.l	d0-d3/a0-a1,-(sp)
		move.l	DeltaPackBufferLen(pc),d3
		cmp.l	d3,d7
		bhi.b	.ok
		move.l	d7,d3
		moveq	#0,d7
		bra.b	.read
.ok		sub.l	d3,d7
.read		move.l	d3,d6
		move.l	DeltaPackBuffer(pc),d2
		move.l	Filehandle(pc),d1
		CallDOS Read
		tst.l	d0
		ble.b	.error
		movem.l	(sp)+,d0-d3/a0-a1
		move.l	DeltaPackBuffer(pc),a0
		rts

.error		movem.l	(sp)+,d0-d3/a0-a1
		move.l	DeltaPackBuffer(pc),a0
		move.l	#-1,d4
		addq	#4,sp
		rts

* Twins/PHA *****************************************************************
* Interuptserver routines                             Last Change: 92-10-24 *
*****************************************************************************

_OldAudInt	rs.l	1

SetAudInt	moveq	#7,d0
		lea	AudIntHandler,a1
		CallSys SetIntVector
		move.l	d0,_OldAudInt(a5)
		move.l	#ClrAudInt,_ClrAudInt(a5)
		rts

ClrAudInt	moveq	#7,d0
		move.l	_OldAudInt(a5),a1
		CallSys SetIntVector
		clr.l	_ClrAudInt(a5)
		rts

AudIntHandler	dc.l 0,0
		dc.b 2,0
		dc.l AudIntName,0,PlayMusic
AudIntName	dc.b "MlAudInt",0
		even

PlayMusic	movem.l	d2-d7/a2/a3/a4,-(sp)
		move	#$0080,$dff09c

		lea	Bss,a5
		tst	_IntMode(a5)
		beq	.exit
		tst.b	_PlayMode(a5)
		beq.b	.normal
		eor	#2560,_DoubleBuf(a5)
		bsr	Dma4
.normal		cmp.b	#2,_PlayTune(a5)
		bne.b	.playtune
		move.b	#1,_PlayTune(a5)
		move	_Ch1Volume(a5),$dff0a8
		move	_Ch2Volume(a5),$dff0b8
		move	_Ch3Volume(a5),$dff0c8
		move	_Ch4Volume(a5),$dff0d8
		bra.b	.playfx
.playtune	bsr	PlayTune
.playfx		bsr	PlayEffects
		bsr	PerCalc
		bsr	PerVolPlay
		bsr	DmaPlay

		tst.b	_PlayMode(a5)
		beq	.4ch

		moveq	#0,d2
		move	_DoubleBuf(a5),d2
		move.l	_SndFBuf(a5),d3
		move.l	_SndCBuf(a5),d4
		cmp.l	d3,d4
		beq	.nomove
		add.l	d2,d3
		add.l	d2,d4
		move.l	d3,a0
		move.l	d4,a1
		move	_MixLength(a5),d1
		lsr	#4,d1
		subq	#1,d1
		bpl.b	.moveok
		moveq	#0,d1
.moveok		move	d1,d0
.moveloop1	move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbf	d0,.moveloop1

		add.l	#(2*SndBufSize),d3
		add.l	#(2*SndBufSize),d4
		move.l	d3,a0
		move.l	d4,a1
		move	d1,d0
.moveloop2	move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbf	d0,.moveloop2

		add.l	#(2*SndBufSize),d3
		add.l	#(2*SndBufSize),d4
		move.l	d3,a0
		move.l	d4,a1
		move	d1,d0
.moveloop3	move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbf	d0,.moveloop3

		add.l	#(2*SndBufSize),d3
		add.l	#(2*SndBufSize),d4
		move.l	d3,a0
		move.l	d4,a1
		move	d1,d0
.moveloop4	move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbf	d0,.moveloop4

.nomove		move	$dff01c,d0
		and	#$0080,d0
		beq.b	.exit
		move	$dff01e,d0
		and	#$0080,d0
		beq.b	.exit
		move	#$0080,$dff09c
		bset	#0,_CPUPower(a5)
		bne.b	.exit
		move.l	_Process(a5),a1
		move.l	_Signal(a5),d1
		moveq	#0,d0
		bset	d1,d0
		CallSys Signal

.exit		movem.l	(sp)+,d2-d7/a2/a3/a4
		moveq	#0,d0
		rts

.4ch		lea	$bfd000,a1
		move.b	ciaicr(a4),d0
		btst	#CIAICRB_TA,d0
		beq.b	.oki
		bset	#0,_CPUPower(a5)
		bne.b	.oki
		move.l	_Process(a5),a1
		move.l	_Signal(a5),d1
		moveq	#0,d0
		bset	d1,d0
		CallSys Signal

.oki		movem.l	(sp)+,d2-d7/a2/a3/a4
		moveq	#0,d0
		rts

OpenCIAResource	moveq	#0,d0
		lea	CIABName,a1
		CallSys OpenResource
		move.l	d0,_CIABBase(a5)
		beq	ResourceError

AddTimers	bsr.b	AddTimerA
		bra.b	AddTimerB

AddTimerA	lea	Bss,a5
		btst	#CIAICRB_TA,_TimerFlag(a5)
		bne.b	.exit
		move.l	_CIABBase(a5),a6
		lea	$bfd000,a4
		lea	TempoServer(pc),a1
		moveq	#CIAICRB_TA,d0
		CallLib AddICRVector
		tst.l	d0
		bne	TimerAError
		bset	#CIAICRB_TA,_TimerFlag(a5)
		move.l	#RemTimers,_RemTimers(a5)
		moveq	#0,d0
		bset	#CIAICRB_TA,d0
		CallLib AbleICR
		moveq	#0,d0
		bset	#CIAICRB_TA,d0
		CallLib SetICR
		bclr	#CIACRAB_START,ciacra(a4)
		bclr	#CIACRAB_RUNMODE,ciacra(a4)
		bclr	#CIACRAB_INMODE,ciacra(a4)
		moveq	#0,d0
		bset	#CIAICRB_SETCLR,d0
		bset	#CIAICRB_TA,d0
		CallLib AbleICR
.exit		rts

AddTimerB	lea	Bss,a5
		btst	#CIAICRB_TB,_TimerFlag(a5)
		bne.b	.exit
		move.l	_CIABBase(a5),a6
		lea	$bfd000,a4
		lea	DmaWaitServer(pc),a1
		moveq	#CIAICRB_TB,d0
		CallLib AddICRVector
		tst.l	d0
		bne	TimerBError
		bset	#CIAICRB_TB,_TimerFlag(a5)
		move.l	#RemTimers,_RemTimers(a5)
		moveq	#0,d0
		bset	#CIAICRB_TB,d0
		CallLib AbleICR
		bclr	#CIACRBB_START,ciacrb(a4)
		bset	#CIACRBB_RUNMODE,ciacrb(a4)
		bclr	#CIACRBB_INMODE0,ciacrb(a4)
		bclr	#CIACRBB_INMODE1,ciacrb(a4)
		moveq	#0,d0
		bset	#CIAICRB_TB,d0
		CallLib SetICR
		moveq	#0,d0
		bset	#CIAICRB_SETCLR,d0
		bset	#CIAICRB_TB,d0
		CallLib AbleICR
.exit		rts

ResourceError	move.l	DeliBase(pc),a5
		sub.l	a0,a0
		lea	EasyReqDefs,a1
		move.l	#Resource.Txt,12(a1)
		move.l	#Exit.Txt,16(a1)
		sub.l	a2,a2
		sub.l	a3,a3
		CallIntuition EasyRequestArgs
		addq	#4,sp
		moveq	#-1,d0
		rts

TimerAError	move.l	DeliBase(pc),a5
		sub.l	a0,a0
		lea	EasyReqDefs,a1
		move.l	#TimerA.Txt,12(a1)
		move.l	#RetryCancel.Txt,16(a1)
		sub.l	a2,a2
		sub.l	a3,a3
		CallIntuition EasyRequestArgs
		tst.l	d0
		bne	AddTimerA
		addq	#8,sp
		moveq	#-1,d0
		rts

TimerBError	move.l	DeliBase(pc),a5
		sub.l	a0,a0
		lea	EasyReqDefs,a1
		move.l	#TimerB.Txt,12(a1)
		move.l	#RetryCancel.Txt,16(a1)
		sub.l	a2,a2
		sub.l	a3,a3
		CallIntuition EasyRequestArgs
		tst.l	d0
		bne	AddTimerB
		addq	#4,sp
		moveq	#-1,d0
		rts

RemTimers	move.l	_CIABBase(a5),d0
		beq.b	.exit
		move.l	d0,a6
.remtimera	btst	#CIAICRB_TA,_TimerFlag(a5)
		beq.b	.remtimerb
		moveq	#CIAICRB_TA,d0
		lea	TempoServer(pc),a1
		CallLib RemICRVector
		bclr	#CIAICRB_TA,_TimerFlag(a5)
		clr.l	_RemTimers(a5)
.remtimerb	btst	#CIAICRB_TB,_TimerFlag(a5)
		beq.b	.exit
		moveq	#CIAICRB_TB,d0
		lea	DmaWaitServer(pc),a1
		CallLib RemICRVector
		lea	$bfd000,a0
		bclr	#CIACRBB_RUNMODE,ciacrb(a0)
		bclr	#CIAICRB_TB,_TimerFlag(a5)
		clr.l	_RemTimers(a5)
.exit		rts

CIABName	dc.b "ciab.resource",0

DmaWaitServer	dc.l 0,0
		dc.b 2,0
		dc.l dmawaitname
		dc.l 0,PlayDma

dmawaitname	dc.b "ml_DMAWait",0

	even

TempoServer	dc.l 0,0
		dc.b 2,0
		dc.l temponame
		dc.l 0,PlayMusic

temponame	dc.b "ml_Tempo",0
		even

_CIABBase	rs.l	1
_DmaWait	rs.b	1
_TimerFlag	rs.b	1
_IntMode	rs.w	1
_TimerValue1	rs.l	1
_TimerValue2	rs.l	1
_TimerValue3	rs.l	1

* Twins/PHA *****************************************************************
* PlayTune                                            Last Change: 93-01-15 *
*****************************************************************************

_TuneSpd	rs.b	1
_TuneGrv	rs.b	1
_TuneTmp	rs.w	1
_LoopError	rs.w	1

Tune		dc.w	0
TunePtr		dc.l	0

PlayTune	move.l	TunePtr(pc),a0
.voice1		move.l	tune_Ch1Ptr(a0),a3
		lea	Channel1Buf,a4
		bsr.b	PlayVoice

.voice2		move.l	TunePtr(pc),a0
		move.l	tune_Ch2Ptr(a0),a3
		lea	Channel2Buf,a4
		bsr.b	PlayVoice

.voice3		move.l	TunePtr(pc),a0
		move.l	tune_Ch3Ptr(a0),a3
		lea	Channel3Buf,a4
		bsr.b	PlayVoice

.voice4		move.l	TunePtr(pc),a0
		move.l	tune_Ch4Ptr(a0),a3
		lea	Channel4Buf,a4
		bsr.b	PlayVoice

.voice5		tst.b	_PlayMode(a5)
		beq.b	.exit

		move.l	TunePtr(pc),a0
		move.l	tune_Ch5Ptr(a0),a3
		lea	Channel5Buf,a4
		bsr.b	PlayVoice

.voice6		move.l	TunePtr(pc),a0
		move.l	tune_Ch6Ptr(a0),a3
		lea	Channel6Buf,a4
		bsr.b	PlayVoice

.voice7		move.l	TunePtr(pc),a0
		move.l	tune_Ch7Ptr(a0),a3
		lea	Channel7Buf,a4
		bsr.b	PlayVoice

.voice8		move.l	TunePtr(pc),a0
		move.l	tune_Ch8Ptr(a0),a3
		lea	Channel8Buf,a4
		bsr.b	PlayVoice

.exit		rts

PlayVoice	tst.b	ch_VoiceOff(a4)
		bne	.exit
		subq.b	#1,ch_SpdCnt(a4)
		bne	.exit
		move.b	ch_PartPos(a4),ch_PartPosWork(a4)
		move	#256,_LoopError(a5)
		move.b	ch_Spd(a4),d0
		not.b	ch_PartGrv(a4)
		beq.b	.nogrv
		move.b	ch_Grv(a4),d1
		beq.b	.nogrv
		exg	d0,d1
.nogrv		move.b	d0,ch_SpdCnt(a4)
		clr.b	ch_SpdPart(a4)
		clr.b	ch_GrvPart(a4)
.restart	subq	#1,_LoopError(a5)
		bcs	.exit
		move.l	a3,a0
		moveq	#0,d0
		move.b	ch_TunePos(a4),d0
		cmp.b	_TunePos(a5),d0
		bne.b	.skipp
		bset	#1,ch_PlayError(a4)
.skipp		move.b	d0,d2
		add	d0,d0
		add	d0,a0
		move	(a0),d3
		move	d3,d5
		and	#$001f,d5
		btst	#5,d3
		beq	.part
		move	d3,d4
		and	#$00c0,d4
		lsr	#6,d4
.end		cmp	#1,d4
		bne.b	.jump
		move.b	#1,ch_VoiceOff(a4)
		bset	#0,ch_PlayError(a4)
		bra	.exit
.jump		cmp	#2,d4
		bne.b	.wait
		tst.b	ch_TuneJumpCount(a4)
		beq.b	.jumpinitcount
		subq.b	#1,ch_TuneJumpCount(a4)
		beq.b	.jumpcountend
		move.b	(a0),ch_TunePos(a4)
		bra	.restart
.jumpcountend	addq.b	#1,ch_TunePos(a4)
		bra	.restart
.jumpinitcount	cmp.b	(a0),d2
		bls.b	.done
		move.b	d5,ch_TuneJumpCount(a4)
		bne.b	.ok
		bset	#0,ch_PlayError(a4)
.ok		move.b	(a0),ch_TunePos(a4)
		bra	.restart
.done		addq.b	#1,ch_TunePos(a4)
		bra	.restart
.wait		cmp	#3,d4
		bne.b	.part
		tst.b	ch_TuneWait(a4)
		beq.b	.waitinit
		subq.b	#1,ch_TuneWait(a4)
		beq.b	.done
		bra	.exit
.waitinit	move.b	(a0),ch_TuneWait(a4)
		beq.b	.done
		clr.b	ch_PTPchSld(a4)
		clr.b	ch_PchSld(a4)
		clr.b	ch_VolSld(a4)
		clr	ch_PartNote(a4)
		tst.b	ch_Vib(a4)
		bne.b	.skipvib
		clr.b	ch_Vib(a4)
.skipvib	tst.b	ch_Tre(a4)
		bne.b	.skiptre
		clr.b	ch_Tre(a4)
.skiptre	move	d5,d0
		beq	.exit
		move.b	d0,ch_Spd(a4)
		move.b	d0,ch_SpdCnt(a4)
		bra	.exit
.part		move	d3,d4
		lsl	#2,d4
		and	#$300,d4
		lsr	#8,d3
		or	d4,d3
		move	d3,ch_PartNum(a4)
		sub.b	#$10,d5
		move.b	d5,ch_TransposeNum(a4)
		moveq	#0,d0
		move	d3,d0
		ext	d5
		lsl	#5,d5
		add	d0,d0
		add	d0,d0
		move.l	PartList(pc),a1
		move.l	(a1,d0.w),a1
.partrestart	moveq	#0,d0
		move.b	ch_PartPos(a4),d0
		move.b	d0,d2
		addq.b	#1,ch_PartPos(a4)
		and.b	#$7f,ch_PartPos(a4)
		bne.b	.noadd
		addq.b	#1,ch_TunePos(a4)
		move.b	_TuneSpd(a5),ch_Spd(a4)
		move.b	_TuneGrv(a5),ch_Grv(a4)
.noadd		mulu	#12,d0
		lea	(a1,d0.w),a2
		move.l	(a2)+,ch_PartNote(a4)
		move.l	(a2)+,ch_PartEffects(a4)
		move.l	(a2)+,ch_PartEffects+4(a4)
		move.b	ch_PartNote(a4),d1
.partend	cmp.b	#61,d1
		bne.b	.partjump
		tst.b	d2
		bne.b	.skip
		jmp	StopPlay
.skip		clr.b	ch_PartPos(a4)
		clr.b	ch_PartPosWork(a4)
		move.b	_TuneSpd(a5),ch_Spd(a4)
		move.b	_TuneGrv(a5),ch_Grv(a4)
		move.b	ch_Spd(a4),ch_SpdCnt(a4)
		addq.b	#1,ch_TunePos(a4)
		bra	.restart
.partjump	bclr	#7,d1
		beq.b	.playinst
		tst.b	ch_PartJmpCnt(a4)
		beq.b	.partjumpinit
		subq.b	#1,ch_PartJmpCnt(a4)
		beq	.partrestart
		move.b	d1,ch_PartPos(a4)
		move.b	d1,ch_PartPosWork(a4)
		bra	.partrestart
.partjumpinit	cmp.b	d1,d2
		bls	.partrestart
		move.b	ch_PartInst(a4),ch_PartJmpCnt(a4)
		bne.b	.okey
		bset	#0,ch_PlayError(a4)
.okey		move.b	d1,ch_PartPos(a4)
		move.b	d1,ch_PartPosWork(a4)
		bra	.partrestart
.playinst	tst.b	d1
		beq.b	CheckInst
		move	d5,ch_Transpose(a4)
		bra.b	CheckInst
.exit		rts

*****************************************************************************
* Play Arpeggio                                  * Conny Cyr?us - Musicline *
*****************************************************************************

CheckInst	moveq	#0,d0
		move.b	ch_PartInst(a4),d0
		move	d0,d1
		beq.b	.oldinst
		lsl	#2,d1
		move.l	InstList(pc),a0
		move.l	(a0,d1.w),d1
		beq.b	.oldinst
		move.l	d1,ch_InstPtr(a4)
		cmp.b	ch_OldInst(a4),d0
		beq.b	.oldinst
		clr.b	ch_Arp(a4)
		clr.b	ch_InstPchSld(a4)
		move.b	d0,ch_OldInst(a4)
.oldinst	bsr.b	PlayPartFx
		bsr	PlayArpg
		bra	PlayInst

PlayPartFx	bset	#1,ch_Play(a4)
		bclr	#6,ch_Effects1(a4)
		clr.b	ch_Vib(a4)
		clr	ch_VibNote(a4)
		clr	ch_PTVibNote(a4)
		clr.b	ch_Tre(a4)
		clr.b	ch_Vol(a4)
		clr.b	ch_VolAdd(a4)
		clr.b	ch_VolSld(a4)
		clr.b	ch_CVolSld(a4)
		clr.b	ch_MVolSld(a4)
		clr.b	ch_PchSld(a4)
		clr.b	ch_PTPchSld(a4)
		clr.b	ch_SmpOfs(a4)
		clr.b	ch_Restart(a4)
		and.b	#$f5,ch_Arp(a4)
		bclr	#4,ch_Arp(a4)
		beq.b	.skip
		clr.b	ch_Arp(a4)
		clr.b	ch_ArpVolSld(a4)
		clr.b	ch_ArpPchSld(a4)
		clr	ch_ArpPchSldNote(a4)
.skip		tst.b	ch_PartNote(a4)
		beq.b	.skipp
		move	#-1,ch_PchSldToNote(a4)
		move	#-1,ch_PTPchSldToNote(a4)
.skipp		lea	ch_PartEffectNum(a4),a3
		moveq	#4,d7
.loop		moveq	#0,d0
		move.b	(a3)+,d0
		move	d0,d1
		add	d1,d1
		add	d1,d1
		lea	FX_JumpTable,a2
		move.l	(a2,d1.w),a2
		jsr	(a2)
		addq	#1,a3
		dbf	d7,.loop
		rts

PlayArpg	tst.b	ch_PartNote(a4)
		beq.b	.exit
		move.l	ch_InstPtr(a4),d0
		beq.b	.exit
		clr.b	ch_ArpWait(a4)
		move.l	d0,a0
		btst	#2,ch_Arp(a4)
		bne.b	.ok
		btst	#0,ch_Arp(a4)
		bne.b	.ok
		btst	#ARPEGGIO,inst_Effects1(a0)
		beq.b	.exit
		bset	#0,ch_Arp(a4)
		bra.b	.ok
.exit		rts
.ok		tst.b	ch_Restart(a4)
		bne.b	.oki
		tst.b	ch_PartInst(a4)
		beq	.exit
.oki		bset	#1,ch_Arp(a4)
		move.l	ArpgList(pc),a1
		move	inst_ArpTable(a0),d0
		btst	#2,ch_Arp(a4)
		beq.b	.okej
		move.b	ch_ArpTab(a4),d0
.okej		lsl	#2,d0
		move.l	(a1,d0.w),d0
		beq	.exit
		move.l	d0,a1
		clr.b	ch_ArpPos(a4)
		clr.b	ch_ArpWait(a4)
		clr.b	ch_ArpVolSld(a4)
		clr.b	ch_ArpPchSld(a4)
		clr	ch_ArpPchSldNote(a4)
		move.b	inst_ArpSpeed(a0),ch_ArpSpdCnt(a4)
.restart	move.l	a1,a2
		moveq	#0,d0
		move.b	ch_ArpPos(a4),d0
		move.b	d0,d1
		addq.b	#1,d1
		and.b	#$7f,d1
		move.b	d1,ch_ArpPos(a4)
		mulu	#6,d0
		add	d0,a2
		move.b	ch_PartNote(a4),ch_ArpgNote(a4)
.note		moveq	#0,d0
		move.b	(a2)+,d0
		beq	WaitArpg
.end		cmp.b	#61,d0
		bne.b	.jump
		bclr	#ARPEGGIO,ch_Effects1(a4)
		bra	.exit
.jump		cmp.b	#62,d0
		bne.b	.ws
		bra	.restart
.ws		moveq	#0,d1
		move.b	(a2)+,d1
		move	d1,d2
		bne.b	.fx
		move.b	inst_SmplNumber(a0),d2
.fx		move.b	d2,ch_WsNumber(a4)
		moveq	#1,d7
.loop		moveq	#0,d2
		move.b	(a2)+,d2
		move	d2,d3
 		cmp	#5,d3
		bhi.b	.skip
		lsl	#2,d3
		lea	ArpFx_JmpTab(pc),a1
		move.l	(a1,d3.w),a1
		jsr	(a1)
.skip		addq	#1,a2
		dbf	d7,.loop
		tst.b	d0
		bmi.b	.transnote
		bset	#5,ch_Arp(a4)
		bra.b	.fixnote
.transnote	add.b	#61,d0
		add.b	ch_ArpgNote(a4),d0
.fixnote	ext	d0
		lsl	#5,d0
		move	d0,ch_Note(a4)
		move	d0,ch_ArpNote(a4)
ArpWaitStart	lsl	#2,d1
		bne.b	.wsptr
		rts
.wsptr		move.l	SmplList(pc),a1
		move.l	(a1,d1.w),d0
		beq.b	.exit
		move.l	d0,ch_WsPtr(a4)
		bset	#3,ch_Arp(a4)
.exit		rts
WaitArpg	bset	#0,ch_ArpWait(a4)
		rts

ArpFx_JmpTab	dc.l	ArpRts
		dc.l	ArpSldUp
		dc.l	ArpSldDwn
		dc.l	ArpSetVol
		dc.l	ArpSldVol
		dc.l	ArpSldVol
		dc.l	ArpRestart

ArpRts		rts

ArpSldUp	move.b	d2,ch_ArpPchSld(a4)
		clr.b	ch_ArpPchSldType(a4)
		moveq	#0,d3
		move.b	(a2),d3
		beq.b	.x
		move	d3,ch_ArpPchSldSpd(a4)
		move	#59*32+32,ch_ArpPchSldToNote(a4)
.x		rts

ArpSldDwn	move.b	d2,ch_ArpPchSld(a4)
		move.b	#$ff,ch_ArpPchSldType(a4)
		moveq	#0,d3
		move.b	(a2),d3
		beq.b	.x
		move	d3,ch_ArpPchSldSpd(a4)
		clr	ch_ArpPchSldToNote(a4)
.x		rts

ArpSetVol	moveq	#0,d3
		move.b	(a2),d3
		lsl	#4,d3
		bset	#2,ch_Restart(a4)
		move	d3,ch_Volume1(a4)
		move	d3,ch_Volume2(a4)
		move	d3,ch_Volume3(a4)
		rts

ArpSldVol	move.b	d2,ch_ArpVolSld(a4)
		moveq	#0,d3
		move.b	(a2),d3
		beq.b	.x
		move	d3,ch_ArpVolSldSpd(a4)
.x		rts

ArpRestart	bset	#1,ch_Restart(a4)
		move.b	ch_EffectsPar1(a4),d3
		btst	#PHASEINIT,d3
		beq.b	.next1
		clr.b	ch_PhaInit(a4)
.next1		btst	#RESONANCEINIT,d3
		beq.b	.next2
		clr.b	ch_ResInit(a4)
.next2		btst	#FILTERINIT,d3
		beq.b	.next3
		clr.b	ch_FilInit(a4)
.next3		btst	#TRANSFORMINIT,d3
		beq.b	.next4
		clr.b	ch_TraInit(a4)
.next4		btst	#MIXINIT,d3
		beq.b	.next5
		clr.b	ch_MixInit(a4)
.next5		btst	#LOOPINIT,ch_EffectsPar2(a4)
		beq.b	.next6
		clr.b	ch_LooInit(a4)
.next6		rts

PlayInst	btst	#0,ch_ArpWait(a4)
		bne	.exit
		move.l	ch_InstPtr(a4),d0
		beq	.exit
		move.l	d0,a0
		move.l	d0,a1
		move.b	ch_Restart(a4),d1
		and.b	#3,d1
		bne.b	.inst
		tst.b	ch_PartInst(a4)
		beq	.playnote
		cmp.b	#fx_Portamento,ch_PchSld(a4)
		beq	.getvol
		tst.b	ch_PartNote(a4)
		beq	.getvol
		btst	#3,ch_Arp(a4)
		beq.b	.inst
		move.l	ch_WsPtr(a4),d0
		beq	.exit
		move.l	d0,a1
		move.b	smpl_Type(a1),d1
		bne.b	.wave
		bra.b	.ws
.inst		move.b	inst_SmplNumber(a0),ch_WsNumber(a4)
.wave		move.b	smpl_Type(a0),d1
.ws		move.l	smpl_Pointer(a1),d0
		beq	.exit
		tst.b	inst_Transpose(a0)
		bne.b	.skip
		clr	ch_Transpose(a4)
.skip		move.b	inst_EnvTraPhaFilBits(a0),d3
		btst	#6,ch_Effects1(a4)
		beq.b	.noholdsus
		and.b	#$fe,d3
		and.b	#1,ch_EffectsPar1(a4)
		or.b	ch_EffectsPar1(a4),d3
.noholdsus	move.b	d3,ch_EffectsPar1(a4)
		move.b	inst_MixResLooBits(a0),ch_EffectsPar2(a4)
		move	inst_Effects1(a0),ch_Effects1(a4)

		move.b	d1,ch_WaveOrSample(a4)
		beq.b	.sample
		bsr	FixWaveLength
		bra.b	.getvolume
.sample		move	smpl_Length(a1),d1
		tst.b	ch_SmpOfs(a4)
		beq.b	.nosmpofs
		moveq	#0,d3
		move.b	ch_SmplOfs(a4),d3
		lsl	#7,d3
		cmp	d1,d3
		blo.b	.ok
		moveq	#1,d1
		bra.b	.nosmpofs
.ok		sub	d3,d1
		lsl	#1,d3
		add.l	d3,d0
.nosmpofs	move.l	d0,ch_WsPointer(a4)
		move	d1,ch_WsLength(a4)
		move.l	smpl_RepPointer(a1),d0
		btst	#3,ch_Arp(a4)
		beq.b	.instlen
		move	smpl_RepLength(a1),d1
		bra.b	.oki
.instlen	move	smpl_RepLength(a1),d1
		btst	#WSLOOP,inst_Effects1(a0)
.oki		bne.b	.wsloop
		move.l	#ZeroSample,d0
		moveq	#1,d1
.wsloop		move.l	d0,ch_WsRepPointer(a4)
		move.l	d0,ch_WsRepPtrOrg(a4)
		move	d1,ch_WsRepLength(a4)

.getvolume	and.b	#7,ch_Restart(a4)
		bne.b	.playnote
.getvol		move	inst_Volume(a0),d0
		lsl	#4,d0
		move	d0,ch_Volume1(a4)

.playnote	move	ch_Volume1(a4),d1
		tst.b	ch_Vol(a4)
		beq.b	.skip1
		move	ch_VolSet(a4),d1
.skip1		tst.b	ch_VolAdd(a4)
		beq.b	.skip2
		add	ch_VolAddNum(a4),d1
		bpl.b	.tstmaxvol
		clr	d1
.tstmaxvol	cmp	#64*16,d1
		bls.b	.skip2
		move	#64*16,d1
.skip2		move	d1,ch_Volume1(a4)
		move	d1,ch_Volume2(a4)
		move	d1,ch_Volume3(a4)

		cmp.b	#fx_Portamento,ch_PchSld(a4)
		beq	.exit

		move.b	inst_SlideSpeed(a0),d0
		beq.b	.noteplay
		moveq	#0,d2
		move.b	ch_PartNote(a4),d2
		beq.b	.noteplay
		move.b	d0,ch_PchSldSpd+1(a4)

		move	ch_Note(a4),d1
		add	ch_PchSldNote(a4),d1
		lsl	#5,d2
		move	d2,ch_PchSldToNote(a4)
		cmp	d1,d2
		smi.b	ch_PchSldType(a4)
		tst.b	ch_InstPchSld(a4)
		bne	InstPlay
		move.b	#fx_Portamento,ch_InstPchSld(a4)

.noteplay	bclr	#1,ch_Arp(a4)
		bne.b	.skip3
		moveq	#0,d1
		move.b	ch_PartNote(a4),d1
		beq.b	.exit
		lsl	#5,d1
		move	d1,ch_Note(a4)
		clr.b	ch_ArpVolSld(a4)
		clr.b	ch_ArpPchSld(a4)
		clr	ch_ArpPchSldNote(a4)
.skip3		move	smpl_SemiTone(a1),d0
		lsl	#5,d0
		move	d0,ch_SemiTone(a4)
		btst	#2,ch_Play(a4)
		bne.b	.skipp
		move	smpl_FineTune(a1),ch_FineTune(a4)
.skipp		clr	ch_PTPchSldNote(a4)
		clr	ch_PchSldNote(a4)
		clr	ch_PTVibNote(a4)
		clr.b	ch_PTTrePos(a4)
		clr.b	ch_PTVibPos(a4)
		clr	ch_VibNote(a4)
		clr	ch_PTPchAdd(a4)
		clr	ch_PchAdd(a4)
		tst.b	ch_PartInst(a4)
		bne	InstPlay
		move.b	ch_Restart(a4),d1
		and.b	#3,d1
		bne	InstPlay
.exit		rts

* Part Effects
*?????            Pitch                             ?????*
pfx_UNUSED	rts

pfx_SlideUp	move.b	d0,ch_PchSld(a4)
		clr.b	ch_PchSldType(a4)
		moveq	#0,d3
		move.b	(a3),d3
		beq.b	.x
		move	d3,ch_PchSldSpd(a4)
.x		move	#59*32+32,ch_PchSldToNote(a4)
		rts

pfx_SlideDown	move.b	d0,ch_PchSld(a4)
		move.b	#$ff,ch_PchSldType(a4)
		moveq	#0,d3
		move.b	(a3),d3
		beq.b	.x
		move	d3,ch_PchSldSpd(a4)
.x		clr	ch_PchSldToNote(a4)
		rts

pfx_Portamento	move.b	d0,ch_PchSld(a4)
		moveq	#0,d3
		move.b	(a3),d3
		beq.b	.skip
		move	d3,ch_PchSldSpd(a4)
.skip		move	ch_Note(a4),d1
		add	ch_PchSldNote(a4),d1
		moveq	#0,d2
		move.b	ch_PartNote(a4),d2
		beq.b	.x
		lsl	#5,d2
		clr.b	ch_PartNote(a4)
		move	d2,ch_PchSldToNote(a4)
		cmp	d1,d2
		beq.b	.zero
		smi.b	ch_PchSldType(a4)
		rts
.zero		move	#-1,ch_PchSldToNote(a4)
.x		cmp	#-1,ch_PchSldToNote(a4)
		bne.b	.exit
		clr.b	ch_PchSld(a4)
.exit		rts

pfx_InitInstrumentPortamento
		clr.b	ch_InstPchSld(a4)
		rts

pfx_PitchUp	moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		add	d1,ch_PchAdd(a4)
.x		rts

pfx_PitchDown	moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		sub	d1,ch_PchAdd(a4)
.x		rts

pfx_VibratoSpeed
		moveq	#0,d0
		move.b	(a3),d0
		beq.b	.x
		move	d0,ch_VibCmdSpeed(a4)
.x		rts

pfx_VibratoUp	moveq	#1,d1
		bra.b	Vibrato_pfx
pfx_VibratoDown	moveq	#0,d1
Vibrato_pfx	move.b	d0,ch_Vib(a4)
		tst.b	ch_PartNote(a4)
		beq.b	.vib
		move.b	d1,ch_VibDir(a4)
		clr	ch_VibCount(a4)
		clr	ch_VibCmdDepth(a4)
		clr	ch_VibCmdDelay(a4)
		clr	ch_VibAtkSpeed(a4)
		clr	ch_VibAtkLength(a4)
.vib		moveq	#0,d0
		move.b	(a3),d0
		beq.b	.skip
		lsl	#8,d0
		move	d0,ch_VibDepth(a4)
.skip		move.b	ch_PartVibWaveNum(a4),ch_VibWaveNum(a4)
		rts

pfx_VibratoWave	move.b	(a3),d0
		cmp.b	#3,d0
		bhi.b	.x
		move.b	d0,ch_VibWaveNum(a4)
		move.b	d0,ch_PartVibWaveNum(a4)
.x		rts

pfx_SetFinetune	moveq	#0,d1
		move.b	(a3),d1
		bmi.b	.minus
		cmp.b	#31,d1
		bls.b	.done
		moveq	#31,d1
		bra.b	.done
.minus		cmp.b	#-31,d1
		bge.b	.done
		moveq	#-31,d1
.done		ext	d1
		move	d1,ch_FineTune(a4)
		bset	#2,ch_Play(a4)
		rts

*?????            Instrument Volume                 ?????*
pfx_Volume	move.b	d0,ch_Vol(a4)
		moveq	#0,d1
		move.b	(a3),d1
		lsl	#4,d1
		move	d1,ch_VolSet(a4)
		rts

pfx_VolumeSlideUp
		move.b	d0,ch_VolSld(a4)
		moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		move	d1,ch_VolSldSpd(a4)
.x		rts
pfx_VolumeSlideDown
		move.b	d0,ch_VolSld(a4)
		moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		move	d1,ch_VolSldSpd(a4)
.x		rts

pfx_VolumeSlideToVolSet
		moveq	#0,d0
		move.b	(a3),d0
		lsl	#4,d0
		move	d0,ch_VolSldToVol(a4)
		rts
pfx_VolumeSlideToVol
		move.b	d0,ch_VolSld(a4)
		moveq	#0,d3
		move.b	(a3),d3
		beq.b	.skip
		move	d3,ch_VolSldSpd(a4)
.skip		move	ch_Volume1(a4),d1
		move	d1,ch_VolSldVol(a4)
		move	ch_VolSldToVol(a4),d2
		cmp	d1,d2
		beq.b	.zero
		smi.b	ch_VolSldType(a4)
		clr.b	ch_VolSldToVolOff(a4)
		rts
.zero		move.b	#1,ch_VolSldToVolOff(a4)
		rts

pfx_VolumeAdd	move.b	d0,ch_VolAdd(a4)
		moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		lsl	#4,d1
		move	d1,ch_VolAddNum(a4)
.x		rts
pfx_VolumeSub	move.b	d0,ch_VolAdd(a4)
		moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		lsl	#4,d1
		neg	d1
		move	d1,ch_VolAddNum(a4)
.x		rts

pfx_TremoloSpeed
		moveq	#0,d0
		move.b	(a3),d0
		beq.b	.x
		move	d0,ch_TreCmdSpeed(a4)
.x		rts
pfx_TremoloUp	moveq	#1,d1
		bra.b	Tremolo_pfx
pfx_TremoloDown	moveq	#0,d1
Tremolo_pfx	move.b	d0,ch_Tre(a4)
		tst.b	ch_PartNote(a4)
		beq.b	.tre
		move.b	d1,ch_TreDir(a4)
		clr	ch_TreCount(a4)
		clr	ch_TreCmdDepth(a4)
		clr	ch_TreCmdDelay(a4)
		clr	ch_TreAtkSpeed(a4)
		clr	ch_TreAtkLength(a4)
.tre		moveq	#0,d0
		move.b	(a3),d0
		beq.b	.skip
		lsl	#8,d0
		move	d0,ch_TreDepth(a4)
.skip		move.b	ch_PartTreWaveNum(a4),ch_TreWaveNum(a4)
		rts

pfx_TremoloWave	move.b	(a3),d0
		cmp.b	#3,d0
		bhi.b	.x
		move.b	d0,ch_TreWaveNum(a4)
		move.b	d0,ch_PartTreWaveNum(a4)
.x		rts

*?????            Channel Volume                    ?????*
pfx_ChannelVol	moveq	#0,d1
		move.b	(a3),d1
		lsl	#4,d1
		move	d1,ch_CVolume(a4)
		rts

pfx_ChannelVolSlideUp
		move.b	d0,ch_CVolSld(a4)
		moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		move	d1,ch_CVolSldSpd(a4)
.x		rts
pfx_ChannelVolSlideDown
		move.b	d0,ch_CVolSld(a4)
		moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		move	d1,ch_CVolSldSpd(a4)
.x		rts

pfx_ChannelVolSlideToVolSet
		moveq	#0,d0
		move.b	(a3),d0
		lsl	#4,d0
		move	d0,ch_CVolSldToVol(a4)
		rts
pfx_ChannelVolSlideToVol
		move.b	d0,ch_CVolSld(a4)
		moveq	#0,d3
		move.b	(a3),d3
		beq.b	.skip
		move	d3,ch_CVolSldSpd(a4)
.skip		move	ch_CVolume(a4),d1
		move	d1,ch_CVolSldVol(a4)
		move	ch_CVolSldToVol(a4),d2
		cmp	d1,d2
		beq.b	.zero
		smi.b	ch_CVolSldType(a4)
		clr.b	ch_CVolSldToVolOff(a4)
		rts
.zero		move.b	#1,ch_CVolSldToVolOff(a4)
		rts

pfx_ChannelVolAdd
		moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		lsl	#4,d1
		move	d1,ch_CVolAddNum(a4)
.x		move	ch_CVolAddNum(a4),d1
		add	d1,ch_CVolume(a4)
		cmp	#64*16,ch_CVolume(a4)
		bls.b	.next
		move	#64*16,ch_CVolume(a4)
.next		rts
pfx_ChannelVolSub
		moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		lsl	#4,d1
		move	d1,ch_CVolAddNum(a4)
.x		move	ch_CVolAddNum(a4),d1
		sub	d1,ch_CVolume(a4)
		bpl.b	.next
		clr	ch_CVolume(a4)
.next		rts

pfx_AllChannelVol
		moveq	#0,d1
		move.b	(a3),d1
		lsl	#4,d1
		lea	Channel1Buf,a2
		move	d1,ch_CVolume(a2)
		lea	Channel2Buf,a2
		move	d1,ch_CVolume(a2)
		lea	Channel3Buf,a2
		move	d1,ch_CVolume(a2)
		lea	Channel4Buf,a2
		move	d1,ch_CVolume(a2)
		tst.b	_PlayMode(a5)
		beq.b	.x
		lea	Channel5Buf,a2
		move	d1,ch_CVolume(a2)
		lea	Channel6Buf,a2
		move	d1,ch_CVolume(a2)
		lea	Channel7Buf,a2
		move	d1,ch_CVolume(a2)
		lea	Channel8Buf,a2
		move	d1,ch_CVolume(a2)
.x		rts

*?????            Master Volume                     ?????*

pfx_MasterVol	moveq	#0,d1
		move.b	(a3),d1
		lsl	#4,d1
		move	d1,_MasterVol(a5)
		rts
pfx_MasterVolSlideUp
		move.b	d0,ch_MVolSld(a4)
		moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		move	d1,ch_MVolSldSpd(a4)
.x		rts
pfx_MasterVolSlideDown
		move.b	d0,ch_MVolSld(a4)
		moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		move	d1,ch_MVolSldSpd(a4)
.x		rts

pfx_MasterVolSlideToVolSet
		moveq	#0,d0
		move.b	(a3),d0
		lsl	#4,d0
		move	d0,ch_MVolSldToVol(a4)
		rts
pfx_MasterVolSlideToVol
		move.b	d0,ch_MVolSld(a4)
		moveq	#0,d3
		move.b	(a3),d3
		beq.b	.skip
		move	d3,ch_MVolSldSpd(a4)
.skip		move	d1,ch_MVolSldVol(a4)
		move	ch_MVolSldToVol(a4),d2
		cmp	d1,d2
		beq.b	.zero
		smi.b	ch_MVolSldType(a4)
		clr.b	ch_MVolSldToVolOff(a4)
		rts
.zero		move.b	#1,ch_MVolSldToVolOff(a4)
		rts

pfx_MasterVolAdd
		moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		lsl	#4,d1
		move	d1,ch_MVolAddNum(a4)
.x		move	ch_MVolAddNum(a4),d1
		add	d1,_MasterVol(a5)
		cmp	#64*16,_MasterVol(a5)
		bls.b	.next
		move	#64*16,_MasterVol(a5)
.next		rts
pfx_MasterVolSub
		moveq	#0,d1
		move.b	(a3),d1
		beq.b	.x
		lsl	#4,d1
		move	d1,ch_MVolAddNum(a4)
.x		move	ch_MVolAddNum(a4),d1
		sub	d1,_MasterVol(a5)
		bpl.b	.next
		clr	_MasterVol(a5)
.next		rts

*?????            Other                  ?????*
pfx_SpeedPart	move.b	(a3),d0
		beq.b	.x
		cmp.b	#$1f,d0
		bls.b	.ok
		move	#$1f,d0
.ok		move.b	#1,ch_SpdPart(a4)
		move.b	d0,ch_Spd(a4)
		tst.b	ch_Grv(a4)
		beq.b	.spd
		tst.b	ch_PartGrv(a4)
		bne.b	.x
.spd		move.b	d0,ch_SpdCnt(a4)
.x		rts

pfx_GroovePart	move.b	(a3),d0
		beq.b	.x
		cmp.b	#$1f,d0
		bls.b	.ok
		move	#$1f,d0
.ok		move.b	#1,ch_GrvPart(a4)
		move.b	d0,ch_Grv(a4)
		beq.b	.spd
		tst.b	ch_PartGrv(a4)
		beq.b	.x
.spd		move.b	d0,ch_SpdCnt(a4)
.x		rts

SpeedAllMacro	MACRO
		lea	\1,a2
		cmp.l	a2,a4
		blo.b	.speed\@
		tst.b	ch_SpdPart(a2)
		bne.b	.x\@
		move.b	d0,ch_Spd(a2)
		tst.b	ch_Grv(a2)
		beq.b	.spd\@
		tst.b	ch_PartGrv(a2)
		bne.b	.x\@
.spd\@		move.b	d0,ch_SpdCnt(a2)
		bra.b	.x\@
.speed\@	move.b	d0,ch_Spd(a2)
.x\@
		ENDM

GrooveAllMacro	MACRO
		lea	\1,a2
		cmp.l	a2,a4
		blo.b	.speed\@
		tst.b	ch_GrvPart(a2)
		bne.b	.x\@
		move.b	d0,ch_Grv(a2)
		beq.b	.x\@
		tst.b	ch_PartGrv(a2)
		bne.b	.x\@
		move.b	d0,ch_SpdCnt(a2)
		bra.b	.x\@
.speed\@	move.b	d0,ch_Grv(a2)
.x\@
		ENDM

pfx_SpeedAll	moveq	#0,d0
		move.b	(a3),d0
		beq	.x
		cmp.b	#$20,d0
		blo.b	.notempo
		move	d0,_TuneTmp(a5)
		move.l	_TimerValue1(a5),d1
		divu	d0,d1
		lea	$bfd000,a1
		move.b	d1,ciatalo(a1)
		lsr	#8,d1
		move.b	d1,ciatahi(a1)
		rts
.notempo	move.b	d0,_TuneSpd(a5)
		SpeedAllMacro	Channel1Buf
		SpeedAllMacro	Channel2Buf
		SpeedAllMacro	Channel3Buf
		SpeedAllMacro	Channel4Buf
		tst.b	_PlayMode(a5)
		beq	.x
		SpeedAllMacro	Channel5Buf
		SpeedAllMacro	Channel6Buf
		SpeedAllMacro	Channel7Buf
		SpeedAllMacro	Channel8Buf
.x		rts

pfx_GrooveAll	move.b	(a3),d0
		beq	.x
		and.b	#$1f,d0
		move.b	d0,_TuneGrv(a5)
		GrooveAllMacro	Channel1Buf
		GrooveAllMacro	Channel2Buf
		GrooveAllMacro	Channel3Buf
		GrooveAllMacro	Channel4Buf
		tst.b	_PlayMode(a5)
		beq	.x
		GrooveAllMacro	Channel5Buf
		GrooveAllMacro	Channel6Buf
		GrooveAllMacro	Channel7Buf
		GrooveAllMacro	Channel8Buf
.x		rts

pfx_ArpeggioList
		bset	#2,ch_Arp(a4)
		move.b	(a3),ch_ArpTab(a4)
		rts

pfx_ArpeggioListOneStep
		or.b	#$14,ch_Arp(a4)
		move.b	(a3),ch_ArpTab(a4)
		rts

pfx_HoldSustain	bset	#6,ch_Effects1(a4)
		bclr	#ADSRHOLDSUSTAIN,ch_EffectsPar1(a4)
		tst.b	(a3)
		beq.b	.x
		bset	#ADSRHOLDSUSTAIN,ch_EffectsPar1(a4)
.x		rts

pfx_Filter	tst.b	(a3)
		beq.b	.off
		bclr	#1,$bfe001
		rts
.off		bset	#1,$bfe001
		rts

pfx_SampleOffset
		move.b	d0,ch_SmpOfs(a4)
		moveq	#0,d3
		move.b	(a3),d3
		beq.b	.nonewofs
		move.b	d3,ch_SmplOfs(a4)
.nonewofs	rts

pfx_RestartNoVolume
		tst.b	ch_PartInst(a4)
		bne.b	.exit
		move.b	#1,ch_Restart(a4)
.exit		rts

pfx_WaveSample	moveq	#0,d3
		move.b	(a3),d3
		beq.b	.exit
		move.l	SmplList(pc),a1
		lsl.l	#2,d3
		move.l	(a1,d3.w),d3
		beq.b	.exit
		move.l	d3,ch_WsPtr(a4)
		bset	#3,ch_Arp(a4)
.exit		rts

pfx_InitInstrument
		clr.b	ch_PhaInit(a4)
		clr.b	ch_ResInit(a4)
		clr.b	ch_FilInit(a4)
		clr.b	ch_TraInit(a4)
		clr.b	ch_MixInit(a4)
		clr.b	ch_LooInit(a4)
		rts

*?????            ProTracker Pitch           ?????*

pfx_PTSlideUp	move.b	d0,ch_PTPchSld(a4)
		clr.b	ch_PTPchSldType(a4)
		moveq	#0,d3
		move.b	(a3),d3
		beq.b	.x
		move	d3,ch_PTPchSldSpd(a4)
.x		move	#106,ch_PTPchSldToNote(a4)
		rts

pfx_PTSlideDown	move.b	d0,ch_PTPchSld(a4)
		move.b	#$ff,ch_PTPchSldType(a4)
		moveq	#0,d3
		move.b	(a3),d3
		beq.b	.x
		move	d3,ch_PTPchSldSpd(a4)
.x		move	#3591,ch_PTPchSldToNote(a4)
		rts
pfx_PTPortamento
		move.b	#fx_Portamento,ch_PchSld(a4)
		move.b	d0,ch_PTPchSld(a4)
		moveq	#0,d3
		move.b	(a3),d3
		beq.b	.skip
		move	d3,ch_PTPchSldSpd2(a4)
.skip		bsr	GetPeriod
		add	ch_PTPchSldNote(a4),d0
		move	d0,d2
		moveq	#0,d0
		move.b	ch_PartNote(a4),d0
		beq.b	.x
		lsl	#5,d0
		bsr	GetPeriod2
		clr.b	ch_PartNote(a4)
		move	d0,ch_PTPchSldToNote(a4)
		cmp	d0,d2
		beq.b	.zero
		smi.b	ch_PTPchSldType(a4)
		rts
.zero		move	#-1,ch_PTPchSldToNote(a4)
.x		cmp	#-1,ch_PTPchSldToNote(a4)
		bne.b	.exit
		clr.b	ch_PTPchSld(a4)
		clr.b	ch_PchSld(a4)
.exit		rts

pfx_PTFineSlideUp
		move.b	(a3),d1
		beq.b	.x
		and	#$f,d1
		sub	d1,ch_PTPchAdd(a4)
.x		rts

pfx_PTFineSlideDown
		move.b	(a3),d1
		beq.b	.x
		and	#$f,d1
		add	d1,ch_PTPchAdd(a4)
.x		rts

pfx_PTTremolo	move.b	d0,ch_Tre(a4)
		move.b	(a3),d0
		beq.b	.x
		move.b	ch_PTTreCmd(a4),d2
		and.b	#$0f,d0
		beq.b	.treskip
		and.b	#$f0,d2
		or.b	d0,d2
.treskip	move.b	(a3),d0
		and.b	#$f0,d0
		beq.b	.treskip2
		and.b	#$0f,d2
		or.b	d0,d2
.treskip2	move.b	d2,ch_PTTreCmd(a4)
.x		rts

pfx_PTTremoloWave
		move.b	(a3),d0
		and.b	#$0f,d0
		move.b	d0,ch_PTTreWave(a4)
		rts

pfx_PTVibrato	move.b	d0,ch_Vib(a4)
		move.b	(a3),d0
		beq.b	.x
		move.b	ch_PTVibCmd(a4),d2
		and.b	#$0f,d0
		beq.b	.vibskip
		and.b	#$f0,d2
		or.b	d0,d2
.vibskip	move.b	(a3),d0
		and.b	#$f0,d0
		beq.b	.vibskip2
		and.b	#$0f,d2
		or.b	d0,d2
.vibskip2	move.b	d2,ch_PTVibCmd(a4)
.x		rts

pfx_PTVibratoWave
		move.b	(a3),d0
		and.b	#$0f,d0
		move.b	d0,ch_PTVibWave(a4)
		rts

pfx_PTVolSlideUp
		bra	pfx_VolumeSlideUp
pfx_PTVolSlideDown
		bra	pfx_VolumeSlideDown

*?????            UserCommand            ?????*
pfx_UserCommand			rts

FixWaveLength	cmp.b	#1,d1
		bhi.b	.fix1
		add.l	#256+128+64+32,d0
		move.l	d0,ch_WsPointer(a4)
		move.l	d0,ch_WsRepPointer(a4)
		move.l	d0,ch_WsRepPtrOrg(a4)
		move	inst_SmplLength(a0),d0
		lsr	#4,d0
		move	d0,ch_WsLength(a4)
		move	d0,ch_WsRepLength(a4)
		bra	.skip
.fix1		cmp.b	#2,d1
		bhi.b	.fix2
		add.l	#256+128+64,d0
		move.l	d0,ch_WsPointer(a4)
		move.l	d0,ch_WsRepPointer(a4)
		move.l	d0,ch_WsRepPtrOrg(a4)
		move	inst_SmplLength(a0),d0
		lsr	#3,d0
		move	d0,ch_WsLength(a4)
		move	d0,ch_WsRepLength(a4)
		bra.b	.skip
.fix2		cmp.b	#3,d1
		bhi.b	.fix3
		add.l	#256+128,d0
		move.l	d0,ch_WsPointer(a4)
		move.l	d0,ch_WsRepPointer(a4)
		move.l	d0,ch_WsRepPtrOrg(a4)
		move	inst_SmplLength(a0),d0
		lsr	#2,d0
		move	d0,ch_WsLength(a4)
		move	d0,ch_WsRepLength(a4)
		bra.b	.skip
.fix3		cmp.b	#4,d1
		bhi.b	.fix4
		add.l	#256,d0
		move.l	d0,ch_WsPointer(a4)
		move.l	d0,ch_WsRepPointer(a4)
		move.l	d0,ch_WsRepPtrOrg(a4)
		move	inst_SmplLength(a0),d0
		lsr	#1,d0
		move	d0,ch_WsLength(a4)
		move	d0,ch_WsRepLength(a4)
		bra.b	.skip
.fix4		move.l	d0,ch_WsPointer(a4)
		move.l	d0,ch_WsRepPointer(a4)
		move.l	d0,ch_WsRepPtrOrg(a4)
		move	inst_SmplLength(a0),d0
		move	d0,ch_WsLength(a4)
		move	d0,ch_WsRepLength(a4)
.skip		rts

* Twins/PHA *****************************************************************
* Play Arpeggio                                       Last Change: 93-01-15 *
*****************************************************************************

InstPlay	cmp.b	#fx_Portamento,ch_PchSld(a4)
		beq	Sexit
		btst	#0,ch_ArpWait(a4)
		bne	Sexit
		bset	#0,ch_Play(a4)
.vibrato	tst.b	ch_Vib(a4)
		bne.b	.tremolo
		btst	#VIBRATO,ch_Effects1(a4)
		beq.b	.tremolo
		clr	ch_VibCount(a4)
		clr	ch_VibCmdDepth(a4)
		move	inst_VibSpeed(a0),ch_VibCmdSpeed(a4)
		move	inst_VibDelay(a0),ch_VibCmdDelay(a4)
		move	inst_VibAtkSpd(a0),ch_VibAtkSpeed(a4)
		move	inst_VibAttack(a0),ch_VibAtkLength(a4)
		move	inst_VibDepth(a0),ch_VibDepth(a4)
		move.b	inst_VibWaveNum(a0),ch_VibWaveNum(a4)
		move.b	inst_VibDir(a0),ch_VibDir(a4)
.tremolo	tst.b	ch_Tre(a4)
		bne.b	.adsr
		btst	#TREMOLO,ch_Effects1(a4)
		beq.b	.adsr
		clr	ch_TreCount(a4)
		clr	ch_TreCmdDepth(a4)
		move	inst_TreSpeed(a0),ch_TreCmdSpeed(a4)
		move	inst_TreDelay(a0),ch_TreCmdDelay(a4)
		move	inst_TreAtkSpd(a0),ch_TreAtkSpeed(a4)
		move	inst_TreAttack(a0),ch_TreAtkLength(a4)
		move	inst_TreDepth(a0),ch_TreDepth(a4)
		move.b	inst_TreWaveNum(a0),ch_TreWaveNum(a4)
		move.b	inst_TreDir(a0),ch_TreDir(a4)
.adsr		btst	#ADSR,ch_Effects1(a4)
		beq.b	.phaseing
		clr	ch_ADSRVolume(a4)
		lea	inst_EnvAttLen(a0),a1
		lea	ch_ADSRData(a4),a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
.phaseing	btst	#PHASE,ch_Effects2(a4)
		beq.b	.resonancing
		move.b	inst_PhaType+1(a0),ch_PhaType(a4)
		lea	ch_PhaData(a4),a2
		btst	#PHASESTEP,ch_EffectsPar1(a4)
		sne	cnt_step(a2)
		beq.b	.pskipstep
		move	inst_PhaTurns(a0),ch_PhaSpd(a4)
		clr	cnt_turns(a2)
		bra.b	.phainit
.pskipstep	move	inst_PhaTurns(a0),cnt_turns(a2)
		btst	#PHASEINIT,ch_EffectsPar1(a4)
		bne.b	.phainit
		clr.b	ch_PhaInit(a4)
.phase		move	inst_PhaStart(a0),d0
		move	d0,cnt_counter(a2)
		move	inst_PhaSpeed(a0),cnt_speed(a2)
		move	inst_PhaRepeat(a0),d1
		move	d1,cnt_repeat(a2)
		move	inst_PhaRepEnd(a0),cnt_repeatend(a2)
		cmp	d1,d0
		ble.b	.phago
		neg	cnt_speed(a2)
.phago		move	inst_PhaDelay(a0),cnt_delay(a2)
		bra.b	.resonancing
.phainit	move.b	ch_PhaInit(a4),d0
		move.b	ch_PartInst(a4),ch_PhaInit(a4)
.phaskip	cmp.b	ch_PartInst(a4),d0
		bne	.phase
		bra	.phago

.resonancing	move.b	inst_MixResFilBoost(a0),ch_MixResFilBoost(a4)
		btst	#RESONANCE,ch_Effects2(a4)
		beq.b	.filtering
		move.b	inst_ResAmp(a0),ch_ResAmp(a4)
		lea	ch_ResData(a4),a2
		btst	#RESONANCESTEP,ch_EffectsPar2(a4)
		sne	cnt_step(a2)
		beq.b	.rskipstep
		move	inst_ResTurns(a0),ch_ResSpd(a4)
		clr	cnt_turns(a2)
		bra.b	.resinit
.rskipstep	move	inst_ResTurns(a0),cnt_turns(a2)
		btst	#RESONANCEINIT,ch_EffectsPar2(a4)
		bne.b	.resinit
		clr.b	ch_ResInit(a4)
.resonace	move.b	#1,ch_ResLastInit(a4)
		move	inst_ResStart(a0),d0
		move	d0,cnt_counter(a2)
		move	inst_ResSpeed(a0),cnt_speed(a2)
		move	inst_ResRepeat(a0),d1
		move	d1,cnt_repeat(a2)
		move	inst_ResRepEnd(a0),cnt_repeatend(a2)
		cmp	d1,d0
		ble.b	.resgo
		neg	cnt_speed(a2)
.resgo		move	inst_ResDelay(a0),cnt_delay(a2)
		bra.b	.filtering
.resinit	move.b	ch_ResInit(a4),d0
		move.b	ch_PartInst(a4),ch_ResInit(a4)
.resskip	cmp.b	ch_PartInst(a4),d0
		bne	.resonace
		bra	.resgo

.filtering	btst	#FILTER,ch_Effects2(a4)
		beq.b	.mix
		move.b	inst_FilType(a0),ch_FilType(a4)
		lea	ch_FilData(a4),a2
		btst	#FILTERSTEP,ch_EffectsPar1(a4)
		sne	cnt_step(a2)
		beq.b	.fskipstep
		move	inst_FilTurns(a0),ch_FilSpd(a4)
		clr	cnt_turns(a2)
		bra.b	.filinit
.fskipstep	move	inst_FilTurns(a0),cnt_turns(a2)
		btst	#FILTERINIT,ch_EffectsPar1(a4)
		bne.b	.filinit
		clr.b	ch_FilInit(a4)
.filter		move.b	#1,ch_FilLastInit(a4)
		move	inst_FilStart(a0),d0
		move	d0,cnt_counter(a2)
		move	inst_FilSpeed(a0),cnt_speed(a2)
		move	inst_FilRepeat(a0),d1
		move	d1,cnt_repeat(a2)
		move	inst_FilRepEnd(a0),cnt_repeatend(a2)
		cmp	d1,d0
		ble.b	.filgo
		neg	cnt_speed(a2)
.filgo		move	inst_FilDelay(a0),cnt_delay(a2)
		bra.b	.mix
.filinit	move.b	ch_FilInit(a4),d0
		move.b	ch_PartInst(a4),ch_FilInit(a4)
.filskip	cmp.b	ch_PartInst(a4),d0
		bne	.filter
		bra	.filgo

.mix		btst	#MIX,ch_Effects2(a4)
		beq.b	.transform
		move.b	inst_MixWaveNum(a0),ch_MixWaveNum(a4)
		lea	ch_MixData(a4),a2
		btst	#MIXSTEP,ch_EffectsPar2(a4)
		sne	cnt_step(a2)
		beq.b	.mskipstep
		move	inst_MixTurns(a0),ch_MixSpd(a4)
		clr	cnt_turns(a2)
		bra.b	.mixinit
.mskipstep	move	inst_MixTurns(a0),cnt_turns(a2)
		btst	#MIXINIT,ch_EffectsPar2(a4)
		bne.b	.mixinit
		clr.b	ch_MixInit(a4)
.mixse		move	inst_MixStart(a0),d0
		move	d0,cnt_counter(a2)
		move	inst_MixSpeed(a0),cnt_speed(a2)
		move	inst_MixRepeat(a0),d1
		move	d1,cnt_repeat(a2)
		move	inst_MixRepEnd(a0),cnt_repeatend(a2)
		cmp	d1,d0
		ble.b	.mixgo
		neg	cnt_speed(a2)
.mixgo		move	inst_MixDelay(a0),cnt_delay(a2)
		bra.b	.transform
.mixinit	move.b	ch_MixInit(a4),d0
		move.b	ch_PartInst(a4),ch_MixInit(a4)
.mixskip	cmp.b	ch_PartInst(a4),d0
		bne	.mixse
		bra	.mixgo

.transform	btst	#TRANSFORM,ch_Effects2(a4)
		beq	.playloop
		lea	inst_TraWaveNums(a0),a1
		lea	ch_TraWsPtrs(a4),a2
		move.b	inst_SmplNumber(a0),(a2)+
		move.b	(a1)+,(a2)+
		move.b	(a1)+,(a2)+
		move.b	(a1)+,(a2)+
		move.b	(a1)+,(a2)+
		move.b	(a1)+,(a2)+
		lea	ch_TraData(a4),a2
		btst	#TRANSFORMSTEP,ch_EffectsPar1(a4)
		sne	cnt_step(a2)
		beq.b	.tskipstep
		move	inst_TraTurns(a0),ch_TraSpd(a4)
		clr	cnt_turns(a2)
		bra.b	.trainit
.tskipstep	move	inst_TraTurns(a0),cnt_turns(a2)
		btst	#TRANSFORMINIT,ch_EffectsPar1(a4)
		bne.b	.trainit
		clr.b	ch_TraInit(a4)
.trans		move	inst_TraStart(a0),d0
		move	d0,(a2)
		move	inst_TraSpeed(a0),2(a2)
		move	inst_TraRepeat(a0),d1
		move	d1,4(a2)
		move	inst_TraRepEnd(a0),6(a2)
		cmp	d1,d0
		ble.b	.trago
		neg	2(a2)
.trago		move	inst_TraDelay(a0),10(a2)
		bra.b	.playloop
.trainit	move.b	ch_TraInit(a4),d0
		move.b	ch_PartInst(a4),ch_TraInit(a4)
.traskip	cmp.b	ch_PartInst(a4),d0
		bne	.trans
		bra	.trago

.playloop	btst	#LOOP,ch_Effects1(a4)
		beq	Sexit
		tst.b	inst_SmplType(a0)
		bne.b	.pexit
		tst	inst_LooLength(a0)
		bne.b	.oki
.pexit		bclr	#LOOP,ch_Effects1(a4)
		bra	Sexit
.oki		btst	#LOOPSTEP,ch_EffectsPar2(a4)
		beq.b	.lskipstep
		move	inst_LooTurns(a0),ch_LooSpd(a4)
		clr	ch_LooTurns(a4)
		bra	.plinit
.lskipstep	move	inst_LooTurns(a0),ch_LooTurns(a4)
		btst	#LOOPINIT,ch_EffectsPar2(a4)
		bne	.plinit
		clr.b	ch_LooInit(a4)
.loop		move.l	SmplList(pc),a1
		moveq	#0,d0
		move.b	inst_SmplNumber(a0),d0
		add	d0,d0
		add	d0,d0
		add	d0,a1
		move.l	(a1),a1
		moveq	#0,d2
		move	smpl_Length(a1),d2
		move.l	smpl_Pointer(a1),a1
		move.l	a1,ch_LooWsPointer(a4)
		move	inst_LooStart(a0),d0
		move	d0,ch_LooCounter(a4)
		move	d0,ch_LooCounterSave(a4)
		moveq	#0,d1
		move	inst_LooLength(a0),d1
		sub.l	d1,d2
		move	d2,ch_LooWsCounterMax(a4)
		move	d1,ch_LooLength(a4)
		move	inst_LooRepEnd(a0),ch_LooRepEnd(a4)
		move	inst_LooWait(a0),ch_LooWait(a4)
		moveq	#0,d1
		move	inst_LooLpStep(a0),d1
		move.l	d1,ch_LooStep(a4)
		move	inst_LooRepeat(a0),d1
		move	d1,ch_LooRepeat(a4)
		cmp	d1,d0
		ble.b	.plgo
		neg.l	ch_LooStep(a4)
.plgo		move	inst_LooDelay(a0),ch_LooDelay(a4)
		clr	ch_LooWaitCounter(a4)
		moveq	#0,d0
		move	ch_LooCounterSave(a4),d0
		move.l	ch_LooWsPointer(a4),d1
		add.l	d0,d0
		add.l	d0,d1
		move.l	d1,ch_WsPointer(a4)
		move.l	d1,ch_WsRepPointer(a4)
		move.l	d1,ch_WsRepPtrOrg(a4)
		move	ch_LooLength(a4),d1
		move	d1,ch_WsLength(a4)
		move	d1,ch_WsRepLength(a4)
		bra.b	Sexit
.plinit		move.b	ch_LooInit(a4),d0
		move.b	ch_PartInst(a4),ch_LooInit(a4)
.plskip		cmp.b	ch_PartInst(a4),d0
		bne	.loop
		bclr	#0,ch_Play(a4)
		bra	.plgo

Sexit		move	ch_WsRepLength(a4),d0
		subq	#8,d0
		beq.b	.okidoki
		subq	#8,d0
		beq.b	.okidoki
		sub	#16,d0
		beq.b	.okidoki
		sub	#32,d0
		beq.b	.okidoki
		sub	#64,d0
		beq.b	.okidoki
		clr.b	ch_Effects2(a4)
.okidoki	rts

PerCalc		lea	Channel1Buf,a4
		bsr.b	Per
		lea	Channel2Buf,a4
		bsr.b	Per
		lea	Channel3Buf,a4
		bsr.b	Per
		lea	Channel4Buf,a4
		bsr.b	Per
		tst.b	_PlayMode(a5)
		beq.b	.exit
		lea	Channel5Buf,a4
		bsr.b	Per
		lea	Channel6Buf,a4
		bsr.b	Per
		lea	Channel7Buf,a4
		bsr.b	Per
		lea	Channel8Buf,a4
		bsr.b	Per
.exit		rts

Per		move	ch_Note(a4),d0
		add	ch_VibNote(a4),d0
		add	ch_PchSldNote(a4),d0
		add	ch_ArpPchSldNote(a4),d0
		add	ch_SemiTone(a4),d0
		add	ch_FineTune(a4),d0
		add	ch_PchAdd(a4),d0
		btst	#5,ch_Arp(a4)
		bne.b	.notranspose
		move	ch_Transpose(a4),d1
		beq.b	.notranspose
		add	d1,d0
.notranspose	cmp	#-32,d0
		bge.b	.ok
		moveq	#-32,d0
.ok		cmp	#5*12*32,d0
		ble.b	.oki
		move	#5*12*32,d0
.oki		add	d0,d0
		lea	PalPitchTable,a0
		move	(a0,d0.w),d0
		add	ch_PTPchSldNote(a4),d0
		add	ch_PTVibNote(a4),d0
		add	ch_PTPchAdd(a4),d0
		cmp	#106,d0
		bge.b	.ok1
		moveq	#106,d0
.ok1		cmp	#3591,d0
		ble.b	.ok2
		move	#3591,d0
.ok2		move	d0,ch_Period1(a4)
		move	d0,ch_Period2(a4)
.noper		rts

PerVolPlay	tst.b	_PlayMode(a5)
		bne.b	Play8PerVol
		lea	Channel1Buf,a4
		bsr.b	.pervolplay
		lea	Channel2Buf,a4
		bsr.b	.pervolplay
		lea	Channel3Buf,a4
		bsr.b	.pervolplay
		lea	Channel4Buf,a4

.pervolplay	btst	#0,ch_Play(a4)
		bne.b	.nopervol
		move.l	ch_CustomAddress(a4),a6
		move	ch_Period2(a4),6(a6)
		move	ch_Period2(a4),ch_VUPeriod(a4)
.noper		tst.b	ch_ChannelOff(a4)
		bne.b	.nopervol
		move	ch_Volume3(a4),d1
.channelvol	mulu	ch_CVolume(a4),d1
		lsl.l	#6,d1
		swap	d1
.mastervol	mulu	_MasterVol(a5),d1
.voldone	lsl.l	#2,d1
		swap	d1
		move	d1,8(a6)
		move	d1,ch_VUVolume(a4)
.nopervol	rts

Play8PerVol	lea	VolumeTables,a6
		move.l	_SndFBuf(a5),a2
		clr	SndBufSize-2(a2)
		lea	Channel1Buf,a4
		bsr.b	Play8PV
		move.l	_SndFBuf(a5),a2
		add	#(2*SndBufSize),a2
		clr	SndBufSize-2(a2)
		lea	Channel2Buf,a4
		bsr.b	Play8PV
		move.l	_SndFBuf(a5),a2
		add	#(2*(2*SndBufSize)),a2
		clr	SndBufSize-2(a2)
		lea	Channel3Buf,a4
		bsr.b	Play8PV
		move.l	_SndFBuf(a5),a2
		add	#(3*(2*SndBufSize)),a2
		clr	SndBufSize-2(a2)
		lea	Channel4Buf,a4
		bsr.b	Play8PV
		move.l	_SndFBuf(a5),a2
		lea	Channel5Buf,a4
		bsr.b	Play8PV
		move.l	_SndFBuf(a5),a2
		add	#(2*SndBufSize),a2
		lea	Channel6Buf,a4
		bsr.b	Play8PV
		move.l	_SndFBuf(a5),a2
		add	#(2*(2*SndBufSize)),a2
		lea	Channel7Buf,a4
		bsr.b	Play8PV
		move.l	_SndFBuf(a5),a2
		add	#(3*(2*SndBufSize)),a2
		lea	Channel8Buf,a4

Play8PV		btst	#0,ch_Play(a4)
		beq.b	.ok
.exit		rts
.ok		tst.b	ch_MixSmplEnd(a4)
		beq.b	.oki
		tst	SndBufSize-2(a2)
		bne.b	.end
		move	_MixLength(a5),d7
		subq	#1,d7
		add	_DoubleBuf(a5),a2
.clear		clr.b	(a2)+
		dbf	d7,.clear
.end		rts
.oki		moveq	#0,d1
		tst.b	ch_ChannelOff(a4)
		bne.b	.novol1
		move	ch_Volume3(a4),d1
.channelvol	mulu	ch_CVolume(a4),d1
		lsl.l	#6,d1
		swap	d1
.mastervol	mulu	_MasterVol(a5),d1
.voldone	lsr.l	#6,d1
		and	#$ff00,d1
.novol1		add.l	a6,d1
		move.l	d1,ch_MixVolTable(a4)
		move.l	_PeriodValue(a5),d0
		move	ch_Period2(a4),d1
		move	d1,ch_VUPeriod(a4)
		beq.b	.exit
		divu	d1,d0
		moveq	#0,d1
		move	d0,d1
		add.l	d1,d1
		move.l	d1,ch_MixAdd2(a4)
		moveq	#0,d0
		move	ch_MixWsLen(a4),d0
		add.l	d0,d0
		move.l	d0,d6
		sub.l	ch_MixWsCounter(a4),d0
		move.l	d0,d2
		moveq	#0,d1
		move	ch_Period2(a4),d1
		lsl.l	#8,d1
		divu	_MixPeriod(a5),d1
		mulu	d1,d0
		add.l	ch_MixSaveDec1(a4),d0
		move.b	d0,ch_MixSaveDec1+3(a4)
		lsr.l	#8,d0
		swap	d2
		tst	d2
		beq.b	.no
		moveq	#0,d2
		move	d1,d2
		lsl.l	#8,d2
		add.l	d2,d0
.no		move.l	d0,ch_MixWsLength(a4)
		tst	SndBufSize-2(a2)
		bne	MixAdd
		bra	MixMove

DmaPlay		tst.b	_PlayMode(a5)
		bne	Play8channels
		moveq	#0,d0
		or	_DmaSave(a5),d0
		moveq	#100,d7
		lea	$dff000,a6
		lea	Channel1Buf,a4
		btst	#0,ch_Play(a4)
		beq.b	.nplay1
		move.b	ch_WsNumber(a4),d1
		move.b	ch_WsNumberOld(a4),d2
		move.b	d1,ch_WsNumberOld(a4)
		tst.b	ch_WaveOrSample(a4)
		beq.b	.play1
		cmp.b	d1,d2
		beq.b	.nplay1
.play1		or	#1,d0
		cmp	_DmaWait1(a5),d7
		bge.b	.nplay1
		move	_DmaWait1(a5),d7
.nplay1		lea	Channel2Buf,a4
		btst	#0,ch_Play(a4)
		beq.b	.nplay2
		move.b	ch_WsNumber(a4),d1
		move.b	ch_WsNumberOld(a4),d2
		move.b	d1,ch_WsNumberOld(a4)
		tst.b	ch_WaveOrSample(a4)
		beq.b	.play2
		cmp.b	d1,d2
		beq.b	.nplay2
.play2		or	#2,d0
		cmp	_DmaWait2(a5),d7
		bge.b	.nplay2
		move	_DmaWait2(a5),d7
.nplay2		lea	Channel3Buf,a4
		btst	#0,ch_Play(a4)
		beq.b	.nplay3
		move.b	ch_WsNumber(a4),d1
		move.b	ch_WsNumberOld(a4),d2
		move.b	d1,ch_WsNumberOld(a4)
		tst.b	ch_WaveOrSample(a4)
		beq.b	.play3
		cmp.b	d1,d2
		beq.b	.nplay3
.play3		or	#4,d0
		cmp	_DmaWait3(a5),d7
		bge.b	.nplay3
		move	_DmaWait3(a5),d7
.nplay3		lea	Channel4Buf,a4
		btst	#0,ch_Play(a4)
		beq.b	.nplay4
		move.b	ch_WsNumber(a4),d1
		move.b	ch_WsNumberOld(a4),d2
		move.b	d1,ch_WsNumberOld(a4)
		tst.b	ch_WaveOrSample(a4)
		beq.b	.play4
		cmp.b	d1,d2
		beq.b	.nplay4
.play4		or	#8,d0
		cmp	_DmaWait4(a5),d7
		bge.b	.nplay4
		move	_DmaWait4(a5),d7
.nplay4		move	d0,$96(a6)
		move	d0,_DmaSave(a5)
		move.b	#1,_DmaWait(a5)
		lea	Channel1Buf,a4
		move	ch_Period2(a4),_DmaWait1(a5)
		lea	Channel2Buf,a4
		move	ch_Period2(a4),_DmaWait2(a5)
		lea	Channel3Buf,a4
		move	ch_Period2(a4),_DmaWait3(a5)
		lea	Channel4Buf,a4
		move	ch_Period2(a4),_DmaWait4(a5)
		lea	$bfd000,a4
		move.b	d7,ciatblo(a4)
		lsr.w	#8,d7
		move.b	d7,ciatbhi(a4)
.exit		rts

PlayDma		movem.l	d0-d7/a0-a6,-(sp)
		lea	Bss,a5
		lea	$dff000,a6
		moveq	#0,d0
		move.b	_DmaWait(a5),d0
		subq	#1,d0
		bmi.b	.exit
		lsl	#2,d0
		lea	DmaJmpTab,a0
		move.l	(a0,d0.w),a0
		jsr	(a0)
.exit		movem.l	(sp)+,d0-d7/a0-a6
		rts

DmaJmpTab	dc.l	Dma1
		dc.l	Dma2
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0

Dma1		lea	Channel1Buf,a4
		bclr	#0,ch_Play(a4)
		beq.b	.noplay1
		tst.b	ch_ChannelOff(a4)
		bne.b	.novol1
		move	ch_Volume3(a4),d1
.channelvol	mulu	ch_CVolume(a4),d1
		lsl.l	#6,d1
		swap	d1
.mastervol	mulu	_MasterVol(a5),d1
.voldone	lsl.l	#2,d1
		swap	d1
		move	d1,$a8(a6)
		move	d1,ch_VUVolume(a4)
.novol1		move	ch_Period2(a4),ch_VUPeriod(a4)
		move.l	ch_WsPointer(a4),ch_VUWsPointer(a4)
		moveq	#0,d1
		move	ch_WsLength(a4),d1
		add.l	d1,d1
		move.l	d1,ch_VUWsLength(a4)
		move.l	ch_WsPointer(a4),$a0(a6)
		move	ch_WsLength(a4),$a4(a6)
		move	ch_Period2(a4),$a6(a6)

.noplay1	lea	Channel2Buf,a4
		bclr	#0,ch_Play(a4)
		beq.b	.noplay2
		tst.b	ch_ChannelOff(a4)
		bne.b	.novol2
		move	ch_Volume3(a4),d1
.channelvol2	mulu	ch_CVolume(a4),d1
		lsl.l	#6,d1
		swap	d1
.mastervol2	mulu	_MasterVol(a5),d1
.voldone2	lsl.l	#2,d1
		swap	d1
		move	d1,$b8(a6)
		move	d1,ch_VUVolume(a4)
.novol2		move	ch_Period2(a4),ch_VUPeriod(a4)
		move.l	ch_WsPointer(a4),ch_VUWsPointer(a4)
		moveq	#0,d1
		move	ch_WsLength(a4),d1
		add.l	d1,d1
		move.l	d1,ch_VUWsLength(a4)
		move.l	ch_WsPointer(a4),$b0(a6)
		move	ch_WsLength(a4),$b4(a6)
		move	ch_Period2(a4),$b6(a6)

.noplay2	lea	Channel3Buf,a4
		bclr	#0,ch_Play(a4)
		beq.b	.noplay3
		tst.b	ch_ChannelOff(a4)
		bne.b	.novol3
		move	ch_Volume3(a4),d1
.channelvol3	mulu	ch_CVolume(a4),d1
		lsl.l	#6,d1
		swap	d1
.mastervol3	mulu	_MasterVol(a5),d1
.voldone3	lsl.l	#2,d1
		swap	d1
		move	d1,$c8(a6)
		move	d1,ch_VUVolume(a4)
.novol3		move	ch_Period2(a4),ch_VUPeriod(a4)
		move.l	ch_WsPointer(a4),ch_VUWsPointer(a4)
		moveq	#0,d1
		move	ch_WsLength(a4),d1
		add.l	d1,d1
		move.l	d1,ch_VUWsLength(a4)
		move.l	ch_WsPointer(a4),$c0(a6)
		move	ch_WsLength(a4),$c4(a6)
		move	ch_Period2(a4),$c6(a6)

.noplay3	lea	Channel4Buf,a4
		bclr	#0,ch_Play(a4)
		beq.b	.noplay4
		tst.b	ch_ChannelOff(a4)
		bne.b	.novol4
		move	ch_Volume3(a4),d1
.channelvol4	mulu	ch_CVolume(a4),d1
		lsl.l	#6,d1
		swap	d1
.mastervol4	mulu	_MasterVol(a5),d1
.voldone4	lsl.l	#2,d1
		swap	d1
		move	d1,$d8(a6)
		move	d1,ch_VUVolume(a4)
.novol4		move	ch_Period2(a4),ch_VUPeriod(a4)
		move.l	ch_WsPointer(a4),ch_VUWsPointer(a4)
		moveq	#0,d1
		move	ch_WsLength(a4),d1
		add.l	d1,d1
		move.l	d1,ch_VUWsLength(a4)
		move.l	ch_WsPointer(a4),$d0(a6)
		move	ch_WsLength(a4),$d4(a6)
		move	ch_Period2(a4),$d6(a6)

.noplay4	move	_DmaSave(a5),d0
		bset	#15,d0
		move	d0,$96(a6)
		move.b	#2,_DmaWait(a5)
		move	#150,d7
		lea	$bfd000,a4
		move.b	d7,ciatblo(a4)
		lsr.w	#8,d7
		move.b	d7,ciatbhi(a4)
		rts

Dma2		move	_DmaSave(a5),d0
		btst	#0,d0
		beq.b	.noplay1
		lea	Channel1Buf,a4
		move.l	ch_WsRepPointer(a4),ch_VUWsRepPointer(a4)
		moveq	#0,d1
		move	ch_WsRepLength(a4),d1
		add.l	d1,d1
		move.l	d1,ch_VUWsRepLength(a4)
		move.l	ch_WsRepPointer(a4),$a0(a6)
		move	ch_WsRepLength(a4),$a4(a6)

.noplay1	btst	#1,d0
		beq.b	.noplay2
		lea	Channel2Buf,a4
		move.l	ch_WsRepPointer(a4),ch_VUWsRepPointer(a4)
		moveq	#0,d1
		move	ch_WsRepLength(a4),d1
		add.l	d1,d1
		move.l	d1,ch_VUWsRepLength(a4)
		move.l	ch_WsRepPointer(a4),$b0(a6)
		move	ch_WsRepLength(a4),$b4(a6)

.noplay2	btst	#2,d0
		beq.b	.noplay3
		lea	Channel3Buf,a4
		move.l	ch_WsRepPointer(a4),ch_VUWsRepPointer(a4)
		moveq	#0,d1
		move	ch_WsRepLength(a4),d1
		add.l	d1,d1
		move.l	d1,ch_VUWsRepLength(a4)
		move.l	ch_WsRepPointer(a4),$c0(a6)
		move	ch_WsRepLength(a4),$c4(a6)

.noplay3	btst	#3,d0
		beq.b	.noplay4
		lea	Channel4Buf,a4
		move.l	ch_WsRepPointer(a4),ch_VUWsRepPointer(a4)
		moveq	#0,d1
		move	ch_WsRepLength(a4),d1
		add.l	d1,d1
		move.l	d1,ch_VUWsRepLength(a4)
		move.l	ch_WsRepPointer(a4),$d0(a6)
		move	ch_WsRepLength(a4),$d4(a6)

.noplay4	clr	_DmaSave(a5)
		clr.b	_DmaWait(a5)
		rts

Dma4		lea	$dff000,a6
		move.l	_SndCBuf(a5),a0
		add	_DoubleBuf(a5),a0
		move.l	a0,$a0(a6)
		add	#(2*SndBufSize),a0
		move.l	a0,$b0(a6)
		add	#(2*SndBufSize),a0
		move.l	a0,$c0(a6)
		add	#(2*SndBufSize),a0
		move.l	a0,$d0(a6)
		rts

Dma6		lea	$dff000,a6
		move	#$0080,$9c(a6)
		move	#$8080,$9a(a6)
		move	#$800f,$96(a6)
		move	#64,$a8(a6)
		move	#64,$b8(a6)
		move	#64,$c8(a6)
		move	#64,$d8(a6)
		rts

_MixLength	rs.w	1
_MixPeriod	rs.w	1
_DoubleBuf	rs.w	1
_PeriodValue	rs.l	1

Play8channels	lea	VolumeTables,a6
		move.l	_SndFBuf(a5),a2
		lea	Channel1Buf,a4
		bsr.b	Play8ch
		move.l	_SndFBuf(a5),a2
		add	#(2*SndBufSize),a2
		lea	Channel2Buf,a4
		bsr.b	Play8ch
		move.l	_SndFBuf(a5),a2
		add	#(2*(2*SndBufSize)),a2
		lea	Channel3Buf,a4
		bsr.b	Play8ch
		move.l	_SndFBuf(a5),a2
		add	#(3*(2*SndBufSize)),a2
		lea	Channel4Buf,a4
		bsr.b	Play8ch
		move.l	_SndFBuf(a5),a2
		lea	Channel5Buf,a4
		bsr.b	Play8ch
		move.l	_SndFBuf(a5),a2
		add	#(2*SndBufSize),a2
		lea	Channel6Buf,a4
		bsr.b	Play8ch
		move.l	_SndFBuf(a5),a2
		add	#(2*(2*SndBufSize)),a2
		lea	Channel7Buf,a4
		bsr.b	Play8ch
		move.l	_SndFBuf(a5),a2
		add	#(3*(2*SndBufSize)),a2
		lea	Channel8Buf,a4

Play8ch		bclr	#0,ch_Play(a4)
		bne.b	.ok
.exit		rts
.ok		moveq	#0,d1
		tst.b	ch_ChannelOff(a4)
		bne.b	.novol1
		move	ch_Volume3(a4),d1
.channelvol	mulu	ch_CVolume(a4),d1
		lsl.l	#6,d1
		swap	d1
.mastervol	mulu	_MasterVol(a5),d1
.voldone	lsr.l	#6,d1
		and	#$ff00,d1
.novol1		add.l	a6,d1
		move.l	d1,ch_MixVolTable(a4)
		move.l	ch_WsPointer(a4),ch_MixWsPointer(a4)
		clr.l	ch_MixWsCounter(a4)
		clr.l	ch_MixSaveDec1(a4)
		clr	ch_MixSaveDec2(a4)
		clr.b	ch_MixSmplEnd(a4)
		move.l	_PeriodValue(a5),d0
		move	ch_Period2(a4),d1
		beq.b	.exit
		divu	d1,d0
		moveq	#0,d1
		move	d0,d1
		add.l	d1,d1
		move.l	d1,ch_MixAdd2(a4)
		moveq	#0,d0
		move	ch_WsLength(a4),d0
		move	d0,ch_MixWsLen(a4)
		add.l	d0,d0
		move.l	d0,d6
		move.l	d0,d2
		moveq	#0,d1
		move	ch_Period2(a4),d1
		lsl.l	#8,d1
		divu	_MixPeriod(a5),d1
		mulu	d1,d0
		move.b	d0,ch_MixSaveDec1+3(a4)
		lsr.l	#8,d0
		swap	d2
		tst	d2
		beq.b	.no
		moveq	#0,d2
		move	d1,d2
		lsl.l	#8,d2
		add.l	d2,d0
.no		move.l	d0,ch_MixWsLength(a4)
		moveq	#0,d0
		bset	#LOOP,d0
		bset	#WSLOOP,d0
		move.b	ch_Effects1(a4),d1
		and.b	d0,d1
		move.b	d1,ch_MixLoop(a4)
		tst	SndBufSize-2(a2)
		bne	MixAdd

MixMove		move	#1,SndBufSize-2(a2)
		moveq	#0,d4
		move	ch_MixAdd2(a4),d4
		add	_DoubleBuf(a5),a2
		move.l	a2,-(sp)
		move.l	ch_MixWsPointer(a4),a0
		move.l	ch_MixVolTable(a4),a1

		moveq	#0,d7
		move	_MixLength(a5),d7
		subq	#1,d7
.loop		move.l	ch_MixWsCounter(a4),d0
		moveq	#0,d1
		move	ch_MixAdd1(a4),d2
		move	ch_MixSaveDec2(a4),d3
		move.l	ch_MixWsLength(a4),d5
		subq.l	#1,d5
		bmi.b	.skip
		cmp.l	d7,d5
		blt.b	.mix2
.mix1		cmp.l	d6,d0
		bge.b	.skip
		add	d2,d3
		move.b	(a0,d0.l),d1
		addx.l	d4,d0
		move.b	(a1,d1.w),(a2)+
		dbf	d7,.mix1
		move.l	d0,ch_MixWsCounter(a4)
		move	d3,ch_MixSaveDec2(a4)

.done		move.l	(sp)+,a2
		rts

.mix2		cmp.l	d6,d0
		bge.b	.skip
		subq	#1,d7
		add	d2,d3
		move.b	(a0,d0.l),d1
		addx.l	d4,d0
		move.b	(a1,d1.w),(a2)+
		dbf	d5,.mix2

.skip		tst.b	ch_MixLoop(a4)
		bne.b	.wsloop
.clear		clr.b	(a2)+
		dbf	d7,.clear
		move.b	#1,ch_MixSmplEnd(a4)
		bra.b	.done
.wsloop		move.l	ch_WsRepPointer(a4),a0
		move.l	a0,ch_MixWsPointer(a4)
		clr.l	ch_MixWsCounter(a4)
		clr	ch_MixSaveDec2(a4)
		move.l	_PeriodValue(a5),d0
		divu	ch_Period2(a4),d0
		moveq	#0,d1
		move	d0,d1
		add.l	d1,d1
		move.l	d1,ch_MixAdd2(a4)
		moveq	#0,d0
		move	ch_WsRepLength(a4),d0
		move	d0,ch_MixWsLen(a4)
		add.l	d0,d0
		move.l	d0,d6
		move.l	d0,d2
		moveq	#0,d1
		move	ch_Period2(a4),d1
		lsl.l	#8,d1
		divu	_MixPeriod(a5),d1
		mulu	d1,d0
		add.l	ch_MixSaveDec1(a4),d0
		move.b	d0,ch_MixSaveDec1+3(a4)
		lsr.l	#8,d0
		swap	d2
		tst	d2
		beq.b	.no
		moveq	#0,d2
		move	d1,d2
		lsl.l	#8,d2
		add.l	d2,d0
.no		move.l	d0,ch_MixWsLength(a4)
		bra	.loop

MixAdd		moveq	#0,d4
		move	ch_MixAdd2(a4),d4
		add	_DoubleBuf(a5),a2
		move.l	a2,-(sp)
		move.l	ch_MixWsPointer(a4),a0
		move.l	ch_MixVolTable(a4),a1

		moveq	#0,d7
		move	_MixLength(a5),d7
		subq	#1,d7
.loop		move.l	ch_MixWsCounter(a4),d0
		moveq	#0,d1
		move	ch_MixAdd1(a4),d2
		move	ch_MixSaveDec2(a4),d3
		move.l	ch_MixWsLength(a4),d5
		subq.l	#1,d5
		bmi.b	.skip
		cmp.l	d7,d5
		blt.b	.mix2
.mix1		cmp.l	d6,d0
		bge.b	.skip
		move.b	(a0,d0.l),d1
		add	d2,d3
		move.b	(a1,d1.w),d1
		addx.l	d4,d0
		add.b	d1,(a2)+
		dbf	d7,.mix1
		move.l	d0,ch_MixWsCounter(a4)
		move	d3,ch_MixSaveDec2(a4)

.done		move.l	(sp)+,a2
		rts

.mix2		cmp.l	d6,d0
		bge.b	.skip
		subq	#1,d7
		move.b	(a0,d0.l),d1
		add	d2,d3
		move.b	(a1,d1.w),d1
		addx.l	d4,d0
		add.b	d1,(a2)+
		dbf	d5,.mix2

.skip		tst.b	ch_MixLoop(a4)
		bne.b	.wsloop
		move.b	#1,ch_MixSmplEnd(a4)
		bra.b	.done
.wsloop		move.l	ch_WsRepPointer(a4),a0
		move.l	a0,ch_MixWsPointer(a4)
		clr.l	ch_MixWsCounter(a4)
		clr	ch_MixSaveDec2(a4)
		move.l	_PeriodValue(a5),d0
		divu	ch_Period2(a4),d0
		moveq	#0,d1
		move	d0,d1
		add.l	d1,d1
		move.l	d1,ch_MixAdd2(a4)
		moveq	#0,d0
		move	ch_WsRepLength(a4),d0
		move	d0,ch_MixWsLen(a4)
		add.l	d0,d0
		move.l	d0,d6
		move.l	d0,d2
		moveq	#0,d1
		move	ch_Period2(a4),d1
		lsl.l	#8,d1
		divu	_MixPeriod(a5),d1
		mulu	d1,d0
		add.l	ch_MixSaveDec1(a4),d0
		move.b	d0,ch_MixSaveDec1+3(a4)
		lsr.l	#8,d0
		swap	d2
		tst	d2
		beq.b	.no
		moveq	#0,d2
		move	d1,d2
		lsl.l	#8,d2
		add.l	d2,d0
.no		move.l	d0,ch_MixWsLength(a4)
		bra	.loop

PlayEffects	lea	Channel1Buf,a4
		lea	$dff0a0,a6
		bsr.b	.playfx
		lea	Channel2Buf,a4
		lea	$dff0b0,a6
		bsr.b	.playfx
		lea	Channel3Buf,a4
		lea	$dff0c0,a6
		bsr.b	.playfx
		lea	Channel4Buf,a4
		lea	$dff0d0,a6
		tst.b	_PlayMode(a5)
		beq.b	.playfx
		bsr.b	.playfx
		lea	Channel5Buf,a4
		lea	$dff0a0,a6
		bsr.b	.playfx
		lea	Channel6Buf,a4
		lea	$dff0b0,a6
		bsr.b	.playfx
		lea	Channel7Buf,a4
		lea	$dff0c0,a6
		bsr.b	.playfx
		lea	Channel8Buf,a4
		lea	$dff0d0,a6

.playfx		move.l	ch_WsRepPtrOrg(a4),ch_WsRepPointer(a4)
		btst	#0,ch_Play(a4)
		bne.b	.every1
		bsr	SlideVol
		bsr	SlideChannelVol
		bsr	SlideMasterVol
		bsr	SlideArpVol
		bsr	SlideNote
		bsr	SlideArpNote
		bsr	ArpeggioPlay
		bsr	VibratoPlay
		bsr	TremoloPlay
.every1		bsr	ADSRPlay
		bsr	MoveLoop
		bsr	TransformPlay
		bsr	PhasePlay
		bsr	MixPlay
		bsr	ResonancePlay
		bsr	FilterPlay

		tst.b	_PlayMode(a5)
		bne.b	.loopplay
		tst.l	_FreeSndFBuf(a5)
		beq.b	.loopplay
		lea	ch_TraWaveBuffer(a4),a0
		lea	ch_FilWaveBuffer(a4),a1
		move.l	ch_WsRepPointer(a4),a2
		cmp.l	a0,a2
		blo.b	.loopplay
		cmp.l	a1,a2
		bhi.b	.loopplay
		move.l	ch_WaveBuffer(a4),a3
		move.l	a3,ch_WsRepPointer(a4)
		tst.b	ch_WaveOrSample(a4)
		beq.b	.test
		bra.b	.fixptr
.test		btst	#LOOP,ch_Effects1(a4)
		beq.b	.skipptr
.fixptr		move.l	a3,ch_WsPointer(a4)
.skipptr	move	ch_WsRepLength(a4),d0
		lsr	#3,d0
		subq	#1,d0
.moveloop1	move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		dbf	d0,.moveloop1

.loopplay	btst	#0,ch_Play(a4)
		bne.b	.next1
		btst	#LOOP,ch_Effects1(a4)
		beq.b	.next1
		tst.b	_PlayMode(a5)
		bne.b	.n1
		move.l	ch_WsRepPointer(a4),d0
		move.l	d0,ch_VUWsRepPointer(a4)
		move.l	d0,(a6)
		moveq	#0,d0
		move	ch_LooLength(a4),d0
		move	d0,4(a6)
		add.l	d0,d0
		move.l	d0,ch_VUWsRepLength(a4)
.n1		move	ch_LooLength(a4),ch_WsRepLength(a4)
.next1		tst.b	ch_ArpWait(a4)
		bne.b	.x
		clr.b	ch_PartNote(a4)
.x		and.b	#1,ch_Play(a4)
		rts

***************************************************************************

MoveLoop	moveq	#0,d0
		moveq	#0,d2
		btst	#LOOP,ch_Effects1(a4)
		beq	.exit
		btst	#LOOPSTEP,ch_EffectsPar2(a4)
		bne.b	.step
		subq	#1,ch_LooDelay(a4)
		bpl	.exit2
		clr	ch_LooDelay(a4)
		tst	ch_LooWait(a4)
		beq.b	.count
		subq	#1,ch_LooWaitCounter(a4)
		bpl	.exit
		move	ch_LooWait(a4),ch_LooWaitCounter(a4)
		bra.b	.count
.step		btst	#LOOPINIT,ch_EffectsPar2(a4)
		bne.b	.initstep
		tst.b	ch_PartNote(a4)
		beq.b	.nocount
		bra.b	.count
.initstep	tst.b	ch_PartNote(a4)
		beq.b	.counter
.count		move	ch_LooCounter(a4),ch_LooCounterSave(a4)
.counter	bsr	LoopCounter
.nocount	move	ch_LooCounterSave(a4),d0

		btst	#LOOPSTEP,ch_EffectsPar2(a4)
		beq.b	.nostep
		subq	#1,ch_LooDelay(a4)
		bpl.b	.nostep
		clr	ch_LooDelay(a4)
		tst	ch_LooWait(a4)
		beq.b	.ok
		subq	#1,ch_LooWaitCounter(a4)
		bpl.b	.nostep
		move	ch_LooWait(a4),ch_LooWaitCounter(a4)
.ok		move	ch_LooStep+2(a4),d3
		bpl.b	.loopok
		neg	d3
.loopok		moveq	#0,d2
		move	ch_LooCounterSave(a4),d2
		move.b	ch_LooSpd+1(a4),d1
		ext	d1
		bpl.b	.right
.left		muls	d3,d1
		add.l	d1,d2
		bpl.b	.endstep
		clr	ch_LooCounterSave(a4)
		bra.b	.nostep
.right		muls	d3,d1
		add.l	d1,d2
		moveq	#0,d1
		move	ch_LooWsCounterMax(a4),d1
		cmp.l	d2,d1
		bhi.b	.endstep
		move	d1,d2
.endstep	move	d2,ch_LooCounterSave(a4)

.nostep		move.l	ch_LooWsPointer(a4),d1
		add.l	d0,d0
		add.l	d0,d1
		move.l	d1,ch_WsRepPointer(a4)
		move.l	d1,ch_WsRepPtrOrg(a4)
		tst	ch_LooTurns(a4)
		bpl.b	.exit
		btst	#LOOPSTOP,ch_Effects1(a4)
		beq.b	.exit
		clr.b	ch_MixLoop(a4)
		bclr	#LOOP,ch_Effects1(a4)
		tst.b	_PlayMode(a5)
		bne.b	.exit
		lea	ZeroSample,a0
		move.l	a0,(a6)
		move.l	a0,ch_VUWsPointer(a4)
		move	#1,4(a6)
.exit		rts

.exit2		move	ch_LooCounterSave(a4),d0
		move.l	ch_LooWsPointer(a4),d1
		add.l	d0,d0
		add.l	d0,d1
		move.l	d1,ch_WsRepPointer(a4)
		move.l	d1,ch_WsRepPtrOrg(a4)
		rts

LoopCounter	move	ch_LooCounter(a4),d0
.lc_go		tst	ch_LooTurns(a4)
		bmi.b	.lc_exit
		move	ch_LooRepeat(a4),d1
		cmp	ch_LooRepEnd(a4),d1
		blo.b	.lc_normal
		bra.b	.lc_inverted
.lc_notok	tst	ch_LooTurns(a4)
		beq.b	.lc_turn
		subq	#1,ch_LooTurns(a4)
		bne.b	.lc_turn
		move	#-1,ch_LooTurns(a4)
.lc_turn	sub.l	ch_LooStep(a4),d0
		neg.l	ch_LooStep(a4)
.lc_ok		move	d0,ch_LooCounter(a4)
.lc_exit	rts

.lc_normal	tst.l	ch_LooStep(a4)
		bpl.b	.lc_nadd
.lc_nsub	add.l	ch_LooStep(a4),d0
		move	ch_LooRepeat(a4),d2
		cmp.l	d2,d0
		bge.b	.lc_ok
		bra.b	.lc_notok
.lc_nadd	add.l	ch_LooStep(a4),d0
		move	ch_LooRepEnd(a4),d2
		cmp.l	d2,d0
		ble.b	.lc_ok
		bra.b	.lc_notok

.lc_inverted	tst.l	ch_LooStep(a4)
		bpl.b	.lc_iadd
.lc_isub	add.l	ch_LooStep(a4),d0
		move	ch_LooRepEnd(a4),d2
		cmp.l	d2,d0
		bge.b	.lc_ok
		bra.b	.lc_notok
.lc_iadd	add.l	ch_LooStep(a4),d0
		move	ch_LooRepeat(a4),d2
		cmp.l	d2,d0
		ble.b	.lc_ok
		bra.b	.lc_notok

***************************************************************************

SlideNote	move.b	ch_PTPchSld(a4),d1
		bne.b	PTSlideNote
		tst.b	ch_PchSld(a4)
		bne.b	.tonote
		tst.b	ch_InstPchSld(a4)
		beq.b	.x1
.tonote		tst	ch_PchSldToNote(a4)
		bmi.b	.x1
		move	ch_PchSldSpd(a4),d0
		tst.b	ch_PchSldType(a4)
		bne.b	.slidedown

.slideup	add	d0,ch_PchSldNote(a4)
		move	ch_Note(a4),d0
		add	ch_PchSldNote(a4),d0
		sub	ch_PchSldToNote(a4),d0
		blt.b	.x1
		sub	d0,ch_PchSldNote(a4)
		move	#-1,ch_PchSldToNote(a4)
.x1		rts

.slidedown	sub	d0,ch_PchSldNote(a4)
		move	ch_Note(a4),d0
		add	ch_PchSldNote(a4),d0
		sub	ch_PchSldToNote(a4),d0
		bgt.b	.x2
		sub	d0,ch_PchSldNote(a4)
		move	#-1,ch_PchSldToNote(a4)
.x2		rts

PTSlideNote	btst	#1,ch_Play(a4)
		bne.b	.x1
		tst	ch_PTPchSldToNote(a4)
		bmi.b	.x1
		move	ch_PTPchSldSpd(a4),d0
		cmp.b	#fx_PTPortamento,d1
		bne.b	.skip
		move	ch_PTPchSldSpd2(a4),d0
.skip		tst.b	ch_PTPchSldType(a4)
		bne.b	.slidedown

.slideup	sub	d0,ch_PTPchSldNote(a4)
		bsr.b	GetPeriod
		add	ch_PTPchSldNote(a4),d0
		sub	ch_PTPchSldToNote(a4),d0
		bgt.b	.x1
		sub	d0,ch_PTPchSldNote(a4)
		move	#-1,ch_PTPchSldToNote(a4)
.x1		rts

.slidedown	add	d0,ch_PTPchSldNote(a4)
		bsr.b	GetPeriod
		add	ch_PTPchSldNote(a4),d0
		sub	ch_PTPchSldToNote(a4),d0
		blt.b	.x2
		sub	d0,ch_PTPchSldNote(a4)
		move	#-1,ch_PTPchSldToNote(a4)
.x2		rts

GetPeriod	move	ch_Note(a4),d0
GetPeriod2	add	ch_VibNote(a4),d0
		add	ch_PchSldNote(a4),d0
		add	ch_ArpPchSldNote(a4),d0
		add	ch_SemiTone(a4),d0
		add	ch_FineTune(a4),d0
		add	ch_PchAdd(a4),d0
		move	ch_Transpose(a4),d1
		beq.b	.notranspose
		add	d1,d0
.notranspose	cmp	#-32,d0
		bge.b	.ok
		moveq	#-32,d0
.ok		cmp	#5*12*32,d0
		ble.b	.oki
		move	#5*12*32,d0
.oki		add	d0,d0
		lea	PalPitchTable,a0
		move	(a0,d0.w),d0
		rts

SlideArpNote	tst.b	ch_ArpPchSld(a4)
		beq.b	.x1
		tst	ch_ArpPchSldToNote(a4)
		bmi.b	.x1
		tst.b	ch_ArpPchSldType(a4)
		bne.b	.slidedown

.slideup	move	ch_ArpPchSldSpd(a4),d0
		add	d0,ch_ArpPchSldNote(a4)
		move	ch_ArpNote(a4),d0
		add	ch_ArpPchSldNote(a4),d0
		sub	ch_ArpPchSldToNote(a4),d0
		blt.b	.x1
		sub	d0,ch_ArpPchSldNote(a4)
		move	#-1,ch_ArpPchSldToNote(a4)
.x1		rts

.slidedown	move	ch_ArpPchSldSpd(a4),d0
		sub	d0,ch_ArpPchSldNote(a4)
		move	ch_ArpNote(a4),d0
		add	ch_ArpPchSldNote(a4),d0
		sub	ch_ArpPchSldToNote(a4),d0
		bgt.b	.x2
		sub	d0,ch_ArpPchSldNote(a4)
		move	#-1,ch_ArpPchSldToNote(a4)
.x2		rts

SlideVol	cmp.b	#fx_VolumeSlideToVol,ch_VolSld(a4)
		bne.b	.checknext
		tst.b	ch_VolSldToVolOff(a4)
		bne.b	.exit
		tst.b	ch_VolSldType(a4)
		bne.b	.slidedown
.slideup	move	ch_Volume1(a4),d2
		add	ch_VolSldSpd(a4),d2
		cmp	ch_VolSldToVol(a4),d2
		ble.b	.ok1
		move	ch_VolSldToVol(a4),d2
		move.b	#1,ch_VolSldToVolOff(a4)
.ok1		move	d2,ch_Volume1(a4)
		move	d2,ch_Volume2(a4)
		move	d2,ch_Volume3(a4)
		rts
.slidedown	move	ch_Volume1(a4),d2
		sub	ch_VolSldSpd(a4),d2
		cmp	ch_VolSldToVol(a4),d2
		bge.b	.ok2
		move	ch_VolSldToVol(a4),d2
		move.b	#1,ch_VolSldToVolOff(a4)
.ok2		move	d2,ch_Volume1(a4)
		move	d2,ch_Volume2(a4)
		move	d2,ch_Volume3(a4)
.exit		rts
.checknext	cmp.b	#fx_VolumeSlideUp,ch_VolSld(a4)
		beq.b	.okej1
		cmp.b	#fx_PTVolSlideUp,ch_VolSld(a4)
		bne.b	.down
		btst	#1,ch_Play(a4)
		bne.b	.exit
.okej1		move	ch_Volume1(a4),d2
		add	ch_VolSldSpd(a4),d2
		cmp	#64*16,d2
		ble.b	.ok3
		move	#64*16,d2
.ok3		move	d2,ch_Volume1(a4)
		move	d2,ch_Volume2(a4)
		move	d2,ch_Volume3(a4)
		rts
.down		cmp.b	#fx_VolumeSlideDown,ch_VolSld(a4)
		beq.b	.okej2
		cmp.b	#fx_PTVolSlideDown,ch_VolSld(a4)
		bne.b	.exit
		btst	#1,ch_Play(a4)
		bne.b	.exit
.okej2		move	ch_Volume1(a4),d2
		sub	ch_VolSldSpd(a4),d2
		bpl.b	.ok4
		moveq	#0,d2
.ok4		move	d2,ch_Volume1(a4)
		move	d2,ch_Volume2(a4)
		move	d2,ch_Volume3(a4)
		rts

SlideChannelVol	cmp.b	#fx_ChannelVolSlideToVol,ch_CVolSld(a4)
		bne.b	.checknext
		tst.b	ch_CVolSldToVolOff(a4)
		bne.b	.exit
		tst.b	ch_CVolSldType(a4)
		bne.b	.slidedown
.slideup	move	ch_CVolume(a4),d2
		add	ch_CVolSldSpd(a4),d2
		cmp	ch_CVolSldToVol(a4),d2
		ble.b	.ok1
		move	ch_CVolSldToVol(a4),d2
		move.b	#1,ch_CVolSldToVolOff(a4)
.ok1		move	d2,ch_CVolume(a4)
		rts
.slidedown	move	ch_CVolume(a4),d2
		sub	ch_CVolSldSpd(a4),d2
		cmp	ch_CVolSldToVol(a4),d2
		bge.b	.ok2
		move	ch_CVolSldToVol(a4),d2
		move.b	#1,ch_CVolSldToVolOff(a4)
.ok2		move	d2,ch_CVolume(a4)
.exit		rts
.checknext	cmp.b	#fx_ChannelVolSlideUp,ch_CVolSld(a4)
		bne.b	.down
		move	ch_CVolume(a4),d2
		add	ch_CVolSldSpd(a4),d2
		cmp	#64*16,d2
		ble.b	.ok3
		move	#64*16,d2
.ok3		move	d2,ch_CVolume(a4)
		rts
.down		cmp.b	#fx_ChannelVolSlideDown,ch_CVolSld(a4)
		bne.b	.exit
		move	ch_CVolume(a4),d2
		sub	ch_CVolSldSpd(a4),d2
		bpl.b	.ok4
		moveq	#0,d2
.ok4		move	d2,ch_CVolume(a4)
		rts

SlideMasterVol	cmp.b	#fx_MasterVolSlideToVol,ch_MVolSld(a4)
		bne.b	.checknext
		tst.b	ch_MVolSldToVolOff(a4)
		bne.b	.exit
		tst.b	ch_MVolSldType(a4)
		bne.b	.slidedown
.slideup	move	_MasterVol(a5),d2
		add	ch_MVolSldSpd(a4),d2
		cmp	ch_MVolSldToVol(a4),d2
		ble.b	.ok1
		move	ch_MVolSldToVol(a4),d2
		move.b	#1,ch_MVolSldToVolOff(a4)
.ok1		move	d2,_MasterVol(a5)
		rts
.slidedown	move	_MasterVol(a5),d2
		sub	ch_MVolSldSpd(a4),d2
		cmp	ch_MVolSldToVol(a4),d2
		bge.b	.ok2
		move	ch_MVolSldToVol(a4),d2
		move.b	#1,ch_MVolSldToVolOff(a4)
.ok2		move	d2,_MasterVol(a5)
.exit		rts
.checknext	cmp.b	#fx_MasterVolSlideUp,ch_MVolSld(a4)
		bne.b	.down
		move	_MasterVol(a5),d2
		add	ch_MVolSldSpd(a4),d2
		cmp	#64*16,d2
		ble.b	.ok3
		move	#64*16,d2
.ok3		move	d2,_MasterVol(a5)
		rts
.down		cmp.b	#fx_MasterVolSlideDown,ch_MVolSld(a4)
		bne	.exit
		move	_MasterVol(a5),d2
		sub	ch_MVolSldSpd(a4),d2
		bpl.b	.ok4
		moveq	#0,d2
.ok4		move	d2,_MasterVol(a5)
		rts

SlideArpVol	cmp.b	#4,ch_ArpVolSld(a4)
		bne.b	.down
		move	ch_Volume1(a4),d2
		add	ch_ArpVolSldSpd(a4),d2
		cmp	#64*16,d2
		ble.b	.ok1
		move	#64*16,d2
.ok1		move	d2,ch_Volume1(a4)
		move	d2,ch_Volume2(a4)
		move	d2,ch_Volume3(a4)
		rts
.down		cmp.b	#5,ch_ArpVolSld(a4)
		bne.b	.exit
		move	ch_Volume1(a4),d2
		sub	ch_ArpVolSldSpd(a4),d2
		bpl.b	.ok1
		moveq	#0,d2
		bra.b	.ok2
.ok2		move	d2,ch_Volume1(a4)
		move	d2,ch_Volume2(a4)
		move	d2,ch_Volume3(a4)
.exit		rts

ArpeggioPlay	btst	#2,ch_Arp(a4)
		bne.b	.play
		btst	#0,ch_Arp(a4)
		beq	.exit
.play		subq.b	#1,ch_ArpSpdCnt(a4)
		bne	.exit
		move.l	ch_InstPtr(a4),a0
		move.b	inst_ArpSpeed(a0),d0
		not.b	ch_ArpgGrv(a4)
		beq.b	.nogrv
		move.b	inst_ArpGroove(a0),d1
		beq.b	.nogrv
		exg	d0,d1
.nogrv		move.b	d0,ch_ArpSpdCnt(a4)
.arpeggio	move.l	ArpgList(pc),a1
		move	inst_ArpTable(a0),d0
		btst	#2,ch_Arp(a4)
		beq.b	.okej
		move.b	ch_ArpTab(a4),d0
.okej		lsl	#2,d0
		move.l	(a1,d0.w),d0
		beq	.exit
		move.l	d0,a1
.restart	move.l	a1,a2
		moveq	#0,d0
		move.b	ch_ArpPos(a4),d0
		move.b	d0,d2
		addq.b	#1,ch_ArpPos(a4)
		and.b	#$7f,ch_ArpPos(a4)
		mulu	#6,d0
		add	d0,a2
		tst.b	ch_ArpWait(a4)
		beq.b	.oki
		tst.b	(a2)
		beq	.exit
.oki		moveq	#0,d0
		move.b	(a2)+,d0
.end		cmp.b	#61,d0
		bne.b	.jump
		clr.b	ch_Arp(a4)
		move	ch_ArpNote(a4),ch_Note(a4)
		bra	.exit
.jump		cmp.b	#62,d0
		bne.b	.nojump
		move.b	(a2)+,d1
		cmp.b	d1,d2
		beq	.restart
		move.b	d1,ch_ArpPos(a4)
		bra	.restart
.nojump		moveq	#0,d1
		move.b	(a2)+,d1
		move	d1,d2
		bne.b	.fx
		move.b	inst_SmplNumber(a0),d2
.fx		move.b	d2,ch_WsNumber(a4)
		clr.b	ch_Restart(a4)
		clr.b	ch_ArpPchSld(a4)
		clr.b	ch_ArpVolSld(a4)
		moveq	#1,d7
.loop		moveq	#0,d2
		move.b	(a2)+,d2
		move	d2,d3
		cmp	#6,d3
		bhi.b	.skip
		add	d3,d3
		add	d3,d3
		lea	ArpFx_JmpTab(pc),a1
		move.l	(a1,d3.w),a1
		jsr	(a1)
.skip		addq	#1,a2
		dbf	d7,.loop

		bclr	#5,ch_Arp(a4)
		tst.b	d0
		beq	.exit
		bmi.b	.transnote
		bset	#5,ch_Arp(a4)
		bra.b	.fixnote
.transnote	add.b	#61,d0
		add.b	ch_ArpgNote(a4),d0
.fixnote	ext	d0
		lsl	#5,d0
		move	d0,ch_ArpNote(a4)
		move	d0,ch_Note(a4)
		clr	ch_ArpPchSldNote(a4)
		bclr	#0,ch_ArpWait(a4)
		beq.b	.nowait
		bsr	ArpWaitStart
		bra	PlayInst
.nowait		btst	#1,ch_Restart(a4)
		beq.b	.norestart
		bset	#1,ch_Arp(a4)
		lsl	#2,d1
		bne.b	.wsptr
		bra	PlayInst
.wsptr		move.l	SmplList(pc),a1
		move.l	(a1,d1.w),d0
		beq	.exit
		move.l	d0,ch_WsPtr(a4)
		bset	#3,ch_Arp(a4)
		bra	PlayInst
.norestart	lsl	#2,d1
		bne.b	.ok
		move	inst_SemiTone(a0),d0
		lsl	#5,d0
		move	d0,ch_SemiTone(a4)
		btst	#2,ch_Play(a4)
		bne	.exit
		move	inst_FineTune(a0),ch_FineTune(a4)
		bra	.exit
.ok		bset	#0,ch_Play(a4)
		move.l	SmplList(pc),a1
		move.l	(a1,d1.w),d0
		beq	.exit
		move.l	d0,a1
		move	smpl_SemiTone(a1),d0
		lsl	#5,d0
		move	d0,ch_SemiTone(a4)
		btst	#2,ch_Play(a4)
		bne.b	.skippa
		move	smpl_FineTune(a1),ch_FineTune(a4)
.skippa		move.l	smpl_Pointer(a1),d0
		move.b	smpl_Type(a1),ch_WaveOrSample(a4)
		beq.b	.sample
		move.b	inst_SmplType(a0),d1
		bne.b	.wave
		moveq	#3,d1
.wave		move.b	d1,ch_WaveOrSample(a4)
		bsr	FixWaveLength
		bra.b	.checklen
.sample		move.l	d0,ch_WsPointer(a4)
		move	smpl_Length(a1),ch_WsLength(a4)
		move.l	smpl_RepPointer(a1),d0
		move	smpl_RepLength(a1),d1
		bne.b	.wsloop
		move.l	#ZeroSample,d0
		moveq	#1,d1
.wsloop		move.l	d0,ch_WsRepPointer(a4)
		move.l	d0,ch_WsRepPtrOrg(a4)
		move	d1,ch_WsRepLength(a4)
		move	ch_WsRepLength(a4),d0
.checklen	subq	#8,d0
		beq.b	.okidoki
		subq	#8,d0
		beq.b	.okidoki
		sub	#16,d0
		beq.b	.okidoki
		sub	#32,d0
		beq.b	.okidoki
		sub	#64,d0
		beq.b	.okidoki
		clr.b	ch_Effects2(a4)
.exit		rts
.okidoki	move.b	inst_Effects2(a0),ch_Effects2(a4)
		rts

ADSRPlay	btst	#ADSR,ch_Effects1(a4)
		beq.b	.exit
		lea	ch_ADSRData(a4),a0
		move	(a0)+,d0
		bne.b	.found
		move	(a0)+,d0
		bne.b	.found
		move	(a0)+,d0
		bne.b	.found

		btst	#ADSRHOLDSUSTAIN,ch_EffectsPar1(a4)
		beq.b	.nothold
		move	14(a0),d1
		bra.b	.notzero

.nothold	move	(a0)+,d0
		bne.b	.found
		move	14(a0),d1
		bra.b	.notzero

.found		move	ch_ADSRVolume(a4),d1
		add	6(a0),d1
		move	d1,ch_ADSRVolume(a4)
		lsr	#8,d1

		subq	#1,d0
		move	d0,-(a0)
		bne.b	.notzero
		move	16(a0),d1
.notzero	mulu	ch_Volume2(a4),d1
		lsr.l	#6,d1
		move	d1,ch_Volume3(a4)
.exit		rts

TremoloPlay	cmp.b	#fx_PTTremolo,ch_Tre(a4)
		beq	PTTremoloPlay
		tst.b	ch_Tre(a4)
		bne.b	.go
		btst	#TREMOLO,ch_Effects1(a4)
		beq	.exit
		tst	ch_TreCmdDelay(a4)
		beq.b	.go
		subq	#1,ch_TreCmdDelay(a4)
		rts

.go		tst	ch_TreAtkLength(a4)
		bne.b	.attack
		move	ch_TreDepth(a4),ch_TreCmdDepth(a4)
		bra.b	.vibba

.attack		move	ch_TreAtkSpeed(a4),d0
		add	d0,ch_TreCmdDepth(a4)
		subq	#1,ch_TreAtkLength(a4)
		bne.b	.vibba
		move	ch_TreDepth(a4),ch_TreCmdDepth(a4)

.vibba		move	ch_TreCount(a4),d0
		move	ch_TreCmdSpeed(a4),d1
		move	ch_TreCmdDepth(a4),d2
		lsr	#8,d2
		moveq	#0,d3
		move.b	ch_TreWaveNum(a4),d3
		lsl	#7,d3
		lea	Sine,a0
		add	d3,a0
		lsr	#2,d0
		move.b	(a0,d0.w),d3
		ext	d3
		tst.b	ch_TreDir(a4)
		bne.b	.oki
		neg	d3
.oki		muls	d2,d3
		asr.l	#1,d3
		bpl.b	.plus1
		add	#16,d3

.plus1		move	ch_Volume1(a4),d4
		beq.b	.notre
		add	d3,d4
		bpl.b	.ok1
		moveq	#0,d4
.ok1		cmp	#64*16,d4
		ble.b	.notre
		move	#64*16,d4
.notre		move	d4,ch_Volume2(a4)
		move	d4,ch_Volume3(a4)
		move	ch_TreCount(a4),d0
		add	d1,d0
		and	#$1ff,d0
		move	d0,ch_TreCount(a4)
.exit		rts

PTTremoloPlay	btst	#1,ch_Play(a4)
		bne	.exit
		move.b	ch_PTTrePos(a4),d0
		lea	PTVibratoTable(pc),a0
		lsr	#2,d0
		and	#$001f,d0
		moveq	#0,d2
		move.b	ch_PTTreWave(a4),d2
		and.b	#$03,d2
		beq.b	.tre_sine
		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.b	.tre_rampdown
		move.b	#255,d2
		bra.b	.tre_set
.tre_rampdown	tst.b	ch_PTTrePos(a4)
		bpl.b	.tre_rampdown2
		move.b	#255,d2
		sub.b	d0,d2
		bra.b	.tre_set
.tre_rampdown2	move.b	d0,d2
		bra.b	.tre_set
.tre_sine	move.b	(a0,d0.w),d2
.tre_set	move.b	ch_PTTreCmd(a4),d0
		and	#15,d0
		mulu	d0,d2
		lsr	#2,d2
		tst.b	ch_PTTrePos(a4)
		bpl.b	.positive
		bra.b	.negative
.positive	tst	d2
		bpl.b	.ok
		neg	d2
		bra.b	.ok
.negative	tst	d2
		bmi.b	.ok
		neg	d2
.ok		move	ch_Volume1(a4),d4
		beq.b	.notre
		add	d2,d4
		bpl.b	.ok1
		moveq	#0,d4
.ok1		cmp	#64*16,d4
		ble.b	.notre
		move	#64*16,d4
.notre		move	d4,ch_Volume2(a4)
		move	d4,ch_Volume3(a4)
		move.b	ch_PTTreCmd(a4),d0
		lsr	#2,d0
		and	#$003c,d0
		add.b	d0,ch_PTTrePos(a4)
.exit		rts

VibratoPlay	cmp.b	#fx_PTVibrato,ch_Vib(a4)
		beq	PTVibratoPlay
		tst.b	ch_Vib(a4)
		bne.b	.go
		btst	#VIBRATO,ch_Effects1(a4)
		beq.b	.exit
		tst	ch_VibCmdDelay(a4)
		beq.b	.go
		subq	#1,ch_VibCmdDelay(a4)
		rts

.go		tst	ch_VibAtkLength(a4)
		bne.b	.attack
		move	ch_VibDepth(a4),ch_VibCmdDepth(a4)
		bra.b	.vibba

.attack		move	ch_VibAtkSpeed(a4),d0
		add	d0,ch_VibCmdDepth(a4)
		subq	#1,ch_VibAtkLength(a4)
		bne.b	.vibba
		move	ch_VibDepth(a4),ch_VibCmdDepth(a4)

.vibba		move	ch_VibCount(a4),d0
		move	ch_VibCmdSpeed(a4),d1
		move	ch_VibCmdDepth(a4),d2
		lsr	#8,d2
		moveq	#0,d3
		move.b	ch_VibWaveNum(a4),d3
		lsl	#7,d3
		lea	Sine,a0
		add	d3,a0
		lsr	#2,d0
		move.b	(a0,d0.w),d3
		ext	d3
		tst.b	ch_VibDir(a4)
		bne.b	.oki
		neg	d3
.oki		muls	d2,d3
		asr.l	#4,d3
		bpl.b	.plus1
		addq	#1,d3
.plus1		move	d3,ch_VibNote(a4)
		move	ch_VibCount(a4),d0
		add	d1,d0
		and	#$1ff,d0
		move	d0,ch_VibCount(a4)
.exit		rts

PTVibratoPlay	btst	#1,ch_Play(a4)
		bne.b	.exit
		move.b	ch_PTVibPos(a4),d0
		lea	PTVibratoTable(pc),a0
		lsr	#2,d0
		and	#$001f,d0
		moveq	#0,d2
		move.b	ch_PTVibWave(a4),d2
		and.b	#$03,d2
		beq.b	.vib_sine
		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.b	.vib_rampdown
		move.b	#255,d2
		bra.b	.vib_set
.vib_rampdown	tst.b	ch_PTVibPos(a4)
		bpl.b	.vib_rampdown2
		move.b	#255,d2
		sub.b	d0,d2
		bra.b	.vib_set
.vib_rampdown2	move.b	d0,d2
		bra.b	.vib_set
.vib_sine	move.b	(a0,d0.w),d2
.vib_set	move.b	ch_PTVibCmd(a4),d0
		and	#15,d0
		mulu	d0,d2
		lsr	#7,d2
		tst.b	ch_PTVibPos(a4)
		bpl.b	.positive
		bra.b	.negative
.positive	tst	d2
		bpl.b	.ok
		neg	d2
		bra.b	.ok
.negative	tst	d2
		bmi.b	.ok
		neg	d2
.ok		move	d2,ch_PTVibNote(a4)
		move.b	ch_PTVibCmd(a4),d0
		lsr	#2,d0
		and	#$003c,d0
		add.b	d0,ch_PTVibPos(a4)
.exit		rts

PTVibratoTable	dc.b	000,024,049,074,097,120,141,161
		dc.b	180,197,212,224,235,244,250,253
		dc.b	255,253,250,244,235,224,212,197
		dc.b	180,161,141,120,097,074,049,024

PhasePlay	btst	#PHASE,ch_Effects2(a4)
		beq	PhaseExit
		lea	ch_PhaData(a4),a0
		move	ch_WsRepLength(a4),d6
		add	d6,d6
		btst	#PHASESTEP,ch_EffectsPar1(a4)
		beq.b	.count
		btst	#PHASEINIT,ch_EffectsPar1(a4)
		bne.b	.initstep
		tst.b	ch_PartNote(a4)
		beq.b	.nocount
		bra.b	.count
.initstep	tst.b	ch_PartNote(a4)
		beq.b	.counter
.count		move	cnt_counter(a0),cnt_savecounter(a0)
.counter	bsr	Counter
.nocount	move	cnt_savecounter(a0),d0
		btst	#PHASESTEP,ch_EffectsPar1(a4)
		beq.b	.nostep
		tst	cnt_delay(a0)
		beq.b	.okstep
		subq	#1,cnt_delay(a0)
		bra.b	.nostep
.okstep		move.b	ch_PhaSpd+1(a4),d1
		ext	d1
		bmi.b	.right
.left		sub	d1,cnt_savecounter(a0)
		cmp	#2,cnt_savecounter(a0)
		bge.b	.nostep
		move	#2,cnt_savecounter(a0)
		bra.b	.nostep
.right		sub	d1,cnt_savecounter(a0)
		cmp	#512,cnt_savecounter(a0)
		ble.b	.nostep
		move	#512,cnt_savecounter(a0)

.nostep		cmp	#128,d6
		ble.b	.next1
		addq	#1,d0
		lsr	#1,d0
		lea	SizerTable256,a3
		lea	SizerOffset256,a0
		bra.b	.ok
.next1		cmp	#64,d6
		ble.b	.next2
		addq	#3,d0
		lsr	#2,d0
		lea	SizerTable128,a3
		lea	SizerOffset128,a0
		bra.b	.ok
.next2		cmp	#32,d6
		ble.b	.next3
		addq	#7,d0
		lsr	#3,d0
		lea	SizerTable64,a3
		lea	SizerOffset64,a0
		bra.b	.ok
.next3		cmp	#16,d6
		ble.b	.next4
		add	#15,d0
		lsr	#4,d0
		lea	SizerTable32,a3
		lea	SizerOffset32,a0
		bra.b	.ok
.next4		add	#31,d0
		lsr	#5,d0
		lea	SizerTable16,a3
		lea	SizerOffset16,a0

.ok		move.l	ch_WsRepPointer(a4),a1
		lea	ch_PhaWaveBuffer(a4),a2
		move.l	a2,ch_WsRepPointer(a4)
		btst	#LOOP,ch_Effects1(a4)
		bne.b	.yes
		tst.b	ch_WaveOrSample(a4)
		beq.b	.nest
.yes		move.l	a2,ch_WsPointer(a4)

.nest		btst	#1,_PlayBits(a5)
		bne	PhaseExit
		move	d6,d7
		cmp	d6,d0
		bge	Phase_Mova
		move	d0,d7
		beq	Phase_Mova
		subq	#1,d7
		move	d7,d5
		move	d6,d1
		sub	d0,d1

		moveq	#0,d2
		subq	#1,d0
		add	d0,d0
		move	(a0,d0.w),d2
		add.l	d2,a3
		cmp.b	#3,ch_PhaType(a4)
		beq	Phase_Low
		cmp.b	#1,ch_PhaType(a4)
		beq.b	Phase_High
		cmp.b	#2,ch_PhaType(a4)
		beq	Phase_Med

Phase_Quick	move.l	a2,d4
		moveq	#0,d0
.loop1		move.b	(a3)+,d0
		move.b	(a1,d0.w),(a2)+
		dbf	d7,.loop1

		btst	#PHASEFILL,ch_EffectsPar1(a4)
		bne.b	.fill

		subq	#1,d1
		bmi.b	.end
		move.b	(a1,d0.w),d0
.loop2		move.b	d0,(a2)+
		dbf	d1,.loop2
.end		rts

.fill		subq	#1,d1
		bmi.b	.fillend
		move.l	d4,a1
.fillloop	move.b	(a1)+,(a2)+
		dbf	d1,.fillloop
.fillend	rts

Phase_High	move.l	a3,d6
		move.l	a1,a0
		moveq	#0,d0
.loop1		move.b	(a3)+,d0
		move.b	(a1,d0.w),d2
		ext	d2
		move.b	(a0)+,d3
		ext	d3
		add	d2,d3
		add	d2,d2
		add	d2,d3
		asr	#2,d3
		move.b	d3,(a2)+
		dbf	d7,.loop1

		btst	#PHASEFILL,ch_EffectsPar1(a4)
		bne.b	.fill

		subq	#1,d1
		bmi.b	.end
		move.b	(a1,d0.w),d0
		ext	d0
		move	d0,d2
		add	d2,d2
		add	d2,d0
.loop2		move.b	(a0)+,d2
		ext	d2
		add	d0,d2
		asr	#2,d2
		move.b	d2,(a2)+
		dbf	d1,.loop2
.end		rts

.fill		tst	d1
		beq.b	.fillend
		move.l	d6,a3
.fillagain	move	d5,d7
		moveq	#0,d3
.fillloop	move.b	(a3)+,d3
		move.b	(a1,d3.w),d0
		ext	d0
		move.b	(a0)+,d2
		ext	d2
		add	d0,d2
		add	d0,d0
		add	d0,d2
		asr	#2,d2
		move.b	d2,(a2)+
		subq	#1,d1
		dbeq	d7,.fillloop
		bne.b	.fillagain
.fillend	rts

Phase_Med	move.l	a3,d6
		move.l	a1,a0
		moveq	#0,d0
.loop1		move.b	(a3)+,d0
		move.b	(a1,d0.w),d2
		ext	d2
		move.b	(a0)+,d3
		ext	d3
		add	d2,d3
		asr	#1,d3
		move.b	d3,(a2)+
		dbf	d7,.loop1

		btst	#PHASEFILL,ch_EffectsPar1(a4)
		bne.b	.fill

		subq	#1,d1
		bmi.b	.end
		move.b	(a1,d0.w),d0
		ext	d0
.loop2		move.b	(a0)+,d2
		ext	d2
		add	d0,d2
		asr	#1,d2
		move.b	d2,(a2)+
		dbf	d1,.loop2
.end		rts

.fill		tst	d1
		beq.b	.fillend
		moveq	#0,d3
.fillagain	move.l	d6,a3
		move	d5,d7
.fillloop	move.b	(a3)+,d3
		move.b	(a1,d3.w),d0
		ext	d0
		move.b	(a0)+,d2
		ext	d2
		add	d0,d2
		asr	#1,d2
		move.b	d2,(a2)+
		subq	#1,d1
		dbeq	d7,.fillloop
		bne.b	.fillagain
.fillend	rts

Phase_Low	move.l	a3,d6
		move.l	a1,a0
		moveq	#0,d0
.loop1		move.b	(a3)+,d0
		move.b	(a1,d0.w),d2
		ext	d2
		move.b	(a0)+,d3
		ext	d3
		add	d3,d2
		add	d3,d3
		add	d3,d2
		asr	#2,d2
		move.b	d2,(a2)+
		dbf	d7,.loop1

		btst	#PHASEFILL,ch_EffectsPar1(a4)
		bne.b	.fill

		subq	#1,d1
		bmi.b	.end
		move.b	(a1,d0.w),d0
		ext	d0
.loop2		move.b	(a0)+,d2
		ext	d2
		move	d2,d3
		add	d3,d3
		add	d3,d2
		add	d0,d2
		asr	#2,d2
		move.b	d2,(a2)+
		dbf	d1,.loop2
.end		rts

.fill		tst	d1
		beq.b	.fillend
		move.l	d6,a3
.fillagain	move	d5,d7
		moveq	#0,d3
.fillloop	move.b	(a3)+,d3
		move.b	(a1,d3.w),d0
		ext	d0
		move.b	(a0)+,d2
		ext	d2
		add	d2,d0
		add	d2,d2
		add	d0,d2
		asr	#2,d2
		move.b	d2,(a2)+
		subq	#1,d1
		dbeq	d7,.fillloop
		bne.b	.fillagain
.fillend	rts

Phase_Mova	subq	#1,d6
.mloop		move.b	(a1)+,(a2)+
		dbf	d6,.mloop
PhaseExit	rts

MixPlay		btst	#MIX,ch_Effects2(a4)
		beq	.exit
		lea	ch_MixData(a4),a0
		move	ch_WsRepLength(a4),d7
		add	d7,d7
		btst	#MIXSTEP,ch_EffectsPar2(a4)
		beq.b	.count
		btst	#MIXINIT,ch_EffectsPar2(a4)
		bne.b	.initstep
		tst.b	ch_PartNote(a4)
		beq.b	.nocount
		bra.b	.count
.initstep	tst.b	ch_PartNote(a4)
		beq.b	.counter
.count		move	cnt_counter(a0),cnt_savecounter(a0)
.counter	btst	#MIXCOUNTER,ch_EffectsPar2(a4)
		beq.b	.twoway
.oneway		pea	.nocount
		bra	OneWayCounter
.twoway		bsr	Counter
.nocount	move	cnt_savecounter(a0),d0
		btst	#MIXSTEP,ch_EffectsPar2(a4)
		beq.b	.nostep
		tst	cnt_delay(a0)
		beq.b	.okstep
		subq	#1,cnt_delay(a0)
		bra.b	.nostep
.okstep		move.b	ch_MixSpd+1(a4),d1
		ext	d1
		bpl.b	.right
.left		add	d1,cnt_savecounter(a0)
		bge.b	.nostep
		clr	cnt_savecounter(a0)
		bra.b	.nostep
.right		add	d1,cnt_savecounter(a0)
		cmp	#510,cnt_savecounter(a0)
		ble.b	.nostep
		move	#510,cnt_savecounter(a0)
.nostep		cmp	#128,d7
		ble.b	.next1
		lsr	#1,d0
		moveq	#0,d4
		bra.b	.ok
.next1		cmp	#64,d7
		ble.b	.next2
		lsr	#2,d0
		move.l	#256,d4
		bra.b	.ok
.next2		cmp	#32,d7
		ble.b	.next3
		lsr	#3,d0
		move.l	#256+128,d4
		bra.b	.ok
.next3		cmp	#16,d7
		ble.b	.next4
		lsr	#4,d0
		move.l	#256+128+64,d4
		bra.b	.ok
.next4		lsr	#5,d0
		move.l	#256+128+64+32,d4

.ok		move.l	ch_WsRepPointer(a4),a0
		lea	ch_MixWaveBuffer(a4),a1
		btst	#MIXBUFF,ch_EffectsPar2(a4)
		bne.b	.skipnormal
		move.l	a0,a1
		moveq	#0,d1
		move.b	ch_MixWaveNum(a4),d1
		beq.b	.skipnormal
		add	d1,d1
		add	d1,d1
		move.l	SmplList(pc),a1
		move.l	(a1,d1.w),a1
		move.l	smpl_RepPointer(a1),a1
		add.l	d4,a1
.skipnormal	move.l	a1,a3
		lea	ch_MixWaveBuffer(a4),a2
		move.l	a2,ch_WsRepPointer(a4)
		tst.b	ch_WaveOrSample(a4)
		beq.b	.nest
		move.l	a2,ch_WsPointer(a4)

.nest		btst	#1,_PlayBits(a5)
		bne.b	.exit
		add	d0,a1
		sub	d0,d7
		subq	#1,d7
		moveq	#1,d4
		btst	#2,ch_MixResFilBoost(a4)
		beq.b	.skip
		moveq	#0,d4
.skip		bsr.b	.loop

		move	d0,d7
		beq.b	.exit
		subq	#1,d7
		move.l	a3,a1

.loop		move.b	(a0)+,d2
		ext	d2
		move.b	(a1)+,d1
		ext	d1
		add	d1,d2
		asr	d4,d2
		move.b	d2,(a2)+
		dbf	d7,.loop
.exit		rts

ResonancePlay	btst	#RESONANCE,ch_Effects2(a4)
		beq	.exit
		lea	ch_ResData(a4),a0
		btst	#RESONANCESTEP,ch_EffectsPar2(a4)
		beq.b	.count
		btst	#RESONANCEINIT,ch_EffectsPar2(a4)
		bne.b	.initstep
		tst.b	ch_PartNote(a4)
		beq.b	.nocount
		bra.b	.count
.initstep	tst.b	ch_PartNote(a4)
		beq.b	.counter
.count		move	cnt_counter(a0),cnt_savecounter(a0)
.counter	bsr	Counter
.nocount	move	cnt_savecounter(a0),d0
		btst	#RESONANCESTEP,ch_EffectsPar2(a4)
		beq.b	.nostep
		tst	cnt_delay(a0)
		beq.b	.okstep
		subq	#1,cnt_delay(a0)
		bra.b	.nostep
.okstep		move.b	ch_ResSpd+1(a4),d1
		ext	d1
		bpl.b	.right
.left		add	d1,cnt_savecounter(a0)
		bge.b	.nostep
		clr	cnt_savecounter(a0)
		bra.b	.nostep
.right		add	d1,cnt_savecounter(a0)
		cmp	#510,cnt_savecounter(a0)
		ble.b	.nostep
		move	#510,cnt_savecounter(a0)

.nostep		move.l	ch_WsRepPointer(a4),a0
		lea	ch_ResWaveBuffer(a4),a1
		move.l	a1,ch_WsRepPointer(a4)
		btst	#LOOP,ch_Effects1(a4)
		bne.b	.yes
		tst.b	ch_WaveOrSample(a4)
		beq.b	.nest
.yes		move.l	a1,ch_WsPointer(a4)

.nest		btst	#1,_PlayBits(a5)
		bne.b	.exit
		move	ch_WsRepLength(a4),d7
		add	d7,d7
		subq	#1,d7

		move.b	ch_ResLastSample(a4),d4
		tst.b	ch_ResLastInit(a4)
		beq.b	.skip
		clr.b	ch_ResLastInit(a4)
		move.b	(a0,d7.w),d4
		asr.b	#2,d4
.skip		ext	d4
		asl	#7,d4

		and	#$fffe,d0		clear bit 0
		move	#$8000,d2
		moveq	#0,d3

		lea	.resonancelist(pc),a2
		move	(a2,d0.w),d5

		lea	.resamplist(pc),a2
		moveq	#0,d0
		move.b	ch_ResAmp(a4),d0
		add	d0,d0
		move	(a2,d0.w),d1
		sub	d1,d2
		mulu	#$e666,d2
		swap	d2
		moveq	#7,d0
		btst	#1,ch_MixResFilBoost(a4)
		beq.b	.loop
		moveq	#6,d0
.loop		move.b	(a0)+,d6
		ext	d6
		asl	#5,d6
		sub	d4,d6
		ext.l	d6
		asl.l	#7,d6
		divs	d5,d6
		add	d6,d3
		add	d3,d4
		move	d4,d6
		asr	d0,d6
		move.b	d6,(a1)+
		muls	d2,d3
		add.l	d3,d3
		swap	d3
		dbf	d7,.loop
		move.b	d6,ch_ResLastSample(a4)
.exit		rts

		incdir	Mline:raw/
.resonancelist	incbin	resonancelist.raw
.resamplist	incbin	resonanceamplist.raw

FilterPlay	btst	#FILTER,ch_Effects2(a4)
		beq	.exit
		lea	ch_FilData(a4),a0
		btst	#FILTERSTEP,ch_EffectsPar1(a4)
		beq.b	.count
		btst	#FILTERINIT,ch_EffectsPar1(a4)
		bne.b	.initstep
		tst.b	ch_PartNote(a4)
		beq.b	.nocount
		bra.b	.count
.initstep	tst.b	ch_PartNote(a4)
		beq.b	.counter
.count		move	cnt_counter(a0),cnt_savecounter(a0)
.counter	bsr	Counter
.nocount	move	cnt_savecounter(a0),d0
		btst	#FILTERSTEP,ch_EffectsPar1(a4)
		beq.b	.nostep
		tst	cnt_delay(a0)
		beq.b	.okstep
		subq	#1,cnt_delay(a0)
		bra.b	.nostep
.okstep		move.b	ch_FilSpd+1(a4),d1
		ext	d1
		bpl.b	.right
.left		add	d1,cnt_savecounter(a0)
		bge.b	.nostep
		clr	cnt_savecounter(a0)
		bra.b	.nostep
.right		add	d1,cnt_savecounter(a0)
		cmp	#510,cnt_savecounter(a0)
		ble.b	.nostep
		move	#510,cnt_savecounter(a0)

.nostep		move.l	ch_WsRepPointer(a4),a0
		lea	ch_FilWaveBuffer(a4),a1
		move.l	a1,ch_WsRepPointer(a4)
		btst	#LOOP,ch_Effects1(a4)
		bne.b	.yes
		tst.b	ch_WaveOrSample(a4)
		beq.b	.nest
.yes		move.l	a1,ch_WsPointer(a4)

.nest		btst	#1,_PlayBits(a5)
		bne.b	.exit
		move	ch_WsRepLength(a4),d7
		add	d7,d7
		subq	#1,d7

		move.b	ch_FilLastSample(a4),d4

		tst.b	ch_FilType(a4)
		beq.b	.filter
.resfilter	tst.b	ch_FilLastInit(a4)
		beq.b	.resskip
		clr.b	ch_FilLastInit(a4)
		move.b	(a0,d7.w),d4
		asr.b	#1,d4
.resskip	ext	d4
		asl	#7,d4
		and	#$fffe,d0		clear bit 0
		lea	.resfilterlist(pc),a2
		move	(a2,d0.w),d1
		move	#$8000,d2
		sub	d1,d2
		lsr	#1,d1
		mulu	#$e666,d2
		swap	d2
		moveq	#0,d3
		moveq	#7,d0
		btst	#0,ch_MixResFilBoost(a4)
		beq.b	.resfilloop
		moveq	#6,d0
.resfilloop	move.b	(a0)+,d6
		ext	d6
		asl	#6,d6
		sub	d4,d6
		muls	d1,d6
		add.l	d6,d6
		add.l	d6,d6
		swap	d6
		add	d6,d3
		add	d3,d4
		move	d4,d6
		asr	d0,d6
		move.b	d6,(a1)+
		muls	d2,d3
		add.l	d3,d3
		swap	d3
		dbf	d7,.resfilloop
		move.b	d6,ch_FilLastSample(a4)
.exit		rts

.filter		tst.b	ch_FilLastInit(a4)
		beq.b	.filskip
		clr.b	ch_FilLastInit(a4)
		move.b	(a0,d7.w),d4
.filskip	ext	d4
		asl	#7,d4
		and	#$fffe,d0		clear bit 0
		lea	.filterlist(pc),a2
		move	(a2,d0.w),d1
		move	#$8000,d2
		sub	d1,d2
		lsr	#1,d1
		muls	#$f000,d2
		swap	d2
		moveq	#0,d3
		moveq	#7,d0
		btst	#0,ch_MixResFilBoost(a4)
		beq.b	.filloop
		moveq	#6,d0
.filloop	move.b	(a0)+,d6
		ext	d6
		asl	#7,d6
		sub	d4,d6
		muls	d1,d6
		add.l	d6,d6
		add.l	d6,d6
		swap	d6
		add	d6,d3
		add	d3,d4
		move	d4,d6
		asr	d0,d6
		move.b	d6,(a1)+
		muls	d2,d3
		add.l	d3,d3
		swap	d3
		dbf	d7,.filloop
		move.b	d6,ch_FilLastSample(a4)
		rts

		incdir	Mline:raw/
.filterlist	incbin	filterlist.raw
.resfilterlist	incbin	resfilterlist.raw

TransformPlay	btst	#TRANSFORM,ch_Effects2(a4)
		beq	TraExit
		lea	ch_TraData(a4),a0
		move	ch_WsRepLength(a4),d6
		moveq	#0,d4
		add	d6,d6
		cmp	#256,d6
		beq.b	.ok
		move	#256,d4
		cmp	#128,d6
		beq.b	.ok
		move	#256+128,d4
		cmp	#64,d6
		beq.b	.ok
		move	#256+128+64,d4
		cmp	#32,d6
		beq.b	.ok
		move	#256+128+64+32,d4

.ok		btst	#TRANSFORMSTEP,ch_EffectsPar1(a4)
		beq.b	.count
		btst	#TRANSFORMINIT,ch_EffectsPar1(a4)
		bne.b	.initstep
		tst.b	ch_PartNote(a4)
		beq.b	.nocount
		bra.b	.count
.initstep	tst.b	ch_PartNote(a4)
		beq.b	.counter
.count		move	cnt_counter(a0),cnt_savecounter(a0)
.counter	bsr	Counter
.nocount	move	cnt_savecounter(a0),d0
		btst	#TRANSFORMSTEP,ch_EffectsPar1(a4)
		beq.b	.nostep
		tst	cnt_delay(a0)
		beq.b	.okstep
		subq	#1,cnt_delay(a0)
		bra.b	.nostep
.okstep		move.b	ch_TraSpd+1(a4),d1
		ext	d1
		bpl.b	.right
.left		add	d1,cnt_savecounter(a0)
		bge.b	.nostep
		clr	cnt_savecounter(a0)
		bra.b	.nostep
.right		add	d1,cnt_savecounter(a0)
		cmp	#510,cnt_savecounter(a0)
		ble.b	.nostep
		move	#510,cnt_savecounter(a0)

.nostep		lsr	#1,d0
		move	#256,d1
		bsr.b	SelectTraWave
		moveq	#0,d1
		lea	ch_TraWsPtrs(a4),a3
		add	d3,a3
		move.b	(a3)+,d1
		beq.b	TraExit
		add	d1,d1
		add	d1,d1
		move.l	SmplList(pc),a2
		move.l	(a2,d1.w),a1
		move.l	smpl_RepPointer(a1),a1
		add	d4,a1
		tst	d3
		bne.b	.skip
		move.l	ch_WsRepPointer(a4),a1
.skip		moveq	#0,d1
		move.b	(a3)+,d1
		beq.b	TraExit
		add	d1,d1
		add	d1,d1
		move.l	(a2,d1.w),a0
		move.l	smpl_RepPointer(a0),a0
		add	d4,a0
		lea	ch_TraWaveBuffer(a4),a2
		move.l	a2,ch_WsRepPointer(a4)
		btst	#LOOP,ch_Effects1(a4)
		bne.b	.yes
		tst.b	ch_WaveOrSample(a4)
		beq.b	.next
.yes		move.l	a2,ch_WsPointer(a4)
.next		btst	#1,_PlayBits(a5)
		bne.b	TraExit
		subq	#1,d6
Trans_Loop	move.b	(a1)+,d1
		ext	d1
		move.b	(a0)+,d2
		ext	d2
		sub	d1,d2
		muls	d0,d2
		asr	#8,d2
		add	d2,d1
		move.b	d1,(a2)+
		dbf	d6,Trans_Loop
TraExit		rts

SelectTraWave	move	d0,d2
		moveq	#0,d3
		sub	d1,d2
		ble.b	.ok
		addq	#1,d3
		move	d2,d0
		sub	d1,d2
		ble.b	.ok
		addq	#1,d3
		move	d2,d0
		sub	d1,d2
		ble.b	.ok
		addq	#1,d3
		move	d2,d0
		sub	d1,d2
		ble.b	.ok
		addq	#1,d3
		move	d2,d0
		sub	d1,d2
		ble.b	.ok
		addq	#1,d3
		move	d2,d0
.ok		rts

;Counter Structure
cht_begin	rs.b	0
		rsreset
cnt_counter	rs.w	1
cnt_speed	rs.w	1
cnt_repeat	rs.w	1
cnt_repeatend	rs.w	1
cnt_turns	rs.w	1
cnt_delay	rs.w	1
cnt_step	rs.w	1
cnt_savecounter	rs.w	1
		rsset	cht_begin

OneWayCounter	move	cnt_counter(a0),d0
		tst	cnt_step(a0)
		bne.b	.cnt_go
		tst	cnt_delay(a0)
		beq.b	.cnt_go
		subq	#1,cnt_delay(a0)
		rts
.cnt_go		add	cnt_speed(a0),d0
		and	#$1ff,d0
		move	d0,cnt_counter(a0)
		rts

Counter		move	cnt_counter(a0),d0
		tst	cnt_step(a0)
		bne.b	.cnt_go
		tst	cnt_delay(a0)
		beq.b	.cnt_go
		subq	#1,cnt_delay(a0)
		rts
.cnt_go		tst	cnt_turns(a0)
		bmi.b	.cnt_exit
		move	cnt_repeat(a0),d1
		cmp	cnt_repeatend(a0),d1
		blo.b	.cnt_normal
		bra.b	.cnt_inverted
.cnt_notok	tst	cnt_turns(a0)
		beq.b	.cnt_turn
		subq	#1,cnt_turns(a0)
		bne.b	.cnt_turn
		move	#-1,cnt_turns(a0)
.cnt_turn	sub	cnt_speed(a0),d0
		neg	cnt_speed(a0)
.cnt_ok		move	d0,cnt_counter(a0)
.cnt_exit	rts

.cnt_normal	tst	cnt_speed(a0)
		bpl.b	.cnt_nadd
.cnt_nsub	add	cnt_speed(a0),d0
		cmp	cnt_repeat(a0),d0
		bge.b	.cnt_ok
		bra.b	.cnt_notok
.cnt_nadd	add	cnt_speed(a0),d0
		cmp	cnt_repeatend(a0),d0
		ble.b	.cnt_ok
		bra.b	.cnt_notok

.cnt_inverted	tst	cnt_speed(a0)
		bpl.b	.cnt_iadd
.cnt_isub	add	cnt_speed(a0),d0
		cmp	cnt_repeatend(a0),d0
		bge.b	.cnt_ok
		bra.b	.cnt_notok
.cnt_iadd	add	cnt_speed(a0),d0
		cmp	cnt_repeat(a0),d0
		ble.b	.cnt_ok
		bra.b	.cnt_notok

* Twins/PHA *****************************************************************
* Init pointers to parts                              Last Change: 92-10-24 *
*****************************************************************************

StartTimerInt	move	#$0080,$dff09a
		move	#$0080,$dff09c
		move.l	_TimerValue1(a5),d4
		move.l	TunePtr(pc),a0
		move	tune_Tempo(a0),_TuneTmp(a5)
		divu	_TuneTmp(a5),d4
		lea	$bfd000,a4
		move.b	d4,ciatalo(a4)
		lsr	#8,d4
		move.b	d4,ciatahi(a4)
		bset	#CIACRAB_START,ciacra(a4)
		move	#1,_IntMode(a5)
		rts

StartAudioInt	move	#2,_IntMode(a5)
		move.l	TunePtr(pc),a0
		move	tune_Tempo(a0),_TuneTmp(a5)
		jsr	SetAudInt
		clr	_DoubleBuf(a5)
		move	#126,d0
		move	d0,_MixPeriod(a5)
		move	d0,d1
		mulu	#32768,d1
		move.l	d1,_PeriodValue(a5)
		move.l	_TimerValue2(a5),d1
		divu	d0,d1
		mulu	#125,d1
		move	_TuneTmp(a5),d2
		mulu	#50,d2
		divu	d2,d1
		bclr	#0,d1
		move	d1,_MixLength(a5)
		lsr	#1,d1
		move.l	_SndCBuf(a5),a0
		move.l	a0,$dff0a0
		move	d1,$dff0a4
		move	d0,$dff0a6
		add	#(2*SndBufSize),a0
		move.l	a0,$dff0b0
		move	d1,$dff0b4
		move	d0,$dff0b6
		add	#(2*SndBufSize),a0
		move.l	a0,$dff0c0
		move	d1,$dff0c4
		move	d0,$dff0c6
		add	#(2*SndBufSize),a0
		move.l	a0,$dff0d0
		move	d1,$dff0d4
		move	d0,$dff0d6
		bclr	#CIACRAB_START,ciacra(a4)
		move	#2,_IntMode(a5)
		jsr	Dma6
		rts

* Twins/PHA *****************************************************************
* Play tune                                           Last Change: 92-10-24 *
*****************************************************************************

_TunePos	rs.b	1
_PlayBits	rs.b	1
_Ch1Volume	rs.w	1
_Ch2Volume	rs.w	1
_Ch3Volume	rs.w	1
_Ch4Volume	rs.w	1
_DmaSave	rs.w	1
_PlayTune	rs.b	1
_PlayPart	rs.b	1

InitPlay	lea	Bss,a5
		move.b	#$ff,_ChannelsOn(a5)
		move.b	#2,_PlayBits(a5)

GetTune		move.l	TuneList(pc),a0
		move	Tune(pc),d0
		lsl	#2,d0
		move.l	(a0,d0.w),a0
		lea	TunePtr(pc),a1
		move.l	a0,(a1)

		move	tune_Tempo(a0),_TuneTmp(a5)

		moveq	#0,d0
		lea	Channel1Buf,a4
		bsr.b	.initchannel
		moveq	#1,d0
		lea	Channel2Buf,a4
		bsr.b	.initchannel
		moveq	#2,d0
		lea	Channel3Buf,a4
		bsr.b	.initchannel
		moveq	#3,d0
		lea	Channel4Buf,a4
		bsr.b	.initchannel
		tst.b	_PlayMode(a5)
		beq.b	.initplay
		moveq	#4,d0
		lea	Channel5Buf,a4
		bsr.b	.initchannel
		moveq	#5,d0
		lea	Channel6Buf,a4
		bsr.b	.initchannel
		moveq	#6,d0
		lea	Channel7Buf,a4
		bsr.b	.initchannel
		moveq	#7,d0
		lea	Channel8Buf,a4
		bsr.b	.initchannel
		bra.b	.initplay

.initchannel	btst	d0,_ChannelsOn(a5)
		seq.b	ch_ChannelOff(a4)
		move	#64*16,ch_CVolume(a4)
		move.b	tune_Speed(a0),_TuneSpd(a5)
		move.b	_TuneSpd(a5),ch_Spd(a4)
		move.b	tune_Groove(a0),_TuneGrv(a5)
		move.b	_TuneGrv(a5),ch_Grv(a4)
		beq.b	.skip
		not.b	ch_PartGrv(a4)
.skip		move.b	#1,ch_SpdCnt(a4)
		move	#-1,ch_PchSldToNote(a4)
		rts

.initplay	clr.b	_TunePos(a5)
		clr	_DmaSave(a5)
		tst.b	_PlayMode(a5)
		bne.b	.play8ch

.play4ch	clr	_Ch1Volume(a5)
		clr	_Ch2Volume(a5)
		clr	_Ch3Volume(a5)
		clr	_Ch4Volume(a5)
		bra	.loop

.play8ch	move	#64,_Ch1Volume(a5)
		move	#64,_Ch2Volume(a5)
		move	#64,_Ch3Volume(a5)
		move	#64,_Ch4Volume(a5)

		move.l	TunePtr(pc),a0
		move	tune_Tempo(a0),_TuneTmp(a5)
		clr	_DoubleBuf(a5)
		move	#126,d0
		move	d0,_MixPeriod(a5)
		move	d0,d1
		mulu	#32768,d1
		move.l	d1,_PeriodValue(a5)
		move.l	_TimerValue2(a5),d1
		divu	d0,d1
		mulu	#125,d1
		move	_TuneTmp(a5),d2
		mulu	#50,d2
		divu	d2,d1
		bclr	#0,d1
		move	d1,_MixLength(a5)
		lsr	#1,d1
		move.l	_SndCBuf(a5),a0
		move.l	a0,$dff0a0
		move	d1,$dff0a4
		move	d0,$dff0a6
		add	#(2*SndBufSize),a0
		move.l	a0,$dff0b0
		move	d1,$dff0b4
		move	d0,$dff0b6
		add	#(2*SndBufSize),a0
		move.l	a0,$dff0c0
		move	d1,$dff0c4
		move	d0,$dff0c6
		add	#(2*SndBufSize),a0
		move.l	a0,$dff0d0
		move	d1,$dff0d4
		move	d0,$dff0d6

		bra.b	.loop

.error		bsr	StopPlay
		clr	_DmaSave(a5)
.exit		clr.b	_PlayBits(a5)
.x		rts

.loop		btst	#0,_PlayBits(a5)
		bne.b	.error
		jsr	PlayTune
		lea	ChnlPtrs(pc),a0
		move	_Voice(a5),d0
		lsl	#2,d0
		move.l	(a0,d0.w),a4
		btst	#0,ch_PlayError(a4)
		bne	.error
		btst	#1,ch_PlayError(a4)
		bne.b	.x

		tst.b	_PlayPosMode(a5)
		bne.b	.fast
		jsr	PlayEffects
		jsr	PerCalc
		bsr	PlayPerVol2
		bsr	PlayDma2
		bra	.loop

.fast		lea	Channel1Buf,a4
		and.b	#$c0,ch_Play(a4)
		clr.b	ch_PartNote(a4)
		clr.b	ch_ArpWait(a4)
		lea	Channel2Buf,a4
		and.b	#$c0,ch_Play(a4)
		clr.b	ch_PartNote(a4)
		clr.b	ch_ArpWait(a4)
		lea	Channel3Buf,a4
		and.b	#$c0,ch_Play(a4)
		clr.b	ch_PartNote(a4)
		clr.b	ch_ArpWait(a4)
		lea	Channel4Buf,a4
		and.b	#$c0,ch_Play(a4)
		clr.b	ch_PartNote(a4)
		clr.b	ch_ArpWait(a4)
		lea	Channel5Buf,a4
		and.b	#$c0,ch_Play(a4)
		clr.b	ch_PartNote(a4)
		clr.b	ch_ArpWait(a4)
		lea	Channel6Buf,a4
		and.b	#$c0,ch_Play(a4)
		clr.b	ch_PartNote(a4)
		clr.b	ch_ArpWait(a4)
		lea	Channel7Buf,a4
		and.b	#$c0,ch_Play(a4)
		clr.b	ch_PartNote(a4)
		clr.b	ch_ArpWait(a4)
		lea	Channel8Buf,a4
		and.b	#$c0,ch_Play(a4)
		clr.b	ch_PartNote(a4)
		clr.b	ch_ArpWait(a4)
		bra	.loop
.ReplyMessage1	rts

PlayPerVol2	tst.b	_PlayMode(a5)
		beq.b	.play4ch
		eor	#2560,_DoubleBuf(a5)
		lea	$dff000,a6
		jsr	Dma4
		jmp	Play8PerVol
.play4ch	lea	_Ch1Volume(a5),a0
		lea	Channel1Buf,a4
		bsr.b	.pervolplay
		lea	_Ch2Volume(a5),a0
		lea	Channel2Buf,a4
		bsr.b	.pervolplay
		lea	_Ch3Volume(a5),a0
		lea	Channel3Buf,a4
		bsr.b	.pervolplay
		lea	_Ch4Volume(a5),a0
		lea	Channel4Buf,a4

.pervolplay	btst	#0,ch_Play(a4)
		bne.b	.nopervol
		move.l	ch_CustomAddress(a4),a6
		move	ch_Period2(a4),6(a6)
.noper		tst.b	ch_ChannelOff(a4)
		bne.b	.nopervol
		move	ch_Volume3(a4),d1
.channelvol	mulu	ch_CVolume(a4),d1
		lsl.l	#6,d1
		swap	d1
.mastervol	mulu	_MasterVol(a5),d1
.voldone	lsl.l	#2,d1
		swap	d1
		move	d1,(a0)
.nopervol	rts

PlayDma2	tst.b	_PlayMode(a5)
		beq.b	.p4ch
		jmp	Play8channels
.p4ch		moveq	#0,d0
		lea	$dff000,a6
		lea	Channel1Buf,a4
		bclr	#0,ch_Play(a4)
		beq.b	.noplay1
		or	#1,d0
		tst.b	ch_ChannelOff(a4)
		bne.b	.novol1
		move	ch_Volume3(a4),d1
.channelvol	mulu	ch_CVolume(a4),d1
		lsl.l	#6,d1
		swap	d1
.mastervol	mulu	_MasterVol(a5),d1
.voldone	lsl.l	#2,d1
		swap	d1
		move	d1,_Ch1Volume(a5)
.novol1		move.l	ch_WsPointer(a4),$a0(a6)
		move	ch_WsLength(a4),$a4(a6)
		move	ch_Period2(a4),$a6(a6)
.noplay1	lea	Channel2Buf,a4
		bclr	#0,ch_Play(a4)
		beq.b	.noplay2
		or	#2,d0
		tst.b	ch_ChannelOff(a4)
		bne.b	.novol2
		move	ch_Volume3(a4),d1
.channelvol2	mulu	ch_CVolume(a4),d1
		lsl.l	#6,d1
		swap	d1
.mastervol2	mulu	_MasterVol(a5),d1
.voldone2	lsl.l	#2,d1
		swap	d1
		move	d1,_Ch2Volume(a5)
.novol2		move.l	ch_WsPointer(a4),$b0(a6)
		move	ch_WsLength(a4),$b4(a6)
		move	ch_Period2(a4),$b6(a6)
.noplay2	lea	Channel3Buf,a4
		bclr	#0,ch_Play(a4)
		beq.b	.noplay3
		or	#4,d0
		tst.b	ch_ChannelOff(a4)
		bne.b	.novol3
		move	ch_Volume3(a4),d1
.channelvol3	mulu	ch_CVolume(a4),d1
		lsl.l	#6,d1
		swap	d1
.mastervol3	mulu	_MasterVol(a5),d1
.voldone3	lsl.l	#2,d1
		swap	d1
		move	d1,_Ch3Volume(a5)
.novol3		move.l	ch_WsPointer(a4),$c0(a6)
		move	ch_WsLength(a4),$c4(a6)
		move	ch_Period2(a4),$c6(a6)
.noplay3	lea	Channel4Buf,a4
		bclr	#0,ch_Play(a4)
		beq.b	.noplay4
		or	#8,d0
		tst.b	ch_ChannelOff(a4)
		bne.b	.novol4
		move	ch_Volume3(a4),d1
.channelvol4	mulu	ch_CVolume(a4),d1
		lsl.l	#6,d1
		swap	d1
.mastervol4	mulu	_MasterVol(a5),d1
.voldone4	lsl.l	#2,d1
		swap	d1
		move	d1,_Ch4Volume(a5)
.novol4		move.l	ch_WsPointer(a4),$d0(a6)
		move	ch_WsLength(a4),$d4(a6)
		move	ch_Period2(a4),$d6(a6)
.noplay4	tst.b	d0
		beq.b	.norep4
		or	d0,_DmaSave(a5)
		btst	#0,d0
		beq.b	.norep1
		lea	Channel1Buf,a4
		move.l	ch_WsRepPointer(a4),$a0(a6)
		move	ch_WsRepLength(a4),$a4(a6)
.norep1		btst	#1,d0
		beq.b	.norep2
		lea	Channel2Buf,a4
		move.l	ch_WsRepPointer(a4),$b0(a6)
		move	ch_WsRepLength(a4),$b4(a6)
.norep2		btst	#2,d0
		beq.b	.norep3
		lea	Channel3Buf,a4
		move.l	ch_WsRepPointer(a4),$c0(a6)
		move	ch_WsRepLength(a4),$c4(a6)
.norep3		btst	#3,d0
		beq.b	.norep4
		lea	Channel4Buf,a4
		move.l	ch_WsRepPointer(a4),$d0(a6)
		move	ch_WsRepLength(a4),$d4(a6)
.norep4		rts

*****************************************************************************
* Start Play                                     * Conny Cyr?us - Musicline *
*****************************************************************************

StartPlay	lea	Bss,a5
		clr.b	_PlayBits(a5)
		clr.b	_CPUPower(a5)
		move.b	#2,_PlayTune(a5)

		tst.b	_PlayMode(a5)
		bne.b	.play8ch

		lea	$bfd000,a4
		bset	#CIACRAB_START,ciacra(a4)
		move	#1,_IntMode(a5)
		move.l	_TimerValue1(a5),d4
		divu	_TuneTmp(a5),d4
		lea	$bfd000,a4
		move.b	d4,ciatalo(a4)
		lsr	#8,d4
		move.b	d4,ciatahi(a4)
		move	_DmaSave(a5),d0
		bset	#15,d0
		move	d0,$dff096
.return		rts

.play8ch	jsr	SetAudInt
		bclr	#CIACRAB_START,ciacra(a4)
		move	#2,_IntMode(a5)
		jsr	Dma6
		bra.b	.return

*****************************************************************************
* Stop Play                                      * Conny Cyr?us - Musicline *
*****************************************************************************

StopPlay	lea	Bss,a5
		move	#$000f,$dff096
		move	#$0080,$dff09a
		move	#$0080,$dff09c
		tst.l	_ClrAudInt(a5)
		beq.b	.not
		jsr	ClrAudInt
.not		clr	_PlayTune(a5)
		lea	$bfd000,a4
		bclr	#CIACRAB_START,ciacra(a4)
		clr	_IntMode(a5)

		lea	ChnlPtrs(pc),a0
		moveq	#8-1,d0
.clrloop	move.l	(a0)+,a1
		clr.b	ch_WsNumberOld(a1)
		dbf	d0,.clrloop

.exit		rts

*****************************************************************************
* Init Play                                      * Conny Cyr?us - Musicline *
*****************************************************************************

InitSound	lea	Tune(pc),a0
		move	dtg_SndNum(a5),(a0)
		move	(a0),d0
		lsl	#2,d0
		lea	TunePtr(pc),a0
		move.l	TuneList(pc),a1
		move.l	(a1,d0.w),(a0)
		lea	Bss,a5
		move.l	TunePtr(pc),a0
		move.b	tune_PlayMode(a0),_PlayMode(a5)

ClearChannels	lea	ChnlPtrs(pc),a0
		moveq	#8-1,d0
.amploop	move.l	(a0)+,a1
		move	ch_VUAmp(a1),d2
		move	ch_VUOldAmp(a1),d3
		move	#ch_SIZEOF/2-1,d1
		move.l	a1,a3
.clearloop	clr	(a3)+
		dbf	d1,.clearloop
		move	d2,ch_VUAmp(a1)
		move	d3,ch_VUOldAmp(a1)
		dbf	d0,.amploop

ClearBuffers	move.l	_SndCBuf(a5),d0
		beq.b	UpdateChStruct
		move.l	d0,a1
		move	#((4*2*SndBufSize)/32)-1,d0
.loop		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		dbf	d0,.loop
		move.l	_SndFBuf(a5),a1
		cmp.l	_SndCBuf(a5),a1
		beq.b	UpdateChStruct
		move	#((4*2*SndBufSize)/32)-1,d0
.loop2		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		dbf	d0,.loop2

UpdateChStruct	move.b	_ChannelsOn(a5),d0
		lea	Channel1Buf,a4
		move	#64*16,ch_CVolume(a4)
		move.l	#$dff0a0,ch_CustomAddress(a4)
		move	#1,ch_DmaChannel(a4)
		btst	#0,d0
		seq.b	ch_ChannelOff(a4)
		move.l	#WaveBuffer1,ch_WaveBuffer(a4)
		lea	Channel2Buf,a4
		move	#64*16,ch_CVolume(a4)
		move.l	#$dff0b0,ch_CustomAddress(a4)
		move	#2,ch_DmaChannel(a4)
		btst	#1,d0
		seq.b	ch_ChannelOff(a4)
		move.l	#WaveBuffer2,ch_WaveBuffer(a4)
		lea	Channel3Buf,a4
		move	#64*16,ch_CVolume(a4)
		move.l	#$dff0c0,ch_CustomAddress(a4)
		move	#4,ch_DmaChannel(a4)
		btst	#2,d0
		seq.b	ch_ChannelOff(a4)
		move.l	#WaveBuffer3,ch_WaveBuffer(a4)
		lea	Channel4Buf,a4
		move	#64*16,ch_CVolume(a4)
		move.l	#$dff0d0,ch_CustomAddress(a4)
		move	#8,ch_DmaChannel(a4)
		btst	#3,d0
		seq.b	ch_ChannelOff(a4)
		move.l	#WaveBuffer4,ch_WaveBuffer(a4)
		lea	Channel5Buf,a4
		move	#64*16,ch_CVolume(a4)
		move.l	#$dff0a0,ch_CustomAddress(a4)
		move	#1,ch_DmaChannel(a4)
		btst	#4,d0
		seq.b	ch_ChannelOff(a4)
		lea	Channel6Buf,a4
		move	#64*16,ch_CVolume(a4)
		move.l	#$dff0b0,ch_CustomAddress(a4)
		move	#2,ch_DmaChannel(a4)
		btst	#5,d0
		seq.b	ch_ChannelOff(a4)
		lea	Channel7Buf,a4
		move	#64*16,ch_CVolume(a4)
		move.l	#$dff0c0,ch_CustomAddress(a4)
		move	#4,ch_DmaChannel(a4)
		btst	#6,d0
		seq.b	ch_ChannelOff(a4)
		lea	Channel8Buf,a4
		move	#64*16,ch_CVolume(a4)
		move.l	#$dff0d0,ch_CustomAddress(a4)
		move	#8,ch_DmaChannel(a4)
		btst	#7,d0
		seq.b	ch_ChannelOff(a4)

		bra	InitPlay

ChnlPtrs	dc.l	Channel1Buf
		dc.l	Channel2Buf
		dc.l	Channel3Buf
		dc.l	Channel4Buf
		dc.l	Channel5Buf
		dc.l	Channel6Buf
		dc.l	Channel7Buf
		dc.l	Channel8Buf

* Twins/PHA *****************************************************************
* Edit column/vertical                                Last Change: 92-10-24 *
*****************************************************************************

_PlayMode	rs.b	1
_CPUPower	rs.b	1

* Twins/PHA *****************************************************************
* Channels on/off                                     Last Change: 92-10-24 *
*****************************************************************************

_ChannelsOn	rs.b	1
_PlayPosMode	rs.b	1

Channel1	lea	Channel1Buf,a4
		bchg	#0,_ChannelsOn(a5)
		sne.b	ch_ChannelOff(a4)
		beq.b	.ok
		tst.b	_PlayMode(a5)
		bne.b	.ok
		clr	$dff0a8
.ok		rts

Channel2	lea	Channel2Buf,a4
		bchg	#1,_ChannelsOn(a5)
		sne.b	ch_ChannelOff(a4)
		beq.b	.ok
		tst.b	_PlayMode(a5)
		bne.b	.ok
		clr	$dff0b8
.ok		rts

Channel3	lea	Channel3Buf,a4
		bchg	#2,_ChannelsOn(a5)
		sne.b	ch_ChannelOff(a4)
		beq.b	.ok
		tst.b	_PlayMode(a5)
		bne.b	.ok
		clr	$dff0c8
.ok		rts

Channel4	lea	Channel4Buf,a4
		bchg	#3,_ChannelsOn(a5)
		sne.b	ch_ChannelOff(a4)
		beq.b	.ok
		tst.b	_PlayMode(a5)
		bne.b	.ok
		clr	$dff0d8
.ok		rts

Channel5	lea	Channel5Buf,a4
		bchg	#4,_ChannelsOn(a5)
		sne.b	ch_ChannelOff(a4)
		beq.b	.ok
		tst.b	_PlayMode(a5)
		bne.b	.ok
		clr	$dff0a8
.ok		rts

Channel6	lea	Channel6Buf,a4
		bchg	#5,_ChannelsOn(a5)
		sne.b	ch_ChannelOff(a4)
		beq.b	.ok
		tst.b	_PlayMode(a5)
		bne.b	.ok
		clr	$dff0b8
.ok		rts

Channel7	lea	Channel7Buf,a4
		bchg	#6,_ChannelsOn(a5)
		sne.b	ch_ChannelOff(a4)
		beq.b	.ok
		tst.b	_PlayMode(a5)
		bne.b	.ok
		clr	$dff0c8
.ok		rts

Channel8	lea	Channel8Buf,a4
		bchg	#7,_ChannelsOn(a5)
		sne.b	ch_ChannelOff(a4)
		beq.b	.ok
		tst.b	_PlayMode(a5)
		bne.b	.ok
		clr	$dff0d8
.ok		rts

* Twins/PHA *****************************************************************
* Data                                                Last Change: 92-10-24 *
*****************************************************************************

		include		Mline:Include/EffectsMac.i

		incdir	Mline:raw/
SizerOffset256	incbin	sizeroffset.256
SizerOffset128	incbin	sizeroffset.128
SizerOffset64	incbin	sizeroffset.064
SizerOffset32	incbin	sizeroffset.032
SizerOffset16	incbin	sizeroffset.016
SizerTable256	incbin	sizertable.256
SizerTable128	incbin	sizertable.128
SizerTable64	incbin	sizertable.064
SizerTable32	incbin	sizertable.032
SizerTable16	incbin	sizertable.016
VolumeTables	incbin	volumelist.raw
Sine		incbin	mlsinus.raw
DownRamp	incbin	mldownramp.raw
SawTooth	incbin	mlsawtooth.raw
Square		incbin	mlsquare.raw
PalPitchTable	incbin	mlpalpitchtable32.raw
		cnop	0,4
HunkReloc32

*--------------------------------------------

_DmaWait1	rs.w	1
_DmaWait2	rs.w	1
_DmaWait3	rs.w	1
_DmaWait4	rs.w	1
_Voice		rs.w	1

* Data_C ********************************************************************

		Section	Data_C,Data_C

ZeroSample	dc.w	0
WaveBuffer1	dcb.b	256,0
WaveBuffer2	dcb.b	256,0
WaveBuffer3	dcb.b	256,0
WaveBuffer4	dcb.b	256,0

* Bss ***********************************************************************

		Section	Bss,Bss

Bss_Size	rs.b	0
Bss		ds.b	Bss_Size

Channel1Buf	ds.b	ch_SIZEOF
Channel2Buf	ds.b	ch_SIZEOF
Channel3Buf	ds.b	ch_SIZEOF
Channel4Buf	ds.b	ch_SIZEOF
Channel5Buf	ds.b	ch_SIZEOF
Channel6Buf	ds.b	ch_SIZEOF
Channel7Buf	ds.b	ch_SIZEOF
Channel8Buf	ds.b	ch_SIZEOF
