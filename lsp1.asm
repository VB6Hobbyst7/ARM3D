; OK : - demarrer sur un petit buffer vide : en fait ecrire dans sptr : 0x36C0000
; OK - remplir chaque VBL N samples
; OK - remplir chaque VBL N samples à une autre fréquence : 416 octets / 48 / 20833.333 hz.
; - remplir en gérant un volume : table volume : samplevoltable , dans currentvol & DMA_volume
; samplevoltable : 64 entrées. 
; volume : attention SUBS SSSSSS


; sample en 8 bits signés : The samples in a MOD file are raw, 8 bit, signed, headerless, linear digital data.
; donc de -128 à 127
; Signed : OK
; 


; 416 sample / VBL = 20 800 HZ
; Sound Frequency Register (SFR}: Address C0H : micro seconde, de 3 à 256 :  1 s = 1 000 000 µs, /50 ( 1 VBL) = 20 000. 256=>78 valeurs. 416=>48

; frequence ?
; volume ?
; activation registre de controle

; écriture directe : MEMC CONTROL REGISTER
; 110110111000001001000011 , problème vitesse mémoire en dur



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

; init jeu fireball 2
;
;   250 SYS "Sound_InstallVoice",code,0									 add a Voice Generator to the table of available voices.
;	260 SYS "Sound_AttachVoice",1,0										 mute voice 1
; 270 VOICE 1,"TrackerVox"
; 280 VOICE 2,"TrackerVox"
;  290 VOICE 3,"TrackerVox"
;  300 VOICE 4,"TrackerVox"
; OSCLI"Stereo "+
;  330 ourinfo=code+&A4+32*V%
;  340 ourinfo!0 =0
;  350 ourinfo!4 =samples
;  360 ourinfo!8 =0
;  370 ourinfo!12=0
;  380 ourinfo!16=0
;  390 SOUND V%+1,&17E,1,255
;  450 SYS "Sound_Configure",0,0,0,0,0 TO p0%,p1%,p2%,p3%,p4%				backup les valeur d'origine
;  460 SYS "Sound_Configure",4,208,34,p3%,p4%
;  R%=code+&154:SYS "OS_Claim",&10,R%,0
;  *FX14,4 = 																enable event, VSync Event

; frequence OK
; 7812,499999	156		128
; 9615,384614	192		104
; 10416,66667	208		96,00000001
; 12820,51282	256		78,00000001
; 15625			312		64,00000001
; 19230,76923	384		52,00000001
; 20833,33333	416		48
; 25641,02564	512		39
; 31250			624		32
; 38461,53846	768		26
; 41666,66666	832		24
; 62499,99999	1248	16
; 76923,07692	1536	13



	.org 0x8000
	.balign 8

.equ	buffer_dma1,		0x50000
.equ	buffer_dma2,		0x7F000

.include "swis.h.asm"

; remplir les 2 buffers
; jouer un son DMA
; jouer les 2 buffers


main:

	SWI		0x01
	.byte	"24KHZ signed sample played at 22Khz with volume control - No OS running.",0
	.p2align 2

; set sound volume
	mov		R0,#127							; maxi 127
	SWI		0x40180	

; read sound volume
	mov		R0,#0							; 0=read = OK 127
	SWI		0x40180

	;bl		unisgn_sample
	bl		create_table_lin2log_edz

;--------
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
	SWI       0x40140					; Sound_Configure
	
	;R0=4
	;R1=0x1A0			 	Samples per channel=416 
	;R2=0x30				Sample period
	;R3=
	;R4=

	.endif
;--------


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
	SWI		OS_ChangeDynamicArea
	
