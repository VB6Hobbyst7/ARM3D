; OK : ne plus utiliser la pile dans la vbl
; OK : la vbl compte juste le nb de frame
; OK : la boucle principale attend la vbl
; OK : modif du pointeur ecran en supervisor dans la boucle principale
; plot d'un point

; vsync
; irq status A bit3
; control port : bit 7
; pas FIQ
; irq, PC=18
; at memory 1c = return


.equ Screen_Mode, 13
.equ screenstartabs, 0x0000
.equ screenstart, 0x0000
.equ screenlow, 0x2000


.include "swis.h.asm"

.org 0x8000

Start:
    adr sp, stack_base
	B main

.skip 1024
stack_base:

scr_bank:
	.long 0

main:

	bl creer_table_320

	MOV r0,#22	;Set MODE
	SWI OS_WriteC
	MOV r0,#Screen_Mode
	SWI OS_WriteC
	
		MOV r0,#23	;Disable cursor
	SWI OS_WriteC
	MOV r0,#1
	SWI OS_WriteC
	MOV r0,#0
	SWI OS_WriteC
	SWI OS_WriteC
	SWI OS_WriteC
	SWI OS_WriteC
	SWI OS_WriteC
	SWI OS_WriteC
	SWI OS_WriteC
	SWI OS_WriteC

	
	; Claim the Event vector
	mov r0, #EventV
	adr r1, event_handler
	mov r2, #0
	swi OS_AddToVector
	
	; Enable Vsync event
	mov r0, #OSByte_EventEnable
	mov r1, #Event_VSync
	SWI OS_Byte

	mov r0,#screenlow
	str	r0,screenaddr

; boucle

boucle:
; vsync
	LDR r0, vsync_count
.bouclevsync:
	LDR r1, vsync_count
	cmp r0, r1
	beq .bouclevsync
	
	;supervisor mode
	SWI 22

;Vinit = &3600000+(val>>4)<<2

	ldr	r0,screenaddr
	mov r0,r0,lsr #4
	mov r0,r0,lsl #2
	mov r1,#0x3600000
	add r0,r0,r1
	str r0,[r0]
	
;Vstart = &3620000+(val>>4)<<2
	ldr r0,screenaddr
	mov r0,r0,lsr #4
	mov r0,r0,lsl #2
	mov r1,#0x3620000
	add r0,r0,r1
	str r0,[r0]	

	ldr	r0,screenaddr
	add r0,r0,#320
	str r0,screenaddr	

; plot d'un point
	ldr	r0,screenaddr
	add r0,r0,#3200
	mov r1,#0x2000000 
	add r0,r0,r1
	mov r1,#0x7777
	ldr r2,[r0]
	eor r2,r2,r1
	mov r2,r1
	
	mov r1,#100
.boucler:
	str r2,[r0]
	add r0,r0,#4
	subs r1,r1,#1
	bne .boucler

	bl	drawline
	
	nop
	nop
	nop
	
	TEQP PC,#0
	MOVNV R0,R0
	
	
	LDR r0, vsync_count
	cmp r0,#50
	bne boucle

	; disable vsync event
	mov r0, #OSByte_EventDisable
	mov r1, #Event_VSync
	swi OS_Byte
	
		; release our event handler
	mov r0, #EventV
	adr r1, event_handler
	mov r2, #0
	swi OS_Release
	
	; Show our final frame count
	bl debug_write_vsync_count
	
	MOV R0,#0
	SWI OS_Exit


; https://fr.wikipedia.org/wiki/Algorithme_de_trac%C3%A9_de_segment_de_Bresenham
drawline:
		ldr	r1,x1
		ldr r2,x2
		ldr r3,y1
		ldr r4,y2
		
		mov		r9,#0x2000000 		; pointeur video
		ldr		r11,screenaddr
		add		r9,r9,r11
		mov		r10,#45				; couleur		
		
		subs r5,r2,r1	; r5 = e =x2-x1
		add r6,r5,r5	; r6 = dx =e*2
		subs r7,r4,r3	; r7 = y2-y1
		add r7,r7,r7	; r7= dy = (y2 - y1) × 2

.boucledrawligne:
		; plot x=r1,y=r3
		; 1 registre : pointeur video
		; 1 registre : couleur
		mov		r8,r3,lsl #2		; y * 4
		mov		r11,#table320
		add		r8,r8,r11			; y * 320
		ldr		r8,[r8]				; r8=y*320
		add		r8,r8,r1			; on ajoute x : r8=x+ (y*320)
		add		r8,r8,r9

		strb	r10,[r8]			; plot pixel avec couleur
		
		
		
		adds r1,r1,#1				; on incremente x
		
		
		subs r5,r5,r7				; on avance e
		addlt r3,r3,#1				; on incremente y si lower than
		addlt r5,r5,r6				; on incremente e si lower than
		
		; x1<x2 ?
		cmp r1,r2
		ble .boucledrawligne
		
		mov pc, r14
		
		


x1:		.long		50
y1:		.long		50
x2:		.long		100
y2:		.long		80

table320:	.skip		256*4
	
creer_table_320:

	mov		r1,#table320
	mov		r0,#0
	mov		r2,#256
.boucle320:
	
	str		r0,[r1],#4
	add		r0,r0,#320
	subs	r2,r2,#1
	bgt		.boucle320
	mov pc, r14
	
; R0=event number
event_handler:
	cmp r0, #Event_VSync
	movnes pc, r14
	
	str lr,savelr
	
; update the vsync counter
	str r0,saver0
	
	LDR r0, vsync_count
	ADD r0, r0, #1
	STR r0, vsync_count
	
	ldr r0,saver0
	
	
	ldr pc,savelr

vsync_count:	.long 0
last_vsync:		.long -1
saver0:		.long 0


	
debug_write_vsync_count:
	mov r0, #30
	swi OS_WriteC

	ldr r0, vsync_count
	ldr r1, last_vsync
	sub r0, r0, r1
	adr r1, debug_string
	mov r2, #8
	swi OS_ConvertHex4

	adr r0, debug_string
	swi OS_WriteO

	mov pc, r14
	
	
	
debug_string:
	.skip 12
	
screenaddr:
	.long 0


save_R14:	
	.long 0

saver14:	.long 0
saver13:	.long 0
savelr:		.long 0

