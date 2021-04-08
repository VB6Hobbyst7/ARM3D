; OK : ne plus utiliser la pile dans la vbl
; OK : la vbl compte juste le nb de frame
; OK : la boucle principale attend la vbl
; OK : modif du pointeur ecran en supervisor dans la boucle principale
; plot d'un point

;Address registers (addresses in binary) :
;Vinit   - %11011x000dddddddddddddddxx
;Vstart  - %11011x001dddddddddddddddxx
;Vend    - %11011x010dddddddddddddddxx
;Cinit   - %11011x011dddddddddddddddxx
;SstartN - %11011x100dddddddddddddddxx
;SendN   - %11011x101dddddddddddddddxx
;Sptr    - %11011x110xxxxxxxxxxxxxxxxx
;Control - %11011x111xxx0dddddddddddxx

; vsync
; irq status A bit3
; control port : bit 7
; pas FIQ
; irq, PC=18
; at memory 1c = return

; breakpoint
;	swi 0x44B85

.equ Screen_Mode, 13

;.global		screen1,screen2

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


	;swi 0x44B85

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
	
	ldr		r1,screenaddr1
	ldr		r2,screenaddr2
	mov		r3,#0
	mov		r0,#20480
.clsall:
	str		r3,[r1],#4
	str		r3,[r2],#4
	subs	r0,r0,#1
	bne		.clsall
	
	

	bl creer_table_320

	
	; Claim the Event vector
	mov r0, #EventV
	adr r1, event_handler
	mov r2, #0
	swi OS_AddToVector
	
	; Enable Vsync event
	mov r0, #OSByte_EventEnable
	mov r1, #Event_VSync
	SWI OS_Byte

	
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
	MOVNV R0,R0

; bordure en rouge
	mov   r0,#0x3400000               
	mov   r1,#111                
	orr   r1,r1,#0x40000000      
	str   r1,[r0]
	
;Vinit = &3600000+(val>>4)<<2

	ldr	r0,screenaddr1_MEMC
	mov r0,r0,lsr #4
	mov r0,r0,lsl #2
	mov r1,#0x3600000
	add r0,r0,r1
	str r0,[r0]

;Vstart = &3620000+(val>>4)<<2
	;ldr r0,screenaddr1
	;mov		r0,#320*128
	;mov r0,r0,lsr #4
	;mov r0,r0,lsl #2
	;mov r1,#0x3620000
	;add r0,r0,r1
	;str r0,[r0]	

	TEQP PC,#0
	MOVNV R0,R0

; swap les pointeurs ecran

	ldr		r3,screenaddr1
	ldr		r4,screenaddr2
	eorgt		r3,r3,r4		; swap r3,r4 
	eorgt		r4,r3,r4
	eorgt		r3,r3,r4
	str		r3,screenaddr1
	str		r4,screenaddr2

	ldr		r3,screenaddr1_MEMC
	ldr		r4,screenaddr2_MEMC
	eorgt		r3,r3,r4		; swap r3,r4 
	eorgt		r4,r3,r4
	eorgt		r3,r3,r4
	str		r3,screenaddr1_MEMC
	str		r4,screenaddr2_MEMC


	;ldr	r0,screenaddr1
	;add r0,r0,#320
	;str r0,screenaddr1

	bl	cls_ecran_actuel

	bl	calc3D

	mov r11,#coordonnees_projetees

		.rept	3
	ldr		r1,[r11],#4		;x1
	add		r1,r1,#160
	ldr		r3,[r11],#4		;y1
	add		r3,r3,#128
	ldr		r2,[r11],#4		;x2
	add		r2,r2,#160
	ldr		r4,[r11],#4		;y2
	add		r4,r4,#128
	

	;ldr	r1,x1
	;ldr r2,x2
	;ldr r3,y1
	;ldr r4,y2

	bl	drawline
	
	sub		r11,r11,#8
	
	.endr


	ldr		r0,x1
	add		r0,r0,#1
	movnes	r1,#319
	cmp		r0,r1
	moveq	r0,#0
	
	str		r0,x1
	
	

; change border color
	mov   r0,#0x3400000               
	mov   r1,#000                  
	orr   r1,r1,#0x40000000            
	SWI 22
	MOVNV R0,R0            
	str   r1,[r0]                     
	teqp  r15,#0                     
	mov   r0,r0    


	
	
	LDR r0, vsync_count
	cmp r0,#500
	bne boucle


