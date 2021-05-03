; !!!!!   ==============>   ajouter n° sprite apres X,Y,Z
; dans calc3D + preparation transformation + execution transformation + routine affichage sprite + bubble sort + 



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
;	  - zoom / position observateur en Z

;		appeller calc3D en ayant rempli
;			- pointeur_points_objet_en_cours
;			- nb_points_objet_en_cours
;			- pointeur_buffer_destination_calculs

; transformation
;	objet source
; 	objet destination
;	nombre d'étapes = nb etapes rotation
;	pour chaque point, (X destination - X Source) / nombre d'étapes = pas en X
;   idem Y et Z , calculer le pas en Y et Z 
;	* 2^15
;	table increments_pas_transformations : 3 * 4 *64
;

; animation:
;  calcul normal de l'objet
; deuxieme boucle pour la partie animée ?
;	- pointeur vers coordonnées des points en cours ( actualisé à chaque frame)
;	- nb points animation
;	- nb frame animation, une fois à zéro => retour au début des coordonnées des points d'animation



.equ	taille_buffer_calculs, 512*32*16

.equ Screen_Mode, 13
.equ	IKey_Escape, 0x9d

.include "swis.h.asm"

	.org 0x8000
	.balign 8


main:

	

; test si assez de RAM


; superviseur
;	SWI		22
;	MOVNV R0,R0

;	mov		R2,#debut_data
;	mov		R3,#fond_de_la_memoire-debut_data
	
;	ldr		R1,[R2,R3]
;	mov		R0,#0x1234
;	str		R0,[R1]
;	ldr		R2,[R1]
;	cmp		R0,R2
;	beq		OK_memoire_suffisante

;	teqp  r15,#0                     
;	mov   r0,r0

;	SWI 0x01				;swi		OS_WriteS	String
;	.byte	"Not enough memory. ",0


;	MOV R0,#0
;	SWI OS_Exit

	
;OK_memoire_suffisante:

;	teqp  r15,#0                     
;	mov   r0,r0

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


	mov		R0,#0
	str		R0,nb_frames_total_calcul

	ldr		R5,pointeur_buffer_en_cours_de_calcul
	str		R5,pointeur_actuel_buffer_en_cours_de_calcul


boucle_lecture_animations:
	
	mov		R1,#0
	str		R1,flag_transformation_en_cours			; pas de transformation
	str		R1,flag_animation_en_cours				; pas d'animation
	str		R1,flag_classique_en_cours				; pas d'objet classique
	

	;mov		R0,#debut_data
	;mov		R3,#pointeur_position_dans_les_animations-debut_data	
	;ldr		R1,[R0,R3]			; R1 = pointeur_position_dans_les_animations
	ldr		R1,pointeur_position_dans_les_animations
	;mov		R3,#pointeur_objet_en_cours-debut_data
	ldr		R2,[R1],#4			; R2 = pointeur vers objet
	cmp		R2,#0
	beq		sortie_boucle_animations

	str		R2,pointeur_objet_en_cours
	str		R2,pointeur_objet_source_transformation
	
	;ldr		R2,pointeur_objet_en_cours
	ldr		R3,[R2],#4								; R2 = pointeur objet, R3 = coordonnees des points de l'objet
	str		R3,pointeur_points_objet_en_cours
	str		R3,pointeur_coordonnees_objet_source_transformation
	ldr		R4,[R2],#4

; si nb points = 0 => pas d'objet classique
	cmp		R4,#0
	beq		.ok_objet_rotation_classique
	mov		R0,#1
	str		R0,flag_classique_en_cours

.ok_objet_rotation_classique:
	str		R4,nb_points_objet_en_cours_objet_classique
	str		R4,nb_sprites_en_cours_calcul
	
	
	;str		R2,[R0,R3]
	
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
	cmp		R0,#0
	blt		.pas_de_changement_de_angle_X_de_depart1
	str		R0,angleX
.pas_de_changement_de_angle_X_de_depart1:
	ldr		R0,[R1],#4			; angle Y de départ objet
	cmp		R0,#0
	blt		.pas_de_changement_de_angle_Y_de_depart1
	str		R0,angleY
.pas_de_changement_de_angle_Y_de_depart1:
	ldr		R0,[R1],#4			; angle Z de départ objet
	cmp		R0,#0
	blt		.pas_de_changement_de_angle_Z_de_depart1
	str		R0,angleZ
.pas_de_changement_de_angle_Z_de_depart1:

	ldr		R0,[R1],#4			; nb frames rotation classique

	



	str		R0,nb_frames_rotation_classique
	ldr		R2,nb_frames_total_calcul
	add		R2,R2,R0
	str		R2,nb_frames_total_calcul

; infos transformation

	ldr		R0,[R1],#4			; pointeur vers objet destination de la transformation
	cmp		R0,#0				; vide ?
	beq		pas_de_transformation
	str		R0,pointeur_coordonnees_objet_destination_transformation			; pointeur vers coordonnees objet destination de la transformation
	
	
; --------- gere la transformation ici :
	mov		R4,#0
	str		R4,numero_etape_en_cours_transformation
	
	mov		R4,#1
	str		R4,flag_transformation_en_cours			; transformation en cours  = 1
	
; le buffer de resultat des calculs de transformation devient la liste des coordonnées de l'objet
	ldr		R4,pointeur_buffer_coordonnees_objet_transformees
	str		R4,pointeur_points_objet_en_cours
	
	ldr		R4,[R1]								; nombre étapes transformation, 0 = pas de transformation	
	str		R4,nb_etapes_transformation
	
	; remplir table increments_pas_transformations ( pointeur_table increments_pas_transformations )
	; 


	
	str		R1,saveR1
	bl		preparation_transformation
	ldr		R1,saveR1
	
pas_de_transformation:


	add		R1,R1,#4			; on saute nombre étapes transformation


