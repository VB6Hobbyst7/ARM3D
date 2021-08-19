; ------------------------------------------------------------------
;
; code principal de l'interruption FIQ
;
; calé entre 0x18 et 0x58
;
; ------------------------------------------------------------------

; valeurs fixes RMA
.equ	vsyncreturn,	7142						; 7142 vsyncreturn=7168+16-1-48   +   vsyncreturn+=7
.equ	vsyncreturn_low,		(vsyncreturn & 0x00FF)>>0
.equ	vsyncreturn_high,		((vsyncreturn & 0xFF00)>>8)

.equ	vsyncreturn_ligne199,			7142+(197*128)+127-64						; vsyncreturn=7168+16-1-48   +   vsyncreturn+=7
.equ	vsyncreturn_low_ligne199,		(vsyncreturn_ligne199 & 0x00FF)>>0
.equ	vsyncreturn_high_ligne199,		((vsyncreturn_ligne199 & 0xFF00)>>8)

	.org	0x18

FIQ_startofcode:
; IRQ arriven 0x18, on force le mode FIRQ pour récuperer les registres donc tout tourne en mode FIRQ
			TEQP      PC,#0x0C000001					; 1 18: %11<<26 OR %01			  ; keep IRQs and FIQs off, change to FIQ mode : irq et fiq OFF (status register dans le PC) + FIQ mode activé
			MOV       R0,R0               				; 2 1C: nop to sync FIQ registers

; FIQ registers
;
;R8 = tmp
;R9 = tmp
;R10 = tmp ( obligatoire pour routine keyboard )
;R11 = 
;R12 = destination couleur 0 = 0x3400000 
;R13 = table_couleur0_vstart_vend : table source : couleur 0, vstart, vend, pour chaque ligne
;R14 = 0x3200000	- utilisation permanente

; ré-orgzaniser, utiliser 
; R8 = tmp
; R9 = tmp / destination couleur 0 = 0x3400000
; R10 = 0x3200000	- utilisation permanente
; R11 = table_couleur0_vstart_vend : table source : couleur 0, vstart, vend, pour chaque ligne
; R12 =  
; R13 = 
; R14 = 

			str		  R8,save_R8							; 3 20
			mov		  R8,#FIQ_tempstack						; 4 24
			STMIA     R8,{R9-R11}							; 5 28
			
			MOV		  R10,#0x3200000         				; 6 2C set R10 to IOC address
			LDRB      R8,[R10,#0x14+0]       				; 7 30 IOC : load irq_A triggers ***BUG to v0.13*** v0.14 read &14+0 was reading status at &10, which ignores IRQ mask!!!
			TST       R8,#0b01000000        				; 8 34 bit 3 = Vsync, bit 6 = T1 trigger (HSync)			
; on saute en VSYNC
			LDREQ     PC,FIQ_notHSync						; 9 38			; FIQ_notHSync 	    ; 5 28 *v0.14 if not T1, then go to VSync/Keyboard code*

			STRB        R8,[R10,#0x14+2]       				; 10 3C  IOC :  (v0.14 moved past branch) clear all interrupt triggers

; les modifs MEMC et VIDC vont ici	
			ldr			R11,pointeur_table_valeurs_reflet	; 11  40
			ldr			R8,[R11],#4							; 12  48   couleur 0
			mov			R9,#0x3400000						; 13  4C
; R12 = destination couleur 0 = 0x3400000 
			str			R8,[R9]								; 14  48   met la couleur 0

			ldmia		R11!,{r8-r9}						; 15 48
; modif de vstart
			str			R8,[R8]					; vstart	; 16 4C
; modif de vend
			str			R9,[R9]					; vend		; 17 50
			
			str			R11,pointeur_table_valeurs_reflet	; 18 
			
			STRB      R10,[R10,#0x28+2]       				; 19 54 *v0.14* set IRQB mask to %00000000 = no STx, SRx IRQs now
			ldr		  R8,position_ligne_hsync 				; 20 58  nb lignes restantes avant fin d ecran
			SUBS      R8,R8,#1				  				; 21 5C  -1
			str		  R8,position_ligne_hsync				; 22 60  
; si nb_ligne > 0				
			BGT		  fin_hsync								; 23 64
; nb lignes restantes = 0 , relancer vsyncreturn
; only get here (EQ) if at last line on screen

			MOV       R8,#0b00001000 	      				; 24 68
			STRB      R8,[R10,#0x18+2]          			; 25 6C    set IRQA mask to %00001000 = VSync only n/r unless likely to do <256?

			MOV       R8,#vsyncreturn_low_ligne199			; 26 70 (vsyncreturn AND &00FF)>>0		;32 94   or ldr r8,vsyncvalue
			STRB      R8,[R10,#0x50+2]           			; 27 74 T1 low byte, +2 for write
			MOV       R8,#vsyncreturn_high_ligne199			; 28 78				; (vsyncreturn AND &FF00)>>8;34 9C   or mov r8,r8,lsr#8
			STRB      R8,[R10,#0x54+2]           		 	; 29 7C T1 high byte, +2 for write
			STRB      R8,[R10,#0x58+2]           			; 30 80 T1_go = reset T1

; FIQ_exitcode:
fin_hsync:		
			nop												; 31 88

			TEQP      PC,#0x0C000002						; 32 8C %000011<<26 OR %10 ;27 80 back to IRQ mode, maintain 'GT', Z clear
			MOV       R0,R0                 				; 33 90 sync IRQ registers
			SUBS      PC,R14,#4             				; 34 94 return to foreground


			nop												;35 9C
			nop												;36 A0
			nop												;37 A4
			nop												;38 A8
			nop												;39 AC


.long      0                      			;40 &B4 n/r
.long      0                      			;41 &B8 n/r
.long      0                      			;42 &BC n/r

FIQ_notHSync:                    ;*NEED TO ADJUST REF. IN swi_install IF THIS MOVES FROM &C0*
.long      0x1234                    	    ;43 &C0 pointer to notHSync ***quad aligned***

valeur_vstart:
.long      0x3620000              			;44 &C4 n/r
valeur_vend:
.long      0x3640000              			;45 &C8 n/r
.long      0                      			;46 &CC n/r


FIQ_tempstack:
.long      0x1234                 ;47 &D0  ***quad aligned***		R9
.long      0                      ;48 &D4 							R10
.long      0                      ;49 &D8 							R11
save_R8:
.long      0                      ;50 &DC 							R8
.long      0                      ;51 &E0 n/r							
.long      0                      ;52 &E4 n/r							
.long      0                      ;53 &E8 n/r							
position_ligne_hsync:
.long      0                      ;54 &EC n/r
pointeur_table_valeurs_reflet:
.long      0                      ;55 &F0 n/r
.long      0                      ;56 &F4 n/r
.long      0                      ;57 &F8 n/r

.byte      "rSTm"                 ;58 &FC

FIQ_endofcode:

; ----------- fin du .org