;--------------------------------------------------------------
;--------------------------------------------------------------
;-- TT Test

;--------------------------------------------------------------
;--------------------------------------------------------------
;-- ToDo



;-- ToDo
;--------------------------------------------------------------
;--------------------------------------------------------------
;-- EQU's


useesetshift equ 0 ; Use esetshift() to change screen mode?

enableice equ 0
enablepalettefading equ 1
enablepixels equ 0
enablexa equ 0
enablehbl equ 0

enablerasters equ 1
enablemusic equ 0

TT_SCREEN_ST_LOW    equ $0000
TT_SCREEN_ST_MEDIUM equ $0100
TT_SCREEN_ST_HIGH   equ $0200
TT_SCREEN_TT_LOW    equ $0700
TT_SCREEN_TT_MEDIUM equ $0300

SCREEN_MODE equ TT_SCREEN_ST_LOW

; Calculations based on screen mode
  ifeq SCREEN_MODE-TT_SCREEN_ST_LOW
SCREEN_BITPLANES equ 4
SCREEN_WIDTH equ 320
SCREEN_HEIGHT equ 200
SCREEN_TT equ 0
  endc
  ifeq SCREEN_MODE-TT_SCREEN_ST_MEDIUM
SCREEN_BITPLANES equ 2
SCREEN_WIDTH equ 640
SCREEN_HEIGHT equ 200
SCREEN_TT equ 0
  endc
  ifeq SCREEN_MODE-TT_SCREEN_ST_HIGH
SCREEN_BITPLANES equ 1
SCREEN_WIDTH equ 640
SCREEN_HEIGHT equ 400
SCREEN_TT equ 0
  endc
  ifeq SCREEN_MODE-TT_SCREEN_TT_LOW
SCREEN_BITPLANES equ 8
SCREEN_WIDTH equ 320
SCREEN_HEIGHT equ 480
SCREEN_TT equ 1
  endc
  ifeq SCREEN_MODE-TT_SCREEN_TT_MEDIUM
SCREEN_BITPLANES equ 4
SCREEN_WIDTH equ 640
SCREEN_HEIGHT equ 480
SCREEN_TT equ 1
  endc

SCREEN_LINE_BYTES equ (SCREEN_WIDTH/8)*SCREEN_BITPLANES
SCREEN_SIZE_BYTES equ SCREEN_LINE_BYTES*SCREEN_HEIGHT


;-- EQU's
;--------------------------------------------------------------
;--------------------------------------------------------------
;-- Macros


	section text

	ifne enableice
deicelealea macro
		movem.l a0/a1,-(sp)
		lea \1,a0
		lea \2,a1
		jsr deice
		movem.l (sp)+,a0/a1
		endm
	endc


backcol macro
	move.w #$\1,currentpalette
	move.w #$\1,$ffff8240
	endm


vblwait macro
; Usage: vblwait [number of frames to wait, minimum 1]
	iflt \1-1 ; disallow values lower than 1
		fail
	endc
	pushd0
	move.l #\1-1,d0
	bsr wait4vbld0
	popd0
	endm


setpalette macro
	pusha0
	lea \1,a0
	bsr setpalettenextframe
	popa0
	endm

setttpalette macro
	pusha0
	lea \1,a0
	bsr setttpalettenextframe
	popa0
	endm


  ifne enablepalettefading 
fade2palette macro
; Usage: fade2palette [address to palette],[number of frames between steps, minimum 1]
	iflt \2-1 ; disallow values lower than 1
		fail
	endc
	movem.l a0/d0,-(sp)
	lea \1,a0
	move.l #\2-1,d0
	bsr fadepalettesaesthetic
	movem.l (sp)+,a0/d0
	endm
	endc


cleartimer macro
	move.w 0,vblwaiter
	endm

waitfortimer macro
	pushd0
	move.w #\1,d0
	bsr waitforvblwaiter
	popd0
	endm


	include _inc\pushpop.s


;-- Macros
;--------------------------------------------------------------
;--------------------------------------------------------------
;-- Setup


	bra gogogoforitgogogo
	dc.b "  Per Almered/Excellence in Art/Checkpoint 2014  "
	even