; --------- gere l'animation ici :

	ldr		R4,[R1],#4			; pointeur vers data animation, 0 = pas d'anim
	cmp		R4,#0
	beq		.pas_d_animation_init

	str		R4,pointeur_vers_coordonnees_points_animation_original
	str		R4,pointeur_vers_coordonnees_points_animation_en_cours
	
	ldr		R4,[R1]				; nombre de points à animer
	str		R4,nb_points_animation_en_cours_objet_anime
	str		R4,nb_points_objet_en_cours_objet_anime
	str		R4,nb_sprites_en_cours_calcul
	
	ldr		R4,[R1,#4]			;  - nombre d'étapes en frame, 0 = pas d'anim, on anime pendant N frames
	str		R4,nb_frame_animation
	str		R4,nb_frame_animation_en_cours

	mov		R4,#1
	str		R4,flag_animation_en_cours

.pas_d_animation_init:
	add		R1,R1,#8			; on saute ajout de points pour animation

; modification du Z observateur ?
	ldr		R0,[R1],#4			; Z observateur
	cmp		R0,#0
	blt		.pas_de_changement_de_Z_observateur
	str		R0,distance_z
.pas_de_changement_de_Z_observateur:
	
	
	str		R1,pointeur_position_dans_les_animations



; calcul frames rotation classique




	ldr		R0,nb_frames_rotation_classique
	str		R0,nb_frame_en_cours

boucle_calcul_frames_classiques:

;	swi		BKP

	; si transformation :
	; on calcul les points transformes dans pointeur_buffer_coordonnees_objet_transformees

	ldr		R5,flag_transformation_en_cours
	cmp		R5,#1
	bne		.pas_de_transformation
	
	bl		realisation_transformation

.pas_de_transformation:
	ldr		R5,pointeur_actuel_buffer_en_cours_de_calcul
	str		R5,pointeur_coordonnees_projetees


	; on appelle calc3D pour calculer une frame
	; input : 
	;	- pointeur_points_objet_en_cours = pointeur vers les points 3D X,Y,Z
	;	- nb_points_objet_en_cours = nombre de points à calculer
	;	- pointeur_coordonnees_transformees = pointeur destination du resultats des calculs

; ----------------------
; projection points fixes et transformés au début :

	ldr		R2,flag_classique_en_cours
	cmp		R2,#1
	bne		.pas_de_rotation_classique_en_boucle

	ldr		R2,pointeur_coordonnees_projetees
	str		R2,pointeur_coordonnees_projetees_actuel
	
	ldr		R2,nb_points_objet_en_cours_objet_classique
	str		R2,nb_points_objet_en_cours


	bl		calc3D

.pas_de_rotation_classique_en_boucle:
; ----------------------

; animation à gérer avant le tri
; on complete pointeur_coordonnees_projetees_actuel
; il faut augmenter nb_points_objet_en_cours avant le tri

	ldr		R2,flag_animation_en_cours
	cmp		R2,#0
	beq		.pas_d_animation_dans_la_boucle_de_calcul_principale
	
	ldr		R2,nb_points_objet_en_cours_objet_anime
	str		R2,nb_points_objet_en_cours

; points source = pointeur_points_objet_en_cours

	ldr		R2,nb_frame_animation_en_cours
	subs	R2,R2,#1
	bgt		.pas_fin_animation
; on revient au nombre initial d'etapes de l'animation
	ldr		R2,nb_frame_animation
	ldr		R3,pointeur_vers_coordonnees_points_animation_original
	str		R3,pointeur_vers_coordonnees_points_animation_en_cours

.pas_fin_animation:
	str		R2,nb_frame_animation_en_cours

	ldr		R2,pointeur_vers_coordonnees_points_animation_en_cours
	str		R2,pointeur_points_objet_en_cours

	ldr		R2,pointeur_coordonnees_projetees
	str		R2,pointeur_coordonnees_projetees_actuel
	

; on calcul nb_points_objet_en_cours points, venant de pointeur_points_objet_en_cours
	bl		calc3D
	
	ldr		R2,pointeur_vers_coordonnees_points_animation_en_cours
	ldr		R3,nb_points_objet_en_cours_objet_anime
	; on avance de nb points * 16
	add		R2,R2,R3,asl #4				; on avance le pointeur de coordonnees de 16 * nb points : X Y Z n° sprite
	str		R2,pointeur_vers_coordonnees_points_animation_en_cours

	ldr		R2,nb_points_objet_en_cours_objet_classique
	ldr		R3,nb_points_objet_en_cours_objet_anime
	add		R2,R2,R3										; nombre total de points
	str		R2,nb_points_objet_en_cours
	
	
.pas_d_animation_dans_la_boucle_de_calcul_principale:
	
	bl		bubblesort_XYZ
	
	ldr		R2,pointeur_actuel_buffer_en_cours_de_calcul
	ldr		R1,nb_points_objet_en_cours
	add		R2,R2,R1,asl #4			; + nb points * 16
	str		R2,pointeur_actuel_buffer_en_cours_de_calcul

; erroné :
; si transformation, il faut avancer dans la liste de points
;	pointeur_points_objet_en_cours=pointeur_points_objet_en_cours + (nb_points * 4 * 3)

;	ldr		R0,flag_transformation_en_cours
;	cmp		R0,#0
;	beq		.pas_de_transformation_dans_la_boucle_de_calcul

; breakpoint
;	swi 0x44B85	


;	ldr		R0,nb_points_objet_en_cours
;	ldr		R1,pointeur_points_objet_en_cours
;	mov		R0,R0, asl #2			; R0=nb points * 4
;	add		R0,R0,R0, asl #1		; R0 = R0*4 + R0*4 *2
;	add		R1,R0,R1			; R0 = nb points * 4 * 3
;	str		R1,pointeur_points_objet_en_cours
	

;.pas_de_transformation_dans_la_boucle_de_calcul:
	
	ldr		R0,nb_frame_en_cours
	subs	R0,R0,#1
	str		R0,nb_frame_en_cours
	cmp		R0,#0
	bgt		boucle_calcul_frames_classiques
; fin de la boucle de calcul

	b		boucle_lecture_animations

sortie_boucle_animations:
	
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
;	LDR r0, vsync_count
;.bouclevsync:
;	LDR r1, vsync_count
;	cmp r0, r1
;	beq .bouclevsync


;Vinit = &3600000+(val>>4)<<2

;	ldr	r0,screenaddr1_MEMC
;	mov r0,r0,lsr #4
;	mov r0,r0,lsl #2
;	mov r1,#0x3600000
;	add r0,r0,r1
;	str r0,[r0]


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
;    VBL
;--------------------------------------------------------------------



; R0=event number
event_handler:
	cmp r0, #Event_VSync
	movnes pc, r14

	str lr,savelr

	str r0,saver0
	
	mov		R0,#save_regs
	stmia	R0,{R1-R14}
		
; update the vsync counter

	LDR r0, vsync_count
	ADD r0, r0, #1
	STR r0, vsync_count


; changement couleur border
	mov   r0,#0x3400000               
	mov   r1,#470  
; border	
	orr   r1,r1,#0x40000000            
	str   r1,[r0]                     

; update pointeur video hardware
	ldr	r0,screenaddr1_MEMC
	mov r0,r0,lsr #4
	mov r0,r0,lsl #2
	mov r1,#0x3600000
	add r0,r0,r1
	str r0,[r0]

; swap pointeur ecrans
	ldr		r3,screenaddr1
	ldr		r4,screenaddr2
	str		r4,screenaddr1
	str		r3,screenaddr2

	ldr		r3,screenaddr1_MEMC
	ldr		r4,screenaddr2_MEMC
	str		r4,screenaddr1_MEMC
	str		r3,screenaddr2_MEMC


; // set palette

	ldr		r12,pointeur_sprite_boule_violette

	mov		r11,#0x00000000
	mov   	r0,#0x3400000 
	mov		R2,#16			; 16 couleurs
	
.boucle_palette2:

	ldr		r1,[r12],#4		; r1=couleur format PC
	mov		r1,r1,lsr #16
	orr		r1,r1,r11		;r11 = registre en cours
	str		r1,[r0]                     
	
	add		R11,R11,#0x04000000
	
	subs	R2,R2,#1
	bgt		.boucle_palette2


;	bl	cls_ecran_actuel
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


; changement couleur border
	mov   r0,#0x3400000               
	mov   r1,#47  
; border	
	orr   r1,r1,#0x40000000            
	str   r1,[r0]       

; affichage des sprites
; en R0=x, R1=y




	ldr		R12,pointeur_actuel_buffer_en_cours_d_affichage
	ldr		R11,nb_sprites_en_cours_affichage

boucle_affiche_sprites_vbl:	
	ldr		R0,[R12],#4
	ldr		R1,[R12],#4
	add		R12,R12,#8			; saute le Z et le N° de sprite pour arrondi à 16 octets
	
; 16x16
;	adds	R0,R0,#160-8
;	adds	R1,R1,#128-8

	bl		copie_sprite

	subs	R11,R11,#1
	bgt		boucle_affiche_sprites_vbl


	ldr		R0,nb_frame_en_cours_affichage
	subs	R0,R0,#1
	bgt		.pas_fin_buffer_affichage
	
	ldr		R0,nb_frames_total_affichage
	ldr		R12,pointeur_buffer_en_cours_d_affichage
	
.pas_fin_buffer_affichage:
	str		R0,nb_frame_en_cours_affichage
	str		R12,pointeur_actuel_buffer_en_cours_d_affichage

; changement couleur border
	mov   r0,#0x3400000               
	mov   r1,#000
; border	
	orr   r1,r1,#0x40000000            
	str   r1,[r0]   


	mov		R0,#save_regs
	ldmia	R0,{R1-R14}

	
	ldr r0,saver0
	
	
	ldr pc,savelr

	




;--------------------------------------------------------------------

set_palette:

	str lr,savelr

;	SWI		22
;	MOVNV R0,R0            

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
	
	

;	teqp  r15,#0                     
;	mov   r0,r0 
	
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

;--------------------------------------------------------------------
;    Transformation
;--------------------------------------------------------------------

;- dans la boucle d'initialisation des animations :
;
;	- calculer deltaX/nb etapes, delta Y / nb etapes, delta Z/nb etapes
;	- multiplier chaque valeur par 2^15
;	- stocker dans table_increments_pas_transformations : X source ,increment X, Y source, increment Y, Z source, increment Z , n° sprite : tout x 2^15
;			pointeur_table_increments_pas_transformations
; fonction : preparation_transformation:
;
;
;- dans la boucle de calcul des rotations/projections
;	- remplir pointeur_buffer_coordonnees_objet_transformees:
;		- avec calcul de table_increments_pas_transformations  : X + inc X, Y+inc Y , Z+inc Z, 
;		- stocker le resultat dans table_increments_pas_transformations +0 +8 + 16
;		- stocker le resultat / 2^15 dans pointeur_buffer_coordonnees_objet_transformees


preparation_transformation:


		ldr		R12,pointeur_table_increments_pas_transformations						; destination pour les X Y Z et increments
		ldr		R11,pointeur_coordonnees_objet_source_transformation					; points de l'objet source : X Y Z n°sprite
		ldr		R10,pointeur_coordonnees_objet_destination_transformation				; coordonnees objet destination : X Y Z n°sprite
		
		ldr		R9,nb_etapes_transformation
		
		ldr		R0,nb_points_objet_en_cours
		
boucle_preparation_transformation:
		
		mov		R7,#3
		
boucle_preparation_transformation_1_valeur:

		ldr		R1,[R11],#4					; on recupere X point objet source
		ldr		R2,[R10],#4					; on recupere X point objet destination
		
		subs	R3,R2,R1					; Delta X = X destination - X source

; calcul du pas : il faut diviser R3 par R9
; en tenant compte de R3 négatif ?

; si r3 négatif :
 	mov R4,#0
	cmp r3,#0
	bpl .deltaX_positif
; r11 négatif

	rsb r3,r3,#0
	mov r4,#1		; R5 = 1 si X negatif

.deltaX_positif:
	mov		R3,R3,asl #15				; * 2^15

; R5 = ( R3 / R9 )
; registres dispos	:  R5 R6 R7 R8 R13 R14

	MOV      R5,#0     ;clear R5 to accumulate result
	MOV      R6,#1     ;set bit 0 in R6, which will be
					   ;shifted left then right
.startdivX_transformation1:
	CMP      R9,R3
	MOVLS    R9,R9,LSL#1
	MOVLS    R6,R6,LSL#1
	BLS      .startdivX_transformation1

.nextdivX_transformation1:
	CMP       R3,R9
	SUBCS     R3,R3,R9
	ADDCS     R5,R5,R6
	MOVS      R6,R6,LSR#1
	MOVCC     R9,R9,LSR#1
	BCC			.nextdivX_transformation1

	cmp		R4,#0			; R3 était négatif ?
	beq		.X_transformation_negatif
	rsb		r5,r5,#0		; alors résultat négatif
	
.X_transformation_negatif:

; R5 = R3/R9

	mov		R1,R1,asl #15	; X * 2^15
	
	str		R1,[R12],#4		; on stocke X * 2^15
	str		R5,[R12],#4		; increment X * 2^15
	
	subs	R7,R7,#1
	bgt		boucle_preparation_transformation_1_valeur
	
	ldr		R7,[R11],#4			; n° sprite source
	add		R10,R10,#4			; on saute le n° sprite objet destination
	str		R7,[R12],#4			; n° sprite table increment
		
	subs	R0,R0,#1
	bgt		boucle_preparation_transformation
	
	

; sortie
	mov pc, r14
	
;	calcul progressif des X Y Z transformation
;	source : pointeur_table_increments_pas_transformations : X source ,increment X, Y source, increment Y, Z source, increment Z  : tout x 2^15
;	dest : pointeur_buffer_coordonnees_objet_transformees


realisation_transformation:

		ldr		R12,pointeur_buffer_coordonnees_objet_transformees
		ldr		R11,pointeur_table_increments_pas_transformations
	
		ldr		R0,nb_points_objet_en_cours

boucle_realisation_transformation:
		mov		R7,#3

boucle_realisation_transformation_1_valeur:
		ldr		R1,[R11]					; X * 2^15
		ldr		R2,[R11,#4]					; increment X * 2^15
		
		adds	R1,R1,R2					; X + increment X/Z
		
		str		R1,[R11],#4					; on stocke X avance * 2^15
		add		R11,R11,#4					; on passe l'increment
		
		mov		R1,R1,asr #15				; on supprime les decimales
		
		str		R1,[R12],#4
		
		subs	R7,R7,#1
		bgt		boucle_realisation_transformation_1_valeur
		
		ldr		R7,[R11],#4			; n° sprite source
		str		R7,[R12],#4			; n° sprite destination
		
		subs	R0,R0,#1
		bgt		boucle_realisation_transformation
		
; sortie
		mov pc, r14		

nb_frame_en_cours:					.long		0
nb_frame_en_cours_affichage:		.long		0

pointeur_actuel_buffer_en_cours_d_affichage:		.long	buffer_calcul1
pointeur_actuel_buffer_en_cours_de_calcul:			.long	buffer_calcul1+taille_buffer_calculs
pointeur_buffer_en_cours_d_affichage:		.long	buffer_calcul1
pointeur_buffer_en_cours_de_calcul:			.long	buffer_calcul1+taille_buffer_calculs
fond_de_la_memoire:							.long	buffer_calcul1+(taille_buffer_calculs*2)

nb_sprites_en_cours_affichage:			.long 0
nb_sprites_en_cours_calcul:				.long 0

pointeur_coordonnees_transformees:						.long coordonnees_transformees
pointeur_coordonnees_projetees:							.long coordonnees_projetees
pointeur_coordonnees_projetees_actuel:					.long coordonnees_projetees

pointeur_points_objet_en_cours:		.long	coords_cube
nb_points_objet_en_cours:			.long	16
nb_points_objet_en_cours_objet_classique:		.long	8
nb_points_objet_en_cours_objet_anime:		.long	8


pointeur_position_dans_les_animations:		.long	anim3

nb_frames_rotation_classique:				.long 0
nb_frames_total_calcul:						.long 0
nb_frames_total_affichage:					.long 0

pointeur_objet_en_cours:					.long	cube

; variables transformation
pointeur_objet_source_transformation:		.long	cube1
pointeur_objet_destination_transformation:	.long	cube2

pointeur_coordonnees_objet_source_transformation:		.long	coordonnees_cube1
pointeur_coordonnees_objet_destination_transformation:		.long	coordonnees_cube2
numero_etape_en_cours_transformation:		.long	0
pointeur_buffer_coordonnees_objet_transformees:	.long buffer_coordonnees_objet_transformees
nb_etapes_transformation:			.long 0

flag_transformation_en_cours:		.long 0
flag_animation_en_cours:			.long 0
flag_classique_en_cours:			.long 0

pointeur_sprite_boule_violette:			.long sprite_boule_violette
pointeur_table_increments_pas_transformations:		.long		table_increments_pas_transformations

; variables animation
pointeur_vers_coordonnees_points_animation_original:			.long 0
pointeur_vers_coordonnees_points_animation_en_cours:			.long 0
nb_points_animation_en_cours:									.long 0
nb_frame_animation_en_cours:									.long 0
nb_frame_animation:												.long 0
nb_points_animation_en_cours_objet_anime:						.long 0

saveR1:			.long 0


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
	str 	r1,nb_points_en_cours

	ldr 	r1,[r5],#4			; X point
	ldr 	r2,[r5],#4			; Y point
	ldr 	r3,[r5],#4			; Z point
	ldr		r9,[r5],#4			; n°sprite
	str		R9,save_numero_sprite
	
	str 	r5,pointeur_en_cours_liste_points
	
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
	
	ldr		R9,save_numero_sprite
	str 	r9,[r0],#4			; stock n° sprite	
	
	ldr r5,pointeur_en_cours_liste_points
	ldr r1,nb_points_en_cours
	subs r1,r1,#1
	bne boucle_calc_points
	
; projection des points dans pointeur_coordonnees_projetees
; calculs des divisons X/Z et Y/Z
	ldr r9,pointeur_coordonnees_transformees
	ldr r8,nb_points_objet_en_cours			; r8=nb points
	ldr r10,pointeur_coordonnees_projetees_actuel
	
boucle_divisions_calcpoints:
	
	ldr 	r11,[r9],#4			; X point
	ldr 	r12,[r9],#4			; Y point
	ldr 	r13,[r9],#4			; Z point
	ldr		R0,[r9],#4			; n° sprite
	str		R0,save_numero_sprite

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
	add	R0,R0,#160-8
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
	add	R0,R0,#128-8
	str r0,[r10],#4
	
; stock Z pour tri
	str 	R13,[r10],#4
	
	ldr		R0,save_numero_sprite
	str		R0,[r10],#4				; stock numéro de sprite
	

; boucle
	subs r8,r8,#1
	bne boucle_divisions_calcpoints
	
	str		R10,pointeur_coordonnees_projetees_actuel

; les points sont dans coordonnees_projetees
	; retour
	ldr r14,save_R14
	mov pc, r14

pointeur_en_cours_liste_points:		.long 0	
nb_points_en_cours:		.long 0
distance_z:				.long 0x600

save_numero_sprite:		.long 0
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
	add		R12,R0,#4							; R12 = n° sprite
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

; Z
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
	
	LDRGT   R8,[R12,R2,LSL #4]	; Z1
	LDRGT   R9,[R12,R3,LSL #4]	; Z2
	STRGT   R9,[R12,R2,LSL #4]   ;// If R4 > R5, store current value at next
    STRGT   R8,[R12,R3,LSL #4]   ;// If R4 > R5, Store next value at current
	
	
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








; animation : 
;     - pointeur vers objet
;     - X,Y,Z objet
;     - increment X, increment Y , increment Z
;     - increment angle X, increment angle Y , increment angle Z
;	  - objet de destination d'une transformation, 0 = pas de transformation
;	  - nombre étapes transformation, 0 = pas de transformation
;     - pointeur vers data animation, 0 = pas d'anim
;     - nombre d'étapes en frame, 0 = pas d'anim
;	  - zoom / position observateur en Z

anim1:
		.long		cube			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		0,2,2			;     - increment angle X, increment angle Y , increment angle Z
		.long		0,0,0			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		256				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		0				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		0				;     - pointeur vers data animation, 0 = pas d'anim
		.long		0				;	  - nombre de points à animer
		.long		0				;     - nombre d'étapes en frame, 0 = pas d'anim

		.long		-1				;	  - zoom / position observateur en Z

		.long		cube			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		2,0,2			;     - increment angle X, increment angle Y , increment angle Z
		.long		0,0,0			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		256				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		0				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		0				;     - pointeur vers data animation, 0 = pas d'anim
		.long		0				;	  - nombre de points à animer
		.long		0				;     - nombre d'étapes en frame, 0 = pas d'anim

		.long		-1				;	  - zoom / position observateur en Z

		.long		cube			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		0,0,2			;     - increment angle X, increment angle Y , increment angle Z
		.long		0,0,0			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		256				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		0				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		0				;     - pointeur vers data animation, 0 = pas d'anim
		.long		0				;	  - nombre de points à animer
		.long		0				;     - nombre d'étapes en frame, 0 = pas d'anim

		.long		-1				;	  - zoom / position observateur en Z

; fin de l'anim
		.long		0


anim2:
		.long		cube1			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		0,2,2			;     - increment angle X, increment angle Y , increment angle Z
		.long		0,0,0			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		128				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		coordonnees_cube2				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		128				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		0				;     - pointeur vers data animation, 0 = pas d'anim
		.long		0				;	  - nombre de points à animer
		.long		0				;     - nombre d'étapes en frame, 0 = pas d'anim
		
		.long		0x500			;	  - zoom / position observateur en Z

		.long		cube2			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		0,2,2			;     - increment angle X, increment angle Y , increment angle Z
		.long		-1,-1,-1			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		128				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		0				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		0				;     - pointeur vers data animation, 0 = pas d'anim
		.long		0				;	  - nombre de points à animer
		.long		0				;     - nombre d'étapes en frame, 0 = pas d'anim

		.long		-1				;	  - zoom / position observateur en Z

		.long		cube2			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		2,0,0			;     - increment angle X, increment angle Y , increment angle Z
		.long		-1,-1,-1			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		128				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		coordonnees_cube1				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		128				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		0				;     - pointeur vers data animation, 0 = pas d'anim
		.long		0				;	  - nombre de points à animer
		.long		0				;     - nombre d'étapes en frame, 0 = pas d'anim

		.long		-1				;	  - zoom / position observateur en Z

		.long		cube1			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		2,0,0			;     - increment angle X, increment angle Y , increment angle Z
		.long		-1,-1,-1		; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		128				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		0				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		0				;     - pointeur vers data animation, 0 = pas d'anim
		.long		0				;	  - nombre de points à animer
		.long		0				;     - nombre d'étapes en frame, 0 = pas d'anim

		.long		-1				;	  - zoom / position observateur en Z

; fin de l'anim
		.long		0

anim3:
		.long		dummy			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		0,2,2			;     - increment angle X, increment angle Y , increment angle Z
		.long		0,0,0			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		120				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		0				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		coordonnees_points_carre				;     - pointeur vers data animation, 0 = pas d'anim
		.long		64				;	  - nombre de points à animer
		.long		20				;     - nombre d'étapes en frame, 0 = pas d'anim
		.long		0x500			;	  - zoom / position observateur en Z
		
		.long		dummy			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		0,-2,-2			;     - increment angle X, increment angle Y , increment angle Z
		.long		0,0,0			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		120				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		0				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		coordonnees_points_carre				;     - pointeur vers data animation, 0 = pas d'anim
		.long		64				;	  - nombre de points à animer
		.long		20				;     - nombre d'étapes en frame, 0 = pas d'anim
		.long		0x500			;	  - zoom / position observateur en Z

; fin de l'anim
		.long		0

; objet: 
;	- pointeur vers les points
;	- nb points
;	- pointeur vers points variables ( morceau de l'objet animé )
;	- nb points variables

; objet vide
dummy:
	.long	coordonnees_cube2			; pointeur coordonnées points
	.long	0							; nb points			
	.long	0
	.long	0

cube:
	.long	coords_cube				; pointeur coordonnées points
	.long	32						; nb points			
	.long	0
	.long	0

cube1:
	.long	coordonnees_cube1			; pointeur coordonnées points
	.long	8						; nb points			
	.long	0
	.long	0

cube2:
	.long	coordonnees_cube2			; pointeur coordonnées points
	.long	8						; nb points			
	.long	0
	.long	0


; point : X,Y,Z, n° sprite	
coords_cube:
	.long	-800,500,0,0
	.long	-600,500,0,0
	.long	-400,500,0,0
	.long	-200,500,0,0
	.long	100,500,0,0
	.long	200,500,0,0
	.long	300,500,0,0
	.long	400,500,0,0
	.long	-300,100,0,0
	.long	-200,100,0,0
	.long	-100,100,0,0
	.long	-000,100,0,0
	.long	100,100,0,0
	.long	200,100,0,0
	.long	300,100,0,0
	.long	400,100,0,0
	
	
	.long	-500,500,-500,0	;1
	.long	-500,-500,-500,0	;2
	.long	500,-500,-500,0	;3
	.long	500,500,-500,0	;4

	.long	-500,500,500,0	;5
	.long	-500,-500,500,0	;6
	.long	500,-500,500,0	;7
	.long	500,500,500,0	    ;8

	.long	-500,500,-300,0	;1
	.long	-500,-500,-300,0	;2
	.long	500,-500,-300,0	;3
	.long	500,500,-300,0	;4

	.long	-500,500,300,0	;5
	.long	-500,-500,300,0	;6
	.long	500,-500,300,0	;7
	.long	500,500,300,0	;8

coordonnees_cube1:
	.long	-500,500,-300,0	;1
	.long	-500,-500,-300,0	;2
	.long	500,-500,-300,0	;3
	.long	500,500,-300,0	;4
	.long	-500,500,300,0	;5
	.long	-500,-500,300,0	;6
	.long	500,-500,300,0	;7
	.long	500,500,300,0		;8

coordonnees_cube2:
	.long	-300,500,-100,0		;1
	.long	-300,-600,100,0		;6
	.long	300,-700,100,0		;7
	.long	300,800,100,0		;8

	.long	-500,-500,-100,0	;2
	.long	500,-500,-100,0		;3
	.long	500,500,-100,0		;4
	.long	-500,500,100,0		;5





save_regs:			.space	4*14
		
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

; structure d'une animation:
; X,Y,Z, N° sprite
; 64 points, 20 étapes
coordonnees_points_carre:
		.long 0xfffffee8,  0x118,0x0, 0x0
		.long 0xffffff38,  0x118,0x0, 0x0
		.long 0xffffff88,  0x118,0x0, 0x0
		.long 0xffffffd8,  0x118,0x0, 0x0
		.long 0x28,  0x118,0x0, 0x0
		.long 0x78,  0x118,0x0, 0x0
		.long 0xc8,  0x118,0x0, 0x0
		.long 0x118,  0x118,0x0, 0x0
		.long 0xfffffeec,  0xc8,0xffffffcf, 0x0
		.long 0xffffff3b,  0xc8,0xffffffdd, 0x1
		.long 0xffffff89,  0xc8,0xffffffeb, 0x1
		.long 0xffffffd8,  0xc8,0xfffffff9, 0x1
		.long 0x27,  0xc8,0x6, 0x1
		.long 0x76,  0xc8,0x14, 0x1
		.long 0xc4,  0xc8,0x22, 0x1
		.long 0x113,  0xc8,0x30, 0x0
		.long 0xfffffef7,  0x78,0xffffffa4, 0x0
		.long 0xffffff42,  0x78,0xffffffbe, 0x0
		.long 0xffffff8e,  0x78,0xffffffd8, 0x1
		.long 0xffffffda,  0x78,0xfffffff2, 0x0
		.long 0x25,  0x78,0xd, 0x0
		.long 0x71,  0x78,0x27, 0x1
		.long 0xbd,  0x78,0x41, 0x0
		.long 0x108,  0x78,0x5b, 0x0
		.long 0xffffff02,  0x28,0xffffff89, 0x0
		.long 0xffffff4a,  0x28,0xffffffab, 0x0
		.long 0xffffff93,  0x28,0xffffffcd, 0x1
		.long 0xffffffdb,  0x28,0xffffffef, 0x0
		.long 0x24,  0x28,0x10, 0x0
		.long 0x6c,  0x28,0x32, 0x1
		.long 0xb5,  0x28,0x54, 0x0
		.long 0xfd,  0x28,0x76, 0x0
		.long 0xffffff0b,  0xffffffd8,0xffffff78, 0x0
		.long 0xffffff51,  0xffffffd8,0xffffff9f, 0x0
		.long 0xffffff97,  0xffffffd8,0xffffffc5, 0x1
		.long 0xffffffdd,  0xffffffd8,0xffffffec, 0x0
		.long 0x22,  0xffffffd8,0x13, 0x0
		.long 0x68,  0xffffffd8,0x3a, 0x1
		.long 0xae,  0xffffffd8,0x60, 0x0
		.long 0xf4,  0xffffffd8,0x87, 0x0
		.long 0xffffff0b,  0xffffff88,0xffffff78, 0x0
		.long 0xffffff51,  0xffffff88,0xffffff9f, 0x0
		.long 0xffffff97,  0xffffff88,0xffffffc5, 0x1
		.long 0xffffffdd,  0xffffff88,0xffffffec, 0x0
		.long 0x22,  0xffffff88,0x13, 0x0
		.long 0x68,  0xffffff88,0x3a, 0x1
		.long 0xae,  0xffffff88,0x60, 0x0
		.long 0xf4,  0xffffff88,0x87, 0x0
		.long 0xffffff02,  0xffffff38,0xffffff89, 0x0
		.long 0xffffff4a,  0xffffff38,0xffffffab, 0x1
		.long 0xffffff93,  0xffffff38,0xffffffcd, 0x1
		.long 0xffffffdb,  0xffffff38,0xffffffef, 0x1
		.long 0x24,  0xffffff38,0x10, 0x1
		.long 0x6c,  0xffffff38,0x32, 0x1
		.long 0xb5,  0xffffff38,0x54, 0x1
		.long 0xfd,  0xffffff38,0x76, 0x0
		.long 0xfffffef7,  0xfffffee8,0xffffffa4, 0x0
		.long 0xffffff42,  0xfffffee8,0xffffffbe, 0x0
		.long 0xffffff8e,  0xfffffee8,0xffffffd8, 0x0
		.long 0xffffffda,  0xfffffee8,0xfffffff2, 0x0
		.long 0x25,  0xfffffee8,0xd, 0x0
		.long 0x71,  0xfffffee8,0x27, 0x0
		.long 0xbd,  0xfffffee8,0x41, 0x0
		.long 0x108,  0xfffffee8,0x5b, 0x0
		.long 0xfffffeeb,  0x118,0xffffffd4, 0x0
		.long 0xffffff3a,  0x118,0xffffffe0, 0x0
		.long 0xffffff89,  0x118,0xffffffed, 0x0
		.long 0xffffffd8,  0x118,0xfffffff9, 0x0
		.long 0x27,  0x118,0x6, 0x0
		.long 0x76,  0x118,0x12, 0x0
		.long 0xc5,  0x118,0x1f, 0x0
		.long 0x114,  0x118,0x2b, 0x0
		.long 0xfffffef5,  0xc8,0xffffffa9, 0x0
		.long 0xffffff41,  0xc8,0xffffffc2, 0x1
		.long 0xffffff8d,  0xc8,0xffffffda, 0x1
		.long 0xffffffd9,  0xc8,0xfffffff3, 0x1
		.long 0x26,  0xc8,0xc, 0x1
		.long 0x72,  0xc8,0x25, 0x1
		.long 0xbe,  0xc8,0x3d, 0x1
		.long 0x10a,  0xc8,0x56, 0x0
		.long 0xffffff02,  0x78,0xffffff89, 0x0
		.long 0xffffff4a,  0x78,0xffffffab, 0x0
		.long 0xffffff93,  0x78,0xffffffcd, 0x1
		.long 0xffffffdb,  0x78,0xffffffef, 0x0
		.long 0x24,  0x78,0x10, 0x0
		.long 0x6c,  0x78,0x32, 0x1
		.long 0xb5,  0x78,0x54, 0x0
		.long 0xfd,  0x78,0x76, 0x0
		.long 0xffffff0b,  0x28,0xffffff78, 0x0
		.long 0xffffff51,  0x28,0xffffff9f, 0x0
		.long 0xffffff97,  0x28,0xffffffc5, 0x1
		.long 0xffffffdd,  0x28,0xffffffec, 0x0
		.long 0x22,  0x28,0x13, 0x0
		.long 0x68,  0x28,0x3a, 0x1
		.long 0xae,  0x28,0x60, 0x0
		.long 0xf4,  0x28,0x87, 0x0
		.long 0xffffff0b,  0xffffffd8,0xffffff78, 0x0
		.long 0xffffff51,  0xffffffd8,0xffffff9f, 0x0
		.long 0xffffff97,  0xffffffd8,0xffffffc5, 0x1
		.long 0xffffffdd,  0xffffffd8,0xffffffec, 0x0
		.long 0x22,  0xffffffd8,0x13, 0x0
		.long 0x68,  0xffffffd8,0x3a, 0x1
		.long 0xae,  0xffffffd8,0x60, 0x0
		.long 0xf4,  0xffffffd8,0x87, 0x0
		.long 0xffffff04,  0xffffff88,0xffffff85, 0x0
		.long 0xffffff4c,  0xffffff88,0xffffffa8, 0x0
		.long 0xffffff94,  0xffffff88,0xffffffcb, 0x1
		.long 0xffffffdc,  0xffffff88,0xffffffee, 0x0
		.long 0x23,  0xffffff88,0x11, 0x0
		.long 0x6b,  0xffffff88,0x34, 0x1
		.long 0xb3,  0xffffff88,0x57, 0x0
		.long 0xfb,  0xffffff88,0x7a, 0x0
		.long 0xfffffef8,  0xffffff38,0xffffffa0, 0x0
		.long 0xffffff44,  0xffffff38,0xffffffbb, 0x1
		.long 0xffffff8f,  0xffffff38,0xffffffd6, 0x1
		.long 0xffffffda,  0xffffff38,0xfffffff2, 0x1
		.long 0x25,  0xffffff38,0xd, 0x1
		.long 0x70,  0xffffff38,0x29, 0x1
		.long 0xbb,  0xffffff38,0x44, 0x1
		.long 0x107,  0xffffff38,0x5f, 0x0
		.long 0xfffffeed,  0xfffffee8,0xffffffca, 0x0
		.long 0xffffff3b,  0xfffffee8,0xffffffd9, 0x0
		.long 0xffffff8a,  0xfffffee8,0xffffffe9, 0x0
		.long 0xffffffd8,  0xfffffee8,0xfffffff8, 0x0
		.long 0x27,  0xfffffee8,0x7, 0x0
		.long 0x75,  0xfffffee8,0x16, 0x0
		.long 0xc4,  0xfffffee8,0x26, 0x0
		.long 0x112,  0xfffffee8,0x35, 0x0
		.long 0xfffffef4,  0x118,0xffffffae, 0x0
		.long 0xffffff40,  0x118,0xffffffc5, 0x0
		.long 0xffffff8d,  0x118,0xffffffdc, 0x0
		.long 0xffffffd9,  0x118,0xfffffff4, 0x0
		.long 0x26,  0x118,0xb, 0x0
		.long 0x72,  0x118,0x23, 0x0
		.long 0xbf,  0x118,0x3a, 0x0
		.long 0x10b,  0x118,0x51, 0x0
		.long 0xffffff00,  0xc8,0xffffff8e, 0x0
		.long 0xffffff49,  0xc8,0xffffffae, 0x1
		.long 0xffffff92,  0xc8,0xffffffcf, 0x1
		.long 0xffffffdb,  0xc8,0xffffffef, 0x1
		.long 0x24,  0xc8,0x10, 0x1
		.long 0x6d,  0xc8,0x30, 0x1
		.long 0xb6,  0xc8,0x51, 0x1
		.long 0xff,  0xc8,0x71, 0x0
		.long 0xffffff0b,  0x78,0xffffff78, 0x0
		.long 0xffffff51,  0x78,0xffffff9f, 0x0
		.long 0xffffff97,  0x78,0xffffffc5, 0x1
		.long 0xffffffdd,  0x78,0xffffffec, 0x0
		.long 0x22,  0x78,0x13, 0x0
		.long 0x68,  0x78,0x3a, 0x1
		.long 0xae,  0x78,0x60, 0x0
		.long 0xf4,  0x78,0x87, 0x0
		.long 0xffffff0b,  0x28,0xffffff78, 0x0
		.long 0xffffff51,  0x28,0xffffff9f, 0x0
		.long 0xffffff97,  0x28,0xffffffc5, 0x1
		.long 0xffffffdd,  0x28,0xffffffec, 0x0
		.long 0x22,  0x28,0x13, 0x0
		.long 0x68,  0x28,0x3a, 0x1
		.long 0xae,  0x28,0x60, 0x0
		.long 0xf4,  0x28,0x87, 0x0
		.long 0xffffff04,  0xffffffd8,0xffffff85, 0x0
		.long 0xffffff4c,  0xffffffd8,0xffffffa8, 0x0
		.long 0xffffff94,  0xffffffd8,0xffffffcb, 0x1
		.long 0xffffffdc,  0xffffffd8,0xffffffee, 0x0
		.long 0x23,  0xffffffd8,0x11, 0x0
		.long 0x6b,  0xffffffd8,0x34, 0x1
		.long 0xb3,  0xffffffd8,0x57, 0x0
		.long 0xfb,  0xffffffd8,0x7a, 0x0
		.long 0xfffffef8,  0xffffff88,0xffffffa0, 0x0
		.long 0xffffff44,  0xffffff88,0xffffffbb, 0x0
		.long 0xffffff8f,  0xffffff88,0xffffffd6, 0x1
		.long 0xffffffda,  0xffffff88,0xfffffff2, 0x0
		.long 0x25,  0xffffff88,0xd, 0x0
		.long 0x70,  0xffffff88,0x29, 0x1
		.long 0xbb,  0xffffff88,0x44, 0x0
		.long 0x107,  0xffffff88,0x5f, 0x0
		.long 0xfffffeee,  0xffffff38,0xffffffc5, 0x0
		.long 0xffffff3c,  0xffffff38,0xffffffd6, 0x1
		.long 0xffffff8a,  0xffffff38,0xffffffe7, 0x1
		.long 0xffffffd8,  0xffffff38,0xfffffff7, 0x1
		.long 0x27,  0xffffff38,0x8, 0x1
		.long 0x75,  0xffffff38,0x18, 0x1
		.long 0xc3,  0xffffff38,0x29, 0x1
		.long 0x111,  0xffffff38,0x3a, 0x0
		.long 0xfffffee8,  0xfffffee8,0xfffffff6, 0x0
		.long 0xffffff38,  0xfffffee8,0xfffffff9, 0x0
		.long 0xffffff88,  0xfffffee8,0xfffffffb, 0x0
		.long 0xffffffd8,  0xfffffee8,0xfffffffe, 0x0
		.long 0x27,  0xfffffee8,0x1, 0x0
		.long 0x77,  0xfffffee8,0x4, 0x0
		.long 0xc7,  0xfffffee8,0x6, 0x0
		.long 0x117,  0xfffffee8,0x9, 0x0
		.long 0xffffff00,  0x118,0xffffff8e, 0x0
		.long 0xffffff49,  0x118,0xffffffae, 0x0
		.long 0xffffff92,  0x118,0xffffffcf, 0x0
		.long 0xffffffdb,  0x118,0xffffffef, 0x0
		.long 0x24,  0x118,0x10, 0x0
		.long 0x6d,  0x118,0x30, 0x0
		.long 0xb6,  0x118,0x51, 0x0
		.long 0xff,  0x118,0x71, 0x0
		.long 0xffffff08,  0xc8,0xffffff7c, 0x0
		.long 0xffffff4f,  0xc8,0xffffffa2, 0x1
		.long 0xffffff96,  0xc8,0xffffffc7, 0x1
		.long 0xffffffdc,  0xc8,0xffffffed, 0x1
		.long 0x23,  0xc8,0x12, 0x1
		.long 0x69,  0xc8,0x38, 0x1
		.long 0xb0,  0xc8,0x5d, 0x1
		.long 0xf7,  0xc8,0x83, 0x0
		.long 0xffffff0b,  0x78,0xffffff78, 0x0
		.long 0xffffff51,  0x78,0xffffff9f, 0x0
		.long 0xffffff97,  0x78,0xffffffc5, 0x1
		.long 0xffffffdd,  0x78,0xffffffec, 0x0
		.long 0x22,  0x78,0x13, 0x0
		.long 0x68,  0x78,0x3a, 0x1
		.long 0xae,  0x78,0x60, 0x0
		.long 0xf4,  0x78,0x87, 0x0
		.long 0xffffff06,  0x28,0xffffff80, 0x0
		.long 0xffffff4d,  0x28,0xffffffa5, 0x0
		.long 0xffffff95,  0x28,0xffffffc9, 0x1
		.long 0xffffffdc,  0x28,0xffffffed, 0x0
		.long 0x23,  0x28,0x12, 0x0
		.long 0x6a,  0x28,0x36, 0x1
		.long 0xb2,  0x28,0x5a, 0x0
		.long 0xf9,  0x28,0x7f, 0x0
		.long 0xfffffefa,  0xffffffd8,0xffffff9b, 0x0
		.long 0xffffff45,  0xffffffd8,0xffffffb8, 0x0
		.long 0xffffff8f,  0xffffffd8,0xffffffd4, 0x1
		.long 0xffffffda,  0xffffffd8,0xfffffff1, 0x0
		.long 0x25,  0xffffffd8,0xe, 0x0
		.long 0x70,  0xffffffd8,0x2b, 0x1
		.long 0xba,  0xffffffd8,0x47, 0x0
		.long 0x105,  0xffffffd8,0x64, 0x0
		.long 0xfffffeef,  0xffffff88,0xffffffc1, 0x0
		.long 0xffffff3d,  0xffffff88,0xffffffd3, 0x0
		.long 0xffffff8b,  0xffffff88,0xffffffe5, 0x1
		.long 0xffffffd9,  0xffffff88,0xfffffff7, 0x0
		.long 0x26,  0xffffff88,0x8, 0x0
		.long 0x74,  0xffffff88,0x1a, 0x1
		.long 0xc2,  0xffffff88,0x2c, 0x0
		.long 0x110,  0xffffff88,0x3e, 0x0
		.long 0xfffffee8,  0xffffff38,0xfffffff1, 0x0
		.long 0xffffff38,  0xffffff38,0xfffffff5, 0x1
		.long 0xffffff88,  0xffffff38,0xfffffff9, 0x1
		.long 0xffffffd8,  0xffffff38,0xfffffffd, 0x1
		.long 0x27,  0xffffff38,0x2, 0x1
		.long 0x77,  0xffffff38,0x6, 0x1
		.long 0xc7,  0xffffff38,0xa, 0x1
		.long 0x117,  0xffffff38,0xe, 0x0
		.long 0xfffffeea,  0xfffffee8,0x26, 0x0
		.long 0xffffff39,  0xfffffee8,0x1b, 0x0
		.long 0xffffff89,  0xfffffee8,0x10, 0x0
		.long 0xffffffd8,  0xfffffee8,0x5, 0x0
		.long 0x27,  0xfffffee8,0xfffffffa, 0x0
		.long 0x76,  0xfffffee8,0xffffffef, 0x0
		.long 0xc6,  0xfffffee8,0xffffffe4, 0x0
		.long 0x115,  0xfffffee8,0xffffffd9, 0x0
		.long 0xffffff08,  0x118,0xffffff7c, 0x0
		.long 0xffffff4f,  0x118,0xffffffa2, 0x0
		.long 0xffffff96,  0x118,0xffffffc7, 0x0
		.long 0xffffffdc,  0x118,0xffffffed, 0x0
		.long 0x23,  0x118,0x12, 0x0
		.long 0x69,  0x118,0x38, 0x0
		.long 0xb0,  0x118,0x5d, 0x0
		.long 0xf7,  0x118,0x83, 0x0
		.long 0xffffff0b,  0xc8,0xffffff78, 0x0
		.long 0xffffff51,  0xc8,0xffffff9f, 0x1
		.long 0xffffff97,  0xc8,0xffffffc5, 0x1
		.long 0xffffffdd,  0xc8,0xffffffec, 0x1
		.long 0x22,  0xc8,0x13, 0x1
		.long 0x68,  0xc8,0x3a, 0x1
		.long 0xae,  0xc8,0x60, 0x1
		.long 0xf4,  0xc8,0x87, 0x0
		.long 0xffffff06,  0x78,0xffffff80, 0x0
		.long 0xffffff4d,  0x78,0xffffffa5, 0x0
		.long 0xffffff95,  0x78,0xffffffc9, 0x1
		.long 0xffffffdc,  0x78,0xffffffed, 0x0
		.long 0x23,  0x78,0x12, 0x0
		.long 0x6a,  0x78,0x36, 0x1
		.long 0xb2,  0x78,0x5a, 0x0
		.long 0xf9,  0x78,0x7f, 0x0
		.long 0xfffffefc,  0x28,0xffffff97, 0x0
		.long 0xffffff46,  0x28,0xffffffb5, 0x0
		.long 0xffffff90,  0x28,0xffffffd3, 0x1
		.long 0xffffffda,  0x28,0xfffffff1, 0x0
		.long 0x25,  0x28,0xe, 0x0
		.long 0x6f,  0x28,0x2c, 0x1
		.long 0xb9,  0x28,0x4a, 0x0
		.long 0x103,  0x28,0x68, 0x0
		.long 0xfffffef0,  0xffffffd8,0xffffffbc, 0x0
		.long 0xffffff3d,  0xffffffd8,0xffffffcf, 0x0
		.long 0xffffff8b,  0xffffffd8,0xffffffe2, 0x1
		.long 0xffffffd9,  0xffffffd8,0xfffffff6, 0x0
		.long 0x26,  0xffffffd8,0x9, 0x0
		.long 0x74,  0xffffffd8,0x1d, 0x1
		.long 0xc2,  0xffffffd8,0x30, 0x0
		.long 0x10f,  0xffffffd8,0x43, 0x0
		.long 0xfffffee8,  0xffffff88,0xffffffec, 0x0
		.long 0xffffff38,  0xffffff88,0xfffffff2, 0x0
		.long 0xffffff88,  0xffffff88,0xfffffff7, 0x1
		.long 0xffffffd8,  0xffffff88,0xfffffffd, 0x0
		.long 0x27,  0xffffff88,0x2, 0x0
		.long 0x77,  0xffffff88,0x8, 0x1
		.long 0xc7,  0xffffff88,0xd, 0x0
		.long 0x117,  0xffffff88,0x13, 0x0
		.long 0xfffffeea,  0xffffff38,0x22, 0x0
		.long 0xffffff39,  0xffffff38,0x18, 0x1
		.long 0xffffff88,  0xffffff38,0xe, 0x1
		.long 0xffffffd8,  0xffffff38,0x4, 0x1
		.long 0x27,  0xffffff38,0xfffffffb, 0x1
		.long 0x77,  0xffffff38,0xfffffff1, 0x1
		.long 0xc6,  0xffffff38,0xffffffe7, 0x1
		.long 0x115,  0xffffff38,0xffffffdd, 0x0
		.long 0xfffffef2,  0xfffffee8,0x4d, 0x0
		.long 0xffffff3f,  0xfffffee8,0x37, 0x0
		.long 0xffffff8c,  0xfffffee8,0x21, 0x0
		.long 0xffffffd9,  0xfffffee8,0xb, 0x0
		.long 0x26,  0xfffffee8,0xfffffff4, 0x0
		.long 0x73,  0xfffffee8,0xffffffde, 0x0
		.long 0xc0,  0xfffffee8,0xffffffc8, 0x0
		.long 0x10d,  0xfffffee8,0xffffffb2, 0x0
		.long 0xffffff0d,  0x118,0xffffff73, 0x0
		.long 0xffffff52,  0x118,0xffffff9b, 0x0
		.long 0xffffff98,  0x118,0xffffffc3, 0x0
		.long 0xffffffdd,  0x118,0xffffffeb, 0x0
		.long 0x22,  0x118,0x14, 0x0
		.long 0x67,  0x118,0x3c, 0x0
		.long 0xad,  0x118,0x64, 0x0
		.long 0xf2,  0x118,0x8c, 0x0
		.long 0xffffff08,  0xc8,0xffffff7c, 0x0
		.long 0xffffff4f,  0xc8,0xffffffa2, 0x1
		.long 0xffffff96,  0xc8,0xffffffc7, 0x1
		.long 0xffffffdc,  0xc8,0xffffffed, 0x1
		.long 0x23,  0xc8,0x12, 0x1
		.long 0x69,  0xc8,0x38, 0x1
		.long 0xb0,  0xc8,0x5d, 0x1
		.long 0xf7,  0xc8,0x83, 0x0
		.long 0xfffffefc,  0x78,0xffffff97, 0x0
		.long 0xffffff46,  0x78,0xffffffb5, 0x0
		.long 0xffffff90,  0x78,0xffffffd3, 0x1
		.long 0xffffffda,  0x78,0xfffffff1, 0x0
		.long 0x25,  0x78,0xe, 0x0
		.long 0x6f,  0x78,0x2c, 0x1
		.long 0xb9,  0x78,0x4a, 0x0
		.long 0x103,  0x78,0x68, 0x0
		.long 0xfffffef1,  0x28,0xffffffb7, 0x0
		.long 0xffffff3e,  0x28,0xffffffcc, 0x0
		.long 0xffffff8c,  0x28,0xffffffe0, 0x1
		.long 0xffffffd9,  0x28,0xfffffff5, 0x0
		.long 0x26,  0x28,0xa, 0x0
		.long 0x73,  0x28,0x1f, 0x1
		.long 0xc1,  0x28,0x33, 0x0
		.long 0x10e,  0x28,0x48, 0x0
		.long 0xfffffee9,  0xffffffd8,0xffffffe7, 0x0
		.long 0xffffff38,  0xffffffd8,0xffffffee, 0x0
		.long 0xffffff88,  0xffffffd8,0xfffffff5, 0x1
		.long 0xffffffd8,  0xffffffd8,0xfffffffc, 0x0
		.long 0x27,  0xffffffd8,0x3, 0x0
		.long 0x77,  0xffffffd8,0xa, 0x1
		.long 0xc7,  0xffffffd8,0x11, 0x0
		.long 0x116,  0xffffffd8,0x18, 0x0
		.long 0xfffffee9,  0xffffff88,0x1d, 0x0
		.long 0xffffff39,  0xffffff88,0x14, 0x0
		.long 0xffffff88,  0xffffff88,0xc, 0x1
		.long 0xffffffd8,  0xffffff88,0x4, 0x0
		.long 0x27,  0xffffff88,0xfffffffb, 0x0
		.long 0x77,  0xffffff88,0xfffffff3, 0x1
		.long 0xc6,  0xffffff88,0xffffffeb, 0x0
		.long 0x116,  0xffffff88,0xffffffe2, 0x0
		.long 0xfffffef2,  0xffffff38,0x4d, 0x0
		.long 0xffffff3f,  0xffffff38,0x37, 0x1
		.long 0xffffff8c,  0xffffff38,0x21, 0x1
		.long 0xffffffd9,  0xffffff38,0xb, 0x1
		.long 0x26,  0xffffff38,0xfffffff4, 0x1
		.long 0x73,  0xffffff38,0xffffffde, 0x1
		.long 0xc0,  0xffffff38,0xffffffc8, 0x1
		.long 0x10d,  0xffffff38,0xffffffb2, 0x0
		.long 0xfffffefe,  0xfffffee8,0x6d, 0x0
		.long 0xffffff47,  0xfffffee8,0x4e, 0x0
		.long 0xffffff91,  0xfffffee8,0x2e, 0x0
		.long 0xffffffdb,  0xfffffee8,0xf, 0x0
		.long 0x24,  0xfffffee8,0xfffffff0, 0x0
		.long 0x6e,  0xfffffee8,0xffffffd1, 0x0
		.long 0xb8,  0xfffffee8,0xffffffb1, 0x0
		.long 0x101,  0xfffffee8,0xffffff92, 0x0
		.long 0xffffff08,  0x118,0xffffff7c, 0x0
		.long 0xffffff4f,  0x118,0xffffffa2, 0x0
		.long 0xffffff96,  0x118,0xffffffc7, 0x0
		.long 0xffffffdc,  0x118,0xffffffed, 0x0
		.long 0x23,  0x118,0x12, 0x0
		.long 0x69,  0x118,0x38, 0x0
		.long 0xb0,  0x118,0x5d, 0x0
		.long 0xf7,  0x118,0x83, 0x0
		.long 0xfffffefe,  0xc8,0xffffff92, 0x0
		.long 0xffffff47,  0xc8,0xffffffb1, 0x1
		.long 0xffffff91,  0xc8,0xffffffd1, 0x1
		.long 0xffffffdb,  0xc8,0xfffffff0, 0x1
		.long 0x24,  0xc8,0xf, 0x1
		.long 0x6e,  0xc8,0x2e, 0x1
		.long 0xb8,  0xc8,0x4e, 0x1
		.long 0x101,  0xc8,0x6d, 0x0
		.long 0xfffffef1,  0x78,0xffffffb7, 0x0
		.long 0xffffff3e,  0x78,0xffffffcc, 0x0
		.long 0xffffff8c,  0x78,0xffffffe0, 0x1
		.long 0xffffffd9,  0x78,0xfffffff5, 0x0
		.long 0x26,  0x78,0xa, 0x0
		.long 0x73,  0x78,0x1f, 0x1
		.long 0xc1,  0x78,0x33, 0x0
		.long 0x10e,  0x78,0x48, 0x0
		.long 0xfffffee9,  0x28,0xffffffe2, 0x0
		.long 0xffffff39,  0x28,0xffffffeb, 0x0
		.long 0xffffff88,  0x28,0xfffffff3, 0x1
		.long 0xffffffd8,  0x28,0xfffffffb, 0x0
		.long 0x27,  0x28,0x4, 0x0
		.long 0x77,  0x28,0xc, 0x1
		.long 0xc6,  0x28,0x14, 0x0
		.long 0x116,  0x28,0x1d, 0x0
		.long 0xfffffee9,  0xffffffd8,0x18, 0x0
		.long 0xffffff38,  0xffffffd8,0x11, 0x0
		.long 0xffffff88,  0xffffffd8,0xa, 0x1
		.long 0xffffffd8,  0xffffffd8,0x3, 0x0
		.long 0x27,  0xffffffd8,0xfffffffc, 0x0
		.long 0x77,  0xffffffd8,0xfffffff5, 0x1
		.long 0xc7,  0xffffffd8,0xffffffee, 0x0
		.long 0x116,  0xffffffd8,0xffffffe7, 0x0
		.long 0xfffffef1,  0xffffff88,0x48, 0x0
		.long 0xffffff3e,  0xffffff88,0x33, 0x0
		.long 0xffffff8c,  0xffffff88,0x1f, 0x1
		.long 0xffffffd9,  0xffffff88,0xa, 0x0
		.long 0x26,  0xffffff88,0xfffffff5, 0x0
		.long 0x73,  0xffffff88,0xffffffe0, 0x1
		.long 0xc1,  0xffffff88,0xffffffcc, 0x0
		.long 0x10e,  0xffffff88,0xffffffb7, 0x0
		.long 0xfffffefe,  0xffffff38,0x6d, 0x0
		.long 0xffffff47,  0xffffff38,0x4e, 0x1
		.long 0xffffff91,  0xffffff38,0x2e, 0x1
		.long 0xffffffdb,  0xffffff38,0xf, 0x1
		.long 0x24,  0xffffff38,0xfffffff0, 0x1
		.long 0x6e,  0xffffff38,0xffffffd1, 0x1
		.long 0xb8,  0xffffff38,0xffffffb1, 0x1
		.long 0x101,  0xffffff38,0xffffff92, 0x0
		.long 0xffffff08,  0xfffffee8,0x83, 0x0
		.long 0xffffff4f,  0xfffffee8,0x5d, 0x0
		.long 0xffffff96,  0xfffffee8,0x38, 0x0
		.long 0xffffffdc,  0xfffffee8,0x12, 0x0
		.long 0x23,  0xfffffee8,0xffffffed, 0x0
		.long 0x69,  0xfffffee8,0xffffffc7, 0x0
		.long 0xb0,  0xfffffee8,0xffffffa2, 0x0
		.long 0xf7,  0xfffffee8,0xffffff7c, 0x0
		.long 0xffffff00,  0x118,0xffffff8e, 0x0
		.long 0xffffff49,  0x118,0xffffffae, 0x0
		.long 0xffffff92,  0x118,0xffffffcf, 0x0
		.long 0xffffffdb,  0x118,0xffffffef, 0x0
		.long 0x24,  0x118,0x10, 0x0
		.long 0x6d,  0x118,0x30, 0x0
		.long 0xb6,  0x118,0x51, 0x0
		.long 0xff,  0x118,0x71, 0x0
		.long 0xfffffef2,  0xc8,0xffffffb2, 0x0
		.long 0xffffff3f,  0xc8,0xffffffc8, 0x1
		.long 0xffffff8c,  0xc8,0xffffffde, 0x1
		.long 0xffffffd9,  0xc8,0xfffffff4, 0x1
		.long 0x26,  0xc8,0xb, 0x1
		.long 0x73,  0xc8,0x21, 0x1
		.long 0xc0,  0xc8,0x37, 0x1
		.long 0x10d,  0xc8,0x4d, 0x0
		.long 0xfffffeea,  0x78,0xffffffdd, 0x0
		.long 0xffffff39,  0x78,0xffffffe7, 0x0
		.long 0xffffff88,  0x78,0xfffffff1, 0x1
		.long 0xffffffd8,  0x78,0xfffffffb, 0x0
		.long 0x27,  0x78,0x4, 0x0
		.long 0x77,  0x78,0xe, 0x1
		.long 0xc6,  0x78,0x18, 0x0
		.long 0x115,  0x78,0x22, 0x0
		.long 0xfffffee8,  0x28,0x13, 0x0
		.long 0xffffff38,  0x28,0xd, 0x0
		.long 0xffffff88,  0x28,0x8, 0x1
		.long 0xffffffd8,  0x28,0x2, 0x0
		.long 0x27,  0x28,0xfffffffd, 0x0
		.long 0x77,  0x28,0xfffffff7, 0x1
		.long 0xc7,  0x28,0xfffffff2, 0x0
		.long 0x117,  0x28,0xffffffec, 0x0
		.long 0xfffffef0,  0xffffffd8,0x43, 0x0
		.long 0xffffff3d,  0xffffffd8,0x30, 0x0
		.long 0xffffff8b,  0xffffffd8,0x1d, 0x1
		.long 0xffffffd9,  0xffffffd8,0x9, 0x0
		.long 0x26,  0xffffffd8,0xfffffff6, 0x0
		.long 0x74,  0xffffffd8,0xffffffe2, 0x1
		.long 0xc2,  0xffffffd8,0xffffffcf, 0x0
		.long 0x10f,  0xffffffd8,0xffffffbc, 0x0
		.long 0xfffffefc,  0xffffff88,0x68, 0x0
		.long 0xffffff46,  0xffffff88,0x4a, 0x0
		.long 0xffffff90,  0xffffff88,0x2c, 0x1
		.long 0xffffffda,  0xffffff88,0xe, 0x0
		.long 0x25,  0xffffff88,0xfffffff1, 0x0
		.long 0x6f,  0xffffff88,0xffffffd3, 0x1
		.long 0xb9,  0xffffff88,0xffffffb5, 0x0
		.long 0x103,  0xffffff88,0xffffff97, 0x0
		.long 0xffffff08,  0xffffff38,0x83, 0x0
		.long 0xffffff4f,  0xffffff38,0x5d, 0x1
		.long 0xffffff96,  0xffffff38,0x38, 0x1
		.long 0xffffffdc,  0xffffff38,0x12, 0x1
		.long 0x23,  0xffffff38,0xffffffed, 0x1
		.long 0x69,  0xffffff38,0xffffffc7, 0x1
		.long 0xb0,  0xffffff38,0xffffffa2, 0x1
		.long 0xf7,  0xffffff38,0xffffff7c, 0x0
		.long 0xffffff0d,  0xfffffee8,0x8c, 0x0
		.long 0xffffff52,  0xfffffee8,0x64, 0x0
		.long 0xffffff98,  0xfffffee8,0x3c, 0x0
		.long 0xffffffdd,  0xfffffee8,0x14, 0x0
		.long 0x22,  0xfffffee8,0xffffffeb, 0x0
		.long 0x67,  0xfffffee8,0xffffffc3, 0x0
		.long 0xad,  0xfffffee8,0xffffff9b, 0x0
		.long 0xf2,  0xfffffee8,0xffffff73, 0x0
		.long 0xfffffef4,  0x118,0xffffffae, 0x0
		.long 0xffffff40,  0x118,0xffffffc5, 0x0
		.long 0xffffff8d,  0x118,0xffffffdc, 0x0
		.long 0xffffffd9,  0x118,0xfffffff4, 0x0
		.long 0x26,  0x118,0xb, 0x0
		.long 0x72,  0x118,0x23, 0x0
		.long 0xbf,  0x118,0x3a, 0x0
		.long 0x10b,  0x118,0x51, 0x0
		.long 0xfffffeea,  0xc8,0xffffffd9, 0x0
		.long 0xffffff39,  0xc8,0xffffffe4, 0x1
		.long 0xffffff89,  0xc8,0xffffffef, 0x1
		.long 0xffffffd8,  0xc8,0xfffffffa, 0x1
		.long 0x27,  0xc8,0x5, 0x1
		.long 0x76,  0xc8,0x10, 0x1
		.long 0xc6,  0xc8,0x1b, 0x1
		.long 0x115,  0xc8,0x26, 0x0
		.long 0xfffffee8,  0x78,0xe, 0x0
		.long 0xffffff38,  0x78,0xa, 0x0
		.long 0xffffff88,  0x78,0x6, 0x1
		.long 0xffffffd8,  0x78,0x2, 0x0
		.long 0x27,  0x78,0xfffffffd, 0x0
		.long 0x77,  0x78,0xfffffff9, 0x1
		.long 0xc7,  0x78,0xfffffff5, 0x0
		.long 0x117,  0x78,0xfffffff1, 0x0
		.long 0xfffffeef,  0x28,0x3e, 0x0
		.long 0xffffff3d,  0x28,0x2c, 0x0
		.long 0xffffff8b,  0x28,0x1a, 0x1
		.long 0xffffffd9,  0x28,0x8, 0x0
		.long 0x26,  0x28,0xfffffff7, 0x0
		.long 0x74,  0x28,0xffffffe5, 0x1
		.long 0xc2,  0x28,0xffffffd3, 0x0
		.long 0x110,  0x28,0xffffffc1, 0x0
		.long 0xfffffefa,  0xffffffd8,0x64, 0x0
		.long 0xffffff45,  0xffffffd8,0x47, 0x0
		.long 0xffffff8f,  0xffffffd8,0x2b, 0x1
		.long 0xffffffda,  0xffffffd8,0xe, 0x0
		.long 0x25,  0xffffffd8,0xfffffff1, 0x0
		.long 0x70,  0xffffffd8,0xffffffd4, 0x1
		.long 0xba,  0xffffffd8,0xffffffb8, 0x0
		.long 0x105,  0xffffffd8,0xffffff9b, 0x0
		.long 0xffffff06,  0xffffff88,0x7f, 0x0
		.long 0xffffff4d,  0xffffff88,0x5a, 0x0
		.long 0xffffff95,  0xffffff88,0x36, 0x1
		.long 0xffffffdc,  0xffffff88,0x12, 0x0
		.long 0x23,  0xffffff88,0xffffffed, 0x0
		.long 0x6a,  0xffffff88,0xffffffc9, 0x1
		.long 0xb2,  0xffffff88,0xffffffa5, 0x0
		.long 0xf9,  0xffffff88,0xffffff80, 0x0
		.long 0xffffff0d,  0xffffff38,0x8c, 0x0
		.long 0xffffff52,  0xffffff38,0x64, 0x1
		.long 0xffffff98,  0xffffff38,0x3c, 0x1
		.long 0xffffffdd,  0xffffff38,0x14, 0x1
		.long 0x22,  0xffffff38,0xffffffeb, 0x1
		.long 0x67,  0xffffff38,0xffffffc3, 0x1
		.long 0xad,  0xffffff38,0xffffff9b, 0x1
		.long 0xf2,  0xffffff38,0xffffff73, 0x0
		.long 0xffffff0d,  0xfffffee8,0x8c, 0x0
		.long 0xffffff52,  0xfffffee8,0x64, 0x0
		.long 0xffffff98,  0xfffffee8,0x3c, 0x0
		.long 0xffffffdd,  0xfffffee8,0x14, 0x0
		.long 0x22,  0xfffffee8,0xffffffeb, 0x0
		.long 0x67,  0xfffffee8,0xffffffc3, 0x0
		.long 0xad,  0xfffffee8,0xffffff9b, 0x0
		.long 0xf2,  0xfffffee8,0xffffff73, 0x0
		.long 0xfffffeeb,  0x118,0xffffffd4, 0x0
		.long 0xffffff3a,  0x118,0xffffffe0, 0x0
		.long 0xffffff89,  0x118,0xffffffed, 0x0
		.long 0xffffffd8,  0x118,0xfffffff9, 0x0
		.long 0x27,  0x118,0x6, 0x0
		.long 0x76,  0x118,0x12, 0x0
		.long 0xc5,  0x118,0x1f, 0x0
		.long 0x114,  0x118,0x2b, 0x0
		.long 0xfffffee8,  0xc8,0x9, 0x0
		.long 0xffffff38,  0xc8,0x6, 0x1
		.long 0xffffff88,  0xc8,0x4, 0x1
		.long 0xffffffd8,  0xc8,0x1, 0x1
		.long 0x27,  0xc8,0xfffffffe, 0x1
		.long 0x77,  0xc8,0xfffffffb, 0x1
		.long 0xc7,  0xc8,0xfffffff9, 0x1
		.long 0x117,  0xc8,0xfffffff6, 0x0
		.long 0xfffffeee,  0x78,0x3a, 0x0
		.long 0xffffff3c,  0x78,0x29, 0x0
		.long 0xffffff8a,  0x78,0x18, 0x1
		.long 0xffffffd8,  0x78,0x8, 0x0
		.long 0x27,  0x78,0xfffffff7, 0x0
		.long 0x75,  0x78,0xffffffe7, 0x1
		.long 0xc3,  0x78,0xffffffd6, 0x0
		.long 0x111,  0x78,0xffffffc5, 0x0
		.long 0xfffffefa,  0x28,0x64, 0x0
		.long 0xffffff45,  0x28,0x47, 0x0
		.long 0xffffff8f,  0x28,0x2b, 0x1
		.long 0xffffffda,  0x28,0xe, 0x0
		.long 0x25,  0x28,0xfffffff1, 0x0
		.long 0x70,  0x28,0xffffffd4, 0x1
		.long 0xba,  0x28,0xffffffb8, 0x0
		.long 0x105,  0x28,0xffffff9b, 0x0
		.long 0xffffff06,  0xffffffd8,0x7f, 0x0
		.long 0xffffff4d,  0xffffffd8,0x5a, 0x0
		.long 0xffffff95,  0xffffffd8,0x36, 0x1
		.long 0xffffffdc,  0xffffffd8,0x12, 0x0
		.long 0x23,  0xffffffd8,0xffffffed, 0x0
		.long 0x6a,  0xffffffd8,0xffffffc9, 0x1
		.long 0xb2,  0xffffffd8,0xffffffa5, 0x0
		.long 0xf9,  0xffffffd8,0xffffff80, 0x0
		.long 0xffffff0d,  0xffffff88,0x8c, 0x0
		.long 0xffffff52,  0xffffff88,0x64, 0x0
		.long 0xffffff98,  0xffffff88,0x3c, 0x1
		.long 0xffffffdd,  0xffffff88,0x14, 0x0
		.long 0x22,  0xffffff88,0xffffffeb, 0x0
		.long 0x67,  0xffffff88,0xffffffc3, 0x1
		.long 0xad,  0xffffff88,0xffffff9b, 0x0
		.long 0xf2,  0xffffff88,0xffffff73, 0x0
		.long 0xffffff0d,  0xffffff38,0x8c, 0x0
		.long 0xffffff52,  0xffffff38,0x64, 0x1
		.long 0xffffff98,  0xffffff38,0x3c, 0x1
		.long 0xffffffdd,  0xffffff38,0x14, 0x1
		.long 0x22,  0xffffff38,0xffffffeb, 0x1
		.long 0x67,  0xffffff38,0xffffffc3, 0x1
		.long 0xad,  0xffffff38,0xffffff9b, 0x1
		.long 0xf2,  0xffffff38,0xffffff73, 0x0
		.long 0xffffff04,  0xfffffee8,0x7a, 0x0
		.long 0xffffff4c,  0xfffffee8,0x57, 0x0
		.long 0xffffff94,  0xfffffee8,0x34, 0x0
		.long 0xffffffdc,  0xfffffee8,0x11, 0x0
		.long 0x23,  0xfffffee8,0xffffffee, 0x0
		.long 0x6b,  0xfffffee8,0xffffffcb, 0x0
		.long 0xb3,  0xfffffee8,0xffffffa8, 0x0
		.long 0xfb,  0xfffffee8,0xffffff85, 0x0
		.long 0xfffffee8,  0x118,0x0, 0x0
		.long 0xffffff38,  0x118,0x0, 0x0
		.long 0xffffff88,  0x118,0x0, 0x0
		.long 0xffffffd8,  0x118,0x0, 0x0
		.long 0x28,  0x118,0x0, 0x0
		.long 0x78,  0x118,0x0, 0x0
		.long 0xc8,  0x118,0x0, 0x0
		.long 0x118,  0x118,0x0, 0x0
		.long 0xfffffeed,  0xc8,0x35, 0x0
		.long 0xffffff3b,  0xc8,0x26, 0x1
		.long 0xffffff8a,  0xc8,0x16, 0x1
		.long 0xffffffd8,  0xc8,0x7, 0x1
		.long 0x27,  0xc8,0xfffffff8, 0x1
		.long 0x75,  0xc8,0xffffffe9, 0x1
		.long 0xc4,  0xc8,0xffffffd9, 0x1
		.long 0x112,  0xc8,0xffffffca, 0x0
		.long 0xfffffef8,  0x78,0x5f, 0x0
		.long 0xffffff44,  0x78,0x44, 0x0
		.long 0xffffff8f,  0x78,0x29, 0x1
		.long 0xffffffda,  0x78,0xd, 0x0
		.long 0x25,  0x78,0xfffffff2, 0x0
		.long 0x70,  0x78,0xffffffd6, 0x1
		.long 0xbb,  0x78,0xffffffbb, 0x0
		.long 0x107,  0x78,0xffffffa0, 0x0
		.long 0xffffff04,  0x28,0x7a, 0x0
		.long 0xffffff4c,  0x28,0x57, 0x0
		.long 0xffffff94,  0x28,0x34, 0x1
		.long 0xffffffdc,  0x28,0x11, 0x0
		.long 0x23,  0x28,0xffffffee, 0x0
		.long 0x6b,  0x28,0xffffffcb, 0x1
		.long 0xb3,  0x28,0xffffffa8, 0x0
		.long 0xfb,  0x28,0xffffff85, 0x0
		.long 0xffffff0d,  0xffffffd8,0x8c, 0x0
		.long 0xffffff52,  0xffffffd8,0x64, 0x0
		.long 0xffffff98,  0xffffffd8,0x3c, 0x1
		.long 0xffffffdd,  0xffffffd8,0x14, 0x0
		.long 0x22,  0xffffffd8,0xffffffeb, 0x0
		.long 0x67,  0xffffffd8,0xffffffc3, 0x1
		.long 0xad,  0xffffffd8,0xffffff9b, 0x0
		.long 0xf2,  0xffffffd8,0xffffff73, 0x0
		.long 0xffffff0d,  0xffffff88,0x8c, 0x0
		.long 0xffffff52,  0xffffff88,0x64, 0x0
		.long 0xffffff98,  0xffffff88,0x3c, 0x1
		.long 0xffffffdd,  0xffffff88,0x14, 0x0
		.long 0x22,  0xffffff88,0xffffffeb, 0x0
		.long 0x67,  0xffffff88,0xffffffc3, 0x1
		.long 0xad,  0xffffff88,0xffffff9b, 0x0
		.long 0xf2,  0xffffff88,0xffffff73, 0x0
		.long 0xffffff04,  0xffffff38,0x7a, 0x0
		.long 0xffffff4c,  0xffffff38,0x57, 0x1
		.long 0xffffff94,  0xffffff38,0x34, 0x1
		.long 0xffffffdc,  0xffffff38,0x11, 0x1
		.long 0x23,  0xffffff38,0xffffffee, 0x1
		.long 0x6b,  0xffffff38,0xffffffcb, 0x1
		.long 0xb3,  0xffffff38,0xffffffa8, 0x1
		.long 0xfb,  0xffffff38,0xffffff85, 0x0
		.long 0xfffffef8,  0xfffffee8,0x5f, 0x0
		.long 0xffffff44,  0xfffffee8,0x44, 0x0
		.long 0xffffff8f,  0xfffffee8,0x29, 0x0
		.long 0xffffffda,  0xfffffee8,0xd, 0x0
		.long 0x25,  0xfffffee8,0xfffffff2, 0x0
		.long 0x70,  0xfffffee8,0xffffffd6, 0x0
		.long 0xbb,  0xfffffee8,0xffffffbb, 0x0
		.long 0x107,  0xfffffee8,0xffffffa0, 0x0
		.long 0xfffffeec,  0x118,0x30, 0x0
		.long 0xffffff3b,  0x118,0x22, 0x0
		.long 0xffffff89,  0x118,0x14, 0x0
		.long 0xffffffd8,  0x118,0x6, 0x0
		.long 0x27,  0x118,0xfffffff9, 0x0
		.long 0x76,  0x118,0xffffffeb, 0x0
		.long 0xc4,  0x118,0xffffffdd, 0x0
		.long 0x113,  0x118,0xffffffcf, 0x0
		.long 0xfffffef7,  0xc8,0x5b, 0x0
		.long 0xffffff42,  0xc8,0x41, 0x1
		.long 0xffffff8e,  0xc8,0x27, 0x1
		.long 0xffffffda,  0xc8,0xd, 0x1
		.long 0x25,  0xc8,0xfffffff2, 0x1
		.long 0x71,  0xc8,0xffffffd8, 0x1
		.long 0xbd,  0xc8,0xffffffbe, 0x1
		.long 0x108,  0xc8,0xffffffa4, 0x0
		.long 0xffffff04,  0x78,0x7a, 0x0
		.long 0xffffff4c,  0x78,0x57, 0x0
		.long 0xffffff94,  0x78,0x34, 0x1
		.long 0xffffffdc,  0x78,0x11, 0x0
		.long 0x23,  0x78,0xffffffee, 0x0
		.long 0x6b,  0x78,0xffffffcb, 0x1
		.long 0xb3,  0x78,0xffffffa8, 0x0
		.long 0xfb,  0x78,0xffffff85, 0x0
		.long 0xffffff0d,  0x28,0x8c, 0x0
		.long 0xffffff52,  0x28,0x64, 0x0
		.long 0xffffff98,  0x28,0x3c, 0x1
		.long 0xffffffdd,  0x28,0x14, 0x0
		.long 0x22,  0x28,0xffffffeb, 0x0
		.long 0x67,  0x28,0xffffffc3, 0x1
		.long 0xad,  0x28,0xffffff9b, 0x0
		.long 0xf2,  0x28,0xffffff73, 0x0
		.long 0xffffff0d,  0xffffffd8,0x8c, 0x0
		.long 0xffffff52,  0xffffffd8,0x64, 0x0
		.long 0xffffff98,  0xffffffd8,0x3c, 0x1
		.long 0xffffffdd,  0xffffffd8,0x14, 0x0
		.long 0x22,  0xffffffd8,0xffffffeb, 0x0
		.long 0x67,  0xffffffd8,0xffffffc3, 0x1
		.long 0xad,  0xffffffd8,0xffffff9b, 0x0
		.long 0xf2,  0xffffffd8,0xffffff73, 0x0
		.long 0xffffff06,  0xffffff88,0x7f, 0x0
		.long 0xffffff4d,  0xffffff88,0x5a, 0x0
		.long 0xffffff95,  0xffffff88,0x36, 0x1
		.long 0xffffffdc,  0xffffff88,0x12, 0x0
		.long 0x23,  0xffffff88,0xffffffed, 0x0
		.long 0x6a,  0xffffff88,0xffffffc9, 0x1
		.long 0xb2,  0xffffff88,0xffffffa5, 0x0
		.long 0xf9,  0xffffff88,0xffffff80, 0x0
		.long 0xfffffefa,  0xffffff38,0x64, 0x0
		.long 0xffffff45,  0xffffff38,0x47, 0x1
		.long 0xffffff8f,  0xffffff38,0x2b, 0x1
		.long 0xffffffda,  0xffffff38,0xe, 0x1
		.long 0x25,  0xffffff38,0xfffffff1, 0x1
		.long 0x70,  0xffffff38,0xffffffd4, 0x1
		.long 0xba,  0xffffff38,0xffffffb8, 0x1
		.long 0x105,  0xffffff38,0xffffff9b, 0x0
		.long 0xfffffeee,  0xfffffee8,0x3a, 0x0
		.long 0xffffff3c,  0xfffffee8,0x29, 0x0
		.long 0xffffff8a,  0xfffffee8,0x18, 0x0
		.long 0xffffffd8,  0xfffffee8,0x8, 0x0
		.long 0x27,  0xfffffee8,0xfffffff7, 0x0
		.long 0x75,  0xfffffee8,0xffffffe7, 0x0
		.long 0xc3,  0xfffffee8,0xffffffd6, 0x0
		.long 0x111,  0xfffffee8,0xffffffc5, 0x0
		.long 0xfffffef5,  0x118,0x56, 0x0
		.long 0xffffff41,  0x118,0x3d, 0x0
		.long 0xffffff8d,  0x118,0x25, 0x0
		.long 0xffffffd9,  0x118,0xc, 0x0
		.long 0x26,  0x118,0xfffffff3, 0x0
		.long 0x72,  0x118,0xffffffda, 0x0
		.long 0xbe,  0x118,0xffffffc2, 0x0
		.long 0x10a,  0x118,0xffffffa9, 0x0
		.long 0xffffff02,  0xc8,0x76, 0x0
		.long 0xffffff4a,  0xc8,0x54, 0x1
		.long 0xffffff93,  0xc8,0x32, 0x1
		.long 0xffffffdb,  0xc8,0x10, 0x1
		.long 0x24,  0xc8,0xffffffef, 0x1
		.long 0x6c,  0xc8,0xffffffcd, 0x1
		.long 0xb5,  0xc8,0xffffffab, 0x1
		.long 0xfd,  0xc8,0xffffff89, 0x0
		.long 0xffffff0d,  0x78,0x8c, 0x0
		.long 0xffffff52,  0x78,0x64, 0x0
		.long 0xffffff98,  0x78,0x3c, 0x1
		.long 0xffffffdd,  0x78,0x14, 0x0
		.long 0x22,  0x78,0xffffffeb, 0x0
		.long 0x67,  0x78,0xffffffc3, 0x1
		.long 0xad,  0x78,0xffffff9b, 0x0
		.long 0xf2,  0x78,0xffffff73, 0x0
		.long 0xffffff0d,  0x28,0x8c, 0x0
		.long 0xffffff52,  0x28,0x64, 0x0
		.long 0xffffff98,  0x28,0x3c, 0x1
		.long 0xffffffdd,  0x28,0x14, 0x0
		.long 0x22,  0x28,0xffffffeb, 0x0
		.long 0x67,  0x28,0xffffffc3, 0x1
		.long 0xad,  0x28,0xffffff9b, 0x0
		.long 0xf2,  0x28,0xffffff73, 0x0
		.long 0xffffff06,  0xffffffd8,0x7f, 0x0
		.long 0xffffff4d,  0xffffffd8,0x5a, 0x0
		.long 0xffffff95,  0xffffffd8,0x36, 0x1
		.long 0xffffffdc,  0xffffffd8,0x12, 0x0
		.long 0x23,  0xffffffd8,0xffffffed, 0x0
		.long 0x6a,  0xffffffd8,0xffffffc9, 0x1
		.long 0xb2,  0xffffffd8,0xffffffa5, 0x0
		.long 0xf9,  0xffffffd8,0xffffff80, 0x0
		.long 0xfffffefa,  0xffffff88,0x64, 0x0
		.long 0xffffff45,  0xffffff88,0x47, 0x0
		.long 0xffffff8f,  0xffffff88,0x2b, 0x1
		.long 0xffffffda,  0xffffff88,0xe, 0x0
		.long 0x25,  0xffffff88,0xfffffff1, 0x0
		.long 0x70,  0xffffff88,0xffffffd4, 0x1
		.long 0xba,  0xffffff88,0xffffffb8, 0x0
		.long 0x105,  0xffffff88,0xffffff9b, 0x0
		.long 0xfffffeef,  0xffffff38,0x3e, 0x0
		.long 0xffffff3d,  0xffffff38,0x2c, 0x1
		.long 0xffffff8b,  0xffffff38,0x1a, 0x1
		.long 0xffffffd9,  0xffffff38,0x8, 0x1
		.long 0x26,  0xffffff38,0xfffffff7, 0x1
		.long 0x74,  0xffffff38,0xffffffe5, 0x1
		.long 0xc2,  0xffffff38,0xffffffd3, 0x1
		.long 0x110,  0xffffff38,0xffffffc1, 0x0
		.long 0xfffffee8,  0xfffffee8,0xe, 0x0
		.long 0xffffff38,  0xfffffee8,0xa, 0x0
		.long 0xffffff88,  0xfffffee8,0x6, 0x0
		.long 0xffffffd8,  0xfffffee8,0x2, 0x0
		.long 0x27,  0xfffffee8,0xfffffffd, 0x0
		.long 0x77,  0xfffffee8,0xfffffff9, 0x0
		.long 0xc7,  0xfffffee8,0xfffffff5, 0x0
		.long 0x117,  0xfffffee8,0xfffffff1, 0x0
		.long 0xffffff02,  0x118,0x76, 0x0
		.long 0xffffff4a,  0x118,0x54, 0x0
		.long 0xffffff93,  0x118,0x32, 0x0
		.long 0xffffffdb,  0x118,0x10, 0x0
		.long 0x24,  0x118,0xffffffef, 0x0
		.long 0x6c,  0x118,0xffffffcd, 0x0
		.long 0xb5,  0x118,0xffffffab, 0x0
		.long 0xfd,  0x118,0xffffff89, 0x0
		.long 0xffffff0b,  0xc8,0x87, 0x0
		.long 0xffffff51,  0xc8,0x60, 0x1
		.long 0xffffff97,  0xc8,0x3a, 0x1
		.long 0xffffffdd,  0xc8,0x13, 0x1
		.long 0x22,  0xc8,0xffffffec, 0x1
		.long 0x68,  0xc8,0xffffffc5, 0x1
		.long 0xae,  0xc8,0xffffff9f, 0x1
		.long 0xf4,  0xc8,0xffffff78, 0x0
		.long 0xffffff0d,  0x78,0x8c, 0x0
		.long 0xffffff52,  0x78,0x64, 0x0
		.long 0xffffff98,  0x78,0x3c, 0x1
		.long 0xffffffdd,  0x78,0x14, 0x0
		.long 0x22,  0x78,0xffffffeb, 0x0
		.long 0x67,  0x78,0xffffffc3, 0x1
		.long 0xad,  0x78,0xffffff9b, 0x0
		.long 0xf2,  0x78,0xffffff73, 0x0
		.long 0xffffff08,  0x28,0x83, 0x0
		.long 0xffffff4f,  0x28,0x5d, 0x0
		.long 0xffffff96,  0x28,0x38, 0x1
		.long 0xffffffdc,  0x28,0x12, 0x0
		.long 0x23,  0x28,0xffffffed, 0x0
		.long 0x69,  0x28,0xffffffc7, 0x1
		.long 0xb0,  0x28,0xffffffa2, 0x0
		.long 0xf7,  0x28,0xffffff7c, 0x0
		.long 0xfffffefc,  0xffffffd8,0x68, 0x0
		.long 0xffffff46,  0xffffffd8,0x4a, 0x0
		.long 0xffffff90,  0xffffffd8,0x2c, 0x1
		.long 0xffffffda,  0xffffffd8,0xe, 0x0
		.long 0x25,  0xffffffd8,0xfffffff1, 0x0
		.long 0x6f,  0xffffffd8,0xffffffd3, 0x1
		.long 0xb9,  0xffffffd8,0xffffffb5, 0x0
		.long 0x103,  0xffffffd8,0xffffff97, 0x0
		.long 0xfffffef0,  0xffffff88,0x43, 0x0
		.long 0xffffff3d,  0xffffff88,0x30, 0x0
		.long 0xffffff8b,  0xffffff88,0x1d, 0x1
		.long 0xffffffd9,  0xffffff88,0x9, 0x0
		.long 0x26,  0xffffff88,0xfffffff6, 0x0
		.long 0x74,  0xffffff88,0xffffffe2, 0x1
		.long 0xc2,  0xffffff88,0xffffffcf, 0x0
		.long 0x10f,  0xffffff88,0xffffffbc, 0x0
		.long 0xfffffee8,  0xffffff38,0x13, 0x0
		.long 0xffffff38,  0xffffff38,0xd, 0x1
		.long 0xffffff88,  0xffffff38,0x8, 0x1
		.long 0xffffffd8,  0xffffff38,0x2, 0x1
		.long 0x27,  0xffffff38,0xfffffffd, 0x1
		.long 0x77,  0xffffff38,0xfffffff7, 0x1
		.long 0xc7,  0xffffff38,0xfffffff2, 0x1
		.long 0x117,  0xffffff38,0xffffffec, 0x0
		.long 0xfffffeea,  0xfffffee8,0xffffffdd, 0x0
		.long 0xffffff39,  0xfffffee8,0xffffffe7, 0x0
		.long 0xffffff88,  0xfffffee8,0xfffffff1, 0x0
		.long 0xffffffd8,  0xfffffee8,0xfffffffb, 0x0
		.long 0x27,  0xfffffee8,0x4, 0x0
		.long 0x77,  0xfffffee8,0xe, 0x0
		.long 0xc6,  0xfffffee8,0x18, 0x0
		.long 0x115,  0xfffffee8,0x22, 0x0
		.long 0xffffff0b,  0x118,0x87, 0x0
		.long 0xffffff51,  0x118,0x60, 0x0
		.long 0xffffff97,  0x118,0x3a, 0x0
		.long 0xffffffdd,  0x118,0x13, 0x0
		.long 0x22,  0x118,0xffffffec, 0x0
		.long 0x68,  0x118,0xffffffc5, 0x0
		.long 0xae,  0x118,0xffffff9f, 0x0
		.long 0xf4,  0x118,0xffffff78, 0x0
		.long 0xffffff0d,  0xc8,0x8c, 0x0
		.long 0xffffff52,  0xc8,0x64, 0x1
		.long 0xffffff98,  0xc8,0x3c, 0x1
		.long 0xffffffdd,  0xc8,0x14, 0x1
		.long 0x22,  0xc8,0xffffffeb, 0x1
		.long 0x67,  0xc8,0xffffffc3, 0x1
		.long 0xad,  0xc8,0xffffff9b, 0x1
		.long 0xf2,  0xc8,0xffffff73, 0x0
		.long 0xffffff08,  0x78,0x83, 0x0
		.long 0xffffff4f,  0x78,0x5d, 0x0
		.long 0xffffff96,  0x78,0x38, 0x1
		.long 0xffffffdc,  0x78,0x12, 0x0
		.long 0x23,  0x78,0xffffffed, 0x0
		.long 0x69,  0x78,0xffffffc7, 0x1
		.long 0xb0,  0x78,0xffffffa2, 0x0
		.long 0xf7,  0x78,0xffffff7c, 0x0
		.long 0xfffffefe,  0x28,0x6d, 0x0
		.long 0xffffff47,  0x28,0x4e, 0x0
		.long 0xffffff91,  0x28,0x2e, 0x1
		.long 0xffffffdb,  0x28,0xf, 0x0
		.long 0x24,  0x28,0xfffffff0, 0x0
		.long 0x6e,  0x28,0xffffffd1, 0x1
		.long 0xb8,  0x28,0xffffffb1, 0x0
		.long 0x101,  0x28,0xffffff92, 0x0
		.long 0xfffffef1,  0xffffffd8,0x48, 0x0
		.long 0xffffff3e,  0xffffffd8,0x33, 0x0
		.long 0xffffff8c,  0xffffffd8,0x1f, 0x1
		.long 0xffffffd9,  0xffffffd8,0xa, 0x0
		.long 0x26,  0xffffffd8,0xfffffff5, 0x0
		.long 0x73,  0xffffffd8,0xffffffe0, 0x1
		.long 0xc1,  0xffffffd8,0xffffffcc, 0x0
		.long 0x10e,  0xffffffd8,0xffffffb7, 0x0
		.long 0xfffffee9,  0xffffff88,0x18, 0x0
		.long 0xffffff38,  0xffffff88,0x11, 0x0
		.long 0xffffff88,  0xffffff88,0xa, 0x1
		.long 0xffffffd8,  0xffffff88,0x3, 0x0
		.long 0x27,  0xffffff88,0xfffffffc, 0x0
		.long 0x77,  0xffffff88,0xfffffff5, 0x1
		.long 0xc7,  0xffffff88,0xffffffee, 0x0
		.long 0x116,  0xffffff88,0xffffffe7, 0x0
		.long 0xfffffee9,  0xffffff38,0xffffffe2, 0x0
		.long 0xffffff39,  0xffffff38,0xffffffeb, 0x1
		.long 0xffffff88,  0xffffff38,0xfffffff3, 0x1
		.long 0xffffffd8,  0xffffff38,0xfffffffb, 0x1
		.long 0x27,  0xffffff38,0x4, 0x1
		.long 0x77,  0xffffff38,0xc, 0x1
		.long 0xc6,  0xffffff38,0x14, 0x1
		.long 0x116,  0xffffff38,0x1d, 0x0
		.long 0xfffffef1,  0xfffffee8,0xffffffb7, 0x0
		.long 0xffffff3e,  0xfffffee8,0xffffffcc, 0x0
		.long 0xffffff8c,  0xfffffee8,0xffffffe0, 0x0
		.long 0xffffffd9,  0xfffffee8,0xfffffff5, 0x0
		.long 0x26,  0xfffffee8,0xa, 0x0
		.long 0x73,  0xfffffee8,0x1f, 0x0
		.long 0xc1,  0xfffffee8,0x33, 0x0
		.long 0x10e,  0xfffffee8,0x48, 0x0
		.long 0xffffff0d,  0x118,0x8c, 0x0
		.long 0xffffff52,  0x118,0x64, 0x0
		.long 0xffffff98,  0x118,0x3c, 0x0
		.long 0xffffffdd,  0x118,0x14, 0x0
		.long 0x22,  0x118,0xffffffeb, 0x0
		.long 0x67,  0x118,0xffffffc3, 0x0
		.long 0xad,  0x118,0xffffff9b, 0x0
		.long 0xf2,  0x118,0xffffff73, 0x0
		.long 0xffffff0b,  0xc8,0x87, 0x0
		.long 0xffffff51,  0xc8,0x60, 0x1
		.long 0xffffff97,  0xc8,0x3a, 0x1
		.long 0xffffffdd,  0xc8,0x13, 0x1
		.long 0x22,  0xc8,0xffffffec, 0x1
		.long 0x68,  0xc8,0xffffffc5, 0x1
		.long 0xae,  0xc8,0xffffff9f, 0x1
		.long 0xf4,  0xc8,0xffffff78, 0x0
		.long 0xfffffefe,  0x78,0x6d, 0x0
		.long 0xffffff47,  0x78,0x4e, 0x0
		.long 0xffffff91,  0x78,0x2e, 0x1
		.long 0xffffffdb,  0x78,0xf, 0x0
		.long 0x24,  0x78,0xfffffff0, 0x0
		.long 0x6e,  0x78,0xffffffd1, 0x1
		.long 0xb8,  0x78,0xffffffb1, 0x0
		.long 0x101,  0x78,0xffffff92, 0x0
		.long 0xfffffef2,  0x28,0x4d, 0x0
		.long 0xffffff3f,  0x28,0x37, 0x0
		.long 0xffffff8c,  0x28,0x21, 0x1
		.long 0xffffffd9,  0x28,0xb, 0x0
		.long 0x26,  0x28,0xfffffff4, 0x0
		.long 0x73,  0x28,0xffffffde, 0x1
		.long 0xc0,  0x28,0xffffffc8, 0x0
		.long 0x10d,  0x28,0xffffffb2, 0x0
		.long 0xfffffee9,  0xffffffd8,0x1d, 0x0
		.long 0xffffff39,  0xffffffd8,0x14, 0x0
		.long 0xffffff88,  0xffffffd8,0xc, 0x1
		.long 0xffffffd8,  0xffffffd8,0x4, 0x0
		.long 0x27,  0xffffffd8,0xfffffffb, 0x0
		.long 0x77,  0xffffffd8,0xfffffff3, 0x1
		.long 0xc6,  0xffffffd8,0xffffffeb, 0x0
		.long 0x116,  0xffffffd8,0xffffffe2, 0x0
		.long 0xfffffee9,  0xffffff88,0xffffffe7, 0x0
		.long 0xffffff38,  0xffffff88,0xffffffee, 0x0
		.long 0xffffff88,  0xffffff88,0xfffffff5, 0x1
		.long 0xffffffd8,  0xffffff88,0xfffffffc, 0x0
		.long 0x27,  0xffffff88,0x3, 0x0
		.long 0x77,  0xffffff88,0xa, 0x1
		.long 0xc7,  0xffffff88,0x11, 0x0
		.long 0x116,  0xffffff88,0x18, 0x0
		.long 0xfffffef1,  0xffffff38,0xffffffb7, 0x0
		.long 0xffffff3e,  0xffffff38,0xffffffcc, 0x1
		.long 0xffffff8c,  0xffffff38,0xffffffe0, 0x1
		.long 0xffffffd9,  0xffffff38,0xfffffff5, 0x1
		.long 0x26,  0xffffff38,0xa, 0x1
		.long 0x73,  0xffffff38,0x1f, 0x1
		.long 0xc1,  0xffffff38,0x33, 0x1
		.long 0x10e,  0xffffff38,0x48, 0x0
		.long 0xfffffefc,  0xfffffee8,0xffffff97, 0x0
		.long 0xffffff46,  0xfffffee8,0xffffffb5, 0x0
		.long 0xffffff90,  0xfffffee8,0xffffffd3, 0x0
		.long 0xffffffda,  0xfffffee8,0xfffffff1, 0x0
		.long 0x25,  0xfffffee8,0xe, 0x0
		.long 0x6f,  0xfffffee8,0x2c, 0x0
		.long 0xb9,  0xfffffee8,0x4a, 0x0
		.long 0x103,  0xfffffee8,0x68, 0x0
		.long 0xffffff0b,  0x118,0x87, 0x0
		.long 0xffffff51,  0x118,0x60, 0x0
		.long 0xffffff97,  0x118,0x3a, 0x0
		.long 0xffffffdd,  0x118,0x13, 0x0
		.long 0x22,  0x118,0xffffffec, 0x0
		.long 0x68,  0x118,0xffffffc5, 0x0
		.long 0xae,  0x118,0xffffff9f, 0x0
		.long 0xf4,  0x118,0xffffff78, 0x0
		.long 0xffffff00,  0xc8,0x71, 0x0
		.long 0xffffff49,  0xc8,0x51, 0x1
		.long 0xffffff92,  0xc8,0x30, 0x1
		.long 0xffffffdb,  0xc8,0x10, 0x1
		.long 0x24,  0xc8,0xffffffef, 0x1
		.long 0x6d,  0xc8,0xffffffcf, 0x1
		.long 0xb6,  0xc8,0xffffffae, 0x1
		.long 0xff,  0xc8,0xffffff8e, 0x0
		.long 0xfffffef2,  0x78,0x4d, 0x0
		.long 0xffffff3f,  0x78,0x37, 0x0
		.long 0xffffff8c,  0x78,0x21, 0x1
		.long 0xffffffd9,  0x78,0xb, 0x0
		.long 0x26,  0x78,0xfffffff4, 0x0
		.long 0x73,  0x78,0xffffffde, 0x1
		.long 0xc0,  0x78,0xffffffc8, 0x0
		.long 0x10d,  0x78,0xffffffb2, 0x0
		.long 0xfffffeea,  0x28,0x22, 0x0
		.long 0xffffff39,  0x28,0x18, 0x0
		.long 0xffffff88,  0x28,0xe, 0x1
		.long 0xffffffd8,  0x28,0x4, 0x0
		.long 0x27,  0x28,0xfffffffb, 0x0
		.long 0x77,  0x28,0xfffffff1, 0x1
		.long 0xc6,  0x28,0xffffffe7, 0x0
		.long 0x115,  0x28,0xffffffdd, 0x0
		.long 0xfffffee8,  0xffffffd8,0xffffffec, 0x0
		.long 0xffffff38,  0xffffffd8,0xfffffff2, 0x0
		.long 0xffffff88,  0xffffffd8,0xfffffff7, 0x1
		.long 0xffffffd8,  0xffffffd8,0xfffffffd, 0x0
		.long 0x27,  0xffffffd8,0x2, 0x0
		.long 0x77,  0xffffffd8,0x8, 0x1
		.long 0xc7,  0xffffffd8,0xd, 0x0
		.long 0x117,  0xffffffd8,0x13, 0x0
		.long 0xfffffef0,  0xffffff88,0xffffffbc, 0x0
		.long 0xffffff3d,  0xffffff88,0xffffffcf, 0x0
		.long 0xffffff8b,  0xffffff88,0xffffffe2, 0x1
		.long 0xffffffd9,  0xffffff88,0xfffffff6, 0x0
		.long 0x26,  0xffffff88,0x9, 0x0
		.long 0x74,  0xffffff88,0x1d, 0x1
		.long 0xc2,  0xffffff88,0x30, 0x0
		.long 0x10f,  0xffffff88,0x43, 0x0
		.long 0xfffffefc,  0xffffff38,0xffffff97, 0x0
		.long 0xffffff46,  0xffffff38,0xffffffb5, 0x1
		.long 0xffffff90,  0xffffff38,0xffffffd3, 0x1
		.long 0xffffffda,  0xffffff38,0xfffffff1, 0x1
		.long 0x25,  0xffffff38,0xe, 0x1
		.long 0x6f,  0xffffff38,0x2c, 0x1
		.long 0xb9,  0xffffff38,0x4a, 0x1
		.long 0x103,  0xffffff38,0x68, 0x0
		.long 0xffffff06,  0xfffffee8,0xffffff80, 0x0
		.long 0xffffff4d,  0xfffffee8,0xffffffa5, 0x0
		.long 0xffffff95,  0xfffffee8,0xffffffc9, 0x0
		.long 0xffffffdc,  0xfffffee8,0xffffffed, 0x0
		.long 0x23,  0xfffffee8,0x12, 0x0
		.long 0x6a,  0xfffffee8,0x36, 0x0
		.long 0xb2,  0xfffffee8,0x5a, 0x0
		.long 0xf9,  0xfffffee8,0x7f, 0x0
		.long 0xffffff02,  0x118,0x76, 0x0
		.long 0xffffff4a,  0x118,0x54, 0x0
		.long 0xffffff93,  0x118,0x32, 0x0
		.long 0xffffffdb,  0x118,0x10, 0x0
		.long 0x24,  0x118,0xffffffef, 0x0
		.long 0x6c,  0x118,0xffffffcd, 0x0
		.long 0xb5,  0x118,0xffffffab, 0x0
		.long 0xfd,  0x118,0xffffff89, 0x0
		.long 0xfffffef4,  0xc8,0x51, 0x0
		.long 0xffffff40,  0xc8,0x3a, 0x1
		.long 0xffffff8d,  0xc8,0x23, 0x1
		.long 0xffffffd9,  0xc8,0xb, 0x1
		.long 0x26,  0xc8,0xfffffff4, 0x1
		.long 0x72,  0xc8,0xffffffdc, 0x1
		.long 0xbf,  0xc8,0xffffffc5, 0x1
		.long 0x10b,  0xc8,0xffffffae, 0x0
		.long 0xfffffeea,  0x78,0x26, 0x0
		.long 0xffffff39,  0x78,0x1b, 0x0
		.long 0xffffff89,  0x78,0x10, 0x1
		.long 0xffffffd8,  0x78,0x5, 0x0
		.long 0x27,  0x78,0xfffffffa, 0x0
		.long 0x76,  0x78,0xffffffef, 0x1
		.long 0xc6,  0x78,0xffffffe4, 0x0
		.long 0x115,  0x78,0xffffffd9, 0x0
		.long 0xfffffee8,  0x28,0xfffffff1, 0x0
		.long 0xffffff38,  0x28,0xfffffff5, 0x0
		.long 0xffffff88,  0x28,0xfffffff9, 0x1
		.long 0xffffffd8,  0x28,0xfffffffd, 0x0
		.long 0x27,  0x28,0x2, 0x0
		.long 0x77,  0x28,0x6, 0x1
		.long 0xc7,  0x28,0xa, 0x0
		.long 0x117,  0x28,0xe, 0x0
		.long 0xfffffeef,  0xffffffd8,0xffffffc1, 0x0
		.long 0xffffff3d,  0xffffffd8,0xffffffd3, 0x0
		.long 0xffffff8b,  0xffffffd8,0xffffffe5, 0x1
		.long 0xffffffd9,  0xffffffd8,0xfffffff7, 0x0
		.long 0x26,  0xffffffd8,0x8, 0x0
		.long 0x74,  0xffffffd8,0x1a, 0x1
		.long 0xc2,  0xffffffd8,0x2c, 0x0
		.long 0x110,  0xffffffd8,0x3e, 0x0
		.long 0xfffffefa,  0xffffff88,0xffffff9b, 0x0
		.long 0xffffff45,  0xffffff88,0xffffffb8, 0x0
		.long 0xffffff8f,  0xffffff88,0xffffffd4, 0x1
		.long 0xffffffda,  0xffffff88,0xfffffff1, 0x0
		.long 0x25,  0xffffff88,0xe, 0x0
		.long 0x70,  0xffffff88,0x2b, 0x1
		.long 0xba,  0xffffff88,0x47, 0x0
		.long 0x105,  0xffffff88,0x64, 0x0
		.long 0xffffff06,  0xffffff38,0xffffff80, 0x0
		.long 0xffffff4d,  0xffffff38,0xffffffa5, 0x1
		.long 0xffffff95,  0xffffff38,0xffffffc9, 0x1
		.long 0xffffffdc,  0xffffff38,0xffffffed, 0x1
		.long 0x23,  0xffffff38,0x12, 0x1
		.long 0x6a,  0xffffff38,0x36, 0x1
		.long 0xb2,  0xffffff38,0x5a, 0x1
		.long 0xf9,  0xffffff38,0x7f, 0x0
		.long 0xffffff0b,  0xfffffee8,0xffffff78, 0x0
		.long 0xffffff51,  0xfffffee8,0xffffff9f, 0x0
		.long 0xffffff97,  0xfffffee8,0xffffffc5, 0x0
		.long 0xffffffdd,  0xfffffee8,0xffffffec, 0x0
		.long 0x22,  0xfffffee8,0x13, 0x0
		.long 0x68,  0xfffffee8,0x3a, 0x0
		.long 0xae,  0xfffffee8,0x60, 0x0
		.long 0xf4,  0xfffffee8,0x87, 0x0
		.long 0xfffffef5,  0x118,0x56, 0x0
		.long 0xffffff41,  0x118,0x3d, 0x0
		.long 0xffffff8d,  0x118,0x25, 0x0
		.long 0xffffffd9,  0x118,0xc, 0x0
		.long 0x26,  0x118,0xfffffff3, 0x0
		.long 0x72,  0x118,0xffffffda, 0x0
		.long 0xbe,  0x118,0xffffffc2, 0x0
		.long 0x10a,  0x118,0xffffffa9, 0x0
		.long 0xfffffeeb,  0xc8,0x2b, 0x0
		.long 0xffffff3a,  0xc8,0x1f, 0x1
		.long 0xffffff89,  0xc8,0x12, 0x1
		.long 0xffffffd8,  0xc8,0x6, 0x1
		.long 0x27,  0xc8,0xfffffff9, 0x1
		.long 0x76,  0xc8,0xffffffed, 0x1
		.long 0xc5,  0xc8,0xffffffe0, 0x1
		.long 0x114,  0xc8,0xffffffd4, 0x0
		.long 0xfffffee8,  0x78,0xfffffff6, 0x0
		.long 0xffffff38,  0x78,0xfffffff9, 0x0
		.long 0xffffff88,  0x78,0xfffffffb, 0x1
		.long 0xffffffd8,  0x78,0xfffffffe, 0x0
		.long 0x27,  0x78,0x1, 0x0
		.long 0x77,  0x78,0x4, 0x1
		.long 0xc7,  0x78,0x6, 0x0
		.long 0x117,  0x78,0x9, 0x0
		.long 0xfffffeee,  0x28,0xffffffc5, 0x0
		.long 0xffffff3c,  0x28,0xffffffd6, 0x0
		.long 0xffffff8a,  0x28,0xffffffe7, 0x1
		.long 0xffffffd8,  0x28,0xfffffff7, 0x0
		.long 0x27,  0x28,0x8, 0x0
		.long 0x75,  0x28,0x18, 0x1
		.long 0xc3,  0x28,0x29, 0x0
		.long 0x111,  0x28,0x3a, 0x0
		.long 0xfffffef8,  0xffffffd8,0xffffffa0, 0x0
		.long 0xffffff44,  0xffffffd8,0xffffffbb, 0x0
		.long 0xffffff8f,  0xffffffd8,0xffffffd6, 0x1
		.long 0xffffffda,  0xffffffd8,0xfffffff2, 0x0
		.long 0x25,  0xffffffd8,0xd, 0x0
		.long 0x70,  0xffffffd8,0x29, 0x1
		.long 0xbb,  0xffffffd8,0x44, 0x0
		.long 0x107,  0xffffffd8,0x5f, 0x0
		.long 0xffffff04,  0xffffff88,0xffffff85, 0x0
		.long 0xffffff4c,  0xffffff88,0xffffffa8, 0x0
		.long 0xffffff94,  0xffffff88,0xffffffcb, 0x1
		.long 0xffffffdc,  0xffffff88,0xffffffee, 0x0
		.long 0x23,  0xffffff88,0x11, 0x0
		.long 0x6b,  0xffffff88,0x34, 0x1
		.long 0xb3,  0xffffff88,0x57, 0x0
		.long 0xfb,  0xffffff88,0x7a, 0x0
		.long 0xffffff0b,  0xffffff38,0xffffff78, 0x0
		.long 0xffffff51,  0xffffff38,0xffffff9f, 0x1
		.long 0xffffff97,  0xffffff38,0xffffffc5, 0x1
		.long 0xffffffdd,  0xffffff38,0xffffffec, 0x1
		.long 0x22,  0xffffff38,0x13, 0x1
		.long 0x68,  0xffffff38,0x3a, 0x1
		.long 0xae,  0xffffff38,0x60, 0x1
		.long 0xf4,  0xffffff38,0x87, 0x0
		.long 0xffffff0b,  0xfffffee8,0xffffff78, 0x0
		.long 0xffffff51,  0xfffffee8,0xffffff9f, 0x0
		.long 0xffffff97,  0xfffffee8,0xffffffc5, 0x0
		.long 0xffffffdd,  0xfffffee8,0xffffffec, 0x0
		.long 0x22,  0xfffffee8,0x13, 0x0
		.long 0x68,  0xfffffee8,0x3a, 0x0
		.long 0xae,  0xfffffee8,0x60, 0x0
		.long 0xf4,  0xfffffee8,0x87, 0x0
		.long 0xfffffeec,  0x118,0x30, 0x0
		.long 0xffffff3b,  0x118,0x22, 0x0
		.long 0xffffff89,  0x118,0x14, 0x0
		.long 0xffffffd8,  0x118,0x6, 0x0
		.long 0x27,  0x118,0xfffffff9, 0x0
		.long 0x76,  0x118,0xffffffeb, 0x0
		.long 0xc4,  0x118,0xffffffdd, 0x0
		.long 0x113,  0x118,0xffffffcf, 0x0
		.long 0xfffffee8,  0xc8,0xfffffffb, 0x0
		.long 0xffffff38,  0xc8,0xfffffffc, 0x1
		.long 0xffffff88,  0xc8,0xfffffffd, 0x1
		.long 0xffffffd8,  0xc8,0xffffffff, 0x1
		.long 0x27,  0xc8,0x0, 0x1
		.long 0x77,  0xc8,0x2, 0x1
		.long 0xc7,  0xc8,0x3, 0x1
		.long 0x117,  0xc8,0x4, 0x0
		.long 0xfffffeed,  0x78,0xffffffca, 0x0
		.long 0xffffff3b,  0x78,0xffffffd9, 0x0
		.long 0xffffff8a,  0x78,0xffffffe9, 0x1
		.long 0xffffffd8,  0x78,0xfffffff8, 0x0
		.long 0x27,  0x78,0x7, 0x0
		.long 0x75,  0x78,0x16, 0x1
		.long 0xc4,  0x78,0x26, 0x0
		.long 0x112,  0x78,0x35, 0x0
		.long 0xfffffef8,  0x28,0xffffffa0, 0x0
		.long 0xffffff44,  0x28,0xffffffbb, 0x0
		.long 0xffffff8f,  0x28,0xffffffd6, 0x1
		.long 0xffffffda,  0x28,0xfffffff2, 0x0
		.long 0x25,  0x28,0xd, 0x0
		.long 0x70,  0x28,0x29, 0x1
		.long 0xbb,  0x28,0x44, 0x0
		.long 0x107,  0x28,0x5f, 0x0
		.long 0xffffff04,  0xffffffd8,0xffffff85, 0x0
		.long 0xffffff4c,  0xffffffd8,0xffffffa8, 0x0
		.long 0xffffff94,  0xffffffd8,0xffffffcb, 0x1
		.long 0xffffffdc,  0xffffffd8,0xffffffee, 0x0
		.long 0x23,  0xffffffd8,0x11, 0x0
		.long 0x6b,  0xffffffd8,0x34, 0x1
		.long 0xb3,  0xffffffd8,0x57, 0x0
		.long 0xfb,  0xffffffd8,0x7a, 0x0
		.long 0xffffff0b,  0xffffff88,0xffffff78, 0x0
		.long 0xffffff51,  0xffffff88,0xffffff9f, 0x0
		.long 0xffffff97,  0xffffff88,0xffffffc5, 0x1
		.long 0xffffffdd,  0xffffff88,0xffffffec, 0x0
		.long 0x22,  0xffffff88,0x13, 0x0
		.long 0x68,  0xffffff88,0x3a, 0x1
		.long 0xae,  0xffffff88,0x60, 0x0
		.long 0xf4,  0xffffff88,0x87, 0x0
		.long 0xffffff0b,  0xffffff38,0xffffff78, 0x0
		.long 0xffffff51,  0xffffff38,0xffffff9f, 0x1
		.long 0xffffff97,  0xffffff38,0xffffffc5, 0x1
		.long 0xffffffdd,  0xffffff38,0xffffffec, 0x1
		.long 0x22,  0xffffff38,0x13, 0x1
		.long 0x68,  0xffffff38,0x3a, 0x1
		.long 0xae,  0xffffff38,0x60, 0x1
		.long 0xf4,  0xffffff38,0x87, 0x0
		.long 0xffffff02,  0xfffffee8,0xffffff89, 0x0
		.long 0xffffff4a,  0xfffffee8,0xffffffab, 0x0
		.long 0xffffff93,  0xfffffee8,0xffffffcd, 0x0
		.long 0xffffffdb,  0xfffffee8,0xffffffef, 0x0
		.long 0x24,  0xfffffee8,0x10, 0x0
		.long 0x6c,  0xfffffee8,0x32, 0x0
		.long 0xb5,  0xfffffee8,0x54, 0x0
		.long 0xfd,  0xfffffee8,0x76, 0x0
		
		
		
nom_Rasterman:			.byte		"rm24",0
nom_QT:					.byte		"qt",0
nom_module_Rasterman:	.byte		"Rasterman",0
nom_module_QT:			.byte		"QTMTracker",0
				.balign		8
;.section bss,"u"
coordonnees_transformees:	.space 1024
coordonnees_projetees:	.space 1024
index_et_Z_pour_tri:	.space	4*256
table_increments_pas_transformations:		.space			64*7*4
; X,Y,Z,increment pas , tout multiplié par 2^15
		
buffer_coordonnees_objet_transformees:		.space			64*4*4
	.p2align 8
buffer_calcul1:
		.skip		512*64*16
buffer_calcul2:		
		.skip		512*64*16
