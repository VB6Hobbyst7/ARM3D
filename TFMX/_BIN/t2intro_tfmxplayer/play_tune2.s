; Hi Leonard, this little routines plays the turrican 2 intromusic
; which uses 7voices iirc so it should be a good test for your
; paula emulator. :) the module needs to be at $2f000 otherwise
; the player won't work correctly due to some absolute addresses
; used in the voicestructures. it also needs the VBR at $0 otherwise
; the IRQ Init will fail. Hope it's useful for you. If you have
; questions, just drop me a line in the forum. :)
;
; Regards, Sting



	SECTION	TEST,CODE_c

START	move.w	#$4000,$dff09a
	bsr	INIT_TYPE1
.loop	btst	#6,$bfe001
	bne.b	.loop
	move.w	#$c000,$dff09a
	rts
	


INIT_TYPE1
	move.l	#$30000,d0
	jsr	replay+$675e8-$64a50


	moveq	#0,d0
	move.w	SUBSONG(pc),d0
	moveq	#18,d1
	movem.w	d0/d1,-(sp)
	move.l	SONGPTR(pc),d0
	move.l	d0,d1
	add.l	#$13CE6,d0		; point to begin of patterndata
	move.l	#$7E000,d2

;	move.l	#buf,d2

	bsr	replay+$675d4-$64a50	;($675D4)
	movem.w	(sp),d0/d1
	move.w	d1,d0
	bsr	replay+$67620-$64a50	;($67620)
	movem.w	(sp)+,d0/d1
	bsr	replay+$675cc-$64a50	;($675CC)
	rts
	


; loaded to: $13e70
; decrunched to: $2f000

SONGPTR		dc.l	song		; ptr to loaded module
SUBSONG		dc.w	0		; subsong? (0-2 for t2_introtune)

; $64a50
replay	incbin	sources:tfmx_replay/replay.bin

	org	$2f000
song	incbin	sources:tfmx_replay/testsongs/t2_introtune.tfmx

;buf	ds.b	$80000-$7e000