gogogoforitgogogo


; Set supervisor mode
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	add.l #6,sp
	move.l d0,oldusp

; Get physbase
	move #2,-(sp)		; get address of physical screen
	trap #14
	addq #2,sp
	move.l d0,oldphysbase

; Get old screen mode
	ifne useesetshift
	  move.w #$51,-(sp)
  	trap #14
  	add.l #2,sp
	else
		move.w $ffff8262,d0
	endc
  move.w d0,oldttscreenmode

; Set new screen mode
  move.w #TT_SCREEN_TT_LOW,d0
	ifne useesetshift
  	move.w d0,-(sp)
  	move.w #$50,-(sp)
  	trap #14
  	add.l #4,sp
	else
		move.w d0,$ffff8262
	endc

	move.w #SCREEN_TT,ttscreenmode


	move.w #0,musicinvbl

	movem.l $ffff8240,d0-d7
	movem.l d0-d7,oldstpal

  move.l #$ffff8400,a0
  lea oldttpal,a1
  move.l #256/2-1,d7
.ttpal
  move.l (a0)+,(a1)+
  dbra d7,.ttpal

	move.b $484,old484 ; save key click
	bclr #0,$484 ; kill key click

	dc.w $a00a	;hide mouse pointer
	move.b #$12,$fffffc02 ; disable mouse reporting


	move.w sr,-(sp)
	or.w #$0700,sr

	move.l	$70,oldvbl		; store old VBL
	move.l	#vbl,$70		; steal VBL

	ifne enablehbl
		move.b #0,$fffffa1b		; Switch off Timer B
		move.b #0,$fffffa09		; Disable all timers in IERB, including Timer A
		move.l $120,oldhbl		; save old hbl
		move.l	#hbl,$120			; insert own hbl
		bset #0,$fffffa07			; Enable Timer B
		bset #0,$fffffa13			; Mask Timer B to enable it
	;	move.b #50,$fffffa21	; Timer B data
	;	move.b #8,$fffffa1b		; Set Timer B to Event Count Mode

	;	or.b	#1,$fffffa07		; IERA bit 0: Timer B enabled
	;	move.b	#0,$fffffa09	; IERB: all timers disabled
	;	or.b	#1,$fffffa13		; Mask bit 0: timer b enabled
	;	move.b	#0,$fffffa1b	; timer b control empty
	;
	;	move.l $120,oldhbl
	;	move.l	#hbl,$120
	endc

	move.w (sp)+,sr

	move.l sp,startupsp


; Set caching
	movec cacr,d0
	move.w d0,oldcacr
	move.w #$101,d0
	movec d0,cacr


; Set up screens
  lea smokescreen1,a0
  move.l a0,d0
  clr.b d0
  move.l d0,screenaddress
  lea smokescreen2,a0
  move.l a0,d0
  clr.b d0
  move.l d0,smokescreenaddress


;-- Setup
;--------------------------------------------------------------
;--------------------------------------------------------------
;-- Main code


	ifne enablemusic
		bsr	MUSIC+0			; init music
		move.w #1,musicinvbl ; every vbl, music is played
	endc


	ifne 0
	setpalette stepal

  move.l #$ffff8400,a0
  move.w #$000,(a0)+
  move.w #$fff,d0
  move.l #255-1,d7
.col
  move.w d0,(a0)+
	sub.w #1,d0
  dbra d7,.col

	ifne 1
  move.l screenaddress,a0
  move.l #100,d7
.line
  move.l #SCREEN_LINE_BYTES/2-1,d6
.loop
;  move.w #%10101010,(a0)+
	move.w #$ff00,(a0)+
  dbra d6,.loop
  dbra d7,.line
	endc
	endc

	;setttpalette cat001pal

	lea cat001pal,a0
	lea test002pal,a0
	lea currentpalette,a1
	move.l #$ffff8400,a1
	move.l #256/2-1,d7
.pal
	move.l (a0)+,(a1)+
	dbra d7,.pal

	lea cat001,a0
	lea test002,a0
	move.l screenaddress,a1
	move.l #SCREEN_SIZE_BYTES/4-1,d7
