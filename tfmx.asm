; player TFMX sur Archimedes ARM2
; 
; v0.0 - 20/08/2021
;
;
;
;
; il faut convertir:
; - SONGPLAY : changement de morceau/musique dans le module
; - IRQIN : routine de replay
; - OK : INITDATA : initialisation de TFMX + du module
; - setv7freq : mets d0 dans v7mixrate + 

; DMACON: set à 0 = on coupe le canal / set a 1 = on active le canal en prenant en entrée : pointeur adresse smaple et longeur sample


; interruptions:
; level 1 - vector $64 : soft/DskBlk/Tbe
; level 2 - vector $68 : keyboard					IRQVEC2
; level 3 - vector $6c : Vbl/Copper/Blitter			IRQVEC3
; level 4 - vector $70 : audio
; level 5 - vector $74 : DskSyn/Rbf
; level 6 - vector $78 : Cia-b 

; IRQVEC4 = mwadr = interruption audio = 
; IRQVEC6 = timerin = Cia-b = player audio aussi
; IRQVEC3 = irq1 = Vbl/Copper/Blitter = routine de replay une fois par VBL

; paramètres
.equ tfmx_maxbyts,		480+792			; extended buffer - taille du buffer passer en D2 lors des inits. - buffer pour la gestion de la musique
.equ tfmx_maxbyts_div2_moins32,		((tfmx_maxbyts)/2)-32
.equ tfmx_maxbyts_fois3_div4,		((tfmx_maxbyts*3)/4)

	.org 0x8000
main:



; ----------- début de Initdata
initdata:
; en entrée :
; R0 = mdatbase	in d0.l : pointeur sur fichier binaire mdat
; R1 = smplbase	in d1.l : pointeur sur fichier binaire smpl
; R2 = 7voicebase in d2.l : buffer de maxbyts
; R3 = 7voicerate in d3.w = frequence ? pas utilisé a priori