;-----------------------
;sortie
;-----------------------




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

	MOV r0,#22	;Set MODE
	SWI OS_WriteC
	MOV r0,#Screen_Mode
	SWI OS_WriteC
	
	MOV R0,#0
	SWI OS_Exit
	nop
	nop

noir:	.long 	0b01000000111111111110000000000000


; https://fr.wikipedia.org/wiki/Algorithme_de_trac%C3%A9_de_segment_de_Bresenham
drawline:
; r1=x1, r2=x2, r3=y1, r4=y2
; breakpoint
;	swi 0x44B85


		
		; calculer DeltaX et DeltaY
		subs	r5,r2,r1	; r5 = e =x2-x1
		rsbmi	r5,r5,#0	; r5 = abs(x2-1)  delta X

		subs	r7,r4,r3	; r7 = y2-y1
		rsbmi 	r7,r7,#0	; r7 = abs(y2-y1)

; delta Y > delta X ?		
		cmp		r7,r5
		bgt		ligne_increment_en_Y

; x2>x1 ?		
 		cmp		r1,r2
		; si x1>x2 : on inverse x1,y1 et x2,y2 
		eorgt		r1,r1,r2		; swap r1,r2 ( x1,x2)
		eorgt		r2,r1,r2
		eorgt		r1,r1,r2
		eorgt		r3,r3,r4		; swap r3,r4 ( y1,y2)
		eorgt		r4,r3,r4
		eorgt		r3,r3,r4
		
		mov		r12,#320
		cmp		r4,r3		; Y2 > Y1 ?
		rsblt	r12,r12,#0
		
		
		mov		r9,#0x2000000 		; pointeur video
		mov		r9,#0x000000
		ldr		r10,screenaddr1
		add		r9,r9,r10
		; on ajoute y debut
		mov		r10,#table320
		mov		r8,r3,lsl #2		; y * 4
		add		r8,r8,r10			; y * 320
		ldr		r8,[r8]				; r8=y*320
		add		r9,r8,r9			; pointeur ecran + y*320
		add		r9,r9,r1			; on ajoute x : r9=pointeur ecran + x+ (y*320)
		
		mov		r10,#45				; couleur		
		

		add		r6,r5,r5	; r6 = dx =e*2
		
		add 	r7,r7,r7	; r7= dy = (y2 - y1) × 2

.boucledrawligne1:
		; plot x=r1,y=r3
		; 1 registre : r9 : pointeur video
		; 1 registre : r10 : couleur
		
		strb	r10,[r9]			; plot pixel avec couleur
				
		adds r9,r9,#1				; on incremente pointeur ecran en x
		adds r1,r1,#1				; on incremente x
					
		subs r5,r5,r7				; on avance e
		;addlt r3,r3,#1				; on incremente y si lower than
		addlt r9,r9,r12			; on incremente pointeur ecran de 320 si y+1
		addlt r5,r5,r6				; on incremente e si lower than
		
		
		; x1<x2 ?
		cmp r1,r2
		ble .boucledrawligne1
		mov pc, r14

ligne_increment_en_Y:		
		
; y2>y1 ?		
 		cmp		r3,r4
		; si y1>y2 : on inverse x1,y1 et x2,y2 
		eorgt		r1,r1,r2		; swap r1,r2 ( x1,x2)
		eorgt		r2,r1,r2
		eorgt		r1,r1,r2
		eorgt		r3,r3,r4		; swap r3,r4 ( y1,y2)
		eorgt		r4,r3,r4
		eorgt		r3,r3,r4

		mov		r12,#320
		cmp		r4,r3		; Y2 > Y1 ?
		rsblt	r12,r12,#0		
		
		mov		r9,#0x2000000 		; pointeur video
		mov		r9,#0x000000
		ldr		r10,screenaddr1
		add		r9,r9,r10
		; on ajoute y debut
		mov		r10,#table320
		mov		r8,r3,lsl #2		; y * 4
		add		r8,r8,r10			; y * 320
		ldr		r8,[r8]				; r8=y*320
		add		r9,r8,r9			; pointeur ecran + y*320
		add		r9,r9,r1			; on ajoute x : r9=pointeur ecran + x+ (y*320)
		
		mov		r10,#45				; couleur		

; r5 = dx
; r7 = dy
		

		add		r6,r7,r7	; r6 = dy*2 =e*2
		; r7 = e
		
		add 	r5,r5,r5	; r5= dx = (x2 - x1) × 2




