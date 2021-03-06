;*****************************************************************
;
;	Light Speed Player v1.03
;	Fastest Amiga MOD player ever :)
;	Written By Arnaud Carr? (aka Leonard / OXYGENE)
;	https://github.com/arnaud-carre/LSPlayer
;	twitter: @leonard_coder
;
;	"small & fast" player version ( min/avg/peak = 0.25/1/2 scanline)
;	Less than 512 bytes of code!
;	You can also use generated "insane" player code for even more perf
;
;	--------How to use--------- 
;
;	bsr LSP_MusicDriver+0 : Init LSP player code
;		In:	a0: LSP music data(any memory)
;			a1: LSP sound bank(chip memory)
;			a2: DMACON 8bits byte address
;		Out:a0: music BPM pointer (16bits)
;
;	bsr LSP_MusicDriver+4 : LSP player tick (call once per frame)
;		In:	a6: should be $dff0a0
;			Used regs: d0/d1/a0/a1/a2/a3/a4
;		Out:None
;
;*****************************************************************

	opt o-		; switch off ALL optimizations (we don't want vasm to change some code size, and all optimizations are done!)

LSP_MusicDriver:
			bra.w	.LSP_PlayerInit

;.LSP_MusicDriver+4:						; player tick handle ( call this at music player rate )
			lea		.LSPVars(pc),a1
			move.l	(a1),a0					; byte stream

.process:		moveq	#0,d0
			move.b	(a0)+,d0
			bne.s	.swCode
			move.w	#$0100,d0
			move.b	(a0)+,d0
			bne.s	.swCode
			move.w	#$0200,d0
			move.b	(a0)+,d0

.swCode:		add.w	d0,d0					; valeur byte stream * 2
			move.l	m_codeTableAddr(a1),a2			; code table = 0x00C4 dans le fichier lsmusic
			move.w	0(a2,d0.w),d0				; code
			beq		.noInst				; code = 0 => no instrument, aucune action
			bpl.s	.optim					; si code > 0 => pas changement bpm ni rewind
			cmpi.w	#$ffff,d0
			beq		.r_rewind
			cmpi.w	#$f00f,d0
			beq		.r_chgbpm
.optim:
			moveq	#15,d1		; d1=0b1111
			and.w	d0,d1		; d1 = 4 bits du bas du code = modif DMACon

			add.w	d0,d0
			bcc.s	.noRd			; test du bit 15.0=pas de repet canal D
			move.l	.resetv(pc),a3
			move.l	(a3)+,$d0-$a0(a6)
			move.w	(a3)+,$d4-$a0(a6)
.noRd:			add.w	d0,d0			; test du bit 14.0=pas de repet canal C
			bcc.s	.noRc
			move.l	.resetv+4(pc),a3
			move.l	(a3)+,$c0-$a0(a6)
			move.w	(a3)+,$c4-$a0(a6)
.noRc:		add.w	d0,d0
			bcc.s	.noRb			; test du bit 13.0=pas de repet canal B
			move.l	.resetv+8(pc),a3
			move.l	(a3)+,$b0-$a0(a6)
			move.w	(a3)+,$b4-$a0(a6)
.noRb:		add.w	d0,d0
			bcc.s	.noRa			; test du bit 12.0=pas de repet canal A
			move.l	.resetv+12(pc),a3
			move.l	(a3)+,(a6)
			move.w	(a3)+,$a4-$a0(a6)
.noRa:		

			add.w	d0,d0			; test du bit 11.0=pas de changement de volume D
			bcc.s	.noVd
			move.b	(a0)+,$d9-$a0(a6)
.noVd:			add.w	d0,d0			; test du bit 10.0=pas de changement de volume C
			bcc.s	.noVc
			move.b	(a0)+,$c9-$a0(a6)
.noVc:		add.w	d0,d0				; test du bit 09.0=pas de changement de volume B
			bcc.s	.noVb
			move.b	(a0)+,$b9-$a0(a6)
.noVb:		add.w	d0,d0				; test du bit 08.0=pas de changement de volume A
			bcc.s	.noVa
			move.b	(a0)+,$a9-$a0(a6)
.noVa:		
			move.l	a0,(a1)+	; store byte stream ptr

; debut lecture du flux en word
			move.l	(a1),a0		; word stream

			add.w	d0,d0			; test du bit 15.0=pas de changement de volume D
			bcc.s	.noPd
			move.w	(a0)+,$d6-$a0(a6)	; changement de note canal D
.noPd:		add.w	d0,d0
			bcc.s	.noPc
			move.w	(a0)+,$c6-$a0(a6)	; changement de note canal C
.noPc:		add.w	d0,d0
			bcc.s	.noPb
			move.w	(a0)+,$b6-$a0(a6)	; changement de note canal B
.noPb:		add.w	d0,d0
			bcc.s	.noPa
			move.w	(a0)+,$a6-$a0(a6)	; changement de note canal A
.noPa:		
			tst.w	d1
			beq.s	.noInst

			move.l	m_dmaconPatch-4(a1),a3		; dmacon patch
			move.w	d1,$96-$a0(a6)				; switch off DMA
			move.b	d1,(a3)						; dmacon : $8000 + d1 en .b => set canaux DMA ON		
			move.l	m_lspInstruments-4(a1),a2	; instrument table



			lea		.resetv(pc),a3
			add.w	d0,d0
			bcc.s	.noId
			add.w	(a0)+,a2
			move.l	(a2)+,$d0-$a0(a6)		; 
			move.w	(a2)+,$d4-$a0(a6)
			move.l	a2,(a3)				; stocke pointeur sur repetition de l'instrument/sample
.noId:		add.w	d0,d0
			bcc.s	.noIc
			add.w	(a0)+,a2
			move.l	(a2)+,$c0-$a0(a6)
			move.w	(a2)+,$c4-$a0(a6)
			move.l	a2,4(a3)
.noIc:		add.w	d0,d0
			bcc.s	.noIb
			add.w	(a0)+,a2
			move.l	(a2)+,$b0-$a0(a6)
			move.w	(a2)+,$b4-$a0(a6)
			move.l	a2,8(a3)
.noIb:		add.w	d0,d0
			bcc.s	.noIa
			add.w	(a0)+,a2
			move.l	(a2)+,(a6)
			move.w	(a2)+,$a4-$a0(a6)
			move.l	a2,12(a3)
.noIa:		

.noInst:		move.l	a0,(a1)			; store word stream (or byte stream if coming from early out)
			rts

.r_rewind:	move.l	m_byteStreamLoop(a1),a0
			move.l	m_wordStreamLoop(a1),m_wordStream(a1)
			bra		.process

.r_chgbpm:	move.b	(a0)+,(m_currentBpm+1)(a1)	; BPM
			bra		.process


	rsreset
	
m_byteStream:		rs.l	1	;  0 byte stream
m_wordStream:		rs.l	1	;  4 word stream
m_dmaconPatch:		rs.l	1	;  8 m_lfmDmaConPatch
m_codeTableAddr:	rs.l	1	; 12 code table addr
m_lspInstruments:	rs.l	1	; 16 LSP instruments table addr
m_relocDone:		rs.w	1	; 20 reloc done flag
m_currentBpm:		rs.w	1	; 22 current BPM
m_byteStreamLoop:	rs.l	1	; 24 byte stream loop point
m_wordStreamLoop:	rs.l	1	; 28 word stream loop point
sizeof_LSPVars:		rs.w	0

.LSPVars:	ds.b	sizeof_LSPVars
			
.resetv:	dc.l	0,0,0,0

; a0: music data (any mem)
; a1: sound bank data (chip mem)
; a2: 16bit DMACON word address

.LSP_PlayerInit:
			cmpi.l	#'LSP1',(a0)+					; A0+4
			bne.s	.dataError
			move.l	(a0)+,d0		; unique id		; A0+8
			cmp.l	(a1),d0			; check that sample bank is this one
			bne.s	.dataError

			lea		.LSPVars(pc),a3
			move.w	(a0)+,d0				; skip major & minor version of LSP	; a0+10
			move.w	(a0)+,m_currentBpm(a3)			; default BPM : 125			; a0+12
			move.l	a2,m_dmaconPatch(a3)			
			move.w	(a0)+,d0				; instrument count : 0x000F		; a0+14
			lea		-12(a0),a2				; LSP data has -12 offset on instrument tab ( to win 2 cycles in fast player :) )
			move.l	a2,m_lspInstruments(a3)			; instrument tab addr ( minus 4 )
			tst.b	m_relocDone(a3)
			bne.s	.skip
			st		m_relocDone(a3)
			subq.w	#1,d0
			move.l	a1,d1
