; TO DO
; ------
; !!!!!   ==============>    faire un scrolling completement dynamique en 3D
; idées objets : transformation décompte de chiffres, avion, ballon dirigeable
; reprendre la version du 10/05 des spheres violettes
; Interaction entre les objets, Passage hélico ou avion sous arche, Tirs entre hélicos, Explosion par transformation
; QTM ?
; YM6 ?

; DONE
; ------
; OK : rotation autour du point ZERO de l'objet hors observateur
; OK : utiliser incrementations positions X Y Z de l'objet
; OK : ---> scene avec plusieurs objets : creer structure temporaire objet pour calculs, 
; OK : faire 4 tables de mouvement en code
; OK : partie fixe + partie animée, même objet
; OK :  faire des sequences d'elements d'animation pour repeter certains mouvements
; OK : faire un quick sort
; OK - faire une table de centrage en fonction de la taille, du n° de sprite
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

; 34 secondes 320 spheres avec tri
; 3 secondes sans le tri



; point : X,Y,Z, n° sprite
;
; objet: 
;	- nb points
;	- ( N° de point * 16 ) * N
;	- pointeur vers points variables ( morceau de l'objet animé )
;
; animation : 
;	  - nombre d'objets de la scene
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


.equ	nombre_de_boules_maxi, 320
.equ	taille_buffer_calculs, 256*nombre_de_boules_maxi*4

.equ Screen_Mode, 97
.equ	IKey_Escape, 0x9d

.equ	etape_en_cours, 0x7000

.include "swis.h.asm"

; valeurs fixes RM / timers
.equ	ylines,			58
.equ	vsyncreturn,	7142						; vsyncreturn=7168+16-1-48   +   vsyncreturn+=7
.equ	vsyncreturn_low,		(vsyncreturn & 0x00FF)>>0
.equ	vsyncreturn_high,		((vsyncreturn & 0xFF00)>>8)

.equ	vsyncreturn_ligne199,			7142+(197*128)+127-64					; vsyncreturn=7168+16-1-48   +   vsyncreturn+=7
.equ	vsyncreturn_low_ligne199,		(vsyncreturn_ligne199 & 0x00FF)>>0
.equ	vsyncreturn_high_ligne199,		((vsyncreturn_ligne199 & 0xFF00)>>8)


.equ	hsyncline,		128-1			; 127
.equ	hsyncline_low,			((hsyncline & 0x00FF)>>0)
.equ	hsyncline_high,			((hsyncline & 0xFF00)>>8)

.equ	position_ligne_hsync,	 	0xEC


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


;	SWI		0x01
;.byte	"         Please wait, overclocking CPU",0
	.p2align 2

; ---------------------------------
; gestion de la RAM
; ---------------------------------

	; essai d'ecriture sans allocation
;	ldr		R1,fond_de_la_memoire
;	mov		R0,#0x1234
;	str		R0,[R1]


; lecture des infos actuelles



	mov		R0,#-1				; New size of current slot
	mov		R1,#-1				;  	New size of next slot
	SWI		0x400EC			; Wimp_SlotSize 
	str		R0,ancienne_taille_alloc_memoire_current_slot
	
	;R2 = taille mémoire dispo

	mov		R3,R2
	ldr		R2,valeur_taille_memoire
	cmp		R3,R2
	bge		ok_assez_de_ram

	SWI		0x01
	.byte	"Not enough memory.",0
	.p2align 2


	MOV R0,#0
	SWI OS_Exit


ok_assez_de_ram:
	add		R0,R0,R2
	mov		R1,#-1
	SWI 	0x400EC			; Wimp_SlotSize 

	ldr		R1,fond_de_la_memoire
	mov		R0,#0x1234
	str		R0,[R1]

; ---------------------------------


	mov		R1,#0			; stop color flashing
	mov		R0,#9
	swi		OS_Byte

	bl 		creer_table_416


	SWI		0x01
	.byte	"---",0
	.p2align 2
; ---------------------------------

	mov		R0,#0
	str		R0,nb_frames_total_calcul

; on démarre une sequence de calculs, donc on pointe au debut du buffer de calcul
	ldr		R5,pointeur_buffer_en_cours_de_calcul
	str		R5,pointeur_actuel_buffer_en_cours_de_calcul


	ldr		R5,pointeur_buffer_sequences_calcul
	str		R5,pointeur_actuel_buffer_sequences_calcul

; le pointeur vers les variables pour calculer 1 objet	
	ldr		R5,pointeur_buffers_variables_objets_initial
	str		R5,pointeur_buffers_variables_objets_en_cours


; --------------- début init des  calculs --------------------------
boucle_lecture_animations:
; sauvegarde dans les sequences le pointeur dans le buffer de calcul au début des calculs


	ldr		R12,pointeur_actuel_buffer_sequences_calcul
	ldr		R1,pointeur_actuel_buffer_en_cours_de_calcul
	str		R1,[R12],#4
	str		R12,pointeur_actuel_buffer_sequences_calcul

; mise à zéro du nb points total de la séquence
;	mov		R1,#0
;	str		R1,nb_points_total_sequence


; tracage1
	mov		R12,#etape_en_cours
	mov		R13,#1
	str		R13,[R12]
	
	ldr		R1,pointeur_buffer_calculs_intermediaire
	str		R1,pointeur_buffer_calculs_intermediaire_actuel
	


	;mov		R0,#debut_data
	;mov		R3,#pointeur_position_dans_les_animations-debut_data	
	;ldr		R1,[R0,R3]			; R1 = pointeur_position_dans_les_animations
	ldr		R1,pointeur_position_dans_les_animations
	;mov		R3,#pointeur_objet_en_cours-debut_data

; nombre d'objets dans la scene

	ldr		R2,[R1],#4				; nombre d'objets de la scene
	cmp		R2,#0					; 0 objet = fin de la scene
	beq		sortie_boucle_animations
	str		R2,nombre_d_objets_de_la_scene_initial					; nombre d'objets de la scene
	str		R2,nombre_d_objets_de_la_scene_en_cours


boucle_preparation_objet_par_objet:

	mov		R2,#0
	str		R2,flag_transformation_en_cours			; pas de transformation
	str		R2,flag_animation_en_cours				; pas d'animation
	str		R2,flag_classique_en_cours				; pas d'objet classique
	str		R2,flag_mouvement_en_cours
	str		R2,flag_repetition_mouvement_en_cours

; sortie si pointeur vers objet = 0
	ldr		R2,[R1],#4			; R2 = pointeur vers objet
;	cmp		R2,#0
;	beq		sortie_boucle_animations

	str		R2,pointeur_objet_en_cours
	str		R2,pointeur_objet_source_transformation
	
	;ldr		R2,pointeur_objet_en_cours
	ldr		R3,[R2],#4								; R2 = pointeur objet, R3 = coordonnees des points de l'objet
	str		R3,pointeur_points_objet_classique
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
; PB
;	str		R4,nb_sprites_en_cours_calcul
	str		R4,nb_points_objet_en_cours
	
	
	;str		R2,[R0,R3]
	
	ldr		R0,[R1],#4			; X objet
	str		R0,position_objet_en_cours_X
	ldr		R0,[R1],#4			; Y objet
	str		R0,position_objet_en_cours_Y
	ldr		R0,[R1],#4			; Z objet
	str		R0,position_objet_en_cours_Z

	ldr		R0,[R1],#4			; X objet
	str		R0,increment_position_X
	ldr		R0,[R1],#4			; Y objet
	str		R0,increment_position_Y
	ldr		R0,[R1],#4			; Z objet
	str		R0,increment_position_Z


	
	ldr		R0,[R1],#4			; increment X objet	
	str		R0,increment_angle_X
	ldr		R0,[R1],#4			; increment Y objet	
	str		R0,increment_angle_Y
	ldr		R0,[R1],#4			; increment Z objet	
	str		R0,increment_angle_Z



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
; PB
;	str		R4,nb_sprites_en_cours_calcul
	
	
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

	
	





	ldr		R0,nb_frames_rotation_classique
	str		R0,nb_frame_en_cours


	str		R1,saveR1
	bl		push_sauvegarde_variables_de_l_objet_full
	ldr		R1,saveR1


; ici on boucle sur les objets
	ldr		R0,nombre_d_objets_de_la_scene_en_cours
	subs	R0,R0,#1
	str		R0,nombre_d_objets_de_la_scene_en_cours
	bgt		boucle_preparation_objet_par_objet

	ldr		R0,nb_frame_en_cours

; sauvegarde dans les sequences le nombre de frames du calcul
	ldr		R12,pointeur_actuel_buffer_sequences_calcul
	str		R0,[R12],#4
	str		R12,pointeur_actuel_buffer_sequences_calcul



	
;-----------------------------------------------------------
;
;-------------------- boucle principale précalcul des points
;
;-----------------------------------------------------------
; calcul frames rotation classique





; tracage4	
	mov		R12,#etape_en_cours
	mov		R13,#4
	str		R13,[R12]


boucle_calcul_frames_classiques:
	SWI		0x01
	.byte	"/  ",0
	.p2align 2

; apres la boucle sur les objets, on revient au début de la pile de structures
; le pointeur vers les variables pour calculer 1 objet	

	ldr		R5,pointeur_buffers_variables_objets_initial
	str		R5,pointeur_buffers_variables_objets_en_cours
	
	ldr		R5,nombre_d_objets_de_la_scene_initial
	str		R5,nombre_d_objets_de_la_scene_en_cours
	
	mov		R4,#0
	str		R4,nb_points_objet_en_cours_au_total

; on initialize le buffer de destination
	ldr		R2,pointeur_coordonnees_projetees
	str		R2,pointeur_coordonnees_projetees_actuel

		
boucle_execution_objet_par_objet:

	SWI		0x01
	.byte	"o  ",0
	.p2align 2

; on charge les variables de l'objet en cours, le pointeur n'est pas avancé
	bl		pop_sauvegarde_variables_de_l_objet_full
	
	
; ++++++++++++++++++++++++++++++++++++++++++++++
; gestion du mouvement de l'objet en entier
; 
	bl		incrementation_des_angles

	mov		R0,#0
	str		R0,position_objet_sur_ecran_X
	str		R0,position_objet_sur_ecran_Y

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




; ++++++++++++++++++++++++++++++++++++++++++++++

	; si transformation :
	; on calcul les points transformes dans pointeur_buffer_coordonnees_objet_transformees

	ldr		R5,flag_transformation_en_cours
	cmp		R5,#1
	bne		.pas_de_transformation

	ldr		R5,nb_points_objet_en_cours_objet_classique
	str		R5,nb_points_objet_en_cours

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

; on checke transformation pour determiner la source des points.
	ldr		R5,flag_transformation_en_cours
	cmp		R5,#1
	bne		.pas_de_transformation2
	ldr		R2,pointeur_buffer_coordonnees_objet_transformees
	str		R2,pointeur_points_objet_en_cours 
	b		ok_points_objet_classique_ou_transforme
	
.pas_de_transformation2:
	ldr		R2,pointeur_points_objet_classique
	str		R2,pointeur_points_objet_en_cours 
	
ok_points_objet_classique_ou_transforme:
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

; ++++++++++++++++++++++++++++++++++++++++++++++
; animation

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
	ldr		R2,nb_points_objet_en_cours_objet_anime
	str		R2,nb_points_objet_en_cours
	

; on calcul nb_points_objet_en_cours points, venant de pointeur_points_objet_en_cours
	bl		calc3D
	
	ldr		R2,pointeur_vers_coordonnees_points_animation_en_cours
	ldr		R3,nb_points_objet_en_cours_objet_anime
	; on avance de nb points * 16
	add		R2,R2,R3,asl #4				; on avance le pointeur de coordonnees de 16 * nb points : X Y Z n° sprite
	str		R2,pointeur_vers_coordonnees_points_animation_en_cours




.pas_d_animation_dans_la_boucle_de_calcul_principale:

	ldr		R4,nb_points_objet_en_cours_au_total

	ldr		R2,nb_points_objet_en_cours_objet_classique
	ldr		R3,nb_points_objet_en_cours_objet_anime
	add		R2,R2,R3										; nombre total de points
	add		R4,R4,R2
	str		R4,nb_points_objet_en_cours_au_total
	str		R4,nb_sprites_en_cours_calcul
	str		R2,nb_points_un_seul_objet
	


; on met à jour les variables dans la structure des objets, le pointeur sur les structures est incrémenté
	bl		push_sauvegarde_variables_de_l_objet_full
	

	ldr		R0,nombre_d_objets_de_la_scene_en_cours
	subs	R0,R0,#1
	str		R0,nombre_d_objets_de_la_scene_en_cours
	bgt		boucle_execution_objet_par_objet

; il faut trier après calcul de tous les points
; tracage	
	mov		R12,#etape_en_cours
	mov		R13,#11
	str		R13,[R12]
	
;	bl		bubblesort_XYZ
;	bl		quick_sort
	bl		quick_sort2
	
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
	ldr		R1,nb_points_objet_en_cours_au_total
;	add		R2,R2,R1,asl #4			; + nb points * 16
	add		R2,R2,R1,asl #2			; + nb points * 4
	str		R2,pointeur_actuel_buffer_en_cours_de_calcul	


	
	ldr		R0,nb_frame_en_cours
	subs	R0,R0,#1
	str		R0,nb_frame_en_cours
	cmp		R0,#0
	bgt		boucle_calcul_frames_classiques
; fin de la boucle de calcul de N frames

; tracage	
	mov		R12,#etape_en_cours
	mov		R13,#14
	str		R13,[R12]

	ldr		R2,nb_points_objet_en_cours_au_total
	ldr		R12,pointeur_actuel_buffer_sequences_calcul
	str		R2,[R12],#4
	str		R12,pointeur_actuel_buffer_sequences_calcul

	


	b		boucle_lecture_animations

sortie_boucle_animations:


;------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------
	SWI		0x01
	.byte	"+++",0
	.p2align 2
	
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

	ldr		R1,pointeur_buffer_sequences_calcul
	ldr		R2,pointeur_buffer_sequences_affichage
	str		R1,pointeur_buffer_sequences_affichage
	str		R2,pointeur_buffer_sequences_calcul

	;ldr		R0,nb_frames_total_affichage
	;ldr		R12,pointeur_buffer_en_cours_d_affichage
	;str		R0,nb_frame_en_cours_affichage
	;str		R12,pointeur_actuel_buffer_en_cours_d_affichage



	
;initialiser sequences
;- stocker nb frames affichage en cours
;- stocker nb sprites affichage en cours
;- stocker pointeur buffer memoire affichage en cours

; mets la sequence infinie d'attente de la fin des calculs en OFF
	mov		R1,#0
	str		R1,sequence_infinie

	ldr		R1,pointeur_lecture_sequences
; - numéro de séquence
; - nb répétition de la séquence
	ldr		R2,[R1],#4				; R2 = numéro de séquence
	ldr		R3,[R1],#4				; R3 = nb répétition de la séquence
	str		R3,nb_repetition_sequence_affichage
	str		R1,pointeur_lecture_sequences_affichage

; 	- pointeur mémoire debut séquence
;	- nb étapes de la séquence
;	- nb points de la séquence
	
	ldr		R1,pointeur_buffer_sequences_affichage
; R2 * 12 = 4+8
	mov		R2,R2,lsl #2				; R2*4
	add		R2,R2,R2, lsl #1			; R2 = R2*4 + R2*4*2 = 12*R2
	ldr		R4,[R1,R2]					; pointeur mémoire debut séquence
	str		R4,pointeur_lecture_calculs_pendant_affichage
	str		R4,pointeur_initial_lecture_calculs_pendant_affichage
	add		R1,R1,#4
	ldr		R4,[R1,R2]					; nb étapes/frames de la séquence
	str		R4,nombre_frames_sequence_en_cours_affichage
	str		R4,nombre_frames_initial_sequence_en_cours_affichage
	add		R1,R1,#4
	ldr		R4,[R1,R2]					; nb points de la séquence
	str		R4,nombre_sprites_sequence_en_cours_affichage
	
	

	


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
	
	bl		RM_init

	bl		RM_start

	

	
	

boucle:

;	bl		RM_wait_VBL

; exit if SPACE is pressed
	bl      RM_scankeyboard
	cmp		R0,#0x5F
	bne		boucle


	
exit:

	bl		RM_wait_VBL

;-----------------------
;sortie finale
;-----------------------


	bl	RM_release



	

	MOV r0,#22	;Set MODE
	SWI OS_WriteC
	MOV r0,#12
	SWI OS_WriteC


; rmkill module mode97
	mov		R1,#nom_mode97
	mov		R0,#04
	swi		OS_Module

; rmkill QT
;	mov		R1,#nom_module_QT
;	mov		R0,#04
;	swi		OS_Module

	ldr		R0,ancienne_taille_alloc_memoire_current_slot 	; New size of current slot
	mov		R1,#-1											;  	New size of next slot
	SWI		0x400EC											; Wimp_SlotSize 
	str		R0,ancienne_taille_alloc_memoire_current_slot


	
	MOV R0,#0
	SWI OS_Exit


; ------------------ end of main code ----------------------

couleur:	.long	0x7f7f7f7f
couleur2:	.long	0x1e1e1e1e


valeur_ecran_forcee:			.long	((416*140)+128) * 16
valeur_ecran_forcee0:			.long	((416*140)+128) * 16
valeur_ecran_forcee1:			.long	((416*160)+129) * 16
valeur_ecran_forcee2:			.long	((416*180)+130) * 16
valeur_ecran_forcee3:			.long	((416*200)+131) * 16

valeur_taille_memoire:		.long ((taille_buffer_calculs*2))
ancienne_taille_alloc_memoire_current_slot:			.long 0

nom_mode97:				.byte		"mode97",0		
;nom_Rasterman:			.byte		"rm24",0
;nom_QT:					.byte		"qt",0
;nom_module_Rasterman:	.byte		"Rasterman",0
;nom_module_QT:			.byte		"QTMTracker",0
		.p2align 4

; variable gestion des sequences lors de l'affichage
nb_repetition_sequence_affichage:			.long	0
pointeur_lecture_sequences_affichage:			.long	0
pointeur_lecture_calculs_pendant_affichage:		.long	0
pointeur_initial_lecture_calculs_pendant_affichage:		.long	0
nombre_frames_initial_sequence_en_cours_affichage:		.long	0
nombre_frames_sequence_en_cours_affichage:		.long	0
nombre_sprites_sequence_en_cours_affichage:		.long	0

; 	- pointeur mémoire debut séquence
;	- nb étapes de la séquence
;	- nb points de la séquence
pointeur_buffer_sequences_calcul:				.long buffer_sequences_calcul
pointeur_buffer_sequences_affichage:			.long buffer_sequences_affichage
pointeur_actuel_buffer_sequences_calcul:		.long buffer_sequences_calcul
pointeur_actuel_buffer_sequences_affichage:		.long buffer_sequences_affichage
sequence_infinie:								.long 0

pointeur_lecture_sequences:			.long		anim1_sequences

;-----------------------
; routines de sauvegardes et restaurations des variables dans la structure d'objet
;-----------------------
pop_sauvegarde_variables_de_l_objet_partiel:
; mise à jour  des variables de l'objet en cours à partir de la structure d'objet
	ldr		R13,pointeur_buffers_variables_objets_en_cours
	ldr		R0,[R13,#52]						; angleX : ok	+52	
	ldr		R1,[R13,#56]						; angleY : ok	+56
	ldr		R2,[R13,#60]						; angleZ : ok	+60
	ldr		R3,[R13,#132]						; nombre_etapes_du_mouvement_en_cours : ok	+132
	ldr		R4,[R13,#124]						; pointeur_index_actuel_mouvement : ok		+124
	ldr		R5,[R13,#116]						; flag_mouvement_en_cours		: ok		+116
	ldr		R6,[R13,#112]						; nb_frame_animation_en_cours : ok			+112
	ldr		R7,[R13,#100]						; pointeur_vers_coordonnees_points_animation_en_cours : ok		+100
	ldr		R8,[R13,#64]						; nb_frames_rotation_classique, - nb_frame_en_cours -				: ok 				+64

	str		R0,angleX
	str		R1,angleY
	str		R2,angleZ
	str		R3,nombre_etapes_du_mouvement_en_cours
	str		R4,pointeur_index_actuel_mouvement
	str		R5,flag_mouvement_en_cours
	str		R6,nb_frame_animation_en_cours
	str		R7,pointeur_vers_coordonnees_points_animation_en_cours
;	str		R8,nb_frame_en_cours
	
	mov		pc,lr

push_sauvegarde_variables_de_l_objet_partiel:
; mise à jour de la structure d'objet à partir des variables de l'objet en cours
	ldr		R13,pointeur_buffers_variables_objets_en_cours

	ldr		R0,angleX
	ldr		R1,angleY
	ldr		R2,angleZ
	ldr		R3,nombre_etapes_du_mouvement_en_cours
	ldr		R4,pointeur_index_actuel_mouvement
	ldr		R5,flag_mouvement_en_cours
	ldr		R6,nb_frame_animation_en_cours
	ldr		R7,pointeur_vers_coordonnees_points_animation_en_cours
	ldr		R8,nb_frame_en_cours

	ldr		R0,[R13,#52]						; angleX : ok	+52	
	ldr		R1,[R13,#56]						; angleY : ok	+56
	ldr		R2,[R13,#60]						; angleZ : ok	+60
	ldr		R3,[R13,#132]						; nombre_etapes_du_mouvement_en_cours : ok	+132
	ldr		R4,[R13,#124]						; pointeur_index_actuel_mouvement : ok		+124
	ldr		R5,[R13,#116]						; flag_mouvement_en_cours		: ok		+116
	ldr		R6,[R13,#112]						; nb_frame_animation_en_cours : ok			+112
	ldr		R7,[R13,#100]						; pointeur_vers_coordonnees_points_animation_en_cours : ok		+100
	ldr		R8,[R13,#64]						; nb_frames_rotation_classique, - nb_frame_en_cours -				: ok 				+64

	
	mov		pc,lr

push_sauvegarde_variables_de_l_objet_full:
; sauvegardes des variables de l'objet en cours + on avance le pointeur de sauvegarde des structures dynamiques d'objet
	ldr		R13,pointeur_buffers_variables_objets_en_cours
	
	ldr		R0,flag_classique_en_cours
	ldr		R1,pointeur_objet_source_transformation
	ldr		R2,pointeur_points_objet_classique
	ldr		R3,nb_points_objet_en_cours_objet_classique
	ldr		R4,position_objet_en_cours_X
	ldr		R5,position_objet_en_cours_Y
	ldr		R6,position_objet_en_cours_Z
	ldr		R7,increment_position_X
	ldr		R8,increment_position_Y
	ldr		R9,increment_position_Z
	ldr		R10,increment_angle_X
	ldr		R11,increment_angle_Y
	ldr		R12,increment_angle_Z
	stmia	R13!,{R0-R12}
	
	ldr		R0,angleX
	ldr		R1,angleY
	ldr		R2,angleZ
	ldr		R3,nb_frame_en_cours
	ldr		R4,pointeur_coordonnees_objet_destination_transformation
	ldr		R5,flag_transformation_en_cours
	ldr		R6,pointeur_buffer_coordonnees_objet_transformees
	ldr		R7,nb_etapes_transformation
	ldr		R8,numero_etape_en_cours_transformation
	ldr		R9,flag_animation_en_cours
	ldr		R10,pointeur_vers_coordonnees_points_animation_original
	ldr		R11,pointeur_vers_coordonnees_points_animation_en_cours
	ldr		R12,nb_points_animation_en_cours_objet_anime
	stmia	R13!,{R0-R12}
	
	ldr		R0,nb_frame_animation
	ldr		R1,nb_frame_animation_en_cours
	ldr		R2,flag_mouvement_en_cours
	ldr		R3,pointeur_debut_mouvement
	ldr		R4,pointeur_index_actuel_mouvement
	ldr		R5,nombre_etapes_du_mouvement_initial
	ldr		R6,nombre_etapes_du_mouvement_en_cours
	ldr		R7,flag_repetition_mouvement_en_cours
	ldr		R8,pointeur_initial_repetition_mouvement
	ldr		R9,pointeur_actuel_repetition_mouvement
	ldr		R10,nombre_etapes_repetition_du_mouvement_initial
	ldr		R11,nombre_etapes_repetition_du_mouvement_en_cours
	ldr		R12,distance_z
	stmia	R13!,{R0-R12}
	
	str		R13,pointeur_buffers_variables_objets_en_cours
	
	mov		pc,lr

pop_sauvegarde_variables_de_l_objet_full:
; restauration des variables de l'objet en cours + on avance le pointeur de sauvegarde des structures dynamiques d'objet
	ldr		R13,pointeur_buffers_variables_objets_en_cours
	
	ldmia	R13!,{R0-R12}
	str		R0,flag_classique_en_cours
	str		R1,pointeur_objet_source_transformation
	str		R2,pointeur_points_objet_classique
	str		R3,nb_points_objet_en_cours_objet_classique
	str		R4,position_objet_en_cours_X
	str		R5,position_objet_en_cours_Y
	str		R6,position_objet_en_cours_Z
	str		R7,increment_position_X
	str		R8,increment_position_Y
	str		R9,increment_position_Z
	str		R10,increment_angle_X
	str		R11,increment_angle_Y
	str		R12,increment_angle_Z

	ldmia	R13!,{R0-R12}
	str		R0,angleX
	str		R1,angleY
	str		R2,angleZ
;	str		R3,nb_frame_en_cours
	str		R4,pointeur_coordonnees_objet_destination_transformation
	str		R5,flag_transformation_en_cours
	str		R6,pointeur_buffer_coordonnees_objet_transformees
	str		R7,nb_etapes_transformation
	str		R8,numero_etape_en_cours_transformation
	str		R9,flag_animation_en_cours
	str		R10,pointeur_vers_coordonnees_points_animation_original
	str		R11,pointeur_vers_coordonnees_points_animation_en_cours
	str		R12,nb_points_animation_en_cours_objet_anime
	
	ldmia	R13!,{R0-R12}
	str		R0,nb_frame_animation
	str		R1,nb_frame_animation_en_cours
	str		R2,flag_mouvement_en_cours
	str		R3,pointeur_debut_mouvement
	str		R4,pointeur_index_actuel_mouvement
	str		R5,nombre_etapes_du_mouvement_initial
	str		R6,nombre_etapes_du_mouvement_en_cours
	str		R7,flag_repetition_mouvement_en_cours
	str		R8,pointeur_initial_repetition_mouvement
	str		R9,pointeur_actuel_repetition_mouvement
	str		R10,nombre_etapes_repetition_du_mouvement_initial
	str		R11,nombre_etapes_repetition_du_mouvement_en_cours
	str		R12,distance_z
	
;	str		R13,pointeur_buffers_variables_objets_en_cours
	
	mov		pc,lr




;--------------------------------------------------------------------
;    VBL
;--------------------------------------------------------------------

	.ifeq		1

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


; ------------------------------------------------------------------------
;
;        boucle affichage VBL Sprites
;
; ------------------------------------------------------------------------




;	ldr		R12,pointeur_actuel_buffer_en_cours_d_affichage
;	ldr		R11,nb_sprites_en_cours_affichage


	ldr		R12,pointeur_lecture_calculs_pendant_affichage
	ldr		R11,nombre_sprites_sequence_en_cours_affichage

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

	ldr		r2,screenaddr1
	add		R1,R2,R0			; R1=R2+R0 offset ecran

	ldr		R15,[R1,R6, lsl #2]				; R15 = adresse routine sprite
	
retour_copie_sprite:

	ldr		R11,saveR11_local
	ldr		R12,saveR12_local



	subs	R11,R11,#1
	bgt		boucle_affiche_sprites_vbl

	str		R12,pointeur_lecture_calculs_pendant_affichage

;exploiter sequences
; - diminuer nombre_frames_sequence_en_cours_affichage de 1
; si egal à 0 
;	- continuer à parcourir les sequences :
		
;		- si sequence_infinie=0 => diminuer nb_repetition_sequence_affichage
;		- si égal à 0 => lire la suite à partir de pointeur_lecture_sequences_affichage : si repetition = -1 => sequence_infinie = 1
;		- si >0 : pointeur_initial_lecture_calculs_pendant_affichage => pointeur_lecture_calculs_pendant_affichage & nombre_frames_initial_sequence_en_cours_affichage => nombre_frames_sequence_en_cours_affichage

	ldr		R0,nombre_frames_sequence_en_cours_affichage
	subs	R0,R0,#1
	bgt		pas_fin_frames_affichage_sequence_en_cours

	ldr		R1,sequence_infinie
	cmp		R1,#0
	beq		pas_sequence_infinie
; on est sur une sequence infinie
	ldr		R0,nombre_frames_initial_sequence_en_cours_affichage
	ldr		R1,pointeur_initial_lecture_calculs_pendant_affichage
	str		R1,pointeur_lecture_calculs_pendant_affichage
	
	b		pas_fin_frames_affichage_sequence_en_cours
	
	
pas_sequence_infinie:
	ldr		R1,nb_repetition_sequence_affichage
	subs	R1,R1,#1
	str		R1,nb_repetition_sequence_affichage
	beq		fin_de_repetition_de_sequence
; on repete la sequence
	ldr		R0,nombre_frames_initial_sequence_en_cours_affichage
	ldr		R1,pointeur_initial_lecture_calculs_pendant_affichage
	str		R1,pointeur_lecture_calculs_pendant_affichage
	
	b		pas_fin_frames_affichage_sequence_en_cours	

fin_de_repetition_de_sequence:
	ldr		R2,pointeur_lecture_sequences_affichage
; - numéro de séquence
; - nb répétition de la séquence
	ldr		R3,[R2],#4				; R3 = numéro de séquence
	ldr		R4,[R2],#4				; R4 = nb répétition de la séquence
	str		R4,nb_repetition_sequence_affichage
	str		R2,pointeur_lecture_sequences_affichage
	
	cmp		R4,#-1
	bgt		la_nouvelle_sequence_n_est_pas_infinie
	str		R4,sequence_infinie							; on bascule en sequence infinie

la_nouvelle_sequence_n_est_pas_infinie:
; 	- pointeur mémoire debut séquence
;	- nb étapes de la séquence
;	- nb points de la séquence
	
	ldr		R1,pointeur_buffer_sequences_affichage
; R2 * 12 = 4+8
	mov		R3,R3,lsl #2				; R2*4
	add		R3,R3,R3, lsl #1			; R2 = R2*4 + R2*4*2 = 12*R2
	ldr		R4,[R1,R3]					; pointeur mémoire debut séquence
	str		R4,pointeur_lecture_calculs_pendant_affichage
	str		R4,pointeur_initial_lecture_calculs_pendant_affichage
	add		R1,R1,#4
	ldr		R4,[R1,R3]					; nb étapes/frames de la séquence
	str		R4,nombre_frames_sequence_en_cours_affichage
	str		R4,nombre_frames_initial_sequence_en_cours_affichage
	add		R1,R1,#4
	ldr		R4,[R1,R3]					; nb points de la séquence
	str		R4,nombre_sprites_sequence_en_cours_affichage	
	
	b		continuer_apres_gestion_sequence


	
pas_fin_frames_affichage_sequence_en_cours:
	str		R0,nombre_frames_sequence_en_cours_affichage

continuer_apres_gestion_sequence:



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

	.endif

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
	mov		R2,#15			; 16 couleurs
	
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
nb_points_objet_en_cours_au_total:			.long	16
nb_points_un_seul_objet:					.long	0
nb_points_objet_en_cours_objet_classique:		.long	8
nb_points_objet_en_cours_objet_anime:		.long	8

; animedz
pointeur_position_dans_les_animations:		.long	anim4

nb_frames_rotation_classique:				.long 0
nb_frames_total_calcul:						.long 0
nb_frames_total_affichage:					.long 0

pointeur_objet_en_cours:					.long	cube
pointeur_points_objet_classique:			.long	cube
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
increment_angle_X:		.long 0
increment_angle_Y:		.long 0
increment_angle_Z:		.long 2
increment_position_X:		.long 0
increment_position_Y:		.long 0
increment_position_Z:		.long 2
distance_z:				.long 0x400


position_objet_en_cours_X:		.long 0
position_objet_en_cours_Y:		.long 0
position_objet_en_cours_Z:		.long 0

position_objet_sur_ecran_X:			.long 0
position_objet_sur_ecran_Y:			.long 0



nombre_d_objets_de_la_scene_initial:		.long		0
nombre_d_objets_de_la_scene_en_cours:		.long		0
pointeur_buffers_variables_objets_initial:			.long	buffers_variables_objets
pointeur_buffers_variables_objets_en_cours:			.long	buffers_variables_objets


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

incrementation_des_angles:
	mov	r11,#511
	
	ldr r1,angleX
	ldr	r12,increment_angle_X
	add	r1,r1,r12
	and	r1,r1,r11
	str	r1,angleX
	
	ldr r1,angleY
	ldr	r12,increment_angle_Y
	add	r1,r1,r12
	and	r1,r1,r11
	str	r1,angleY
	
	
	ldr r1,angleZ
	ldr	r12,increment_angle_Z
	add	r1,r1,r12
	and	r1,r1,r11
	str	r1,angleZ

	ldr		R1,position_objet_en_cours_X
	ldr		R12,increment_position_X
	adds	R1,R1,R12
	str		R1,position_objet_en_cours_X

	ldr		R1,position_objet_en_cours_Y
	ldr		R12,increment_position_Y
	adds	R1,R1,R12
	str		R1,position_objet_en_cours_Y

	ldr		R1,position_objet_en_cours_Z
	ldr		R12,increment_position_Z
	adds	R1,R1,R12
	str		R1,position_objet_en_cours_Z



	mov	pc,lr

calc3D:
; input : 
;	- pointeur_points_objet_en_cours = pointeur vers les points 3D X,Y,Z
;	- nb_points_objet_en_cours = nombre de points à calculer
;	- pointeur_coordonnees_transformees = pointeur destination du resultats des calculs

	str r14,save_R14

	; calcul de la matrice de transformation
	;mov r12,#matrice
	ldr r11,pointeur_SINCOS
	
	
	ldr r1,angleX
	add r1,r11, r1, lsl #3
	ldmia r1, {r2-r3}			
	; r2=SINX , r3=COSX
	
	ldr r1,angleY
	add r1,r11, r1, lsl #3
	ldmia r1, {r4-r5}
	; r4=SINY , r5=COSY
	
	ldr r1,angleZ
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
	
	ldr		R5,position_objet_en_cours_X
	adds	R1,R1,R5		; X point + X objet
	ldr		R5,position_objet_en_cours_Y
	adds	R2,R2,R5		; Y point + Y objet
	ldr		R5,position_objet_en_cours_Z
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

	ldr 	r9,pointeur_coordonnees_transformees
	ldr 	r8,nb_points_objet_en_cours			; r8=nb points
	ldr 	r10,pointeur_coordonnees_projetees_actuel

	ldr		R2,position_objet_sur_ecran_X
	ldr		R4,position_objet_sur_ecran_Y
	
	ldr		R7,pointeur_table_centrage_sprites
	
; unsued :   R14
boucle_divisions_calcpoints:
	
	ldr 	r11,[r9],#4			; X point
	ldr 	r12,[r9],#4			; Y point
	ldr 	r13,[r9],#4			; Z point
	ldr		R1,[r9],#4			; n° sprite
	mov		R14,R1,asl #3					; numero de sprite * 8 
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


	adds	R0,R0,#208						; centrage horizontal par rapport à l'écran
	

	
	ldr		R3,[R7,R14]				; centrage horizontal en fonction de la taille du sprite
	adds	R0,R0,R3
	
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
	
	add		R7,R7,#4					; on passe à hauteur du sprite en fonction du numéro
	ldr		R3,[R7,R14]				; centrage vertical Y en fonction de la taille du sprite
	sub		R7,R7,#4					; on rebascule sur X
	adds	R0,R0,R3					; on soustrait taille du sprite
	
	adds	R0,R0,R4						; + deplacement objet Y

	cmp		R0,#-32
	bge		.clipping_ok_pas_Y_negatif
	mov		R0,#-32
.clipping_ok_pas_Y_negatif:
	mov		R5,#258							; 258 lignes de hauteur d'ecran
	cmp		R0,R5
	blt		.clipping_ok_pas_Y_sup_258

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

save_numero_sprite:		.long 0
save_R14:	
	.long 0


matrice:
	.long	1,2,3,4,5,6,7,8,9
	
numero_objet:
	.long 0

pointeur_table_centrage_sprites:		.long		table_centrage_sprites



all_objects:	
	.long coords_cube

pointeur_SINCOS:		.long SINCOS



bubblesort_XYZ:
; X Y Z n0 sprite=> 4 * 4 = 16 octets
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

	ldr		R0,nb_points_objet_en_cours_au_total
	
	ldr		R11,pointeur_coordonnees_projetees					; source
	ldr		R12,pointeur_actuel_buffer_en_cours_de_calcul		; destination
	
	ldr		r13,pointeur_table416
	
.boucle_copie_avec_reduction:

	ldmia	R11!,{R1-R4}

	
;	ldr		R1,[R11],#4				; X projeté écran
;	ldr		R2,[R11],#4				; Y projeté écran
;	add		R11,R11,#4				; on saute le Z
;	ldr		R4,[R11],#4				; n° sprite

; on calcule le position ecran
	ldr		R2,[r13,R2,asl #2]		; R2=Y * 416
	adds	R2,R2,R1				; R1 = position mémoire écran : X + 416 * Y
; valeur maxi : 107 328 : 18 bits
; il faut garder le bas du X pour choisir le bon décalage de  sprite
;	mov		R2,R2,asl #2			; 2 bits pour position X 

;	and		R1,R1,#0b11				; on garde la position X sur 4
;	adds	R2,R2,R1				; on ajoute à la position mémoire
	mov		R2,R2,asl #4			; + 4 bits pour le n° sprite 
	adds	R2,R2,R4				; + n° sprite		
	
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

pointeur_pile_quick_sort:		.long	pile_quick_sort

; ------------------------------------------------------------
;
; QUICK SORT
;
; ------------------------------------------------------------


quick_sort:


; X Y Z n0 sprite=> 4 * 4 = 16 octets
	ldr		R10,pointeur_coordonnees_projetees			; R10 = X
	add		R11,R10,#4							; R11 = Y
	add		R12,R11,#4							; R12	= Z
	;add		R13,R12,#4							; R13 = n° sprite
	
	ldr		R1,nb_points_objet_en_cours
	
	ldr		R13,pointeur_pile_quick_sort

qsort:
; push de tous les registres
	stmdb	R13!,{R0-R12,LR}
	
	MOV     R4,R12               ;// R4 = Array Location ( Z )
	MOV     R5,R1               ;// R5 - Array Size
	CMP     R5,#1               ;// Check for an array of size <= 1
    BLE     qsort_done          ;// If array size <= 1, return
	
	CMP     R5,#2               ;// Check for an array of size == 2
	BEQ     qsort_check         ;// If array size == 2, check values
	
qsort_partition:
	mov		R2,R5,lsr #1		 ;// R2 = The middle element index , R1 / 2
	LDR     R6,[R4]             ;// R6 = Beginning of array value
	LDR     R7,[R4,R2,LSL #4]   ;// R7 = Middle of array value, *16 car X Y Z N°sprite = 16 octets
	SUB     R8,R5,#1             ;// R8 = Upper array bound index (len -1 1)
	LDR     R8,[R4,R8,LSL #4]   ;// R8 = End of the array value , *16 car X Y Z N°sprite = 16 octets
	
	CMP     R6,R7                ;// Sort the values
	MOVGT   R9,R6				 ;// echange R6 et R7
    MOVGT   R6,R7
    MOVGT   R7,R9
	
	CMP     R7,R8
    MOVGT   R9,R7				 ;// echange R7 et R8
    MOVGT   R7,R8
    MOVGT   R8,R9
	
	CMP     R6,R7
    MOVGT   R9,R6				 ;// echange R6 et R7 
    MOVGT   R6,R7
    MOVGT   R7,R9
	
	MOV     R6,R7                ;// R6 = Pivot
	MOV     R7,#0                ;// R7 = Lower array bounds index
	SUB     R8,R5,#1             ;// R8 = Upper array bounds index (len - 1)

qsort_loop:
	LDR     R0,[R4,R7,LSL #4]   ;// R0 = Lower value, Z, *16 car X Y Z N°sprite = 16 octets
	LDR     R1,[R4,R8,LSL #4]   ;// R1 = Upper value , Z
	CMP     R0,R6               ;// Compare lower value to pivot
	BEQ     qsort_loop_u        ;// If == pivot, do nothing
	ADDLT   R7,R7,#1            ;// If < pivot, increment lower index
	STRGE   R0,[R4,R8,LSL #4]  ; // If > pivot, swap values
	STRGE   R1,[R4,R7,LSL #4]
; X
	sub		R10,R4,#8			; position Z - 8 = X
	LDRGE	R0,[R10,R7,LSL #4]	; X1
	LDRGE	R1,[R10,R8,LSL #4]	; X2
	STRGE   R0,[R10,R8,LSL #4]	; X1
	STRGE   R1,[R10,R7,LSL #4]	; X2
; Y
	add		R10,R10,#4			; passe à position Y
	LDRGE	R0,[R10,R7,LSL #4]	; Y1
	LDRGE	R1,[R10,R8,LSL #4]	; Y2
	STRGE   R0,[R10,R8,LSL #4]	; Y1
	STRGE   R1,[R10,R7,LSL #4]	; Y2
; n° sprite
	add		R10,R10,#8			; passe à position n°sprite
	LDRGE	R0,[R10,R7,LSL #4]	; n° 1
	LDRGE	R1,[R10,R8,LSL #4]	; n°2
	STRGE   R0,[R10,R8,LSL #4]	; n°1
	STRGE   R1,[R10,R7,LSL #4]	; n°2

	SUBGE   R8,R8,#1            ; // if > pivot, decrement upper index
	CMP     R7,R8               ; // if indexes are the same, recurse
	BEQ     qsort_recurse
	LDR     R0,[R4,R7,LSL #4]  ; // R0 = Lower value
	LDR     R1,[R4,R8,LSL #4]  ; // R1 = Upper value

qsort_loop_u:
	CMP     R1,R6               ; // Compare upper value to pivot
	SUBGT   R8,R8,#1            ; // if > pivot, decrement upper index
	STRLE   R0,[R4,R8,LSL #4]  ; // If < pivot, swap values
	STRLE   R1,[R4,R7,LSL #4]

; X
	sub		R10,R4,#8			; position Z - 8 = X
	LDRLE	R0,[R10,R7,LSL #4]	; X1
	LDRLE	R1,[R10,R8,LSL #4]	; X2
	STRLE   R0,[R10,R8,LSL #4]	; X1
	STRLE   R1,[R10,R7,LSL #4]	; X2
; Y
	add		R10,R10,#4			; passe à position Y
	LDRLE	R0,[R10,R7,LSL #4]	; Y1
	LDRLE	R1,[R10,R8,LSL #4]	; Y2
	STRLE   R0,[R10,R8,LSL #4]	; Y1
	STRLE   R1,[R10,R7,LSL #4]	; Y2
; n° sprite
	add		R10,R10,#8			; passe à position n°sprite
	LDRLE	R0,[R10,R7,LSL #4]	; n° 1
	LDRLE	R1,[R10,R8,LSL #4]	; n°2
	STRLE   R0,[R10,R8,LSL #4]	; n°1
	STRLE   R1,[R10,R7,LSL #4]	; n°2	
	
	
	ADDLE   R7,R7,#1			; // if < pivot, increment lower index
	CMP     R7,R8               ; // if indexes are the same, recurse
	BEQ     qsort_recurse
	B       qsort_loop          ; // Continue loop
	
qsort_recurse:
	MOV     R12,R4              ; // R0 = Location of the first bucket
	MOV     R1,R7               ; // R1 = Length of the first bucket
	BL      qsort               ; // Sort first bucket
	ADD     R8,R8,#1            ; // R8 = 1 index past final index
	CMP     R8,R5               ; // Compare final index to original length
	BGE     qsort_done          ; // If equal, return
	ADD     R12,R4,R8,LSL #4    ; // R0 = Location of the second bucket , *16 car X Y Z N°sprite = 16 octets
	SUB     R1,R5,R8            ; // R1 = Length of the second bucket
	BL      qsort               ; // Sort second bucket
	B       qsort_done          ; // return
	
qsort_check:
	LDR     R0,[R4]             ; // Load first value into R0
	LDR     R1,[R4,#16]          ; // Load second value into R1
	CMP     R0,R1               ; // Compare R0 and R1
	BLE     qsort_done          ; // If R1 <= R0, then we are done
	
	STR     R1,[R4]             ; // Otherwise, swap values
	STR     R0,[R4,#16]          ; //  *16 car X Y Z N°sprite = 16 octets
; X
	sub		R10,R4,#8			; position Z - 8 = X
	LDR		R0,[R10]			; X1
	LDR		R1,[R10,#16]		; X2
	STR	    R1,[R10]	; X1
	STR	    R0,[R10, #16]	; X2
; Y
	add		R10,R10,#4			; passe à position Y
	LDR		R0,[R10]			; X1
	LDR		R1,[R10,#16]		; X2
	STR	    R1,[R10]	; X1
	STR	    R0,[R10, #16]	; X2
; n° sprite
	add		R10,R10,#8			; passe à position n°sprite
	LDR		R0,[R10]			; X1
	LDR		R1,[R10,#16]		; X2
	STR	    R1,[R10]	; X1
	STR	    R0,[R10, #16]	; X2



qsort_done:

; pop de tous les registres
	ldmia	R13!,{R0-R12,PC}

; ------------------------------------------------------------
;
; QUICK SORT 2eme version
;
; ------------------------------------------------------------


	

quick_sort2:

;  qsort:  @ Takes three parameters:

; R0 = pointeur vers le tableau de valeurs
; R1 = 0
; R2 = nb elements

		ldr		sp,pointeur_pile_quick_sort

		ldr		R0,pointeur_coordonnees_projetees
		add		R0,R0,#8			; pointe sur Z

		mov		R1,#0				; on commence à 0
		ldr		R2,nb_points_objet_en_cours_au_total

; dispos : R8 R9 R10 R11 R12 

qsort2_qsort:
;        @   a:     Pointer to base of array a to be sorted (arrives in r0)
;        @   left:  First of the range of indexes to sort (arrives in r1)
;        @   right: One past last of range of indexes to sort (arrives in r2)
;        @ This function destroys: r1, r2, r3, r5, r7

        stmfd   sp!, {r4, r6, lr}     ; @ Save r4 and r6 for caller
        mov     r6, r2                ; @ r6 <- right

qsort2_qsort_tailcall_entry:
        sub     r7, r6, r1            ; @ If right - left <= 1 (already sorted),
        cmp     r7, #1
        ldmlefd sp!, {r4, r6, pc}     ; @ Return, restoring r4 and r6

        ldr     r7, [r0, r1, asl #4]  ; @ r7 <- a[left], gets pivot element   	Z
		
        add     r2, r1, #1            ; @ l <- left + 1
        mov     r4, r6                ; @ r <- right
		
		
qsort2_partition_loop:
        ldr     r3, [r0, r2, asl #4]  ; @ r3 <- a[l]							Z

        cmp     r3, r7                ; @ If a[l] <= pivot_element,
        addge   r2, r2, #1            ; @ ... increment l, and
        bge     qsort2_partition_test        ; @ ... continue to next iteration.

        sub     r4, r4, #1            ; @ Otherwise, decrement r,
        ldr     r5, [r0, r4, asl #4]  ; @ ... and swap a[l] and a[r].
        str     r5, [r0, r2, asl #4]
        str     r3, [r0, r4, asl #4]
		
; X
		sub		R12,R0,#8				; position en X
		ldr     r3, [r12, r2, asl #4]		; X1
		ldr     r5, [r12, r4, asl #4]		; X2
		str     r5, [r12, r2, asl #4]
		str     r3, [r12, r4, asl #4]
; Y
		add		R12,R12,#4				; position en Y
		ldr     r3, [r12, r2, asl #4]		; Y1
		ldr     r5, [r12, r4, asl #4]		; Y2
		str     r5, [r12, r2, asl #4]
		str     r3, [r12, r4, asl #4]
; n° sprite
		add		R12,R12,#8				; position en n° sprite
		ldr     r3, [r12, r2, asl #4]		; 1
		ldr     r5, [r12, r4, asl #4]		; 2
		str     r5, [r12, r2, asl #4]
		str     r3, [r12, r4, asl #4]
		
		

qsort2_partition_test:
        cmp     r2, r4                ; @ If l < r,
        blt     qsort2_partition_loop        ; @ ... continue iterating.

qsort2_partition_finish:
        sub     r2, r2, #1            ; @ Decrement l
        ldr     r3, [r0, r2, asl #4]  ; @ Swap a[l] and pivot
        str     r3, [r0, r1, asl #4]
        str     r7, [r0, r2, asl #4]

; X
		sub		R12,R0,#8				; position en X		
		ldr     r3, [r12, r2, asl #4]		; X1
		ldr     r5, [r12, r1, asl #4]		; X2
		str     r5, [r12, r2, asl #4]
		str     r3, [r12, r1, asl #4]
; Y
		add		R12,R12,#4				; position en Y
		ldr     r3, [r12, r2, asl #4]		; Y1
		ldr     r5, [r12, r1, asl #4]		; Y2
		str     r5, [r12, r2, asl #4]
		str     r3, [r12, r1, asl #4]
; n° sprite
		add		R12,R12,#8				; position en n° sprite
		ldr     r3, [r12, r2, asl #4]		; 1
		ldr     r5, [r12, r1, asl #4]		; 2
		str     r5, [r12, r2, asl #4]
		str     r3, [r12, r1, asl #4]		
		
		
        bl      qsort2_qsort                ;@ Call self recursively on left part,
                                      ;@  with args a (r0), left (r1), r (r2),
                                      ;@  also preserves r4 and r6
        mov     r1, r4
        b       qsort2_qsort_tailcall_entry  ; @ Tail-call self on right part,
                                      ; @  with args a (r0), l (r1), right (r6)



masque_decodage_X:			.long 0b11111111111111111110000000000000

debut_data:

.include "palette.asm"

pointeur_table416:			.long table416
pointeur_table416negatif:			.long table416negatif

vsync_count:	.long 0
last_vsync:		.long -1


saver14:	.long 0
saver13:	.long 0
savelr:		.long 0
saver5:		.long 0
saver0:		.long 0





		.ifeq		1
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
	
	.endif


SphereAddress:		.long 0
	.p2align 3
SavedR13:	.long 0
SavedR14:	.long 0
			.long 0
			.long 0


;----------------------------------------------------
;
;    RM reconstruit et adapté
;
;----------------------------------------------------


;----------------------------------------------------------------------------------------------------------------------
RM_init:
; ne fait que verifier la version de Risc OS...
	str		lr,save_lr
; get OS version
	MOV     R0,#129
	MOV     R1,#0
	MOV     R2,#0xFF
	SWI     OS_Byte

	STRB    R1,os_version

; Risc os 3.5 ? => sortie
	CMP     R1,#0xA5
	beq		exit
	
	ldr		lr,save_lr
	mov		pc,lr
save_lr:		.long		0

; SH decoded IRQ and FIQ masks
;
; to load/set/store IRQ and FIQ masks use:
;
; Rx=mask
; Ry=&3200000 (IOC base)
;
;
; LDRB Rx,[Ry,#&18+0]      ;load irqa mask (+0)
; STRB Rx,oldirqa          ;store original mask
; MOV  Rx,#%00100000       ;only allow timer 0 interrupt
; STRB Rx,[Ry,#&18+2]      ;(note +2 on storing)
;
; LDRB Rx,[Ry,#&28+0]      ;load irqb mask (+0)
; STRB Rx,oldirqb          ;store original mask
; MOV  Rx,#%00000010       ;only allow sound interrupt
; STRB Rx,[Ry,#&28+2]      ;(note +2 on storing)
;
;

;irqa mask = IOC (&3200000) + &18
;
;bit 0   - il6 0 printer busy / printer irq
;    1   - il7 0 serial port ringing / low battery
;    2   - if  0 printer ack / floppy index
;    3s  - ir  1 vsync
;    4   - por 0 power on
;    5c  - tm0 0 timer 0
;    6   - tm1 1 timer 1
;    7   - 1   0 n/c      (fiq downgrade?)
;
;irqb mask = IOC (&3200000) + &28
;
;bit 0   - il0 0 expansion card fiq downgrade
;    1   - il1 0 sound system buffer change
;    2   - il2 0 serial port controller
;    3   - il3 0 hdd controller / ide controller
;    4   - il4 0 floppy changed / floppy interrupt
;    5   - il5 0 expansion card interrupt
;    6   - stx 1 keyboard transmit empty
;    7cs - str 1 keyboard recieve full
;
; c = cmdline critical
; s = desktop critical
;
;fiq mask (none are critical) = IOC (&3200000) + &38
;
;bit 0  - fh0 0 floppy data request / floppy dma
;    1  - fh1 0 fdc interrupt / fh1 pin on ioc
;    2  - fl  0 econet interrupt
;    3  - c3  0 c3 on ioc
;    4  - c4  0 c4 on ioc / serial interrupt (also IRQB bit2)
;    5  - c5  0 c5 on ioc
;    6  - il0 0 expansion card interrupt
;    7  - 1   0 force fiq (always 1)
;
;cr
;
;bit 0 - c0 IIC data
;    1 - c1 IIC clock
;    2 - c2 floppy ready / density
;    3 - c3 reset enable / unique id
;    4 - c4 aux i/o connector / serial fiq
;    5 - c5 speaker
;    6 - if printer ack or floppy index
;    7 - ir vsync
;	
;----------------------------------------------------------------------------------------------------------------------
RM_start:
	str		lr,save_lr
; appel XOS car si appel OS_SWI si erreur, ça sort directement
	MOV		R0,#0x0C           ;claim FIQ
	SWI		XOS_ServiceCall
	bvs		exit


; we own FIQs


	TEQP	PC,#0xC000001					; bit 27 & 26 = 1, bit 0=1 : IRQ Disable+FIRQ Disable+FIRQ mode ( pour récupérer et sauvegarder les registres FIRQ )
;	TEQP	PC,#0b11<<26 OR 0b01			;disable IRQs and FIQs, change to FIQ mode
	MOV		R0,R0

	ADR       R0,fiqoriginal				; sauvegarde de R8-R14
	STMIA     R0,{R8-R14}

	MOV       R1,#0x3200000
	LDRB      R0,[R1,#0x18]					; lecture et sauvegarde mask IRQ A
	STR       R0,oldIRQa
	LDRB      R0,[R1,#0x28]					; lecture et sauvegarde mask IRQ B
	STR       R0,oldIRQb

; When installing, we will start on the next VSync, so set IRQ for VSync only
; and set T1 to contain 'vsyncvalue', so everything in place for VSync int...

	MOV       R0,#0b00001000
	STRB      R0,[R1,#0x18+2]    ;set IRQA mask to %00001000 = VSync only : bit 3 sur mask IRQ A = vsync
	MOV       R0,#0
	STRB      R0,[R1,#0x28+2]    ;set IRQB mask to 0					:	IRQ B mask à 0 = disabled
	STRB      R0,[R1,#0x38+2]    ;set FIQ mask to 0 (disable FIQs)		:	FIRQ  mask à 0 = disabled

; Timer 1 / IRQ A
	MOV       R0,#0xFF           ;*v0.14* set max T1 - ensure T1 doesn't trigger before first VSync!
	STRB      R0,[R1,#0x50+2]    ;T1 low byte, +2 for write			: verrou / compteur = 0xFFFF
	STRB      R0,[R1,#0x54+2]    ;T1 high byte, +2 for write
	STRB      R1,[R1,#0x58+2]    ;T1_go = reset T1					: remet le compteur a la valeur latch ( verrou)

; on prépare le compteur du Timer 1 qui tournera entre le Vsync et la 1ere ligne de hsync
	MOV       R0,#vsyncreturn_low_ligne199			;or ldr r8,vsyncval  - will reload with this on VSync...			
	STRB      R0,[R1,#0x50+2]    				;T1 low byte, +2 for write									: verrou / compteur 
	MOV       R0,#vsyncreturn_high_ligne199			;or mov r8,r8,lsr#8
	STRB      R0,[R1,#0x54+2]   					;T1 high byte, +2 for write								: verrou / compteur 


; poke our IRQ/FIQ code into &1C-&FC : copie des routines IRQ/FIRQ dans la mémoire basse en 0x18
	MOV       R0,#0
	LDR       R1,[R0,#0x18]      ;load current IRQ vector
	STR       R1,oldIRQbranch

	BIC       R1,R1,#0xFF000000
	MOV       R1,R1,LSL#2
	ADD       R1,R1,#0x18+8
	STR       R1,oldIRQaddress

;copy IRQ/FIQ code to &18 onwards
	ldr			R0,pointeur_fiqbase
	MOV       R1,#0x18	
	LDMIA     R0!,{R2-R12}
	STMIA     R1!,{R2-R12}      ;11 pokey codey
	LDMIA     R0!,{R2-R12}
	STMIA     R1!,{R2-R12}      ;22 pokey codey
	LDMIA     R0!,{R2-R12}
	STMIA     R1!,{R2-R12}      ;33 pokey codey
	LDMIA     R0!,{R2-R12}
	STMIA     R1!,{R2-R12}      ;44 pokey codey
	LDMIA     R0!,{R2-R12}
	STMIA     R1!,{R2-R12}      ;55 pokey codey
	LDMIA     R0!,{R2-R4}
	STMIA     R1!,{R2-R4}       ;58 pokey codey (58 max)

; init des registres permanents
	MOV			R14,#0x3200000         	; 6 2C set R14 to IOC address
	mov			R12,#0x3400000


.equ 	FIQ_notHSync_valeur, 0xC0
; on écrit l'adresse de la routine Vsync dans le code IRQ/FIRQ en bas de mémoire  pour revenir si vsync ou keyboard
	adr		R0,notHSync					;FNlong_adr("",0,notHSync)   ;set up VSync code after copying
	MOV     R1,#FIQ_notHSync_valeur 	;ref. works if assembling on RO3, note 'FIQ_notHSync' is 0-relative!
	STR       R0,[R1]

; sauvegarde de la première instruction pour vérifier la présence du code , pour ne pas lancer plusieurs fois RM, inutile dans mon cas.
;	MOV       R0,#0
;	LDR       R1,[R0,#0x18]      ;first IRQ instruction from our code
;	STR       R1,newIRQfirstinst

; sortie
;									mode SVC Supervisor
	TEQP      PC,#0b11				; %00<<26 OR %11;enable IRQs and FIQs, change to user mode
	MOV       R0,R0
	
	ldr		lr,save_lr
	mov		pc,lr					;exit in USER mode and with IRQs and FIQs on


;----------------------------------------------------------------------------------------------------------------------
RM_release:
	str		lr,save_lr

; we own FIQs
				  
	TEQP      PC,#0x0C000001					; %11<<26 OR %01            ;disable IRQs and FIQs, switch FIQ mode
	MOV       R0,R0

	MOV       R0,#0
	LDR       R1,oldIRQbranch
	STR       R1,[R0,#0x18]        ;restore original IRQ controller
	
	MOV       R0,#0
	MOV       R1,#0x3200000
	STRB      R0,[R1,#0x38+2]      ;set FIQ mask to 0 (disable FIQs)

	LDR       R0,oldIRQa
	STRB      R0,[R1,#0x18+2]
	LDR       R0,oldIRQb
	STRB      R0,[R1,#0x28+2]      ;restore IRQ masks

	TEQP      PC,#0b11  			; (%00<<26) OR %11          ;enable IRQs and FIQs, stay SVC mode
	MOV       R0,R0


	MOV       R0,#0x0B             ;release FIQ
	SWI       XOS_ServiceCall

	ldr		lr,save_lr
	mov		pc,lr					; return USER mode, leave IRQs and FIQs on

;----------------------------------------------------------------------------------------------------------------------
RM_wait_VBL:
	LDRB      R11,vsyncbyte   ;load our byte from FIQ address, if enabled
waitloop_vbl:
	LDRB      R12,vsyncbyte
	TEQ       R12,R11
	BEQ       waitloop_vbl
	MOVS      PC,R14

;----------------------------------------------------------------------------------------------------------------------
RM_scankeyboard:
; https://www.riscosopen.org/wiki/documentation/show/Low-Level%20Internal%20Key%20Numbers
; retour : R0 = touche sur 2 octets
	;mov		R12,#0
	;mov		R0,#0

	LDRB      R12,keybyte2
	ands			R12,R12,#0b1111
	beq		  sortie_keycheck
	LDRB      R0,keybyte1
	ands			R0,R0,#0b1111
	ORR       R0,R12,R0,LSL#4

sortie_keycheck:
	mov		pc,lr				; retour 

;----------------------------------------------------------------------------------------------------------------------
RM_clearkeybuffer:		   ;10 - temp SWI, probably not needed in future once full handler done
	MOV       R12,#0
	STRB      R12,keybyte1
	STRB      R12,keybyte2
	MOV       PC,R14      ;flags not preserved


;----------------------------------------------------------------------------------------------------------------------
; routine de verif du clavier executée pendant l'interruption.  lors de la lecture de 0x04, le bit d'interruption est remis à zéro
RM_check_keyboard:
	;CMP       R13,#256            ;retrace? - this is a backup to disable STx SRx irqs, n/r
	;MOVNE     R8,#%00000000       ;           n/r once everything is working
	;STRNEB    R8,[R14,#&28+2]     ;set IRQB mask to %11000000 = STx or SRx
	;BNE       exitVScode          ;back to IRQ mode and exit

; dans la vbl, registres sauvés en debut de VBL
	;ADR       R8,kbd_stack
	;STMIA     R8,{R4-R7}          ;some regs to play with

; R14 = IOC 
	MOV       R9,#0x3200000       ; R14 to IOC address
	LDRB      R8,[R9,#0x24+0]     ;load irq_B triggers								:IRQ B Status, bit 7 = buffer clavier vide
	TST       R8,#0b10000000       ;bit 7 = SRx, cleared by a read from 04

	; LDMEQIA     R8,{R4-R7}          ;restore regs
	BEQ         exitVScode          ;back to IRQ mode and exit
;BNE       kbd_received
;:
;.kbd_trans
;TST       R4,#%01000000       ;bit 6 = STx, cleared by a write to 04
;LDRNEB    R5,nextkeybyte
;STRNEB    R5,[R14,#&04+2]     ;clear STx
;MOVNE     R5,#%10000000       ;set mask to wait for ok-to-read
;STRNEB    R5,[R14,#&28+2]     ;set IRQB mask to %10000000 = SRx
;:
;LDMIA     R8,{R4-R7}          ;restore regs
;B         exitVScode          ;back to IRQ mode and exit
;
;
kbd_received:

; process key byte, and put ack value in nextkeybyte

	LDRB      R8,keycounter
	RSBS      R8,R8,#1            ;if =1 (NE), then this is the first byte, else (EQ)=second byte
	STRB      R8,keycounter

	LDRB      R10,[R9,#0x04+0]     ;load byte, clear SRx							: lors de la lecture de 0x04, le bit d'interruption est remis à zéro
	STRNEB    R10,keybyte1															; si pas R10 vide on stock l'octet clavier 1
	STRNEB    R9,keybyte2			;clear byte 2!!! (was key-bug until v0.20)
	
	MOVNE     R8,#0b00111111       ;if first byte, reply with bACK					: pdf TRM A4 : BACK 0011 1111 ACK for first keyboard data byte pair.
	STREQB    R10,keybyte2
	
	MOVEQ     R8,#0b00110001       ;if second byte, reply with sACK					: pdf TRM A4 : SACK 0011 0001 Last data byte ACK.
	STRB      R8,[R9,#0x04+2] 		;transmit response = sACK
	;STRB      R6,nextkeybyte

	;MOV       R5,#%01000000       ;set mask to wait for ok-to-transmit
	;STRB      R5,[R14,#&28+2]     ;set IRQB mask to %01000000 = STx
	
	;LDMIA     R8,{R4-R7}          ;restore regs
	B         exitVScode          ;back to IRQ mode and exit
	;B         kbd_trans


; bACK=%00111111
; sACK=%00110001


keycounter:  .byte 0 ;1 or 0
keybyte1:    .byte 0
keybyte2:    .byte 0
nextkeybyte: .byte 0

kbd_stack:
.long      0 ;R4
.long      0 ;R5
.long      0 ;R6
.long      0 ;R7


;currently have rem'd the disable STx SRx irqs in hsync code and checkkeyboard code

;next try only enabling receive, assume transmit is ok...

;something wrong - &FFFF (HRST) seems to be only byte received
;v0.14 worked when trying only enabling receive, assume transmit is ok...

; on arrive avec:
; sauvegarde de R14 dans saveR14_firq en 0xE0
; sauvegarde de R4-R7 dans FIQ_tempstack en 0xD0
;  R14 = pointeur sur saveR14_firq
;  R8 = load irq_A triggers ( anciennement R8) R4 
;  R5 = 0x3200000 ( anciennement R14)  - IOC -
;  R6 = ...
;  R7 = ...

;----------------------------------------------------------------------------------------------------------------------
notHSync:
VBL:
	TST       R8,#0b00001000       ;retest R5 is it bit 3 = Vsync? (bit 6 = T1 trigger/HSync)				: R8 = 0x14 = IRQ Request A => bit 3=vsync, bit 6=Timer 1 / hsync
	STRNEB    R14,[R14,#0x58+2]    ;if VSync, reset T1 (latch should already have the vsyncvalue...)		: si vsync, alors on refait un GO = on remet le compteur (latch) pour le timer 1 à la valeur vsyncreturn ( mise dans les registres dans le start et  après la derniere ligne )
;
; that's the high-priority stuff done, now we can check keyboard too...
;
	BEQ       RM_check_keyboard       ;check IRQ_B for SRx/STx interrupts									: R8=0 / si 0, c'est qu'on a ni bit3=vsync, ni bit 6=Timer 1, donc c'est une IRQ B = clavier/keyboard

	STRB      R8,[R14,#0x14+2]     ; ...and clear all IRQ_A interrupt triggers								: 1 = clear, donc ré-écrire la valeur de request efface/annule la requete d'interruption

; remaskage IRQ A : Timer 1 + Vsync
	MOV       R8,#0b01000000        ; Timer 1 only. **removed VSync trigger v0.05
;	MOV       R8,#0b01001000		; EDZ : Vsync + Timer 1
;	MOV       R8,#0b00001000		; EDZ : Vsync only

	STRB      R8,[R14,#0x18+2]     ;set IRQA mask to %01000000 = T1 only									: mask IRQ A : bit 6 = Timer 1, plus de Vsync

; remaskage IRQ B : clavier/keyboard
	MOV       R8,#0b10000000       ;R8,#%11000000
	STRB      R8,[R14,#0x28+2]     ;set IRQB mask to %11000000 = STx or SRx									: mask IRQ B pour clavier

; remet le compteur inter ligne pour la frequence de Timer 1 = Hsync	
	MOV       R8,#hsyncline_low			; (hsyncline AND &00FF)>>0
	STRB      R8,[R14,#0x50+2]              ;T1 low byte, +2 for write
	MOV       R8,#hsyncline_high		; (hsyncline AND &FF00)>>8
	STRB      R8,[R14,#0x54+2]              ;T1 high byte, +2 for write

; vsyncbyte = 3 - vsyncbyte
; sert de flag de vsync, si modifié => vsync
	LDRB      R8,vsyncbyte
	RSB       R8,R8,#3
	STRB      R8,vsyncbyte


;	ADR       R8,regtable
;	LDMIA     R8,{R9,R10,R11,R12}          ;reset table registers to defaults

; on remet le nombre de ligne a decrementer avant d'arriver à vsync
	mov			R9,#position_ligne_hsync
	mov 		R8,#ylines                  ;reset yline counter
	str			R8,[R9]
	

;	b		zap_swap1

; swap des pointeurs :
; swap pointeur ecrans
	ldr		r8,screenaddr1
	ldr		r9,screenaddr2
	str		r9,screenaddr1
	str		r8,screenaddr2

	ldr		r8,screenaddr1_MEMC
	ldr		r9,screenaddr2_MEMC
	str		r9,screenaddr1_MEMC
	str		r8,screenaddr2_MEMC

; swap pointeurs table reflet

	ldr		R8,pointeur_table_reflet_MEMC1
	ldr		R9,pointeur_table_reflet_MEMC2
	str		R9,pointeur_table_reflet_MEMC1
	str		R8,pointeur_table_reflet_MEMC2

	ldr		R8,vstart_MEMC1
	ldr		R9,vstart_MEMC2
	str		R9,vstart_MEMC1
	str		R8,vstart_MEMC2

	ldr		R8,vend_MEMC1
	ldr		R9,vend_MEMC2
	str		R9,vend_MEMC1
	str		R8,vend_MEMC2

zap_swap1:
;--------------
; test avec vstart 
; vinit = 0x3600000
; vstart = 0x3620000 = 0
; vend = 0x3640000 = 26

; vstart = 0
	mov	R9,#0x3620000
	;mov	R8,#104*32
	ldr		R8,vstart_MEMC1
	add	R8,R8,R9
	str	R8,[R8]
	
; vend = ligne 200
	mov	R9,#0x3640000
	;mov	R8,#104*232			; 199*104 + 104 -4 : 200 +32 lignes en haut
	ldr	R8,vend_MEMC1
	sub	R8,R8,#4
	add	R8,R8,R9
	str	R8,[R8]
	
; update pointeur video hardware vinit
	ldr	r8,screenaddr1_MEMC
	mov r8,r8,lsr #4
	mov r8,r8,lsl #2
	mov r9,#0x3600000
	add r8,r8,r9
	str r8,[r8]

	
; vinit
;	mov	R9,#0x3600000
;	mov		R8,#0
;	add	R8,R8,R9
;	str	R8,[R8]


	.ifeq		1

; ---------------attente debug affichage

	mov   r9,#0x3400000               
	mov   r8,#777
; border	
	orr   r8,r8,#0x00000000            
	str   r8,[r9]  


	mov		R8,#10000
bouclewait:
	mov	R8,R8
	subs	R8,R8,#1
	bgt	bouclewait

	.endif
	
	ldr			R13,pointeur_table_reflet_MEMC1
	;mov			R13,#table_couleur0_vstart_vend

; couleur fond = noir
	mov			R8,#0
	str			R8,[R12]				; remise à noir du fond
	

 

; ---------------attente debug affichage

;	- vstart modifiable après démarrage affichage : vinit à 0, vstart à 0, vend à 199*104+100, attendre affichage, pendant affichage : vstart à 50*104

; vinit à zéro
; vinit
;	mov	R9,#0x3600000
	;mov	R8,#104*50			; 
;	mov		R8,#0
;	add	R8,R8,R9
;	str	R8,[R8]

; vstart à 0
; vstart = 0
;	mov	R9,#0x3620000
;	mov	R8,#104*50			; 199*104 + 104 -4 
;	mov	R8,#0
;	add	R8,R8,R9
;	str	R8,[R8]

; vend = ligne 200
;	mov	R9,#0x3640000
;	mov	R8,#104*39			; 199*104 + 104 -4 
;	sub	R8,R8,#4
;	add	R8,R8,R9
;	str	R8,[R8]





	; update pointeur video hardware vinit
;	ldr	r0,screenaddr1_MEMC
;	mov r0,r0,lsr #4
;	mov r0,r0,lsl #2
;	mov r1,#0x3600000
;	add r0,r0,r1
;	str r0,[r0]

; vinit à la ligne 199
	;mov	R8,#0x3600000
	;add	R8,R8,#(199*104)
	;ldr	R8,valeur_vinit_premiere_ligne
	;str	R8,[R8]

	;ldr	R8,valeur_vend_premiere_ligne
	;str	R8,[R8]


;	ldr	R8,valeur_vstart_premiere_ligne
;	str	R8,[R8]


	
	;MOV       R13,#ylines                  ;reset yline counter

; ----- QTM
;	LDRB      R8,qtmcontrol
;	TEQ       R8,#1
;	BNE       exitVScode                   ;back to IRQ mode and exit

;rastersound:                  ;entered in FIQ mode, must exit via IRQ mode with SUBS PC,R14,#4
;	TEQP      PC,#%11<<26 OR %10  ;enter IRQ mode, IRQs/FIQs off
;	MOV       R0,R0               ;sync
;	STMFD     R13!,{R14}          ;stack R13_IRQ
;	TEQP      PC,#%11<<26 OR %11  ;enter SVC mode, IRQs/FIQs off
;	MOV       R0,R0               ;sync

;	STR       R13,tempr13         ;
;	LDRB      R13,dma_in_progress ;
;	TEQ       R13,#0              ;
;	LDRNE     R13,tempr13         ;
;	BNE       exitysoundcode      ;
;	STRB      PC,dma_in_progress  ;

;	adr		R13,startofstack	;FNlong_adr("",13,startofstack);
;	STMFD     R13!,{R14}          ;stack R14_SVC
;	LDR       R14,tempr13         ;
;	STMFD     R13!,{R14}          ;stack R13_SVC - we are now reentrant!!!
;	BL        rastersound_1       ;call rastersound routine - enables IRQs

;	MOV       R14,#0              ;...on return IRQs/FIQs will be off
;	STRB      R14,dma_in_progress ;
;	LDMFD     R13,{R13,R14}       ;restore R14_SVC and R13_SVC

;exitysoundcode:
;	TEQP      PC,#%11<<26 OR %10  ;back to IRQ mode
;	MOV       R0,R0               ;sync

;	LDMFD     R13!,{R14}
;	SUBS      PC,R14,#4           ;return to foreground


exitVScode:
;	mode IRQ mode, 
	TEQP      PC,#0x0C000002			; %000011<<26 OR %10 ;36 A4 back to IRQ mode				: xor sur bits 27&26 = autorise IRQ et FIRQ. xor sur bit1 = 01 xor 0b10 = 11 SVC
	MOV       R0,R0                  ;37 A8 sync IRQ registers
	SUBS      PC,R14,#4              ;38 AC return to foreground
;----------------------------------------------------------------------------------------------------------------------

			
			
			

; ---------------------
; variables RM
os_version:		.long      0         ;1 byte &A0 for Arthur 0.3/1.2, &A1 for RO2, &A3 for RO3.0, &A4 for RO3.1
fiqoriginal:	
.long      0         ;R8
.long      0         ;R9
.long      0         ;R10
.long      0         ;R11
.long      0         ;R12
.long      0         ;R13
.long      0         ;R14

oldIRQa:	.long	0				; ancien vecteur IRQ A du système
oldIRQb:	.long	0				; ancien vecteur IRQ B du système
newIRQfirstinst:	.long	0	
oldIRQbranch:		.long 	0
oldIRQaddress:		.long	0

vsyncbyte:		.long 	0
pointeur_fiqbase:		.long	fiqbase

pointeur_table_reflet_MEMC1:	.long	table_couleur0_vstart_vend_MEMC1
pointeur_table_reflet_MEMC2:	.long	table_couleur0_vstart_vend_MEMC2

vstart_MEMC1:		.long		104*32
vend_MEMC1:			.long		104*232
vstart_MEMC2:		.long		104*32+(104*290)
vend_MEMC2:			.long		104*232+(104*290)

; 58 lignes en tout
;       .long   couleur0, vstart, vend
;------------------------------------------------------------------------------------------------
table_couleur0_vstart_vend_MEMC1:
;1ere ligne : fin de l'écran du haut. : vend = 0x3640000+((200*104)-4)
	.set	numero_ligne_reflet,199
	.set 	couleur0,0
	.long   couleur0, 0x3620000 + (numero_ligne_reflet*104)+(104*32), 0x3640000+((200*104)-4)+(104*32)
	.set	couleur0, couleur0+0b100000000
	.set	numero_ligne_reflet , numero_ligne_reflet - 1
	.rept	6
		.rept	2
			.long   couleur0, 0x3620000 + (numero_ligne_reflet*104)+(104*32), 0x3640000+(((numero_ligne_reflet+1)*104)+100)+(104*32)
			.set	numero_ligne_reflet , numero_ligne_reflet - 1
		.endr
		.set	couleur0, couleur0+0b100000000
	.endr
; 12+1 = 13 lignes
; ligne 186	à 62 sur 25 lignes
;       .long   couleur0, vstart, vend
		.long   couleur0, 0x3620000 + (186*104)+(104*32), 0x3640000+((187*104)+100)+(104*32)
        .long   couleur0, 0x3620000 + (178*104)+(104*32), 0x3640000+(186*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (170*104)+(104*32), 0x3640000+(178*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (162*104)+(104*32), 0x3640000+(170*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (155*104)+(104*32), 0x3640000+(162*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (147*104)+(104*32), 0x3640000+(155*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (140*104)+(104*32), 0x3640000+(147*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (133*104)+(104*32), 0x3640000+(140*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (126*104)+(104*32), 0x3640000+(133*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (119*104)+(104*32), 0x3640000+(126*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (113*104)+(104*32), 0x3640000+(119*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (106*104)+(104*32), 0x3640000+(113*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (101*104)+(104*32), 0x3640000+(106*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (95*104)+(104*32), 0x3640000+(101*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (90*104)+(104*32), 0x3640000+(95*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (85*104)+(104*32), 0x3640000+(90*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (81*104)+(104*32), 0x3640000+(85*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (77*104)+(104*32), 0x3640000+(81*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (73*104)+(104*32), 0x3640000+(77*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (70*104)+(104*32), 0x3640000+(73*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (68*104)+(104*32), 0x3640000+(70*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (65*104)+(104*32), 0x3640000+(68*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (64*104)+(104*32), 0x3640000+(65*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (62*104)+(104*32), 0x3640000+(64*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (61*104)+(104*32), 0x3640000+(62*104)+100+(104*32)
; 25+13 = 38 lignes affichées, reste 20 lignes
;       .long   couleur0, vstart, vend
       .long   couleur0, 0x3620000 + (60*104)+(104*32), 0x3640000+((61*104)+100)+(104*32)
       .long   couleur0, 0x3620000 + (55*104)+(104*32), 0x3640000+(60*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (50*104)+(104*32), 0x3640000+(55*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (45*104)+(104*32), 0x3640000+(50*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (41*104)+(104*32), 0x3640000+(45*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (37*104)+(104*32), 0x3640000+(41*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (32*104)+(104*32), 0x3640000+(37*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (28*104)+(104*32), 0x3640000+(32*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (24*104)+(104*32), 0x3640000+(28*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (21*104)+(104*32), 0x3640000+(24*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (17*104)+(104*32), 0x3640000+(21*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (14*104)+(104*32), 0x3640000+(17*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (11*104)+(104*32), 0x3640000+(14*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (8*104)+(104*32), 0x3640000+(11*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (6*104)+(104*32), 0x3640000+(8*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (4*104)+(104*32), 0x3640000+(6*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (2*104)+(104*32), 0x3640000+(4*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (1*104)+(104*32), 0x3640000+(2*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (0*104)+(104*32), 0x3640000+(1*104)+100+(104*32)
        .long   couleur0, 0x3620000 + (0*104)+(104*32), 0x3640000+(0*104)+100+(104*32)
; 38+20=58
;------------------------------------------------------------------------------------------------
table_couleur0_vstart_vend_MEMC2:
;1ere ligne : fin de l'écran du haut. : vend = 0x3640000+((200*104)-4)
	.set	numero_ligne_reflet,199
	.set 	couleur0,0
	.long   couleur0, 0x3620000 + (numero_ligne_reflet*104)+(104*32)+(104*290), 0x3640000+((200*104)-4)+(104*32)+(104*290)
	.set	couleur0, couleur0+0b100000000
	.set	numero_ligne_reflet , numero_ligne_reflet - 1
	.rept	6
		.rept	2
			.long   couleur0, 0x3620000 + (numero_ligne_reflet*104)+(104*32)+(104*290), 0x3640000+(((numero_ligne_reflet+1)*104)+100)+(104*32)+(104*290)
			.set	numero_ligne_reflet , numero_ligne_reflet - 1
		.endr
		.set	couleur0, couleur0+0b100000000
	.endr
; 12+1 = 13 lignes
; ligne 186	à 62 sur 25 lignes
;       .long   couleur0, vstart, vend
		.long   couleur0, 0x3620000 + (186*104)+(104*32)+(104*290), 0x3640000+((187*104)+100)+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (178*104)+(104*32)+(104*290), 0x3640000+(186*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (170*104)+(104*32)+(104*290), 0x3640000+(178*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (162*104)+(104*32)+(104*290), 0x3640000+(170*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (155*104)+(104*32)+(104*290), 0x3640000+(162*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (147*104)+(104*32)+(104*290), 0x3640000+(155*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (140*104)+(104*32)+(104*290), 0x3640000+(147*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (133*104)+(104*32)+(104*290), 0x3640000+(140*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (126*104)+(104*32)+(104*290), 0x3640000+(133*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (119*104)+(104*32)+(104*290), 0x3640000+(126*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (113*104)+(104*32)+(104*290), 0x3640000+(119*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (106*104)+(104*32)+(104*290), 0x3640000+(113*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (101*104)+(104*32)+(104*290), 0x3640000+(106*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (95*104)+(104*32)+(104*290), 0x3640000+(101*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (90*104)+(104*32)+(104*290), 0x3640000+(95*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (85*104)+(104*32)+(104*290), 0x3640000+(90*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (81*104)+(104*32)+(104*290), 0x3640000+(85*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (77*104)+(104*32)+(104*290), 0x3640000+(81*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (73*104)+(104*32)+(104*290), 0x3640000+(77*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (70*104)+(104*32)+(104*290), 0x3640000+(73*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (68*104)+(104*32)+(104*290), 0x3640000+(70*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (65*104)+(104*32)+(104*290), 0x3640000+(68*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (64*104)+(104*32)+(104*290), 0x3640000+(65*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (62*104)+(104*32)+(104*290), 0x3640000+(64*104)+100+(104*32)+(104*290)
        .long   couleur0, 0x3620000 + (61*104)+(104*32)+(104*290), 0x3640000+(62*104)+100+(104*32)+(104*290)
; 25+13 = 38 lignes affichées, reste 20 lignes
;       .long   couleur0, vstart, vend
       .long   couleur0, 0x3620000 + (60*104)+(104*32)+(104*290), 0x3640000+((61*104)+100)+(104*290)+(104*32)
       .long   couleur0, 0x3620000 + (55*104)+(104*32)+(104*290), 0x3640000+(60*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (50*104)+(104*32)+(104*290), 0x3640000+(55*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (45*104)+(104*32)+(104*290), 0x3640000+(50*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (41*104)+(104*32)+(104*290), 0x3640000+(45*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (37*104)+(104*32)+(104*290), 0x3640000+(41*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (32*104)+(104*32)+(104*290), 0x3640000+(37*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (28*104)+(104*32)+(104*290), 0x3640000+(32*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (24*104)+(104*32)+(104*290), 0x3640000+(28*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (21*104)+(104*32)+(104*290), 0x3640000+(24*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (17*104)+(104*32)+(104*290), 0x3640000+(21*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (14*104)+(104*32)+(104*290), 0x3640000+(17*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (11*104)+(104*32)+(104*290), 0x3640000+(14*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (8*104)+(104*32)+(104*290), 0x3640000+(11*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (6*104)+(104*32)+(104*290), 0x3640000+(8*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (4*104)+(104*32)+(104*290), 0x3640000+(6*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (2*104)+(104*32)+(104*290), 0x3640000+(4*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (1*104)+(104*32)+(104*290), 0x3640000+(2*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (0*104)+(104*32)+(104*290), 0x3640000+(1*104)+100+(104*290)+(104*32)
        .long   couleur0, 0x3620000 + (0*104)+(104*32)+(104*290), 0x3640000+(0*104)+100+(104*290)+(104*32)
; 38+20=58
;------------------------------------------------------------------------------------------------



; ligne 199 : vstart = 0, vend=(200*104)-4
;	.long	couleur0,0x3620000, 0x3640000+((200*104)-4)
; ligne 200: vstart = 10*104, vend = 104-4
;	.long	couleur0,0x3620000+(104*10), 0x3640000+((1*104)-4)




; fin


; pointeurs proches	
		.p2align		4




;**********************************************************************
;
; Sphere 16x16 violette position 0 V2
;
;**********************************************************************
			

	.p2align 4
pos0v2:



;	ldr		r2,screenaddr1
;	add		R1,R2,R0			; R2=R2+X


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


;	ldr		r2,screenaddr1
;	add		R1,R2,R0			; R2=R2+X

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


;	ldr		r2,screenaddr1
;	add		R1,R2,R0			; R1=R2+R0 offset ecran


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



;	ldr		r2,screenaddr1
;	add		R1,R2,R0			; R1=R2+R0 offset ecran

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
	
data_pos3v2:				   
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






;----------------------------------------------------
;
;    table de sequencage des animation
;
;----------------------------------------------------

; - numéro de séquence
; - nb répétition de la séquence
anim1_sequences:
	.long			0				; séquence 0
	.long			3				; 1 fois
	.long			0				; séquence 0
	.long			-1				; infini jusqu'au calcul suivant
	
	.long			-1				; fin des séquences
	


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
		.long		1				; nombre d'objets de la scene
		.long		objet128	;     - pointeur vers objet
		.long		0,-150,0			;     - X,Y,Z objet
		.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		0,4,4			;     - increment angle X, increment angle Y , increment angle Z
		.long		40,0,0			; 	  - angles depart X,Y,Z, non modifié si =-1
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

		.long		0x200				;	  - zoom / position observateur en Z
		.long		0
		
		.long		1				; nombre d'objets de la scene		
		.long		cube			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		.long		0,0,0			;     - increment X, increment Y , increment Z
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

		.long		1				; nombre d'objets de la scene
		.long		cube			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		.long		0,0,0			;     - increment X, increment Y , increment Z
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
		.long		1				; nombre d'objets de la scene
		.long		cube1			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		.long		0,0,0			;     - increment X, increment Y , increment Z
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

		.long		1				; nombre d'objets de la scene
		.long		cube2			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		.long		0,0,0			;     - increment X, increment Y , increment Z
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

		.long		1				; nombre d'objets de la scene
		.long		cube2			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		.long		0,0,0			;     - increment X, increment Y , increment Z
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

		.long		1				; nombre d'objets de la scene
		.long		cube1			;     - pointeur vers objet
		.long		0,0,0			;     - X,Y,Z objet
		.long		0,0,0			;     - increment X, increment Y , increment Z
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
		.long		1				; nombre d'objets de la scene
		.long		objet_sphere
		.long		200,0,50			;     - X,Y,Z objet
		.long		0,0,0			;     - increment X, increment Y , increment Z
		.long		4,4,0			;     - increment angle X, increment angle Y , increment angle Z
		.long		0,128,0		; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		128				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		coordonnees_tube64				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		128				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		coordonnees_points_carre				;     - pointeur vers data animation, 0 = pas d'anim
		.long		64				;	  - nombre de points à animer
		.long		40				;     - nombre d'étapes en frame, 0 = pas d'anim
; mouvement de l'objet
		.long		-1; 			; table_mouvement_vertical_vers_le_bas	; table_de_mouvement, -1 = pas de mouvement
		.long		160	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

		.long		0x200			;	  - zoom / position observateur en Z
		.long 		0

; etape 2
		.long		1				; nombre d'objets de la scene
		.long		dummy			;     - pointeur vers objet
		.long		200,0,50			;     - X,Y,Z objet
		.long		0,0,0			;     - increment X, increment Y , increment Z
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
		.long		1				; nombre d'objets de la scene
		.long		objet_points_carre			;     - pointeur vers objet
		.long		200,0,50			;     - X,Y,Z objet
		.long		0,0,0			;     - increment X, increment Y , increment Z
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
		.long		2				; nombre d'objets de la scene
		.long		objet_corps_heli			;     - pointeur vers objet
		.long		-100,100,-2200			;     - X,Y,Z objet
		.long		0,2,20			;     - increment X, increment Y , increment Z
		.long		0,1,0			;     - increment angle X, increment angle Y , increment angle Z
		.long		0,256+128,256			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		300				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		0				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		coordonnees_animation_helice_HELI				;     - pointeur vers data animation, 0 = pas d'anim
		.long		8				;	  - nombre de points à animer
		.long		8				;     - nombre d'étapes en frame, 0 = pas d'anim
; mouvement de l'objet
		.long		0  ;table_mouvement_XY_centre_de_haut_en_bas	; table_de_mouvement, -1 = pas de mouvement
		.long		320	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

		.long		0x330			;	  - zoom / position observateur en Z
; 2eme objet
		.long		objet_corps_heli			;     - pointeur vers objet
		.long		0,500,-2000			;     - X,Y,Z objet
		.long		0,0,20			;     - increment X, increment Y , increment Z
		.long		0,0,0			;     - increment angle X, increment angle Y , increment angle Z
		.long		256,128,0			; 	  - angles depart X,Y,Z, non modifié si =-1
		.long		300				; 	  - nb frames rotation classique, 0 = pas de rotation classique
; transformation
		.long		0				;	  - coordonnees objet de destination d'une transformation, 0 = pas de transformation
		.long		0				;	  - nombre étapes transformation, 0 = pas de transformation
; animation
		.long		coordonnees_animation_helice_HELI				;     - pointeur vers data animation, 0 = pas d'anim
		.long		8				;	  - nombre de points à animer
		.long		8				;     - nombre d'étapes en frame, 0 = pas d'anim
; mouvement de l'objet
		.long		0	; table_de_mouvement, -1 = pas de mouvement
		.long		320	; nombre étapes du mouvement
		.long		-1	; pointeur vers table de mouvement pour repetition, -1 = pas de repetition, mouvement terminé
		.long		0	; nombre étapes de repetition du mouvement

		.long		0x530			;	  - zoom / position observateur en Z

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

objet128:
	.long	coords_128
	.long	320
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
	
objet_corps_heli:
	.long	coordonnees_HELI
	.long	56
	.long	0,0

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

coords_128:

	.set y,-240
	.rept	16
	.set x,-300
		.rept	20
			.long	x
			.long   0
			.long   y
			.long   0
			.set x,x+30
		.endr
		.set y,y+30
	.endr

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

coordonnees_points_carre:		
		.include	"RIPPLEDZ_A.s"
coordonnees_sphere:		
		.include	"sphere.s"
coordonnees_tube64:		
		.include	"tube.s"
coordonnees_animation_helice_HELI:
; 8 boule pour l'helice
; nb etapes : 8
		.include	"HELI_ROT.s"

coordonnees_HELI:
	.long 240,100,160,0	;SKIDRIGHT
	.long 240,100,80,0
	.long 240,100,0,0
	.long 240,100,0,0
	.long 240,100,-70,7
	.long 240,100,-130,10
	.long 240,100,-180,13
	.long -240,100,160,0	;SKIDLEFT
	.long -240,100,80,0
	.long -240,100,0,0
	.long -240,100,0,0
	.long -240,100,-70,7
	.long -240,100,-130,10
	.long -240,100,-180,13
	.long -180,60,40,13
	.long -180,60,-40,13
	.long 180,60,40,13
	.long 180,60,-40,13
	.long 0,10,-180,10	;BOTTOM
	.long 0,30,-100,0
	.long 0,30,-20,0
	.long 0,30,60,0
	.long 0,10,120,10
	.long 80,10,-180,10
	.long 80,30,-100,0
	.long 80,30,-20,0
	.long 80,30,60,0
	.long 80,10,120,10
	.long -80,10,-180,10
	.long -80,30,-100,0
	.long -80,30,-20,0
	.long -80,30,60,0
	.long -80,10,120,10
	.long 80,-50,-180,0
	.long 80,-50,-100,0
	.long 80,-50,-20,0
	.long 80,-50,60,2
	.long 0,-50,60,2
	.long -80,-50,-180,0
	.long -80,-50,-100,0
	.long -80,-50,-20,0
	.long -80,-50,60,2
	.long 70,-120,-180,7
	.long 80,-130,-100,0
	.long 80,-130,-20,2
	.long -70,-120,-180,7
	.long -80,-130,-100,0
	.long -80,-130,-20,2
	.long 0,-130,-180,0
	.long 0,-130,-100,0
	.long 0,-130,-20,2
	.long 0,-50,-220,0
	.long 0,-60,-290,7
	.long 0,-70,-350,10
	.long 0,-80,-400,13
	.long 0,-170,-100,11

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

;-----------------------------------
; tables des mouvements
; N * X , Y

; mouvements horizontaux
		.p2align 2
table_mouvement_XY_milieu_de_gauche_a_droite:
; 416 étapes
		.set x,-208
		.rept	416
		.long		x,0
		.set x, x+1
		.endr

table_mouvement_XY_milieu_de_droite_a_gauche:
; 416 étapes
		.set x,+208
		.rept	416
		.long		x,0
		.set x, x-1
		.endr
table_mouvement_XY_haut_de_gauche_a_droite:
; 416 étapes
		.set x,-208
		.rept	416
		.long		x,-60
		.set x, x+1
		.endr

table_mouvement_XY_haut_de_droite_a_gauche:
; 416 étapes
		.set x,+208
		.rept	416
		.long		x,-60
		.set x, x-1
		.endr
; mouvements verticaux
table_mouvement_XY_centre_de_haut_en_bas:
; 300 étapes
		.set y,-149
		.rept	320
		.long		0,y
		.set y, y+1
		.endr
table_mouvement_XY_centre_de_bas_en_haut:
; 320 étapes
		.set y,171
		.rept	320
		.long		0,y
		.set y, y-1
		.endr
		
;table_mouvement_vertical_vers_le_bas:
;		.incbin		"descente_verticaleXY100.bin"			; 50 étapes		X,Y,Z
;		.p2align 2

;table_mouvement_vertical_vers_le_haut:
;		.incbin		"montee_verticaleXY.bin"				; 50 étapes		X,Y
;		.p2align 2

sprite_boule_violette:
		.incbin		"sphere16x16pourArchi.bin"
		.p2align 2

; structure d'une animation:
; X,Y,Z, N° sprite
; 64 points, 20 étapes

		.p2align 3
		
module97:		.incbin	"97,ffa"
				.p2align 2

; ------------------------------------------------------------------
;
; code principal de l'interruption FIQ
;
; calé entre 0x18 et 0x58
;
; ------------------------------------------------------------------



fiqbase:              ;copy to &18 onwards, 57 instructions max
                      ;this pointer must be relative to module

		.incbin		"build\fiqrmi.bin"


fiqend:
		.p2align 2
		

;.section bss,"u"
table416negatif:
			.skip		32*4
table416:	.skip		260*4

coordonnees_transformees:	.space nombre_de_boules_maxi*4*4
coordonnees_projetees:		.space nombre_de_boules_maxi*4*4


table_centrage_sprites:
; 8 octets par taille de sprite, centrage en X , centrage en Y
; * nombre de sprites
			
		.long			-8,-8
		.rept	15
		.long			-8,-8
		.endr
		

;index_et_Z_pour_tri:	.space	4*256
	.p2align 4
table_increments_pas_transformations:		.space			nombre_de_boules_maxi*4*4
; X,Y,Z,increment pas , tout multiplié par 2^15
		.p2align 4
buffer_coordonnees_objet_transformees:		.space			nombre_de_boules_maxi*4*4
	.p2align 4
buffer_calculs_intermediaire:			.skip		nombre_de_boules_maxi*4*4
	.p2align 4
buffer_sequences_calcul:		
; 	- pointeur mémoire debut séquence
;	- nb étapes de la séquence
;	- nb points de la séquence 
		.skip	4*16*3
buffer_sequences_affichage:		
; 	- pointeur mémoire debut séquence
;	- nb étapes de la séquence
;	- nb points de la séquence
		.skip	4*16*3

; buffers pour stocker toutes les variables pour le calcul de 1 objet
; 5 objets en meme temps au maximum
buffers_variables_objets:		.skip		40*4*5

	.skip		14*4*400
pile_quick_sort:



buffer_calcul1:
		;.skip		taille_buffer_calculs
	;.p2align 4
;buffer_calcul2:		
;		.skip		taille_buffer_calculs

;-----------------------------------------------------
; structure dynamique d'objet pour effectuer les calculs dessus

;au début : 
;	- nb_frames_total_calcul=0

; 1 - flag rotation classique objet normal en cours 										: flag_classique_en_cours
; 1 - pointeur vers objet classique												: pointeur_objet_source_transformation, pointeur_objet_en_cours
; 1 - pointeur vers les coordonnées de l'objet											: pointeur_points_objet_classique, pointeur_coordonnees_objet_source_transformation										
; 1 - nb points objet classique													: nb_points_objet_en_cours_objet_classique, nb_points_objet_en_cours, - nb_sprites_en_cours_calcul -
; 3 - X, Y , Z de l'objet													: position_objet_en_cours_X, position_objet_en_cours_Y , position_objet_en_cours_Z
; 3 - increments X , Y et Z de l'objet en 3D											: increment_position_X, increment_position_Y, increment_position_Z
; 3 - angles actuels X , Y , Z de l'objet											: increment_angle_X, increment_angle_Y, increment_angle_Z
; 3 - increments angles sur axes X, Y , Z											: angleX, angleY, angleZ
; 1 - nombre frames de rotation classique, initial										: nb_frames_rotation_classique, - nb_frame_en_cours -
; 1 - nombre frames de rotation classique, en cours

; -- transformation : se fait de pointeur_table_increments_pas_transformations vers pointeur_buffer_coordonnees_objet_transformees
; 1 - pointeur vers objet de destination de la transformation									: pointeur_coordonnees_objet_destination_transformation
; 1 - flag transformation en cours ?												: flag_transformation_en_cours
; 1 - pointeur vers tableau points actuels ( transformation donc points dynamiques)						: pointeur_buffer_coordonnees_objet_transformees => pointeur_points_objet_en_cours
; 1 - nb étapes actuel de transformation											: nb_etapes_transformation
; 1 - numero de l'etape en cours de la transformation										: numero_etape_en_cours_transformation

; -- animation d'une partie de l'objet
; 1 - flag animation en cours 													: flag_animation_en_cours
; 1 - pointeur vers coordonnées actuel animé, initial										: pointeur_vers_coordonnees_points_animation_original
; 1 - pointeur vers coordonnées actuel animé, actuel										: pointeur_vers_coordonnees_points_animation_en_cours
; 1 - nombre de points à animer													: nb_points_animation_en_cours_objet_anime, nb_points_objet_en_cours_objet_anime, - nb_sprites_en_cours_calcul -
; 1 - nb étapes de l'animation, initial												: nb_frame_animation
; 1 - nb étapes de l'animation, actuel												: nb_frame_animation_en_cours

; -- mouvement de l'objet en 2D
; 1 - flag mouvement en cours ?													: flag_mouvement_en_cours
; 1 - pointeur table de mouvement, initial											: pointeur_debut_mouvement
; 1 - pointeur table de mouvement, actuel											: pointeur_index_actuel_mouvement
; 1 - nombre étapes du mouvement, initial											: nombre_etapes_du_mouvement_initial
; 1 - nombre étapes du mouvement, actuel											: nombre_etapes_du_mouvement_en_cours
; 1 - flag si repetition du mouvement												: flag_repetition_mouvement_en_cours
; 1 - pointeur vers table de mouvement pour repetition, initial, -1 = pas de repetition du mouvement				: pointeur_initial_repetition_mouvement
; 1 - pointeur vers table de mouvement pour repetition, actuel									: pointeur_actuel_repetition_mouvement
; 1 - nombre étapes du mouvement de répétition, initial										: nombre_etapes_repetition_du_mouvement_initial
; 1 - nombre étapes du mouvement de répétition, actuel										: nombre_etapes_repetition_du_mouvement_en_cours

; ---
; 1 - zoom / position observateur en Z												: distance_z


; nb_frames_total_calcul = nb_frames_rotation_classique + 