.blit
	move.l (a0)+,(a1)+
	dbra d7,.blit

	move.l screenaddress,a0
	bsr clear32000

mainloop
	backcol 000
	vblwait 1
	backcol 007
	lea test002,a0
	move.l screenaddress,a1
	bsr copy32000
	bra mainloop


	backcol 000
	vblwait 115
	backcol 007
	vblwait 15
	backcol 707
	vblwait 15
  bra mainloop


;-- Main code
;--------------------------------------------------------------
;--------------------------------------------------------------


endloop
	bra endloop


;--------------------------------------------------------------
;--------------------------------------------------------------
;-- sudo shutdown -h now


exitall

	move.l startupsp,sp

	ifne enablemusic
		move.w #0,musicinvbl
		bsr	MUSIC+4			; de-init music
	endc


; Restore cache
	move.w oldcacr,d0
	movec d0,cacr


	move.w sr,-(sp)
	or.w #$0700,sr

	move.l	oldvbl,$70.w		; restore VBL

	ifne enablehbl
		move.l oldhbl,$120			; restore HBL
		move.b old07,$fffffa07
		move.b old09,$fffffa09
		move.b old13,$fffffa13
		move.b old1b,$fffffa1b
		move.b old21,$fffffa21
	endc

	move.w (sp)+,sr


; Restore TT palette
  lea oldttpal,a0
  move.l #$ffff8400,a1
  move.l #256/2-1,d7
.ttpal
  move.l (a0)+,(a1)+
  dbra d7,.ttpal

	movem.l oldstpal,d0-d7		; restore st palette
	movem.l d0-d7,$ffff8240

	move.b #$8,$fffffc02 ; restore mouse reading
	dc.w $a009 ; restore mouse pointer

	move.b old484,$484 ; restore keyclick

; Restore screen mode
	ifne useesetshift
	  move.w oldttscreenmode,-(sp)
  	move.w #$50,-(sp)
  	trap #14
  	add.l #4,sp
	else
		move.w oldttscreenmode,$ffff8262
	endc

; Restore physbase
  move.w #-1,-(sp)
  move.w #-1,-(sp)
  move.l oldphysbase,-(sp)
  move.l #-1,-(sp)
  move.w #$05,-(sp)
  trap #14
  add.l #14,sp  

; Back to user mode
  move.l oldusp,-(sp)
  move.w #$20,-(sp)
  trap #1
  addq.l #6,sp

; Exit
  clr.w -(sp)
  move.w #$4c,-(sp)
  trap #1


;-- sudo shutdown -h now
;--------------------------------------------------------------
;--------------------------------------------------------------
;-- Subroutines


copy32000
  pushall
  ; Phase 1: 32*988 = 31616, remainder: 384
  move.l #32-1,d7
numchunksize set 52
numrepts set 19
.cachestart
.loop1
	  pushd7 ; 2 bytes
offs set 0
  	rept numrepts
    	movem.l (offs,a0),d0-d7/a2-a6 ; 13 regs (52 bytes), 4 bytes
    	movem.l d0-d7/a2-a6,(offs,a1) ; 13 regs (52 bytes), 4 bytes
offs set offs+numchunksize
  	endr
    add.w #numrepts*numchunksize,a0 ; 4 bytes
    add.w #numrepts*numchunksize,a1 ; 4 bytes
  	popd7 ; 2 bytes
  dbra d7,.loop1 ; 4 bytes
.cacheend

	ifgt .cacheend-.cachestart-256
		fail CODE DOESN'T FIT IN CACHE
	endc

  ; Phase 2: 384 bytes
  move.l #384/4-1,d7
.loop2
  	move.l (a0)+,(a1)+
  dbra d7,.loop2
  popall
  rts


clear32000
  pushall
  move.l #0,d0
  move.l d0,d1
  move.l d0,d2
  move.l d0,d3
  move.l d0,d4
  move.l d0,d5
  move.l d0,d6
  move.l d0,a1
  move.l d0,a2
  move.l d0,a3
  move.l d0,a4
  move.l d0,a5
  move.l d0,a6
  ; Phase 1: 9*3360 = 30240, remainder: 1760
  move.l #9-1,d7
