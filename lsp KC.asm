; OK : - demarrer sur un petit buffer vide : en fait ecrire dans sptr : 0x36C0000
; OK - remplir chaque VBL N samples
; OK - remplir chaque VBL N samples à une autre fréquence : 416 octets / 48 / 20833.333 hz.
; OK - remplir en gérant un volume : table volume : samplevoltable , dans currentvol & DMA_volume . samplevoltable : 64 entrées.
; OK - convertir le sample en mu-law avant 
; OK - mixer le même sample sur 4 voies
; OK - mixer 4 voies : Paula emulateur
; OK - virer le sample 
; OK - initialiser les canaux avec le silence, rechecker tout.
; OK - mettre en place la gestion de dmacon : avant le mixage, si bit du canal =0 => initialiser vers du silence : offset du silence + increment=0 + volume=0
; OK - debug : on depasse lors des repetitions, si nouveau sample il ne faut pas reprendre le depassement. A voir
; OK - correction des frequences
; OK : faire une version avec test de bouclage pour comparer 
; OK - copier la table d'instruments intégrées dans la table instruments locale
; OK - deboucler le remplissage
; OK - optimiser la gestion du repeat : lire 2 registres d'un coup, stocker 2 registres d'un coup
; OK - inverser les octets du stream de word, pour optimiser leur lecture
; OK	- optimiser lecture notes
; OK	- optimiser lecture offset relatif d'instrument : valeur signée

; TODO:
; - tester une frequence + élevée : 31250			624		32



; faire une table de frequences calculées comme QTM
; utiliser les registres FIQ : + 7 registres







; 416 sample / VBL = 20 800 HZ
; Sound Frequency Register (SFR}: Address C0H : micro seconde, de 3 à 256 :  1 s = 1 000 000 µs, /50 ( 1 VBL) = 20 000. 256=>78 valeurs. 416=>48

; frequence ?
; volume ?
; activation registre de controle





; initQTMsound
;	- "XSound_Configure" avec R0-R4 = 0 => sauvegarde config son ( RO-R3 à stocker )
;	- stock R3+8 & +12=volume scaled log amp table :  linear-log table, 
;	- XSound_Configure avec : R4=0, R3=qtmblock ?, R0=nb canaux/voies, R1=dma size /16, R2=current us, frequence
;	- 8 x XSound_Stereo : R1 = image position, R0 = numéro de la voie/channel 
;
; initQTMsound
;
; start
;	- setDMAblock
; 	- 



; frequence OK
; 7812,499999	156		128
; 9615,384614	192		104
; 10416,66667	208		96,00000001
; 12820,51282	256		78,00000001
; 15625			312		64,00000001
; 19230,76923	384		52,00000001
; 20833,33333	416		48
; 25641,02564	512		39
; 31250			624		32 : 624x50.0801282 = 31 249,9999968 / 1000000/32=31250
; 38461,53846	768		26
; 41666,66666	832		24
; 62499,99999	1248	16
; 76923,07692	1536	13

.equ		ecart_sample,		1024

; parametre de qualité
.equ		frequence_replay,	20833							; 20833
.equ		nb_octets_par_vbl,	416								; 416 : 416x50.0801282 = 20 833,333
.equ		nb_octets_par_vbl_fois_4,	nb_octets_par_vbl*4
.equ		ms_freq_Archi,		48								; 48 : 1 000 000 / 48 = 20 833,333
.equ		ms_freq_Archi_div_4_pour_registre_direct,		12

	.org 0x8000
	.balign 8

.equ		dmabuffer1_fix,		0x7E000
.equ		dmabuffer2_fix,		0x7F000


.include "swis.h.asm"




main:

; read machine infos
	mov		R0,#2
	swi		0x58				; OS_ReadSysInfo
	
; R0 	Hardware configuration word 0 = 1 = VIDC1a MEMC1/MEMC1a IOC IOEB
; R1 	Hardware configuration word 1 = 1 = 82C710
; R2 	Hardware configuration word 2 =0 = LCD controller type none, IOMD, VIDC20 variant  VIDC20, 
; R3 	Low half of machine ID
; R4 	High half of machine ID 	


; test sur les frequences pour correction	
	.ifeq	1
	ADR     R0,readclock
	ADR     R1,answer
	SWI 	0x31					; SWI     "XOS_ReadVduVariables"

	LDR     R0,answer				; R0=clock of VIDC = 0x5DC0 = 24 000
; VIDC1A
	
	LDR     R2,shiftclock				; 24000/1000*4096
	ldr		R3,current_uS				; 48
	LDR     R4,chans_use				; 4 canaux

	MOV     R5,#24
	MUL     R0,R2,R3				; R0=48*4 
	MUL     R1,R4,R5				; R1=4*24
	;BL      r0_div_r1				; R0=(R0/R1) << 12 = (0x480000 / 0x60) = 0xC000
	mov		R0,#0xC000

	MOV     R6,R0,LSR#12				; R6=R0>>12
	MUL     R6,R4,R6				; R6 = R6 * 4 canaux
	MOV     R0,R6,LSL#22				; R0 = R6 * 4 canaux << 22
	MOV     R1,R2,LSR#2				; R1 = shiftclock >> 2

	;BL      r0_div_r1				; R0 = 0xC000000   R1=0x6000   => R0=0x2000
	mov		R0,#0x2000
	
	MUL     R0,R5,R0				; R0=actual_uS = 0x30000 = 48*4096 ( <<12)

	str		R0,actual_uS

; test pour note = 400
; dans la table
	mov		R0,#400
	adr		R1,table_increments_frequence
	mov		R0,R0,lsl #2		; note * 4
	ldr		R12,[R1,R0]			; R12 = increment note 400 = 0x6DF = 1759

; calcul avec formule QTM

	mov		R2,#400				; Amiga note
	LDR     R10,Amiga_multiplier
	LDR     R9,actual_uS
	MOV     R7,#9				;default accuracy is 9bits
	RSB     R6,R7,#30               ;30-x
	MOV     R0,R10
	MOV     R1,R2
	;BL      r0_div_r1			; R0=R0/R1 = 0xE3005235 / 400 = 9 521 122
	ldr		R0,valeur9521122
	
	MOV     R0,R0,LSR R7
	MOV     R1,R9
	MUL     R0,R1,R0
	MOV     R2,R0,LSR R6		; R2=0x6CF => décalage de note
	.endif
	
; increment dans R2

	.ifeq	1

	mov		R0,#0
	ldr		R1,pointeur_module_Amiga
	swi		QTM_Load
	
	nop
	
	SWI		QTM_Start

	nop

; qtm sound control
	MVN       R0,#0
	MVN       R1,#0
	MVN       R2,#0
	SWI		0x47E58
	; RO=nb voies du module

	mov		R0,R0

; pour SWI "QTM_MusicVolume" 
	mov		R0,#64
	swi		0x47E5C

;"XQTM_DMABuffer"
	SWI		0x47E4A
; R0 = buffer DMA

	mov		R0,R0


	
	MOV       R0,#0
	MOV       R1,#0
	MOV       R2,#0
	MOV       R3,#0
	MOV       R4,#0
	SWI       XSound_Configure					; Sound_Configure
	
	;R0=4
	;R1=0x1A0			 	Samples per channel=416 
	;R2=0x30				Sample period
	;R3=
	;R4=
	MUL       R0,R1,R0
	; R0=nb octets a remplir
	.endif



	SWI		0x01
	.byte	"20KHZ module LSP player conversion unlooped -  No OS running.",13,10,0
	.p2align 2
	SWI		0x01
	.byte	"16 to 24 pixels",13,10,0
	.p2align 2
	SWI		0x01
	.byte	"24 to 32 pixels",13,10,0
	.p2align 2

; set sound volume
	mov		R0,#100							; maxi 127
	SWI		XSound_Volume	

; read sound volume
	mov		R0,#0							; 0=read = OK 127
	SWI		XSound_Volume


	bl		create_table_lin2log

	mov		R0,R0
	bl		LSP_PlayerInit_standard
	bl		convertion_samples_instruments_en_mu_law
	bl		ajout_ecart_entre_instruments_et_copie_repetitions

; appel inversion des words 16 bits du stream words :
; pointeur sur stream words : LSPVars_standard+4
; pointeur sur stream bytes = fin du stream words = LSPVars_standard
	bl		inverse_bytes_stream_words
	
	
; pour test
;	bl		LSP_Player_standard
	

	; read memc control register
	mov		R0,#0
	mov		R1,#0
	swi		0x1A
	str		R0,memc_control_register_original
	
; default = 0x36E0D4C
; 11 0110 1110 0000 1101 0100 1100
; page size = 11 = 32 KB
; low rom access time = 00 = 450ns
; high rom access time = 01 = 325ns
; Dram refresh control = 01 = during video fly back
; video cursor dma = 1 = enable
; Sound OMA Control = 1 = enable
; Operating System Mode = 0 = OS Mode Off


		



	
	

 ; Set screen size for number of buffers
	MOV 	r0, #DynArea_Screen
	SWI 	OS_ReadDynamicArea
	; r1=taille actuelle de la memoire ecran
	str		R1,taille_actuelle_memoire_ecran
	
	
	MOV r0, #DynArea_Screen
; 416 * ( 32+258+32+258+32)
	MOV		r1, #4096				; 4Ko octets de plus pour le dma audio
	mov		R1,#65536				; evitons QDebug
	SWI		OS_ChangeDynamicArea
	
; taille dynamic area screen = 320*256*2

	MOV		r0, #DynArea_Screen
	SWI		OS_ReadDynamicArea
	
	; r0 = pointeur debut memoire ecrans
	ldr		R10,taille_actuelle_memoire_ecran
	add		R0,R0,R10		; au bout de la mémoire video, le buffer dma
	str		R0,fin_de_la_memoire_video
	
	;add		R0,R0,#4096
	;add		R0,R0,#65536-16384-16384
	add		R1,R0,#16384
	str		R0,adresse_dma1_logical
	add		R1,R0,#16384
	str		R1,adresse_dma2_logical	

	;add		R1,R0,#16384
	;str		R1,adresse_dma3_logical	
	
	;add		R1,R0,#16384
	;str		R1,adresse_dma4_logical		

	
	
	
		ldr		R6,adresse_dma1_logical
		ldr		R5,adresse_dma2_logical
	
		SWI       OS_ReadMemMapInfo 		;  read the page size used by the memory controller and the number of pages in use
		STR       R0,pagesize
		STR       R1,numpages

		SUB       R4,R0,#1			; R4 = pagesize - 1
		BIC       R7,R5,R4          ; page for dmabuffer2 : 
		BIC       R8,R6,R4          ; page for dmabuffer1 : and R6 & not(R4)

		SUB       R5,R5,R7          ;offset into page dma2
		SUB       R6,R6,R8          ;offset into page dma1

		ADR       R0,pagefindblk
		MOV       R1,#0
		STR       R1,[R0,#0]
		STR       R1,[R0,#8]
		MVN       R1,#0
		STR       R1,[R0,#12]
		STR       R7,[R0,#4]
		SWI       OS_FindMemMapEntries 		;not RISC OS 2 or earlier
		LDR       R1,[R0,#0]
		LDR       R4,pagesize
		MUL       R1,R4,R1
		ADD       R1,R1,R5
		STR       R1,adresse_dma2_memc 			;got the correct phys addr of buf2 (R7)
	

		MOV       R1,#0
		STR       R1,[R0,#0]
		STR       R1,[R0,#8]
		MVN       R1,#0
		STR       R1,[R0,#12]
		STR       R8,[R0,#4]
		SWI       OS_FindMemMapEntries ;not RISC OS 2 or earlier
		LDR       R1,[R0,#0]
		LDR       R4,pagesize
		MUL       R1,R4,R1
		ADD       R1,R1,R6
		STR       R1,adresse_dma1_memc ;got the correct phys addr of buf1 (R8)


		;ldr		R6,adresse_dma3_logical
		;ldr		R5,adresse_dma4_logical
	
		;SWI       OS_ReadMemMapInfo 		;  read the page size used by the memory controller and the number of pages in use
		;STR       R0,pagesize
		;STR       R1,numpages

		;SUB       R4,R0,#1			; R4 = pagesize - 1
		;BIC       R7,R5,R4          ; page for dmabuffer2 : 
		;BIC       R8,R6,R4          ; page for dmabuffer1 : and R6 & not(R4)

		;SUB       R5,R5,R7          ;offset into page dma2
		;SUB       R6,R6,R8          ;offset into page dma1

		;ADR       R0,pagefindblk
		;MOV       R1,#0
		;STR       R1,[R0,#0]
		;STR       R1,[R0,#8]
		;MVN       R1,#0
		;STR       R1,[R0,#12]
		;STR       R7,[R0,#4]
		;SWI       OS_FindMemMapEntries 		;not RISC OS 2 or earlier
		;LDR       R1,[R0,#0]
		;LDR       R4,pagesize
		;MUL       R1,R4,R1
		;ADD       R1,R1,R5
		;STR       R1,adresse_dma4_memc 			;got the correct phys addr of buf2 (R7)
	    ;

		;MOV       R1,#0
		;STR       R1,[R0,#0]
		;STR       R1,[R0,#8]
		;MVN       R1,#0
		;STR       R1,[R0,#12]
		;STR       R8,[R0,#4]
		;SWI       OS_FindMemMapEntries ;not RISC OS 2 or earlier
		;LDR       R1,[R0,#0]
		;LDR       R4,pagesize
		;MUL       R1,R4,R1
		;ADD       R1,R1,R6
		;STR       R1,adresse_dma3_memc ;got the correct phys addr of buf1 (R8)

	;.ifeq		1
	; test => KO	
	;mov		R0,#dmabuffer1_fix
	;str		R0,adresse_dma1_memc
	;ADD		R0,R0,#0x2000000
	;str		R0,adresse_dma1_logical

	;mov		R0,#dmabuffer2_fix
	;str		R0,adresse_dma2_memc
	;ADD		R0,R0,#0x2000000
	;str		R0,adresse_dma2_logical
	;.endif
	
;	ldr		r1,adresse_dma1_logical
;	ldr		R2,adresse_dma1_memc
;	ldr		R11,fin_de_la_memoire_video 
;	ldr		R12,taille_actuelle_memoire_ecran

; +16384

;	ldr		r1,adresse_dma2_logical
;	ldr		R2,adresse_dma2_memc
;	ldr		R11,fin_de_la_memoire_video
;	add		R11,R11,#16384
;	ldr		R12,taille_actuelle_memoire_ecran
;	add		R12,R12,#16384

	
	
	


; on met à zéro les buffers DMA
	ldr		R1,adresse_dma1_logical
	mov		R2,#16384					; buffer 1 a 4
	mov		R0,#0
boucle_cls_buffer_dma:
	str		R0,[R1],#4
	subs	R2,R2,#1
	bgt		boucle_cls_buffer_dma


	

	MOV       R0,#0							;  	Channels for 8 bit sound
	MOV       R1,#0						; Samples per channel (in bytes)
	MOV       R2,#0						; Sample period (in microseconds per channel) 
	MOV       R3,#0
	MOV       R4,#0
	SWI       XSound_Configure						;"Sound_Configure"
	
	adr		R5,backup_params_sons
	stmia	R5,{r0-R4}

; bug sound configure
	
	MOV       R0,#1							;  	Channels for 8 bit sound
	MOV       R1,#nb_octets_par_vbl_fois_4	; Samples per channel (in bytes)
	MOV       R2,#ms_freq_Archi				; Sample period (in microseconds per channel)  = 48  / 125 pour 8000hz
	MOV       R3,#0
	MOV       R4,#0
	SWI       XSound_Configure						;"Sound_Configure"
	

	MOV       R0,#4							;  	Channels for 8 bit sound
	MOV       R1,#0							; Samples per channel (in bytes)
	MOV       R2,#0							; Sample period (in microseconds per channel)  = 48  / 125 pour 8000hz
	MOV       R3,#0
	MOV       R4,#0
	SWI       XSound_Configure						;"Sound_Configure"


	MOV       R0,#0							;  	Channels for 8 bit sound
	MOV       R1,#0						; Samples per channel (in bytes)
	MOV       R2,#0						; Sample period (in microseconds per channel) 
	MOV       R3,#0
	MOV       R4,#0
	SWI       XSound_Configure						;"Sound_Configure"
	MUL       R0,R1,R0
; R0=taille du dma 


	.ifeq	0
; change bien la frequence
;sound frequency register ? 0xC0 / VIDC
	mov		R0,#12-1
	mov		R0,#ms_freq_Archi_div_4_pour_registre_direct-1

	mov		r1,#0x3400000               
; sound frequency VIDC
	mov		R2,#0xC0000100
	orr   	r0,r0,R2
	str   	r0,[r1]  
	.endif
	
; variables pour PAULA
; initialiser:
; External :
; 	- OK : offset pointeur sample A B C D
;	- OK : length A B C D
;	- note
; 	- OK : volume A B C D = 64

; Internal
; 	- OK : offset actuel lecture sample
;	- OK : offset fin sample
; 	- OK : increment A B C D = 0

; OK : DMACon = 0

	adr		R0,Paula_registers_external
	ldr		R1,pointeur_debut_silence
	adr		R4,LSPBank
	subs	R2,R1,R4			; offset debut silence

; test silence
	str		R2,[R0,#0x00]		; External Audio channel 0 location
	str		R2,[R0,#0x14]
	str		R2,[R0,#0x28]
	str		R2,[R0,#0x3C]
	
	mov		R2,R2,lsl #12		; << 12
	str		R2,[R0,#0x50]		; internal offsets pointeur debut sample A B C D
	str		R2,[R0,#0x60]
	str		R2,[R0,#0x70]
	str		R2,[R0,#0x80]
		
	
	mov		R2,#0					; External
	
	str		R2,[R0,#0x90]			; DMACon = 0000
	
	str		R2,[R0,#0x0C]			; volume canal A
	str		R2,[R0,#0x20]			; volume canal B
	str		R2,[R0,#0x34]			; volume canal C
	str		R2,[R0,#0x48]			; volume canal D

	mov		R2,#0					; Internal increment A B C D << 12
	str		R2,[R0,#0x5C]
	str		R2,[R0,#0x6C]
	str		R2,[R0,#0x7C]
	str		R2,[R0,#0x8C]
	
	
	ldr		R3,pointeur_LSPBank
	ldr		R3,pointeur_fin_silence
	subs	R3,R3,R4				; fin de sample - debut sample = offset fin de sample

; test silence
	str		R3,[R0,#0x54]			; end sample offset channel 0
	str		R3,[R0,#0x64]
	str		R3,[R0,#0x74]
	str		R3,[R0,#0x84]

	mov		R3,#fin_silence-silence	; taille du silence
	mov		R3,R3,lsr #1			; en mots/word 
	
	str		R3,[R0,#0x04]			; External Audio channel 0 length
	str		R3,[R0,#0x18]			; External Audio channel 1 length
	str		R3,[R0,#0x2C]			; External Audio channel 2 length
	str		R3,[R0,#0x40]			; External Audio channel 3 length
	
	mov		R2,#512
	str		R2,[R0,#0x08]			; External Audio period 0 / note
	str		R2,[R0,#0x1C]			; External Audio period 1 / note
	str		R2,[R0,#0x30]			; External Audio period 2 / note
	str		R2,[R0,#0x44]			; External Audio period 3 / note


; EDZ

	.ifeq		1
; pour test


	mov		R1,#400
boucle_R1_compteur:
	str		R1,sauve_R1_compteur
	bl		LSP_Player_standard
;	bl		Paula_remplissage_DMA_416
	mov		R0,#2
	bl		mixage_DMA_1_voie

	;ldr		R1,sauve_R1_compteur

	;cmp		R1,#200
	;bgt		zap_verif
	;bl		check_valeurs_repetition
;zap_verif:
	ldr		R1,sauve_R1_compteur
	subs	R1,R1,#1
	bgt		boucle_R1_compteur



	.endif


	.ifeq		1

; remplit les 2 dmas $8254
;	bl		Paula_remplissage_DMA_416
	mov		R0,#0
	bl		mixage_DMA_1_voie
	mov		R0,#1
	bl		mixage_DMA_1_voie
	mov		R0,#2
	bl		mixage_DMA_1_voie
	mov		R0,#3
	bl		mixage_DMA_1_voie
	
	
	SWI		22
	MOVNV R0,R0
	bl		set_dma_dma1
	teqp  r15,#0                     
	mov   r0,r0	
	
	bl		swap_pointeurs_dma_son

;	bl		Paula_remplissage_DMA_416
	mov		R0,#0
	bl		mixage_DMA_1_voie
	mov		R0,#1
	bl		mixage_DMA_1_voie
	mov		R0,#2
	bl		mixage_DMA_1_voie
	mov		R0,#3
	bl		mixage_DMA_1_voie


	SWI		22
	MOVNV R0,R0
	bl		set_dma_dma1
	teqp  r15,#0                     
	mov   r0,r0	
	
	bl		swap_pointeurs_dma_son

	.endif

; sound volume
	mov		R0,#127							; maxi 127
	SWI		XSound_Volume		


	SWI		22
	MOVNV R0,R0      




	.ifeq	1
; stereo : 60,64,68,6C,70,74,78,7C
	mov		R0,#3						; 0
	mov		r1,#0x3400000               
	orr		r0,r0,#0x60000000            
	str		r0,[r1]  

	mov		R0,#3						; 1
	mov		r1,#0x3400000               
	orr		r0,r0,#0x64000000           
	str		r0,[r1]  
	
	mov		R0,#3						; 2
	mov		r1,#0x3400000               
	orr		r0,r0,#0x68000000            
	str		r0,[r1]  

	mov		R0,#3						; 3
	mov		r1,#0x3400000               
	orr		r0,r0,#0x6C000000            
	str		r0,[r1] 

	mov		R0,#3						; 4
	mov		r1,#0x3400000               
	orr		r0,r0,#0x70000000            
	str		r0,[r1] 

	mov		R0,#3						; 5
	mov		r1,#0x3400000               
	orr		r0,r0,#0x74000000            
	str		r0,[r1] 

	mov		R0,#3						; 6
	mov		r1,#0x3400000               
	orr		r0,r0,#0x78000000            
	str		r0,[r1] 

	mov		R0,#3						; 7
	mov		r1,#0x3400000               
	orr		r0,r0,#0x7C000000            
	str		r0,[r1] 
	
	.endif


	;bl		set_dma_dma1


; write sptr pour reset DMA
;	mov		R12,#0x36C0000
;	str		R12,[R12]

	teqp  r15,#0                     
	mov   r0,r0
	
;	mov		R0,#02								; Enable sound output 
;	SWI		0x40141								; Sound_Enable	


	SWI		22
	MOVNV R0,R0 

; installation vsync RM
	bl		install_vsync
	bl		wait_VBL




	SWI		22
	MOVNV R0,R0            

	.ifeq		0

; met dans le dma - petit buffer
	ldr		  R12,adresse_dma1_memc
	;mov		R12,#dmabuffer1_fix
	mov       R10,#128-16
	ADD       R10,R10,R12         ;SendN
	SUB       R10,R10,#16         ; fixit ;-)


	MOV       R12,R12,LSR#2       ;(Sstart/16) << 2
	MOV       R10,R10,LSR#2       ;(SendN/16) << 2
	MOV       R0,#0x3600000     ;memc base
	ADD       R1,R0,#0x0080000     ;Sstart
	ADD       R2,R0,#0x00A0000     ;SendN
	ORR       R1,R1,R12           ;Sstart
	ORR       R2,R2,R10           ;SendN
	STR       R2,[R2]
	STR       R1,[R1]

	
	bl		wait_VBL
	
; met dans le dma
	bl		set_dma_dma1

	bl		wait_VBL
	bl		wait_VBL


	.endif

; stereo : 60,64,68,6C,70,74,78,7C
	mov		R0,#2						; 0
	mov		r1,#0x3400000               
	orr		r0,r0,#0x60000000            
	str		r0,[r1]  

	mov		R0,#3						; 1
	mov		r1,#0x3400000               
	orr		r0,r0,#0x64000000           
	str		r0,[r1]  
	
	mov		R0,#5						; 2
	mov		r1,#0x3400000               
	orr		r0,r0,#0x68000000            
	str		r0,[r1]  

	mov		R0,#6						; 3
	mov		r1,#0x3400000               
	orr		r0,r0,#0x6C000000            
	str		r0,[r1] 

	mov		R0,#2						; 4
	mov		r1,#0x3400000               
	orr		r0,r0,#0x70000000            
	str		r0,[r1] 

	mov		R0,#3						; 5
	mov		r1,#0x3400000               
	orr		r0,r0,#0x74000000            
	str		r0,[r1] 

	mov		R0,#5						; 6
	mov		r1,#0x3400000               
	orr		r0,r0,#0x78000000            
	str		r0,[r1] 

	mov		R0,#6						; 7
	mov		r1,#0x3400000               
	orr		r0,r0,#0x7C000000            
	str		r0,[r1] 
	
; write memc control register, start sound

	ldr		R0,memc_control_register_original	
	orr		R0,R0,#0b100000000000
	str		R0,[R0]


	teqp  r15,#0                     
	mov   r0,r0 


;------------------------------------------------ boucle centrale

boucle:

	mov		R0,#5850
boucle_attente:
	mov		R0,R0
	subs	R0,R0,#1
	bgt		boucle_attente


	SWI		22
	MOVNV R0,R0            

	mov   r0,#0x3400000               
	mov   r1,#100
; border	
	orr   r1,r1,#0x40000000              
	str   r1,[r0]                     

	teqp  r15,#0                     
	mov   r0,r0	




	bl		LSP_Player_standard

	SWI		22
	MOVNV R0,R0            

	mov   r0,#0x3400000               
	mov   r1,#10
; border	
	orr   r1,r1,#0x40000000              
	str   r1,[r0]                     

	teqp  r15,#0                     
	mov   r0,r0	


	bl		Paula_remplissage_DMA_416

	.ifeq		1
	mov		R0,#0
	bl		mixage_DMA_1_voie
	mov		R0,#1
	bl		mixage_DMA_1_voie
	mov		R0,#2
	bl		mixage_DMA_1_voie
	mov		R0,#3
	bl		mixage_DMA_1_voie
	.endif

	SWI		22
	MOVNV R0,R0
	bl		set_dma_dma1
	bl		swap_pointeurs_dma_son
	teqp  r15,#0                     
	mov   r0,r0	

	SWI		22
	MOVNV R0,R0            

	mov   r0,#0x3400000               
	mov   r1,#000  
; border	
	orr   r1,r1,#0x40000000               
	str   r1,[r0]                     

	teqp  r15,#0                     
	mov   r0,r0	

	bl		wait_VBL
	
; vsync par risc os
	;mov		R0,#0x13
	;swi		0x6




	bl      scankeyboard

test_touche_space:
	cmp		R0,#0x5F
	bne		boucle
;------------------------------------------------ boucle centrale



exit:
	nop
	nop

	bl		wait_VBL
;-----------------------
;sortie
;-----------------------

	bl	remove_VBL

	adr		R5,backup_params_sons
	ldmia	R5,{r0-R4}

	SWI       XSound_Configure						;"Sound_Configure"
	
	mov		R0,#01								; Disable sound output 
	SWI		XSound_Enable								; Sound_Enable


	MOV r0,#22	;Set MODE
	SWI OS_WriteC
	MOV r0,#12
	SWI OS_WriteC
	
	
; sortie
	MOV R0,#0
	SWI OS_Exit

sauve_R1_compteur:		.long		0

memc_control_register_original:			.long	0
taille_actuelle_memoire_ecran:			.long		0


adresse_dma1_logical:				.long		0
;adresse_dma1_logical_courant:		.long		0
;adresse_dma1_logical_fin:			.long		0
adresse_dma1_memc:					.long		0
;adresse_dma1_memc_courant:			.long		0


adresse_dma2_logical:				.long		0
;adresse_dma2_logical_courant:		.long		0
;adresse_dma2_logical_fin:			.long		0
adresse_dma2_memc:					.long		0
;adresse_dma2_memc_courant:			.long		0

;adresse_dma3_logical:				.long		0
;adresse_dma3_logical_courant:		.long		0
;adresse_dma3_logical_fin:			.long		0
;adresse_dma3_memc:					.long		0
;adresse_dma3_memc_courant:			.long		0

;adresse_dma4_logical:				.long		0
;adresse_dma4_logical_courant:		.long		0
;adresse_dma4_logical_fin:			.long		0
;adresse_dma4_memc:					.long		0
;adresse_dma4_memc_courant:			.long		0


pagesize:		.long	0
numpages:		.long	0

physicaldma1:	.long	0
physicaldma2:	.long	0


offset_silence:				.long	silence-LSPBank
pointeur_debut_silence:		.long	silence
pointeur_fin_silence:		.long	fin_silence
longueur_silence:			.long	02

nombre_instruments_du_module:		.long		0

readclock:
	.long		172
	.long		-1

answer:		.long		0

shiftclock:			.long		98304					; 24000/1000*4096
current_uS:			.long		ms_freq_Archi			; 48
chans_use:			.long		4
actual_uS:			.long		0
Amiga_multiplier:	.long		0xE3005235
valeur9521122:		.long		9521122

fin_de_la_memoire_video:	.long		0

;--------------------------------------------------------------------------------------------
; routines LSP
;--------------------------------------------------------------------------------------------

	.ifeq		1
check_valeurs_repetition:
	ldr		R1,adresse_dma1_logical
	mov		R7,#nb_octets_par_vbl
	adr		R2,table_valeurs_repetition_instrument_7
boucle_lecture_buffer_dma:
	ldr		R0,[R1],#4
	mov		R0,R0,lsr #24
	mov		R4,R2
	mov		R5,#0			; R5 = flag trouvé ?
	mov		R6,#0x80		; nombre de valeurs dans la table
boucle_cherche:
	ldrb	R3,[R4],#1
	cmp		R3,R0
	bne		pas_trouve
; trouve
	mov		R5,#1
pas_trouve:
	subs	R6,R6,#1
	bgt		boucle_cherche
	
	cmp		R5,#0
	bne		valeur_suivante

valeur_suivante:
	subs	R7,R7,#1
	bgt		boucle_lecture_buffer_dma
	mov		pc,lr
	.endif
;-------------------------------------

LSP_Player_standard:								; player tick handle
	adr		R6,Paula_registers_external
	adr		R1,LSPVars_standard
	ldr		R0,[R1]							; byte stream	= $C412

process_Player_standard:
	mov		R11,#0
	ldrb	R10,[R0],#1						; read 1 byte
	cmp		R10,#0
	bne		swCode_Player_standard
	mov		R11,#0x100
	ldrb	R10,[R0],#1						; read 1 byte
	cmp		R10,#0
	bne		swCode_Player_standard
	mov		R11,#0x200
	ldrb	R10,[R0],#1						; read 1 byte

swCode_Player_standard:
	add		R10,R10,R11					; gere le +$100 et le +$200
	
	add		R10,R10,R10					; R10*2 ; valeur byte stream * 2

	ldr		R2,[R1,#12]					; R2=m_codeTableAddr = table des codes

	ldrb	R8,[R2,R10]					; 1 byte : code
	add		R10,R10,#1
	ldrb	R9,[R2,R10]					; 1 byte : code
	adds	R10,R9,R8,asl #8			; R10=code

	beq		noInst_Player_standard		; code = 0 => no instrument, aucune action

	mov		R8,#0xFFFF
	cmp		R10,R8
	beq		r_rewind_Player_standard

	mov		R8,#0xF00F
	cmp		R10,R8
	beq		r_chgbpm_Player_standard
	
;.optim:
optim_Player_standard:	
	mov		R11,#15
	and		R11,R11,R10					; = 4 bits du bas du code = modif DMACon

; R13=mask pour tests
	mov		R13,#0b1000000000000000	

; ------------ repetitions ------------------
	tst		R10,R13						; test bit 15
	beq		noRd_Player_standard
; repetition canal D
	
	ldr		R3,resetv
	add		R7,R6,#0x3C
	ldmia	R3!,{R8-R9}
	stmia	R7,{R8-R9}
	;ldr		R8,[R3],#4					; pointeur sur instrument, partie repetition
	;str		R8,[R6,#0x3C]				; D0=AUD3LCH_L Audio channel 3 location offset	
	;ldr		R8,[R3],#4	
	;str		R8,[R6,#0x40]				; AUD3LEN	

noRd_Player_standard:
	mov		R13,R13,lsr #1				; rotation du masque de test pour test bit suivant
	tst		R10,R13						; test bit 14
	beq		noRc_Player_standard

;	swi		BKP
; repetition canal C
	ldr		R3,resetv+4
	add		R7,R6,#0x28
	ldmia	R3!,{R8-R9}
	stmia	R7,{R8-R9}
	;ldr		R8,[R3],#4					; pointeur sur instrument, partie repetition
	;str		R8,[R6,#0x28]				; D0=AUD2LCH_L Audio channel 2 location offset	
	;ldr		R8,[R3],#4	
	;str		R8,[R6,#0x2C]				; AUD2LEN		

noRc_Player_standard:	
	mov		R13,R13,lsr #1				; rotation du masque de test pour test bit suivant
	tst		R10,R13						; test bit 13
	beq		noRb_Player_standard
; repetition canal B
	ldr		R3,resetv+8
	add		R7,R6,#0x14
	ldmia	R3!,{R8-R9}
	stmia	R7,{R8-R9}
	;ldr		R8,[R3],#4					; pointeur sur instrument, partie repetition
	;str		R8,[R6,#0x14]				; D0=AUD1LCH_L Audio channel 1 location offset	
	;ldr		R8,[R3],#4	
	;str		R8,[R6,#0x18]				; AUD1LEN		
	
noRb_Player_standard:
	mov		R13,R13,lsr #1				; rotation du masque de test pour test bit suivant
	tst		R10,R13						; test bit 12
	beq		noRa_Player_standard
; repetition canal A
	ldr		R3,resetv+12
	;add		R7,R6,#0x00
	ldmia	R3!,{R8-R9}
	stmia	R6,{R8-R9}
	;ldr		R8,[R3],#4					; pointeur sur instrument, partie repetition
	;str		R8,[R6,#0x00]				; D0=AUD1LCH_L Audio channel 1 location offset	
	;ldr		R8,[R3],#4	
	;str		R8,[R6,#0x04]				; AUD1LEN	

; ------------ volumes - stream bytes ------------------
; 4 tests pour les volumes	
noRa_Player_standard:
	mov		R13,R13,lsr #1				; test bit 11
	tst		R10,R13
	beq		no_V_d_Player_standard
	ldrb	R8,[R0],#1
	str		R8,[R6,#0x48]				; volume D

no_V_d_Player_standard:
	mov		R13,R13,lsr #1				; test bit 10
	tst		R10,R13
	beq		no_V_c_Player_standard
	ldrb	R8,[R0],#1
	str		R8,[R6,#0x34]				; volume C
	
no_V_c_Player_standard:
	mov		R13,R13,lsr #1				; test bit 09
	tst		R10,R13
	beq		no_V_b_Player_standard
	ldrb	R8,[R0],#1
	str		R8,[R6,#0x20]				; volume B

no_V_b_Player_standard:
	mov		R13,R13,lsr #1				; test bit 08
	tst		R10,R13
	beq		no_V_a_Player_standard
	ldrb	R8,[R0],#1
	str		R8,[R6,#0x0C]				; volume A

no_V_a_Player_standard:

	str		R0,[R1],#4					; store byte stream ptr
	
; --------- debut lecture du flux en word
	ldr		R0,[R1]

; ------------ notes/periods ------------------
; 4 tests pour les notes
	mov		R13,R13,lsr #1				; test pour note canal D
	tst		R10,R13						; test bit 07
	beq		no_P_d_Player_standard
	ldr		R8,[R0],#2					; lecture d'un word inversé
	mov		R8,R8,lsl #16
	mov		R8,R8,asr #16
	str		R8,[R6,#0x44]				; changement de note canal D
	
no_P_d_Player_standard:
	mov		R13,R13,lsr #1				; test pour note canal C
	tst		R10,R13						; test bit 06
	beq		no_P_c_Player_standard
	ldr		R8,[R0],#2					; lecture d'un word inversé
	mov		R8,R8,lsl #16
	mov		R8,R8,asr #16
	str		R8,[R6,#0x30]				; changement de note canal C
	
no_P_c_Player_standard:
	mov		R13,R13,lsr #1				; test pour note canal B
	tst		R10,R13						; test bit 05
	beq		no_P_b_Player_standard
	ldr		R8,[R0],#2					; lecture d'un word inversé
	mov		R8,R8,lsl #16
	mov		R8,R8,asr #16
	str		R8,[R6,#0x1C]				; changement de note canal B
	
no_P_b_Player_standard:
	mov		R13,R13,lsr #1				; test pour note canal A
	tst		R10,R13						; test bit 04
	beq		no_P_a_Player_standard
	ldr		R8,[R0],#2					; lecture d'un word inversé
	mov		R8,R8,lsl #16
	mov		R8,R8,asr #16
	str		R8,[R6,#0x08]				; changement de note canal A
	
no_P_a_Player_standard:
;.noPa
	cmp		R11,#0
	beq		noInst_Player_standard
	
; gestion du dmacon patch, donc coupe certaines voies
; Notez que si vous remettez en route ces canaux DMA, Paula recommencera le son du début
; dmacon : 0x90

	orr		R3,R11,#0x8000				; activation des canaux, bit 15=0
	;str		R3,DMAcon_Temp
	str		R11,[R6,#0x90]				; DMACon

	adr		R3,resetv

	mov		R2,#0						; position courante et actualisée par rapport aux instruments en version * 12

	adr		R4,table_12_16
	adr		R5,LSP_InstrumentInfo-16	

; ------------ instruments ------------------

; utilisés :	R13,R10,R0,R1,R2,R3,R4,R8,R9,R6
; le numéro d'instrument est relatif au numéro de l'instrument précédent	
; le numéro d'instrument est multiplié par 12 et doit etre multiplié par 16 : table de conversion.
	mov		R13,R13,lsr #1				; test bit 03
	tst		R10,R13
	beq		no_I_d_Player_standard
	ldr		R8,[R0],#2					; lecture d'un word inversé signé
	mov		R8,R8,lsl #16
	mov		R8,R8,asr #16

	adds	R2,R2,R8					; position relative en *12
	ldr		R8,[R4,R2]					; *16 en fonction de la position relative
	
; on doit ecraser : location:OK, length:OK, current sample offset:OK,end sample offset:OK
	
	add		R12,R5,R8					; LSP_InstrumentInfo-16 + n°instrument * 16
; pointeurs debut sample

;	ldr		R8,[R12],#4					; AUD3LCH = offset instrument canal D0
;	str		R8,[R6,#0x3C]				; External Audio channel 3 location
;	mov		R9,R8,lsl #12
;	str		R9,[R6,#0x80]				; Internal current sample offset channel 3 << 12
; longeur sample
;	ldr		R9,[R12],#4					; AUD3LEN : longueur instrument
;	str		R9,[R6,#0x40]				; Audio channel 3 length
;	add		R8,R8,R9, lsl #1			; R8 = debut + 2 x longueur en mot => fin
;	str		R8,[R6,#0x84]				; end sample offset channel 3
; on remplit Internal


	ldmia	R12!,{R8-R9}				; R8=AUD3LCH = offset instrument canal D0 / R9=AUD3LEN : longueur instrument
	add		R11,R6,#0x3C
	stmia	R11,{R8-R9}				; en 0x3C et 0x40
	add		R9,R8,R9, lsl #1			; R9 = debut + 2 x longueur en mot => fin
	mov		R8,R8,lsl #12				; Internal current sample offset channel 3 << 12
	add		R11,R6,#0x80				; 
	stmia	R11,{R8-R9}				; Internal current sample offset channel 3 << 12 + end sample offset channel 3

	
	
	str		R12,[R3]					; pointeur position de la repetition de l'instrument canal D
	add		R2,R2,#6					; on avance le pointeur relatif car on a lu debut ins + longueur ins = 6 octets
	
no_I_d_Player_standard:	
	mov		R13,R13,lsr #1				; test bit 02
	tst		R10,R13
	beq		no_I_c_Player_standard
	ldr		R8,[R0],#2					; lecture d'un word inversé signé
	mov		R8,R8,lsl #16
	mov		R8,R8,asr #16

	adds	R2,R2,R8					; position relative en *12
	ldr		R8,[R4,R2]					; en fonction de la position relative	
	
	add		R12,R5,R8					; LSP_InstrumentInfo-16 + n°instrument
	
	
	
	;ldr		R8,[R12],#4					; AUD2LCH = offset instrument canal D0
	;str		R8,[R6,#0x28]				; Audio channel 2 location
	;mov		R9,R8,lsl #12
	;str		R9,[R6,#0x70]				; Internal current sample offset channel 2 << 12

	;ldr		R9,[R12],#4					; AUD2LEN : longueur instrument
	;str		R9,[R6,#0x2C]				; Audio channel 2 length
	;add		R8,R8,R9, lsl #1			; R8 = debut + 2 x longueur en mot => fin
	;str		R8,[R6,#0x74]				; end sample offset channel 2
	ldmia	R12!,{R8-R9}				; R8=AUD2LCH = offset instrument canal D0 / R9=AUD2LEN : longueur instrument
	add		R11,R6,#0x28
	stmia	R11,{R8-R9}				; en 0x28 et 0x2C
	add		R9,R8,R9, lsl #1			; R9 = debut + 2 x longueur en mot => fin
	mov		R8,R8,lsl #12				; Internal current sample offset channel 3 << 12
	add		R11,R6,#0x70				; 
	stmia	R11,{R8-R9}				; Internal current sample offset channel 3 << 12 + end sample offset channel 2

	str		R12,[R3,#04]				; pointeur position de la repetition de l'instrument canal C
	add		R2,R2,#6					; on avance le pointeur relatif car on a lu debut ins + longueur ins = 6 octets

no_I_c_Player_standard:	
	mov		R13,R13,lsr #1				; test bit 01
	tst		R10,R13
	beq		no_I_b_Player_standard
	ldr		R8,[R0],#2					; lecture d'un word inversé signé
	mov		R8,R8,lsl #16
	mov		R8,R8,asr #16

	adds	R2,R2,R8					; position relative en *12
	ldr		R8,[R4,R2]					; *16 en fonction de la position relative		
	
	add		R12,R5,R8					; LSP_InstrumentInfo-16 + n°instrument
	
	;ldr		R8,[R12],#4					; AUD3LCH = offset instrument canal D0
	;str		R8,[R6,#0x14]				; Audio channel 3 location
	;mov		R9,R8,lsl #12
	;str		R9,[R6,#0x60]				; Internal current sample offset channel 1 << 12

	;ldr		R9,[R12],#4					; AUD3LEN : longueur instrument
	;str		R9,[R6,#0x18]				; Audio channel 3 length
	;add		R8,R8,R9, lsl #1			; R8 = debut + 2 x longueur en mot => fin
	;str		R8,[R6,#0x64]				; end sample offset channel 1
	ldmia	R12!,{R8-R9}				; R8=AUD2LCH = offset instrument canal D0 / R9=AUD2LEN : longueur instrument
	add		R11,R6,#0x14
	stmia	R11,{R8-R9}				; en 0x14 et 0x18
	add		R9,R8,R9, lsl #1			; R9 = debut + 2 x longueur en mot => fin
	mov		R8,R8,lsl #12				; Internal current sample offset channel 3 << 12
	add		R11,R6,#0x60				; 
	stmia	R11,{R8-R9}				; Internal current sample offset channel 3 << 12 + end sample offset channel 2
	
	str		R12,[R3,#8]					; pointeur position de la repetition de l'instrument canal B
	add		R2,R2,#6					; on avance le pointeur relatif car on a lu debut ins + longueur ins = 6 octets
	
no_I_b_Player_standard:	
	mov		R13,R13,lsr #1				; test bit 00
	tst		R10,R13
	beq		no_I_a_Player_standard
	ldr		R8,[R0],#2					; lecture d'un word inversé signé
	mov		R8,R8,lsl #16
	mov		R8,R8,asr #16

	adds	R2,R2,R8					; position relative en *12
	ldr		R8,[R4,R2]					; *16 en fonction de la position relative		
	
	add		R12,R5,R8					; LSP_InstrumentInfo-16 + n°instrument
;	ldr		R8,[R12],#4					; AUD3LCH = offset instrument canal D0
;	str		R8,[R6,#0x00]				; Audio channel 0 location
;	mov		R9,R8,lsl #12
;	str		R9,[R6,#0x50]				; Internal current sample offset channel 0 << 12

;	ldr		R9,[R12],#4					; AUD3LEN : longueur instrument
;	str		R9,[R6,#0x04]				; Audio channel 0 length
;	add		R8,R8,R9, lsl #1			; R8 = debut + 2 x longueur en mot => fin
;	str		R8,[R6,#0x54]				; end sample offset channel 0
	ldmia	R12!,{R8-R9}				; R8=AUD2LCH = offset instrument canal D0 / R9=AUD2LEN : longueur instrument
	;add		R11,R6,#0x00
	stmia	R6,{R8-R9}					; en 0x00 et 0x04
	add		R9,R8,R9, lsl #1			; R9 = debut + 2 x longueur en mot => fin
	mov		R8,R8,lsl #12				; Internal current sample offset channel 3 << 12
	add		R11,R6,#0x50				; 
	stmia	R11,{R8-R9}					; Internal current sample offset channel 3 << 12 + end sample offset channel 2

	str		R12,[R3,#12]				; pointeur position de la repetition de l'instrument canal A
	add		R2,R2,#6					; on avance le pointeur relatif car on a lu debut ins + longueur ins = 6 octets
	
no_I_a_Player_standard:
	
noInst_Player_standard:

	str		R0,[R1]
	
	mov		pc,lr	
; ------------ fin analyse code du stream ------------------


r_rewind_Player_standard:
	ldr		R0,[R1,#28]					; m_byteStreamLoop
	ldr		R2,[R1,#32]					; m_wordStreamLoop
	str		R2,[R1,#4]					; m_wordStream
	b		process_Player_standard
	
r_chgbpm_Player_standard:
	ldrb	R10,[R0],#1					; BPM
	str		R10,[R1,#24]				; m_currentBpm
	b		process_Player_standard	




; ------------ inits LSP ------------------
LSP_PlayerInit_standard:
	ldr		R0,pointeur_LSPMusic
	ldr		R1,pointeur_LSPBank
	adr		R3,LSPVars_standard
	
	add		R0,R0,#4					; skip 'LSP1'
	add		R0,R0,#4					; skip unique id identique dans lsmusic & lsbank
	
	add		R0,R0,#2					; skip major & minor version of LSP (1.03)
; lecture du BPM	
	ldrb	R5,[R0],#1					; lecture d'un word...
	ldrb	R4,[R0],#1
	add		R4,R4,R5,lsl #8				; R4=R5*256+R4 = 1 word
	str		R4,[R3,#24]					; m_currentBpm default BPM : 125
; lecture nombre d'instruments
	ldrb	R5,[R0],#1					; lecture d'un word...
	ldrb	R4,[R0],#1
	add		R4,R4,R5,lsl #8				; instrument count : 0x000F R4=R5*256+R4 = 1 word
	
	sub		R5,R0,#12					; LSP data has -12 offset on instrument tab ( to win 2 cycles in fast player :) )
	str		R5,[R3,#16]					; instrument tab addr
	
	; pas de relocation des instruments

	adr		R8,LSP_InstrumentInfo
	mov		R9,R4						; nb instruments
	str		R4,nombre_instruments_du_module

boucle_copie_table_instruments:
; copie les infos des instruments dans LSP_InstrumentInfo
	ldrb	R4,[R0],#1					; lecture d'un double word...
	ldrb	R5,[R0],#1
	ldrb	R6,[R0],#1					
	ldrb	R7,[R0],#1
	add		R7,R7,R6,lsl #8
	add		R7,R7,R5,lsl #16
	add		R7,R7,R4,lsl #24
	str		R7,[R8],#4					; stock offset debut instrument
	
	ldrb	R4,[R0],#1					; lecture d'un double word...
	ldrb	R5,[R0],#1
	add		R5,R5,R4,lsl #8				; 
	str		R5,[R8],#4					; stock longueur instrument
	
	ldrb	R4,[R0],#1					; lecture d'un double word...
	ldrb	R5,[R0],#1
	ldrb	R6,[R0],#1					
	ldrb	R7,[R0],#1
	add		R7,R7,R6,lsl #8
	add		R7,R7,R5,lsl #16
	add		R7,R7,R4,lsl #24
	str		R7,[R8],#4					; stock offset debut repetition
	
	ldrb	R4,[R0],#1					; lecture d'un double word...
	ldrb	R5,[R0],#1
	add		R5,R5,R4,lsl #8				; 
	str		R5,[R8],#4					; stock longueur repetition
	
	subs	R9,R9,#1
	bgt		boucle_copie_table_instruments
	


; saute 12 x nb instruments R4 : 12=8+4
;	add		R4,R4,R4					;  x2
;	add		R4,R4,R4					;  x4
;	add		R4,R4,R4, lsl #1			; x4 + x8 = x12
;	add		R0,R0,R4					; R0+nb instruements * 12 = +180 => +194/+$C2
	
	ldrb	R5,[R0],#1					; lecture d'un word...
	ldrb	R4,[R0],#1
	add		R4,R4,R5,lsl #8				; instrument count : 0x000F R4=R5*256+R4 = 1 word
; codes count (+2)		d0=0x01c3

	str		R0,[R3,#12]					; code table addr
	add		R4,R4,R4					; *2 = +902   : $c4+ = $456
	add		R0,R0,R4					; saute la table de code

; word stream size = $0000 BFBC ( en $44a dans le fichier lsmusic)	
	ldrb	R10,[R0],#1					; 00
	ldrb	R11,[R0],#1					; 00
	ldrb	R12,[R0],#1					; BF
	ldrb	R13,[R0],#1					; BC 
	add		R13,R13,R10,lsl #24 
	add		R13,R13,R11,lsl #16
	add		R5,R13,R12,lsl #8 			; 4 octets => 1 mot long

; byte stream loop point = $0000 1ADA = 6874
	ldrb	R10,[R0],#1					; 00
	ldrb	R11,[R0],#1					; 00
	ldrb	R12,[R0],#1					; 1A
	ldrb	R13,[R0],#1					; DA 
	add		R13,R13,R10,lsl #24 
	add		R13,R13,R11,lsl #16
	add		R6,R13,R12,lsl #8 			; 4 octets => 1 mot long
	
; word stream loop point = $0000 30F2 = 12530
	ldrb	R10,[R0],#1					; 00
	ldrb	R11,[R0],#1					; 00
	ldrb	R12,[R0],#1					; 30
	ldrb	R13,[R0],#1					; F2 
	add		R13,R13,R10,lsl #24 
	add		R13,R13,R11,lsl #16
	add		R7,R13,R12,lsl #8 			; 4 octets => 1 mot long
	
	str		R0,[R3,#4]					; m_wordStream = pointeur sur stream des words 
	add		R1,R0,R5					; byte stream = a0+d0  = R5 = taille du stream des words
	str		R1,[R3,#0]					; m_byteStream
	
	add		R0,R0,R7
	add		R1,R1,R6
	str		R0,[R3,#32]					; m_wordStreamLoop
	str		R1,[R3,#28]					; m_byteStreamLoop
	
	mov		pc,lr

	.set	valeur16,-16*2
	.rept	2
		.long	valeur16,valeur16,valeur16
		.set valeur16,valeur16+16
	.endr
table_12_16:
	.set	valeur16,0
	.rept	32
		.long	valeur16,valeur16,valeur16
		.set valeur16,valeur16+16
	.endr

LSP_PlayerInit_Insane:
; OK - convertir les samples en mu-law
; - relocaliser les samples en insérant de l'espace pour le bouclage
; - mettre à jour la table LSP_InstrumentInfo avec les nouvelles positions des samples
; - relativiser la table LSP_InstrumentInfo par rapport à LSPBank
	

	ldr		R0,pointeur_LSPMusic
	ldr		R1,pointeur_LSPBank
	
	add		R0,R0,#8				; skip LSP1 + #$ee61e523
	add		R0,R0,#1102				; skip header --depend du module
	adr		R3,LSPVars_Insane
	
	str		R0,[R3,#20]				; pointeur word stream
	add		R4,R0,#49084			; --depend du module
	str		R4,[R3,#12]				; byte stream ptr
	
	add		R0,R0,#12530			; word stream loop pos : --depend du module
	str		R0,[R3]					; word stream loop ptr
	
	add		R4,R4,#6874				; byte stream loop pos : --depend du module
	str		R4,[R3,#28]				; byte stream loop ptr

	mov		pc,lr

	
convertion_samples_instruments_en_mu_law:
; - convertir les samples en mu-law

	ldr		R1,pointeur_LSPBank
	add		R1,R1,#4				; saute la somme de controle au début
	ldr		R2,pointeur_LSPBank_end
	adr		R6,lin2logtab

boucle_convert_sample_mu_law_init_LSP:

	ldrb	R0,[R1]
	ldrb	R0,[R6,R0]
	strb	R0,[R1],#1
	cmp		R1,R2
	blt		boucle_convert_sample_mu_law_init_LSP
; - fin de conversion des samples en mu-law
	mov		pc,lr

ajout_ecart_entre_instruments_et_copie_repetitions:
; - relocaliser les samples en insérant de l'espace pour le bouclage
; OK - lire l'offset de début du sample
; OK - calculer la fin : +2xtaille
; OK - copier en commencant par la fin, le sample vers le bas.
; OK - mettre à jour la table pour chaque sample

	adr		R13,LSP_InstrumentInfo
	ldr		R12,pointeur_LSPBank

	mov		R5,#ecart_sample
	ldr		R8,nombre_instruments_du_module

boucle_sample_par_sample:
	ldr		R4,pointeur_LSPBank_end	
	ldr		R1,[R13]				; offset debut sample
	ldr		R2,[R13,#4]				; nb words .w sample
	add		R2,R2,R2				; longeur en octets
	add		R3,R1,R2				; R3 = offset fin du sample
	
	add		R6,R4,R5				; R6 = nouvelle fin de lspbank
	str		R6,pointeur_LSPBank_end	; sauvegarde nouvelle fin

	
	add		R3,R12,R3				; R3 = offset fin du sample  + pointeur_LSPBank
	
	
boucle_copie_un_sample_avec_ecart:
	subs	R4,R4,#1
	subs	R6,R6,#1
	ldrb	R0,[R4]
	strb	R0,[R6]
	cmp		R4,R3
	bgt		boucle_copie_un_sample_avec_ecart


; mets des zeros dans la zone ecart après le sample	
	mov		R7,R5				;  ecart_sample
	mov		R0,#0
boucle_copie_un_sample_zero_ecart:
	strb	R0,[R4],#1
	subs	R7,R7,#1
	bgt		boucle_copie_un_sample_zero_ecart


; recalculer les offsets qui sont > offset du sample en cours = R1

	adr		R11,LSP_InstrumentInfo
	ldr		R7,nombre_instruments_du_module					; N samples/instruments

reloc_offsets_du_sample_en_cours:	
	ldr		R0,[R11]
	cmp		R0,R1
	ble		.pas_de_recalcul_de_l_offset_du_sample
	add		R0,R0,R5		; on ajoute l ecart crée
	str		R0,[R11]
	ldr		R0,[R11,#8]		; offset repetition
	add		R0,R0,R5		; on ajoute l ecart crée
	str		R0,[R11,#8]
	
	
.pas_de_recalcul_de_l_offset_du_sample:
	add		R11,R11,#16
	
	subs	R7,R7,#1
	bgt		reloc_offsets_du_sample_en_cours



	
	add		R13,R13,#16					; prochain Sample/intrument
	subs	R8,R8,#1
	bgt		boucle_sample_par_sample


; remplir l'écart avec la répétition
	adr		R11,LSP_InstrumentInfo
	ldr		R7,nombre_instruments_du_module					; N samples

boucle_repetition_sample_par_sample:
	ldr		R2,[R11]				; offset debut sample
	ldr		R3,[R11,#4]				; longueur sample en mot
	add		R3,R3,R3				; longueur * 2
	add		R3,R3,R2				; R3=offset fin sample
	mov		R6,R3

	ldr		R0,[R11,#12]			; longueur de la repetition, en mot
; test length = 01 ?
	cmp		R0,#01					; repetition de silence ?
	beq		fin_copie_repetition_sample_dans_ecart
	

	ldr		R12,pointeur_LSPBank
	add		R3,R3,R12				; R3=pointeur fin sample = position écart
	mov		R4,#ecart_sample
	add		R4,R3,R4				; R4=fin de la zone a remplir
; remplir de R3 à R4
	ldr		R5,[R11,#8]				; offset repetition
	add		R5,R5,R12				; adresse reelle debut repetition
	mov		R10,R5					; sauvegarde adresse reelle debut repetition
	
	add		R0,R0,R0				; R0=longueur a repeter en octets
	mov		R9,R0					; sauvegarde longueur de la boucle de repetition

boucle_copie_repetition_du_sample_dans_l_ecart:	
	ldrb	R8,[R5],#1
	strb	R8,[R3],#1
	
	subs	R0,R0,#1				; diminue nb octets de la boucle de repetition
	bgt		pas_de_fin_de_la_boucle_de_repetition_du_sample
; on a fini de copier une boucle de repetition
; il faut réinitialiser R0 et R5
	mov		R0,R9					; nb octets de la boucle
	mov		R5,R10					; R5=adresse reelle debut repetition

pas_de_fin_de_la_boucle_de_repetition_du_sample:
	cmp		R3,R4					; arrivé a la fin de l'écart ?
	blt		boucle_copie_repetition_du_sample_dans_l_ecart
	

fin_copie_repetition_sample_dans_ecart:
	str		R6,[R11,#8]				; mise à jour offset repetition = fin du sample
	

	add		R11,R11,#16				; instrument suivant
	subs	R7,R7,#1
	bgt		boucle_repetition_sample_par_sample
	

; check des nouveaux offsets
	adr		R11,LSP_InstrumentInfo
	ldr		R7,nombre_instruments_du_module					; N samples
	
boucle_verif_reloc_sample:	
	ldr		R0,[R11]				; offset debut sample/instrument
	add		R0,R0,R12				; + adresse lsp bank
; doit commencer par 4* 0x00
	add		R11,R11,#16
	subs	R7,R7,#1
	bgt		boucle_verif_reloc_sample

	mov		pc,lr

inverse_bytes_stream_words:
; inversion des octets de chaque word du stream word
; pointeur sur stream words : LSPVars_standard
; pointeur sur stream bytes = fin du stream words = LSPVars_standard+4

	adr		R3,LSPVars_standard
	ldr		R2,[R3]					; fin du stream words = byte stream
	ldr		R1,[R3,#4]				; pointeur sur stream words
	
boucle_inverse_bytes_stream_words:
	ldrb	R8,[R1]
	ldrb	R9,[R1,#1]
	strb	R9,[R1],#1
	strb	R8,[R1],#1
	cmp		R1,R2
	blt		boucle_inverse_bytes_stream_words
	

	mov		pc,lr


pointeur_module_Amiga:		.long	moduleAmiga
	
LSPVars_standard:
m_byteStream:			.long		0			; 0 byte stream
m_wordStream:			.long		0			; 4 word stream
m_dmaconPatch:			.long		0			; 8 m_lfmDmaConPatch
m_codeTableAddr:		.long		0			; 12 code table addr
m_lspInstruments:		.long		0			; 16 LSP instruments table addr
m_relocDone:			.long		0			; 20 reloc done flag
m_currentBpm:			.long		0			; 24 current BPM
m_byteStreamLoop:		.long		0			; 28 byte stream loop point
m_wordStreamLoop:		.long		0			; 32 word stream loop point
	
LSPVars_Insane:
			.long		0			; 0  word stream loop
			.long		0			; 4  reloc has been done
			.long		0			; 8  current music BPM
			.long		0			; 12  pointeur byte stream		+8
			.long		0			; 16 m_lfmDmaConPatch
			.long		0			; 20 pointeur word stream
			.long		0			; 24 pointeur word stream loop
			.long		0			; 28 pointeur byte stream loop
			
; WARNING: in word stream, instrument offset is shifted by -12 bytes (3 last long of .LSPVars)
LSP_InstrumentInfo:			; (15 instruments)
; adresse relative début sample
; longeur sample *2 ( valeur en word )
; adresse relative début répétition sample
; longeur répétition * 2 ( valeur en word )
; quand repetition length = 0x0001, en fait il y a 4 octets à zéro au début du sample
			.long		0x0000c752,0x1188,0x0000ea62,0x0096
			.long		0x0001ae9a,0x191d,0x0001e0d4,0x0001
			.long		0x00000004,0x08a8,0x00001154,0x0001
			.long		0x00007cfc,0x0662,0x000089c0,0x0001
			.long		0x00008dc0,0x0d39,0x0000a832,0x0001
			.long		0x00001554,0x2753,0x000063fa,0x0086
			.long		0x0001502e,0x0bba,0x000167a2,0x0040
			.long		0x00012234,0x14fd,0x00014c2e,0x0001
			.long		0x0000ff2a,0x0F85,0x00011e34,0x0001
			.long		0x0000ee62,0x0664,0x0000fb2a,0x0001
			.long		0x0000ac32,0x0B90,0x0000c352,0x0001
			.long		0x000067fa,0x0881,0x000078fc,0x0001
			.long		0x000183ee,0x1356,0x0001aa9a,0x0001
			.long		0x00016ba2,0x0A26,0x00017fee,0x0001
			.long		0x0001e4d4,0x0067,0x0001e5a2,0x000f

			.ifeq		1
			.long		0x0000af52, 0x1188, 0x0000d134, 0x0096
			.long		0x00017a9a, 0x191d, 0x00017a9a, 0x0001
			.long		0x00000004, 0x08a8, 0x00000004, 0x0001
			.long		0x000070fc, 0x0662, 0x000070fc, 0x0001
			.long		0x00007dc0, 0x0d39, 0x00007dc0, 0x0001
			.long		0x00001154, 0x2753, 0x00005eee, 0x0086
			.long		0x0001282e, 0x0bba, 0x00013f22, 0x0040
			.long		0x0000fe34, 0x14fd, 0x0000fe34, 0x0001
			.long		0x0000df2a, 0x0f85, 0x0000df2a, 0x0001
			.long		0x0000d262, 0x0664, 0x0000d262, 0x0001
			.long		0x00009832, 0x0b90, 0x00009832, 0x0001
			.long		0x00005ffa, 0x0881, 0x00005ffa, 0x0001
			.long		0x000153ee, 0x1356, 0x000153ee, 0x0001
			.long		0x00013fa2, 0x0a26, 0x00013fa2, 0x0001
			.long		0x0001acd4, 0x00fd, 0x0001ad84, 0x000f
			.endif
			
			.rept		32-15
			.long		0,0,0,0
			.endr

; pointeurs sur la table des instruments, pour repetition de D C B A
resetv:
		.long		0			; pointeur dans la table d'instruments LSP_InstrumentInfo, sur l'adresse de repetition du canal D
		.long		0			; canal C
		.long		0			; canal B
		.long		0			; canal A

pointeur_LSPMusic:			.long		LSPMusic
pointeur_LSPBank:			.long		LSPBank
pointeur_LSPBank_end:		.long		LSPBank_end

;--------------------------------------------------------------------------------------------


	

create_table_lin2log_edz:
	adr		R11,lin2logtab
	mov		R1,#0
	mov		R2,#256

boucle_table_lin2log_edz:
	mov		R0,R1,LSL #24			; de signed 8 bits à signed 32 bits
	SWI     XSound_SoundLog		; This SWI is used to convert a signed linear sample to the 8 bit logarithmic format that’s used by the 8 bit sound system. The returned value will be scaled by the current volume (as set by Sound_Volume).
; résultat dans R0
	STRB    R0,[R11],#1
	adds	R1,R1,#1
	cmp		R1,R2
	blt		boucle_table_lin2log_edz
	mov		pc,lr
	
	

create_table_lin2log:
	adr		R11,lin2logtab
	mov		R2,#256					; nb valeurs
	mov		R1,#0					; valeur actuelle
	
 	adr 	R11,lin2logtab
 	MOV     R1,#255
setlinlogtab:

	MOV     R0,R1,LSL#24		; R0=R1<<24 : en entrée du 8 bits donc shifté en haut, sur du 32 bits
	SWI     XSound_SoundLog		; This SWI is used to convert a signed linear sample to the 8 bit logarithmic format that’s used by the 8 bit sound system. The returned value will be scaled by the current volume (as set by Sound_Volume).
	STRB    R0,[R11,R1]			; 8 bit mu-law logarithmic sample 
	SUBS    R1,R1,#1
	BGE     setlinlogtab
	mov		pc,lr




increment_frequence:			.long	1207959				; 20 bits de precision
increment_frequence12bits:		.long	4719				; 12 bits de precision

mask_bits_virgule_frequence:	.long	0b11111111111111111111
save_R14_Paula:		.long	0
;-------------------------------
; copie avec calcul d'avancée en fonction de la frequence
; sample = 8000
; réel = 20833,3333
;
; R0=sample, R1=adresse sample voie 1, R2=position actuelle sample voie 1
;	ldrb	R0,[R1,R2, ASR#12]
; R3=increment x 2^12
;	add		R2,R2,R3
; R4=volume, 0 = plein volume
;	subs	R0,R0,R4
; si volume négatif => 0
;	movmi	R0,#0
; R14=buffer canaux mélangés
;	strb	R0,[R14],#1	

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

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
valeur0x167a2:		.long		0x167a2+0x80*4
pointeur_expanded_mixing:	.long		expanded_filling_routine
; mixage avec gestion du Paula
Paula_remplissage_DMA_416:
	str	R14,save_R14_Paula

;----------
; U: R0,R1,R2,R3,R4

	adr		R4,table_increments_frequence

	adr		R0,Paula_registers_external

	adr		R14,table_volume

	ldr		R1,[R0,#0x90]						; DMACon
	mov		R1,#0b000001111

; canal A	
	tst		R1,#01							; bit 0 de DMACon ?
	bne		DMACon_Canal_A_On

	ldr		R2,offset_silence				; on pointe sur silence
	mov		R2,R2,lsl #12
	mov		R3,#0							; increment = 0
	mov		R13,#64							; volume = 0
	b		continue_DMACon_Canal_A
DMACon_Canal_A_On:
	ldr		R2,[R0,#0x50]					; current sample ptr channel 0 / Paula_registers_internal

	
	ldr		R3,[R0,#0x08]					; note Amiga canal A
	mov		R3,R3,lsl #2					; *4
	ldr		R3,[R4,R3]
	
	ldr		R13,[R0,#0x0C]						; volume canal A
continue_DMACon_Canal_A:
	ldrb	R13,[R14,R13]					; R13=volume A

; canal B
	tst		R1,#02							; bit 1 de DMACon ?
	bne		DMACon_Canal_B_On
	ldr		R5,offset_silence				; on pointe sur silence
	mov		R5,R5,lsl #12
	mov		R6,#0							; increment = 0
	mov		R10,#64							; volume = 0
	b		continue_DMACon_Canal_B
DMACon_Canal_B_On:
	ldr		R5,[R0,#0x60]
	ldr		R6,[R0,#0x1C]					; note Amiga canal B
	mov		R6,R6,lsl #2					; *4
	ldr		R6,[R4,R6]

	ldr		R10,[R0,#0x20]						; volume canal B
continue_DMACon_Canal_B:
	ldrb	R10,[R14,R10]					; R10=volume
	orr		R13,R10,R13,lsl #8

; canal C
	tst		R1,#04							; bit 2 de DMACon ?
	bne		DMACon_Canal_C_On
	ldr		R8,offset_silence				; on pointe sur silence
	mov		R8,R8,lsl #12
	mov		R9,#0							; increment = 0
	mov		R10,#64							; volume = 0
	b		continue_DMACon_Canal_C
DMACon_Canal_C_On:
	ldr		R8,[R0,#0x70]					; current sample offset C
	ldr		R9,[R0,#0x30]					; note Amiga canal C
	mov		R9,R9,lsl #2					; *4
	ldr		R9,[R4,R9]

	ldr		R10,[R0,#0x34]						; volume canal C
continue_DMACon_Canal_C:
	ldrb	R10,[R14,R10]					; R10=volume
	orr		R13,R10,R13,lsl #8

; canal D
	tst		R1,#8							; bit 3 de DMACon ?
	bne		DMACon_Canal_D_On
	ldr		R11,offset_silence				; on pointe sur silence
	mov		R11,R11,lsl #12
	mov		R12,#0							; increment = 0
	mov		R10,#64							; volume = 0
	b		continue_DMACon_Canal_D
DMACon_Canal_D_On:
	ldr		R11,[R0,#0x80]					; offset actuel position instrument
	ldr		R12,[R0,#0x44]					; note Amiga canal D
	mov		R12,R12,lsl #2					; *4
	ldr		R12,[R4,R12]
	ldr		R10,[R0,#0x48]				; volume canal D
continue_DMACon_Canal_D:
	ldrb	R10,[R14,R10]					; R10=volume
	orr		R13,R10,R13,lsl #8

; R13 = vAvBvCvD


;---------- Mixage
;R0 = temp
;R1 = debut des samples
;R2 = offset actuel voie 1
;R3 = increment suivant la frequence voie 1
;R4 = volume de la voie en cours
;R5 = offset actuel voie 2
;R6= increment suivant la frequence voie 2
;R7= resultat long mot
;R8=offset actuel voie 3
;R9= increment suivant la frequence voie 3
;R10=compteur pour la boucle de remplissage
;R11=offset actuel voie 4
;R12= increment suivant la frequence voie 4
;R13= tous les volumes sur 1 long mot
;R14 = buffer dma destination



	;mov		R2,#0xEA62
	;add		R2,R2,#0x110
	;mov		R2,R2,lsl #12

	
	mov	R10,#nb_octets_par_vbl

	ldr		R14,adresse_dma1_logical

	adr		R1,LSPBank

	;adr		R2,table_valeurs_repetition_instrument_7
	;sub		R2,R2,R1
	;mov		R2,R2,lsl #12

	ldr		pc,pointeur_expanded_mixing

boucle_Paula_remplissage_DMA_416:
	ldrb	R0,[R1,R2,lsr #12]
	add		R2,R2,R3
	; mov		R4,R13,lsr #24
	; subs	R0,R0,R4
	subs	R0,R0,R13, lsr#24
	movmi	R0,#0
	mov		R7,R0,lsl #24

	ldrb	R0,[R1,R5,lsr #12]
	add		R5,R5,R6
	mov		R4,R13,lsl #8
	subs	R0,R0,R4,lsr #24
	movmi	R0,#0
	orr		R7,R7,R0,lsl #16

	ldrb	R0,[R1,R8,lsr #12]
	add		R8,R8,R9
	mov		R4,R13,lsl #16
	subs	R0,R0,R4, lsr #24
	movmi	R0,#0
	orr		R7,R7,R0,lsl #8

	ldrb	R0,[R1,R11,lsr #12]
	add		R11,R11,R12
	mov		R4,R13,lsl #24
	subs	R0,R0,R4,lsr #24
	movmi	R0,#0
	orr		R7,R7,R0

	str		R7,[R14],#4


	subs	R10,R10,#1
	bgt		boucle_Paula_remplissage_DMA_416

;---------- FIN Mixage
retour_mixage:

; verif fin de sample ?
; conserver : R2,R5,R8,R11

	adr		R10,Paula_registers_external
	mov		R14,#4095

; gestion bouclage canal A
	mov		R0,R2,asr #12			; R2 = offset actuel << 12
	ldr		R1,[R10,#0x54]			; AUD0END : end sample offset channel 0
	subs	R0,R0,R1				; R0 = offset en cours - offset de fin
	blt		pas_de_bouclage_canal_A_Paula

; R0=depassement
	ldr		R12,[R10,#0x04]			; R12 = longueur du sample en mots
	cmp		R12,#01					; repetition courte, silence
	moveq	R0,#0
	beq		OK_depassement_canal_A
	add		R12,R12,R12					; en octets	
test_depassement_canal_A:
	cmp		R0,R12
	blt		OK_depassement_canal_A
	subs	R0,R0,R12
	b		test_depassement_canal_A
OK_depassement_canal_A:	
	ldr		R3,[R10,#0x00]			; Audio channel 1 location
	add		R0,R0,R3				; offset début + dépassement
	and		R2,R2,R14
	orr		R2,R2,R0,lsl #12			; << 12
	
	ldr		R0,[R10,#0x04]			; Audio channel 1 length
	add		R0,R0,R0				; en octets = 2 x longeur en word
	add		R0,R0,R3				; offset de fin du sample = Audio channel 1 location + Audio channel 1 length
	str		R0,[R10,#0x54]			; AUD0END : end sample offset channel 1
pas_de_bouclage_canal_A_Paula:

; gestion bouclage canal B
	mov		R0,R5,asr #12
	ldr		R1,[R10,#0x64]			; AUD0END : end sample offset channel 1
	subs	R0,R0,R1				; R0 = offset en cours - offset de fin
	blt		pas_de_bouclage_canal_B_Paula

; R0=depassement
	ldr		R12,[R10,#0x18]			; R12 = longueur du sample en mots
	cmp		R12,#01					; repetition courte, silence
	moveq	R0,#0
	beq		OK_depassement_canal_B
	add		R12,R12,R12					; en octets	
test_depassement_canal_B:
	cmp		R0,R12
	blt		OK_depassement_canal_B
	subs	R0,R0,R12
	b		test_depassement_canal_B
OK_depassement_canal_B:	
	ldr		R3,[R10,#0x14]			; Audio channel 1 location
	add		R0,R0,R3				; offset début + dépassement
	and		R5,R5,R14
	orr		R5,R5,R0,lsl #12			; << 12
	
	ldr		R0,[R10,#0x18]			; Audio channel 1 length
	add		R0,R0,R0				; en octets = 2 x longeur en word
	add		R0,R0,R3				; offset de fin du sample = Audio channel 1 location + Audio channel 1 length
	str		R0,[R10,#0x64]			; AUD0END : end sample offset channel 1
pas_de_bouclage_canal_B_Paula:

; gestion bouclage canal C
	mov		R0,R8,asr #12
	ldr		R1,[R10,#0x74]			; AUD0END : end sample offset channel 0
	subs	R0,R0,R1				; R0 = offset en cours - offset de fin
	blt		pas_de_bouclage_canal_C_Paula

; R0=depassement
	ldr		R12,[R10,#0x2C]			; R12 = longueur du sample en mots
	cmp		R12,#01					; repetition courte, silence
	moveq	R0,#0
	beq		OK_depassement_canal_C
	add		R12,R12,R12					; en octets	
test_depassement_canal_C:
	cmp		R0,R12
	blt		OK_depassement_canal_C
	subs	R0,R0,R12
	b		test_depassement_canal_C
OK_depassement_canal_C:	
	ldr		R3,[R10,#0x28]			; Audio channel 2 location
	add		R0,R0,R3				; offset début + dépassement
	and		R8,R8,R14
	orr		R8,R8,R0,lsl #12			; << 12
	
	ldr		R0,[R10,#0x2C]			; Audio channel 2 length
	add		R0,R0,R0				; en octets = 2 x longeur en word
	add		R0,R0,R3				; offset de fin du sample = Audio channel 0 location + Audio channel 0 length
	str		R0,[R10,#0x74]			; AUD0END : end sample offset channel 0
pas_de_bouclage_canal_C_Paula:

; gestion bouclage canal D
	mov		R0,R11,asr #12
	ldr		R1,[R10,#0x84]			; AUD0END : end sample offset channel 3
	subs	R0,R0,R1				; R0 = offset en cours - offset de fin
	blt		pas_de_bouclage_canal_D_Paula

; R0=depassement
	ldr		R12,[R10,#0x40]			; R12 = longueur du sample en mots
	cmp		R12,#01					; repetition courte, silence
	moveq	R0,#0
	beq		OK_depassement_canal_D
	add		R12,R12,R12					; en octets	
test_depassement_canal_D:
	cmp		R0,R12
	blt		OK_depassement_canal_D
	subs	R0,R0,R12
	b		test_depassement_canal_D
OK_depassement_canal_D:	
	ldr		R3,[R10,#0x3C]			; Audio channel 3 location
	add		R0,R0,R3				; offset début + dépassement
	and		R11,R11,R14
	orr		R11,R11,R0,lsl #12			; << 12
	
	ldr		R0,[R10,#0x40]			; Audio channel 3 length
	add		R0,R0,R0				; en octets = 2 x longeur en word
	add		R0,R0,R3				; offset de fin du sample = Audio channel 0 location + Audio channel 0 length
	str		R0,[R10,#0x84]			; AUD0END : end sample offset channel 0
pas_de_bouclage_canal_D_Paula:

; stockage des registres à jour

	str		R2,[R10,#0x50]			; offset par rapport au debut des samples / canal A

	str		R5,[R10,#0x60]			; offset par rapport au debut des samples / canal B

	str		R8,[R10,#0x70]			; offset par rapport au debut des samples / canal C

	str		R11,[R10,#0x80]			; offset par rapport au debut des samples / canal D


	ldr		R15,save_R14_Paula

;-------------------------------------------------------------------------------------------------------------------------------------
; mixage voie par voie
; en entrée : R0 = numéro de la voie à mixer
;EDZ
mixage_DMA_1_voie:
	str		R14,save_R14_Paula

	ldr		R14,adresse_dma1_logical	
	add		R14,R14,R0						; position R14 = dma buffer dest + numero de canal
	adr		R4,table_increments_frequence

	adr		R1,table_volume


; registres exterieurs Paula : R0*0x14 => x20 = *x16+x4
	mov		R8,r0,lsl #2		; r8=numero de canal * 4
	mov		R9,R8,lsl #2		; R9 = R8 * 4 = R0 * 4 * 4 = R0*16
	add		R8,R8,R8,lsl #2		; R8 = R8*4+R8*16=R8*20


	adr		R0,Paula_registers_external
	add		R8,R8,R0					; R8=pointeur absolu registres externes du canal 
	add		R9,R9,R0					; R9 = 
	add		R9,R9,#0x50					; +0x50 debut registre internes

; on charge les valeurs pour le canal concerné
	ldr		R11,[R8,#0]					; location external register = offset repetition
	ldr		R5,[R8,#04]					; length external register = longeur repetition en word
	add		R5,R11,R5, lsl #1			; offset debut repetition + longueur * 2 
	mov		R11,R11,lsl #12				; << 12 pour remplacer offset en cours
	mov		R5,R5,lsl #12				; << 12 pour remplacer offset de fin en cours
	
	ldr		R2,[R9,#0x00]				; current sample ptr channel 0 / Paula_registers_internal
	ldr		R12,[R9,#0x04]				; current sample end offset
	mov		R12,R12,lsl #12				; pour pouvoir comparer à R2
	ldr		R3,[R8,#8]					; note Amiga canal A
	mov		R3,R3,lsl #2				; *4
	ldr		R3,[R4,R3]					; increment
	ldr		R4,[R8,#0x0C]				; volume canal 
	ldrb	R4,[R1,R4]					; volume corrigé en fonction du volume global
	
	
	adr		R1,LSPBank
	mov		R10,#nb_octets_par_vbl
;on garde
;-R0 = temp
;-R1 = debut des samples
;-R2 = offset actuel voie 1 					- à Sauvegarder
;-R3 = increment suivant la frequence voie 1
;-R4 = volume de la voie en cours
;-R5  = offset fin sample de la repetition << 12

;-R8 = pointeur sur la structure de registres du canal
;-R11 = offset repetition << 12
;-R12 = offset fin sample << 12					- à Sauvegarder
;-R14 = buffer dma destination

; il faut garder la virgule en cours dans R2

boucle_Paula_remplissage_DMA_1_voie:
	ldrb		R0,[R1,R2,lsr #12]		; lis octet sample source
	add			R2,R2,R3			; incremente offset sample << 12
	cmp			R2,R12				; fin du sample << 12 ?
	blt			pas_de_bouclage_mixage_1voie												; pour test
;	swi		BKP
	sub			R2,R2,R12				; R2 = depassement << 12
	add			R2,R2,R11				; R2 = depassement << 12 + offset debut repetition << 12
	mov			R12,R5					; remplacer R12 par nouvelle fin de sample R5
pas_de_bouclage_mixage_1voie:
	subs		R0,R0,R4
	movmi		R0,#0
	strb		R0,[R14],#4
	subs		R10,R10,#1
	bgt			boucle_Paula_remplissage_DMA_1_voie

; stockage de l'offset actuel R2
; il faut garder la pos des registres de la voie

	str		R2,[R9,#0x00]				; sauvegarde pointeur offset current sample
	mov		R12,R12,lsr #12
	str		R12,[R9,#0x04]				; sauvegarde fin de sample actualisé

	ldr		R15,save_R14_Paula


;-------------------------------	
swap_pointeurs_dma_son:

	ldr		R8,adresse_dma1_memc
	ldr		R9,adresse_dma2_memc
	str		R8,adresse_dma2_memc
	str		R9,adresse_dma1_memc
	
	ldr		R8,adresse_dma1_logical
	ldr		R9,adresse_dma2_logical
	str		R8,adresse_dma2_logical
	str		R9,adresse_dma1_logical

	;ldr		R8,adresse_dma2_memc_courant
	;ldr		R9,adresse_dma1_memc_courant
	;str		R8,adresse_dma1_memc_courant
	;str		R9,adresse_dma2_memc_courant

	;ldr		R8,adresse_dma1_logical_courant
	;ldr		R9,adresse_dma2_logical_courant
	;str		R8,adresse_dma2_logical_courant
	;str		R9,adresse_dma1_logical_courant

	;ldr		R8,adresse_dma1_logical_fin
	;ldr		R9,adresse_dma2_logical_fin
	;str		R8,adresse_dma2_logical_fin
	;str		R9,adresse_dma1_logical_fin


	mov		pc,lr

;-------------------------------	
set_dma_dma1:
	ldr		  R12,adresse_dma1_memc
	mov       R10,#nb_octets_par_vbl_fois_4
	ADD       R10,R10,R12         ;SendN
	SUB       R10,R10,#16         ; fixit ;-)


	MOV       R12,R12,LSR#2       ;(Sstart/16) << 2
	MOV       R10,R10,LSR#2       ;(SendN/16) << 2
	MOV       R0,#0x3600000     ;memc base
	ADD       R1,R0,#0x0080000     ;Sstart
	ADD       R2,R0,#0x00A0000     ;SendN
	ORR       R1,R1,R12           ;Sstart
	ORR       R2,R2,R10           ;SendN
	STR       R2,[R2]
	STR       R1,[R1]
	mov		pc,lr

; met dans le dma
	ldr		R12,adresse_dma1_memc
	;add		R10,R12,#416-16
	;add		R10,R12,#nb_octets_par_vbl_fois_4-16
	add		R10,R12,#nb_octets_par_vbl_fois_4


	mov		r12,r12,lsr #4
	mov		r12,r12,lsl #2
	
	mov		r10,r10,lsr #4
	mov		r10,r10,lsl #2

	MOV		R0,#0x36A0000     ; SendN
	add		R10,R10,R0
	str		R10,[R10]	


	MOV		R0,#0x3680000     ; Sstart
	add		R12,R12,R0
	str		R12,[R12]

	mov		pc,lr

remove_VBL:
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



install_vsync:
	str		lr,save_lr
	; appel XOS car si appel OS_SWI si erreur, ça sort directement
	MOV		R0,#0x0C           ;claim FIQ
	SWI		XOS_ServiceCall
	bvs		exit
	
	TEQP	PC,#0xC000001					; bit 27 & 26 = 1, bit 0=1 : IRQ Disable+FIRQ Disable+FIRQ mode ( pour récupérer et sauvegarder les registres FIRQ )
	
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
	adr		R0,VBL					;FNlong_adr("",0,notHSync)   ;set up VSync code after copying
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
wait_VBL:
	LDRB      R11,vsyncbyte   ;load our byte from FIQ address, if enabled
waitloop_vbl:
	LDRB      R12,vsyncbyte
	TEQ       R12,R11
	BEQ       waitloop_vbl
	MOVS      PC,R14

;----------------------------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------------------------
scankeyboard:
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
clearkeybuffer:		   ;10 - temp SWI, probably not needed in future once full handler done
	MOV       R12,#0
	STRB      R12,keybyte1
	STRB      R12,keybyte2
	MOV       PC,R14      ;flags not preserved


;----------------------------------------------------------------------------------------------------------------------
; routine de verif du clavier executée pendant l'interruption.  lors de la lecture de 0x04, le bit d'interruption est remis à zéro
check_keyboard:
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
save_lr:		.long		0


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
VBL:
	TST       R8,#0b00001000       ;retest R5 is it bit 3 = Vsync? (bit 6 = T1 trigger/HSync)				: R8 = 0x14 = IRQ Request A => bit 3=vsync, bit 6=Timer 1 / hsync
	STRNEB    R14,[R14,#0x58+2]    ;if VSync, reset T1 (latch should already have the vsyncvalue...)		: si vsync, alors on refait un GO = on remet le compteur (latch) pour le timer 1 à la valeur vsyncreturn ( mise dans les registres dans le start et  après la derniere ligne )
;
; that's the high-priority stuff done, now we can check keyboard too...
;
	BEQ       check_keyboard       ;check IRQ_B for SRx/STx interrupts									: R8=0 / si 0, c'est qu'on a ni bit3=vsync, ni bit 6=Timer 1, donc c'est une IRQ B = clavier/keyboard

	STRB      R8,[R14,#0x14+2]     ; ...and clear all IRQ_A interrupt triggers								: 1 = clear, donc ré-écrire la valeur de request efface/annule la requete d'interruption

; remaskage IRQ A : Timer 1 + Vsync
	MOV       R8,#0b00001000		; EDZ : Vsync only

	STRB      R8,[R14,#0x18+2]     ;set IRQA mask to %01000000 = T1 only									: mask IRQ A : bit 6 = Timer 1, plus de Vsync

; remaskage IRQ B : clavier/keyboard
	MOV       R8,#0b10000000       ;R8,#%11000000
	STRB      R8,[R14,#0x28+2]     ;set IRQB mask to %11000000 = STx or SRx									: mask IRQ B pour clavier


; vsyncbyte = 3 - vsyncbyte
; sert de flag de vsync, si modifié => vsync
	LDRB      R8,vsyncbyte
	RSB       R8,R8,#3
	STRB      R8,vsyncbyte

	adr		R8,pile_regs
	stmia	R8,{R0-R7}


	.ifeq	1
	ldr		R9,adresse_dma2_memc
	add		R8,R9,#nb_octets_par_vbl-2


	mov		r9,r9,lsr #4
	mov		r9,r9,lsl #2
	
	mov		r8,r8,lsr #4
	mov		r8,r8,lsl #2

	MOV		R10,#0x36A0000     ; SendN
	add		R8,R8,R10


	MOV		R10,#0x3680000     ; Sstart
	add		R9,R9,R10

	str		R8,[R8]	
	str		R9,[R9]


	ldr		R8,adresse_dma2_memc
	ldr		R9,adresse_dma1_memc
	str		R8,adresse_dma1_memc
	str		R9,adresse_dma2_memc

	ldr		R8,adresse_dma1_logical
	ldr		R9,adresse_dma2_logical
	str		R8,adresse_dma2_logical
	str		R9,adresse_dma1_logical





	mov   r9,#0x3400000               
	mov   r8,#777
; border	
	orr   r8,r8,#0x40000000            
	str   r8,[r9]  



; --------------------
	ldr		R2,adresse_dma1_logical
	ldr		R5,fin_sample
	ldr		R1,pointeur_lecture_sample
	mov		R0,#nb_octets_par_vbl
	mov		R4,#0b11111110
	adr		R6,lin2logtab
	mov		R7,#127
	mov		R3,#0
bouclecopie2:


	ldrb		R3,[r1],#4
	ldrb		R3,[R6,R3]
	;and			R3,R3,R4
	;subs		R3,R3,#1
	;movmi		R3,#0

	strb		R3,[R2],#1
	
	cmp		R1,R5
	;blt		.pas_fin_de_sample2
	ldrlt		R1,debut_sample

.pas_fin_de_sample2:
	subs	R0,R0,#1
	bgt		bouclecopie2
	str		R1,pointeur_lecture_sample

	.endif

	adr		R8,pile_regs
	ldmia	R8,{R0-R7}

exitVScode:
	mov   r9,#0x3400000                
	mov   r8,#000
; border	
	orr   r8,r8,#0x40000000            
	str   r8,[r9]  



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

pile_regs:
		.rept		16
		.long		0
		.endr


pointeur_fiqbase:		.long	fiqbase
fiqbase:              ;copy to &18 onwards, 57 instructions max
                      ;this pointer must be relative to module

		.incbin		"build\fiqrmi2.bin"


fiqend:




pagefindblk:
		.long      0 ;0
		.long      0 ;4
		.long      0 ;8
		.long      0 ;12

page_block:
	.long		0		; Physical page number 
	.long		0		; Logical address 
	.long		0		; Physical address 

backup_params_sons:	
	.long		0
	.long		0
	.long		0
	.long		0
	.long		0
	.long		0



Paula_registers_external:
; $dff0a0
; canal A
AUD0LCH_L:	.long		0		; 00: Audio channel 0 location				00
AUD0LEN:	.long		0		; 04: Audio channel 0 length				04
AUD0PER:	.long		0		; 06: Audio channel 0 period				08
AUD0VOL:	.long		0		; 08: Audio channel 0 volume				0C
AUD0DAT:	.long		0		; 0A: Audio channel 0 data					10
; canal B
AUD1LCH_L:	.long		0		; 10: Audio channel 1 location				14
AUD1LEN:	.long		0		; 14: Audio channel 1 length				18
AUD1PER:	.long		0		; 16: Audio channel 1 period				1C
AUD1VOL:	.long		0		; 18: Audio channel 1 volume				20
AUD1DAT:	.long		0		; 1A: Audio channel 1 data					24
; canal C
AUD2LCH_L:	.long		0		; 10: Audio channel 2 location				28
AUD2LEN:	.long		0		; 14: Audio channel 2 length				2C
AUD2PER:	.long		0		; 16: Audio channel 2 period				30
AUD2VOL:	.long		0		; 18: Audio channel 2 volume				34
AUD2DAT:	.long		0		; 1A: Audio channel 2 data					38
; canal D
AUD3LCH_L:	.long		0		; 10: Audio channel 3 location				3C
AUD3LEN:	.long		0		; 14: Audio channel 3 length				40
AUD3PER:	.long		0		; 16: Audio channel 3 period				44
AUD3VOL:	.long		0		; 18: Audio channel 3 volume				48
AUD3DAT:	.long		0		; 1A: Audio channel 3 data					4C
Paula_registers_internal:
; canal A internal
AUD0POSCUR:	.long		0		; current sample offset channel 0 << 12		50
AUD0END:	.long		0		; end sample offset channel 0				54
AUD0FIXEDP:	.long		0		; current fixed point channel 0				58
AUD0INC:	.long		0		; increment <<12 channel 0					5C
; canal B internal
AUD1POSCUR:	.long		0		; current sample offset channel 1 << 12		60
AUD1END:	.long		0		; end sample offset channel 1				64
AUD1FIXEDP:	.long		0		; current fixed point channel 1				68
AUD1INC:	.long		0		; increment <<12 channel 1					6C
; canal C internal
AUD2POSCUR:	.long		0		; current sample offset channel 2 << 12		70
AUD2END:	.long		0		; end sample offset channel 2				74
AUD2FIXEDP:	.long		0		; current fixed point channel 2				78
AUD2INC:	.long		0		; increment <<12 channel 2					7C
; canal D internal
AUD3POSCUR:	.long		0		; current sample offset channel 3 << 12		80
AUD3END:	.long		0		; end sample offset channel 3				84
AUD3FIXEDP:	.long		0		; current fixed point channel 3				88
AUD3INC:	.long		0		; increment <<12 channel 3					8C

DMACon:		.long		0		; DMA Control bits 03-00					90

DMAcon_Temp:	.long	0		; valeur DMACon temporaire avant traitement

table_volume:
	.byte		0xFE,0xB6,0x9A,0x8A,   0x7C,0x74,0x6C,0x64
	.byte		0x5C,0x58,0x54,0x50,   0x4C,0x48,0x44,0x40
	.byte		0x3C,0x3A,0x38,0x36,   0x34,0x32,0x30,0x2E
	.byte		0x2C,0x2A,0x28,0x26,   0x24,0x22,0x20,0x1E
	.byte		0x1C,0x1C,0x1A,0x1A,   0x18,0x18,0x16,0x16
	.byte		0x14,0x14,0x12,0x12,   0x10,0x10,0x0E,0x0E
	.byte		0x0C,0x0C,0x0A,0x0A,   0x08,0x08,0x06,0x06
	.byte		0x04,0x04,0x02,0x02,   0x00,0x00,0x00,0x00
	.byte		0x00,0x00,0x00,0x00,   0x00,0x00,0x00,0x00
	.p2align	4


lin2logtab:		.skip		256


table_increments_frequence:
	.if frequence_replay = 20833
	.include	"table_frequences_20833.s"
	.endif
	.if frequence_replay = 31250
	.include	"table_frequences_31250.s"
	.endif

expanded_filling_routine:
	.rept		nb_octets_par_vbl
	ldrb	R0,[R1,R2,lsr #12]
	add		R2,R2,R3
	;mov		R4,R13,lsr #24
	;subs	R0,R0,R4
	subs	R0,R0,R13, lsr#24
	movmi	R0,#0
	mov		R7,R0,lsl #24

	ldrb	R0,[R1,R5,lsr #12]
	add		R5,R5,R6
	mov		R4,R13,lsl #8
	subs	R0,R0,R4,lsr #24
	movmi	R0,#0
	orr		R7,R7,R0,lsl #16

	ldrb	R0,[R1,R8,lsr #12]
	add		R8,R8,R9
	mov		R4,R13,lsl #16
	subs	R0,R0,R4, lsr #24
	movmi	R0,#0
	orr		R7,R7,R0,lsl #8

	ldrb	R0,[R1,R11,lsr #12]
	add		R11,R11,R12
	mov		R4,R13,lsl #24
	subs	R0,R0,R4,lsr #24
	movmi	R0,#0
	orr		R7,R7,R0

	str		R7,[R14],#4		
	.endr
	ldr		pc,pointeur_retour_mixage

pointeur_retour_mixage:		.long		retour_mixage


LSPMusic:
	.incbin		"knullakuk.lsmusic"
	.p2align	2

LSPBank:
	.incbin		"knullakuk.lsbank"
LSPBank_end:
	.skip		ecart_sample*31				; espace pour bouclage des 31 samples
silence:
	.long		0,0,0,0
fin_silence:
	.rept		1000
		.long		0
	.endr
	.p2align	2
	.ifeq		1
table_valeurs_repetition_instrument_7:
.rept		4
.byte	0xBE,0xBE,0xBE,0xBE,0xBE,0xBE,0xBE,0xBE
.byte	0xBE,0xBE,0x5C,0x2F,0x5D,0x77,0x8B,0x91
.byte	0x91,0x91,0xAB,0xB3,0xB7,0xBD,0xBF,0xBF
.byte	0xBF,0xBF,0xBF,0xBF,0x8F,0x2E,0x2E,0xA5
.byte	0xBF,0xBF,0xBF,0xBF,0xBF,0xBF,0xAF,0x69
.byte	0x2E,0x60,0x76,0x88,0x94,0x9C,0xA6,0xAC
.byte	0xB0,0xB6,0xBA,0xBA,0x90,0x99,0x9B,0x9D
.byte	0xA1,0xA3,0xA1,0xB8,0xBC,0xBE,0xBC,0x7D
.byte	0x9D,0xA3,0xA7,0xAD,0xAD,0x98,0xB4,0xB6
.byte	0xB6,0xBA,0xBA,0xB6,0x37,0xA3,0xA7,0xA9
.byte	0xAD,0xB1,0xB5,0xB7,0xBB,0xBD,0xBF,0xBF
.byte	0xBF,0xB1,0x2F,0x92,0x96,0x9A,0x3E,0xBD
.byte	0xBD,0xBF,0xBF,0xBF,0xBF,0xB5,0x98,0xA0
.byte	0xA8,0xA2,0xB3,0xB3,0xB3,0xB5,0xB5,0xAD
.byte	0xA8,0xB4,0xB6,0xBA,0xBE,0xB4,0x59,0x95
.byte	0x99,0x99,0x91,0xA6,0xBE,0xBE,0xBE,0xBE
.endr
.endif


moduleAmiga:
	;.incbin		"MOD.knulla-kuk !!!.mod"

	.ifeq 1
; transformation du module pour ne pas gérer les boucles 
; ls player pour génerer les effets
; émulateur Paula de mixage
;
; 416 octets / voie / VBL = 20.833kHz.
;
; Frequence QTM = 48 uS
; 48*4 = 192
; 48*8 = 384
; 

;-----------------------------
; table de frequences : 
	; - european PAL Amiga clock rate of 7.093789 MHz
	; - de valeur de note protracker à frequence Amiga. : https://github.com/8bitbubsy/pt23f/blob/main/replayer/PT2.3F_replay_cia.s
	; - de fréquence Amiga à incréments calculs. : on divise la note Amiga par (3579546(paula) * 65536(precision)) / 25033(frequence de replay - MIXERFRQ)
	; - de note protracker à incréments calculs 

;-----------------------------
; table de volume
; dans QTM à volumetable : ;un-scaled volume table
; source creation en bas de page
; 

;-----------------------------
; samples Amiga signés 8 bits
; samples Archimedes 
; log / lineaire ?
;
; "its sample data is converted into 8-bit logarithmic data, from signed linear data."
; dans new5, ligne 2590 :
;	- preparation des repetitions ?
;	- conversion des samples ?
;
; creation de la table de conversion :

; 	adr 	R11,linlogtab
; 	MOV     R1,#255
; setlinlogtab:

;	MOV     R0,R1,LSL#24		; R0=R1<<24 : en entrée du 8 bits donc shifté en haut, sur du 32 bits
;	SWI     "XSound_SoundLog"	; This SWI is used to convert a signed linear sample to the 8 bit logarithmic format that’s used by the 8 bit sound system. The returned value will be scaled by the current volume (as set by Sound_Volume).
;	STRB    R0,[R11,R1]			; 8 bit mu-law logarithmic sample 
;	SUBS    R1,R1,#1
;	BGE     setlinlogtab
;
;	conversion de chaque octet à partir de linlogtable ( linéaire à log) ou de loglintab ( log à linéaire) suivant le sens de la conversion :

;
; pour le mixage :
;	4 registres pour source du sample
;	4 registres pour incréments suivant fréquence/note
;	4 registres pour position
;	1 seul registre pour 4 registres de volume => subs du volume sur l'octet de sample, 4 voies mais 32 bits, donc 4 volumes dans 1 seul registre avec rotation des bits
;	1 registre de destination
;	1 registre de travail
; 14

; pour le volume
; on lit un octet de sample
; on a un pointeur sur une table de volume pour chaque voie
; on lit l'octet à table_volume de la voie + sample
; 
; voie 1 : R1,R2,R3,R4
;
; R0=sample, R1=adresse sample voie 1, R2=position actuelle sample voie 1
	ldrb	R0,[R1,R2, ASR#12]
; R3=increment x 2^12
	add		R2,R2,R3
; R4=volume, 0 = plein volume
	subs	R0,R0,R4
; si volume négatif => 0
	movmi	R0,#0
; R14=buffer canaux mélangés
	strb	R0,[R14],#1	
	

; range frequences :
; ST : de $71 à $d60 / 113 à 3424
; QTm : de 1 à 1024
; table des notes : 28 à 1712
;---------------------------------
; increment frequence
; valeur ST:
; 9371195 = (3579546(paula) * 65536(precision)) / 25033(frequence de mixage)
; 9371195

; version ST CNX
; frq=(1/(2.79365*10^-7))/freq
; valeur finale increment = ( frq/i ) * (2^12)   / i= note amiga

;valeur archi = (Amiga_multiplier / note amiga ) * actual_uS
; 

;Amiga_multiplier = ((7093789.2/2*1024)/1E6)*2^20 = 0xE3005235
;amiga = 28.86 khz
;AUDxPER = 3579546 / samples per seconds
;uSec = .279365 * Period * Length
;
; pour 416 octets:
; frequence Amiga = 3579546.4715
; frequence Archi = 20833.33333
; frq Amiga / Frq Archi = 171.81823066
; par exemple pour note = $BF = 191 => 3684,6464544363141



;frequence réelle = 

;frequency register : de 3 a 256 en microsecond ( 1000= 1 nanosecond / 1 000 000 = 1 second. par exemple pour 3 => 333 333 fois par seconde
;valeur registre frequence = 48 par voie


;buffer dma en 0x7E000 et 0x7F000
; set the sound dma registers





MOV       R12,R12,LSR#2       ;(Sstart/16) << 2
MOV       R10,R10,LSR#2       ;(SendN/16) << 2
MOV          R0,#0x3600000     ;memc base
ADD       R1,R0,#0x0080000     ;Sstart
ADD       R2,R0,#0x00A0000     ;SendN
ORR       R1,R1,R12           ;Sstart
ORR       R2,R2,R10           ;SendN
STR       R2,[R2]
STR       R1,[R1]


on divise la note par (3579546(paula) * 65536(precision)) / 25033(frequence de replay - MIXERFRQ)

FC = de $71 à $6b0
MOD = de 113 ($71) à 907 

PERMIN		=	$71 = 113 = plus basse frequence Amiga
PERMAX		=	$d60 = 3424 =plus haute frequence Amiga
frequenceBuild:	

		lea	frequenceTable(pc),a0
		moveq	#PERMIN-1,d0
.clear:		
		clr.l	(a0)+
		dbf	d0,.clear
		move.w	#PERMIN,d0
		move.w	#PERMAX-PERMIN-1,d1
		move.l	#9371195,d2	; (3579546(paula) * 65536(precision)) / 25033(frequence de replay - MIXERFRQ)
		move.b	iHwConfig(pc),d5
		beq.s	.ok25
		lsr.l	#1,d2			; 50khz => /2
.ok25:
		move.l	d2,d5			; D5 = frequence calculée
		clr.w	d5				; partie entiere uniquement, virgule=0
		swap	d5				; d5.w = 
.compute:
		move.l	d5,d3			; 
		divu	d0,d3			; d3 = d3/d0 = reste 16 bits,resultat 16 bits
		move.w	d3,d4			; resultat de la division, partie entiere
		cmpi.w	#2,d4			; partie entiere >= 2 ?
		bge.s	.clamp
		swap	d4				; partie entiere en haut de d4
		move.w	d2,d3			; partie virgule de la frequence calculée + reste en word haut 
		divu	d0,d3			; d3 = d3/d0 = reste 16 bits,resultat 16 bits
		move.w	d3,d4			; d3 = résultat virgule

		move.l	d4,(a0)+		; d4=increment : entier 16bits, virgule 16bits
.backClamp:
		addq.w	#1,d0			; d0 : note=note+1
		dbf	d1,.compute
		rts
.clamp:	; NOTE: Only two notes are high on STF (high part more = 2)
		move.l	#$0001FFFF,(a0)+	; on met 1,9999999 comme incrément
		bra.s	.backClamp
		
		
;---------------------------------------------
creation tables conversion mu law sur ARchie:
utilisé dans la routine convsamps

 2591 STMFD   R13!,{R0-R6,R11-R12,R14}

 2592 FNlong_adr("  ",11,linlogtab)

 2593 MOV     R1,#255

 2594 .setlinlogtab

 2595 MOV     R0,R1,LSL#24

 2596 SWI     "XSound_SoundLog"

 2597 STRB    R0,[R11,R1]

 2598 SUBS    R1,R1,#1

 2599 BGE     setlinlogtab

 2600 :

 2601 MOV     R1,#64                  ;..consider reducing to 32 or 48 for RO3.5+

 2602 STRB    R1,[R12,#musicvolume]   ;..to allow TSS to play system sounds through louder?

 2603 STRB    R1,[R12,#samplevolume]

 2604 ADD     R2,R12,#(volumetable-song_data)

 2605 ADD     R3,R2,#(musicvoltable-volumetable)

 2606 ADD     R4,R2,#(samplevoltable-volumetable) AND &ff00

 2607 ADD     R4,R4,#(samplevoltable-volumetable) AND &00ff

 2608 .setvoltabs

 2609 MOV     R0,R1,LSL#(24+1)					; R0 = volume en cours << 25 ( 7 bits pour la valeur 64 + 25 bits de precision)

 2610 SWI     "XSound_SoundLog"					; R0 => 8-bit signed volume-scaled logarithm

 2611 RSB     R0,R0,#255						; R0 = 255 - R0

 2612 AND     R0,R0,#%11111110                ;stops odd/even changes (ie. +/- sample changes)

 2613 STRB    R0,[R2,R1]						; volumetable

 2614 STRB    R0,[R3,R1]						; musicvoltable

 2615 STRB    R0,[R4,R1]                      ;set all volume tables (unscaled, music and sample)  : samplevoltable

 2616 SUBS    R1,R1,#1

 2617 BGE     setvoltabs
 
 
; ----------------------------------------------
; registres PAULA
	; Custom chip AMIGA:
	;	$dff0a0.L : Sample start adress
	;	$dff0a4.W : Sample length (in words)
	;	$dff0a6.W : Channel period.
	;	$dff0a8.W : Channel Volume.

; registre en interne
;		ds.l	1   ; current sample ptr : pointeur actuel sur le sample
;		ds.l	1	; end sample ptr     : pointeur fin de sample
;		ds.w	1	; fixed point        : partie à virgule stockée pour le calcul
 
 


	.endif
	
	
	
	
		.ifeq		1

; check du bouclage des 4 voies
	ldr		R1,debut_sample
	ldr		R2,fin_sample
	subs	R1,R2,R1			; R1 = taille du sample



	adr		R10,Paula_registers_external
	
	ldr		R2,[R10,#0x50]			; offset << 12
	subs	R0,R1,R2, asr #12		; R0 = taille du sample - offset >> 12
	bgt		.pas_boucle_canal_A
	; R0 est positif, offset actuel
	subs	R0,R2,R1,asl #12		; offset - taille de sample << 12 = depassement avec la virgule
	str		R0,[R10,#0x50]
.pas_boucle_canal_A:

	ldr		R2,[R10,#0x60]			; offset << 12
	subs	R0,R1,R2, asr #12		; R0 = taille du sample - offset >> 12
	bgt		.pas_boucle_canal_B
	; R0 est positif, offset actuel
	subs	R0,R2,R1,asl #12		; offset - taille de sample << 12 = depassement avec la virgule
	str		R0,[R10,#0x60]
.pas_boucle_canal_B:

	ldr		R2,[R10,#0x70]			; offset << 12
	subs	R0,R1,R2, asr #12		; R0 = taille du sample - offset >> 12
	bgt		.pas_boucle_canal_C
	; R0 est positif, offset actuel
	subs	R0,R2,R1,asl #12		; offset - taille de sample << 12 = depassement avec la virgule
	str		R0,[R10,#0x70]
.pas_boucle_canal_C:

	ldr		R2,[R10,#0x80]			; offset << 12
	subs	R0,R1,R2, asr #12		; R0 = taille du sample - offset >> 12
	bgt		.pas_boucle_canal_D
	; R0 est positif, offset actuel
	subs	R0,R2,R1,asl #12		; offset - taille de sample << 12 = depassement avec la virgule
	str		R0,[R10,#0x80]
.pas_boucle_canal_D:

	.endif
	
	
	
; sample en 8 bits signés : The samples in a MOD file are raw, 8 bit, signed, headerless, linear digital data.
; donc de -128 à 127
; Signed : OK
; 
; écriture directe : MEMC CONTROL REGISTER
; 110110111000001001000011 , problème vitesse mémoire en dur