.boucledrawligne2:
		; plot x=r1,y=r3
		; 1 registre : r9 : pointeur video
		; 1 registre : r10 : couleur
		
		strb	r10,[r9]			; plot pixel avec couleur
				
		adds r9,r9,r12				; on incremente pointeur ecran en y +320 ou -320
		adds r3,r3,#1				; on incremente y1
					
		subs r7,r7,r5				; on avance e
		;addlt r1,r1,#1				; on incremente x si lower than
		addlt r9,r9,#1				; on incremente pointeur ecran de 1 si x+1
		addlt r7,r7,r6				; on incremente e=e +dx  si lower than
		
		
		; x1<x2 ?
		cmp r3,r4
		ble .boucledrawligne2
		
		
		mov pc, r14
		
		


x1:		.long		0
y1:		.long		0
x2:		.long		319
y2:		.long		255

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
	
cls_ecran_actuel:

	str		r14,saver14
;320x256 = 81920
	ldr		r0,screenaddr1
	mov		r14,#63
	mov		r1,#0
	mov		r2,r1
	mov		r3,r1
	mov		r4,r1
	mov		r5,r1
	mov		r6,r1
	mov		r7,r1
	mov		r8,r1
	mov		r9,r1
	mov		r10,r1
	mov		r11,r1
	mov		r12,r1
	mov		r13,r1
;13*4 = 52
.boucleCLS:
	.rept	25
	stmia	r0!,{r1-r13}
	.endr
	subs	r14,r14,#1
	bne		.boucleCLS
	
	stmia	r0!,{r1-r5}
	
	ldr		r15,saver14
	
debug_string:
	.skip 12
	
screenaddr1:	.long 0
screenaddr2:	.long 0
screenaddr1_MEMC:	.long 0
screenaddr2_MEMC:	.long 0

; PORTION DE CODE EFFECTUANT LES PROJECTIONS DES POINTS

; SX=SIN/COS ANGLE X,SY=SIN/COS ANGLE Y,SZ=SIN/COS ANGLE Z
; L14=ANGLE ROT X,L16=ANGLE ROT Y,L3C=ANGLE ROT Z
; ROTX,ROTY,ROTZ=ANGLES COURANTS

; table SINCOS entrelacés

; en entrée :
; angleX et incrementX
; angleY et intrementY
; angleZ et incrementZ

; SIN et COS * 32768 signés
; 512 valeurs pour cos et 512 pour sin
; cos * cos *2 puis swap


calc3D:

	str r14,save_R14

	; calcul de la matrice de transformation
	;mov r12,#matrice
	mov r11,#SINCOS
	
	mov	r13,#511
	
	ldr r1,angleX
	ldr	r14,incrementX
	add	r1,r1,r14
	and	r1,r1,r13
	str	r1,angleX
	add r1,r11, r1, lsl #3
	ldmia r1, {r2-r3}			
	; r2=SINX , r3=COSX
	
	ldr r1,angleY
	ldr	r14,incrementY
	add	r1,r1,r14
	and	r1,r1,r13
	str	r1,angleY
	
	add r1,r11, r1, lsl #3
	ldmia r1, {r4-r5}
	; r4=SINY , r5=COSY
	
	ldr r1,angleZ
	ldr	r14,incrementZ
	add	r1,r1,r14
	and	r1,r1,r13
	str	r1,angleZ


	add r1,r11, r1, lsl #3
	ldmia r1, {r6-r7}
	; r6=SINZ , r7=COSZ
	
	RSB r6,r6,#0
	;mov r1,#0
	;sub r6,r1,r6
	;neg R6, ROTATION EN Z BUGGEE !!!

	; r2-r7 utilisés

	; calcul de CY*CZ
	muls r14, r5 , r7	; CY*CZ * 2^15*2^15
	; # / 2^15
	;asr r1,#15
	mov r14,r14,asr #15	; / 32768
	;str r1, [r12], #4	;r14
		
	; calcul de -(CY*SZ*CX+SX*SY)
	muls r1,r5,r6	;r1=cy*sz
	mov r1,r1,asr #15
	mov r8,r1		; on met de coté cy*sz dans R8
	muls r1,r3,r1	; CY*SZ*CX
	muls r0,r2,r4	; SX*SY
	adds r1,r0,r1	; (CY*SZ*CX+SX*SY)
	mov r0,#0
	sub r13,r0,r1,asr #15	; r1=-(CY*SZ*CX+SX*SY) / 32768
	;str r1, [r12], #4	;r13
	
	; calcul de CY*SZ*SX-SY*CX
	muls r1,r8,r2		; CY*SZ*SX
	
	muls r0,r4,r3		; SY*CX
	subs r1,r0,r1 		; CY*SZ*SX-SY*CX
	mov r10,r1,asr #15	; / 32768
	;str r1, [r12], #4	; r10
	
	; calcul de SZ
	;str r6, [r12], #4	;r6
	
	; calcul de CX*CZ
	muls r0,r3,r7
	mov r11,r0,asr #15	; / 32768
	;str r0, [r12], #4	; r11
	
	; calcul de -SX*CZ
	muls r0,r2,r7
	mov r1,#0
	sub r12,r1,r0,asr #15	; /32768
	;str r0, [r12], #4		; r12
	
	; calcul de SY*CZ
	muls r0, r4, r7
	mov r7,r0,asr #15	; / 32768
	;str r0, [r12], #4	; r7 possible
	
	; r2,r3,r4,r5,r6 : utilisés
	; r7 : dispo
	; calcul de CY*SX-SY*SZ*CX
	muls r0, r4, r6		; r0=SY*SZ
	mov r0,r0,asr #15	; / 32768
	muls r1, r5, r2		; r1 = CY*SX
	muls r8, r0, r3		; r8 = SY*SZ*CX
	subs r1, r1, r8		;  CY*SX-SY*SZ*CX
	mov r4,r1,asr #15	; / 32768
	;str r1, [r12], #4	; r4 possible
	
	; r2,r3,r5 : utilisés
	; r4,r6,r7 : dispos
	; calcul de SY*SZ*SX+CY*CX
	; r0=SY*SZ
	muls r0, r2 , r0	; SY*SZ*SX
	muls r1, r5, r3		; CY*CX
	adds r0, r1, r0		; SY*SZ*SX+CY*CX
	mov r8,r0,asr #15	; / 32768
	;str r0, [r12], #4	; r8
	
	; il faut 9 resgistres
	; r0, r1 : bloqués
	; r12,r11,r10,r9,r8 : 5
	; r12,r11,r10
	; r6 garde SZ
	; r13 : dispo
	; r14  : dispo
	
	; au final : r14 , r13 , r10 , r6 , r11 , r12 , r7 , r4 , r8
	; dispos : r0,r1,r2,r3, r5,r9
	

	ldr r0,numero_objet	; numero objet en cours
	mov r1,#all_objects
	add R1, R1, R0, LSL #3	; numero objet *8
	ldr r5,[r1],#4			; r5 = pointeur vers les points
	
	ldr r1,[r5],#4			; nb points
	
	mov r0,#coordonnees_transformees
	str r1,[r0],#4			; nb points
	
boucle_calc_points:
	str r1,nb_points_en_cours

	ldr r1,[r5],#4			; X point
	ldr r2,[r5],#4			; Y point
	ldr r3,[r5],#4			; Z point
	str r5,pointeur_en_cours_liste_points



	; calcul de X transformé
	muls r5,r1,r14			; x
	muls r9,r2,r13
	adds r5,r5,r9
	muls r9,r3,r10
	adds r5,r5,r9
	mov r5,r5,asr #8
	str r5,[r0],#4			; stock X transformé
	
	; calcul de Y transformé	
	muls r5,r1,r6			; Y
	muls r9,r2,r11
	adds r5,r5,r9
	muls r9,r3,r12
	adds r5,r5,r9
	mov r5,r5,asr #8
	str r5,[r0],#4			; stock Y transformé	
	
	; calcul de Z transformé
	muls r9,r1,r7			; Z
	muls r5,r2,r4
	adds r9,r5,r9
	muls r5,r3,r8
	adds r9,r5,r9
	
	ldr r5,distance_z
	mov r9,r9,asr #16
	subs r9,r9,r5			; r0=Z transformé
	str r9,[r0],#4			; stock Z transformé
	
	ldr r5,pointeur_en_cours_liste_points
	ldr r1,nb_points_en_cours
	subs r1,r1,#1
	bne boucle_calc_points
	

; calculs des divisons X/Z et Y/Z
	mov r9,#coordonnees_transformees
	ldr r8,[r9],#4			; r8=nb points
	mov r10,#coordonnees_projetees
	
boucle_divisions_calcpoints:
	
	ldr r11,[r9],#4			; X point
	ldr r12,[r9],#4			; Y point
	ldr r13,[r9],#4			; Z point


