����                                        ;               T

npc_left	equ	-32767
npc_right	equ	32767

npc_nextchan	equ	$00	* long
npc_modified	equ	$0B	* byte
npc_chanpos	equ	$0C	* word
npc_sampleptr	equ	$10	* long
npc_samplelen	equ	$14	* word
npc_srepeatptr	equ	$18	* long
npc_srepeatlen	equ	$1c	* word
npc_period	equ	$20	* word
npc_volume	equ	$24	* word (max = 64)

npc_structsize	equ	64

npc_sampleptr_modified	equ	$02
npc_repeatptr_modified	equ	$04
npc_period_modified	equ	$08
npc_volume_modified	equ	$10
