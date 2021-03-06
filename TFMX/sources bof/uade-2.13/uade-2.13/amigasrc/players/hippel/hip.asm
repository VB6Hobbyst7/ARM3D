????                                        ;               T

	incdir	asm:
	include	rmacros.i
	include	custom.i
	incdir	include:
	include	misc/deliplayer.i


	section	hippelplayer,code
	moveq	#-1,d0
	rts
	dc.b	'DELIRIUM'
	dc.l	table
	dc.b	'$VER: Jochen Hippel player module V0.1 '
	dc.b	'for UADE (22.12.2001)',0
	dc.b	'$COPYRIGHT: Heikki Orsila <heikki.orsila@tut.fi>',0
	dc.b	'$LICENSE: GNU LGPL',0
	even

table	dc.l	DTP_PlayerName,playername
	dc.l	DTP_Creator,creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	$80004474,2			* songend support
	dc.l	0
playername	dc.b	'Hippel',0
creator	dc.b	'Jochen Hippel player for UADE by shd',0
	even

Check2	move.l	a5,delibase
	move.l	dtg_ChkData(a5),a0
	* check file format
	bsr	checktype1
	tst.l	d0
	beq.b	checksub1
	bsr	checktype2
	tst.l	d0
	beq.b	checksub2
	bsr	checktype3
	tst.l	d0
	beq.b	checksub3
	rts
checksub1
checksub2
checksub3	bsr	checksubs
	bsr	patchmod
	tst.l	d0
	rts

checktype1	moveq	#-1,d0
	move.l	a0,a1

	bsr	gotoinitbsrfunc
	tst.l	d1
	bne.b	nottype1
	move.l	a2,intfuncptr

	cmp.l	#$48e7fffe,(a1)
	bne.b	nottype1

	cmp.b	#$61,4(a1)
	bne.b	nottype1
	moveq	#0,d1
	move.b	5(a1),d1
	bne.b	ibe1
	add	6(a1),a1	* add init bsr offset
	bra.b	ibehandled
ibe1	add	d1,a1
ibehandled	addq.l	#6,a1

	move.l	a1,initfuncptr
	cmp	#$2f00,(a1)
	bne.b	nottype1

	cmp	#$201f,6(a1)
	bne.b	type1bb
	addq.l	#4,a1
	add	(a1),a1
	bra.b	type1wb
type1bb	moveq	#0,d1
	move.b	3(a1),d1
	addq.l	#4,a1
	add.l	d1,a1
type1wb
	cmp	#$41fa,(a1)	* lea xyz(pc),a0
	bne.b	nottype1
	cmp	#$6600,6(a1)
	bne.b	notfmx
	addq	#2,a1
	add	(a1),a1
	clr	(a1)		* clear flag that prevents playing
notfmx	moveq	#0,d0
nottype1	rts

checktype2	moveq	#-1,d0
	move.l	a0,a1

	bsr	gotoinitbsrfunc
	tst.l	d1
	bne.b	nottype2
	move.l	a2,intfuncptr

	cmp.l	#$48e7fffe,(a1)	* check for push all
	bne.b	nottype2

	cmp.b	#$61,4(a1)
	bne.b	nottype2
	moveq	#0,d1
	move.b	5(a1),d1
	bne.b	ibe2
	add	6(a1),a1	* add init bsr offset
	bra.b	ibehandled2
ibe2	add	d1,a1		* add init bsr.b offset
ibehandled2	addq.l	#6,a1
	move.l	a1,initfuncptr

	cmp	#$4a40,(a1)
	bne.b	noskipt2
	cmp.b	#$67,2(a1)
	bne.b	noskipt2
	addq	#4,a1
noskipt2
	cmp	#$41fa,(a1)
	bne.b	nottype2
	addq	#2,a1
	add	(a1),a1
	cmp.l	#'COSO',(a1)
	bne.b	nottype2
	moveq	#0,d0
nottype2	rts


checktype3	moveq	#-1,d0
	move.l	a0,a1

	bsr	gotoinitbsrfunc
	tst.l	d1
	bne.b	nottype3
	move.l	a2,intfuncptr

	cmp.l	#$48e7fffe,(a1)	* check for push all
	bne.b	nottype3
	cmp	#$41fa,4(a1)
	bne.b	nottype3
	lea	6(a1),a2
	add	(a2),a2
	cmp.l	#'TFMX',(a2)
	bne.b	nottype3
	move.l	a1,initfuncptr
	moveq	#0,d0
nottype3	rts


gotoinitbsrfunc	cmp.b	#$60,(a1)
	bne.b	gotoiniterr
	cmp.b	#$60,2(a1)
	beq.b	gotoinitbsr1
	cmp	#$6000,4(a1)
	bne.b	gotoiniterr
	addq	#2,a1		* it's bra
	add	(a1),a1		* go to init bsr func
	lea	4(a0),a2
	bra.b	gotoinitbsr2
gotoinitbsr1	moveq	#0,d1		* it's bra.b
	move.b	1(a1),d1
	addq.l	#2,a1
	add	d1,a1		* go to init bsr func
	lea	2(a0),a2
gotoinitbsr2	moveq	#0,d1
	rts
gotoiniterr	moveq	#-1,d1
	rts


