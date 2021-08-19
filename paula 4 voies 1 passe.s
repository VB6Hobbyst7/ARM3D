; mixage sans gestion du Paula
	str	R14,save_R14_Paula

	adr	R0,Paula_registers_external
	adr	R1,sample
	
	ldr	R2,[R0,#0x50]
	ldr	R3,[R0,#0x5C]
	ldr	R13,[R0,#0x0C]			; volume canal A

	ldr	R5,[R0,#0x60]
	ldr	R6,[R0,#0x6C]
	ldr	R10,[R0,#0x20]			; volume canal B
	orr	R13,R10,R13,lsl #8

	ldr	R8,[R0,#0x70]
	ldr	R9,[R0,#0x7C]
	ldr	R10,[R0,#0x34]			; volume canal C
	orr	R13,R10,R13,lsl #8

	ldr	R11,[R0,#0x80]
	ldr	R12,[R0,#0x8C]
	ldr	R10,[R0,#0x48]			; volume canal D
	orr	R13,R10,R13,lsl #8

; R13 = vAvBvCvD
	mov	R10,#416

	ldr	R14,adresse_dma1_logical

; R0 : registre de travail, sample
; R1 : base des samples tous canaux

; R2 : index canal A ( par rapport au début des samples )
; R3 : increment canal A
; R4 : volume canal en cours

; R5 : index canal B ( par rapport au début des samples )
; R6 : increment canal B

; R7 : octet final pour DMA

; R8 : index canal C ( par rapport au début des samples )
; R9 : increment canal C

; R10: index boucle

; R11: index canal D ( par rapport au début des samples )
; R12: increment canal D

; R13: volume canal A B C D
; R14: destination buffer DMA


boucle_Paula_remplissage_DMA_416:
	ldrb	R0,[R1,R2,asr #12]
	add	R2,R2,R3
	mov	R4,R13,asr #24
	subs	R0,R0,R4
	movmi	R0,#0
	mov	R7,R0,lsl #24

	ldrb	R0,[R1,R5,asr #12]
	add	R5,R5,R6
	mov	R4,R13,asr #16
	and	R4,R4,#0xFF
	subs	R0,R0,R4
	movmi	R0,#0
	orr	R7,R0,R0,lsl #16

	ldrb	R0,[R1,R8,asr #12]
	add	R8,R8,R9
	mov	R4,R13,asr #8
	and	R4,R4,#0xFF
	subs	R0,R0,R4
	movmi	R0,#0
	orr	R7,R0,R0,lsl #8

	ldrb	R0,[R1,R11,asr #12]
	add	R11,R11,R12
	mov	R4,R13
	and	R4,R4,#0xFF
	subs	R0,R0,R4
	movmi	R0,#0
	orr	R7,R0,R0

	str	R7,[R14],#4

	subs	R10,R10,#1
	bgt	boucle_Paula_remplissage_DMA_416





