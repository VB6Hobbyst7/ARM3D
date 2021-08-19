; vsync
; irq status A bit3
; control port : bit 7
; pas FIQ
; irq, PC=18
; at memory 1c = return


.equ Screen_Mode, 13
;.equ screenstartabs, 0x1FEC000
;.equ screenstart, 0x1FEC000
.equ screenstartabs, 0x2000
.equ screenstart, 0x2000
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


	;mov r1,#screenstart
	;mov r2,#0x1
	;LDR r0, [r1]
	;STR r2,[r1]

; vsync
	MOV R0,#19
	SWI OS_Byte

;supervisor mode
	SWI 22

;Vinit = &3600000+(val>>4)<<2

	mov r0,#screenlow
	str	r0,screenaddr
	mov r0,r0,lsr #4
	mov r0,r0,lsl #2
	mov r1,#0x3600000
	add r0,r0,r1
	str r0,[r0]

;Vstart = &3620000+(val>>4)<<2
	;ldr r0,screenaddr
	;mov r0,r0,lsr #4
	;mov r0,r0,lsl #2
	;mov r1,#0x3620000
	;add r0,r0,r1
	;mov r1,#0x3600000
	;str r0,[r1]	
	nop
	nop
	nop
	
	TEQP PC,#0
	MOVNV R0,R0
	

	;mov r1,#0x8000
	;mov r0,#22
	;SWI OS_Word

; boucle

boucle:
	LDR r0, vsync_count
	cmp r0,#500
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
	
	
	
; R0=event number
event_handler:
	cmp r0, #Event_VSync
	movnes pc, r14
	
	str lr,savelr
	STMDB sp!, {r0-r2}

	; update the vsync counter
	LDR r0, vsync_count
	ADD r0, r0, #1
	STR r0, vsync_count

	str	r14,saver14
	str r13,saver13

	;supervisor mode
	SWI 22
	
	;ldr	r1,screenaddr
	;add r1,r1,#3200
	;LDR r0, [r1]
	;mov r2,#0x303
	;mov r0,r0, ror #31
	;eor r0,r0,r2
	;mov r0,#0xFFFFFFFF
	;STR r0,[r1]

	nop
	nop
	nop
	
	TEQP PC,#0
	MOVNV R0,R0
	



	ldr	r0,screenaddr
	add r0,r0,#320
	str r0,screenaddr
	mov r0,r0,lsr #4
	mov r0,r0,lsl #2
	mov r1,#0x3600000
	add r0,r0,r1
	str r0,[r0]
	
	ldr	r14,saver14
	ldr r13,saver13
	
	LDMIA sp!, {r0-r2}
	
	ldr pc,savelr

vsync_count:
	.long 0
	
last_vsync:
	.long -1
	
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