checksubs	push	all
	move.l	dtg_ChkData(a5),a0
	move.l	dtg_ChkSize(a5),d0
	add.l	a0,d0
	bclr	#0,d0
	move.l	d0,a1
	move.l	#'COSO',d4
	move.l	#'TFMX',d5
	moveq	#0,d2		* COSO counter
	moveq	#0,d3		* TFMX counter
csloop1	move.l	(a0),d0
	cmp.l	d0,d4		* COSO
	bne.b	notcoso
	cmp.l	$20(a0),d5	* + TFMX
	bne.b	notcoso
	addq.l	#1,d2
notcoso	cmp.l	d0,d5		* TFMX
	bne.b	nottfmx
	addq.l	#1,d3
nottfmx	addq.l	#2,a0
	cmp.l	a0,a1
	bgt.b	csloop1

	tst.l	d2
	bne.b	cosocheck
	tst.l	d3
	beq	csend
tfmxcheck
	move.l	dtg_ChkData(a5),a0
	move.l	dtg_ChkSize(a5),d0
	add.l	a0,d0
	bclr	#0,d0
	move.l	d0,a1
	moveq	#0,d7			* max subsong
cstloop1	cmp.l	(a0),d5			* TFMX
	bne.b	notcoso3

	moveq	#0,d1
	moveq	#0,d0
	move	4(a0),d0
	add	6(a0),d0
	addq	#2,d0
	lsl	#6,d0
	add.l	d0,d1

	move	8(a0),d0
	addq	#1,d0
	mulu	12(a0),d0
	add.l	d0,d1

	move	10(a0),d0
	addq	#1,d0
	mulu	#12,d0
	add.l	d0,d1

	cmp.l	dtg_ChkSize(a5),d1
	bge.b	notcoso3

	lea	$22(a0,d1.l),a2
cstloop2	tst	(a2)
	beq.b	notcoso3
	addq.l	#1,d7
	cmp.l	#64,d7			* max 64 subsongs
	bge.b	notcoso3
	addq.l	#6,a2
	bra.b	cstloop2

notcoso3	addq.l	#2,a0
	cmp.l	a0,a1
	bgt.b	cstloop1
	move.l	d7,maxsubsong
	bra.b	csend
cosocheck
	move.l	dtg_ChkData(a5),a0
	move.l	dtg_ChkSize(a5),d0
	add.l	a0,d0
	bclr	#0,d0
	move.l	d0,a1
	moveq	#0,d7			* max subsong
cscloop1	cmp.l	(a0),d4			* COSO
	bne.b	notcoso2
	cmp.l	$20(a0),d5		* TFMX
	bne.b	notcoso2

	move.l	$14(a0),d0		* sub tab offset
	beq.b	notcoso2
	lea	2(a0,d0.l),a2
cscloop2	tst	(a2)
	beq.b	notcoso2
	addq.l	#1,d7
	cmp.l	#64,d7			* max 64 subsongs
	bge.b	notcoso2
	addq.l	#6,a2
	bra.b	cscloop2

notcoso2	addq.l	#2,a0
	cmp.l	a0,a1
	bgt.b	cscloop1
	move.l	d7,maxsubsong

csend	pull	all
	rts


patchmod	push	all
	move.l	InitFuncPtr(pc),a0
	lea	$400(a0),a1
patchloop	cmp.l	#$b5cb6606,(a0)
	bne.b	next
	cmp.l	#$21450004,4(a0)
	bne.b	next
	cmp.l	#$24507200,8(a0)
	bne.b	next
	cmp.l	#$1212116a,12(a0)
	bne.b	next
	cmp.l	#$0001002c,16(a0)
	bne.b	next
	cmp.l	#$116a0002,20(a0)
	bne.b	next
	lea	songendfunc(pc),a2
	move	jsrcom(pc),4(a0)
	move.l	a2,6(a0)
	bra.b	patched
next	addq.l	#2,a0
	cmp.l	a0,a1
	bne.b	patchloop
patched	pull	all
	rts
jsrcom	jsr	0

songendfunc	move.l	d5,4(a0)		* replaced code line
	move.l	(a0),a2			* replaced code line
	push	all
	move.l	delibase,a5
	move.l	dtg_SongEnd(a5),a0
	jsr	(a0)
	pull	all
	rts

SubSongRange	moveq	#1,D0
	move.l	maxsubsong,d1
	rts

InitPlayer	push	all
	moveq	#0,d0
	move.l	dtg_GetListData(a5),a0
	jsr	(a0)
	move.l	dtg_AudioAlloc(a5),A0
	jsr	(a0)
	pull	all
	moveq	#0,d0
	rts

InitSound	push	all
	moveq	#0,d0
	move	dtg_SndNum(a5),d0
	move.l	initfuncptr,a0
	jsr	(a0)
	pull	all
	rts

Interrupt	push	all
	move.l	intfuncptr,a0
	jsr	(a0)
	pull	all
	rts

EndSound	push	all
	lea	$dff000,a2
	moveq	#0,d0
	move	d0,aud0vol(a2)
	move	d0,aud1vol(a2)
	move	d0,aud2vol(a2)
	move	d0,aud3vol(a2)
	move	#$000f,dmacon(a2)
	pull	all
	rts

EndPlayer	move.l	dtg_AudioFree(a5),A0
	jsr	(a0)
	rts

delibase	dc.l	0
initfuncptr	dc.l	0
intfuncptr	dc.l	0
maxsubsong	dc.l	0

	end