numchunksize set 56
numrepts set 60
.loop1
  	pushd7 ; 2 bytes
offs set 0
		move.l d0,d7
  	rept numrepts
    	movem.l d0-d7/a1-a6,(offs,a0) ; 14 regs (56 bytes), 4 bytes
offs set offs+numchunksize
  	endr
    add.w #numrepts*numchunksize,a0 ; 4 bytes
  	popd7 ; 2 bytes
  dbra d7,.loop1 ; 4 bytes

  ; Phase 2: 44*40 = 1760, remainder: 0
  move.l #44-1,d7
numchunksize set 40
.loop2
    movem.l d0-d6/a1-a3,(a0) ; 10 regs (40 bytes), 4 bytes
    add.w #numchunksize,a0 ; 4 bytes
  dbra d7,.loop2 ; 4 bytes

  popall
  rts



waitforfirstline
	pushd0
.sync
	move.b $FFFF8209.w,d0
	beq.s .sync
	not.b d0
	lsr.b d0,d0
	popd0
	rts


waitforvblwaiter
	pushd1
	move.w vblwaiter,d1
.wait
	cmp.w d0,d1
	bge .done
	bsr wait4vbl
	bra .wait
.done
	popd1
	rts


  ifne enablepalettefading
fadepalettesaesthetic
; In: a0 - address of target palette
;     d0 - number of vbls to wait between steps (routine will take this amount * 15 frames)
	pushd7
	bsr fadepalettessetup
	move.l #16-1,d7
.onefade
	bsr fadepalettesdoonefade
	pushd0
	bsr wait4vbld0
	popd0
	dbra d7,.onefade
	popd7
	rts


fadepalettessetup
; In: a0 - address of target palette
	pushall
	lea currentpalette,a1
	lea fadecomponents,a2
	move.l #16-1,d7
.onecolor
	move.l #0,d0
	move.w (a1)+,d0
	bsr fadeconvertste2normal
	bsr fadecolorsplit
	move.l d1,d4 ; R
	move.l d2,d5 ; G
	move.l d3,d6 ; B
	move.w (a0)+,d0
	bsr fadeconvertste2normal
	bsr fadecolorsplit
	; Now we have source RGB in d4/d5/d6 and target RGB in d0/d1/d2
	; R
	sub.l d4,d1
	tst.l d1
	bmi .Rneg
.Rpos
	lea fadetableadd,a3
	bra .Rgoon
.Rneg
	lea fadetablesub,a3
	neg.l d1
.Rgoon
	lsl #4,d1
	add.l d1,a3
	move.l a3,(a2)+
	move.w d4,(a2)+
	; G
	sub.l d5,d2
	tst.l d2
	bmi .Gneg
.Gpos
	lea fadetableadd,a3
	bra .Ggoon
.Gneg
	lea fadetablesub,a3
	neg.l d2
.Ggoon
	lsl #4,d2
	add.l d2,a3
	move.l a3,(a2)+
	move.w d5,(a2)+
	; B
	sub.l d6,d3
	tst.l d3
	bmi .Bneg
.Bpos
	lea fadetableadd,a3
	bra .Bgoon
.Bneg
	lea fadetablesub,a3
	neg.l d3
.Bgoon
	lsl #4,d3
	add.l d3,a3
	move.l a3,(a2)+
	move.w d6,(a2)+
	dbra d7,.onecolor
	move.w #0,fadetablepos
	popall
	rts

fadepalettesdoonefade
	cmp.w #16,fadetablepos
	bge .alldone
	pushall
	lea fadecomponents,a0
	lea currentpalette,a1
	move.l #16-1,d7
