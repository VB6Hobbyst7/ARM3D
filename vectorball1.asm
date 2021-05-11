; !!! faire des sequences d'elements d'animation pour repeter certains mouvements

; !!!!!   ==============>    faire un scrolling completement dynamique en 3D

; idées objets : transformation décompte de chiffres, 
; 

; reprendre la version du 10/05 des spheres violettes

; OK :table pour les positions de boules
; - OK :  compresser les données : position dans mémoire vidéo <<4 + n° sprite
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


.equ	nombre_de_boules_maxi, 64
.equ	taille_buffer_calculs, 1024*nombre_de_boules_maxi*4

.equ Screen_Mode, 97
.equ	IKey_Escape, 0x9d

.equ	etape_en_cours, 0x7000

.include "swis.h.asm"

	.org 0x8000
	.balign 8


main:
				


	


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


	SWI		0x01
.byte	"         Please wait, overclocking CPU",0
	.p2align 2

; gestion de la RAM
; lecture des infos actuelles
	mov		R0,#-1
	mov		R1,#-1
	SWI		0x400EC			; Wimp_SlotSize 

	mov		R0,#taille_buffer_calculs*4
	mov		R1,#-1
	SWI 	0x400EC			; Wimp_SlotSize 

	mov		R1,#0			; stop color flashing
	mov		R0,#9
	swi		OS_Byte

	bl 		creer_table_416


	mov		R0,#0
	str		R0,nb_frames_total_calcul

; on démarre une sequence de calculs, donc on pointe au debut du buffer de calcul
	ldr		R5,pointeur_buffer_en_cours_de_calcul
	str		R5,pointeur_actuel_buffer_en_cours_de_calcul

; --------------- début init des  calculs --------------------------
boucle_lecture_animations:

; tracage1
	mov		R12,#etape_en_cours
	mov		R13,#1
	str		R13,[R12]
	
	ldr		R1,pointeur_buffer_calculs_intermediaire
	str		R1,pointeur_buffer_calculs_intermediaire_actuel
	
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

; tracage2
	mov		R12,#etape_en_cours
	mov		R13,#2
	str		R13,[R12]


	mov		R0,#1
	str		R0,flag_classique_en_cours

.ok_objet_rotation_classique:
	str		R4,nb_points_objet_en_cours_objet_classique
	str		R4,nb_sprites_en_cours_calcul
	str		R4,nb_points_objet_en_cours
	
	
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
; tracage3	
	mov		R12,#etape_en_cours
	mov		R13,#3
	str		R13,[R12]


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
	ble		.pas_de_mouvement_de_l_objet

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

; tracage4	
	mov		R12,#etape_en_cours
	mov		R13,#4
	str		R13,[R12]


boucle_calcul_frames_classiques:

; gestion du mouvement de l'objet en entier
; 
	

	ldr		R0,flag_mouvement_en_cours
	cmp		r0,#0
	beq		.pas_de_mouvement_pendant_calcul
; on applique la table de mouvements

	; tracage	
	mov		R12,#etape_en_cours
	mov		R13,#5
	str		R13,[R12]


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

; tracage5	
	mov		R12,#etape_en_cours
	mov		R13,#6
	str		R13,[R12]





	; si transformation :
	; on calcul les points transformes dans pointeur_buffer_coordonnees_objet_transformees

	ldr		R5,flag_transformation_en_cours
	cmp		R5,#1
	bne		.pas_de_transformation
	
	bl		realisation_transformation

.pas_de_transformation:
; tracage6	
	mov		R12,#etape_en_cours
	mov		R13,#7
	str		R13,[R12]



	ldr		R5,pointeur_buffer_calculs_intermediaire
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

; tracage	
	mov		R12,#etape_en_cours
	mov		R13,#8
	str		R13,[R12]


	ldr		R2,pointeur_coordonnees_projetees
	str		R2,pointeur_coordonnees_projetees_actuel
	
	ldr		R2,nb_points_objet_en_cours_objet_classique
	str		R2,nb_points_objet_en_cours


	bl		calc3D

.pas_de_rotation_classique_en_boucle:

; tracage	
	mov		R12,#etape_en_cours
	mov		R13,#9
	str		R13,[R12]

; ----------------------

; animation à gérer avant le tri
; on complete pointeur_coordonnees_projetees_actuel
; il faut augmenter nb_points_objet_en_cours avant le tri

	ldr		R2,flag_animation_en_cours
	cmp		R2,#0
	beq		.pas_d_animation_dans_la_boucle_de_calcul_principale

; tracage	
	mov		R12,#etape_en_cours
	mov		R13,#10
	str		R13,[R12]

	
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
; tracage	
	mov		R12,#etape_en_cours
	mov		R13,#11
	str		R13,[R12]
	
	bl		bubblesort_XYZ

; tracage	
	mov		R12,#etape_en_cours
	mov		R13,#12
	str		R13,[R12]


	bl		copie_dans_buffer_calcul_final
	
	; tracage	
	mov		R12,#etape_en_cours
	mov		R13,#13
	str		R13,[R12]

	
; on avance dans le gros buffer final	
	ldr		R2,pointeur_actuel_buffer_en_cours_de_calcul
	ldr		R1,nb_points_objet_en_cours
