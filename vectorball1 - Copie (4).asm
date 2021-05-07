; !!! compresser les données : 9 bits pour X, 9 bits pour Y, 2 bits pour n° sprite = 20 bits   :   1 Mega = 26 secondes


; !!!!!   ==============>    permettre une animation de déplacement dans l'espace de l'objet : table mouvement, inc X, inc Y , inc Z de l'objet en entier

; !!!!!   ==============>    faire un scrolling completement dynamique en 3D

; idées objets : transformation décompte de chiffres, 


; - OK : Gérer clipping Y<-16 Y>258, X<0 X>416 
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

.equ Screen_Mode, 97
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

	mov		R0,#11			; OS_Module 11 : Insert module from memory and move into RMA
	ldr		R1,pointeur_module97
	SWI		0x1E

	mov		R1,#0			; stop color flashing
	mov		R0,#9
	swi		OS_Byte

	bl 		creer_table_416


	mov		R0,#0
	str		R0,nb_frames_total_calcul

	ldr		R5,pointeur_buffer_en_cours_de_calcul
	str		R5,pointeur_actuel_buffer_en_cours_de_calcul


boucle_lecture_animations:
	
	mov		R1,#0
	str		R1,flag_transformation_en_cours			; pas de transformation
	str		R1,flag_animation_en_cours				; pas d'animation
	str		R1,flag_classique_en_cours				; pas d'objet classique
	str		R1,flag_mouvement_en_cours
	str		R1,flag_repetition_mouvement_en_cours

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


; ; --------- gestion des initialisations du mouvement 
	
	ldr		R4,[R1],#4			; pointeur vers table de mouvements de l'objet
	cmp		R4,#0			
	beq		.pas_de_mouvement_de_l_objet

;	.long		0	; nombre étapes du mouvement
;	.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
	
	str		R4,pointeur_debut_mouvement
	str		R4,pointeur_index_actuel_mouvement

	mov		R4,#1
	str		R4,flag_mouvement_en_cours

	
	ldr		R4,[R1]				; nombre étapes du mouvement 
	str		R4,nombre_etapes_du_mouvement_initial
	str		R4,nombre_etapes_du_mouvement_en_cours
	
	ldr		R4,[R1,#4]			; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
	cmp		R4,#0
	ble		.pas_de_mouvement_de_l_objet		; pas de repetition
	str		R4,pointeur_initial_repetition_mouvement
	str		R4,pointeur_actuel_repetition_mouvement

	mov		R4,#1
	str 	R4,flag_repetition_mouvement_en_cours
	
	ldr		R4,[R1,#8]					; nombre etapes de la repetition
	str		R4,nombre_etapes_repetition_du_mouvement_initial
	str		R4,nombre_etapes_repetition_du_mouvement_en_cours
	

	mov		R4,#1
	str		R4,flag_mouvement_en_cours
.pas_de_mouvement_de_l_objet:

	add		R1,R1,#12			; on saute 

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

;-------------------- boucle principale précalcul des points


boucle_calcul_frames_classiques:

; gestion du mouvement de l'objet en entier
; 
	

	ldr		R0,flag_mouvement_en_cours
	cmp		r0,#0
	beq		.pas_de_mouvement_pendant_calcul
; on applique la table de mouvements

	ldr		R0,nombre_etapes_du_mouvement_en_cours
	subs	R0,R0,#1
	bne		.pas_fin_du_mouvement_pendant_calcul

; fin du mouvement
; y a t il répetition ?
	ldr		R1,flag_repetition_mouvement_en_cours
	cmp		R1,#0
	beq		.pas_de_repetition_mouvement_pendant_calcul

; on sort du mouvement initial et on initialize la répétition
	ldr		R2,pointeur_initial_repetition_mouvement		; on pointe vers la table de repetition
	str		R2,pointeur_index_actuel_mouvement
	
	ldr		R0,nombre_etapes_repetition_du_mouvement_initial
	;str		R0,nombre_etapes_du_mouvement_en_cours			; nb etapes mouvement en cours = nb etapes de repetition
	
	
	b		.pas_fin_du_mouvement_pendant_calcul
	
.pas_de_repetition_mouvement_pendant_calcul:
	str		R1,flag_mouvement_en_cours					; pas de repetition = mouvement terminé = 0
	

.pas_fin_du_mouvement_pendant_calcul:
	str		R0,nombre_etapes_du_mouvement_en_cours

	ldr		R10,pointeur_index_actuel_mouvement
	ldr		R2,[R10],#4								; X objet sur l ecran
	str		R2,position_objet_sur_ecran_X
	ldr		R2,[R10],#4								; Y objet sur l ecran
	str		R2,position_objet_sur_ecran_Y
	str		R10,pointeur_index_actuel_mouvement
	
	
.pas_de_mouvement_pendant_calcul:





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
; 416 * ( 32+258+32+258+32)
	MOV r2, #416*612

	; 320*256 * 2 ecrans
	SUBS r1, r2, r1
	SWI OS_ChangeDynamicArea
	
; taille dynamic area screen = 320*256*2

	MOV r0, #DynArea_Screen
	SWI OS_ReadDynamicArea
	
	; r0 = pointeur memoire ecrans
	
	add		R0,R0,#416*32
	str		r0,screenaddr1
	add		r0,r0,#416*290
	str		r0,screenaddr2
	
	mov		r0,#416*32
	str		r0,screenaddr1_MEMC
	add		r0,r0,#416*290
	str		r0,screenaddr2_MEMC
	
	ldr		r1,screenaddr1
	ldr		r2,screenaddr2
	ldr		r3,couleur
	mov		r0,#26832/2
.clsall:
	str		r3,[r1],#4
	str		r3,[r2],#4
	subs	r0,r0,#1
	bne		.clsall
	
	ldr		r3,couleur2
	mov		r0,#26832/2
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
	orr   r1,r1,#0x00000000            
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
	
	
	;------------------


    MOV R0,#19
    SWI OS_Byte

	SWI		22
	MOVNV R0,R0
	

	
	
	; update pointeur video hardware
	ldr	r0,screenaddr1_MEMC
	mov r0,r0,lsr #4
	mov r0,r0,lsl #2
	mov r1,#0x3600000
	add r0,r0,r1
	str r0,[r0]

	;b		toto

;	ldr		R3,pointeur_table_mode97
;	ldr		R2,[R3],#4			; nb de registres
;	mov   	r0,#0x3400000
	
;boucle_mode97:
;	ldr		R1,[R3],#4
;	str		r1,[r0]
;	mov   r0,r0
;	
;	subs	R2,R2,#1
;	bgt		boucle_mode97


	teqp  r15,#0                     
	mov   r0,r0
	

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
	;orr   r1,r1,#0x40000000            
	orr   r1,r1,#0x00000000
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
;416x258 = 107328
	ldr		r0,screenaddr1
	mov		r14,#52
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

; 107328
; 107328 /4 = 26832
; 26832 / 12 = 2236
; 


.boucleCLS:
	.rept	43
	stmia	r0!,{r1-r12}
	.endr
	subs	r14,r14,#1
	bne		.boucleCLS
	
	stmia	r0!,{r1-r8}


; changement couleur border
	mov   r0,#0x3400000               
	mov   r1,#47  
; border	
	orr   r1,r1,#0x00000000            
	;orr   r1,r1,#0x40000000            
	str   r1,[r0]       






 	



; affichage des sprites
; en R0=x, R1=y




	ldr		R12,pointeur_actuel_buffer_en_cours_d_affichage
	ldr		R11,nb_sprites_en_cours_affichage

	;mov		R11,#32
	;mov		R12,#0
	;mov		R10,#0

boucle_affiche_sprites_vbl:	
	ldr		R0,[R12],#4
	ldr		R1,[R12],#4
	add		R12,R12,#8			; saute le Z et le N° de sprite pour arrondi à 16 octets
	

	;bl		copie_sprite

	str		R11,saveR11_local
	str		R12,saveR12_local
	str		R10,saveR10_local
;	str		R0,saveR0_local
;	str		R1,saveR1_local
	
	
	;mov		R0,R10
	;mov		R1,R12
	
	bl		plot_boule16x16_position0
	
;	.rept	4
;	ldr		R0,saveR0_local
;	ldr		R1,saveR1_local
;	bl		plot_boule16x16_position0
;	.endr
	
	;bl		Plot_Violette_Sphere_Pos_0
	
	ldr		R11,saveR11_local
	ldr		R12,saveR12_local
	ldr		R10,saveR10_local
	
	;add		R12,R12,#32
	;add		R10,R10,#33

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
	;orr   r1,r1,#0x40000000            
	orr   r1,r1,#0x00000000            

	str   r1,[r0]   
	nop

	mov		R0,#save_regs
	ldmia	R0,{R1-R14}

	
	ldr r0,saver0
	
	
	ldr pc,savelr

saveR11_local:		.long 0
saveR12_local:		.long 0	
saveR10_local:		.long 0	
saveR0_local:		.long 0
saveR1_local:		.long 0

		.p2align		3
pointeur_module97:		.long	module97


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
	ldr		r10,pointeur_table416
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
	
	add		r2,r2,#416-16
	subs		r4,r4,#1
	bgt		.boucle_copie_sprite_ligne
	
	
	mov		 pc,r14
	
.vide:
	add			R2,R2,#1
	subs		r0,r0,#1
	bgt		.boucle_copie_sprite_pixel
	
	add		r2,r2,#416-16
	subs		r4,r4,#1
	bgt		.boucle_copie_sprite_ligne
	
	
	mov		 pc,r14



cls_ecran_actuel:

	str		r14,saver14
;320x256 = 81920
	
	ldr		r15,saver14
	
	
creer_table_416:

	ldr		r1,pointeur_table416negatif
	ldr		r0,valeur_N_13312					;-416*32
	mov		r2,#292								; 260 + 32
.boucle416:
	
	str		r0,[r1],#4
	add		r0,r0,#416
	subs	r2,r2,#1
	bgt		.boucle416
	mov pc, r14

valeur_N_13312:			.long 		0xFFFFCC00							;-416*32
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


pointeur_position_dans_les_animations:		.long	anim4

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
flag_mouvement_en_cours:			.long 0
flag_repetition_mouvement_en_cours:			.long 0

pointeur_sprite_boule_violette:			.long sprite_boule_violette
pointeur_table_increments_pas_transformations:		.long		table_increments_pas_transformations

; variables animation
pointeur_vers_coordonnees_points_animation_original:			.long 0
pointeur_vers_coordonnees_points_animation_en_cours:			.long 0
nb_points_animation_en_cours:									.long 0
nb_frame_animation_en_cours:									.long 0
nb_frame_animation:												.long 0
nb_points_animation_en_cours_objet_anime:						.long 0
nombre_etapes_du_mouvement_initial:								.long 0
nombre_etapes_du_mouvement_en_cours:							.long 0
pointeur_index_actuel_mouvement:								.long 0
pointeur_debut_mouvement:										.long 0

; variables gestion du mouvement de l'objet
nombre_etapes_repetition_du_mouvement_en_cours:				.long 0
nombre_etapes_repetition_du_mouvement_initial:				.long 0
pointeur_initial_repetition_mouvement:				.long 0
pointeur_actuel_repetition_mouvement:				.long 0

saveR1:			.long 0

angleX:			.long 0
angleY:			.long 0
angleZ:			.long 0
incrementX:		.long 0
incrementY:		.long 0
incrementZ:		.long 2

X_objet_en_cours:		.long 0
Y_objet_en_cours:		.long 0
Z_objet_en_cours:		.long 0

position_objet_sur_ecran_X:			.long 0
position_objet_sur_ecran_Y:			.long 0


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

	ldr		R2,position_objet_sur_ecran_X
	ldr		R4,position_objet_sur_ecran_Y
	
; unsued : R7 R10 R14
boucle_divisions_calcpoints:
	
	ldr 	r11,[r9],#4			; X point
	ldr 	r12,[r9],#4			; Y point
	ldr 	r13,[r9],#4			; Z point
	ldr		R1,[r9],#4			; n° sprite
	;str		R0,save_numero_sprite

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

	adds	R0,R0,#208						; centrage horizontal
	adds	R0,R0,R2						; + deplacement objet X
	cmp		R0,#0
	bge	.clipping_ok_pas_X_negatif
	mov		R0,#0
.clipping_ok_pas_X_negatif:
	cmp		R0,#384							; 416-32
	blt		.clipping_ok_pas_X_sup_416
	mov		R0,#384
	

.clipping_ok_pas_X_sup_416:
	str 	r0,[r10],#4


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

	adds	R0,R0,#129						; centrage vertical
	adds	R0,R0,R4						; + deplacement objet Y

	cmp		R0,#-32
	bge		.clipping_ok_pas_Y_negatif
	mov		R0,#-32
.clipping_ok_pas_Y_negatif:
	mov		R5,#258							; 258 lignes de hauteur d'ecran
	cmp		R0,R5
	blt		.clipping_ok_pas_Y_sup_258
	;swi		BKP
	mov		R0,R5
	

.clipping_ok_pas_Y_sup_258:

	
	str 	r0,[r10],#4					; stock Y projeté
	
; stock Z pour tri
	str 	R13,[r10],#4
	
	;ldr		R0,save_numero_sprite
	str		R1,[r10],#4				; stock numéro de sprite
	

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
distance_z:				.long 0x400

save_numero_sprite:		.long 0
save_R14:	
	.long 0


matrice:
	.long	1,2,3,4,5,6,7,8,9
	
numero_objet:
	.long 0





all_objects:	
	.long coords_cube

pointeur_SINCOS:		.long SINCOS



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

pointeur_table416:			.long table416
pointeur_table416negatif:			.long table416negatif

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


pointeur_table_mode97:		.long table_mode97
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
	.long		0xe000000c
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


SphereAddress:		.long 0
	.p2align 3
SavedR13:	.long 0
SavedR14:	.long 0
			.long 0
			.long 0
			
plot_boule16x16_position0:
	str 	R13,SavedR13
	str 	R14,SavedR14
	
	ldr		r2,screenaddr1
	add		R2,R2,R0			; R2=R2+X
	ldr		r10,pointeur_table416
	mov		r1,r1,lsl #2		; y * 4
	ldr		r8,[r10,R1]				; r8=y*320
	add		r1,r8,r2			; pointeur ecran + y*320
	
	
	adr R14,Databoule16x16
	ldmia R14!,{R0,R2-R12}

; Line #0
ldrb R13,[R1,#4]!    ; Pos 4
add R0,R0,R13
ldrb R13,[R1,#7]
add R13,R2,R13,lsl#24
stmia R1,{R0,R13}

; Line #1
mov R0,#1
strb R0,[R1,#416-1]! ; Pos 3
stmib R1,{R3-R4}
strb R0,[R1,#9]

; Line #2
ldr R0,[R1,#416-1]!  ; Pos 2
add R0,R5,R0,lsr#16
ldr R13,[R1,#12]
add R13,R8,R13,lsl#16
stmia R1,{R0,R6-R7,R13}

; Line #3
ldrb R0,[R1,#416-2]!   ; Pos 0
add R0,R9,R0
ldrb R13,[R1,#15]
add R13,R12,R13,lsl#24
stmia R1,{R0,R10-R11,R13}

ldmia R14!,{R0,R2-R4,R5-R8,R9-R12}
; Line #4
ldrb R13,[R1,#416]!      ; Pos 0
add R0,R0,R13
ldrb R13,[R1,#15]
add R13,R4,R13,lsl#24
stmia R1,{R0,R2-R3,R13}

; Line #5
add R1,R1,#416
stmia R1,{R5-R8}

; Line #6
add R1,R1,#416
stmia R1,{R9-R12}

ldmia R14!,{R0,R2-R4,R5-R8,R9-R12}
; Line #7
add R1,R1,#416
stmia R1,{R0,R2-R4}

; Line #8
add R1,R1,#416
stmia R1,{R5-R8}

; Line #9
add R1,R1,#416
stmia R1,{R9-R12}

ldmia R14!,{R0,R2-R4,R5-R8,R9-R12}
; Line #10
add R1,R1,#416
stmia R1,{R0,R2-R4}

; Line #11
ldrb R0,[R1,#416]!  ; Pos 0
add R0,R5,R0
ldrb R13,[R1,#15]
add R13,R8,R13,lsl#24
stmia R1,{R0,R6-R7,R13}

; Line #12
ldrb R0,[R1,#416]!  ; Pos 0
add R0,R9,R0
ldrb R13,[R1,#15]
add R13,R12,R13,lsl#24
stmia R1,{R0,R10-R11,R13}

ldmia R14!,{R0,R2-R4,R5-R6,R7-R8}
; Line #13
ldr R13,[R1,#416+2]!  ; Pos 2
add R0,R0,R13,lsr#16
ldr R13,[R1,#12]
add R13,R4,R13,lsl#16
stmia R1,{R0,R2-R3,R13}

; Line #14
mov R0,#1
strb R0,[R1,#416+1]!  ; Pos 3
stmib R1,{R5-R6}
mov R0,#9
strb R0,[R1,#9]

; Line #15
ldrb R0,[R1,#416+2]!    ; Pos 5
add R0,R7,R0
ldrb R13,[R1,#7]
add R13,R8,R13,lsl#24
stmia R1,{R0,R13}


ldr R13,SavedR13
ldr pc,SavedR14

		.p2align 3
Databoule16x16:
; line #0
.byte 0, 1, 34, 34       ; r0
.byte 34, 34, 1, 0       ; r2

; line #1
.byte 35, 164, 164, 164  ; r3
.byte 164, 165, 35, 34   ; r4

; line #2
.byte 0, 0, 34, 165      ; r5
.byte 198, 198, 198, 198 ; r6
.byte 199, 164, 165, 35  ; r7
.byte 34, 1, 0, 0        ; r8

; line #3
.byte 0, 1, 165, 198     ; r9
.byte 200, 200, 200, 200 ; r10
.byte 198, 199, 164, 165 ; r11
.byte 35, 9, 1, 0        ; r12

; line #4
.byte 0, 35, 198, 200    ; r0
.byte 235, 252, 252, 235 ; r2
.byte 200, 198, 164, 164 ; r3
.byte 35, 9, 34, 0       ; r4

; line #5
.byte 9, 165, 198, 200   ; r5
.byte 252, 253, 253, 252 ; r6
.byte 200, 198, 164, 164 ; r7
.byte 165, 9, 35, 1      ; r8

; line #6
.byte 34, 164, 198, 200   ; r9
.byte 252, 253, 253, 252 ; r10
.byte 200, 198, 164, 164 ; r11
.byte 165, 9, 165, 34    ; r12

; line #7
.byte 35, 164, 198, 200  ; r0
.byte 235, 252, 252, 235 ; r2
.byte 200, 198, 164, 164 ; r3
.byte 35, 9, 164, 35     ; r4

; line #8
.byte 35, 164, 199, 198  ; r5
.byte 200, 200, 200, 200 ; r6
.byte 198, 199, 164, 165 ; r7
.byte 34, 9, 199, 35     ; r8

; line #9
.byte 34, 165, 164, 199  ; r9
.byte 198, 198, 198, 198 ; r10
.byte 199, 164, 165, 35  ; r11
.byte 9, 35, 199, 34     ; r12

; line #10
.byte 9, 35, 165, 164    ; r0
.byte 164, 164, 164, 164 ; r2
.byte 164, 165, 35, 9    ; r3
.byte 34, 199, 165, 1    ; r4

; line #11
.byte 0, 34, 35, 165     ; r5
.byte 165, 165, 165, 165 ; r6
.byte 165, 35, 9, 34     ; r7
.byte 165, 199, 35, 0    ; r8

; line #12
.byte 0, 1, 34, 35       ; r9
.byte 35, 35, 35, 35     ; r10
.byte 34, 9, 34, 165     ; r11
.byte 199, 165, 1, 0     ; r12

; line #13
.byte 0, 0, 9, 34        ; r0
.byte 34, 34, 34, 34     ; r2
.byte 34, 35, 165, 199   ; r3
.byte 165, 9, 0, 0       ; r4

; line #14
.byte 34, 34, 35, 35     ; r5
.byte 165, 164, 164, 34  ; r6

; line #15
.byte 0, 1, 9, 34        ; r7
.byte 34, 9, 1, 0        ; r8

.p2align	3

	
Plot_Violette_Sphere_Pos_0:

	; R0=X
	; R1=Y
	str 	R13,SavedR13
	str 	R14,SavedR14




	ldr		r2,screenaddr1
	add		R2,R2,R0			; R2=R2+X
	ldr		r10,pointeur_table416
	mov		r1,r1,lsl #2		; y * 4
	ldr		r8,[r10,R1]				; r8=y*320
	add		r1,r8,r2			; pointeur ecran + y*320


; Eric, copy everything from here and make sure it is on a QWA address +8

Code_To_Plot_Violette_Sphere_Pos_0:

		adr		R14,VioletteSphereDataPos0

; Code must be at QWA address +8, checked by BASIC
; Data must be at QWA address +4, checked by BASIC

; lines #0 and #10
		ldmia R14!,{R2-R4,R5-R12}  ; 11 registers, exits QWA
; line #0
		ldr R0,[R1,#10]!        ; Pos 10  #2*4+2
		strb R5,[R1,#10]        ; r5b = 1   #-10+5*4
		add R0,R2,R0,lsr#16
		stmia R1,{R0,R3-R4}       ; Exits pos R10, unchanged

; line #10
		ldrb R13,[R1,#3221]! 		; Pos 31    #-10+320*(10-0)+31 missed opportunity
		add R13,R12,R13,lsl#24
		stmda R1,{R5-R11,R13}    ; exits pos 31,unchanged

; line #9
		ldmia R14!,{R2,R8-R11}    ; 5 registers, exits QWA + 4
; line #9
; r6 is reused
; r7 is rused
; r12 is reused
; line #9
		ldrb R13,[R1,#-320]!         ; Pos 31   #+320*(9-10)
		ldrb R0,[R1,#-31]            ; Pos 31, unchanged
		add R13,R12,R13,lsl#24
		add R0,R2,R0
		stmda R1,{R0,R6-R11,R13}

; lines #24
; line #6
		ldr R0,[R1,#-989]!    ; Pos 2   #-31+320*(6-9)+2
		ldmia R14!,{R2-R8,R9-R12}       ; 11 registers, exits QWA
		add R0,R2,R0,lsr#16
		stmia R1,{R0,R3-R8}            ; Pos R2, unchanged
; Note 5 at position 6*4 isnt plotted now

; line #1
		ldrb R0,[R1,#-1594]!  ; Pos 8    #-2+320*(1-6)+2*4
		add R0,R9,R0
		stmia R1,{R0,R10-R12}          ; Exits pos R8, unchanged
		
; lines #-1594
		ldmia R14!,{R2-R7,R8-R13}       ; 12 registers
; line #3
; starts with the end
		ldr R0,[R1,#658]! ; Pos 26   ; #-8+320*(3-1)+6*4+2
		add R7,R7,R0,lsl#16
		ldrb R0,[R1,#-22]        ; Pos 26, unchanged
		add R0,R2,R0
		stmda R1,{R0,R3-R7}      ; Missed ldr(b) or str(b)

; line #4
		ldrb R0,[R1,#321]! ; Pos 27     ; #-26+320*(4-3)+6*4+3
		add R13,R13,R0,lsl#24
		stmda R1,{R8-R13}             ; Exits pos 27, unchanged

; pixel 5 at the end of line #5
; 5 is in 8b lets plot 5 at the beginning of line #5
		strb R8,[R1,#296]!   ; Pos 3    ; #-27+320*(5-4)+3

; Plot 5 also at pos 24 on line #2
		strb R8,[R1,#-939]    ; #-3+320*(2-5)+6*4
; can be used for the missed opportunity above by changing offset value

; lines #-939
		ldmia R14!,{R2-R7,R8-R11}        ; 6 + 4 = 10 registers, exits QWA + 8
; line #5
		stmib R1,{R2-R7}              ; Note use of ib to increment 1st
; Exits pos R3, unchanged
; 5 was alreay plotted

; line #2
		strb R10,[R1,#-956]! ; Pos 7  ; #-3+320*(2-5)+1*4+3
; r10b = 164
		stmib R1,{R8-R11}             ; Note use of ib to increment 1st
; 5 was alreay plotted

		adr		R14,VioletteSphere7
		
; Data must be QWA, checked by BASIC
; line #7
		ldmia R14!,{R2-R9}            ; 8 registers, exits QWA
		ldr R0,[R1,#1595]! ; Pos 2    #-7+(7-2)*320+2
		add R0,R2,R0,lsr#16
		ldr R13,[R1,#28]             ; #-2+7*4+2
		add R13,R9,R13,lsl#16
		stmia R1,{R0,R3-R8,R13}         ; missed opportunity

; line #8
		ldmia R14!,{R2-R9}
		ldrb R0,[R1,#318]! ; Pos 0   #-2+(8-7)*320
		add R0,R2,R0
		ldr R13,[R1,#30]          ; #7*4+2
		add R13,R9,R13,lsl#16
		stmia R1,{R0,R3-R8,R13}

; line #11
		ldmia R14!,{R2-R9}
		ldrb R13,[R1,#991]! ; Pos 31   #(11-8)*320+7*4+3
		add R13,R9,R13,lsl#24
		stmda R1,{R2-R8,R13}

; line #12
		ldmia R14!,{R2-R9}
		add R1,R1,#320; Pos 31   #320*1  missed opportunity
		stmda R1,{R2-R9}

; line #13
		ldmia R14!,{R2-R9}
		add R1,R1,#320; Pos 31     #320*1
		stmda R1,{R2-R9}        ; missed opportunity

; line #14
		ldmia R14!,{R0,R2,R3,R4-R7,R8-R10,R12-R13}    ; 11 registers, exits QWA +12
		add R1,R1,#320; Pos 31   #320*1
		stmda R1,{R0,R2,R4-R7,R12-R13}  ; Pos 31, unchanged

; line #15
		add R1,R1,#320; Pos 31      #320*1
		stmda R1,{R0,R2,R3,R8-R9,R10,R12-R13} ; Pos 31, unchanged

; line #25
		strb R12,[R1,#3172]!   ; #-31+(25-15)*320+3 Pos 3
		strb R12,[R1,#25]               ; #-3+7*4 can be used for missed opportunity above with recomputed offset
; r12b = 2
		ldmia R14!,{R0,R2-R6,R7-R9,R10-R13}       ; 13 registers, exits QWA missed opportunity
		stmib R1,{R0,R2-R6}

; line #31
		ldr R0,[R1,#1927]!       ; Pos 10 missed opportunity  #-3+(31-25)*320+2*4+2
		add R0,R7,R0,lsr#16
		strb R10,[R1,#10]        ; #-10+5*4
; r10b = 1
		stmia R1,{R0,R8-R9}

; line #30
		ldrb R0,[R1,#-307]!      ; Pos 23       #-10+(30-31)*320+5*4+3
		add R13,R13,R0,lsl#24
		stmda R1,{R10-R13}        ; missed opportunity

; line #29
		strb R10,[R1,#-336]!     ; Pos 7      #-23+(29-30)*320+1*4+3
; r10b = 1
		ldmia R14!,{R0,R2-R4,R5-R12}
		stmib R1,{R0,R2-R4}
		strb R0,[R1,#17]
; r0b = 2

; line #24
		ldr R0,[R1,#-1605]!      ; Pos 2    #-7+(24-29)*320+2
		add R0,R5,R0,lsr#16
		ldr R13,[R1,#28]         ; #-2+7*4+2
		add R13,R12,R13,lsl#16; missed opportunity
		stmia R1,{R0,R6-R11,R13}

		ldmia R14!,{R0,R2-R8}
; line #16
		sub R1,R1,#2560; Pos 2
		stmia R1,{R0,R2-R8}        ; missed opportunity

		ldmia R14!,{R0,R2-R8}
; line #17
		add R1,R1,#320; Pos 2
		stmia R1,{R0,R2-R8}

		ldmia R14!,{R0,R2-R8}      ; missed opportunity
; line #18
		add R1,R1,#320; Pos 2
		stmia R1,{R0,R2-R8}

		ldmia R14!,{R0,R2-R8}
; line #19
		add R1,R1,#320; Pos 2  missed opportunity
		stmia R1,{R0,R2-R8}

ldmia R14!,{R0,R2-R8}
; line #20
		add R1,R1,#320; Pos 2
		stmia R1,{R0,R2-R8}

; line #21
		ldrb R13,[R1,#349]!      ; Pos 31     #-2+(21-20)*320+7*4+3
		ldmia R14!,{R0,R2-R8}
		add R13,R8,R13,lsl#24
		stmda R1,{R0,R2-R7,R13}

; line #22
		ldrb R0,[R1,#289]!       ; Pos 0    #-31+(22-21)*320
		ldmia R14!,{R2,R3-R9}
		add R0,R2,R0
		ldrb R13,[R1,#31]        ; #7*4+3
		add R13,R9,R13,lsl#24; missed opportunity
		stmia R1,{R0,R3-R8,R13}     

		ldmia R14!,{R2,R3-R9}
; line #23
		ldr R0,[R1,#322]!        ; Pos 2 #(23-22)*320+2
		ldr R13,[R1,#28]         ;  #-2+7*4+2
		add R0,R2,R0,lsr#16
		add R13,R9,R13,lsl#16
		stmia R1,{R0,R3-R8,R13}

		ldmia R14!,{R0,R2-R6,R7-R12} ; 12 registers  missed opportunity
; line #26
		add R1,R1,#960; Pos 2
		stmib R1,{R0,R2-R6}

; line #27
		ldrb R0,[R1,#322]!       ; Pos 4   #(27-26)*320-2+1*4
		ldrb R13,[R1,#23]        ; #-4+6*4+3
		add R0,R7,R0
		add R13,R12,R13,lsl#24
		stmia R1,{R0,R8-R11,R13}    

; line #28
		ldr R0,[R1,#322]!        ; #(28-27)*320-4+1*4+2 Pos 6
		ldmia R14!,{R2-R7}        
		add R0,R2,R0,lsr#16
		ldr R13,[R1,#20]
		add R13,R7,R13,lsl#16; missed opportunity
		stmia R1,{R0,R3-R6,R13}
; sortie
		ldr R13,SavedR13
		ldr pc,SavedR14

		.p2align 4

VioletteSphereDataPos0:   ; Data must be at QWA address +4, checked by BASIC
; 3 registers for line #0
        .byte    0, 0, 1, 2             ; r2
        .byte    131, 164, 164, 164     ; r3
        .byte    164, 131, 2, 5         ; r4

; 8 registers for line #10
        .byte    1, 164, 215, 219       ; r5
        .byte    219, 253, 254, 254     ; r6
        .byte    255, 255, 254, 254     ; r7
        .byte    253, 219, 253, 215     ; r8
        .byte    216, 215, 186, 182     ; r9
        .byte    169, 182, 169, 131     ; r10
        .byte    164, 164, 131, 2       ; r11
        .byte    5, 5, 1, 0             ; r12

; 5 registers for line #10
        .byte    0, 2, 182, 219      ; r2
        .byte    253, 219, 219, 215  ; r8
        .byte    186, 215, 182, 169  ; r9
        .byte    182, 169, 164, 164  ; r10
        .byte    169, 164, 131, 12   ; r11

; 7 registers for line #6
        .byte    0, 0, 1, 164        ; r2
        .byte    216, 219, 219, 253  ; r3
        .byte    253, 253, 253, 219  ; r4
        .byte    216, 215, 186, 182  ; r5
        .byte    182, 169, 169, 164  ; r6
        .byte    164, 131, 131, 164  ; r7
        .byte    131, 131, 12, 5     ; r8

; 4 registers for line #1
        .byte    0, 164, 182, 215    ; r9
        .byte    216, 216, 215, 182  ; r10
        .byte    169, 169, 164, 131  ; r11
        .byte    2, 5, 5, 1          ; r12

; lines #1
; 2-R7, 8-13 12 registers
; 6 registers for line #3
        .byte    0, 5, 169, 216       ; r2
        .byte    219, 216, 215, 182   ; r3
        .byte    182, 182, 169, 169   ; r4
        .byte    164, 164, 164, 131   ; r5
        .byte    12, 2, 2, 5          ; r6
        .byte    5, 5, 0, 0           ; r7

; 6 registers for line #4
        .byte    5, 169, 216, 219     ; r8
        .byte    216, 215, 215, 215   ; r9
        .byte    186, 182, 182, 169   ; r10
        .byte    169, 164, 164, 164   ; r11
        .byte    131, 12, 2, 12       ; r12
        .byte    12, 5, 5, 0          ; r13

; 6 registers for line #5
        .byte    169, 216, 219, 219  ; r2
        .byte    219, 219, 219, 216  ; r3
        .byte    215, 186, 182, 182  ; r4
        .byte    169, 169, 164, 164  ; r5
        .byte    164, 131, 12, 131   ; r6
        .byte    131, 12, 5, 5       ; r7

; 4 registers for line #2
        .byte    186, 219, 216, 216  ; r8
        .byte    215, 182, 169, 164  ; r9
        .byte    164, 164, 131, 131  ; r10
        .byte    2, 2, 5, 5          ; r11

	.p2align 4
VioletteSphere7:	       ; Must be QWA, checked by BASIC
; 8 registers for line #7
        .byte    0, 0, 2, 186        ; r2
        .byte    219, 219, 253, 253  ; r3
        .byte    254, 254, 253, 253  ; r4
        .byte    219, 216, 215, 186  ; r5
        .byte    182, 182, 169, 169  ; r6
        .byte    164, 164, 131, 169  ; r7
        .byte    164, 131, 131, 2    ; r8
        .byte    5, 1, 0, 0          ; r9

; line #8
; 8 registers for line #8
        .byte    0, 1, 164, 219      ; r2
        .byte    219, 253, 253, 254  ; r3
        .byte    254, 254, 254, 253  ; r4
        .byte    253, 219, 216, 215  ; r5
        .byte    182, 186, 182, 182  ; r6
        .byte    164, 169, 131, 169  ; r7
        .byte    164, 164, 131, 12   ; r8
        .byte    5, 5, 0, 0          ; r9

; line #11
; 8 registers for line #11
        .byte    5, 169, 215, 219       ; r2
        .byte    219, 253, 253, 254     ; r3
        .byte    254, 254, 254, 253     ; r4
        .byte    253, 219, 253, 215     ; r5
        .byte    216, 215, 186, 182     ; r6
        .byte    169, 169, 169, 164     ; r7
        .byte    131, 131, 2, 2         ; r8
        .byte    5, 2, 5, 0             ; r9

; line #12
; 8 registers for line #12
        .byte    2, 182, 215, 219       ; r2
        .byte    219, 219, 253, 253     ; r3
        .byte    254, 254, 253, 253     ; r4
        .byte    219, 253, 219, 216     ; r5
        .byte    215, 215, 186, 182     ; r6
        .byte    169, 169, 164, 131     ; r7
        .byte    131, 12, 5, 2          ; r8
        .byte    5, 2, 2, 1             ; r9

; line #13
; 8 registers for line #13
        .byte    131, 186, 215, 219     ; r2
        .byte    219, 219, 219, 253     ; r3
        .byte    253, 253, 253, 219     ; r4
        .byte    253, 219, 216, 215     ; r5
        .byte    215, 186, 182, 169     ; r6
        .byte    169, 164, 131, 131     ; r7
        .byte    12, 2, 5, 5            ; r8
        .byte    5, 2, 131, 5           ; r9

; line #14
; 8 registers for line #14
        .byte    164, 186, 215, 219     ; r0
        .byte    219, 216, 219, 219     ; r2

        .byte    219, 219, 219, 219     ; r3 for line #15

        .byte    253, 253, 253, 253     ; r4
        .byte    219, 216, 215, 219     ; r5
        .byte    186, 182, 169, 164     ; r6
        .byte    164, 131, 131, 12      ; r7

        .byte    216, 215, 219, 186     ; r8 for line #15
        .byte    182, 169, 164, 131     ; r9 for line #15

        .byte    131, 131, 12, 2        ; r10 for line #15

        .byte    2, 5, 5, 5             ; r12
        .byte    5, 2, 164, 2           ; r13

; line #15
; see above

; line #15
        .byte    169, 182, 164, 164     ; r0
        .byte    164, 164, 131, 12      ; r2
        .byte    164, 131, 12, 12       ; r3
        .byte    131, 131, 12, 2        ; r4
        .byte    12, 131, 164, 169      ; r5
        .byte    182, 215, 253, 215     ; r6

; line #15
        .byte    0, 0, 1, 1             ; r7
        .byte    5, 5, 2, 2             ; r8
        .byte    2, 2, 5, 5             ; r9

; line #15
        .byte    1, 5, 2, 2             ; r10
        .byte    2, 2, 2, 12            ; r11
        .byte    131, 131, 164, 164     ; r12
        .byte    164, 131, 2, 0         ; r13

; line #15
        .byte    2, 164, 164, 131       ; r0
        .byte    12, 2, 5, 5            ; r2
        .byte    2, 2, 131, 164         ; r3
        .byte    169, 169, 169, 164     ; r4

; line #15
        .byte    0, 0, 5, 164           ; r5
        .byte    182, 169, 164, 164     ; r6
        .byte    164, 164, 131, 131     ; r7
        .byte    169, 164, 131, 131     ; r8
        .byte    12, 2, 131, 12         ; r9
        .byte    2, 2, 131, 131         ; r10
        .byte    164, 169, 215, 219     ; r11
        .byte    169, 1, 0, 0           ; r12

; line #15
        .byte    164, 186, 215, 216     ; r0
        .byte    219, 216, 186, 215     ; r2
        .byte    215, 215, 215, 215     ; r3
        .byte    215, 186, 182, 182     ; r4
        .byte    169, 164, 131, 131     ; r5
        .byte    164, 169, 169, 131     ; r6
        .byte    12, 2, 5, 5            ; r7
        .byte    2, 2, 169, 2           ; r8

; line #15
        .byte    164, 186, 215, 215     ; r0
        .byte    219, 216, 186, 182     ; r2
        .byte    186, 215, 215, 186     ; r3
        .byte    182, 182, 182, 169     ; r4
        .byte    164, 131, 131, 164     ; r5
        .byte    169, 164, 164, 164     ; r6
        .byte    131, 12, 2, 5          ; r7
        .byte    2, 131, 169, 2         ; r8

; line #15
        .byte    131, 182, 215, 215     ; r0
        .byte    216, 219, 215, 186     ; r2
        .byte    182, 182, 182, 182     ; r3
        .byte    186, 169, 182, 169     ; r4
        .byte    164, 131, 164, 169     ; r5
        .byte    164, 131, 2, 5         ; r6
        .byte    5, 5, 5, 5             ; r7
        .byte    2, 164, 169, 2         ; r8

; line #15
        .byte    2, 169, 215, 215       ; r0
        .byte    215, 216, 219, 215     ; r2
        .byte    186, 182, 182, 186     ; r3
        .byte    182, 169, 169, 182     ; r4
        .byte    182, 169, 169, 164     ; r5
        .byte    131, 2, 5, 5           ; r6
        .byte    5, 5, 5, 2             ; r7
        .byte    131, 169, 169, 5       ; r8

; line #15
        .byte    5, 164, 215, 215       ; r0
        .byte    215, 215, 216, 216     ; r2
        .byte    216, 215, 186, 182     ; r3
        .byte    169, 169, 164, 164     ; r4
        .byte    164, 164, 131, 164     ; r5
        .byte    2, 5, 5, 5             ; r6
        .byte    5, 5, 5, 2             ; r7
        .byte    164, 182, 164, 1       ; r8

; line #15
        .byte    1, 131, 182, 215       ; r0
        .byte    215, 215, 215, 182     ; r2
        .byte    169, 169, 169, 169     ; r3
        .byte    182, 164, 164, 164     ; r4
        .byte    164, 131, 12, 164      ; r5
        .byte    2, 5, 5, 5             ; r6
        .byte    5, 2, 2, 131           ; r7
        .byte    169, 182, 2, 0         ; r8

; line #15
        .byte    0, 5, 169, 215         ; r2
        .byte    215, 182, 182, 169     ; r3
        .byte    164, 164, 164, 164     ; r4
        .byte    169, 182, 164, 131     ; r5
        .byte    131, 12, 2, 131        ; r6
        .byte    2, 2, 5, 5             ; r7
        .byte    2, 12, 131, 169        ; r8
        .byte    215, 182, 1, 0         ; r9

; line #15
        .byte    0, 0, 131, 182         ; r2
        .byte    215, 169, 169, 164     ; r3
        .byte    164, 131, 131, 164     ; r4
        .byte    164, 169, 169, 164     ; r5
        .byte    12, 2, 2, 2            ; r6
        .byte    12, 2, 2, 2            ; r7
        .byte    131, 164, 169, 215     ; r8
        .byte    216, 131, 0, 0         ; r9

; line #15
        .byte    2, 169, 169, 164       ; r0
        .byte    164, 131, 12, 2        ; r2
        .byte    131, 12, 2, 2          ; r3
        .byte    12, 12, 2, 12          ; r4
        .byte    131, 164, 169, 182     ; r5
        .byte    215, 219, 215, 164     ; r6

; line #15
        .byte    0, 2, 169, 169         ; r7
        .byte    164, 131, 2, 2         ; r8
        .byte    12, 2, 5, 2            ; r9
        .byte    5, 5, 2, 131           ; r10
        .byte    164, 169, 182, 215     ; r11
        .byte    215, 215, 164, 0       ; r12

; line #15
        .byte    0, 0, 2, 164           ; r2
        .byte    169, 164, 131, 12      ; r3
        .byte    2, 5, 2, 5             ; r4
        .byte    5, 5, 2, 131           ; r5
        .byte    164, 169, 182, 182     ; r6
        .byte    169, 2, 0, 0           ; r7



.p2align	3



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
; mouvement de l'objet
		.long		-1	; table_de_mouvement, -1 = pas de mouvement
		.long		0	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

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
; mouvement de l'objet
		.long		-1	; table_de_mouvement, -1 = pas de mouvement
		.long		0	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

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
; mouvement de l'objet
		.long		-1	; table_de_mouvement, -1 = pas de mouvement
		.long		0	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

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
; mouvement de l'objet
		.long		-1	; table_de_mouvement, -1 = pas de mouvement
		.long		0	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

		
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
; mouvement de l'objet
		.long		-1	; table_de_mouvement, -1 = pas de mouvement
		.long		0	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

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
; mouvement de l'objet
		.long		-1	; table_de_mouvement, -1 = pas de mouvement
		.long		0	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

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
; mouvement de l'objet
		.long		-1	; table_de_mouvement, -1 = pas de mouvement
		.long		0	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

		.long		-1				;	  - zoom / position observateur en Z

; fin de l'anim
		.long		0

anim3:
		.long		dummy			;     - pointeur vers objet
		.long		200,0,50			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		3,3,2			;     - increment angle X, increment angle Y , increment angle Z
		.long		0,0,0			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		240				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		0				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		coordonnees_points_carre				;     - pointeur vers data animation, 0 = pas d'anim
		.long		64				;	  - nombre de points à animer
		.long		40				;     - nombre d'étapes en frame, 0 = pas d'anim
; mouvement de l'objet
		.long		-1	; table_de_mouvement, -1 = pas de mouvement
		.long		0	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

		.long		0x200			;	  - zoom / position observateur en Z
		
		.long		dummy			;     - pointeur vers objet
		.long		200,0,50			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		-3,-3,-2			;     - increment angle X, increment angle Y , increment angle Z
		.long		-1,-1,-1		; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		240				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		0				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		coordonnees_points_carre				;     - pointeur vers data animation, 0 = pas d'anim
		.long		64				;	  - nombre de points à animer
		.long		40				;     - nombre d'étapes en frame, 0 = pas d'anim
; mouvement de l'objet
		.long		-1	; table_de_mouvement, -1 = pas de mouvement
		.long		0	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

		.long		-1			;	  - zoom / position observateur en Z

; ----------------fin de l'anim
		.long		0

anim4:
		.long		cube1			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		2,2,2			;     - increment angle X, increment angle Y , increment angle Z
		.long		0,0,0			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		256				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		0				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		0				;     - pointeur vers data animation, 0 = pas d'anim
		.long		0				;	  - nombre de points à animer
		.long		0				;     - nombre d'étapes en frame, 0 = pas d'anim
; mouvement de l'objet
		.long		table_mouvement_vertical_vers_le_bas	; table_de_mouvement, -1 = pas de mouvement
		.long		260	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

		.long		0x630			;	  - zoom / position observateur en Z

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

; tables des mouvements
; N * X , Y , Z

		.p2align 2
table_mouvement_vertical_vers_le_bas:
		.incbin		"descente_verticaleXY100.bin"			; 50 étapes		X,Y,Z
		.p2align 2

table_mouvement_vertical_vers_le_haut:
		.incbin		"montee_verticaleXY.bin"				; 50 étapes		X,Y
		.p2align 2

sprite_boule_violette:
		.incbin		"sphere16x16pourArchi.bin"
		.p2align 2

; structure d'une animation:
; X,Y,Z, N° sprite
; 64 points, 20 étapes
coordonnees_points_carre:
		.include	"RIPPLEDZ_A.DAT"

		.p2align 3
		
		
nom_Rasterman:			.byte		"rm24",0
nom_QT:					.byte		"qt",0
nom_module_Rasterman:	.byte		"Rasterman",0
nom_module_QT:			.byte		"QTMTracker",0
		.p2align 4
module97:		.incbin	"97,ffa"
				.p2align 3

;.section bss,"u"
table416negatif:
			.skip		32*4
table416:	.skip		260*4

coordonnees_transformees:	.space 1024
coordonnees_projetees:	.space 1024
index_et_Z_pour_tri:	.space	4*256
	.p2align 4
table_increments_pas_transformations:		.space			64*7*4
; X,Y,Z,increment pas , tout multiplié par 2^15
		.p2align 4
buffer_coordonnees_objet_transformees:		.space			64*4*4
	.p2align 4
buffer_calcul1:
		.skip		512*64*16
	.p2align 4
buffer_calcul2:		
		.skip		512*64*16
