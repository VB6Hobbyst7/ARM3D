; => tout faire tourner en superviseur !

; -OK: calculs 3D
; -OK: tri quicksort / comparer bubble sort
; - faire 1 objet avec beaucoup de points
; -OK: programme C pour convertir png en format Archi, avec palette Archi 256 couleurs
; -OK: afficher le sprite
; -OK: effacer
;
; en vbl : afficher les boules à partir d'une liste de points triés
; si fin de buffer ET nouveau_buffer pret => on swap
; 
; 
; point : X,Y,Z, n° sprite
;
; objet: 
;	- nb points
;	- ( N° de point * 16 ) * N
;	- pointeur vers points variables ( morceau de l'objet animé )
;
; animation : 
;     - pointeur vers objet
;     - X,Y,Z objet
;     - increment X, increment Y , increment Z
;     - increment angle X, increment angle Y , increment angle Z
;	  - angles depart X,Y,Z
;	  - nb frames rotation classique
;	  - objet de destination d'une transformation, 0 = pas de transformation
;	  - nombre étapes transformation, 0 = pas de transformation
;     - pointeur vers data animation, 0 = pas d'anim
;     - nombre d'étapes en frame, 0 = pas d'anim

;		appeller calc3D en ayant rempli
;			- pointeur_points_objet_en_cours
;			- nb_points_objet_en_cours
;			- pointeur_buffer_destination_calculs

.equ	taille_buffer_calculs, 512*32*16

.equ Screen_Mode, 13
.equ	IKey_Escape, 0x9d

.include "swis.h.asm"

	.org 0x8000
	.balign 8


main:

	

; test si assez de RAM


; superviseur
	SWI		22
	MOVNV R0,R0

	mov		R2,#debut_data
	mov		R3,#fond_de_la_memoire-debut_data
	
	ldr		R1,[R2,R3]
	mov		R0,#0x1234
	str		R0,[R1]
	ldr		R2,[R1]
	cmp		R0,R2
	beq		OK_memoire_suffisante

	teqp  r15,#0                     
	mov   r0,r0

	SWI 0x01				;swi		OS_WriteS	String
	.byte	"Not enough memory. ",0


	MOV R0,#0
	SWI OS_Exit

	
OK_memoire_suffisante:

	teqp  r15,#0                     
	mov   r0,r0

; rmload RM24
;	mov		R1,#nom_Rasterman
;	mov		R0,#01
;	swi		OS_Module

; rmload QT
;	mov		R1,#nom_QT
;	mov		R0,#01
;	swi		OS_Module

	mov		R1,#0			; stop color flashing
	mov		R0,#9
	swi		OS_Byte

	bl 		creer_table_320


	mov		R0,#debut_data
	mov		R3,#pointeur_position_dans_les_animations-debut_data
	ldr		R1,[R0,R3]			; R1 = pointeur_position_dans_les_animations
	mov		R3,#pointeur_objet_en_cours-debut_data
	ldr		R2,[R1],#4			; R2 = pointeur vers objet
	str		R2,[R0,R3]
	
	ldr		R0,[R1],#4			; X objet
	str		R0,X_objet_en_cours
	ldr		R0,[R1],#4			; Y objet
	str		R0,Y_objet_en_cours
	ldr		R0,[R1],#4			; Z objet
	str		R0,Z_objet_en_cours
	
	ldr		R0,[R1],#4			; increment X objet	
	str		R0,incrementX
	ldr		R0,[R1],#4			; increment Y objet	
	str		R0,incrementY
	ldr		R0,[R1],#4			; increment Z objet	
	str		R0,incrementZ

	ldr		R0,[R1],#4			; angle X de départ objet	 
	str		R0,angleX
	ldr		R0,[R1],#4			; angle Y de départ objet
	str		R0,angleY
	ldr		R0,[R1],#4			; angle Z de départ objet
	str		R0,angleZ

	ldr		R0,[R1],#4			; nb frames rotation classique
	
	str		R0,nb_frames_rotation_classique
	str		R0,nb_frames_total_calcul
	
	ldr		R2,pointeur_objet_en_cours
	ldr		R3,[R2],#4
	str		R3,pointeur_points_objet_en_cours
	ldr		R4,[R2],#4
	str		R4,nb_points_objet_en_cours
	str		R4,nb_sprites_en_cours_calcul




; calcul frames rotation classique


	ldr		R5,pointeur_buffer_en_cours_de_calcul
	str		R5,pointeur_actuel_buffer_en_cours_de_calcul

	ldr		R0,nb_frames_rotation_classique
	str		R0,nb_frame_en_cours

; breakpoint
;	swi 0x44B85	
boucle_calcul_frames_classiques:

	ldr		R5,pointeur_actuel_buffer_en_cours_de_calcul
	str		R5,pointeur_coordonnees_projetees


	; on appelle calc3D pour calculer une frame
	; input : 
	;	- pointeur_points_objet_en_cours = pointeur vers les points 3D X,Y,Z
	;	- nb_points_objet_en_cours = nombre de points à calculer
	;	- pointeur_coordonnees_transformees = pointeur destination du resultats des calculs

	bl		calc3D
	
	bl		bubblesort_XYZ
	
	ldr		R2,pointeur_actuel_buffer_en_cours_de_calcul
	ldr		R1,nb_points_objet_en_cours
	add		R2,R2,R1,asl #4			; + nb points * 16
	str		R2,pointeur_actuel_buffer_en_cours_de_calcul
	
	ldr		R0,nb_frame_en_cours
	subs	R0,R0,#1
	str		R0,nb_frame_en_cours
	cmp		R0,#0
	bgt		boucle_calcul_frames_classiques
	
; on swappe calcul et affichage
	ldr		R1,pointeur_buffer_en_cours_d_affichage
	ldr		R2,pointeur_buffer_en_cours_de_calcul
	str		R2,pointeur_buffer_en_cours_d_affichage
	str		R1,pointeur_buffer_en_cours_de_calcul
	
	ldr		R0,nb_sprites_en_cours_calcul
	str		R0,nb_sprites_en_cours_affichage
	
	ldr		R0,nb_frames_total_calcul
	str		R0,nb_frames_total_affichage
	str		R0,nb_frame_en_cours_affichage



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
	
	ldr		r1,screenaddr1
	ldr		r2,screenaddr2
	ldr		r3,couleur
	mov		r0,#20480/2
.clsall:
	str		r3,[r1],#4
	str		r3,[r2],#4
	subs	r0,r0,#1
	bne		.clsall
	
	ldr		r3,couleur2
	mov		r0,#20480/2
.clsall2:
	str		r3,[r1],#4
	str		r3,[r2],#4
	subs	r0,r0,#1
	bne		.clsall2
	
	
; mise en place de la palette
; change border color
	SWI		22
	MOVNV R0,R0            

	mov   r0,#0x3400000               
	mov   r1,#1000  
; border	
	orr   r1,r1,#0x40000000            
	str   r1,[r0]                     

	mov   r0,#0x3400000               
	mov   r1,#1000  
; 	couleur 15
	orr   r1,r1,#0x3C000000            
	str   r1,[r0]                     

	mov   r0,#0x3400000               
	mov   r1,#100  
; 	couleur 14
	orr   r1,r1,#0x38000000            
	str   r1,[r0]                     



	teqp  r15,#0                     
	mov   r0,r0 

	; Claim the Event vector
	mov r0, #EventV
	adr r1, event_handler
	mov r2, #0
;	swi OS_AddToVector
	swi	OS_Claim
	
	; Enable Vsync event
	mov r0, #OSByte_EventEnable
	mov r1, #Event_VSync
	SWI OS_Byte
	
	bl		set_palette



;// couleurs par le system

	ldr		r12,pointeur_sprite_boule_violette
	mov		R11,#16
	mov		r3,#0
	
; R3 = index
; R4 = RGBx word
; Uses R0,R1 
.boucle_couleurs_OS:

	ldr		R4,[R12],#4					; 0302 0000 / B=3 , G=0 , R=2
	str		R4,couleurforce
	bl		palette_set_colour
	
	add		R3,R3,#1

	subs	r11,r11,#1
	bgt		.boucle_couleurs_OS
	

	ldr		R0,nb_frames_total_affichage
	ldr		R12,pointeur_buffer_en_cours_d_affichage
	str		R0,nb_frame_en_cours_affichage
	str		R12,pointeur_actuel_buffer_en_cours_d_affichage	

	
	

boucle:
; vsync
	LDR r0, vsync_count
.bouclevsync:
	LDR r1, vsync_count
	cmp r0, r1
	beq .bouclevsync

	SWI		22
	MOVNV R0,R0            

	mov   r0,#0x3400000               
	mov   r1,#400  
; border	
	orr   r1,r1,#0x40000000            
	str   r1,[r0]                     

;Vinit = &3600000+(val>>4)<<2

	ldr	r0,screenaddr1_MEMC
	mov r0,r0,lsr #4
	mov r0,r0,lsl #2
	mov r1,#0x3600000
	add r0,r0,r1
	str r0,[r0]


	teqp  r15,#0                     
	mov   r0,r0  

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


	bl	set_palette


	bl	cls_ecran_actuel

	SWI		22
	MOVNV R0,R0            

	mov   r0,#0x3400000               
	mov   r1,#650  
; border	
	orr   r1,r1,#0x40000000            
	str   r1,[r0]                     

                    



	teqp  r15,#0                     
	mov   r0,r0 
	

; breakpoint
;	swi 0x44B85	

;	bl	bubblesort_XYZ

	SWI		22
	MOVNV R0,R0            

	mov   r0,#0x3400000               
	mov   r1,#200  
; border	
	orr   r1,r1,#0x40000000            
	str   r1,[r0]                     

                    



	teqp  r15,#0                     
	mov   r0,r0 


; affichage des sprites
; en R0=x, R1=y
	ldr		R12,pointeur_actuel_buffer_en_cours_d_affichage
	
	.rept	16
	ldr		R0,[R12],#4
	ldr		R1,[R12],#4
	add		R12,R12,#8			; saute le Z et le vide pour arrondi à 16 octets
	
	adds	R0,R0,#160
	adds	R1,R1,#128	


	bl		copie_sprite
	.endr
	


	ldr		R0,nb_frame_en_cours_affichage
	subs	R0,R0,#1
	bgt		.pas_fin_buffer_affichage
	
	ldr		R0,nb_frames_total_affichage
	ldr		R12,pointeur_buffer_en_cours_d_affichage
	
.pas_fin_buffer_affichage:
	str		R0,nb_frame_en_cours_affichage
	str		R12,pointeur_actuel_buffer_en_cours_d_affichage

	; exit if SPACE is pressed
	MOV r0, #OSByte_ReadKey
	MOV r1, #IKey_Escape
	MOV r2, #0xff
	SWI OS_Byte
	
	CMP r1, #0xff
	CMPEQ r2, #0xff
	BEQ exit

	SWI		22
	MOVNV R0,R0            

	mov   r0,#0x3400000               
	mov   r1,#000  
; border	
	orr   r1,r1,#0x40000000            
	str   r1,[r0]                     

                    



	teqp  r15,#0                     
	mov   r0,r0 



	b	boucle
	
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
;--------------------------------------------------------------------



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

set_palette:

	str lr,savelr

	SWI		22
	MOVNV R0,R0            

	ldr		r12,pointeur_sprite_boule_violette

	mov		r11,#0x00000000
	mov   	r0,#0x3400000 
	mov		R2,#16			; 16 couleurs
	
.boucle_palette:

	ldr		r1,[r12],#4		; r1=couleur format PC
	mov		r1,r1,lsr #16
	orr		r1,r1,r11		;r11 = registre en cours
	str		r1,[r0]                     
	
	add		R11,R11,#0x04000000
	
	subs	R2,R2,#1
	bgt		.boucle_palette
	
	

	teqp  r15,#0                     
	mov   r0,r0 
	
	ldr pc,savelr

	


copie_sprite:

	


	ldr		r2,screenaddr1
	add		R2,R2,R0			; R2=R2+X
	ldr		r10,pointeur_table320
	mov		r1,r1,lsl #2		; y * 4
	ldr		r8,[r10,R1]				; r8=y*320
	add		r2,r8,r2			; pointeur ecran + y*320
	
	
	ldr		r1,pointeur_sprite_boule_violette
	add		R1,R1,#16*4

	mov		r4,#16
	mov		r3,#0

.boucle_copie_sprite_ligne:
	
	mov		r0,#16
	
	
.boucle_copie_sprite_pixel:

; breakpoint
;	swi 0x44B85	


	ldrb		r3,[r1],#1
	cmp			R3,#0
	beq			.vide
	strb		r3,[r2],#1
	subs		r0,r0,#1
	bgt		.boucle_copie_sprite_pixel
	
	add		r2,r2,#320-16
	subs		r4,r4,#1
	bgt		.boucle_copie_sprite_ligne
	
	
	mov		 pc,r14
	
.vide:
	add			R2,R2,#1
	subs		r0,r0,#1
	bgt		.boucle_copie_sprite_pixel
	
	add		r2,r2,#320-16
	subs		r4,r4,#1
	bgt		.boucle_copie_sprite_ligne
	
	
	mov		 pc,r14



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

table320:	.skip		256*4
	
creer_table_320:

	ldr		r1,pointeur_table320
	mov		r0,#0
	mov		r2,#256
.boucle320:
	
	str		r0,[r1],#4
	add		r0,r0,#320
	subs	r2,r2,#1
	bgt		.boucle320
	mov pc, r14

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
; input : 
;	- pointeur_points_objet_en_cours = pointeur vers les points 3D X,Y,Z
;	- nb_points_objet_en_cours = nombre de points à calculer
;	- pointeur_coordonnees_transformees = pointeur destination du resultats des calculs

	str r14,save_R14

	; calcul de la matrice de transformation
	;mov r12,#matrice
	ldr r11,pointeur_SINCOS
	
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
	

	ldr		R5,pointeur_points_objet_en_cours			; r5 = pointeur vers les points
	ldr		R1,nb_points_objet_en_cours					; nb points
	
	ldr 	r0,pointeur_coordonnees_transformees
	;str 	r1,[r0],#4			; nb points
	
	;str		R1,nb_points_objet_en_cours
	
;matrice transformation : r14 , r13 , r12 , r11 , r10 , r8, r7 , r6, r4
; reste : rien
boucle_calc_points:
	str r1,nb_points_en_cours

	ldr r1,[r5],#4			; X point
	ldr r2,[r5],#4			; Y point
	ldr r3,[r5],#4			; Z point
	str r5,pointeur_en_cours_liste_points
	
	ldr		R5,X_objet_en_cours
	adds	R1,R1,R5		; X point + X objet
	ldr		R5,Y_objet_en_cours
	adds	R2,R2,R5		; Y point + Y objet
	ldr		R5,Z_objet_en_cours
	adds	R3,R3,R5		; Z point + Z objet



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
	ldr r9,pointeur_coordonnees_transformees
	ldr r8,nb_points_objet_en_cours			; r8=nb points
	ldr r10,pointeur_coordonnees_projetees
	
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
	
; stock Z pour tri
	str R13,[r10],#4
	
	; pour multiple de 16 octets
	add		R10,R10,#4

; boucle
	subs r8,r8,#1
	bne boucle_divisions_calcpoints

; les points sont dans coordonnees_projetees
	; retour
	ldr r14,save_R14
	mov pc, r14

pointeur_en_cours_liste_points:		.long 0	
nb_points_en_cours:		.long 0
distance_z:				.long 0x400

save_R14:	
	.long 0


matrice:
	.long	1,2,3,4,5,6,7,8,9
	
numero_objet:
	.long 0

angleX:			.long 0
angleY:			.long 0
angleZ:			.long 0
incrementX:		.long 0
incrementY:		.long 0
incrementZ:		.long 2

X_objet_en_cours:		.long 0
Y_objet_en_cours:		.long 0
Z_objet_en_cours:		.long 0


all_objects:	
	.long coords_cube





bubblesort_XYZ:
; X Y Z => 3 * 4 = 12 octets
	ldr		R11,pointeur_coordonnees_projetees			; R11 = X
	add		R10,R11,#4							; R10 = Y
	add		R0,R10,#4							; R0 = Z
	ldr		R1,nb_points_objet_en_cours

bsort_next:                     ;// Check for a sorted array
    MOV     R2,#0               ;// R2 = Current Element Number
    MOV     R6,#0               ;// R6 = Number of swaps
bsort_loop:                     ;// Start loop
    ADD     R3,R2,#1            ;// R3 = Next Element Number
    CMP     R3,R1               ;// Check for the end of the array
    BGE     bsort_check         ;// When we reach the end, check for changes
    LDR     R4,[R0,R2,LSL #4]   ;// R4 = Current Element Value
    LDR     R5,[R0,R3,LSL #4]   ;// R5 = Next Element Value
    CMP     R5,R4               ;// Compare element values

    STRGT   R5,[R0,R2,LSL #4]   ;// If R4 > R5, store current value at next
    STRGT   R4,[R0,R3,LSL #4]   ;// If R4 > R5, Store next value at current
	
	LDRGT   R8,[R11,R2,LSL #4]	; X1
	LDRGT   R9,[R11,R3,LSL #4]	; X2
	STRGT   R9,[R11,R2,LSL #4]   ;// If R4 > R5, store current value at next
    STRGT   R8,[R11,R3,LSL #4]   ;// If R4 > R5, Store next value at current

	LDRGT   R8,[R10,R2,LSL #4]	; Y1
	LDRGT   R9,[R10,R3,LSL #4]	; Y2
	STRGT   R9,[R10,R2,LSL #4]   ;// If R4 > R5, store current value at next
    STRGT   R8,[R10,R3,LSL #4]   ;// If R4 > R5, Store next value at current
	
    ADDGT   R6,R6,#1            ;// If R4 > R5, Increment swap counter
    MOV     R2,R3               ;// Advance to the next element
    B       bsort_loop          ;// End loop
bsort_check:                    ;// Check for changes
    CMP     R6,#0               ;// Were there changes this iteration?
    SUBGT   R1,R1,#1            ;// Optimization: skip last value in next loop
    BGT     bsort_next          ;// If there were changes, do it again
bsort_done: 

	mov		pc,lr

debut_data:

.include "palette.asm"

pointeur_table320:			.long table320

vsync_count:	.long 0
last_vsync:		.long -1

screenaddr1:	.long 0
screenaddr2:	.long 0
screenaddr1_MEMC:	.long 0
screenaddr2_MEMC:	.long 0

saver14:	.long 0
saver13:	.long 0
savelr:		.long 0
saver5:		.long 0
saver0:		.long 0

couleur:	.long	0x7f7f7f7f
couleur2:	.long	0x1e1e1e1e

couleurforce:		.long		0x0F000000


pointeur_message_erreur_memoire:	.long	message_erreur_memoire



nb_frame_en_cours:					.long		0
nb_frame_en_cours_affichage:		.long		0

pointeur_actuel_buffer_en_cours_d_affichage:		.long	buffer_calcul1
pointeur_actuel_buffer_en_cours_de_calcul:			.long	buffer_calcul1+taille_buffer_calculs
pointeur_buffer_en_cours_d_affichage:		.long	buffer_calcul1
pointeur_buffer_en_cours_de_calcul:			.long	buffer_calcul1+taille_buffer_calculs
fond_de_la_memoire:							.long	buffer_calcul1+(taille_buffer_calculs*2)

nb_sprites_en_cours_affichage:			.long 0
nb_sprites_en_cours_calcul:				.long 0

pointeur_coordonnees_transformees:		.long coordonnees_transformees
pointeur_coordonnees_projetees:			.long coordonnees_projetees

pointeur_points_objet_en_cours:		.long	coords_cube
nb_points_objet_en_cours:			.long	16

pointeur_position_dans_les_animations:		.long	anim1

nb_frames_rotation_classique:				.long 0
nb_frames_total_calcul:						.long 0
nb_frames_total_affichage:					.long 0

pointeur_objet_en_cours:					.long	cube

pointeur_sprite_boule_violette:			.long sprite_boule_violette

; animation : 
;     - pointeur vers objet
;     - X,Y,Z objet
;     - increment X, increment Y , increment Z
;     - increment angle X, increment angle Y , increment angle Z
;	  - objet de destination d'une transformation, 0 = pas de transformation
;	  - nombre étapes transformation, 0 = pas de transformation
;     - pointeur vers data animation, 0 = pas d'anim
;     - nombre d'étapes en frame, 0 = pas d'anim

anim1:
		.long		cube			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		0,1,1			;     - increment angle X, increment angle Y , increment angle Z
		.long		0,0,0			; 	  - angles depart X,Y,Z
		.long		512				; 	  - nb frames rotation classique, 0 = pas de rotation classique
		.long		0				;	  - objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
		.long		0				;     - pointeur vers data animation, 0 = pas d'anim
		.long		0				;     - nombre d'étapes en frame, 0 = pas d'anim

; objet: 
;	- pointeur vers les points
;	- nb points
;	- pointeur vers points variables ( morceau de l'objet animé )
;	- nb points variables

cube:
	.long	coords_cube				; pointeur coordonnées points
	.long	16						; nb points			
	.long	0
	.long	0

; point : X,Y,Z, n° sprite	
coords_cube:
	.long	-300,500,0
	.long	-200,500,0
	.long	-100,500,0
	.long	-000,500,0
	.long	100,500,0
	.long	200,500,0
	.long	300,500,0
	.long	400,500,0
	.long	-300,100,0
	.long	-200,100,0
	.long	-100,100,0
	.long	-000,100,0
	.long	100,100,0
	.long	200,100,0
	.long	300,100,0
	.long	400,100,0
	
	
	.long	-500,500,-500	;1
	.long	-500,-500,-500	;2
	.long	500,-500,-500	;3
	.long	500,500,-500	;4

	.long	-500,500,500	;5
	.long	-500,-500,500	;6
	.long	500,-500,500	;7
	.long	500,500,500	;8
		
; table de sinus, cosinus de 1/512 * 32768 ( $8000 )
; 8 par lignes
; 64 lignes
pointeur_SINCOS:		.long SINCOS
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

sprite_boule_violette:
		.incbin		"sphere16x16pourArchi.bin"


message_erreur_memoire:		.byte	"Not enough memory.",0
nom_Rasterman:			.byte		"rm24",0
nom_QT:					.byte		"qt",0
nom_module_Rasterman:	.byte		"Rasterman",0
nom_module_QT:			.byte		"QTMTracker",0
		.balign		8
;.section bss,"u"
coordonnees_transformees:	.space 1024
coordonnees_projetees:	.space 1024
index_et_Z_pour_tri:	.space	4*256

.p2align 8
buffer_calcul1:
		.skip		512*64*16
buffer_calcul2:		
		.skip		512*64*16
