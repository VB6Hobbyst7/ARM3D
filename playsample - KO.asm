; faire un dma de la taille du sample : 75851 => 83200
; copier le sample dans le dma
; jouer le dma à 8000HZ : us = 125
; copier le sample chaque vbl : 160 octets
; jouer le sample à 20833 hz
; copier le sample chaque vbl : 416 octets




; inclure lsbanks knullakuk
; pointer sur un sample manuellement : instrument 0
; len=$2310, repeat pos=$21e2, repeat len = $12C
; OK : mettre un buffer DMA de 16Ko
; OK : copier le sample dans buffer dma: testé avec convertion mu law
; OK : parametrer xsound
; OK : mettre pointeurs dma
; OK : activer le son avec registre de controle
; le son du sample est OK

; remplir chaque vbl N octets
; boucler au début du sample
; swapper les buffers

; pour tester le swap dma:
; remplir les 2 zones dmas avec tout le sample
; faire avancer le pointeur de dma a chaque vbl sans swap
; remettre du swap


.equ		longueur_du_sample,				0x2310
.equ		ms_freq_Archi,					48
.equ		nb_octets_par_vbl,				416

	.org 0x8000

.include "swis.h.asm"

	; read memc control register
	mov		R0,#0
	mov		R1,#0
	swi		0x1A
	str		R0,memc_control_register_original

; set sound volume
	mov		R0,#80							; maxi 127
	SWI		0x40180	

; read sound volume
	mov		R0,#0							; 0=read = OK 127
	SWI		0x40180	
	
	bl		create_table_lin2log
	
	bl		convertion_samples_instruments_en_mu_law
	
	
 ; Set screen size for number of buffers
	MOV 	r0, #DynArea_Screen
	SWI 	OS_ReadDynamicArea
	; r1=taille actuelle de la memoire ecran
	str		R1,taille_actuelle_memoire_ecran
	MOV r0, #DynArea_Screen
; 416 * ( 32+258+32+258+32)
	MOV		r1, #4096				; 4Ko octets de plus pour le dma audio
	mov		R1,#16384*4				; evitons QDebug
	SWI		OS_ChangeDynamicArea
	
; taille dynamic area screen = 320*256*2

	MOV		r0, #DynArea_Screen
	SWI		OS_ReadDynamicArea
	
	; r0 = pointeur memoire ecrans
	ldr		R10,taille_actuelle_memoire_ecran
	add		R0,R0,R10		; au bout de la mémoire video, le buffer dma
	;add		R0,R0,#4096
	;add		R0,R0,#8192
	str		R0,adresse_dma1_logical
	str		R0,adresse_dma1_logical_courant
	add		R1,R0,#8320*2
	str		R1,adresse_dma1_logical_fin
	
	str		R1,adresse_dma2_logical	
	str		R1,adresse_dma2_logical_courant
	add		R2,R1,#8320*2
	str		R2,adresse_dma2_logical_fin
	

	
	
	
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
		str			R1,adresse_dma2_memc_courant
	

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
		str			R1,adresse_dma1_memc_courant

; on met à zéro les buffers DMA
	ldr		R1,adresse_dma1_logical
	mov		R2,#32768/4
	mov		R0,#0
boucle_cls_buffer_dma:
	str		R0,[R1],#4
	subs	R2,R2,#1
	bgt		boucle_cls_buffer_dma


	adr			R1,LSP_InstrumentInfo
	ldr			R2,[R1],#4
	ldr			R3,pointeur_LSPBank
	add			R3,R3,R2				; debut du sample
	ldr			R2,[R1],#4

	add			R2,R2,R2				; deborde du sample, pour tester
	
	
	add			R4,R3,R2,lsl #2			; fin du sample = debut du sample + len*2
	str			R3,pointeur_courant_instrument
	str			R3,pointeur_debut_instrument
	str			R4,pointeur_fin_du_sample

	ldr			R3,pointeur_LSPBank
	ldr			R2,[R1],#4				; offset position repeat
	add			R2,R2,R3
	str			R2,pointeur_position_repeat
	ldr			R4,[R1],#4				; len repeat
	add			R4,R4,R4				; *2
	add			R4,R2,R4				; + debut repeat

	str			R4,pointeur_fin_repeat

	bl		rempli_les_deux_buffers_dma_avec_le_sample

	;bl		rempli_un_buffer_dma
	;bl		swap_pointeurs_dma_son
	;bl		rempli_un_buffer_dma