.onecomponent
	move.l #0,d0
	; R
	move.l (a0),a2
	add.l #1,(a0)
	add.l #4,a0
	move.w (a0)+,d1
	add.b (a2),d1
	; G
	move.l (a0),a2
	add.l #1,(a0)
	add.l #4,a0
	move.w (a0)+,d2
	add.b (a2),d2
	; B
	move.l (a0),a2
	add.l #1,(a0)
	add.l #4,a0
	move.w (a0)+,d3
	add.b (a2),d3
	; Put it all together
	bsr fadecolormerge
	bsr fadeconvertnormal2ste
	move.w d0,(a1)+
	dbra d7,.onecomponent
	add.w #1,fadetablepos
	popall
.alldone
	rts

fadecolorsplit
; In: d0 - RGB word (normal)
; Out: d1 - R
;      d2 - G
;      d3 - B
; Destroys: nothing
	move.l d0,d1
	move.l d0,d2
	move.l d0,d3
	and.l #$f00,d1
	lsr.l #8,d1
	and.l #$0f0,d2
	lsr.l #4,d2
	and.l #$00f,d3
	rts

fadecolormerge
; In: d1 - R
;     d2 - G
;     d3 - B
; Out: d0 - RGB word (normal)
; Destroys: d1, d2, d3
	lsl.l #8,d1
	move.l d1,d0
	lsl.l #4,d2
	add.l d2,d0
	add.l d3,d0
	rts

fadeconvertnormal2ste
; In: d0 - RGB word (normal)
; Out: d0 - RGB word (STE)
; Destroys: nothing
	pushd1
	move.w	d0,d1
	and.w	#%0000000100010001,d1
	and.w	#%0000111011101110,d0
	lsl.w	#3,d1
	lsr.w	#1,d0
	add.w	d1,d0
	popd1
	rts

fadeconvertste2normal
; In: d0 - RGB word (STE)
; Out: d0 - RGB word (normal)
; Destroys: nothing
	pushd1
	move.w	d0,d1
	and.w	#%0000100010001000,d1
	and.w	#%0000011101110111,d0
	lsr.w	#3,d1
	lsl.w	#1,d0
	add.w	d1,d0
	popd1
	rts
  endc

setpalettenextframe
; In: a0 - point to address of STE palette
	movem.l a1/d0-d7,-(sp)
	movem.l (a0),d0-d7
	lea currentpalette,a1
	movem.l	d0-d7,(a1)
	movem.l (sp)+,a1/d0-d7
	rts

setttpalettenextframe
; In: a0 - point to address of TT palette
	movem.l a0-a1/d7,-(sp)
	lea currentpalette,a1
	move.l #256/2-1,d7
.loop
	move.l (a0)+,(a1)+
	dbra d7,.loop	
	movem.l (sp)+,a0-a1/d7
	rts


getrnd ; random32
     move.l  getrnd_seed(pc),d0
     add.l   D0,D0
     bcc.s   .done
     eori.b  #$AF,D0
.done
     move.l  D0,getrnd_seed
     rts
getrnd_seed
  dc.b "XiA!"


swapscreens
	move.l a0,-(sp)
	move.l screenaddress,a0
	move.l smokescreenaddress,screenaddress
	move.l a0,smokescreenaddress
	move.l (sp)+,a0
	rts


wait4sync
; In: d0 - syncvalue to wait for
	move.l d1,-(sp)
.wait
	move.b syncbyte,d1
	cmp.b d0,d1
	beq .done
	bsr wait4vbl
	bra .wait
.done:
	move.l (sp)+,d1
	rts


wait4vbld0
; In: d0 - number of vbls to wait-1 (i e prepared for dbra)
; Destroys: d0
.onevbl
	bsr wait4vbl
	dbra d0,.onevbl
	rts


wait4vbl
	move.w #$1,vblflag
.loop:
	cmp.w #0,vblflag
	bne .loop
	rts


vbl
	movem.l a0-a1/d0-d7,-(sp)
	move.w #$0,vblflag

	cmp.w #0,ttscreenmode
	bne .ttpalette
	lea currentpalette,a0
	movem.l (a0),d0-d7
	movem.l d0-d7,$ffff8240
	bra .palettesdone
.ttpalette
	lea currentpalette,a0
	move.l #$ffff8400,a1
	move.l #256/2-1,d7
.palloop
	;move.l (a0)+,(a1)+
	dbra d7,.palloop