; si r11 négatif , 
 

	mov R5,#0
	cmp r11,#0
	bpl .cont1
; r11 négatif

	rsb r11,r11,#0
	mov r5,#1		; R5 = 1 si X negatif

.cont1:

; si r13 négatif ,	
	mov R6,#0
	cmp r13,#0
	bpl .cont2
; r13 négatif

	rsb r13,r13,#0
	mov r6,#1		; R6 = 1 si Z negatif

.cont2:

; X / Z
; R11 / R13


; division par zéro ?
	;CMP		R13, #0
	;BEQ		.divide_enddivY
	
	
	MOV      R0,#0     ;clear R0 to accumulate result
	MOV      R3,#1     ;set bit 0 in R3, which will be
					   ;shifted left then right
.startdivX:
	CMP      R13,R11
	MOVLS    R13,R13,LSL#1
	MOVLS    R3,R3,LSL#1
	BLS      .startdivX
 ;shift R13 left until it is about to
 ;be bigger than R111
 ;shift R3 left in parallel in order
 ;to flag how far we have to go

.nextdivX:
	CMP       R11,R13      ;carry set if R11&gt;R13 (don't ask why)
	SUBCS     R11,R11,R13   ;subtract R2 from R1 if this would
                      ;give a positive answer
	ADDCS     R0,R0,R3   ;and add the current bit in R3 to
                      ;the accumulating answer in R0

	MOVS      R3,R3,LSR#1     ;Shift R3 right into carry flag
	MOVCC     R13,R13,LSR#1     ;and if bit 0 of R3 was zero, also
                           ;shift R13 right
	BCC       .nextdivX            ;If carry not clear, R3 has shifted
                           ;back to where it started, and we
                           ;can end

.divide_enddivX:
; resultat dans R0


; signe ?
	eors r5,r6,r5
; 0 si + , 1 si -
	beq .contplus
; resultat est négatif
	rsb r0,r0,#0

.contplus:
; stock X projeté
	str r0,[r10],#4


;---
; Y / Z
; R12 / R13

; si r12 négatif , 
	mov R5,#0
	cmp r12,#0
	bpl .cont11
; r12 négatif

	rsb r12,r12,#0
	mov r5,#1		; R5 = 1 si Y negatif

.cont11:

	MOV      R0,#0     ;clear R0 to accumulate result
	MOV      R3,#1     ;set bit 0 in R3, which will be
					   ;shifted left then right
.startdivY:
	CMP      R13,R12
	MOVLS    R13,R13,LSL#1
	MOVLS    R3,R3,LSL#1
	BLS      .startdivY
 ;shift R13 left until it is about to
 ;be bigger than R12
 ;shift R3 left in parallel in order
 ;to flag how far we have to go

.nextdivY:
	CMP       R12,R13      ;carry set if R11&gt;R13 (don't ask why)
	SUBCS     R12,R12,R13   ;subtract R2 from R1 if this would
                      ;give a positive answer
	ADDCS     R0,R0,R3   ;and add the current bit in R3 to
                      ;the accumulating answer in R0

	MOVS      R3,R3,LSR#1     ;Shift R3 right into carry flag
	MOVCC     R13,R13,LSR#1     ;and if bit 0 of R3 was zero, also
                           ;shift R13 right
	BCC       .nextdivY            ;If carry not clear, R3 has shifted
                           ;back to where it started, and we
                           ;can end

	
	
.divide_enddivY:

; signe ?
	eors r5,r6,r5
; 0 si + , 1 si -
	beq .contplus1
; resultat est négatif
	rsb r0,r0,#0

.contplus1:
; stock Y projeté
	str r0,[r10],#4


; boucle
	subs r8,r8,#1
	bne boucle_divisions_calcpoints

; les points sont dans coordonnees_projetees
	; retour
	ldr r14,save_R14
	mov pc, r14

; breakpoint
;	swi 0x44B85
; les points sont dans coordonnees_projetees
; 

	ldr r0,numero_objet	; numero objet en cours
	mov r1,#all_objects
	add R1, R1, R0, LSL #3	; numero objet *8
	
	ldr r5,[r1,#4]			; r5 = pointeur vers les faces
	
	ldr r0,[r5],#4			; r0=nb faces
	
	mov r10,#coordonnees_projetees
	
	; il faut tester la visibilité entre les points : 1,3 et 2  ( 1,2,3,4)
	; (xa-xb)*(yc-yb) - ( (ya-yb)*(xc-xb) ) si negatif : face invisible
	; point a = 1
	; point b = 3
	; point c = 2

	ldr r11,[r5],#4		; numero point A * 8
	ldr r12,[r5],#4		; numero point B * 8
	ldr r13,[r5],#4		; numero point C * 8
	ldr r14,[r5],#4		; numero point D * 8
	
	ldr r1,[r10,r11]		; r1=XA
	ldr r3,[r10,r14]		; r3=XB
	ldr r5,[r10,r12]		; r5=XC
	
	add r6,r10,#4			; R6 = R10+4 temporaire

	ldr r2,[r6,r11]			; r2=YA
	ldr r4,[r6,r14]			; r4=YB
	ldr r6,[r6,r12]			; r6=YC
	
	subs r1,r1,r3			; r1 = xa-xb
	subs r6,r6,r4			; r6 = yc-yb
	subs r2,r2,r4			; r2 = ya-yb
	subs r5,r5,r3			; r5 = xc-xb

	muls r1,r6,r1			; r1 = (xa-xb)*(yc-yb)
	muls r2,r5,r2			; r2 = (ya-yb)*(xc-xb)
	
	subs r1,r1,r2			; (xa-xb)*(yc-yb) - (ya-yb)*(xc-xb)
	bmi face_invisible		; face visible ?
	
face_visible:
	; il faut tracer les lignes
	; essayer de garder les points deja lus
	nop
	nop
	nop
	nop
	
	; swp r1,r0
	; xor a la place

	

; breakpoint
;	swi 0x44B85


face_invisible:

	; retour
	ldr r14,save_R14
	mov pc, r14

pointeur_en_cours_liste_points:		.long 0	
nb_points_en_cours:		.long 0
distance_z:				.long 0x60



save_R14:	
	.long 0

saver14:	.long 0
saver13:	.long 0
savelr:		.long 0

matrice:
	.long	1,2,3,4,5,6,7,8,9
	
numero_objet:
	.long 0

angleX:			.long 0
angleY:			.long 0
angleZ:			.long 0
incrementX:		.long 0
incrementY:		.long 0
incrementZ:		.long 1

all_objects:	
	.long coords_cube
	.long cube

coords_cube:
	.long	8
	.long	-50,50,-50	;1
	.long	-50,-50,-50	;2
	.long	50,-50,-50	;3
	.long	50,50,-50	;4

	.long	-50,50,50	;5
	.long	-50,-50,50	;6
	.long	50,-50,50	;7
	.long	50,50,50	;8

cube:
	.long	6
	.long	0*8,1*8,2*8,3*8
	.long	0*8,3*8,7*8,4*8
	.long	3*8,2*8,6*8,7*8
	.long	0*8,4*8,5*8,1*8
	.long	7*8,6*8,5*8,4*8
	.long	2*8,1*8,5*8,6*8

coordonnees_transformees:	.space 256
coordonnees_projetees:	.space 256

SINCOS:
        .long   0, 32768,402, 32765,804, 32758,1206, 32745,1607, 32728,2009, 32706,2410, 32679,2811, 32647
        .long   3211, 32610,3611, 32568,4011, 32521,4409, 32469,4808, 32413,5205, 32351,5602, 32285,5997, 32214
        .long   6392, 32138,6786, 32057,7179, 31971,7571, 31881,7961, 31785,8351, 31685,8739, 31581,9126, 31471
        .long   9512, 31357,9896, 31237,10278, 31114,10659, 30985,11039, 30852,11416, 30714,11793, 30572,12167, 30425
        .long   12539, 30273,12910, 30117,13278, 29956,13645, 29791,14010, 29621,14372, 29447,14732, 29269,15090, 29086
        .long   15446, 28898,15800, 28707,16151, 28511,16499, 28310,16846, 28106,17189, 27897,17530, 27684,17869, 27466
        .long   18204, 27245,18537, 27020,18868, 26790,19195, 26557,19519, 26319,19841, 26077,20159, 25832,20475, 25583
        .long   20787, 25330,21097, 25073,21403, 24812,21706, 24547,22005, 24279,22301, 24007,22594, 23732,22884, 23453
        .long   23170, 23170,23453, 22884,23732, 22594,24007, 22301,24279, 22005,24547, 21706,24812, 21403,25073, 21097
        .long   25330, 20787,25583, 20475,25832, 20159,26077, 19841,26319, 19519,26557, 19195,26790, 18868,27020, 18537
        .long   27245, 18204,27466, 17869,27684, 17530,27897, 17189,28106, 16846,28310, 16499,28511, 16151,28707, 15800
        .long   28898, 15446,29086, 15090,29269, 14732,29447, 14372,29621, 14010,29791, 13645,29956, 13278,30117, 12910
        .long   30273, 12539,30425, 12167,30572, 11793,30714, 11416,30852, 11039,30985, 10659,31114, 10278,31237, 9896
        .long   31357, 9512,31471, 9126,31581, 8739,31685, 8351,31785, 7961,31881, 7571,31971, 7179,32057, 6786
        .long   32138, 6392,32214, 5997,32285, 5602,32351, 5205,32413, 4808,32469, 4409,32521, 4011,32568, 3611
        .long   32610, 3211,32647, 2811,32679, 2410,32706, 2009,32728, 1607,32745, 1206,32758, 804,32765, 402
        .long   32768, 0,32765, -402,32758, -804,32745, -1206,32728, -1607,32706, -2009,32679, -2410,32647, -2811
        .long   32610, -3211,32568, -3611,32521, -4011,32469, -4409,32413, -4808,32351, -5205,32285, -5602,32214, -5997
        .long   32138, -6392,32057, -6786,31971, -7179,31881, -7571,31785, -7961,31685, -8351,31581, -8739,31471, -9126
        .long   31357, -9512,31237, -9896,31114, -10278,30985, -10659,30852, -11039,30714, -11416,30572, -11793,30425, -12167
        .long   30273, -12539,30117, -12910,29956, -13278,29791, -13645,29621, -14010,29447, -14372,29269, -14732,29086, -15090
        .long   28898, -15446,28707, -15800,28511, -16151,28310, -16499,28106, -16846,27897, -17189,27684, -17530,27466, -17869
        .long   27245, -18204,27020, -18537,26790, -18868,26557, -19195,26319, -19519,26077, -19841,25832, -20159,25583, -20475
        .long   25330, -20787,25073, -21097,24812, -21403,24547, -21706,24279, -22005,24007, -22301,23732, -22594,23453, -22884
        .long   23170, -23170,22884, -23453,22594, -23732,22301, -24007,22005, -24279,21706, -24547,21403, -24812,21097, -25073
        .long   20787, -25330,20475, -25583,20159, -25832,19841, -26077,19519, -26319,19195, -26557,18868, -26790,18537, -27020
        .long   18204, -27245,17869, -27466,17530, -27684,17189, -27897,16846, -28106,16499, -28310,16151, -28511,15800, -28707
        .long   15446, -28898,15090, -29086,14732, -29269,14372, -29447,14010, -29621,13645, -29791,13278, -29956,12910, -30117
        .long   12539, -30273,12167, -30425,11793, -30572,11416, -30714,11039, -30852,10659, -30985,10278, -31114,9896, -31237
        .long   9512, -31357,9126, -31471,8739, -31581,8351, -31685,7961, -31785,7571, -31881,7179, -31971,6786, -32057
        .long   6392, -32138,5997, -32214,5602, -32285,5205, -32351,4808, -32413,4409, -32469,4011, -32521,3611, -32568
        .long   3211, -32610,2811, -32647,2410, -32679,2009, -32706,1607, -32728,1206, -32745,804, -32758,402, -32765
        .long   0, -32768,-402, -32765,-804, -32758,-1206, -32745,-1607, -32728,-2009, -32706,-2410, -32679,-2811, -32647
        .long   -3211, -32610,-3611, -32568,-4011, -32521,-4409, -32469,-4808, -32413,-5205, -32351,-5602, -32285,-5997, -32214
        .long   -6392, -32138,-6786, -32057,-7179, -31971,-7571, -31881,-7961, -31785,-8351, -31685,-8739, -31581,-9126, -31471
        .long   -9512, -31357,-9896, -31237,-10278, -31114,-10659, -30985,-11039, -30852,-11416, -30714,-11793, -30572,-12167, -30425
        .long   -12539, -30273,-12910, -30117,-13278, -29956,-13645, -29791,-14010, -29621,-14372, -29447,-14732, -29269,-15090, -29086
        .long   -15446, -28898,-15800, -28707,-16151, -28511,-16499, -28310,-16846, -28106,-17189, -27897,-17530, -27684,-17869, -27466
        .long   -18204, -27245,-18537, -27020,-18868, -26790,-19195, -26557,-19519, -26319,-19841, -26077,-20159, -25832,-20475, -25583
        .long   -20787, -25330,-21097, -25073,-21403, -24812,-21706, -24547,-22005, -24279,-22301, -24007,-22594, -23732,-22884, -23453
        .long   -23170, -23170,-23453, -22884,-23732, -22594,-24007, -22301,-24279, -22005,-24547, -21706,-24812, -21403,-25073, -21097
        .long   -25330, -20787,-25583, -20475,-25832, -20159,-26077, -19841,-26319, -19519,-26557, -19195,-26790, -18868,-27020, -18537
        .long   -27245, -18204,-27466, -17869,-27684, -17530,-27897, -17189,-28106, -16846,-28310, -16499,-28511, -16151,-28707, -15800
        .long   -28898, -15446,-29086, -15090,-29269, -14732,-29447, -14372,-29621, -14010,-29791, -13645,-29956, -13278,-30117, -12910
        .long   -30273, -12539,-30425, -12167,-30572, -11793,-30714, -11416,-30852, -11039,-30985, -10659,-31114, -10278,-31237, -9896
        .long   -31357, -9512,-31471, -9126,-31581, -8739,-31685, -8351,-31785, -7961,-31881, -7571,-31971, -7179,-32057, -6786
        .long   -32138, -6392,-32214, -5997,-32285, -5602,-32351, -5205,-32413, -4808,-32469, -4409,-32521, -4011,-32568, -3611
        .long   -32610, -3211,-32647, -2811,-32679, -2410,-32706, -2009,-32728, -1607,-32745, -1206,-32758, -804,-32765, -402
        .long   -32768, 0,-32765, 402,-32758, 804,-32745, 1206,-32728, 1607,-32706, 2009,-32679, 2410,-32647, 2811
        .long   -32610, 3211,-32568, 3611,-32521, 4011,-32469, 4409,-32413, 4808,-32351, 5205,-32285, 5602,-32214, 5997
        .long   -32138, 6392,-32057, 6786,-31971, 7179,-31881, 7571,-31785, 7961,-31685, 8351,-31581, 8739,-31471, 9126
        .long   -31357, 9512,-31237, 9896,-31114, 10278,-30985, 10659,-30852, 11039,-30714, 11416,-30572, 11793,-30425, 12167
        .long   -30273, 12539,-30117, 12910,-29956, 13278,-29791, 13645,-29621, 14010,-29447, 14372,-29269, 14732,-29086, 15090
        .long   -28898, 15446,-28707, 15800,-28511, 16151,-28310, 16499,-28106, 16846,-27897, 17189,-27684, 17530,-27466, 17869
        .long   -27245, 18204,-27020, 18537,-26790, 18868,-26557, 19195,-26319, 19519,-26077, 19841,-25832, 20159,-25583, 20475
        .long   -25330, 20787,-25073, 21097,-24812, 21403,-24547, 21706,-24279, 22005,-24007, 22301,-23732, 22594,-23453, 22884
        .long   -23170, 23170,-22884, 23453,-22594, 23732,-22301, 24007,-22005, 24279,-21706, 24547,-21403, 24812,-21097, 25073
        .long   -20787, 25330,-20475, 25583,-20159, 25832,-19841, 26077,-19519, 26319,-19195, 26557,-18868, 26790,-18537, 27020
        .long   -18204, 27245,-17869, 27466,-17530, 27684,-17189, 27897,-16846, 28106,-16499, 28310,-16151, 28511,-15800, 28707
        .long   -15446, 28898,-15090, 29086,-14732, 29269,-14372, 29447,-14010, 29621,-13645, 29791,-13278, 29956,-12910, 30117
        .long   -12539, 30273,-12167, 30425,-11793, 30572,-11416, 30714,-11039, 30852,-10659, 30985,-10278, 31114,-9896, 31237
        .long   -9512, 31357,-9126, 31471,-8739, 31581,-8351, 31685,-7961, 31785,-7571, 31881,-7179, 31971,-6786, 32057
        .long   -6392, 32138,-5997, 32214,-5602, 32285,-5205, 32351,-4808, 32413,-4409, 32469,-4011, 32521,-3611, 32568
        .long   -3211, 32610,-2811, 32647,-2410, 32679,-2009, 32706,-1607, 32728,-1206, 32745,-804, 32758,-402, 32765




