; remplissage :
;	- petites lignes, and entre les bords
;	- bords + centre
;	- tenir compte des multiples de 16 octets

; améliorer remplissage petites lignes
; jump dans repetition calcul gauche/droit
; CLS limité à zone max - zone min nouvelement calculée
; - tableaux x gauches et droits, directement en adresse video ?
; - remplissage normal
; - remplissage optimisé avec stm sur les multiples de 4 : a gauche, sur 16 octets, puis centre, puis droite, sur 16 octets

; cercles
; ellipses

; OK : ne plus utiliser la pile dans la vbl
; OK : la vbl compte juste le nb de frame
; OK : la boucle principale attend la vbl
; OK : modif du pointeur ecran en supervisor dans la boucle principale
; OK - revoir le cls, pour multiple de 4 doubles mots
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
.equ	IKey_Escape, 0x9d

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
	eor		r3,r3,r4		; swap r3,r4 
	eor		r4,r3,r4
	eor		r3,r3,r4
	str		r3,screenaddr1
	str		r4,screenaddr2

	ldr		r3,screenaddr1_MEMC
	ldr		r4,screenaddr2_MEMC
	eor		r3,r3,r4		; swap r3,r4 
	eor		r4,r3,r4
	eor		r3,r3,r4
	str		r3,screenaddr1_MEMC
	str		r4,screenaddr2_MEMC

; change border color
	mov   r0,#0x3400000               
	mov   r1,#1000                  
	orr   r1,r1,#0x40000000            
	SWI 22
	MOVNV R0,R0            
	str   r1,[r0]                     
	teqp  r15,#0                     
	mov   r0,r0    


	;ldr	r0,screenaddr1
	;add r0,r0,#320
	;str r0,screenaddr1

	bl	cls_ecran_actuel
	
	; change border color
	mov   r0,#0x3400000               
	mov   r1,#10000                  
	orr   r1,r1,#0x40000000            
	SWI 22
	MOVNV R0,R0            
	str   r1,[r0]                     
	teqp  r15,#0                     
	mov   r0,r0  
	

	bl	calc3D
	
		; change border color
	mov   r0,#0x3400000               
	mov   r1,#100000                  
	orr   r1,r1,#0x40000000            
	SWI 22
	MOVNV R0,R0            
	str   r1,[r0]                     
	teqp  r15,#0                     
	mov   r0,r0  
	
	

	bl	affiche_OBJ


	
	

	
	

; change border color
	mov   r0,#0x3400000               
	mov   r1,#111000                  
	orr   r1,r1,#0x40000000            
	SWI 22
	MOVNV R0,R0            
	str   r1,[r0]                     
	teqp  r15,#0                     
	mov   r0,r0    

	; exit if SPACE is pressed
	MOV r0, #OSByte_ReadKey
	MOV r1, #IKey_Escape
	MOV r2, #0xff
	SWI OS_Byte
	
	CMP r1, #0xff
	CMPEQ r2, #0xff
	BEQ exit

; change border color
	mov   r0,#0x3400000               
	mov   r1,#000                  
	orr   r1,r1,#0x40000000            
	SWI 22
	MOVNV R0,R0            
	str   r1,[r0]                     
	teqp  r15,#0                     
	mov   r0,r0  


	b	boucle
	
;	LDR r0, vsync_count
;	cmp r0,#500
;	bne boucle

exit:

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


;#{ 
;-----------------------------------------------------------------------------------------

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
		
		mov		r13,#1
		cmp		r2,r1		; X2 > X1 ?
		rsblt	r13,r13,#0		
		
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
		adds r1,r1,r13				; on incremente x
					
		subs r5,r5,r7				; on avance e
		;addlt r3,r3,r13			; on incremente y si lower than
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
		
		mov		r13,#1
		cmp		r2,r1		; X2 > X1 ?
		rsblt	r13,r13,#0
		
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
		addlt r9,r9,r13				; on incremente pointeur ecran de 1 si x+1
		addlt r7,r7,r6				; on incremente e=e +dx  si lower than
		
		
		; x1<x2 ?
		cmp r3,r4
		ble .boucledrawligne2
		
		
		mov pc, r14
		
;-----------------------------------------------------------------------------------------		


x1:		.long		160
y1:		.long		0
x2:		.long		319
y2:		.long		25

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

;#}

vsync_count:	.long 0
last_vsync:		.long -1


	
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
	mov		r14,#50
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
	
;12*4 = 48
; 320*256 = 81 920

.boucleCLS:
	.rept	34
	stmia	r0!,{r1-r12}
	.endr
	subs	r14,r14,#1
	bne		.boucleCLS
;81408
	.rept	6
	stmia	r0!,{r1-r12}
	.endr
	
	stmia	r0!,{r1-r8}
	
	ldr		r15,saver14
	
debug_string:
	.skip 12
	
screenaddr1:	.long 0
screenaddr2:	.long 0
screenaddr1_MEMC:	.long 0
screenaddr2_MEMC:	.long 0


;#{
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

	;swi 0x44B85
	
	; calcul de CY*SZ*SX-SY*CX
	muls r1,r8,r2		; CY*SZ*SX
	
	muls r0,r4,r3		; r0=SY*CX
	subs r1,r1,r0 		; CY*SZ*SX-SY*CX
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
	
;matrice transformation : r14 , r13 , r12 , r11 , r10 , r8, r7 , r6, r4
; reste : rien
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

;finbloc
;#}

;----------------------------------------------------------------------------------------------------------------

nb_faces_restantes:		.long	0

; les points sont dans coordonnees_projetees
; 
affiche_OBJ:
		str r14,save_R14