.palettesdone

  ifne 1
    move.l #$ffff8203,a0
    move.l screenaddress,d0
    movep.l d0,(a0)
	endc
	ifne 0
    move.l screenaddress,d0
;    swap d0
;    move.b d0,$ffff8201
;    swap d0
;    move.w d0,$ffff8202	
;    move.b d0,$ffff820d
    move.b d0,d1
    lsr.w #8,d0
    move d0,$ffff8200
    move.b d1,$ffff820d
	endc

	movem.l (sp)+,a0-a1/d0-d7
	add.l #1,framecounter
	add.w #1,vblwaiter
	ifne enablerasters
		move.w #$0333,$ffff8240
	endc
	ifne enablemusic
		cmp.w #0,musicinvbl
		beq .nomusic
		bsr 	MUSIC+8			; call music
.nomusic
	endc
	ifne enablerasters
		move.w currentpalette,$ffff8240
	endc
	cmp.b #$2a,$fffffc02
	beq exitall
	rte
	;move.l  oldvbl(pc),-(sp)	; go to old vector (system friendly ;) )
	;rts


	ifne enableice
deice
; In: a0 - address of packed data
;     a1 - address to unpack to
	include _inc\ice.s
	endc


	ifne enablexa
;xa_getnumberofframes
; In:  a0.l - pointer to xa file
; Out: d0.l - number of frames in file MINUS ONE (prepared for dbra)
;xa_getpalette
; In:  a0.l - pointer to xa file
;      a1.l - pointer to 16-word space to write palette to
;xa_unpackoneframe
; In:  a0.l - pointer to source
;      a1.l - pointer to dest
; Out: a0.l - points to next frame
;xa_unpack
; In:  d0.l - number of vbls between frames
;      a0.l - pointer to source
;      a1.l - pointer to image dest
;      a2.l - pointer to palette dest
	include _inc\xa.s
	endc


	ifne enablepixels
;putpixel
; In: d0 - x
;     d1 - y
;     d2 - color
;     a0 - address to screen
;
;putpixeldontdark
; In: same as putpixel, but this one doesn't set pixel if color is lower than existing pixel
;
;getpixel
; In: d0 - x
;     d1 - y
;     a0 - address to screen
; Out:d2 - color
	include _inc\putpixel.s
	endc


;-- Subroutines
;--------------------------------------------------------------
;--------------------------------------------------------------
;-- Data


	section data

MUSIC
	ifne enablemusic
;	incbin c:\utils\maxymizr\tunes\trans_y.snd
;	incbin c:\utils\maxymizr\tunes\brit.snd
	incbin c:\utils\maxymizr\tunes\cheap.snd
	endc
syncbyte equ MUSIC+$b8

  ifne enablepalettefading
fadecomponents ; 288 bytes
	rept 16
	dc.l 0 ; address of fadetable
	dc.w 0 ; R
	dc.l 0 ; address of fadetable
	dc.w 0 ; G
	dc.l 0 ; address of fadetable
	dc.w 0 ; B
	endr

fadetableadd ; 272 bytes
; fadetable positive values
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1
 dc.b 0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2
 dc.b 0,0,1,1,1,1,1,2,2,2,2,2,2,3,3,3
 dc.b 0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4
 dc.b 0,1,1,1,2,2,2,3,3,3,3,4,4,4,5,5
 dc.b 0,1,1,2,2,2,3,3,3,4,4,5,5,5,6,6
 dc.b 0,1,1,2,2,3,3,4,4,4,5,5,6,6,7,7
 dc.b 1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8
 dc.b 1,1,2,2,3,3,4,5,5,6,6,7,7,8,8,9
 dc.b 1,1,2,3,3,4,4,5,6,6,7,8,8,9,9,10
 dc.b 1,1,2,3,3,4,5,6,6,7,8,8,9,10,10,11
 dc.b 1,2,2,3,4,5,5,6,7,8,8,9,10,11,11,12
 dc.b 1,2,2,3,4,5,6,7,7,8,9,10,11,11,12,13
 dc.b 1,2,3,4,4,5,6,7,8,9,10,11,11,12,13,14
 dc.b 1,2,3,4,5,6,7,8,8,9,10,11,12,13,14,15
 dc.b 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
	even