; taille dynamic area screen = 320*256*2

	MOV		r0, #DynArea_Screen
	SWI		OS_ReadDynamicArea
	
	; r0 = pointeur memoire ecrans
	ldr		R10,taille_actuelle_memoire_ecran
	add		R0,R0,R10		; au bout de la mémoire video, le buffer dma
	str		R0,adresse_dma1_logical
	add		R1,R0,#2048
	str		R1,adresse_dma2_logical	
	

	
	
	
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



	
;--------	
	.ifeq		1
	; relecture pour checker adresse physique
	mov		R12,R0			; R12=pointeur memoire adresse ecrans
	mov		R0,#0
	mov		R2,#0b1000000000		; Logical address provided 
	orr		R0,R0,R2			; Logical address provided 
	adr		R1,page_block
	
	str		R12,[R1,#4]			; logical address
	swi		0x68				; OS_Memory 0
	.endif
;--------


	MOV       R0,#0							;  	Channels for 8 bit sound
	MOV       R1,#0						; Samples per channel (in bytes)
	MOV       R2,#0						; Sample period (in microseconds per channel) 
	MOV       R3,#0
	MOV       R4,#0
	SWI       0x40140						;"Sound_Configure"
	
	adr		R5,backup_params_sons
	stmia	R5,{r0-R4}



	MOV       R0,#1							;  	Channels for 8 bit sound
	MOV       R1,#416						; Samples per channel (in bytes)
	MOV       R2,#48							; Sample period (in microseconds per channel)  = 48  / 125 pour 8000hz
	MOV       R3,#0
	MOV       R4,#0
	SWI       0x40140						;"Sound_Configure"

	
;	swi Sound_SampleRate  ?

; remplit les 2 dmas
	bl		copie_sample_416_dans_dma1

	SWI		22
	MOVNV R0,R0
	bl		set_dma_dma1
	teqp  r15,#0                     
	mov   r0,r0	
	
	bl		swap_pointeurs_dma_son

	bl		copie_sample_416_dans_dma1

	SWI		22
	MOVNV R0,R0
	bl		set_dma_dma1
	teqp  r15,#0                     
	mov   r0,r0	
	
	bl		swap_pointeurs_dma_son

	

; sound volume
	mov		R0,#127							; maxi 127
	SWI		0x40180		







	SWI		22
	MOVNV R0,R0      

; clear all the internal timing signals
;sound frequency register ? 0xC0 / VIDC
	mov		R0,#0x30-1
	; mov		R0,#125-1				pour 8000 hz
	mov		r1,#0x3400000               
; sound frequency VIDC
	mov		R2,#0xC0000000
	orr   r0,r0,R2
	str   r0,[r1]  


	.ifeq	0
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

; met dans le dma
	ldr		R12,adresse_dma1_memc
	add		R10,R12,#416-16


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


; write sptr pour reset DMA
	mov		R12,#0x36C0000
	str		R12,[R12]

	teqp  r15,#0                     
	mov   r0,r0
	
;	mov		R0,#02								; Enable sound output 
;	SWI		0x40141								; Sound_Enable	


	SWI		22
	MOVNV R0,R0 

	bl		install_vsync

	SWI		22
	MOVNV R0,R0            

	.ifeq	0
; change bien la frequence
;sound frequency register ? 0xC0 / VIDC
	mov		R0,#0x30-1
	mov		r1,#0x3400000               
; sound frequency VIDC
	mov		R2,#0xC0000100
	orr   r0,r0,R2
	str   r0,[r1]  
	.endif


	.ifeq		0

; met dans le dma - petit buffer
	ldr		R12,adresse_dma1_memc
	add		R10,R12,#64-16


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
	
	
; met dans le dma
	ldr		R12,adresse_dma1_memc
	add		R10,R12,#416-16


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




	.endif

; stereo : 60,64,68,6C,70,74,78,7C
	mov		R0,#4						; 0
	mov		r1,#0x3400000               
	orr		r0,r0,#0x60000000            
	str		r0,[r1]  

	mov		R0,#4						; 1
	mov		r1,#0x3400000               
	orr		r0,r0,#0x64000000           
	str		r0,[r1]  
	
	mov		R0,#4						; 2
	mov		r1,#0x3400000               
	orr		r0,r0,#0x68000000            
	str		r0,[r1]  

	mov		R0,#4						; 3
	mov		r1,#0x3400000               
	orr		r0,r0,#0x6C000000            
	str		r0,[r1] 

	mov		R0,#4						; 4
	mov		r1,#0x3400000               
	orr		r0,r0,#0x70000000            
	str		r0,[r1] 

	mov		R0,#4						; 5
	mov		r1,#0x3400000               
	orr		r0,r0,#0x74000000            
	str		r0,[r1] 

	mov		R0,#4						; 6
	mov		r1,#0x3400000               
	orr		r0,r0,#0x78000000            
	str		r0,[r1] 

	mov		R0,#4						; 7
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
	bl		copie_sample_416_dans_dma1

	SWI		22
	MOVNV R0,R0
	bl		set_dma_dma1
	teqp  r15,#0                     
	mov   r0,r0	
	
	bl		swap_pointeurs_dma_son


	bl		wait_VBL


	bl      scankeyboard
; &keypad + = 4B
; keypad - = 3A
	cmp		R0,#0x01		; F1 ?
	bne		test_touche_plus
; touche -
	ldr		R1,volume_actuel
	subs	R1,R1,#1
	movmi	R1,#0
	str		R1,volume_actuel
	bl		clearkeybuffer
	b   	boucle

test_touche_plus:
	cmp		R0,#0x02		; F2 ?
	bne		test_touche_space
; touche +
	ldr		R1,volume_actuel
	adds	R1,R1,#1
	cmp		R1,#64
	movge	R1,#64
	str		R1,volume_actuel
	bl		clearkeybuffer
	b   	boucle

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

	SWI       0x40140						;"Sound_Configure"
	
	mov		R0,#01								; Disable sound output 
	SWI		0x40141								; Sound_Enable


	MOV r0,#22	;Set MODE
	SWI OS_WriteC
	MOV r0,#12
	SWI OS_WriteC
	
; sortie
	MOV R0,#0
	SWI OS_Exit

;--------------------------------------------------------------------------------------------


unisgn_sample:
	ldr		R11,debut_sample
	ldr		R12,fin_sample
	
boucle_unsign_sample:
	ldrb	R0,[R11]
	adds	R0,R0,#128
	strb	R0,[R11],#1
	
	cmp		R11,R12
	blt		boucle_unsign_sample
	
	mov		pc,lr


	

create_table_lin2log_edz:
	adr		R11,lin2logtab
	mov		R1,#0
	mov		R2,#256

boucle_table_lin2log_edz:
	mov		R0,R1,ASL #24			; de signed 8 bits à signed 32 bits
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
	and		R0,R0,#0b11111110
	STRB    R0,[R11,R1]			; 8 bit mu-law logarithmic sample 
	SUBS    R1,R1,#1
	BGE     setlinlogtab
	mov		pc,lr

;----------------------
;
; copie sample
;
;----------------------
copie_sample:

	ldr		R2,adresse_dma1_logical
	ldr		R5,fin_sample
	ldr		R1,pointeur_lecture_sample
	mov		R0,#416
	;mov		R4,#0b11111110
	adr		R6,lin2logtab
bouclecopie:
	mov		R3,#0

	ldr			R3,[r1],#4
	ldrb		R3,[R6,R3]
	;and		R3,R3,R4
	subs		R3,R3,#200
	movmi		R3,#0

	strb		R3,[R2],#1
	
	cmp		R1,R5
	blt		.pas_fin_de_sample
	ldr		R1,debut_sample

.pas_fin_de_sample:
	subs	R0,R0,#1
	bgt		bouclecopie
	str		R1,pointeur_lecture_sample
	mov		pc,lr




copie_sample_64000:
	ldr		R2,adresse_dma1_logical
	ldr		R1,debut_sample
	mov		R0,#128000
	adr		R6,lin2logtab
	mov		R4,#0b11111110
	
boucle_copie_sample_64000:
	mov		R3,#0
	ldrb	R3,[r1],#1
	;subs	R3,R3,#128
	ldrb	R3,[R6,R3]
	;and		R3,R3,R4
	strb	R3,[R2],#1
	
	subs	R0,R0,#1
	bgt		boucle_copie_sample_64000
	mov		pc,lr


increment_frequence:		.long	1207959
mask_bits_virgule_frequence:	.long	0b11111111111111111111
;-------------------------------
; copie avec calcul d'avancée en fonction de la frequence
; sample = 8000
; réel = 20833,3333
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


	ldrb	R0,[R1,R2,asr #12]
	add		R2,R2,R3
	mov		R4,R13,asr #24
	subs	R0,R0,R4
	movmi	R0,#0
	mov		R7,R0,lsl #24

	ldrb	R0,[R1,R5,asr #12]
	add		R5,R5,R6
	mov		R4,R13,asr #16
	and		R4,R4,#0xFF
	subs	R0,R0,R4
	movmi	R0,#0
	orr		R7,R0,R0,lsl #16

	ldrb	R0,[R1,R8,asr #12]
	add		R8,R8,R9
	mov		R4,R13,asr #8
	and		R4,R4,#0xFF
	subs	R0,R0,R4
	movmi	R0,#0
	orr		R7,R0,R0,lsl #8

	ldrb	R0,[R1,R11,asr #12]
	add		R11,R11,R12
	mov		R4,R13
	and		R4,R4,#0xFF
	subs	R0,R0,R4
	movmi	R0,#0
	orr		R7,R0,R0

	str		R7,[R14],#4







copie_sample_416_dans_dma1:
	ldr		R7,volume_actuel
	adr		R1,table_volume
	ldrb	R7,[R1,R7]					; R7=volume

	ldr		R2,adresse_dma1_logical
	ldr		R1,pointeur_lecture_sample
	ldr		R4,fin_sample
	mov		R0,#416
	adr		R12,lin2logtab
	


; R5 = increment
	;mov		R5,#1572				; (8000 / 20833,3333) * 4096 : 12 bits
	ldr		R5,increment_frequence					; (8000 / 20833,3333) * 1 048 576 : 20 bits
; R6 = index actuel
	ldr		R6,virgule_lecture_sample
	
boucle_copie_sample_416:
	ldrb	R3,[r1,R6,ASR#20]
; index + increment * 4096
	add		R6,R6,R5
	
	ldrb	R3,[R12,R3]
	subs	R3,R3,R7			; - volume
	movmi	R3,#0				; si <0 =>0
	
	strb	R3,[R2],#1
	
	subs	R0,R0,#1
	bgt		boucle_copie_sample_416

; on avance la position dans le sample
	ldr		R8,mask_bits_virgule_frequence
	and		R7,R6,R8			; on garde la virgule
	mov		R6,R6, ASR #20		; partie entiere
	add		R1,R1,R6

	cmp		R1,R4
	blt		.pas_fin_sample_416
	ldr		R1,debut_sample
	mov		R7,#0

.pas_fin_sample_416:

	str		R7,virgule_lecture_sample
	str		R1,pointeur_lecture_sample
	mov		pc,lr
	
;-------------------------------	
copie_sample_416_dans_dma1_simple:
	ldr		R2,adresse_dma1_logical
	ldr		R1,pointeur_lecture_sample
	ldr		R4,fin_sample
	mov		R0,#416
	adr		R6,lin2logtab

	
boucle_copie_sample_416_simple:
	ldrb	R3,[r1],#1
	cmp		R1,R4
	blt		.pas_fin_sample_416_simple
	ldr		R1,debut_sample

.pas_fin_sample_416_simple:
	ldrb	R3,[R6,R3]
	strb	R3,[R2],#1
	
	subs	R0,R0,#1
	bgt		boucle_copie_sample_416_simple
	str		R1,pointeur_lecture_sample
	mov		pc,lr
	

;-------------------------------	
swap_pointeurs_dma_son:
	ldr		R8,adresse_dma2_memc
	ldr		R9,adresse_dma1_memc
	str		R8,adresse_dma1_memc
	str		R9,adresse_dma2_memc

	ldr		R8,adresse_dma1_logical
	ldr		R9,adresse_dma2_logical
	str		R8,adresse_dma2_logical
	str		R9,adresse_dma1_logical
	mov		pc,lr

;-------------------------------	
set_dma_dma1:
; met dans le dma
	ldr		R12,adresse_dma1_memc
	add		R10,R12,#416-16


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
	add		R8,R9,#416-2


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
	mov		R0,#416
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

memc_control_register_original:			.long	0

taille_actuelle_memoire_ecran:			.long		0
adresse_dma1_logical:		.long		0
adresse_dma1_memc:		.long		0
adresse_dma2_logical:		.long		0
adresse_dma2_memc:		.long		0

pagesize:		.long	0
numpages:		.long	0

physicaldma1:	.long	0
physicaldma2:	.long	0

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

debut_sample:				.long	sample
fin_sample:					.long	sample_end
pointeur_lecture_sample:	.long	sample
virgule_lecture_sample:				.long	0

volume_actuel:		.long		32

table_volume:
	.byte		0xFE,0xB6,0x9A,0x8A,   0x7C,0x74,0x6C,0x64
	.byte		0x5C,0x58,0x54,0x50,   0x4C,0x48,0x44,0x40
	.byte		0x3C,0x3A,0x38,0x36,   0x34,0x32,0x30,0x2E
	.byte		0x2C,0x2A,0x28,0x26,   0x24,0x22,0x20,0x1E
	.byte		0x1C,0x1C,0x1A,0x1A,   0x18,0x18,0x16,0x16
	.byte		0x14,0x14,0x12,0x12,   0x10,0x10,0x0E,0x0E
	.byte		0x0C,0x0C,0x0A,0x0A,   0x08,0x08,0x06,0x06
	.byte		0x04,0x04,0x02,0x02,   0x00,0x00,0x00,0x00
	

	.p2align	4
lin2logtab:		.skip		256

pointeur_module_Amiga:		.long	moduleAmiga

sample:
	.incbin		"24khz_s.pcm"
sample_end:


moduleAmiga:
;	.incbin		"MOD.hardwired intro.mod"

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
	




;

;valeur archi = (Amiga_multiplier / note amiga ) * actual_uS

;Amiga_multiplier = ((7093789.2/2*1024)/1E6)*2^20 = 0xE3005235
;amiga = 28.86 khz
;AUDxPER = 3579546 / samples per seconds
;uSec = .279365 * Period * Length



;frequence réelle = 

;frequency register : de 3 a 256 en microsecond ( 1000= 1 nanosecond / 1 000 000 = 1 second. par exemple pour 3 => 333 333 fois par seconde
;valeur registre frequence = 42 ?


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
creation tables volumes sur ARchie:

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