;	add		R2,R2,R1,asl #4			; + nb points * 16
	add		R2,R2,R1,asl #2			; + nb points * 4
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

; tracage	
	mov		R12,#etape_en_cours
	mov		R13,#14
	str		R13,[R12]


	b		boucle_lecture_animations

sortie_boucle_animations:

	
; on swappe calcul et affichage
	ldr		R1,pointeur_buffer_en_cours_d_affichage
	ldr		R2,pointeur_buffer_en_cours_de_calcul
	str		R2,pointeur_buffer_en_cours_d_affichage
	str		R2,pointeur_actuel_buffer_en_cours_d_affichage
	str		R1,pointeur_buffer_en_cours_de_calcul
	
	ldr		R0,nb_sprites_en_cours_calcul
	str		R0,nb_sprites_en_cours_affichage
	
	ldr		R0,nb_frames_total_calcul
	str		R0,nb_frames_total_affichage
	str		R0,nb_frame_en_cours_affichage

	;ldr		R0,nb_frames_total_affichage
	;ldr		R12,pointeur_buffer_en_cours_d_affichage
	;str		R0,nb_frame_en_cours_affichage
	;str		R12,pointeur_actuel_buffer_en_cours_d_affichage



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
	mov		R3,#0
	mov		r0,#26832/2
.clsall:
	str		r3,[r1],#4
	str		r3,[r2],#4
	subs	r0,r0,#1
	bne		.clsall
	
	ldr		r3,couleur2
	mov		R3,#0
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

valeur_ecran_forcee:			.long	((416*140)+128) * 16
valeur_ecran_forcee0:			.long	((416*140)+128) * 16
valeur_ecran_forcee1:			.long	((416*160)+129) * 16
valeur_ecran_forcee2:			.long	((416*180)+130) * 16
valeur_ecran_forcee3:			.long	((416*200)+131) * 16


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



	
;	ldr		R0,valeur_ecran_forcee0
;	mov		R0,R0,asr #4
;	bl		pos0v2
	
;	ldr		R0,valeur_ecran_forcee1
;	mov		R0,R0,asr #4
;	bl		pos1v2

;	ldr		R0,valeur_ecran_forcee2
;	mov		R0,R0,asr #4
;	bl		pos2v2

;	ldr		R0,valeur_ecran_forcee3
;	mov		R0,R0,asr #4
;	bl		pos3v2


	ldr		R12,pointeur_actuel_buffer_en_cours_d_affichage
	ldr		R11,nb_sprites_en_cours_affichage

;	ldr		R0,valeur_ecran_forcee2
;	str		R0,valeur_ecran_forcee


boucle_affiche_sprites_vbl:	

	
	ldr		R0,[R12],#4			; octet compressé : position mémoire ecran + n° sprite


	str		R11,saveR11_local
	str		R12,saveR12_local



; décodage
; R0 = Y*416 +x << 4 + n° sprite
; cible : R0=position, R5 = X n° décalage, R6 = n° sprite
	and		R6,R0,#0b111111					; R6 = position X * 16 + n° sprite
	mov		R0,R0,asr #4
	adr		R1,table_positions_sprites64
	ldr		R15,[R1,R6, lsl #2]				; R3 = adresse routine sprite
	
retour_copie_sprite:
	;bl		copie_sprite

	ldr		R11,saveR11_local
	ldr		R12,saveR12_local



	ldr		R0,valeur_ecran_forcee2
	str		R0,valeur_ecran_forcee


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

		.p2align		2
pointeur_module97:		.long	module97

; en fonction de X modulo 4
table_positions_sprites64:
table_spritespos0:
	.rept	16
	.long	pos0v2
	.endr
table_spritespos1:
	.rept	16
	.long	pos1v2
	.endr
table_spritespos2:
	.rept	16
	.long	pos2v2
	.endr
table_spritespos3:
	.rept	16
	.long	pos3v2
	.endr

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

; animedz
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

; variables buffer intermediaire pour reduction de taille du buffer de calcul
pointeur_buffer_calculs_intermediaire:			.long buffer_calculs_intermediaire
pointeur_buffer_calculs_intermediaire_actuel:			.long buffer_calculs_intermediaire

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

;----------------------------------------------------------
; projection des points dans pointeur_coordonnees_projetees
; calculs des divisons X/Z et Y/Z
;----------------------------------------------------------

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
	
	LDRGT   R8,[R12,R2,LSL #4]	; n° sprite 1
	LDRGT   R9,[R12,R3,LSL #4]	; n° sprite 2
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


copie_dans_buffer_calcul_final:

; encodage :
; 9 bits pour X
; 9 bits pour Y
; 4 bits pour n° sprite
; = 22 bits , reste 10 bits

; X << 13
; Y << 4
; X peut etre negatif
; Y ne peut pas etre negatif
; n° ne peut pas etre negatif

	ldr		R0,nb_points_objet_en_cours
	
	ldr		R11,pointeur_coordonnees_projetees					; source
	ldr		R12,pointeur_actuel_buffer_en_cours_de_calcul		; destination
	
	ldr		r13,pointeur_table416
	
;		swi		BKP
.boucle_copie_avec_reduction:

	
	
	ldr		R1,[R11],#4				; X projeté écran
	ldr		R2,[R11],#4				; Y projeté écran
	add		R11,R11,#4				; on saute le Z
	ldr		R3,[R11],#4				; n° sprite

; on calcule le position ecran
	ldr		R2,[r13,R2,asl #2]		; R2=Y * 416
	adds	R2,R2,R1				; R1 = position mémoire écran : X + 416 * Y
; valeur maxi : 107 328 : 18 bits
; il faut garder le bas du X pour choisir le bon décalage de  sprite
;	mov		R2,R2,asl #2			; 2 bits pour position X 

;	and		R1,R1,#0b11				; on garde la position X sur 4
;	adds	R2,R2,R1				; on ajoute à la position mémoire
	mov		R2,R2,asl #4			; + 4 bits pour le n° sprite 
	adds	R2,R2,R3				; + n° sprite		
	
	str		R2,[R12],#4
; décodage
; R1 = Y*416 +x << 4 + n° sprite
; cible : R4=position, R5 = X n° décalage, R6 = n° sprite
;	and		R6,R2,#0b1111
;	mov		R2,R2,asr #4
;	and		R5,R2,#0b11
;	mov		R4,R2,asr #2
	
	
	
	subs	R0,R0,#1
	bgt		.boucle_copie_avec_reduction
	

	mov		pc,lr

masque_decodage_X:			.long 0b11111111111111111110000000000000

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

;**********************************************************************
;
; Sphere 16x16 violette position 0 V2
;
;**********************************************************************
			

	.p2align 4
pos0v2:
;	str 	R13,SavedR13
;	str 	R14,SavedR14


	ldr		r2,screenaddr1
	add		R1,R2,R0			; R2=R2+X


		adr R14,data_pos0v2            ; Data must be QWA ( checked by BASIC )
; Line #0
		ldrb R13,[R1,#4]!        ; Pos 4



 ldmia R14!,{R0,R2-R12}     ; 12 registers, starts QWA, exits QWA
 add R0,R0,R13
 ldrb R13,[R1,#7]
 add R13,R2,R13,lsl#24		; MMOO
 stmia R1,{R0,R13}




; Line #1
 mov R0,#1
 strb R0,[R1,#415]!  		; Pos 3
 strb R0,[R1,#9]
 stmib R1,{R3-R4}

; Line #2
 ldr R0,[R1,#415]!   ; Pos 2
 add R0,R5,R0,lsr#16
 ldr R13,[R1,#12]
 add R13,R8,R13,lsl#16
 stmia R1,{R0,R6-R7,R13}

; Line #3
 ldrb R0,[R1,#414]!    ; Pos 0
 ldrb R13,[R1,#15]
 add R0,R9,R0
 add R13,R12,R13,lsl#24
 stmia R1,{R0,R10-R11,R13}

; Line #4
 ldrb R13,[R1,#416]!      ; Pos 0
 ldmia R14!,{R0,R2-R4,R5-R8,R9-R12}  ; 12 registers, starts QWA, exits QWA
 add R0,R0,R13
 ldrb R13,[R1,#15]
 add R13,R4,R13,lsl#24; MAISO
 stmia R1,{R0,R2-R3,R13}

; Line #5
 add R1,R1,#416
 stmia R1,{R5-R8}

; Line #6
 add R1,R1,#416; MAISO
 stmia R1,{R9-R12}

 ldmia R14!,{R0,R2-R4,R5-R8,R9-R12}  ; 12 registers, starts QWA, exits QWA
; Line #7
 add R1,R1,#416
 stmia R1,{R0,R2-R4}        ; MAISO

; Line #8
 add R1,R1,#416
 stmia R1,{R5-R8}

; Line #9
 add R1,R1,#416
 stmia R1,{R9-R12}         ; MAISO

 ldmia R14!,{R0,R2-R4,R5-R8,R9-R12}  ;  12 registers, starts QWA, exits QWA
; Line #10
 add R1,R1,#416
 stmia R1,{R0,R2-R4}

; Line #11
 ldrb R0,[R1,#416]!       ; Pos 0
 add R0,R5,R0
 ldrb R13,[R1,#15]
 add R13,R8,R13,lsl#24

 ldrb R2,[R1,#431]     ; for line #12

 stmia R1,{R0,R6-R7,R13}

; Line #12
 ldrb R0,[R1,#416]!       ; Pos 0
 add R0,R9,R0
 add R13,R12,R2,lsl#24; MAISO
 stmia R1,{R0,R10-R11,R13}



; Line #13
	ldr		R10,[R1,#418]!     ; Pos 2
	ldmia	R14!,{R0,R2-R4,R5-R6,R7-R8}
	ldr		R13,[R1,#12]
	add		R0,R0,R10,lsr#16
	add		R13,R4,R13,lsl#16
	stmia	R1,{R0,R2-R3,R13}

; Line #13
; + 12: ldr 10,[1,#416+2]!     ; Pos 2
; +  0: ldmia 14!,{0,2-4,5-6,7-8}
; +  4: ldr 13,[1,#12]
; +  8: add 0,0,10,lsr#2*8
; + 12: add 13,4,13,lsl#2*8
; +  0: stmia 1,{0,2-3,13}


; Line #14
 mov R0,#1; MAISO
 mov R13,#9
 strb R0,[R1,#417]!  ; Pos 3
 stmib R1,{R5-R6}
 strb R13,[R1,#9]

; Line #15
 ldrb R0,[R1,#418]!; Pos 5
 ldrb R13,[R1,#7]
 add R0,R7,R0
 add R13,R8,R13,lsl#24; MAISO
 stmia R1,{R0,R13}

; sortie
;		ldr R13,SavedR13
;		ldr pc,SavedR14

	b	retour_copie_sprite


; Following equds are for QWA
		.p2align 4
data_pos0v2:      
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

;**********************************************************************
;
; Sphere 16x16 violette position 1 V2
;
;**********************************************************************


	.p2align 4
pos1v2:
;	str 	R13,SavedR13
;	str 	R14,SavedR14


	ldr		r2,screenaddr1
	add		R1,R2,R0			; R2=R2+X

  adr R14,data_pos1v2               ; Data must be QWA ( checked by BASIC )
  ldrb r13,[r1,#2079]!          ; Pos 0
  ldmia R14!,{r0,r2-r12}             ; 12 registers, starts and ends QWA

; Line #5
  add r0,r0,r13
  stmia r1,{r0,r3-r5}
; Pixel 1 is plotted later, when plotting line #5

; Line #6
  ldrb r13,[r1,#416]!               ; Pos 0
  add r2,r2,r13
  stmia r1,{r2,r3-r4,r6}
; Pixel 1 is plotted later, when plotting line #416

; Line #7
  ldrb r13,[r1,#416]!             ; Pos 0

; r12b = 34
; Line #416
  strb R12,[R1,#-2077]
; Line #-2077
  strb R12,[R1,#-400]


  add r7,r7,r13
  stmia r1,{r7-r10}
; Pixel 35 is plotted later, when plotting line #2

; Line #15
  ldr R13,[r1,#3334]!    ; Pos 6

; r12b = 34
; Plot it on line #3334
  strb R12,[R1,#-2486]
  add r11,r11,r13,lsr#16
  stmia r1,{R11-R12}


; Line #14
  ldr R13,[R1,#-408]! ; Pos 14
  ldmia R14!,{R0,R2-R3,R4-R5,R6,R7-R8,R9,R10-R12}
  add R3,R3,R13,lsl#16
  stmda R1,{R0,R2-R3}

; Line #10
  ldrb R13,[R1,#-1678]!     ; Pos 0
  add R4,R4,R13
  stmia R1,{R4-R5,R7-R8}
; Pixel 1 is plotted, later, when plotting line #1

; Pixel 9 is in R8b
; Plot in on line #13
  strb r8,[R1,#1251]

; Line #1
  ldr R13,[R1,#-3730]!     ; Pos 14
  add R9,R9,R13,lsl#16
  stmda R1,{R6,R7,R9}

; Pixel 1 is in r6b
  strb R6,[R1,#1666]     ; On line #5
  strb R6,[R1,#3746]    ; On line #10
; Line #2
; Pixel 34 has already been plotted
  ldrb R13,[R1,#417]! ; Pos 15
  add R12,R12,R13,lsl#24
  stmda R1,{R10-R12}

; pixel 35 is in r12b
  strb r12,[R1,#2081]   ; On line #7
  strb r12,[R1,#2497]   ; On line #8

  ldmia R14!,{R0,R2,R3,R4,R5-R6,R7,R8,R9-R12}  ; 12 registers, starts and ends QWA
; Line #0
  ldr r13,[R1,#-841]! ; Pos 6
  add R0,R0,R13,lsr#16; MAISO
  stmia R1,{R0,R2}

; Line #3
  ldr r0,[R1,#1244]!       ; Pos 2
  add R3,R3,R0,lsr#16
  stmia R1,{R3,R5-R6,R7}                 ; MAISO

; Line #8
  ldrb r0,[R1,#2078]!        ; Pos 0
  add R4,R4,R0
  stmia R1,{R4,R5-R6,R8}

; Line #11
  ldr R13,[R1,#1250]!         ; Pos 2
  add R9,R9,R13,lsr#16
  stmia R1,{R9-R12}

  ldmia R14!,{R0,R2-R4,R5-R7,R8-R11}      ; 11 registers, starts QWA, ends at +12
; Line #12
  ldr R13,[R1,#416]!     ; Pos 2
  add R0,R0,R13,lsr#16
  stmia R1,{R0,R2-R4}

; Line #13
  ldrb R13,[R1,#429]!; Pos 15
  add R7,R7,R13,lsl#24; MAISO
  stmda R1,{R5-R7}

; Line #9
  ldrb R13,[R1,#-1679]!      ; Pos 0
  add R8,R8,R13
  stmia R1,{R8-R11}                    ; MAISO

  ldmia R14!,{R0,R2-R4}
; Line #4
  ldr R13,[R1,#-2078]!          ; Pos 2
  add R0,R0,R13,lsr#16
  stmia R1,{R0,R2-R4}                   ; MAISO

	
	
; sortie
;		ldr R13,SavedR13
;		ldr pc,SavedR14

	b	retour_copie_sprite
	
	
	.p2align 4
data_pos1v2:   ; Must be QWA ( checked by BASIC )
; line #5
.byte 0, 9, 165, 198      ; r0

; line #6
.byte 0, 34, 164, 198      ; r2

.byte 200, 252, 253, 253   ; r3
.byte 252, 200, 198, 164   ; r4
.byte 164, 165, 9, 35      ; r5

; line #6
.byte 164, 165, 9, 165     ; r6

; line #7
.byte 0, 35, 164, 198      ; r7
.byte 200, 235, 252, 252   ; r8
.byte 235, 200, 198, 164   ; r9
.byte 164, 35, 9, 164      ; r10

; line #15
.byte 0, 0, 1, 9           ; r11
.byte 34, 34, 9, 1         ; r12

; line #14
.byte 1, 34, 34, 35        ; r0
.byte 35, 165, 164, 164     ; r2
.byte 34, 9, 0, 0          ; r3

; line #10
.byte 0, 9, 35, 165         ; r4
.byte 164, 164, 164, 164    ; r5

; line #1
.byte 1, 35, 164, 164      ; r6

.byte 164, 164, 165, 35    ; r7
.byte 9, 34, 199, 165     ; r8

; line #1
.byte 34, 1, 0, 0          ; r9

; line #2
.byte 165, 198, 198, 198   ; r10
.byte 198, 199, 164, 165   ; r11
.byte 35, 34, 1, 0         ; r12

; line #0
.byte 0, 0, 1, 34          ; r0
.byte 34, 34, 34, 1        ; r2

; line #3
.byte 0, 0, 1, 165          ; r3

; line #8
.byte 0, 35, 164, 199       ; r4

; line #3
.byte 198, 200, 200, 200   ; r5
.byte 200, 198, 199, 164   ; r6
.byte 165, 35, 9, 1        ; r7

; line #8
.byte 165, 34, 9, 199      ; r8

; line #11
.byte 0, 0, 34, 35         ; r9
.byte 165, 165, 165, 165   ; r10
.byte 165, 165, 35, 9      ; r11
.byte 34, 165, 199, 35     ; r12

; line #12
.byte 0, 0, 1, 34          ; r0
.byte 35, 35, 35, 35       ; r2
.byte 35, 34, 9, 34        ; r3
.byte 165, 199, 165, 1     ; r4

; line #13
.byte 34, 34, 34, 34        ; r5
.byte 34, 34, 35, 165       ; r6
.byte 199, 165, 9, 0        ; r7

; line #9
.byte 0, 34, 165, 164       ; r8
.byte 199, 198, 198, 198   ; r9
.byte 198, 199, 164, 165   ; r10
.byte 35, 9, 35, 199       ; r11

; line #4
.byte 0, 0, 35, 198         ; r0
.byte 200, 235, 252, 252   ; r2
.byte 235, 200, 198, 164   ; r3
.byte 164, 35, 9, 34       ; r4

;**********************************************************************
;
; Sphere 16x16 violette position 2 V2
;
;**********************************************************************

pos2v2:
;	str 	R13,SavedR13
;	str 	R14,SavedR14


	ldr		r2,screenaddr1
	add		R1,R2,R0			; R1=R2+R0 offset ecran


  adr R14,data_pos2v2            ; Data must be QWA ( checked by BASIC )
  ldmia R14!,{R0,R2,R3-R4,R5-R6,R7-R8,R9-R11,R12} ; MAISO  12 registers, starts and ends QWA

; Line #0
  str R0,[R1,#6]!  ; Pos 8   -2 because destination has bit 0 and 1 set to 0 and 1

; Line #1
  ldrb R0,[R1,#412]!    ; Pos 4
  add R0,R2,R0
  ldrb R13,[R1,#11]
  add R13,R6,R13,lsl#24
  stmia R1,{R0,R5,R13}



; Line #10
  ldr R0,[R1,#3742]!; Pos 2
  ldr R13,[R1,#16]
  add R0,R3,R0,lsr#16
  add R13,R8,R13,lsl#16
  stmia R1,{R0,R4-R5,R7,R13}

; Line #13
  add R1,R1,#1248; Pos 2   MAISO
  stmib R1,{R9-R11}             ; note usage of ib

; Line #15
  mov R0,#1
; Plot 1s on line #12
  strb R0,[R1,#-415]
  strb R0,[R1,#-402]

; now do line #15
  strb R0,[R1,#837]! ; Pos 7
  str R12,[R1,#1]
  strb R0,[R1,#5]

; Line #9
  ldr R13,[R1,#-2501]!     ; Pos 2
  ldmia R14!,{R0,R2-R5,R6-R10,R11-R12}
  add R0,R0,R13,lsr#16
  ldr R13,[R1,#16]
  add R13,R5,R13,lsl#16; MAISO
  stmia R1,{R0,R2-R4,R13}

; Line #7
  ldr R0,[R1,#-832]!       ; Pos 2
  add R0,R6,R0,lsr#16
  ldr R13,[R1,#16]
  add R13,R10,R13,lsl#16
  stmia R1,{R0,R7-R9,R13}

; Line #4
; r11b = #34
  strb R11,[R1,#-1234]!    ; Pos 16
; Plot 34 on line #11
  strb R11,[R1,#2899]
  stmdb R1,{R7-R9}         ; note usage of db

; r12b = #1
; Do 1s on line #0
  strb R12,[R1,#-1673]
  strb R12,[R1,#-1668]

; Do 1s on line #3
  strb R12,[R1,#-429]
  strb R12,[R1,#-416]

  ldmia R14,{R0,R2,R3,R4-R6,R7,R8-R10,R11-R12,R14}
  

  
; Line #8
  ldr R13,[R1,#1650]!  ; Pos 2
  add R0,R0,R13,lsr#16; MAISO
  ldr R13,[R1,#16]
  add R13,R6,R13,lsl#16
  stmia R1,{R0,R2,R4-R5,R13}


; Line #3
  sub R1,R1,#2080; Pos 2    MAISO
  stmib R1,{R3,R4,R7}               ; Usage of ib

; Line #2
  sub R1,R1,#416; Pos 2
  stmib R1,{R8-R10}                ; usage of ib

; Line #11
; r11b = 35
  strb R11,[R1,#3758]! ; Pos 16
  stmdb R1,{R11,R12,R14}            ; usage of db

; Do other 5s
  strb R11,[R1,#-2496]! ; on line #5 Pos 16
  strb R11,[R1,#-429]  ; on line #4

; Line #5
  ldr R13,[R1,#-14]!            ; Pos 2



  adr R14,data_pos2v2_line5     ; Data must be QWA ( checked by BASIC )
  ldmia R14,{R0,R2,R3-R6,R7,R8-R10,R11-R12,R14} ; 13 registers, starts QWA end exits QWA +4
  add R0,R0,R13,lsr#16
  ldr R13,[R1,#16]
  add R13,R6,R13,lsl#16
  stmia R1,{R0,R3-R5,R13}

; Line #6
  ldr R13,[R1,#416]!   ; Pos 2
  add R0,R2,R13,lsr#16; MAISO
  ldr R13,[R1,#16]
  add R13,R7,R13,lsl#16
  stmia R1,{R0,R3-R5,R13}

; Line #12
  add R1,R1,#2496; Pos 2 MAISO
  stmib R1,{R8-R10}                ; Usage of ib

; Line #14
  ldrb R0,[R1,#834]! ; Pos 4
  add R0,R11,R0
  ldrb R13,[R1,#11]
  add R13,R14,R13,lsl#24
  stmia R1,{R0,R12-R13}



quit_pos2v2:
; sortie
;		ldr R13,SavedR13
;		ldr pc,SavedR14
	b	retour_copie_sprite



	.p2align 4
data_pos2v2:   ; Must be QWA ( checked by BASIC )
; line #0
.byte 34, 34, 34, 34       ; r0

; line #1
.byte  0, 1, 35, 164        ; r2

; line #10
.byte  0, 0, 9, 35          ; r3
.byte  165, 164, 164, 164   ; r4

; line #1
.byte  164, 164, 164, 165   ; r5
.byte  35, 34, 1, 0         ; r6

; line #10
.byte  35, 9, 34, 199       ; r7
.byte  165, 1, 0, 0         ; r8

; line #13
.byte  9, 34, 34, 34         ; r9
.byte  34, 34, 34, 35        ; r10
.byte  165, 199, 165, 9      ; r11

; line #15
.byte  9, 34, 34, 9         ; r12

; line #9
.byte  0, 0, 34, 165       ; r0
.byte  164, 199, 198, 198   ; r2
.byte  198, 198, 199, 164   ; r3
.byte  165, 35, 9, 35       ; r4
.byte  199, 34, 0, 0      ; r5

; line #7
.byte  0, 0, 35, 164        ; r6
.byte  198, 200, 235, 252   ; r7
.byte  252, 235, 200, 198   ; r8
.byte  164, 164, 35, 9      ; r9
.byte  164, 35, 0, 0        ; r10


.long  34     ; r11
.long  1      ; r12

; line #8
.byte  0, 0, 35, 164        ; r0
.byte  199, 198, 200, 200   ; r2

; line #3
.byte  165, 198, 200, 200   ; r3

; line #8
.byte  200, 200, 198, 199   ; r4
.byte 164, 165, 34, 9      ; r5
.byte  199, 35, 0, 0        ; r6

; line #3
.byte  164, 165, 35, 9      ; r7

; line #2
.byte  34, 165, 198, 198    ; r8
.byte  198, 198, 199, 164   ; r9
.byte  165, 35, 34, 1       ; r10

; line #11
.byte  35, 165, 165, 165    ; r11
.byte  165, 165, 165, 35    ; r12
.byte  9, 34, 165, 199      ; r14

	.p2align 4
	
data_pos2v2_line5:		  ; Must be quadword aligned, checked by BASIC
; line #5
.byte 0, 0,9, 165        ; r0

; line #6
.byte 0, 0, 34, 164        ; r2

; line #5 and #6
.byte 198, 200, 252, 253   ; r3
.byte 253, 252, 200, 198   ; r4
.byte 164, 164, 165, 9     ; r5
.byte 35, 1, 0, 0          ; r6
; line #6
.byte 165, 34, 0, 0        ; r7

; line #12
.byte 34, 35, 35, 35       ; r8
.byte 35, 35, 34, 9        ; r9
.byte 34, 165, 199, 165    ; r10

; line #14
.byte 0, 1, 34, 34         ; r11
.byte 35, 35, 165, 164     ; r12
.byte 164, 34, 9, 0        ; r14

;**********************************************************************
;
; Sphere 16x16 violette position 3 V2
;
;**********************************************************************
pos3v2:

;	str 	R13,SavedR13
;	str 	R14,SavedR14


	ldr		r2,screenaddr1
	add		R1,R2,R0			; R1=R2+R0 offset ecran

  adr R14,data_pos3v2         ; Data must be quadword aligned ( checked by BASIC )

  ldmia R14!,{R0,R2,R3,R4,R5-R6,R7-R8,R9-R12}
; Line #0
  ldr R13,[R1,#11]!    ; Pos 14
  add R13,R2,R13,lsl#16
  stmda R1,{R0,R13}
; 1 is in R0b
  strb R0,[R1,#834] ; for line #2

; Line #1
  ldr R0,[R1,#408]! ; Pos 6
  add R0,R3,R0,lsr#16
  stmia R1,{R0,R5-R6}

; Line #10
  ldrb R13,[R1,#3757]! ; Pos 19

; 9 is in r11b plot it on line #13
  strb R11,[R1,#1245] ; for line #13

  add R13,R8,R13,lsl#24
  stmda R1,{R4,R5-R6,R13}

; Line #12
  ldr R13,[R1,#831]! ; Pos 18

; 9 is in r11b plot it on line #10
  strb R11,[R1,#-847]

  add R13,R12,R13,lsl#16
  stmda R1,{R9-R11,R13}

; 9 is in r11b plot it on line #5
  strb R11,[R1,#-2927]

; Line #13
  ldrb R13,[R1,#402]! ; Pos 4
  ldmia R14!,{R0,R2-R3,R4-R6,R7-R8,R9-R12}
  add R0,R0,R13
  stmia R1,{R0,R2-R3}

; Line #14
  ldr R0,[R1,#418]! ; Pos 6
  add R0,R4,R0,lsr#16
  stmia R1,{R0,R5-R6}

; Line #15
  ldr R13,[R1,#424]! ; Pos 14
  add R13,R8,R13,lsl#16; MAISO
  stmda R1,{R7,R13}

; Line #11
  ldr R13,[R1,#-1660]! ; Pos 18
  add R13,R12,R13,lsl#16
; 35 is in R11b
  strb R11,[R1,#-1263] ; for line #8
  stmda R1,{R9-R11,R13}
  strb R11,[R1,#-1679] ; for line #7



; 34 is in r9b
  strb R9,[R1,#-847]  ; for line #9
  strb R9,[R1,#-2095]  ; for line #6
 
  ldmia R14!,{R0,R2,R3,R4,R5-R6,R7,R8,R9-R10,R11,R12}
  
  
; Line #9
  ldrb R13,[R1,#-831]! ; Pos 19
  add R13,R5,R13,lsl#24
  stmda R1,{R0,R3-R4,R13}      ; MAISO

; Line #2
  ldrb R0,[R1,#-2927]!       ; Pos 4
  add R0,R2,R0
  stmia R1,{R0,R3,R6}

; Line #4
  ldr R13,[R1,#846]!    ; Pos 18
  add R13,R11,R13,lsl#16
  stmda R1,{R7,R9-R10,R13}


; ici probleme
; Line #7
  ldrb R13,[R1,#1249]!  ; Pos 19					; R13 = 0000 0000 
  add R13,R12,R13,lsl#24; MAISO						; R13 = 0023 A409
  stmda R1,{R8,R9-R10,R13}							
 

  ldmia R14,{R0,R2,R3,R4-R5,R6-R7,R8,R9,R10-R11,R12,R14} ; 13 registers, starts QWA, exits QWA +4
; Line #8
  ldrb R13,[R1,#416]!  ; Pos 19
  add R13,R5,R13,lsl#24; MAISO
  stmda R1,{R0,R3,R4,R13}

; Line #3
  ldr R13,[R1,#-2081]!   ; Pos 18
  add R13,R7,R13,lsl#16
  stmda R1,{R2,R3,R6,R13}      ; MAISO

; Line #5
  ldrb R13,[R1,#833]!  ; Pos 19
  add R13,R12,R13,lsl#24
  stmda R1,{R8,R10-R11,R13}

; Line #6
  ldrb R13,[R1,#416]!  ; Pos 19
  add R13,R14,R13,lsl#24
  stmda R1,{R9,R10-R11,R13}

quit_pos3v2:
; sortie
;		ldr R13,SavedR13
;		ldr pc,SavedR14

	b	retour_copie_sprite


	.p2align 4
	
data_pos3v2:				   ; Eric Data must be quadword aligned ( checked by BASIC )
; line #0
.byte 1, 34, 34, 34        ; r0
.byte 34, 1, 0, 0           ; r2

; line #1
.byte 0, 0, 1, 35           ; r3

; line #10
.byte 35, 165, 164, 164     ; r4

; line #1
.byte 164, 164, 164, 164    ; r5
.byte 165, 35, 34, 1        ; r6

; line #10
.byte 165, 35, 9, 34        ; r7
.byte 199, 165, 1, 0        ; r8

; line #12
.byte 1, 34, 35, 35         ; r9
.byte 35, 35, 35, 34        ; r10
.byte 9, 34, 165, 199       ; r11
.byte 165, 1, 0, 0          ; r12

;--------------
; line #13
.byte 0, 9, 34, 34          ; r0
.byte 34, 34, 34, 34        ; r2
.byte 35, 165, 199, 165     ; r3

; line #14
.byte 0, 0, 1, 34           ; r4
.byte 34, 35, 35, 165       ; r5
.byte 164, 164, 34, 9       ; r6

; line #15
.byte 1, 9, 34, 34          ; r7
.byte 9, 1, 0, 0            ; r8

; line #11
.byte 34, 35, 165, 165      ; r9
.byte 165, 165, 165, 165    ; r10
.byte 35, 9, 34, 165        ; r11
.byte 199, 35, 0, 0         ; r12

;-------------
; line #9
.byte 165, 164, 199, 198    ; r0

; line #2
.byte 0, 34, 165, 198       ; r2

; line #2 and #9
.byte 198, 198, 198, 199    ; r3

; line #9
.byte 164, 165, 35, 9       ; r4
.byte 35, 199, 34, 0      ; r5

; line #2
.byte 164, 165, 35, 34      ; r6

; line #4
.byte 35, 198, 200, 235     ; r7
; line #7
.byte 164, 198, 200, 235    ; r8
; line #4 and #7
.byte 252, 252, 235, 200    ; r9
.byte 198, 164, 164, 35     ; r10
; line #4
.byte 9, 34, 0, 0           ; r11
; line #7
.byte 9, 164, 35, 0         ; r12


;------------
; line #8
.byte 164, 199, 198, 200    ; r0

; line #3
.byte 1, 165, 198, 200      ; r2

; line #8 and #3
.byte 200, 200, 200, 198    ; r3

; line #8
.byte 199, 164, 165, 34     ; r4
.byte 9, 199, 35, 0         ; r5

; line #3
.byte 199, 164, 165, 35     ; r6
.byte 9, 1, 0, 0            ; r7

; line #5
.byte 165, 198, 200, 252    ; r8
; line #6
.byte 164, 198, 200, 252    ; r9
; line #5 and #6
.byte 253, 253, 252, 200    ; r10
.byte 198, 164, 164, 165    ; r11
; line #5
.byte 9, 35, 1, 0           ; r12
; line #6
.byte 9, 165, 34, 0         ; r14




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

; exemple de transformation
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
		.long		objet_sphere
		.long		200,0,50			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		3,3,2			;     - increment angle X, increment angle Y , increment angle Z
		.long		0,0,0			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		256				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		coordonnees_points_carre				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		256				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		0				;     - pointeur vers data animation, 0 = pas d'anim
		.long		0				;	  - nombre de points à animer
		.long		0				;     - nombre d'étapes en frame, 0 = pas d'anim
; mouvement de l'objet
		.long		table_mouvement_vertical_vers_le_bas	; table_de_mouvement, -1 = pas de mouvement
		.long		160	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

		.long		0x200			;	  - zoom / position observateur en Z


; etape 2
		.long		dummy			;     - pointeur vers objet
		.long		200,0,50			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		3,3,2			;     - increment angle X, increment angle Y , increment angle Z
		.long		-1,-1,-1			; 	  - angles depart X,Y,Z, non modifié si =-1
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
		
; etape 3		
		.long		objet_points_carre			;     - pointeur vers objet
		.long		200,0,50			;     - X,Y,Z objet
		;.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		-3,-3,-2			;     - increment angle X, increment angle Y , increment angle Z
		.long		-1,-1,-1		; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		256				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		coordonnees_tube64				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		256				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		0				;     - pointeur vers data animation, 0 = pas d'anim
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
		.long		0,0,0			;     - increment angle X, increment angle Y , increment angle Z
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

objet_64points_unique:
	.long	coordonnes_objet_64points_unique
	.long	64
	.long	0
	.long	0
objet_sphere:
	.long	coordonnees_sphere
	.long	64
	.long	0
	.long	0

objet_tube64:
	.long	coordonnees_tube64
	.long	64
	.long	0
	.long	0
objet_points_carre:
	.long	coordonnees_points_carre
	.long	64
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

coordonnes_objet_64points_unique:
	.rept	64
	.long	0,00,-800,0			;1
	.endr

coordonnees_points_carre:		.include	"RIPPLEDZ_A.s"
coordonnees_sphere:		.include	"sphere.s"
coordonnees_tube64:		.include	"tube.s"


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
table_increments_pas_transformations:		.space			128*7*4
; X,Y,Z,increment pas , tout multiplié par 2^15
		.p2align 4
buffer_coordonnees_objet_transformees:		.space			128*4*4
	.p2align 4
buffer_calculs_intermediaire:			.skip		300*4*4
buffer_calcul1:
		.skip		512*nombre_de_boules_maxi*4
	.p2align 4
buffer_calcul2:		
		.skip		512*nombre_de_boules_maxi*4