.relocLoop:		add.l	d1,(a0)
			add.l	d1,6(a0)
			lea		12(a0),a0
			dbf		d0,.relocLoop
			bra.s	.relocDone

.skip:			mulu.w	#12,d0					; saute la table d'instruments integr?e dans le fichier lsmusic
			add.l	d0,a0										; a0+14+(15*12) = +$C2/+194

.relocDone:		move.w	(a0)+,d0				; codes count (+2)		d0=0x01c3		; a0+194+2
			move.l	a0,m_codeTableAddr(a3)			; code table : 0x00C4 dans le fichier
			add.w	d0,d0					; *2 = +902   : $c4+ = $456
			add.w	d0,a0
			move.l	(a0)+,d0				; word stream size = $0000 BFBC ( en $44a dans le fichier lsmusic)
			move.l	(a0)+,d1				; byte stream loop point = $0000 1ADA = 6874
			move.l	(a0)+,d2				; word stream loop point = $0000 30F2 = 12530

			move.l	a0,m_wordStream(a3)
			lea		0(a0,d0.l),a1			; byte stream = a0+d0
			move.l	a1,m_byteStream(a3)
			add.l	d2,a0
			add.l	d1,a1
			move.l	a0,m_wordStreamLoop(a3)
			move.l	a1,m_byteStreamLoop(a3)
			bset.b	#1,$bfe001				; disabling this fucking Low pass filter!!
			lea		m_currentBpm(a3),a0
			rts

.dataError:	illegal
