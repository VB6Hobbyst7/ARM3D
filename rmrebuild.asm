;
; template avec rasterman integré
;
; - Vsync
; 128-1 avant première ligne
; 128-1 par ligne * 256 lignes
; 7142 avant Vsync

; - 200 lignes : 200*128 - 1


.equ Screen_Mode, 97
.equ	IKey_Escape, 0x9d

; valeurs fixes RMA
.equ	ylines,			256
.equ	vsyncreturn,	7142						; vsyncreturn=7168+16-1-48   +   vsyncreturn+=7
.equ	vsyncreturn_low,		(vsyncreturn & 0x00FF)>>0
.equ	vsyncreturn_high,		((vsyncreturn & 0xFF00)>>8)

.equ	hsyncline,		128-1			; 127
.equ	hsyncline_low,			((hsyncline & 0x00FF)>>0)
.equ	hsyncline_high,			((hsyncline & 0xFF00)>>8)

.equ	position_ligne_hsync,	 	0xE4
.equ	saveR14_firq,				0xE0

.include "swis.h.asm"
	.org 0x8000
	
main:

;"XOS_ServiceCall"

;OS_SWINumberFromString 
;	ldr		R1,pointeur_XOS_ServiceCall

;	SWI 0x39



	mov		R0,#11			; OS_Module 11 : Insert module from memory and move into RMA
	ldr		R1,pointeur_module97
	SWI		0x1E
	
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

	; 416*258 * 2 ecrans
	SUBS r1, r2, r1
	SWI OS_ChangeDynamicArea
	
; taille dynamic area screen = 416*258*2

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
;	bne		.clsall
	
	ldr		r3,couleur2
	mov		r0,#26832/2
.clsall2:
	str		r3,[r1],#4
	str		r3,[r2],#4
	subs	r0,r0,#1
;	bne		.clsall2

	SWI		22
	MOVNV R0,R0            


	bl		RM_init

	bl		RM_start
	
	mov		R8,#0x1234
	
boucle:

	bl		RM_wait_VBL

; ici il faut tester une touche



	bl      RM_scankeyboard
	cmp		R0,#0x5F
	bne		boucle

	

exit:
	;bl		RM_wait_VBL
	;bl      RM_scankeyboard
	str		R8,toucheclavier

	bl		RM_wait_VBL
;-----------------------
;sortie
;-----------------------

	bl	RM_release


	

	MOV r0,#22	;Set MODE
	SWI OS_WriteC
	MOV r0,#12
	SWI OS_WriteC

	
	
	MOV R0,#0
	SWI OS_Exit
toucheclavier:		.long 0

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

RM_start:
	str		lr,save_lr
; appel XOS car si appel OS_SWI si erreur, ça sort directement
	MOV		R0,#0x0C           ;claim FIQ
	SWI		XOS_ServiceCall
	bvs		exit


; we own FIQs


	TEQP	PC,#0xC000001