; breakpoint
	;swi 0x44B85


	ldr r0,numero_objet	; numero objet en cours
	mov r1,#all_objects
	add R1, R1, R0, LSL #3	; numero objet *8
	
	ldr r5,[r1,#4]			; r5 = r1 + 4 : pointeur vers les faces
	
	ldr r0,[r5],#4			; r0=nb faces

boucle_affiche_OBJ:

	
	str		R5,saver5
	str		R0,nb_faces_restantes
	
	ldr 	R0,[r5],#4			; r0=nb de cotés de la face
	ldr		R11,[R5],#4			; couleur de la face 
	str		R11,couleur_de_la_face
	
	
	mov r10,#coordonnees_projetees
	
	; il faut tester la visibilité entre les points : 1,3 et 2  ( 1,2,3,4)
	; (xa-xb)*(yc-yb) - ( (ya-yb)*(xc-xb) ) si negatif : face invisible
	; point a = 1
	; point b = 3
	; point c = 2

	ldr r11,[r5]			; numero point A * 8
	ldr r12,[r5,#4]			; numero point C * 8
	ldr r13,[r5,#8]			; numero point B * 8
	
	ldr r1,[r10,r11]		; r1=XA
	ldr r3,[r10,r13]		; r3=XB
	ldr r7,[r10,r12]		; r7=XC
	
	add r6,r10,#4			; R6 = R10+4 temporaire

	ldr r2,[r6,r11]			; r2=YA
	ldr r4,[r6,r13]			; r4=YB
	ldr r6,[r6,r12]			; r6=YC
	
	subs r1,r1,r3			; r1 = xa-xb
	subs r6,r6,r4			; r6 = yc-yb
	subs r2,r2,r4			; r2 = ya-yb
	subs r7,r7,r3			; r7 = xc-xb

	muls r1,r6,r1			; r1 = (xa-xb)*(yc-yb)
	muls r2,r7,r2			; r2 = (ya-yb)*(xc-xb)
	
	subs r1,r1,r2			; (xa-xb)*(yc-yb) - (ya-yb)*(xc-xb)
	bpl face_invisible		; face visible ?
	; bmi ? bpl ?
	
face_visible:
	; il faut tracer les lignes

	
	
	
; calcul point gauche ou droite
; registres:
; R0 : nb faces
; R1 : X , partie entiere
; R2 : X , partie virgule
; R3 : increment, partie entiere
; R4 : increment partie virgule
; R5 : source numéros des points / structure
; R6 : Y max pour cette face
; R10 : coordonnees_projetees
; R11 : Y min pour cette face
; R12 : destination memoire X

; R7 , R8 , R9 : pour les calculs
; R13 , R14 dispos

; - recuperer les numéros de 2 points
; - recuperer X1,Y1 et X2,Y2
; - tester ligne verticale
; - tester ligne horizontale
; pour calculer la pente, DX et DY , 

; xmax, xmin, ymax, ymin ? 4 registres


	mov		r11,#512		; Y min
	mov		r6,#0			; Y max
	


.boucle_calcul_bords_face:



	mov		r12,#tableau_des_X_gauche

	ldr 	r13,[r5],#4			; numero point 1 * 8
	ldr		r14,[r5]			; numero point 2 * 8
	
	
	ldr		r1,[r13,r10]			; X1
	ldr		r3,[r14,r10]			; X2
	
	add		r4,r10,#4				; on saute les X

	ldr		r2,[r13,r4]			; Y1
	ldr		r4,[r14,r4]			; Y2
	
; centrage
	adds	r1,r1,#160			; centrage X1
	adds	r3,r3,#160			; centrage X2
	adds	r2,r2,#128			; centrage Y1
	adds	r4,r4,#128			; centrage Y2

	
	cmp		r4,r2
	beq		.sortie				; ligne horizontale
	bgt		.YBsupYA

; breakpoint
;	swi 0x44B85

; echange les 2 points
	eor		r1,r1,r3		; swap r1,r3 ( x1,x2)
	eor		r3,r1,r3
	eor		r1,r1,r3
	eor		r2,r2,r4		; swap r2,r4 ( y1,y2)
	eor		r4,r2,r4
	eor		r2,r2,r4

; Y1 > Y2 => ligne à droite remontante
; on bascule sur les X droite	
	add		r12,r12,#1024
	


.YBsupYA:
; mise à jour Y min
		cmp		R11,R2
		ble		.pas_mise_a_jour_Y_min

		mov		R11,R2			; Y min = Y1

.pas_mise_a_jour_Y_min:
; mise à jour Y max
		cmp		R6,R4
		bge		.pas_mise_a_jour_Y_max

		mov		R6,R4			; Y max = Y2

.pas_mise_a_jour_Y_max:

; il faut calculer DX/DY
; avec virgule
; x maxi 320 : 9 bits
; y maxi 200
; on a 32 bits



	; ptr destination des X : + YA *4
	add		R12,R12,R2, asl #2
	

	mov		R9,#0
	subs	r3,r3,r1		; r3 = Delta X
	;beq		.vertline		; ligne verticale car x1=x2

	; tester si R3 Delta X negatif, R9=1, R3=-R3 et inverser en sortant

	bpl 	.0002
; r3 négatif

	rsb 	r3,r3,#0	
	mov 	R9,#1		; R9 = 1 si Delta X negatif
.0002:
	
	subs	r4,r4,r2		; r4 = Delta Y
	mov		R13,R4			; R13 = Delta Y

	mov		r3,r3,asl #16	; Delta X * 65536



	
; il faut diviser R3 (Delta X ) par R4 ( Delta Y )
; division = 2 registres écrasés : R7 R8 
	
; R7 = R3 / R14
	MOV      R7,#0
	MOV      R8,#1

.startdivX1:
	CMP      R4,R3
	MOVLS    R4,R4,LSL#1
	MOVLS    R8,R8,LSL#1
	BLS      .startdivX1


.nextdivX1:
	CMP       R3,R4
	SUBCS     R3,R3,R4
                     
	ADDCS     R7,R7,R8

	MOVS      R8,R8,LSR#1
	MOVCC     R4,R4,LSR#1
	BCC       .nextdivX1

.divide_enddivX1:

; resultat dans R7
; R7 = resultat * 65536 






	cmp		R9,#0
	beq		Delta_X_positif
	;	delta X était négatif, resultat négatif
	rsb 	r7,r7,#0
	;rsb		r3,r3,#0			; on garde la partie entiere de l'increment en positif vu qu'on va faire un sub
	;rsb		R4,R4,#0			; - increment virgule

Delta_X_positif:
	mov		R2,#32768			; X virgule= 0.5
	mov		R1,R1,asl #16		; X actuel * 65536
	add		R1,R1,R2			; X+0.5

; R1 = (X entier +0.5 )* 65536
	
	


boucle_increment_pente:
; nb octets : 12 octets par calcul
	mov		R4,R1,asr #16		; X / 65536
	str		R4,[R12],#4			; on stocke X	
	adds	R1,R1,R7			; X=X + DX/DY ( entier + virgule)
	
	subs	R13,R13,#1			; Delta Y - 1
	bge		boucle_increment_pente


.sortie:
; on a calculé les bords d'un coté
	

	subs	R0,R0,#1
	bgt		.boucle_calcul_bords_face

; en sortie :
; R6 : Y max pour cette face
; R11 : Y min pour cette face

;-------------------------------------------------------------------------------------------------------------------------
;
;              Remplissage
;
;-------------------------------------------------------------------------------------------------------------------------


; remplir une face
; dans #tableau_des_X_gauche et #tableau_des_X_droite
; de R11 * 4 à R6 * 4
; lire XGAUCHE et XDROITE
;

		; change border color
	mov   r0,#0x3400000               
	mov   r1,#10                  
	orr   r1,r1,#0x40000000            
	SWI 22
	MOVNV R0,R0            
	str   r1,[r0]                     
	teqp  r15,#0                     
	mov   r0,r0  



;- recuperer X gauche
;- recuperer X droite
;- positionner destination ecran sur Y min
;- and X gauche, # 0b111111100 : on garde entre 512 et 320 modulo 4
;- and Y gauche, # 0b111111100 : on garde entre 512 et 320 modulo 4
;- and X gauche , #0b11
;- and X droite, #0b11
;- X droite - X gauche 
;- si 0 = petite ligne
;- petite ligne : 
; 		- masque G and masque D
;		- or sur l'ecran 		
; 		ou alors 2 strb ???
; 
;  ---------------------------------------> reflechir si bord gauche puis bord droit puis centre avec plein de registres
;
; R0 = masque #0x000F
; R1,R2,R3,R4 = couleur
; R5 = masque #0xFFF0
; R7 = nb lignes à remplir
; R8 = source X gauche
; R9 = source X droite
; R13 = destination ecran Y min
; R14 = destination ecran Y min en cours + x gauche 

; R6 = ((XD - XG) and #0xFFF0 ) lsr # 2 ( /4 )
; R10 = 
; R11 = (XG and #0x000F ) lsl #2
; R12 = ( XD and #0x000F ) lsl #2
 


	mov		R8,#tableau_des_X_gauche
	
	add		R8, R8, R11, asl #2			; points gauche = tableau_des_X_gauche + Y min * 4
	add		R9,R8,#1024					; R13 = tableau des X droites + Y min * 4



	sub		R7,R6,R11				; nb lignes = Y max - Y min
	
	

	ldr		r13,screenaddr1
	; on ajoute y debut
	mov		r1,#table320
	mov		r2,r11,lsl #2		; R2 = y min * 4
	ldr		r2,[r1,r2]				; r2=y min * 320
	add		r13,r2,r13			; pointeur ecran + y*320
		
	ldr		r1,couleur_de_la_face			; couleur dans 4 registres
	mov		r2,r1
	mov		r3,r1
	mov		r4,r1

	mov		R5,#0xFFFFFFF0			; masque sur 16

boucle_remplissage_avec_sauts:

	swi 0x44B85	
	
	ldr		R11,[R8],#4			; X Gauche
	ldr		R12,[R9],#4			; X Droite



	
;	mov		R11,#31
;	mov		R12,#32





; il faut calculer:
;   X droite and 0x0F dans R12
;   delta X and 0xFFF0 dans R6
;   delta X - -   dans R11

	and		R0,R12,R5			; X droite and 0xFFF0
	subs	R6,R0,R11			; Delta X : XD - XG

	ands	R10,R6,R5				; on élimine les bits 0x0F des valeurs 0-15
	ble		remplisage_petite_ligne		; ligne inferieure à 16 pixels
	add		R14,R11,R13			; pointeur ecran + X gauche

; on peut réutiliser R11
	mov		R0,#0x000F			; masque 0-15
	and		R12,R12,R0			; X droite and 0x0F

	sub		R11,R6,R10			; nb pixels à afficher - nb pixels milieu
	
	

; j'ai besoin de :
; nb pixels gauche : R11
; nb pixels milieu : R10
; nb pixels droite : R12

	mov		R6,#fin_milieu			; pointeur sur les routines de milieu
	sub		R6,R6,R10,lsr #2		; /4 

	mov		R10,#table_gauche
	ldr		R11,[R10,R11, lsl #2]	; table gauche + 4* x gauche masqué 0x0F
	mov		R15,R11				; on saute à R11
	
	
	

remplisage_petite_ligne:
; j'arrive avec:
; R6 = X droite - X gauche = nb points à remplir
; R0 = X droite and 0xFFF0
	add		R14,R11,R13			; pointeur ecran + X gauche


	subs	R6,R12,R11			; nb points total à afficher
	beq		droite1

	mov		R0,#0x000F			; masque 0-15
	and		R12,R12,R0			; X droite and 0x0F

	sub		R0,R6,R12			; nb points a gauche
	mov		R10,#table_gauche
	ldr		R0,[R10,R0, lsl #2]	; table gauche + 4* x gauche masqué 0x0F

; pour le coté droite
	add		R11,R10,#64				; table routine droite
	ldr		R6,[R11,R12, lsl #2]	; table droite + 4* x  droite masqué 0x0F

; R6 = destination routine de droite	
	
	mov		R15,R0				; saut 
	
couleur_de_la_face:		.long 	0
	.align	8



saut_petit:
	.rept	32
	strb	r1,[R14],#1
	.endr
saut_petit_bas:
	b		suite_remplissage


table_gauche:
	.long	gauche0
	.long	gauche1
	.long	gauche2
	.long	gauche3
	.long	gauche4
	.long	gauche5
	.long	gauche6
	.long	gauche7
	.long	gauche8
	.long	gauche9
	.long	gauche10
	.long	gauche11
	.long	gauche12
	.long	gauche13
	.long	gauche14
	.long	gauche15
table_droite:
	.long	droite1
	.long	droite2
	.long	droite3
	.long	droite4
	.long	droite5
	.long	droite6
	.long	droite7
	.long	droite8
	.long	droite9
	.long	droite10
	.long	droite11
	.long	droite12
	.long	droite13
	.long	droite14
	.long	droite15
	.long	droite16
	

; sur 16 pixels
gauche0:
	mov		R15,R6
gauche1:
	strb	r1,[R14],#1
	mov		R15,R6
gauche2:
	strb	r2,[R14],#1
	strb	r2,[R14],#1
	mov		R15,R6
gauche3:
	strb	r2,[R14],#1
	strb	r2,[R14],#1
	strb	r2,[R14],#1
	mov		R15,R6
gauche4:
	str		R1,[R14],#4
	mov		R15,R6
gauche5:
	strb	r1,[R14],#1
	str		R1,[R14],#4
	mov		R15,R6
gauche6:
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	str		R1,[R14],#4
	mov		R15,R6
gauche7:
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	str		R1,[R14],#4
	mov		R15,R6
gauche8:
	stmia	R14!,{r3-r4}
	mov		R15,R6
gauche9:
	strb	r1,[R14],#1
	stmia	R14!,{r3-r4}
	mov		R15,R6
gauche10:
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	stmia	R14!,{r3-r4}
	mov		R15,R6
gauche11:
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	stmia	R14!,{r3-r4}
	mov		R15,R6
gauche12:
	stmia	R14!,{r1-r3}
	mov		R15,R6
gauche13:
	strb	r1,[R14],#1
	stmia	R14!,{r1-r3}
	mov		R15,R6
gauche14:
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	stmia	R14!,{r1-r3}
	mov		R15,R6
gauche15:
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	stmia	R14!,{r1-r3}
	mov		R15,R6


droite16:
	stmia	R14!,{r1-r4}
	b		suite_remplissage
droite1:
	strb	r1,[R14],#1
	b		suite_remplissage
droite2:
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	b		suite_remplissage
droite3:
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	b		suite_remplissage
droite4:
	str		R1,[R14],#4
	b		suite_remplissage
droite5:
	str		R1,[R14],#4
	strb	r1,[R14],#1
	b		suite_remplissage
droite6:
	str		R1,[R14],#4
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	b		suite_remplissage
droite7:
	str		R1,[R14],#4
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	b		suite_remplissage
droite8:
	stmia	R14!,{r1-r2}
	b		suite_remplissage
droite9:
	stmia	R14!,{r1-r2}
	strb	r1,[R14],#1
	b		suite_remplissage
droite10:
	stmia	R14!,{r1-r2}
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	b		suite_remplissage
droite11:
	stmia	R14!,{r1-r2}
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	b		suite_remplissage
droite12:
	stmia	R14!,{r1-r3}
	b		suite_remplissage
droite13:
	stmia	R14!,{r1-r3}
	strb	r1,[R14],#1
	b		suite_remplissage
droite14:
	stmia	R14!,{r1-r3}
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	b		suite_remplissage
droite15:
	stmia	R14!,{r1-r3}
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	strb	r1,[R14],#1
	b		suite_remplissage
	

milieu:
	.rept		20
	stmia	R14!,{r1-r4}		; 4 octets
	.endr
fin_milieu:

; gerer coté droite !!	
; depend de :
; R12 = nb points a droite

	add		R11,R10,#64				; table routine droite
	ldr		R12,[R11,R12, lsl #2]	; table droite + 4* x  droite masqué 0x0F
	mov		R15,R12				; on saute à R11
	

; ligne suivante	
suite_remplissage:
	add		R13,R13,#320
	subs	R7,R7,#1
	bgt		boucle_remplissage_avec_sauts



	ldr		R5,saver5
	add		R5,R5,#7*4

	ldr		R0,nb_faces_restantes
	subs	R0,R0,#1
	
	bgt		boucle_affiche_OBJ

; retour
	ldr pc,save_R14
	;mov pc, r14	

face_invisible:
; breakpoint
;	swi 0x44B85

	; R0 = nb de cotés de la face
	; R5 = pointeur sur point 0 de la face

; on saute par dessus les points	
	add		R0,R0,#1
	add		R5,R5,R0, asl #2
	
	ldr		R0,nb_faces_restantes
	subs	R0,R0,#1
	
	bgt		boucle_affiche_OBJ

	; retour
	ldr pc,save_R14
	;mov pc, r14

pointeur_en_cours_liste_points:		.long 0	
nb_points_en_cours:		.long 0
distance_z:				.long 0x500

masques_gauche:
	.long	0b1111
	.long	0b0111
	.long	0b0011
	.long	0b0001
masques_droite:
	.long	0b1000
	.long	0b1100
	.long	0b1110
	.long	0b1111


save_R14:	
	.long 0

saver14:	.long 0
saver13:	.long 0
savelr:		.long 0
saver5:		.long 0
saver0:		.long 0

matrice:
	.long	1,2,3,4,5,6,7,8,9
	
numero_objet:
	.long 0

angleX:			.long 0
angleY:			.long 0
angleZ:			.long 17
incrementX:		.long 0
incrementY:		.long 0
incrementZ:		.long 0



all_objects:	
	.long coords_cube
	;.long cubelines
	.long	faces_cube
	
	.long	coords_pyramide
	.long	fpyramide

coords_cube:
	.long	8
	.long	-500,500,-500	;1
	.long	-500,-500,-500	;2
	.long	500,-500,-500	;3
	.long	500,500,-500	;4

	.long	-500,500,500	;5
	.long	-500,-500,500	;6
	.long	500,-500,500	;7
	.long	500,500,500	;8

faces_cube:
; nb faces
	.long	6
; nb de cotés de la face

	.long	4, 0x15151515, 0*8,3*8,7*8,4*8,0*8			; face dessus
	.long	4, 0x25252525, 7*8,6*8,5*8,4*8,7*8			; face avant
	.long	4, 0x05050505, 0*8,1*8,2*8,3*8,0*8			; face arrière
	
	
	.long	4, 0xE5E5E5E5, 3*8,2*8,6*8,7*8,3*8
	
	.long	4, 0xD5D5D5D5, 0*8,4*8,5*8,1*8,0*8
	.long	4, 0xB5B5B5B5 ,2*8,1*8,5*8,6*8,2*8

cubelines:
	.long	12
	.long	0*8,1*8
	.long	1*8,2*8
	.long	2*8,3*8
	.long	3*8,0*8
	.long	4*8,5*8
	.long	5*8,6*8
	.long	6*8,7*8
	.long	7*8,4*8
	.long	0*8,4*8
	.long	1*8,5*8
	.long	2*8,6*8
	.long	3*8,7*8


coords_pyramide:
	.long	13
	.long	-300,300,0
	.long	300,300,0
	.long	300,-300,0
	.long	-300,-300,0
	.long	-200,200,200
	.long	200,200,200
	.long	200,-200,200
	.long	-200,-200,200
	.long	-150,150,300
	.long	150,150,300
	.long	150,-150,300
	.long	-150,-150,300
	.long	0,0,600

fpyramide:
	.long	1
	.long	4,0x18181818, 5*8,1*8,2*8,6*8
	.long	4,0x17171717, 11*8,10*8,9*8,8*8

	.long	4,0x15151515, 4*8,5*8,6*8,7*8
	
	;INV4	0,-1,8,9,10,11
	;INV4	1,-1,0,1,2,3
	;INV3	2,-1,12,9,8
	;INV4	2,-1,5,1,0,4
	;INV3	3,-1,12,10,9
	;INV4	3,-1,6,2,1,5
	;INV3	1,-1,12,11,10	;4
	;INV4	2,-1,7,3,2,6	;4
	;INV3	3,-1,12,8,11	;4
	;INV4	1,-1,4,0,3,7	;4
	

coordonnees_transformees:	.space 256
coordonnees_projetees:	.space 256

tableau_des_X_gauche:		.space 1024
tableau_des_X_droite:		.space 1024



; table de sinus, cosinus de 1/512 * 32768 ( $8000 )
; 8 par lignes
; 64 lignes

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

	;ldr r0,numero_objet	; numero objet en cours
	mov r1,#all_objects
	add R1, R1, R0, LSL #3	; numero objet *8
	
	ldr r5,[r1,#4]			; r5 = pointeur vers les faces
	
	ldr r0,[r5],#4			; r0=nb faces


.boucle_draw_lines_objet:	
	mov r10,#coordonnees_projetees

	ldr r11,[r5],#4		; numero point A * 8
	ldr r12,[r5],#4		; numero point B * 8
	
	ldr r1,[r10,r11]		; r1=XA
	ldr r2,[r10,r12]		; r3=XB
	
	add r10,r10,#4			; R6 = R10+4 temporaire

	ldr r3,[r10,r11]			; r2=YA
	ldr r4,[r10,r12]			; r4=YB	

	adds	r1,r1,#160
	adds	r2,r2,#160
	adds	r3,r3,#128
	adds	r4,r4,#128

	str		r0,saver0_2
	str		r5,saver5_2

	bl	drawline

	ldr		r5,saver5_2
	ldr		r0,saver0_2
	subs	r0,r0,#1
	bgt		.boucle_draw_lines_objet


saver0_2:	.long 0
saver5_2:	.long 0