fadetablesub ; 272 bytes
; fadetable negative values
 dc.b -0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,0
 dc.b -0,-0,-0,-0,-0,-0,-0,-1,-1,-1,-1,-1,-1,-1,-1,-1
 dc.b -0,-0,-0,-1,-1,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2
 dc.b -0,-0,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,-3,-3,-3
 dc.b -0,-1,-1,-1,-1,-2,-2,-2,-2,-3,-3,-3,-3,-4,-4,-4
 dc.b -0,-1,-1,-1,-2,-2,-2,-3,-3,-3,-3,-4,-4,-4,-5,-5
 dc.b -0,-1,-1,-2,-2,-2,-3,-3,-3,-4,-4,-5,-5,-5,-6,-6
 dc.b -0,-1,-1,-2,-2,-3,-3,-4,-4,-4,-5,-5,-6,-6,-7,-7
 dc.b -1,-1,-2,-2,-3,-3,-4,-4,-5,-5,-6,-6,-7,-7,-8,-8
 dc.b -1,-1,-2,-2,-3,-3,-4,-5,-5,-6,-6,-7,-7,-8,-8,-9
 dc.b -1,-1,-2,-3,-3,-4,-4,-5,-6,-6,-7,-8,-8,-9,-9,-10
 dc.b -1,-1,-2,-3,-3,-4,-5,-6,-6,-7,-8,-8,-9,-10,-10,-11
 dc.b -1,-2,-2,-3,-4,-5,-5,-6,-7,-8,-8,-9,-10,-11,-11,-12
 dc.b -1,-2,-2,-3,-4,-5,-6,-7,-7,-8,-9,-10,-11,-11,-12,-13
 dc.b -1,-2,-3,-4,-4,-5,-6,-7,-8,-9,-10,-11,-11,-12,-13,-14
 dc.b -1,-2,-3,-4,-5,-6,-7,-8,-8,-9,-10,-11,-12,-13,-14,-15
 dc.b -1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14,-15,-16
	even

fadetablepos
	dc.w 0
  endc



allwhitepal
	dc.w $0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff
	dc.w $0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff

allblackpal
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

bwpal
val set $000
	rept 16
	dc.w val
val set val+$111
	endr

stepal
	dc.w	$0000,$0888,$0111,$0999,$0222,$0AAA,$0333,$0BBB
	dc.w	$0444,$0CCC,$0555,$0DDD,$0666,$0EEE,$0777,$0FFF



blanklongword
	dc.l 0 


	cnop 0,4
cat001
	incbin cat001.8bp
	cnop 0,4
cat001pal
	include cat001.plt

	cnop 0,4
test002
	incbin test002.8bp
	cnop 0,4
test002pal
	include test002.plt


;-- Data
;--------------------------------------------------------------
;--------------------------------------------------------------
;-- BSS


; Saved for exit
startupsp ds.l 1
oldusp ds.l 1
oldttscreenmode ds.w 1
oldstpal	ds.w 16
oldttpal  ds.w 256
old484 ds.b 1
oldvbl	ds.l 1
	ifne enablehbl
old07	ds.b 1
old09	ds.b 1
old13	ds.b 1
old1b	ds.b 1
old21	ds.b 1
	even
oldhbl	ds.l 1
	endc
oldcacr	ds.w 1
;old8203 ds.w 1
;old8205 ds.w 1
;old8207 ds.w 1
;old8209 ds.w 1
oldphysbase ds.l 1


; Other stuff
ttscreenmode 	ds.w 1
musicinvbl		ds.w 1
physscreen 		ds.l 1
framecounter	ds.l 1
currentpalette	ds.w 256
vblflag				ds.w 1
vblwaiter 		ds.w 1
screenaddress ds.l 1
smokescreenaddress	ds.l 1
	ds.b 256
smokescreen1 ds.b SCREEN_SIZE_BYTES
	ds.b 256
smokescreen2 ds.b SCREEN_SIZE_BYTES