; init de variables internes
		adr			R6,tfmx_MasterDataBlock			; CHfield0
		
		mov			R8,#0x40400000
		str			R8,[R6, #tfmx_fadevol-tfmx_MasterDataBlock]
		
		mov			R8,#0
		strb		R8,[R6, #tfmx_fadeadd-tfmx_MasterDataBlock]			; clear fade
		
		str			R0,[R6, #tfmx_database-tfmx_MasterDataBlock]		; pointeur sur module .mdat
		str			R1,[R6, #tfmx_samplebase-tfmx_MasterDataBlock]		; pointeur sur sample .smpl
		str			R2,[R6, #tfmx_mixbufbase-tfmx_MasterDataBlock]		; buffer de mixage des 3 voies calculées - inutile ?
		
		str			R8,[R1]												; clear oneshoot loopsample
		str			R1,[R6, #tfmx_imsbase-tfmx_MasterDataBlock]			; pointeur sur sample 
		
		ldr			R8,[R1, #tfmx_offset_tracks]						; R8=offset des tracks
		cmp			R8,#0
		beq			initdata_oldversion

		add			R8,R8,R0											; R8=adresse mémoire absolue des tracks
		str			R8,[R6, #tfmx_trackbase-tfmx_MasterDataBlock]
		
		ldr			R8,[R1, #tfmx_offset_ptable]
		add			R8,R8,R0
		str			R8,[R6, #tfmx_pattnbase-tfmx_MasterDataBlock] 		; R8=adresse mémoire absolue des patterns

		ldr			R8,[R1, #tfmx_offset_mtable]
		add			R8,R8,R0
		str			R8,[R6, #tfmx_macrobase-tfmx_MasterDataBlock] 		; R8=adresse mémoire absolue des macros
		
		add			R0,R0,#tfmx_offset_fxtable
		str			R0,[R6, #tfmx_fxbase-tfmx_MasterDataBlock] 			; R0=adresse mémoire absolue des effets / FX
		
		b			initdata_goon

initdata_oldversion:
		mov		R1,#0x800
		add		R1,R1,R0
		str		R1,[R6, #tfmx_trackbase-tfmx_MasterDataBlock]		; R1=adresse mémoire absolue des tracks
		
		mov		R1,#0x400
		add		R1,R1,R0
		str		R1,[R6, #tfmx_pattnbase-tfmx_MasterDataBlock] 		; R1=adresse mémoire absolue des patterns		

		mov		R1,#0x600
		add		R1,R1,R0
		str		R1,[R6, #tfmx_macrobase-tfmx_MasterDataBlock]		; R1=adresse mémoire absolue des macros

initdata_goon:
		; sauve IRQVEC4 dans oldvec4 : $70 = irq 4 = irq fin de lecture de sample par le DMA Audio
		; mets mwadr dans IRQVEC4 : ?
		

; init de variables internes 2 eme partie
		adr			R5,tfmx_PatternDataBlock			; CHfield2
		mov			R8,#5
		str			R8,[R5, #tfmx_offset_PatternDataBlock_speed]
		
		adr			R6,tfmx_songcont
		mov			R9,#0x1F
		mov			R10,#0
initdata_contset:
		str			R8,[R6, #tfmx_PatternDataBlock_songspeed-tfmx_songcont]
		str			R10,[R6, #tfmx_PatternDataBlock_timerspeed-tfmx_songcont]
		str			R10,[R6],#4
		subs		R9,R9,#1
		bge			initdata_contset


		adr			R6,tfmx_MasterDataBlock			; CHfield0
		
		adr			R4,tfmx_Synoffsets
		ldr			R5,pointeur_initdata_tfmx_Synthfield0
		str			R5,[R4],#4
		ldr			R5,pointeur_initdata_tfmx_Synthfield1
		str			R5,[R4],#4
		ldr			R5,pointeur_initdata_tfmx_Synthfield2
		str			R5,[R4],#4
		ldr			R5,pointeur_initdata_tfmx_Synthfield3
		str			R5,[R4],#4
		
		mov			R9,#11
initdata_filfld:
		ldr			R8,[R4,#-16]
		str			R8,[R4],#4
		subs		R9,R9,#1
		bge			initdata_filfld


		adr			R4,tfmx_Synoffsets+16

		ldr			R5,pointeur_initdata_tfmx_Synthfield4
		adr			R3,tfmx_voice1dat

		mov			R8,#0x1		; note/period par défaut = 1
		mov			R9,#0x003F	; volume par défaut = 63
		str			R8,[R3,#8]   ; 8= period
		str			R9,[R3,#12]  ; 12= volume
		
		str			R3,[R5,#tfmx_offset_Synoffsets_audioadr]
		adr			R3,tfmx_set_v7wave1						; routine de ?
		str			R3,[R5,#tfmx_offset_Synoffsets_set_v7wave]
		
		adr			R2,tfmx_flagtab
		str			R2,[R5,#tfmx_offset_Synoffsets_dmaconadr]
		str			R5,[R4],#4
		
		ldr			R5,pointeur_initdata_tfmx_Synthfield5
		adr			R3,tfmx_voice2dat
		str			R8,[R3,#8]   ; 8= period
		str			R9,[R3,#12]  ; 12= volume
		str			R3,[R5,#tfmx_offset_Synoffsets_audioadr]		
		adr			R3,tfmx_set_v7wave2
		str			R3,[R5,#tfmx_offset_Synoffsets_set_v7wave]
		add			R2,R2,#4
		str			R2,[R5,#tfmx_offset_Synoffsets_dmaconadr]
		str			R5,[R4],#4
		
		ldr			R5,pointeur_initdata_tfmx_Synthfield6
		adr			R3,tfmx_voice3dat
		str			R8,[R3,#8]  						 ; 8= period
		str			R9,[R3,#12] 						 ; 12= volume
		str			R3,[R5,#tfmx_offset_Synoffsets_audioadr]		
		adr			R3,tfmx_set_v7wave3
		str			R3,[R5,#tfmx_offset_Synoffsets_set_v7wave]
		add			R2,R2,#4
		str			R2,[R5,#tfmx_offset_Synoffsets_dmaconadr]
		str			R5,[R4],#4		

		ldr			R5,pointeur_initdata_tfmx_Synthfield7
		adr			R3,tfmx_voice4dat
		str			R8,[R3,#8]  						 ; 8= period
		str			R9,[R3,#12] 						 ; 12= volume
		str			R3,[R5,#tfmx_offset_Synoffsets_audioadr]		
		adr			R3,tfmx_set_v7wave4
		str			R3,[R5,#tfmx_offset_Synoffsets_set_v7wave]
		add			R2,R2,#4
		str			R2,[R5,#tfmx_offset_Synoffsets_dmaconadr]
		str			R5,[R4],#4			
		
		
		ldr			R8,[R6,#tfmx_mixbufbase-tfmx_MasterDataBlock]	
		str			R8,[R6,#tfmx_v7buffer1-tfmx_MasterDataBlock]
		add			R8,R8,#tfmx_maxbyts
		str			R8,[R6,#tfmx_v7buffer2-tfmx_MasterDataBlock]
		add			R8,R8,#tfmx_maxbyts
		str			R8,[R6,#tfmx_v7buffer3-tfmx_MasterDataBlock]
		
		bl			tfmx_init7voice
		
		mov			pc,lr

pointeur_initdata_tfmx_Synthfield0:				.long		tfmx_Synthfield0
pointeur_initdata_tfmx_Synthfield1:				.long		tfmx_Synthfield1
pointeur_initdata_tfmx_Synthfield2:				.long		tfmx_Synthfield2
pointeur_initdata_tfmx_Synthfield3:				.long		tfmx_Synthfield3
pointeur_initdata_tfmx_Synthfield4:				.long		tfmx_Synthfield4
pointeur_initdata_tfmx_Synthfield5:				.long		tfmx_Synthfield5
pointeur_initdata_tfmx_Synthfield6:				.long		tfmx_Synthfield6
pointeur_initdata_tfmx_Synthfield7:				.long		tfmx_Synthfield7
; ----------- fin de Initdata

tfmx_init7voice:
		adr			R6,tfmx_MasterDataBlock			; CHfield0
		adr			R5,tfmx_v7field
		mov			R8,#0
		strb		R8,[R6,#tfmx_v7flag-tfmx_MasterDataBlock]
		strb		R8,[R6,#tfmx_v7initflag-tfmx_MasterDataBlock]
		
		adr			R0,tfmx_v7contab
		mov			R8,#384					; boucle de 384 fois
		mov			R9,#0x80
		mov			R10,#0x7F
tfmx_init7voice_loop1:
		strb		R9,[R0],#1				; $80
		strb		R10,[R0,#640-1]			; $7F
		subs		R8,R8,#1
		bgt			tfmx_init7voice_loop1

; conversion table ?
		adr			R0,tfmx_v7contab+384
		mov			R8,#256
		mov			R9,#0x80
tfmx_init7voice_loop2:		
		strb		R9,[R0],#1
		add			R9,R9,#1
		subs		R8,R8,#1
		bgt			tfmx_init7voice_loop2
		
; volume table		
		adr			R0,tfmx_v7voltab
		mov			R11,#0					; d7
		mov			R8,#64					; d0 / 64-1
tfmx_init7voice_loop3:
		mov			R9,#0					; d6
		mov			R10,#256				; d1 / 255
tfmx_init7voice_loop4:
		mov			R2,R9					; d6=>d2
		mul			R2,R11,R2				; d2=d2*d7
		mov			R2,R2,lsr #6
		eor			R2,R2,#0x80
		strb		R2,[R0],#1
		add			R9,R9,#1				; d6
		subs		R10,R10,#1
		bgt			tfmx_init7voice_loop4
;		lea	128(a0),a0
		add			R11,R11,#1
		subs		R8,R8,#1
		bgt			tfmx_init7voice_loop3


		bl			tfmx_set7off
		mov			pc,lr
		

tfmx_set7off:
		
		adr			R6,tfmx_MasterDataBlock			; CHfield0
		mov			R8,#0
		
		str			R8,[R6,#tfmx_v7dmahelp-tfmx_MasterDataBlock]
		adr			R5,tfmx_v7field
		strb		R8,[R6,#tfmx_v7flag-tfmx_MasterDataBlock]
		strb		R8,[R6,#tfmx_v7initflag-tfmx_MasterDataBlock]

		mov			R8,#3
		bl			tfmx_channeloff
		adr			R6,tfmx_MasterDataBlock			; CHfield0

		adr			R5,tfmx_flagtab
		mov			R8,#0
		str			R8,[R5],#4
		str			R8,[R5],#4
		str			R8,[R5],#4
		str			R8,[R5],#4

		adr			R5,tfmx_v7field
		mov			R8,#0xD0
		str			R8,[R5,#tfmx_v7loopd1-tfmx_v7field]
		str			R8,[R5,#tfmx_v7loopd2-tfmx_v7field]
		str			R8,[R5,#tfmx_v7loopd3-tfmx_v7field]
		str			R8,[R5,#tfmx_v7loopd4-tfmx_v7field]				; prolonger sur 7 voies réelles
		
		mov			R8,#0
		str			R8,[R5,#tfmx_v7freq1-tfmx_v7field]
		str			R8,[R5,#tfmx_v7freq2-tfmx_v7field]
		str			R8,[R5,#tfmx_v7freq3-tfmx_v7field]
		str			R8,[R5,#tfmx_v7freq4-tfmx_v7field]				; prolonger sur 7 voies réelles
		
		mov			R8,#0b00000000									; sf
		strb		R8,[R5,#tfmx_v7wset1-tfmx_v7field]
		strb		R8,[R5,#tfmx_v7wset2-tfmx_v7field]
		strb		R8,[R5,#tfmx_v7wset3-tfmx_v7field]
		strb		R8,[R5,#tfmx_v7wset4-tfmx_v7field]

		mov			R8,#0xFFF0
		ldr			R9,[R6,#tfmx_v7buffer3-tfmx_MasterDataBlock]
		
		str			R9,[R5,#tfmx_v7loopv1-tfmx_v7field]
		str			R9,[R5,#tfmx_v7loopv2-tfmx_v7field]
		str			R9,[R5,#tfmx_v7loopv3-tfmx_v7field]
		str			R9,[R5,#tfmx_v7loopv4-tfmx_v7field]
		
		str			R8,[R5,#tfmx_v7regstore-tfmx_v7field]
		str			R8,[R5,#tfmx_v7regstore-tfmx_v7field+4]
		str			R8,[R5,#tfmx_v7regstore-tfmx_v7field+8]
		str			R8,[R5,#tfmx_v7regstore-tfmx_v7field+12]
		str			R9,[R5,#tfmx_v7regstore-tfmx_v7field+16]
		str			R9,[R5,#tfmx_v7regstore-tfmx_v7field+20]
		str			R9,[R5,#tfmx_v7regstore-tfmx_v7field+24]
		str			R9,[R5,#tfmx_v7regstore-tfmx_v7field+28]
		
		bl			tfmx_set_v7wave1
		bl			tfmx_set_v7wave2
		bl			tfmx_set_v7wave3
		bl			tfmx_set_v7wave4
		
		ldr			R5,[R6,#tfmx_mixbufbase-tfmx_MasterDataBlock]
		mov			R8,#tfmx_maxbyts_fois3_div4
		mov			R9,#0
set7off_loop5:
		str			R9,[r5],#4
		subs		R8,R8,#1
		bgt			set7off_loop5
		
		mov			pc,lr
		
		
tfmx_channeloff:
; en entrée, R8 = channel number
		str		R5,tfmx_channeloff_save_r5
		adr		R5,tfmx_Synoffsets
		and		R8,R8,#0x0F
		mov		R8,R8,lsl #2			; * 4
		ldr		R5,[R5,R8]
		ldrb	R9,[R5,#tfmx_offset_Synoffsets_priority]
		cmp		R9,#0
		bne		tfmx_channeloff_out
		;move.w	clibits(a5),CHIP+INTENA							; dff000+09a = Interrupt enable bits
		;//// pas géré
		;move.w	offbits(a5),CHIP+DMACON	;dma disable			; dff000+096 = dmacon, a gérer
		ldr		R9,[R5,#tfmx_offset_Synoffsets_offbits]
		str		R9,AMIGA_HARDWARE_REG_DMACON
		mov		R9,#0
		strb	R9,[R5,#tfmx_offset_Synoffsets_mstatus]
		str		R9,[R5,#tfmx_offset_Synoffsets_ims_dlen]
		strb	R9,[R5,#tfmx_offset_Synoffsets_riffstats]
		
		str		R0,tfmx_channeloff_save_r0
		ldr		R0,[R5,#tfmx_offset_Synoffsets_dmaconadr]
		cmp		R0,#0
		beq		tfmx_channeloff_out
		str		R9,[R0]
		ldr		R0,[R5,#tfmx_offset_Synoffsets_set_v7wave]
		mov		lr,pc
		mov		pc,R0						; jsr a0, a0=set_v7wave(a5)
		
		ldr		R0,tfmx_channeloff_save_r0
tfmx_channeloff_out:
		ldr		R5,tfmx_channeloff_save_r5

		mov			pc,lr

tfmx_channeloff_save_r5:			.long		0
tfmx_channeloff_save_r0:			.long		0
		
; routine specifiques aux voies mixées
tfmx_sauvegarde_R0_R1_R2_R3_R4_R5_R8_R9_R10:		.long		0,0,0,0,0,0,0,0,0
; altere R12
tfmx_set_v7wave1:
		adr			R12,tfmx_sauvegarde_R0_R1_R2_R3_R4_R5_R8_R9_R10
		stmia		R12,{R0-R5,R8-R10}
		adr			R5,tfmx_v7field
		add			R0,R5,#tfmx_voice1dat-tfmx_v7field
		add			R1,R5,#tfmx_v7regstore-tfmx_v7field
		adr			R2,tfmx_flagtab
		add			R3,R5,#tfmx_v7freq1-tfmx_v7field
		add			R4,R5,#tfmx_v7wset1-tfmx_v7field
		bl			tfmx_v7dma
		ldmia		R12,{R0-R5,R8-R10}
		mov			pc,lr

tfmx_set_v7wave2:
		adr			R12,tfmx_sauvegarde_R0_R1_R2_R3_R4_R5_R8_R9_R10
		stmia		R12,{R0-R5,R8-R9}
		adr			R5,tfmx_v7field
		add			R0,R5,#tfmx_voice2dat-tfmx_v7field
		add			R1,R5,#tfmx_v7regstore-tfmx_v7field+4
		adr			R2,tfmx_flagtab+4
		add			R3,R5,#tfmx_v7freq2-tfmx_v7field
		add			R4,R5,#tfmx_v7wset2-tfmx_v7field
		bl			tfmx_v7dma
		ldmia		R12,{R0-R5,R8-R10}
		mov			pc,lr


tfmx_set_v7wave3:
		adr			R12,tfmx_sauvegarde_R0_R1_R2_R3_R4_R5_R8_R9_R10
		stmia		R12,{R0-R5,R8-R9}
		adr			R5,tfmx_v7field
		add			R0,R5,#tfmx_voice3dat-tfmx_v7field
		add			R1,R5,#tfmx_v7regstore-tfmx_v7field+8
		adr			R2,tfmx_flagtab+8
		add			R3,R5,#tfmx_v7freq3-tfmx_v7field
		add			R4,R5,#tfmx_v7wset3-tfmx_v7field
		bl			tfmx_v7dma
		ldmia		R12,{R0-R5,R8-R10}
		mov			pc,lr

tfmx_set_v7wave4:
		adr			R12,tfmx_sauvegarde_R0_R1_R2_R3_R4_R5_R8_R9_R10
		stmia		R12,{R0-R5,R8-R9}
		adr			R5,tfmx_v7field
		add			R0,R5,#tfmx_voice4dat-tfmx_v7field
		add			R1,R5,#tfmx_v7regstore-tfmx_v7field+12
		adr			R2,tfmx_flagtab+12
		add			R3,R5,#tfmx_v7freq4-tfmx_v7field
		add			R4,R5,#tfmx_v7wset4-tfmx_v7field
		bl			tfmx_v7dma
		ldmia		R12,{R0-R5,R8-R10}
		mov			pc,lr

tfmx_v7dma_valeur_3FFFF:			.long			0x3FFFF

tfmx_v7dma:
		ldrb		R8,[R2]
		cmp			R8,#0
		bne			tfmx_v7dma_dma1

		mov			R9,#0
		str			R9,[R3]
		mov			R9,#0b11111111
		strb		r9,[R4]		
		mov			pc,lr

tfmx_v7dma_dma1:
		ldr		R8,[R0]					; R8=startadr
		ldr		R9,[R0,#4]				; R9=length
		cmp		R9,#0x20				; $20=minimal length for sample
		bge		tfmx_v7dma_noone
		mov		R9,#tfmx_maxbyts_div2_moins32
		ldr		R8,[R5,#tfmx_v7clrbuffer-tfmx_v7field]
tfmx_v7dma_noone:
		ldr		R12,tfmx_v7dma_valeur_3FFFF
		and		R9,R9,R12				; longeur maximale du sample en mots = $40000
		mov		R9,R9,lsl #1			; en octets
		add		R8,R9,R8				; R8=fin du sample
		str		R8,[R0,#16]				; ex 10
		str		R9,[R0,#20]				; ex 14

		ldrb	R8,[R4]					; tst v7wset
		cmp		R8,#0
		beq		tfmx_v7dma_dma2

		mov		R8,#0b00000000
		strb	R8,[R4]
		ldr		R9,[R0]					; d1
		ldr		R8,[R0,#4]				; d0
		cmp		R9,#0x20				; 32?
		bge		tfmx_v7dma_noone2
		mov		R8,#tfmx_maxbyts_div2_moins32
		ldr		R9,[R5,#tfmx_v7clrbuffer-tfmx_v7field]
tfmx_v7dma_noone2:
		ldr		R12,tfmx_v7dma_valeur_3FFFF
		and		R8,R8,R12				; longeur maximale du sample en mots = $40000
		mov		R8,R8,lsl #1			; en octets
		add		R9,R9,R8				; R9=fin du sample
		str		R9,[R1,#16]				; ex 16
		rsbs	R8,R8,#0
		str		R8,[R1]
tfmx_v7dma_dma2:
		mov		pc,lr


;--------------------------------------------------------------------------------------
tfmx_songplay:
; d0=numéro de la piste dans le module
; R0 = numéro de la piste dans le module
		adr			R6,tfmx_MasterDataBlock			; CHfield0
		str			R0,[R6,#tfmx_songfl-tfmx_MasterDataBlock]
		mov			R8,#0
		strb		R8,[R6,tfmx_re_in_save-tfmx_MasterDataBlock]
		bl			tfmx_songset
		mov			pc,lr

;
tfmx_playcont:
		adr			R6,tfmx_MasterDataBlock			; CHfield0
		orr			R0,R0,#0b100000000
		str			R0,[R6,#tfmx_songfl-tfmx_MasterDataBlock]
		mov			R8,#0
		strb		R8,[R6,tfmx_re_in_save-tfmx_MasterDataBlock]		
		bl			tfmx_songset
		mov			pc,lr
;		
tfmx_songset:
		bl			tfmx_alloff					; conserve R6
		mov			R8,#0
		strb		R8,[R6,#tfmx_allon-tfmx_MasterDataBlock]		;disable routine
		str			R8,[R6,#tfmx_custom-tfmx_MasterDataBlock]		;disable custom pattern

		ldr			R4,[R6,#tfmx_database-tfmx_MasterDataBlock]		;adress of musicdata
		ldr			R8,[R6,#tfmx_songfl-tfmx_MasterDataBlock]		; new songnumber
		and			R8,R8,#0x1F
		add			R4,R4,R8, lsl #1						; R4=R4+R8*2 = extend to wordpointer + add database

		adr			R5,tfmx_PatternDataBlock			; CHfield2		

		ldrb		R9,[R6,#tfmx_song-tfmx_MasterDataBlock]			;old song number
		mov			R9,R9,asl #24							; pour le passer en signé
		mov			R9,R9,asr #24
		bmi			tfmx_songset_nocont
		and			R9,R9,#0x1F								; maxi 32 tracks / songs
		adr			R0,tfmx_songcont
		add			R0,R0,R9, lsl #1						; R0=R0+R9*2 / extend to wordpointer / a0=contvar.
		
		ldr			R8,[R5,#tfmx_offset_PatternDataBlock_cstep]		;put current step to buffer
		str			R8,[R0]
		ldr			R8,[R5,#tfmx_offset_PatternDataBlock_speed]
		str			R8,[R0,#tfmx_PatternDataBlock_songspeed-tfmx_songcont]	;and songspeed
		
tfmx_songset_nocont:

		ldr		R8,[R4,#tfmx_offset_fsteps]
		str		R8,[R5,#tfmx_offset_PatternDataBlock_cstep]		; set current step
		str		R8,[R5,#tfmx_offset_PatternDataBlock_fstep]		; set first   step
		ldr		R8,[R4,#tfmx_offset_lsteps]
		str		R8,[R5,#tfmx_offset_PatternDataBlock_lstep]		; set last    step

		ldr		R10,[R4,#tfmx_offset_speeds]					;set song speed
		

		move.w	speeds(a4),d2
		btst.b	#0,songfl(a6)		;test cont flag
		beq.s	.norm1

		lea	songcont(pc),a0		;a0=contvar.
		adda.w	d0,a0
		move.w	(a0),cstep(a5)		;set old current step
		moveq.l	#0,d2
		move.b	65(a0),d2		;and songspeed
.norm1
		move.w	#28,d1
		lea	emptypatt(pc),a4
.loop
		move.l	a4,padress(a5,d1.w)
		move.w	#$ff00,patterns(a5,d1.w)
		clr.l	pstep(a5,d1.w)
		subq.w	#4,d1
		bpl.s	.loop
		move.w	d2,speed(a5)

		tst.b	songfl+1(a6)
		bmi.s	.noplay
		move.l	database(a6),a4		;a4=adress of musicdata
		bsr	newtrack
.noplay
		clr.b	newstep(a6)		;clr flag for endofpattern
		clr.w	scount(a6)		;clr sequencer speed counter
		st.b	tloopcount(a6)
		move.b	songfl+1(a6),song(a6)	;save new songnumber
		clr.b	songfl(a6)		;clr songmode
		clr.w	dmaconhelp(a6)
		lea	infodat(pc),a4
		clr.w	info_fade(a4)
		clr.b	info_seqrun(a4)

		bset.b	#1,PRA			;disable low-pass filter
		move.w	#$ff,CHIP+ADKCON	;clr modulations
		move.b	#1,allon(a6)		;enable routine
;		tst.b	v7flag(a6)
;		beq.s	.no7
;		move.w	#$8208,CHIP+DMACON
;		move.w	#$c400,CHIP+INTENA	;enable soundirq
;		move.w	#$8400,CHIP+INTREQ	;do soundirqs immediatly
;.no7
		rts

newtrack:
		movem.l	a0-a1,-(sp)
back
		move.w	cstep(a5),d0		;current step
		lsl.w	#4,d0			;*16
		move.l	trackbase(a6),a0	;track-step-table
		add.w	d0,a0			;+step
		move.l	pattnbase(a6),a1	;pattern-adress-table

		move.w	(a0)+,d0	;get statment (? special)
		cmp.w	#$effe,d0	;if not equal $effe
		bne.s	cont		;to continue (normal step)
		move.w	(a0)+,d0	;get special-statment
		add.w	d0,d0
		add.w	d0,d0		;d0*4=pointer to adress of routine
		cmp.w	#efxx2,d0
		bcs.s	.ok
		moveq.l	#0,d0
.ok
		jmp	.jumptable3(pc,d0.w)
.jumptable3
jumptable3
		bra.w	stopsong	;$0000
		bra.w	loopsong	;$0001
		bra.w	speedsong	;$0002
		bra.w	set7freq	;$0003
		bra.w	fadesong	;$0004
efxx1
.efxx1
efxx2		= efxx1-jumptable3
cont
					;track 1
		move.w	d0,patterns(a5)	;store patternnumber/transpose
		bmi.s	.pp1		;play pattern ?
		clr.b	d0		;yes
		lsr.w	#6,d0		;*64
		move.l	(a1,d0.w),d0	;get 1st patternadress
		add.l	a4,d0		;add database
		move.l	d0,padress(a5)	;store pattern-adress
		clr.l	pstep(a5)	;clear pattern-step
		sf.b	ploopcount(a5)	;reset loops
.pp1
		movem.w	(a0)+,d0-d6
		move.w	d0,patterns+4(a5)
		bmi.s	.pp2
		clr.b	d0
		lsr.w	#6,d0
		move.l	(a1,d0.w),d0
		add.l	a4,d0
		move.l	d0,padress+4(a5)
		clr.l	pstep+4(a5)
		sf.b	ploopcount+4(a5)
.pp2
		move.w	d1,patterns+8(a5)
		bmi.s	.pp3
		clr.b	d1
		lsr.w	#6,d1
		move.l	(a1,d1.w),d0
		add.l	a4,d0
		move.l	d0,padress+8(a5)
		clr.l	pstep+8(a5)
		sf.b	ploopcount+8(a5)
.pp3
		move.w	d2,patterns+12(a5)
		bmi.s	.pp4
		clr.b	d2
		lsr.w	#6,d2
		move.l	(a1,d2.w),d0
		add.l	a4,d0
		move.l	d0,padress+12(a5)
		clr.l	pstep+12(a5)
		sf.b	ploopcount+12(a5)
.pp4
		move.w	d3,patterns+16(a5)
		bmi.s	.pp5
		clr.b	d3
		lsr.w	#6,d3
		move.l	(a1,d3.w),d0
		add.l	a4,d0
		move.l	d0,padress+16(a5)
		clr.l	pstep+16(a5)
		sf.b	ploopcount+16(a5)
.pp5
		move.w	d4,patterns+20(a5)
		bmi.s	.pp6
		clr.b	d4
		lsr.w	#6,d4
		move.l	(a1,d4.w),d0
		add.l	a4,d0
		move.l	d0,padress+20(a5)
		clr.l	pstep+20(a5)
		sf.b	ploopcount+20(a5)
.pp6
		move.w	d5,patterns+24(a5)
		bmi.s	.pp7
		clr.b	d5
		lsr.w	#6,d5
		move.l	(a1,d5.w),d0
		add.l	a4,d0
		move.l	d0,padress+24(a5)
		clr.l	pstep+24(a5)
		sf.b	ploopcount+24(a5)
.pp7
		tst.w	custom(a6)
		bne.s	.pp8
		move.w	d6,patterns+28(a5)
		bmi.s	.pp8
		clr.b	d6
		lsr.w	#6,d6
		move.l	(a1,d6.w),d0
		add.l	a4,d0
		move.l	d0,padress+28(a5)
		clr.l	pstep+28(a5)
		sf.b	ploopcount+28(a5)
.pp8
		movem.l	(sp)+,a0-a1
		rts

aclear
		clr.b	mstatus(a6)		;stop macro
		sf.b	mskipflag(a6)
		clr.l	priority(a6)		;clr priority/priority2/priocount
		clr.l	fxnote(a6)
		clr.w	ims_dlen(a6)
		clr.b	riffstats(a6)
		rts

alloff
		move.l	a6,-(sp)
		lea	CHfield0(pc),a6
		clr.b	allon(a6)		;disable routine
		clr.w	dmaconhelp(a6)
		lea	Synthfield0(pc),a6
		bsr.s	aclear
		lea	Synthfield1(pc),a6
		bsr.s	aclear
		lea	Synthfield2(pc),a6
		bsr.s	aclear
		lea	Synthfield3(pc),a6
		bsr.s	aclear
		lea	Synthfield4(pc),a6
		bsr.s	aclear
		lea	Synthfield5(pc),a6
		bsr.s	aclear
		lea	Synthfield6(pc),a6
		bsr.s	aclear
		lea	Synthfield7(pc),a6
		bsr.b	aclear
		bsr.w	set7off
		clr.w	$dff0a8			;clr volume channel 1-...
		clr.w	$dff0b8
		clr.w	$dff0c8
		clr.w	$dff0d8			;...-4
		move.w	#$f,CHIP+DMACON		;stop sound DMA
		move.w	#$780,CHIP+INTREQ	;clr soundirqs
		move.w	#$780,CHIP+INTENA	;disable soundirq
		move.w	#$780,CHIP+INTREQ	;clr soundirqs
		lea	infodat(pc),a6
		clr.b	info_seqrun(a6)
		move.l	(sp)+,a6
		rts
		


; AMIGA Hardware registers / a voir ensuite avec le mixage
AMIGA_HARDWARE_REG_DMACON:		.long		0

		


; variables pour les 4 voies gerées sur une seule
tfmx_v7field:
tfmx_v7freq1:		.long		0
tfmx_v7freq2:		.long		0
tfmx_v7freq3:		.long		0
tfmx_v7freq4:		.long		0	
tfmx_v7laut1:		.long		0
tfmx_v7laut2:		.long		0
tfmx_v7laut3:		.long		0
tfmx_v7laut4:		.long		0

; valeurs pour écrire dans Paula
tfmx_voice1dat:
		.long		0			; startadr  : 0 (0)   .l
		.long		0			; len		: 4 (4)		.w
		.long		0			; period	: 8 (6)		.w
		.long		63			; volume	: 12 (8)		.w
tfmx_v7loopv1:
		.long		0			;				16 (10)		.l
tfmx_v7loopd1:
		.long		0			;				20 (14)		.w

tfmx_voice2dat:
		.long		0			; startadr
		.long		0			; len
		.long		0			; period
		.long		63			; volume
tfmx_v7loopv2:
		.long		0
tfmx_v7loopd2:
		.long		0

tfmx_voice3dat:
		.long		0			; startadr
		.long		0			; len
		.long		0			; period
		.long		63			; volume
tfmx_v7loopv3:
		.long		0
tfmx_v7loopd3:
		.long		0

tfmx_voice4dat:
		.long		0			; startadr
		.long		0			; len
		.long		0			; period
		.long		63			; volume
tfmx_v7loopv4:
		.long		0
tfmx_v7loopd4:
		.long		0

;
tfmx_v7wset1:		.byte		0
tfmx_v7wset2:		.byte		0
tfmx_v7wset3:		.byte		0
tfmx_v7wset4:		.byte		0
;
tfmx_v7newbuffer:	.long	0
tfmx_v7oldbuffer:	.long	0
tfmx_v7clrbuffer:	.long	0
;
tfmx_v7bytes:		.long	0					; .w => .long
tfmx_v7bytes2:		.long	0					; .w => .long
tfmx_v7perlong:		.long	0					;
tfmx_v7regstore:	.long	0,0,0,0,0,0,0,0
tfmx_v7stackbuffer:	.long 	0
tfmx_flagtab:		.long	0,0,0,0
tfmx_EndFlag:
;

;	offsets datafile / .mdat
.equ tfmx_offset_fsteps,		256
.equ tfmx_offset_lsteps,		320
.equ tfmx_offset_speeds,		384
.equ tfmx_offset_mutes,			448
.equ tfmx_offset_fxtable,		512
.equ tfmx_offset_tracks,		0x1d0
.equ tfmx_offset_ptable,		0x1d4
.equ tfmx_offset_mtable,		0x1d8

; CHfield0/MasterDataBlock (module global)
tfmx_MasterDataBlock:
tfmx_database:		.long		0
tfmx_samplebase:	.long		0
tfmx_imsbase:		.long		0
					.byte		0				; ?
tfmx_newstep:		.byte		0
					.byte		0,0				; filler multiple de 4
tfmx_imask:			.long		0
tfmx_song:			.byte		0
tfmx_fadeadd:		.byte		0
					.byte		0,0				; filler multiple de 4
tfmx_random:		.long		0
tfmx_oldvec3:		.long		0
tfmx_help1:			.long		0
tfmx_scount:		.long		0
tfmx_allon:			.byte		0
tfmx_fxflag:		.byte		0
					.byte		0,0				; filler multiple de 4
tfmx_oldvec4:		.long		0
tfmx_songfl:		.long		0
tfmx_custom:		.long		0
tfmx_fadevol:		.byte		0
tfmx_fadeend:		.byte		0
tfmx_fadecount1:	.byte		0
tfmx_fadecount2:	.byte		0
					.byte		0				; ?
tfmx_re_in_save:	.byte		0
					.byte		0,0				; filler multiple de 4
tfmx_tloopcount:	.long		0
tfmx_trackbase:		.long		0
tfmx_pattnbase:		.long		0
tfmx_macrobase:		.long		0
tfmx_fxbase:		.long		0
tfmx_dmaconhelp:	.long		0
tfmx_v7flag:		.byte		0
tfmx_v7initflag:	.byte		0
					.byte		0,0				; filler multiple de 4
tfmx_v7mixrate:		.long		0
tfmx_v7slodo:		.long		0
tfmx_Slow:			.long		0
tfmx_mixbufbase:	.long		0
tfmx_v7buffer1:		.long		0
tfmx_v7buffer2:		.long		0
tfmx_v7buffer3:		.long		0
tfmx_v7dmahelp:		.long		0


;***
;	offsets for Synthfields (synthesizer)
;
tfmx_Synoffsets:
 		.skip		16*4			; 16 .long
;0
.equ tfmx_offset_Synoffsets_mstatus,			0		; .byte		1	;	 **
.equ tfmx_offset_Synoffsets_modstatus,			1		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_offdma,				2		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_mabcount1,			3		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_basenote,			4		; rs.w	1 => .long	;
.equ tfmx_offset_Synoffsets_irwait,				8		; rs.w	1 => .long	;
.equ tfmx_offset_Synoffsets_basevol,			12		; rs.w	1 => .long	;
.equ tfmx_offset_Synoffsets_detunes,			16		; rs.w	1 => .long	;
.equ tfmx_offset_Synoffsets_madress,			20		; rs.l	1	;
;1
.equ tfmx_offset_Synoffsets_mstep,				24		; rs.w	1 => .long	;
.equ tfmx_offset_Synoffsets_mawait,				28		; rs.w	1 => .long	;
.equ tfmx_offset_Synoffsets_onbits,				32		; rs.w	1 => .long	;
.equ tfmx_offset_Synoffsets_offbits,			36		; rs.w	1 => .long	;
.equ tfmx_offset_Synoffsets_volume,				40		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_oldvol,				41		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_mloopcount,			42		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_mabcount2,			43		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_envelope,			44		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_envcount,			45		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_envolume,			46		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_envspeed,			47		; rs.b	1	;	**
;2
.equ tfmx_offset_Synoffsets_vibrate,			48		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_vibcount,			49		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_pospeed,			50		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_pocount,			51		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_vibperiod,			52		; rs.w => .long		1	;
.equ tfmx_offset_Synoffsets_vibsize1,			56		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_vibsize2,			57		; rs.b	1	;	**
														; .byte * 2 , alignemnt
.equ tfmx_offset_Synoffsets_baseperiod,			60		; rs.w => .long		1	;
.equ tfmx_offset_Synoffsets_beginadd,			64		; rs.w => .long		1	;
.equ tfmx_offset_Synoffsets_sbegin,				68		; rs.l	1	;
;3
.equ tfmx_offset_Synoffsets_potime,				72		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_poperiod,			76		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_samplen,			80		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_keyflag,			84		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_riffAND,			85		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_priority,			86		; rs.b	1	;	 **	----
.equ tfmx_offset_Synoffsets_priority2,			87		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_msubadr,			88		; rs.l	1	;
.equ tfmx_offset_Synoffsets_priocount,			92		; rs.w => .long	1	1	;
;4
.equ tfmx_offset_Synoffsets_msubstep,			96		; rs.w => .long	1	;		----
.equ tfmx_offset_Synoffsets_oldfx,				100		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_ims_deltaold,		101		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_riffmacro,			102		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_rifftrigg,			103		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_intbits,			104		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_clibits,			108		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_riffspeed,			112		; rs.b	1	;	 **	----
.equ tfmx_offset_Synoffsets_riffrandm,			113		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_riffcount,			114		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_riffstats,			115		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_riffadres,			116		; rs.l	1	;		----
;5
.equ tfmx_offset_Synoffsets_riffsteps,			120		; rs.w => .long	1	;		----
.equ tfmx_offset_Synoffsets_channadd,			124		; rs.l	1	;		----
.equ tfmx_offset_Synoffsets_audioadr,			128		; rs.l	1	;
.equ tfmx_offset_Synoffsets_mabadd,				132		; rs.l	1	;
;6
.equ tfmx_offset_Synoffsets_ims_doffs,			136		; rs.l	1	;
.equ tfmx_offset_Synoffsets_ims_sstart,			140		; rs.l	1	;
.equ tfmx_offset_Synoffsets_ims_slen,			144		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_ims_dlen,			148		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_ims_mod1,			152		; rs.l	1	;
;7
.equ tfmx_offset_Synoffsets_ims_mod1len,		156		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_ims_mod1len2,		160		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_ims_mod1add,		164		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_ims_delta,			168		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_ims_mod2,			172		; rs.l	1	;
.equ tfmx_offset_Synoffsets_ims_flen1,			176		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_ims_flen2,			180		; rs.w => .long	1	;
;8
.equ tfmx_offset_Synoffsets_ims_fspeed,			184		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_ims_mod2add,		188		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_ims_mod2len,		192		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_ims_mod2len2,		196		; rs.w => .long	1	;

.equ tfmx_offset_Synoffsets_fxnote,				200		; rs.l	1	;
.equ tfmx_offset_Synoffsets_period,				204		; rs.w => .long	1	;
.equ tfmx_offset_Synoffsets_nwait,				208		; rs.b	1	;	 **
.equ tfmx_offset_Synoffsets_mskipflag,			209		; rs.b	1	;	**
.equ tfmx_offset_Synoffsets_ims_dolby,			210		; rs.b	1	;	 **
												; rs.b	1	;	**
;9
.equ tfmx_offset_Synoffsets_dmaconadr,			212		; rs.l	1	;
.equ tfmx_offset_Synoffsets_set_v7wave,			216		; rs.l	1	;



		

tfmx_Synthfield0:
;0
 	.long	0		;(mstatus.b/modstatus.b/offdma.b/mabcount1.b)
 	.long	0,0		;(last+basenote.w/irwait.w)
 	.long	0,0		;(basevol/detunes)
 	.long	0		;(macroadress)
;1
 	.long	0,0		;(mstep/mawait)
 	.long	0x8201,0x0001	;dmabits(on/off)
 	.long	0		;(volume.b/oldvol.b/mloopcount.b/mabcount2.b)
 	.long	0		;(envelope.b/envcount.b/envolume.b/envspeed.b)
;2
 	.long	0		;(vibrate/vibcount/pospeed/pocount)
 	.long	0		;(vibperiod)
	.byte	0,0,0,0	; (vibsize1/vibsize2/ + 2 bytes alignement)
 	.long	0,0		;(baseperiod/beginadd)
 	.long	0		;(sbegin.l)
;3
 	.long	0,0		;(potime.w/poperiod.w)
 	.long	0		;(samplen.w)
	.byte	0,0		;(keyflag.b/riffAND.b)
	.byte	0,0		;(priority.b/priority2.b)
 	.long	0		;(msubadr.l)
 	.long	0		;(priocount.w) !CLR by alloff
;4
 	.long	0		;(msubstep.w
	.byte	0,0		;(oldfx.b/ims_delatold.b)
	.byte	0,0		;(riffmacro.b/rifftrigg.b)
 	
	.long	0x8080	;irqbits(on)
	.long	0x0080	;irqbits(off)
	.long	0
 	.byte	0,0,0,0	;(riffspeed.b/riffrandm.b/riffcount.b/riffstats.b)
 	.long	0		;(riffadres.l)
;5
 	.long	0		;(riffsteps.w
 	.long	tfmx_Synthfield1-tfmx_Synthfield0	;(channadd.l)
 	.long	0xdff0a0				;(audioadr.l)
 	.long	0		;(mabadd.l)
;6
 	.long	4		;(ims_doffs.l)
 	.long	0		;(ims_sstart.l)
 	.long	0,0		;(ims_slen.w/ims_dlen.w)
 	.long	0		;(ims_mod1.l)
;7
 	.long	0,0		;(ims_mod1len.w/ims_mod1len2.w)
 	.long	0,0		;(ims_mod1add.w/ims_delta.w)
 	.long	0		;(ims_mod2.l)
 	.long	0,0		;(ims_flen1.w/ims_flen2.w)
;8
 	.long	0,0		;(ims_fspeed.w/ims_mod2add.w)
 	.long	0,0		;(ims_mod2len.w/ims_mod2len2.w)
 	.long	0		;(fxnote.l)
	.long	0		;(period.w)
	.byte	0xff,0	; nwait.b, mskipflag, ims_Dolby.b
	.byte	0		; ---alignement
;9
	.long	0		;(dmaconadr.l)
	.long	0		;(set_v7voice.l)
;

tfmx_Synthfield1:
 	.long	0		;(mstatus.b/modstatus.b/offdma.b/mabcount1.b)
 	.long	0,0		;(last+basenote.w/irwait.w)
 	.long	0,0		;(basevol/detunes)
 	.long	0		;(macroadress)
 	.long	0,0		;(mstep/mawait)
 	.long	0x8202,0x0002	;dmabits(on/off)
 	.long	0		;(volume.b/oldvol.b/mloopcount.b/mabcount2.b)
 	.long	0		;(envelope.b/envcount.b/envolume.b/envspeed.b)
 	.long	0		;(vibrate/vibcount/pospeed/pocount)
 	.long	0		;(vibperiod)
	.byte	0,0,0,0	; (vibsize1/vibsize2/ + 2 bytes alignement)
 	.long	0,0		;(baseperiod/beginadd)
 	.long	0		;(sbegin.l)
 	.long	0,0		;(potime.w/poperiod.w)
 	.long	0		;(samplen.w)
	.byte	0,0		;(keyflag.b/riffAND.b)
	.byte	0,0		;(priority.b/priority2.b)
 	.long	0		;(msubadr.l)
 	.long	0		;(priocount.w) !CLR by alloff
 	.long	0		;(msubstep.w
	.byte	0,0		;(oldfx.b/ims_delatold.b)
	.byte	0,0		;(riffmacro.b/rifftrigg.b)
	.long	0x8100	;irqbits(on)
	.long	0x0100	;irqbits(off)
	.long	0
 	.byte	0,0,0,0	;(riffspeed.b/riffrandm.b/riffcount.b/riffstats.b)
 	.long	0		;(riffadres.l)
 	.long	0		;(riffsteps.w
 	.long	tfmx_Synthfield2-tfmx_Synthfield1	;(channadd.l)
 	.long	0xdff0b0				;(audioadr.l)
 	.long	0		;(mabadd.l)
	.long	0x104	;(ims_doffs.l)
 	.long	0		;(ims_sstart.l)
 	.long	0,0		;(ims_slen.w/ims_dlen.w)
 	.long	0		;(ims_mod1.l)
 	.long	0,0		;(ims_mod1len.w/ims_mod1len2.w)
 	.long	0,0		;(ims_mod1add.w/ims_delta.w)
 	.long	0		;(ims_mod2.l)
 	.long	0,0		;(ims_flen1.w/ims_flen2.w)
 	.long	0,0		;(ims_fspeed.w/ims_mod2add.w)
 	.long	0,0		;(ims_mod2len.w/ims_mod2len2.w)
 	.long	0		;(fxnote.l)
	.long	0		;(period.w)
	.byte	0xff,0	; nwait.b, mskipflag, ims_Dolby.b
	.byte	0		; ---alignement
	.long	0		;(dmaconadr.l)
	.long	0		;(set_v7voice.l)

tfmx_Synthfield2:
 	.long	0		;(mstatus.b/modstatus.b/offdma.b/mabcount1.b)
 	.long	0,0		;(last+basenote.w/irwait.w)
 	.long	0,0		;(basevol/detunes)
 	.long	0		;(macroadress)
 	.long	0,0		;(mstep/mawait)
 	.long	0x8204,0x0004	;dmabits(on/off)
 	.long	0		;(volume.b/oldvol.b/mloopcount.b/mabcount2.b)
 	.long	0		;(envelope.b/envcount.b/envolume.b/envspeed.b)
 	.long	0		;(vibrate/vibcount/pospeed/pocount)
 	.long	0		;(vibperiod)
	.byte	0,0,0,0	; (vibsize1/vibsize2/ + 2 bytes alignement)
 	.long	0,0		;(baseperiod/beginadd)
 	.long	0		;(sbegin.l)
 	.long	0,0		;(potime.w/poperiod.w)
 	.long	0		;(samplen.w)
	.byte	0,0		;(keyflag.b/riffAND.b)
	.byte	0,0		;(priority.b/priority2.b)
 	.long	0		;(msubadr.l)
 	.long	0		;(priocount.w) !CLR by alloff
 	.long	0		;(msubstep.w
	.byte	0,0		;(oldfx.b/ims_delatold.b)
	.byte	0,0		;(riffmacro.b/rifftrigg.b)
	.long	0x8200	;irqbits(on)
	.long	0x0200	;irqbits(off)
	.long	0
 	.byte	0,0,0,0	;(riffspeed.b/riffrandm.b/riffcount.b/riffstats.b)
 	.long	0		;(riffadres.l)
 	.long	0		;(riffsteps.w
 	.long	tfmx_Synthfield3-tfmx_Synthfield2	;(channadd.l)
 	.long	0xdff0c0				;(audioadr.l)
 	.long	0		;(mabadd.l)
	.long	0x204	;(ims_doffs.l)
 	.long	0		;(ims_sstart.l)
 	.long	0,0		;(ims_slen.w/ims_dlen.w)
 	.long	0		;(ims_mod1.l)
 	.long	0,0		;(ims_mod1len.w/ims_mod1len2.w)
 	.long	0,0		;(ims_mod1add.w/ims_delta.w)
 	.long	0		;(ims_mod2.l)
 	.long	0,0		;(ims_flen1.w/ims_flen2.w)
 	.long	0,0		;(ims_fspeed.w/ims_mod2add.w)
 	.long	0,0		;(ims_mod2len.w/ims_mod2len2.w)
 	.long	0		;(fxnote.l)
	.long	0		;(period.w)
	.byte	0xff,0	; nwait.b, mskipflag, ims_Dolby.b
	.byte	0		; ---alignement
	.long	0		;(dmaconadr.l)
	.long	0		;(set_v7voice.l)

tfmx_Synthfield3:
 	.long	0		;(mstatus.b/modstatus.b/offdma.b/mabcount1.b)
 	.long	0,0		;(last+basenote.w/irwait.w)
 	.long	0,0		;(basevol/detunes)
 	.long	0		;(macroadress)
 	.long	0,0		;(mstep/mawait)
 	.long	0x8208,0x0008	;dmabits(on/off)
 	.long	0		;(volume.b/oldvol.b/mloopcount.b/mabcount2.b)
 	.long	0		;(envelope.b/envcount.b/envolume.b/envspeed.b)
 	.long	0		;(vibrate/vibcount/pospeed/pocount)
 	.long	0		;(vibperiod)
	.byte	0,0,0,0	; (vibsize1/vibsize2/ + 2 bytes alignement)
 	.long	0,0		;(baseperiod/beginadd)
 	.long	0		;(sbegin.l)
 	.long	0,0		;(potime.w/poperiod.w)
 	.long	0		;(samplen.w)
	.byte	0,0		;(keyflag.b/riffAND.b)
	.byte	0,0		;(priority.b/priority2.b)
 	.long	0		;(msubadr.l)
 	.long	0		;(priocount.w) !CLR by alloff
 	.long	0		;(msubstep.w
	.byte	0,0		;(oldfx.b/ims_delatold.b)
	.byte	0,0		;(riffmacro.b/rifftrigg.b)
	.long	0x8400	;irqbits(on)
	.long	0x0400	;irqbits(off)
	.long	0
 	.byte	0,0,0,0	;(riffspeed.b/riffrandm.b/riffcount.b/riffstats.b)
 	.long	0		;(riffadres.l)
 	.long	0		;(riffsteps.w
 	.long	-(tfmx_Synthfield3-tfmx_Synthfield0)	;(channadd.l)
 	.long	0xdff0d0				;(audioadr.l)
 	.long	0		;(mabadd.l)
	.long	0x204	;(ims_doffs.l)
 	.long	0		;(ims_sstart.l)
 	.long	0,0		;(ims_slen.w/ims_dlen.w)
 	.long	0		;(ims_mod1.l)
 	.long	0,0		;(ims_mod1len.w/ims_mod1len2.w)
 	.long	0,0		;(ims_mod1add.w/ims_delta.w)
 	.long	0		;(ims_mod2.l)
 	.long	0,0		;(ims_flen1.w/ims_flen2.w)
 	.long	0,0		;(ims_fspeed.w/ims_mod2add.w)
 	.long	0,0		;(ims_mod2len.w/ims_mod2len2.w)
 	.long	0		;(fxnote.l)
	.long	0		;(period.w)
	.byte	0xff,0	; nwait.b, mskipflag, ims_Dolby.b
	.byte	0		; ---alignement
	.long	0		;(dmaconadr.l)
	.long	0		;(set_v7voice.l)

tfmx_Synthfield4:
 	.long	0		;(mstatus.b/modstatus.b/offdma.b/mabcount1.b)
 	.long	0,0		;(last+basenote.w/irwait.w)
 	.long	0,0		;(basevol/detunes)
 	.long	0		;(macroadress)
 	.long	0,0		;(mstep/mawait)
 	.long	0x0000,0x0000	;dmabits(on/off)
 	.long	0x40000000		;(volume.b/oldvol.b/mloopcount.b/mabcount2.b)
 	.long	0		;(envelope.b/envcount.b/envolume.b/envspeed.b)
 	.long	0		;(vibrate/vibcount/pospeed/pocount)
 	.long	0		;(vibperiod)
	.byte	0,0,0,0	; (vibsize1/vibsize2/ + 2 bytes alignement)
 	.long	0,0		;(baseperiod/beginadd)
 	.long	0		;(sbegin.l)
 	.long	0,0		;(potime.w/poperiod.w)
 	.long	0		;(samplen.w)
	.byte	0,0		;(keyflag.b/riffAND.b)
	.byte	0,0		;(priority.b/priority2.b)
 	.long	0		;(msubadr.l)
 	.long	0		;(priocount.w) !CLR by alloff
 	.long	0		;(msubstep.w
	.byte	0,0		;(oldfx.b/ims_delatold.b)
	.byte	0,0		;(riffmacro.b/rifftrigg.b)
	.long	0x0000	;irqbits(on)
	.long	0x0000	;irqbits(off)
	.long	0
 	.byte	0,0,0,0	;(riffspeed.b/riffrandm.b/riffcount.b/riffstats.b)
 	.long	0		;(riffadres.l)
 	.long	0		;(riffsteps.w
 	.long	tfmx_Synthfield5-tfmx_Synthfield4	;(channadd.l)
 	.long	0xdff0d0				;(audioadr.l)
 	.long	0		;(mabadd.l)
	.long	0x404	;(ims_doffs.l)
 	.long	0		;(ims_sstart.l)
 	.long	0,0		;(ims_slen.w/ims_dlen.w)
 	.long	0		;(ims_mod1.l)
 	.long	0,0		;(ims_mod1len.w/ims_mod1len2.w)
 	.long	0,0		;(ims_mod1add.w/ims_delta.w)
 	.long	0		;(ims_mod2.l)
 	.long	0,0		;(ims_flen1.w/ims_flen2.w)
 	.long	0,0		;(ims_fspeed.w/ims_mod2add.w)
 	.long	0,0		;(ims_mod2len.w/ims_mod2len2.w)
 	.long	0		;(fxnote.l)
	.long	0		;(period.w)
	.byte	0xff,0	; nwait.b, mskipflag, ims_Dolby.b
	.byte	0		; ---alignement
	.long	0		;(dmaconadr.l)
	.long	0		;(set_v7voice.l)

tfmx_Synthfield5:
 	.long	0		;(mstatus.b/modstatus.b/offdma.b/mabcount1.b)
 	.long	0,0		;(last+basenote.w/irwait.w)
 	.long	0,0		;(basevol/detunes)
 	.long	0		;(macroadress)
 	.long	0,0		;(mstep/mawait)
 	.long	0x0000,0x0000	;dmabits(on/off)
 	.long	0x40000000		;(volume.b/oldvol.b/mloopcount.b/mabcount2.b)
 	.long	0		;(envelope.b/envcount.b/envolume.b/envspeed.b)
 	.long	0		;(vibrate/vibcount/pospeed/pocount)
 	.long	0		;(vibperiod)
	.byte	0,0,0,0	; (vibsize1/vibsize2/ + 2 bytes alignement)
 	.long	0,0		;(baseperiod/beginadd)
 	.long	0		;(sbegin.l)
 	.long	0,0		;(potime.w/poperiod.w)
 	.long	0		;(samplen.w)
	.byte	0,0		;(keyflag.b/riffAND.b)
	.byte	0,0		;(priority.b/priority2.b)
 	.long	0		;(msubadr.l)
 	.long	0		;(priocount.w) !CLR by alloff
 	.long	0		;(msubstep.w
	.byte	0,0		;(oldfx.b/ims_delatold.b)
	.byte	0,0		;(riffmacro.b/rifftrigg.b)
	.long	0x0000	;irqbits(on)
	.long	0x0000	;irqbits(off)
	.long	0
 	.byte	0,0,0,0	;(riffspeed.b/riffrandm.b/riffcount.b/riffstats.b)
 	.long	0		;(riffadres.l)
 	.long	0		;(riffsteps.w
 	.long	tfmx_Synthfield6-tfmx_Synthfield5	;(channadd.l)
 	.long	0xdff0d0				;(audioadr.l)
 	.long	0		;(mabadd.l)
	.long	0x504	;(ims_doffs.l)
 	.long	0		;(ims_sstart.l)
 	.long	0,0		;(ims_slen.w/ims_dlen.w)
 	.long	0		;(ims_mod1.l)
 	.long	0,0		;(ims_mod1len.w/ims_mod1len2.w)
 	.long	0,0		;(ims_mod1add.w/ims_delta.w)
 	.long	0		;(ims_mod2.l)
 	.long	0,0		;(ims_flen1.w/ims_flen2.w)
 	.long	0,0		;(ims_fspeed.w/ims_mod2add.w)
 	.long	0,0		;(ims_mod2len.w/ims_mod2len2.w)
 	.long	0		;(fxnote.l)
	.long	0		;(period.w)
	.byte	0xff,0	; nwait.b, mskipflag, ims_Dolby.b
	.byte	0		; ---alignement
	.long	0		;(dmaconadr.l)
	.long	0		;(set_v7voice.l)

tfmx_Synthfield6:
 	.long	0		;(mstatus.b/modstatus.b/offdma.b/mabcount1.b)
 	.long	0,0		;(last+basenote.w/irwait.w)
 	.long	0,0		;(basevol/detunes)
 	.long	0		;(macroadress)
 	.long	0,0		;(mstep/mawait)
 	.long	0x0000,0x0000	;dmabits(on/off)
 	.long	0x40000000		;(volume.b/oldvol.b/mloopcount.b/mabcount2.b)
 	.long	0		;(envelope.b/envcount.b/envolume.b/envspeed.b)
 	.long	0		;(vibrate/vibcount/pospeed/pocount)
 	.long	0		;(vibperiod)
	.byte	0,0,0,0	; (vibsize1/vibsize2/ + 2 bytes alignement)
 	.long	0,0		;(baseperiod/beginadd)
 	.long	0		;(sbegin.l)
 	.long	0,0		;(potime.w/poperiod.w)
 	.long	0		;(samplen.w)
	.byte	0,0		;(keyflag.b/riffAND.b)
	.byte	0,0		;(priority.b/priority2.b)
 	.long	0		;(msubadr.l)
 	.long	0		;(priocount.w) !CLR by alloff
 	.long	0		;(msubstep.w
	.byte	0,0		;(oldfx.b/ims_delatold.b)
	.byte	0,0		;(riffmacro.b/rifftrigg.b)
	.long	0x0000	;irqbits(on)
	.long	0x0000	;irqbits(off)
	.long	0
 	.byte	0,0,0,0	;(riffspeed.b/riffrandm.b/riffcount.b/riffstats.b)
 	.long	0		;(riffadres.l)
 	.long	0		;(riffsteps.w
 	.long	tfmx_Synthfield7-tfmx_Synthfield6	;(channadd.l)
 	.long	0xdff0d0				;(audioadr.l)
 	.long	0		;(mabadd.l)
	.long	0x604	;(ims_doffs.l)
 	.long	0		;(ims_sstart.l)
 	.long	0,0		;(ims_slen.w/ims_dlen.w)
 	.long	0		;(ims_mod1.l)
 	.long	0,0		;(ims_mod1len.w/ims_mod1len2.w)
 	.long	0,0		;(ims_mod1add.w/ims_delta.w)
 	.long	0		;(ims_mod2.l)
 	.long	0,0		;(ims_flen1.w/ims_flen2.w)
 	.long	0,0		;(ims_fspeed.w/ims_mod2add.w)
 	.long	0,0		;(ims_mod2len.w/ims_mod2len2.w)
 	.long	0		;(fxnote.l)
	.long	0		;(period.w)
	.byte	0xff,0	; nwait.b, mskipflag, ims_Dolby.b
	.byte	0		; ---alignement
	.long	0		;(dmaconadr.l)
	.long	0		;(set_v7voice.l)

tfmx_Synthfield7:
 	.long	0		;(mstatus.b/modstatus.b/offdma.b/mabcount1.b)
 	.long	0,0		;(last+basenote.w/irwait.w)
 	.long	0,0		;(basevol/detunes)
 	.long	0		;(macroadress)
 	.long	0,0		;(mstep/mawait)
 	.long	0x0000,0x0000	;dmabits(on/off)
 	.long	0x40000000		;(volume.b/oldvol.b/mloopcount.b/mabcount2.b)
 	.long	0		;(envelope.b/envcount.b/envolume.b/envspeed.b)
 	.long	0		;(vibrate/vibcount/pospeed/pocount)
 	.long	0		;(vibperiod)
	.byte	0,0,0,0	; (vibsize1/vibsize2/ + 2 bytes alignement)
 	.long	0,0		;(baseperiod/beginadd)
 	.long	0		;(sbegin.l)
 	.long	0,0		;(potime.w/poperiod.w)
 	.long	0		;(samplen.w)
	.byte	0,0		;(keyflag.b/riffAND.b)
	.byte	0,0		;(priority.b/priority2.b)
 	.long	0		;(msubadr.l)
 	.long	0		;(priocount.w) !CLR by alloff
 	.long	0		;(msubstep.w
	.byte	0,0		;(oldfx.b/ims_delatold.b)
	.byte	0,0		;(riffmacro.b/rifftrigg.b)
	.long	0x0000	;irqbits(on)
	.long	0x0000	;irqbits(off)
	.long	0
 	.byte	0,0,0,0	;(riffspeed.b/riffrandm.b/riffcount.b/riffstats.b)
 	.long	0		;(riffadres.l)
 	.long	0		;(riffsteps.w
 	.long	-(tfmx_Synthfield7-tfmx_Synthfield4)	;(channadd.l)
 	.long	0xdff0d0				;(audioadr.l)
 	.long	0		;(mabadd.l)
	.long	0x704	;(ims_doffs.l)
 	.long	0		;(ims_sstart.l)
 	.long	0,0		;(ims_slen.w/ims_dlen.w)
 	.long	0		;(ims_mod1.l)
 	.long	0,0		;(ims_mod1len.w/ims_mod1len2.w)
 	.long	0,0		;(ims_mod1add.w/ims_delta.w)
 	.long	0		;(ims_mod2.l)
 	.long	0,0		;(ims_flen1.w/ims_flen2.w)
 	.long	0,0		;(ims_fspeed.w/ims_mod2add.w)
 	.long	0,0		;(ims_mod2len.w/ims_mod2len2.w)
 	.long	0		;(fxnote.l)
	.long	0		;(period.w)
	.byte	0xff,0	; nwait.b, mskipflag, ims_Dolby.b
	.byte	0		; ---alignement
	.long	0		;(dmaconadr.l)
	.long	0		;(set_v7voice.l)

	
tfmx_PatternDataBlock:										; CHfield2
;	offsets	for CHfield2/PatternDataBlock (sequencer)
.equ tfmx_offset_PatternDataBlock_fstep,		0	;.w=>.l
.equ tfmx_offset_PatternDataBlock_lstep,		4	;.w=>.l
.equ tfmx_offset_PatternDataBlock_cstep,		8	;.w=>.l
.equ tfmx_offset_PatternDataBlock_speed,		12	;.w=>.l
.equ tfmx_offset_PatternDataBlock_muteflags,	16	;8*.w+8*.w
.equ tfmx_offset_PatternDataBlock_padress,		80	;8*.l
.equ tfmx_offset_PatternDataBlock_patterns,		112	;8*.w
.equ tfmx_offset_PatternDataBlock_ploopcount,	144	;8*.b
									;
.equ tfmx_offset_PatternDataBlock_pstep,		176	;8*.w
.equ tfmx_offset_PatternDataBlock_pawait,		208	;8*.b
									; 
.equ tfmx_offset_PatternDataBlock_psubadr,		240	;8*.l
.equ tfmx_offset_PatternDataBlock_psubstep,		272	;8*.l
												; fin=304

tfmx_FirstUsed:
; 0
	.long	0			;fstep .w	
tfmx_LastUsed:
; 4
 	.long	0			;lstep .w
tfmx_CurrentPos:
; 8
 	.long	0			;cstep .w
tfmx_ActualSpeed:
; 12
 	.long	6			;speed .w
; 16
	.long	0,0,0,0,0,0,0,0	; passage en .long / ex (trackmutes.w//pstep.w)
	.long	0,0,0,0,0,0,0,0
; 16+32+32=80
 	.long	0,0,0,0,0,0,0,0 ;(patternadress.l)
; 80+32=112
 	.long	0,0,0,0,0,0,0,0 ; passage en .long  patterns.l / ex (patterns.w/ploopcount.b/)
	.long	0,0,0,0,0,0,0,0 ; ploopcount.l
; 112+32+32=176
 	.long	0,0,0,0,0,0,0,0 ; pstep.l        (pstep.w/pawait.b/) !Cleared by newtrack
	.long	0,0,0,0,0,0,0,0 ; pawait.l
; 176+32+32=240
 	.long	0,0,0,0,0,0,0,0	;(psubadr.l)
; 240+32=272
 	.long	0,0,0,0,0,0,0,0	;(psubstep.w/)
; ***
tfmx_songcont:
tfmx_PatternDataBlock_contstep:
 	.skip	32*4	;contstep / .w
tfmx_PatternDataBlock_songspeed:
;128
 	.skip	32*4	;songspeed / .w
tfmx_PatternDataBlock_timerspeed:
;256
 	.skip	32*4	;timerspeed / .w

; offsets for infodat
.equ tfmx_offset_info_fade,		0
.equ tfmx_offset_info_error,	4
.equ tfmx_offset_info_ch0,		8
.equ tfmx_offset_info_ch1,		12
.equ tfmx_offset_info_ch2,		16
.equ tfmx_offset_info_uvbi,		20
.equ tfmx_offset_info_cliout,	24
.equ tfmx_offset_info_seqrun,	28
.equ tfmx_offset_info_rec,		32
.equ tfmx_offset_info_midi,		36
.equ tfmx_offset_info_flags,	40
; ***

infodat:
 	.long	0	;fadeend					0
 	.long	0	;errorflag					4
 	.long	0	;adress CHfield0			8
 	.long	0	;adress CHfield1			12
 	.long	0	;adress CHfield2			16
 	.long	0	;adress pointer to uservbi	20
 	.long	0	;cliout flag				24
 	.long	0	;sequencer running			28
 	.long	0	;adress recfield			32
 	.long	0	;adress midifield			36
 	.long	0,0,0,0 ;Programmer flags       40-56  (set by macrostatment $20
		;				or patternstatment $fd !)

emptypatt:
	.long		0xf4000000,0xf0000000

;		Note-table v1.0
;	dc.w 3420,3228,3048,2876,2714,2562,2418,2282,2154,2034,1920,1816
tfmx_nottab:
	.long	1710,1614,1524,1438,1357,1281,1209,1141,1077,1017, 960, 908
	.long	856, 810, 764, 720, 680, 642, 606, 571, 539, 509, 480, 454
	.long	428, 404, 381, 360, 340, 320, 303, 286, 270, 254, 240, 227
	.long	214, 202, 191, 180, 170, 160, 151, 143, 135, 127, 120, 113
	.long	214, 202, 191, 180, 170, 160, 151, 143, 135, 127, 120, 113
	.long	214, 202, 191, 180

tfmx_v7contab:		.skip		4*256
tfmx_v7voltab:		.skip		64*256
tfmx_Header:		.skip		248*2
tfmx_buffer_musique:			.skip		tfmx_maxbyts

mdat:		.incbin		"T2_intro_and_title.mdat"
		.p2align	2
smpl:		.incbin		"T2_intro_and_title.smpl"
		.p2align	2

