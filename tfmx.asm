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
; - INITDATA : initialisation de TFMX + du module
; - 


; paramètres
.equ tfmx_maxbyts,		480+792			; extended buffer - taille du buffer passer en D2 lors des inits. - buffer pour la gestion de la musique


	.org 0x8000

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


; routine specifiques aux voies mixées
tfmx_set_v7wave1:
tfmx_set_v7wave2:
tfmx_set_v7wave3:
tfmx_set_v7wave4:
		

mdat:		.incbin		"T2_intro_and_title.mdat"
		.p2align	2
smpl:		.incbin		"T2_intro_and_title.smpl"
		.p2align	2

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
		.long		0			; startadr  : 0 (0)
		.long		0			; len		: 4 (4)
		.long		0			; period	: 8 (6)
		.long		63			; volume	: 12 (8)
tfmx_v7loopv1:
		.long		0
tfmx_v7loopd1:
		.long		0

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
tfmx_v7regstore:	.long	0
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
Synoffsets:
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


tfmx_Synoffsets:
		.skip		16*4
		

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

tfmx_buffer_musique:			.skip		maxbyts