;	TEQP	PC,#0b11<<26 OR 0b01			;disable IRQs and FIQs, change to FIQ mode
	MOV		R0,R0

	ADR       R0,fiqoriginal				; sauvegarde de R8-R14
	STMIA     R0,{R8-R14}

	MOV       R1,#0x3200000
	LDRB      R0,[R1,#0x18]
	STR       R0,oldIRQa
	LDRB      R0,[R1,#0x28]
	STR       R0,oldIRQb

; When installing, we will start on the next VSync, so set IRQ for VSync only
; and set T1 to contain 'vsyncvalue', so everything in place for VSync int...

	MOV       R0,#0b00001000
	STRB      R0,[R1,#0x18+2]    ;set IRQA mask to %00001000 = VSync only
	MOV       R0,#0
	STRB      R0,[R1,#0x28+2]    ;set IRQB mask to 0
	STRB      R0,[R1,#0x38+2]    ;set FIQ mask to 0 (disable FIQs)

	MOV       R0,#0xFF           ;*v0.14* set max T1 - ensure T1 doesn't trigger before first VSync!
	STRB      R0,[R1,#0x50+2]    ;T1 low byte, +2 for write
	STRB      R0,[R1,#0x54+2]    ;T1 high byte, +2 for write
	STRB      R1,[R1,#0x58+2]    ;T1_go = reset T1

	MOV       R0,#vsyncreturn_low			;or ldr r8,vsyncval  - will reload with this on VSync...
	STRB      R0,[R1,#0x50+2]    				;T1 low byte, +2 for write
	MOV       R0,#vsyncreturn_high			;or mov r8,r8,lsr#8
	STRB      R0,[R1,#0x54+2]   					;T1 high byte, +2 for write


; poke our IRQ/FIQ code into &1C-&FC
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

.equ 	FIQ_notHSync_valeur, 0xC0

	adr		R0,notHSync					;FNlong_adr("",0,notHSync)   ;set up VSync code after copying
	MOV     R1,#FIQ_notHSync_valeur 	;ref. works if assembling on RO3, note 'FIQ_notHSync' is 0-relative!
	STR       R0,[R1]

	MOV       R0,#0
	LDR       R1,[R0,#0x18]      ;first IRQ instruction from our code
	STR       R1,newIRQfirstinst

; sortie
	TEQP      PC,#0b11				; %00<<26 OR %11;enable IRQs and FIQs, change to user mode
	MOV       R0,R0
	
	ldr		lr,save_lr
	mov		pc,lr					;exit in USER mode and with IRQs and FIQs on


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

RM_wait_VBL:
	LDRB      R11,vsyncbyte   ;load our byte from FIQ address, if enabled
waitloop_vbl:
	LDRB      R12,vsyncbyte
	TEQ       R12,R11
	BEQ       waitloop_vbl
	MOVS      PC,R14

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

RM_clearkeybuffer:		   ;10 - temp SWI, probably not needed in future once full handler done
	MOV       R12,#0
	STRB      R12,keybyte1
	STRB      R12,keybyte2
	MOV       PC,R14      ;flags not preserved


RM_check_keyboard:
	;CMP       R13,#256            ;retrace? - this is a backup to disable STx SRx irqs, n/r
	;MOVNE     R8,#%00000000       ;           n/r once everything is working
	;STRNEB    R8,[R14,#&28+2]     ;set IRQB mask to %11000000 = STx or SRx
	;BNE       exitVScode          ;back to IRQ mode and exit

; dans la vbl, registres sauvés en debut de VBL
	;ADR       R8,kbd_stack
	;STMIA     R8,{R4-R7}          ;some regs to play with

; R14 = IOC 
	MOV       R5,#0x3200000       ; R14 to IOC address
	LDRB      R4,[R5,#0x24+0]     ;load irq_B triggers
	TST       R4,#0b10000000       ;bit 7 = SRx, cleared by a read from 04

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

	LDRB      R6,keycounter
	RSBS      R6,R6,#1            ;if =1 (NE), then this is the first byte, else (EQ)=second byte
	STRB      R6,keycounter

	LDRB      R4,[R5,#0x04+0]     ;load byte, clear SRx
	STRNEB    R4,keybyte1
	MOVNE     R6,#0b00111111       ;if first byte, reply with bACK

	STREQB    R4,keybyte2
	MOVEQ     R6,#0b00110001       ;if second byte, reply with sACK

	STRB      R6,[R5,#0x04+2] ;transmit
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

notHSync:
	TST       R8,#0b00001000       ;retest R5 is it bit 3 = Vsync? (bit 6 = T1 trigger/HSync)
	STRNEB    R14,[R14,#0x58+2]    ;if VSync, reset T1 (latch should already have the vsyncvalue...)
;
; that's the high-priority stuff done, now we can check keyboard too...
;
	BEQ       RM_check_keyboard       ;check IRQ_B for SRx/STx interrupts

	STRB      R8,[R14,#0x14+2]     ; ...and clear all IRQ_A interrupt triggers

	MOV       R8,#0b01000000       ;**removed VSync trigger v0.05
	STRB      R8,[R14,#0x18+2]     ;set IRQA mask to %01000000 = T1 only
	MOV       R8,#0b10000000       ;R8,#%11000000
	STRB      R8,[R14,#0x28+2]     ;set IRQB mask to %11000000 = STx or SRx

	MOV       R8,#hsyncline_low			; (hsyncline AND &00FF)>>0
	STRB      R8,[R14,#0x50+2]              ;T1 low byte, +2 for write
	MOV       R8,#hsyncline_high		; (hsyncline AND &FF00)>>8
	STRB      R8,[R14,#0x54+2]              ;T1 high byte, +2 for write

	LDRB      R8,vsyncbyte
	RSB       R8,R8,#3
	STRB      R8,vsyncbyte


;	ADR       R8,regtable
;	LDMIA     R8,{R9,R10,R11,R12}          ;reset table registers to defaults

; on remet le nombre de ligne a decrementer avant d'arriver à vsync
	mov			R9,#position_ligne_hsync
	mov 		R8,#ylines                  ;reset yline counter
	str			R8,[R9]
	
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




	TEQP      PC,#0x0C000002			; %000011<<26 OR %10 ;36 A4 back to IRQ mode
	MOV       R0,R0                  ;37 A8 sync IRQ registers
	SUBS      PC,R14,#4              ;38 AC return to foreground




saveR14_firq_local:	.long 0
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

; pointeurs proches	
		.p2align		4
pointeur_module97:		.long	module97
couleur:	.long	0x7f7f7f7f
couleur2:	.long	0x1e1e1e1e
screenaddr1:	.long 0
screenaddr2:	.long 0
screenaddr1_MEMC:	.long 0
screenaddr2_MEMC:	.long 0

;pointeur_XOS_ServiceCall: .long toto
;toto:
;	.byte "XOS_ServiceCall",0


	.p2align 8

; datas lointaines
		.p2align 4
module97:		.incbin	"97,ffa"




; ------------------------------------------------------------------
;
; code principal de l'interruption FIQ
;
; calé entre 0x18 et 0x58
;
; ------------------------------------------------------------------


pointeur_fiqbase:		.long	fiqbase
fiqbase:              ;copy to &18 onwards, 57 instructions max
                      ;this pointer must be relative to module

		.incbin		"build\fiqrmi.bin"


fiqend:

