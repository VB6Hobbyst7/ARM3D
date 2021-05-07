; essai en 320x200
; 320 / 4 carrés de 80 * 80
;

.equ Screen_Mode, 13
.equ	IKey_Escape, 0x9d

.include "swis.h.asm"

	.org 0x8000
	.balign 8

	mov		R1,#0			; stop color flashing
	mov		R0,#9
	swi		OS_Byte
	
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
	
	; Set screen size for number of buffers
	MOV r0, #DynArea_Screen
	SWI OS_ReadDynamicArea
	; r1=taille actuelle de la memoire ecran
	MOV r0, #DynArea_Screen
	MOV r2, #320*256*2
	; 320*256 * 2 ecrans
	SUBS r1, r2, r1
	SWI OS_ChangeDynamicArea
	
; taille dynamic area screen = 320*256*2

	MOV r0, #DynArea_Screen
	SWI OS_ReadDynamicArea
	
	; r0 = pointeur memoire ecrans
	
	str		r0,screenaddr1
	add		r0,r0,#320*256
	str		r0,screenaddr2
	mov		r0,#0
	str		r0,screenaddr1_MEMC
	add		r0,r0,#320*256
	str		r0,screenaddr2_MEMC
	
	mov		R11,#5
	mov		R10,#0				; ajout vertical
		mov		R0,#0x10			; couleur

boucle_grille:
	
	
	ldr		r1,screenaddr1
	add		R1,R1,R10
	
	
	mov		R2,#50				; nb lignes

boucle_ligne:

	mov		R3,#80				; nb pixels
boucle_pixel:
	strb	R0,[R1],#1
	
	subs	R3,R3,#1
	bgt		boucle_pixel
	
	add		R1,R1,#320-80
	
	subs	R2,R2,#1
	bgt		boucle_ligne

;-------------------------
	ldr		r1,screenaddr1
	add		R1,R1,R10

	add		R1,R1,#80
	
	add		R0,R0,#11
	;mov		R0,#0x0F			; couleur
	
	mov		R2,#50				; nb lignes

boucle_ligne2:

	mov		R3,#80				; nb pixels
boucle_pixel2:
	strb	R0,[R1],#1
	
	subs	R3,R3,#1
	bgt		boucle_pixel2
	
	add		R1,R1,#320-80
	
	subs	R2,R2,#1
	bgt		boucle_ligne2

;-------------------------

	ldr		r1,screenaddr1
	add		R1,R1,R10

	add		R1,R1,#80*2
	
	add		R0,R0,#11
	
	;mov		R0,#0xF0			; couleur
	
	mov		R2,#50				; nb lignes

boucle_ligne21:

	mov		R3,#80				; nb pixels
boucle_pixel21:
	strb	R0,[R1],#1
	
	subs	R3,R3,#1
	bgt		boucle_pixel21
	
	add		R1,R1,#320-80
	
	subs	R2,R2,#1
	bgt		boucle_ligne21

;-------------------------
	
	ldr		r1,screenaddr1
	add		R1,R1,R10

	add		R1,R1,#80*3
	
	add		R0,R0,#11
	
	;mov		R0,#0x6F			; couleur
	
	mov		R2,#50				; nb lignes

boucle_ligne22:

	mov		R3,#80				; nb pixels
boucle_pixel22:
	strb	R0,[R1],#1
	
	subs	R3,R3,#1
	bgt		boucle_pixel22
	
	add		R1,R1,#320-80
	
	subs	R2,R2,#1
	bgt		boucle_ligne22


	add		R10,R10,#320*50
	
	subs	R11,R11,#1
	bgt		boucle_grille


	
boucle:



	; exit if SPACE is pressed
	MOV r0, #OSByte_ReadKey
	MOV r1, #IKey_Escape
	MOV r2, #0xff
	SWI OS_Byte
	
	CMP r1, #0xff
	CMPEQ r2, #0xff
	BEQ exit


	b	boucle
	
	
exit:	
	MOV r0,#22	;Set MODE
	SWI OS_WriteC
	MOV r0,#Screen_Mode
	SWI OS_WriteC


; rmkill RM24
;	mov		R1,#nom_module_Rasterman
;	mov		R0,#04
;	swi		OS_Module

; rmkill QT
;	mov		R1,#nom_module_QT
;	mov		R0,#04
;	swi		OS_Module

	
	MOV R0,#0
	SWI OS_Exit
	nop
	nop


screenaddr1:	.long 0
screenaddr2:	.long 0
screenaddr1_MEMC:	.long 0
screenaddr2_MEMC:	.long 0