; system son Risc OS
; set sound volume
	mov		R0,#80							; maxi 127
	SWI		0x40180	

; read sound volume
	mov		R0,#0							; 0=read = OK 127
	SWI		0x40180


	MOV       R0,#0							;  	Channels for 8 bit sound
	MOV       R1,#0						; Samples per channel (in bytes)
	MOV       R2,#0						; Sample period (in microseconds per channel) 
	MOV       R3,#0
	MOV       R4,#0
	SWI       0x40140						;"Sound_Configure"
	
	adr		R5,backup_params_sons
	stmia	R5,{r0-R4}



	MOV       R0,#1							;  	Channels for 8 bit sound
	MOV       R1,#longueur_du_sample		; Samples per channel (in bytes)
	MOV       R2,#ms_freq_Archi				; Sample period (in microseconds per channel)  = 48  / 125 pour 8000hz
	MOV       R3,#0
	MOV       R4,#0
	SWI       0x40140						;"Sound_Configure"


	SWI		22
	MOVNV R0,R0 

; installation vsync RM
	bl		install_vsync
	
	bl		swap_pointeurs_dma_son

	SWI		22
	MOVNV R0,R0
	bl		set_dma_dma1
	teqp  r15,#0                     
	mov   r0,r0		


	
; write memc control register, start sound

	ldr		R0,memc_control_register_original	
	orr		R0,R0,#0b100000000000
	str		R0,[R0]
	
	SWI		22
	MOVNV R0,R0            


; change bien la frequence
;sound frequency register ? 0xC0 / VIDC
	mov		R0,#0x30-1
	mov		R0,#ms_freq_Archi-1

	mov		r1,#0x3400000               
; sound frequency VIDC
	mov		R2,#0xC0000100
	orr   r0,r0,R2
	str   r0,[r1]  


	teqp  r15,#0                     
	mov   r0,r0 

boucle:	

	bl		avance_pointeur_dma1


;rempli buffer dma 1
	.ifeq		0
	bl		rempli_un_buffer_dma
	.endif
	SWI		22
	MOVNV R0,R0
	bl		set_dma_dma1
	teqp  r15,#0                     
	mov   r0,r0	

	bl		swap_pointeurs_dma_son
		

	bl		wait_VBL



; vsync par risc os
	;mov		R0,#0x13
	;swi		0x6n



	bl      scankeyboard

test_touche_space:
	cmp		R0,#0x5F
	bne		boucle

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

;--------------------------------------------------------------------------------------------------------------------------------
avance_pointeur_dma1:

	ldr			R1,adresse_dma1_logical_courant
	add			R1,R1,#nb_octets_par_vbl
	ldr			R3,adresse_dma1_memc_courant
	add			R3,R3,#nb_octets_par_vbl
	
	
	ldr			R2,adresse_dma1_logical_fin
	cmp			R1,R2
	blt			pas_de_bouclage_dma_1

	ldr			R1,adresse_dma1_logical
	ldr			R3,adresse_dma1_memc

pas_de_bouclage_dma_1:
	
	str			R1,adresse_dma1_logical_courant
	str			R3,adresse_dma1_memc_courant




	ldr			R1,adresse_dma2_logical_courant
	add			R1,R1,#nb_octets_par_vbl
	ldr			R3,adresse_dma2_memc_courant
	add			R3,R3,#nb_octets_par_vbl
	
	
	ldr			R2,adresse_dma2_logical_fin
	cmp			R1,R2
	blt			pas_de_bouclage_dma_2

	ldr			R1,adresse_dma2_logical
	ldr			R3,adresse_dma2_memc

pas_de_bouclage_dma_2:
	
	str			R1,adresse_dma2_logical_courant
	str			R3,adresse_dma2_memc_courant


	mov			pc,lr


rempli_les_deux_buffers_dma_avec_le_sample:
	ldr			R11,adresse_dma1_logical
	ldr			R12,adresse_dma2_logical

	ldr			R3,pointeur_debut_instrument
	ldr			R4,pointeur_fin_du_sample
	
boucle_copie_sample_entier:
	ldrb		R0,[R3],#1
	strb		R0,[R11],#1
	strb		R0,[R12],#1
	
	cmp			R3,R4
	blt			boucle_copie_sample_entier
	mov			pc,lr


