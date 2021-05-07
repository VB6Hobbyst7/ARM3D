; essai en 320x200
; 320 / 4 carrés de 80 * 80
; 516 x 258 mode 97

; ecrire 00 en &3350048 IOC

.equ Screen_Mode, 97
.equ	IKey_Escape, 0x9d

.include "swis.h.asm"

	.org 0x8000
	.balign 8

; run mode 97 module from memory

	mov		R0,#11			; OS_Module 10 
	ldr		R1,pointeur_module97
	SWI 0x1E



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
	MOV r2, #416*258*2
	; 320*256 * 2 ecrans
	SUBS r1, r2, r1
	SWI OS_ChangeDynamicArea
	
; taille dynamic area screen = 320*256*2

	MOV r0, #DynArea_Screen
	SWI OS_ReadDynamicArea
	
	; r0 = pointeur memoire ecrans
	
	str		r0,screenaddr1
	add		r0,r0,#416*258
	str		r0,screenaddr2
	mov		r0,#0
	str		r0,screenaddr1_MEMC
	add		r0,r0,#416*258
	str		r0,screenaddr2_MEMC
	
	mov		R11,#5
	mov		R10,#0				; ajout vertical
		mov		R0,#0x10			; couleur


;------------------

; vsync
    MOV R0,#19
    SWI OS_Byte

;superuser
	SWI		22
	MOVNV R0,R0
	
;Video control latch
	ldr		R2,valeur_IOC
	MOV 	R0,#0
	STRB	R0,[R2]
	
	
	; update pointeur video hardware
	ldr	r0,screenaddr1_MEMC
	mov r0,r0,lsr #4
	mov r0,r0,lsl #2
	mov r1,#0x3600000
	add r0,r0,r1
	str r0,[r0]

;
;	adr		R3,table_mode97
;	ldr		R2,[R3],#4			; nb de registres
;	mov   	r0,#0x3400000
	
boucle_mode97:
;	ldr		R1,[R3],#4
;	str		r1,[r0]
;	mov   r0,r0
	
;	subs	R2,R2,#1
;	bgt		boucle_mode97


	teqp  r15,#0                     
	mov   r0,r0

;----------------



boucle_grille:
	
	
	ldr		r1,screenaddr1
	add		R1,R1,R10
	
	
	mov		R2,#50				; nb lignes

boucle_ligne:

	mov		R3,#104				; nb pixels
boucle_pixel:
	strb	R0,[R1],#1
	
	subs	R3,R3,#1
	bgt		boucle_pixel
	
	add		R1,R1,#416-104
	
	subs	R2,R2,#1
	bgt		boucle_ligne

;-------------------------
	ldr		r1,screenaddr1
	add		R1,R1,R10

	add		R1,R1,#104
	
	add		R0,R0,#11
	;mov		R0,#0x0F			; couleur
	
	mov		R2,#50				; nb lignes

boucle_ligne2:

	mov		R3,#104				; nb pixels
boucle_pixel2:
	strb	R0,[R1],#1
	
	subs	R3,R3,#1
	bgt		boucle_pixel2
	
	add		R1,R1,#416-104
	
	subs	R2,R2,#1
	bgt		boucle_ligne2

;-------------------------

	ldr		r1,screenaddr1
	add		R1,R1,R10

	add		R1,R1,#104*2
	
	add		R0,R0,#11
	
	;mov		R0,#0xF0			; couleur
	
	mov		R2,#50				; nb lignes

boucle_ligne21:

	mov		R3,#104				; nb pixels
boucle_pixel21:
	strb	R0,[R1],#1
	
	subs	R3,R3,#1
	bgt		boucle_pixel21
	
	add		R1,R1,#416-104
	
	subs	R2,R2,#1
	bgt		boucle_ligne21

;-------------------------
	
	ldr		r1,screenaddr1
	add		R1,R1,R10

	add		R1,R1,#104*3
	
	add		R0,R0,#11
	
	;mov		R0,#0x6F			; couleur
	
	mov		R2,#50				; nb lignes

boucle_ligne22:

	mov		R3,#104				; nb pixels
boucle_pixel22:
	strb	R0,[R1],#1
	
	subs	R3,R3,#1
	bgt		boucle_pixel22
	
	add		R1,R1,#416-104
	
	subs	R2,R2,#1
	bgt		boucle_ligne22


	add		R10,R10,#416*50
	
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

valeur_IOC:		.long 0x3350048

; 11 valeurs
table_mode97:
	.long		14
; valeur en passant par customvdu
	.long		0x803FC000
	.long		0x84048000
	.long		0x880ec000
	.long		0x8c0a4000
	.long		0x903e4000
	.long		0x943ac000
	.long		0xa04dc000
	.long		0xa4008000
	.long		0xa8094000
	.long		0xAC094000
	.long		0xB049C000
	.long		0xB449C000
	.long		0xe000000C				; 0xe000000c
	.long		0x9c400000
	   
; valeur module mode 97	
	.long			0x803FC000
	.long   	    0x84048000
    .long           0x880EC000
    .long           0x8C0A4000
    .long           0x903E4000
    .long           0x943AC000
    .long           0xA8094000
    .long           0xAC094000
    .long           0xB049C000
    .long           0xB449C000
    .long           0xE000000C
	
pointeur_module97:		.long	module97
module97:		.incbin	"97,ffa"