rempli_un_buffer_dma:
; copier le sample dans adresse_dma1_logical
	ldr			R10,adresse_dma1_logical_courant
	ldr			R11,adresse_dma1_logical_fin


	ldr			R3,pointeur_courant_instrument
	ldr			R4,pointeur_fin_du_sample
	ldr			R2,pointeur_position_repeat
	
	mov			R11,#nb_octets_par_vbl

boucle_copie_sample:
	ldrb		R0,[R3],#1
	strb		R0,[R10],#1

	cmp			R3,R4
	blt			.ok
	mov			R3,R2				; remet l'instrument au début
	ldr			R4,pointeur_fin_repeat
	str			R4,pointeur_fin_du_sample
	
.ok:
	cmp			R10,R11
	blt			.ok_dma
	mov			R3,R2				; remet l'instrument au début
	ldr			R10,adresse_dma1_logical
	
.ok_dma:



	subs		R11,R11,#1
	bgt			boucle_copie_sample
	
	str			R3,pointeur_courant_instrument
	
	mov			pc,lr

pointeur_courant_instrument:		.long		0
pointeur_fin_du_sample:				.long		0
pointeur_debut_instrument:			.long		0
pointeur_position_repeat:			.long		0
pointeur_fin_repeat:				.long		0

;-------------------------------	
set_dma_dma1:
	ldr		  R12,adresse_dma1_memc_courant
	mov       R10,#nb_octets_par_vbl
	ADD       R10,R10,R12         ;SendN
	SUB       R10,R10,#16         ; fixit ;-)

	MOV       R12,R12,LSR#2       ;(Sstart/16) << 2
	MOV       R10,R10,LSR#2       ;(SendN/16) << 2
	MOV          R0,#0x3600000     ;memc base
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
	add		R10,R12,#nb_octets_par_vbl


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

;-------------------------------	
swap_pointeurs_dma_son:
	ldr		R8,adresse_dma2_memc
	ldr		R9,adresse_dma1_memc
	str		R8,adresse_dma1_memc
	str		R9,adresse_dma2_memc

	ldr		R8,adresse_dma2_memc_courant
	ldr		R9,adresse_dma1_memc_courant
	str		R8,adresse_dma1_memc_courant
	str		R9,adresse_dma2_memc_courant

	ldr		R8,adresse_dma1_logical_courant
	ldr		R9,adresse_dma2_logical_courant
	str		R8,adresse_dma2_logical_courant
	str		R9,adresse_dma1_logical_courant

	ldr		R8,adresse_dma1_logical_fin
	ldr		R9,adresse_dma2_logical_fin
	str		R8,adresse_dma2_logical_fin
	str		R9,adresse_dma1_logical_fin

	ldr		R8,adresse_dma1_logical
	ldr		R9,adresse_dma2_logical
	str		R8,adresse_dma2_logical
	str		R9,adresse_dma1_logical


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
	;and		R0,R0,#0b11111110
	STRB    R0,[R11,R1]			; 8 bit mu-law logarithmic sample 
	SUBS    R1,R1,#1
	BGE     setlinlogtab
	mov		pc,lr

pagefindblk:
		.long      0 ;0
		.long      0 ;4
		.long      0 ;8
		.long      0 ;12

page_block:
	.long		0		; Physical page number 
	.long		0		; Logical address 
	.long		0		; Physical address 

pagesize:		.long	0
numpages:		.long	0

backup_params_sons:	
	.long		0
	.long		0
	.long		0
	.long		0
	.long		0
	.long		0

	
pointeur_LSPBank:			.long		LSPBank
pointeur_LSPBank_end:		.long		LSPBank_end	
memc_control_register_original:			.long	0
taille_actuelle_memoire_ecran:			.long		0

adresse_dma1_logical:				.long		0
adresse_dma1_logical_courant:		.long		0
adresse_dma1_logical_fin:			.long		0
adresse_dma1_memc:					.long		0
adresse_dma1_memc_courant:			.long		0


adresse_dma2_logical:				.long		0
adresse_dma2_logical_courant:		.long		0
adresse_dma2_logical_fin:			.long		0
adresse_dma2_memc:					.long		0
adresse_dma2_memc_courant:			.long		0


LSP_InstrumentInfo:			; (15 instruments)
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

pointeur_sample:		.long		sample
pointeur_fin_sample:	.long		fin_sample
	
lin2logtab:		.skip		256


sample:
		.incbin	"bah.pcm"
fin_sample:
	
LSPBank:
	.incbin		"knullakuk.lsbank"
LSPBank_end:

