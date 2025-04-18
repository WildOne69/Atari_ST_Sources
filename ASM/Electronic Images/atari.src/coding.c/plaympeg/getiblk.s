;------------------------------------------------------------------
; Falcon MPEG decoder (Intra-Frame Only)
; By Martin Griffiths, August/September 1994
;------------------------------------------------------------------


			EXPORT	SETVGA,SETTV,ld_rdptr,go,start_time,end_time,frame_count,Save_Rez,Restore_Rez
			IMPORT Log_base,Phy_base,huff_next,mb_addr_inc,Refill_Buffer,Init_Buffer,registered
			IMPORT Cconis,init_mb_addr_inc,alloc_display,init_display,init_biggie,make_getDClum,make_getDCchrom
			IMPORT dc_lum,dc_chrom
			
PICTURE_START_CODE 		equ	$100
SLICE_MIN_STARTCODE 	equ	$101
SLICE_MAX_STARTCODE 	equ	$1af
RESERVED_START_CODE_1   equ $1b0
RESERVED_START_CODE_2   equ $1b1
USER_START_CODE			equ $1B2
SEQ_START_CODE     		equ	$1B3
EXT_START_CODE			equ $1B5
RESERVED_START_CODE_3   equ	$1b6
SEQ_END_CODE       		equ	$1B7
GOP_START_CODE     		equ	$1B8
ISO_11172_END_CODE      equ $1b9
PACK_START_CODE         equ $1ba
SYSTEM_HEADER_START_CODE equ $1bb
RESERVED_STREAM         equ $1bc
PRIVATE_STREAM_1        equ $1bd
PADDING_STREAM          equ $1be
PRIVATE_STREAM_2        equ $1bf
AUDIO_STREAM_0          equ $1c0
AUDIO_STREAM_31         equ $1df
VIDIO_STREAM_0          equ $1e0
VIDIO_STREAM_15         equ $1ef
RESERVED_DATA_STREAM_0  equ $1f0
RESERVED_DATA_STREAM_15 equ $1ff


; Falcon video register equates

vhz	        EQU $FFFF820A
voff_nl     EQU $FFFF820E
vwrap       EQU $FFFF8210
_stshift	EQU $FFFF8260
_spshift    EQU $FFFF8266
hht         EQU $FFFF8282
hbb         EQU $FFFF8284
hbe         EQU $FFFF8286
hdb         EQU $FFFF8288
hde         EQU $FFFF828A
hss         EQU $FFFF828C
hfs         EQU $FFFF828E
hee         EQU $FFFF8290
vft         EQU $FFFF82A2
vbb         EQU $FFFF82A4
vbe         EQU $FFFF82A6
vdb         EQU $FFFF82A8
vde         EQU $FFFF82AA
vss         EQU $FFFF82AC
vco_hi      EQU $FFFF82C0
vco         EQU $FFFF82C2

Refill:
			movem.l	d0-d7/a0-a6,-(sp)
			bsr.w	Refill_Buffer
			movem.l	(sp)+,d0-d7/a0-a6
			rte
			
mb_inc_val	equ	0
mb_inc_num	equ	2

dc_size_val	equ	0
dc_size_num	equ	2

			macro	wait_to_send X
.wait:		BTST.B 	#1,X
			BEQ.S 	.wait
			endm


			macro	showbits X
			bfextu	(a6){d7:X},d0
			endm
						
			macro	flushbits X
			add.w	X,d7
			trapcs	
			endm

			macro	flushbitsQ X
			add.w	#X,d7
			trapcs	
			endm	
						
			macro	getbitsQ X
			bfextu	(a6){d7:X},d0
			flushbitsQ X
			endm
		
			macro	getbits	X
			bfextu	(a6){d7:X},d0
			flushbits X
			endm

			macro	getslicehdr
			bfextu	(a6){d7:5},d0
			flushbitsQ 5
			move.w	d0,ld_quant_scale
			bsr		ext_bit_info
			endm
			
			macro	getMBA
			showbits 11				
			movem.l	(mb_addr_inc,pc,d0*8),d0/d1
			flushbits d1
			endm

; get Macro Block Type
; 2 bits ( %00 = error %01 = intra %10 = 0 %11 = 0)

			macro	getMBtype
			showbits 2
			cmp.w	#1,d0
			blo		error
			seq		d2
			move.l	(quantTbl,pc,d0*4),d0
			flushbits	d0
.nah:		tst.b	d2
			beq.s	.noq
			getbitsQ	5
			move.w	d0,ld_quant_scale			
.noq:
			endm
quantTbl:	dc.l	0,2,1,1

			macro	getDClum
			showbits 15				; showbits(15);
			move.l	(a3,d0.l*4),d0
			flushbits d0
			swap	d0
			endm

			macro	getDCchrom
			showbits 16				; showbits(16)
			move.l	(a4,d0.l*4),d0
			flushbits d0
			swap	d0
			endm


swap_screens:
			move.l	Log_base(pc),d0
			move.l	Phy_base(pc),d1
			move.l	d0,Phy_base
			move.l	d1,Log_base
			move.b	d0,$ffff820d.w
			lsr.w	#8,d0
			move.l	d0,$ffff8200.w
			addq.l	#1,frame_count
			rts

go:			movem.l	d2-d7/a2-a6,-(sp)
			bsr		init_mb_addr_inc
			bsr		init_biggie
			bsr		make_getDClum
			bsr		make_getDCchrom
			move.l	$1c.w,save_vec7
			move.l	#Refill,$1c.w
			clr.l	frame_count
			bsr		initbits
			bsr		startcode			;	valid mpeg stream?
			showbits	32
			cmp.l	#PACK_START_CODE,d0 ;
			beq.s	.is1
			cmp.l 	#SEQ_START_CODE,d0	;
			bne.s	notmpeg				;		
			
.is1:		move.l	$4ba.w,start_time
loop:		bsr		mpeg_stream
			bsr		Cconis
			tst.l	d0
			beq.s	loop
			
itends:		move.l	$4ba.w,end_time
			move.l	save_vec7(pc),$1c.w

			movem.l	(sp)+,d2-d7/a2-a6
			moveq	#0,d0
			rts
notmpeg:	move.l	save_vec7(pc),$1c.w
			movem.l	(sp)+,d2-d7/a2-a6
			moveq	#-1,d0
			rts
save_vec7:	dc.l	0			

initbits:	bsr		Init_Buffer
			lea 	$ffffa206.w,a5
			move.l	ld_rdptr(pc),a6
			moveq	#0,d7
			rts

; Search for the next startcode.
			
startcode:	bfextu	d7{29:3},d0
			beq.s	onbyte
			sub.l	d0,d7
search_lp:	flushbitsQ	8			; flushbits(ld_incnt & 7);
onbyte:		showbits 24				; showbits(24)
			moveq	#1,d1			; == 1??
			cmp.l	d1,d0
			bne.s	search_lp
foundstart:	rts

; Skip Extra Bit Info

extb_lp:	flushbitsQ 8		;		flushbits(8)
ext_bit_info:
			getbitsQ 1			; while (getbits(1))
			tst.w	d0
			bne.s	extb_lp
			rts

; Decode extension and User data

dec_extuse:	moveq	#32,d0
			flushbits d0
ext_user_data:
			bsr		startcode
ext_user_lp:showbits 32
			cmp.l	#EXT_START_CODE,d0
			beq.s	dec_extuse
			cmp.l	#USER_START_CODE,d0
			beq.s	dec_extuse
			rts

;

parse_slice:moveq	#24,d0
			flushbits d0				; flushbits(24)
			bfextu	(a6){d7:8},d6		; code = getbits(8)
			flushbitsQ 	8
			getbitsQ	5
			move.w	d0,ld_quant_scale
			bsr		ext_bit_info
			subq	#1,d6				; (code-1)
			mulu	mb_width(pc),d6		; code *mb_width
			subq.l	#1,d6				; -1 = MBA
			lea		dc_dct_pred(pc),a0
			clr.l	(a0)			
			clr.w	4(a0)
			rts


; Decode Header

mpeg_stream:
			showbits	32
			cmp.l	#SLICE_MIN_STARTCODE,d0
			blo		.nots
			cmp.l	#SLICE_MAX_STARTCODE,d0
			bls		ere
.nots:		cmp.l	#SEQ_END_CODE,d0
			beq.s	seq_end
			cmp.l	#SEQ_START_CODE,d0
			beq.s	getseqhdr
			cmp.l	#GOP_START_CODE,d0
			beq		getgophdr
			cmp.l	#PICTURE_START_CODE,d0
			beq		getpicturehdr
hmmm:		
			flushbitsQ 	1
			bsr		startcode		;	not i frame
			bra 	mpeg_stream

seq_end:	bsr		initbits
			bsr		startcode
			bra		mpeg_stream
			
; Decode Sequence header.

getseqhdr:	moveq	#32,d0
			flushbits d0
			moveq	#12,d1
			getbits d1
			move.w	d0,horizontal_size
			moveq	#12,d1
			getbits	d1
			move.w	d0,vertical_size
			moveq	#27+11,d0
			flushbits d0
			move.w	horizontal_size(pc),d0
			add.w	#15,d0
			lsr.w	#4,d0
			move.w	d0,mb_width
			move.w	vertical_size(pc),d1
			add.w	#15,d1
			lsr.w	#4,d1
			move.w	d1,mb_height
			move.w	d0,d2
			mulu	d1,d2
			move.l 	d2,MBAmax		; mb_height*mb_width
			lsl.w	#4,d0
			lsl.w	#4,d1
			move.w	d0,coded_picture_width
			move.w	d1,coded_picture_height

			move.w	last_vert(pc),d0
			cmp.w	vertical_size(pc),d0
			beq.s	no_init
			move.w	vertical_size(pc),last_vert
			move.w	#37,-(sp)
			trap	#14
			addq.l	#2,sp
			bsr		init_display
			move.w	#37,-(sp)
			trap	#14
			addq.l	#2,sp
no_init:
			MOVE.B #$80+20,$FFFFA201.W		; host command 3
			lea		default_intra_matrix(pc),a0
			moveq	#64-1,d5
			getbitsQ 1
			tst.w	d0
			beq.s	def_matrix
			lea		zig_zag_scan(pc),a3
get_mat:	getbitsQ 8
			move.w	(a3)+,d1
			move.w	d0,(a0,d1*2)
			dbf		d5,get_mat
			moveq	#64-1,d5
def_matrix:	moveq	#0,d0
initdefq:	wait_to_send -4(a5)
			move.b	(a0)+,d0
			move.l	d0,-2(a5)
			dbf		d5,initdefq
mat1_done:	getbitsQ 1
			tst		d0
			beq.s	skipcont
skipnonintra:
			moveq	#64-1,d5
skipnon:	flushbitsQ 8
			dbf		d5,skipnon
skipcont:	bsr		ext_user_data
			rts
			
			
; Decode group of pictures header 
; dropflag(1)/ hour(5)/minute(6)/(1)/seconds(6)/frame(7)/closed_gop(1)/broken_link(1)

getgophdr:	moveq	#27+32,d0
			flushbits d0
			bsr		ext_user_data
			
; Decode Picture Header
; 10 bits (Temporal Reference)/3 bits (Picture Type)/ 16 bits (Vbv delay)

getpicturehdr:
			moveq	#32+10,d0
			flushbits d0
			getbitsQ	3
			cmp.w	#1,d0
			beq.s	hmmmm

.searchpic:	
			bsr		startcode		;	not i frame
			showbits	32
			cmp.l	#PICTURE_START_CODE,d0
			beq 	 mpeg_stream
			cmp.l	#GOP_START_CODE,d0
			beq 	mpeg_stream
			cmp.l	#SEQ_END_CODE,d0
			beq 	mpeg_stream
			flushbitsQ 8
			bra		.searchpic

hmmmm:		moveq	#16,d0
			flushbits d0
			bsr		ext_bit_info
			bsr		ext_user_data

ere:		bsr		parse_slice

getpicture:	
			move.l	Log_base(pc),a0
			add.w	line_width(pc),a0
			sub.w	coded_picture_width(pc),a0
			move.l	a0,this_base
			lea		huff_next,a2
			lea		dc_lum,a3			
			lea		dc_chrom,a4
			clr.b	-1(a5)			
			MOVE.B #$80+19,$FFFFA201.W		; host command 2
nxt:		showbits 23					; showbits(23)
			beq		is_start			; finished
ok_getMBA:	getMBA
			cmp.l	#35,d0
			bne.s	.notesc
			add.l	#33,d6
			bra.s	ok_getMBA
.notesc:	cmp.l	#34,d0
			beq.s	ok_getMBA
			add.l	d0,d6
			cmp.l	MBAmax(pc),d6		; MBA>=MBAmax
			bhs		error
						
			getMBtype

			wait_to_send -4(a5)
			move.w	ld_quant_scale(pc),(a5)

			lea		dc_dct_pred(pc),a0
get_lum_b1:	getDClum
			bsr		getintrablock
get_lum_b2:	getDClum
			bsr		getintrablock
get_lum_b3:	getDClum
			bsr		getintrablock
get_lum_b4:	getDClum
			bsr		getintrablock

			lea		dc_dct_pred+2(pc),a0
get_cr:		getDCchrom
			;bsr		skipintrablock
			bsr		getintrablock
			lea		dc_dct_pred+4(pc),a0
get_cb:		getDCchrom
			;bsr		skipintrablock
			bsr		getintrablock
get_block:	
			move.l	this_base(pc),a0
			move.l	d6, d4
			divu	mb_width(pc),d4
			move.l	d4,d3		; by
			swap	d3			; bx
			lsl		#5,d3		; 16*2
			add.w	d3,a0
			move.w	line_width(pc),d2
			mulu	d2,d4
			lsl.l	#5,d4		; * 32
			add.l	d4,a0
	
			BTST.B 	#0,-4(a5)
			BEQ.S 	*-6

colour:		moveq 	#16-1,d0
			lea		-4(a5),a1
lpd2:		
i			set 0
			rept	8
			BTST.B 	#0,(a1)
			BEQ.S 	*-4
			move.w	(A5),d1
			swap	d1
			BTST.B 	#0,(a1)
			BEQ.S 	*-4			
			move.w	(A5),d1
			move.l	d1,i(a0)
i			set		i+4
			endm
			lea		(a0,d2*2),a0
			dbf		d0,lpd2
			bra		nxt

grey:		moveq 	#16-1,d0
lpd2q:		
i			set 0
			rept	8
			move.w	(A5),d1
			swap	d1
			move.w	(A5),d1
			move.l	d1,i(a0)
i			set		i+4
			endm

			lea		(a0,d2*2),a0
			dbf		d0,lpd2q
			bra		nxt
			
is_start:	bsr		startcode
			showbits 32
			cmp.l	#SLICE_MIN_STARTCODE,d0
			blo		swap_screens
			cmp.l	#SLICE_MAX_STARTCODE,d0
			bhi		swap_screens
			rts
error:		bsr		startcode						
			bra		mpeg_stream
						
this_base:	dc.l	0
lastpos:	dc.l	0
    
; Decode an Intra Block
; a0 -> dc dct predictor value

			.ALIGN 16
			
getintrablock:
			move.w	(a0),d1
			add.w	d0,d1
			move.w	d1,(a0)
			moveq	#1,d2
			wait_to_send -4(a5)
sen_dc:		move.w	d1,(a5)
decode_lp:	showbits 17
			move.l	(a2,d0.l*4),d0	; 
			flushbits d0				; flushbits(tab->len)
			swap	d0					; tab->run
			cmp.b	#64,d0
			bhs.s	is_run				;
			add.b	d0,d2				; i+= tab->run;
			asr.w	#8,d0				; val = tab->level;
decode_sen:	
			wait_to_send -4(a5)
			move.b	d2,-1(a5)
			move.w	d0,(a5)
			addq.b	#1,d2
			bra.s	decode_lp	

is_run:		beq.s	is_end				; if (tab->run==65)
			getbitsQ	6				; i+=getbits(6) 
			add.b	d0,d2
			getbitsQ	8				; val = getbits(8)
			tst.w	d0
			beq.s	val_zero			;
			cmp.w	#128,d0
			bpl.s	val_higher
			bmi.s	decode_sen
			getbitsQ 8					; val = getbits(8)
val_higher:	sub.w	#256,d0				; val -=256;
val_cont:	bra.s	decode_sen
			
val_zero:	getbitsQ	8				; val = getbits(8)
			bra.s	decode_sen
			
is_end:		wait_to_send -4(a5)
			clr.l	-2(a5)
			rts								
			
; Skip an Intra Block
; a0 -> dc dct predictor value

			.ALIGN 16
			
skipintrablock:
.decode_lp:	showbits 16
			move.l	(a2,d0.l*4),d1	; 
			moveq	#0,d0
			move.b	d1,d0
			flushbits d0				; flushbits(tab->len)
			lsr.w	#8,d1				; tab->run
			cmp.b	#64,d1
			bhs.s	.is_run				;
			flushbitsQ 1
			bra.s	.decode_lp	
.is_run:	beq.s	.is_end				; if (tab->run==65)
			flushbitsQ	6				; i+=getbits(6) 
			getbitsQ	8				; val = getbits(8)
			tst.w	d0
			beq.s	.val_zero			;
			cmp.w	#128,d0
			bpl.s	.val_higher
			bmi.s	.val_cont
			flushbitsQ 8				; val = getbits(8)
.val_higher:sub.w	#256,d0				; val -=256;
.val_cont:	bra.s	.decode_lp	
.val_zero:	flushbitsQ	8				; val = getbits(8)
			bra.s	.decode_lp	
.is_end:	rts
			
; Set Video Mode to VGA True Colour 320x200.
; (hit the h/ware directly)

SETTV:
			move.w	#320,line_width
			lea	TC320_TV(PC),A0
			clr.w	(_spshift.w)
			LEA (hht).w,A1
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			move.W	#$0271,(vft.w)
			move.w	vertical_size(pc),d1
			add.w	d1,d1				; *4
			move.w	#480,d0
			sub.w	d1,d0
			lsr.w	#1,d0
			add.w	#$3f,d0
			add.w	d0,d1
			move.w	d0,(vbe.w)  ; top border display end (3f)
			move.w	d1,(vbb.w)	; bottom border (3ff)
			move.w	d0,(vdb.w)	; display start (3f)
			move.w	d1,(vde.w)	; display end   (3ff)
			move.w	#$026b,(vss.w)
	    	move.w  (a0)+,(voff_nl.w)
			MOVE.W  (a0)+,(vwrap.w)
	        move.w  (a0)+,(vco.w)
	        move.w  (a0)+,(vco_hi.w)
			move.w  (a0)+,(vhz.w)
			move.w  (a0),(_spshift)
			rts

SETVGA:		lea	TC320_VGA(PC),A0
			move.w horizontal_size(pc),d0
			move.w vertical_size(pc),d1
			cmp.w	#320,d0
			bhi.s	.set480
			cmp.w	#240,d1
			bhi.s	.set480
			move.w	#320,line_width
			clr.w	(_spshift.w)
			LEA (hht).w,A1
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			move.W	#$0419,(vft.w)
			lsl.w	#2,d1				; *4
			move.w	#960,d0
			sub.w	d1,d0
			lsr.w	#1,d0
			add.w	#$3f,d0
			add.w	d0,d1
			move.w	d0,(vbe.w)  ; top border display end (3f)
			move.w	d1,(vbb.w)	; bottom border (3ff)
			move.w	d0,(vdb.w)	; display start (3f)
			move.w	d1,(vde.w)	; display end   (3ff)
			move.w	#$0415,(vss.w)
		    move.w  (a0)+,(voff_nl.w)
			MOVE.W  (a0)+,(vwrap.w)
	        move.w  (a0)+,(vco.w)
	        move.w  (a0)+,(vco_hi.w)
			move.w  (a0)+,(vhz.w)
			move.w  (a0),(_spshift)
			RTS
.set480:	lea	TC480_VGA(PC),A0
			move.w	#480,line_width
			clr.w	(_spshift.w)
			LEA (hht).w,A1
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			move.W	#$0319,(vft.w)
			lsl.w	#1,d1				; *4
			move.w	#768-64,d0
			sub.w	d1,d0
			lsr.w	#1,d0
			add.w	#$3f,d0
			add.w	d0,d1
			move.w	d0,(vbe.w)  ; top border display end (3f)
			move.w	d1,(vbb.w)	; bottom border (3ff)
			move.w	d0,(vdb.w)	; display start (3f)
			move.w	d1,(vde.w)	; display end   (3ff)
			move.w	#$0315,(vss.w)
		    move.w  (a0)+,(voff_nl.w)
			MOVE.W  (a0)+,(vwrap.w)
	        move.w  (a0)+,(vco.w)
	        move.w  (a0)+,(vco_hi.w)
			move.w  (a0)+,(vhz.w)
			move.w  (a0),(_spshift)
			RTS

line_width:	dc.w 	0

Save_Rez:	move.w	#37,-(sp)
			trap	#14
			addq.l	#2,sp
			lea		saved_res,a0
		    move.w  (voff_nl.w),(a0)+
			MOVE.W  (vwrap.w),(a0)+
			move.l  (_spshift.w)-2,(a0)+		
			LEA 	(hht).w,A1
			MOVE.L	(a1)+,(A0)+
			MOVE.L	(a1)+,(A0)+
			MOVE.L	(a1)+,(A0)+
			MOVE.L	(a1)+,(A0)+
			move.W	(vft.w),(a0)+
			move.w	(vbe.w),(a0)+ 
			move.w 	(vbb.w),(a0)+	
			move.w	(vdb.w),(a0)+
			move.w	(vde.w),(a0)+
			move.w	(vss.w),(a0)+
	        move.l  (vco_hi.w),(a0)+
			move.w  (vhz.w),(a0)+
			RTS
			
Restore_Rez:LEA		saved_res,a0
		    move.w  (a0)+,(voff_nl.w)
			MOVE.W  (a0)+,(vwrap.w)
			move.l  (a0)+,(_spshift.w)-2
			LEA 	(hht).w,A1
			MOVE.L	(a0)+,(a1)+
			MOVE.L	(a0)+,(a1)+
			MOVE.L	(a0)+,(a1)+
			MOVE.L	(a0)+,(a1)+
			move.W	(a0)+,(vft.w)
			move.w	(a0)+,(vbe.w)
			move.w 	(a0)+,(vbb.w)
			move.w	(a0)+,(vdb.w)
			move.w	(a0)+,(vde.w)
			move.w	(a0)+,(vss.w)
	        move.l  (a0)+,(vco_hi.w)
			move.w  (a0)+,(vhz.w)
			RTS
			
			data	

TC320_VGA:	DC.W	$00C6 ; hht
			DC.W	$008D ; hbb
			DC.W	$0015 ; hbe
			DC.W	$02AC ; hdb
			DC.W	$0091 ; hde (horizontal display end, 0 == middle
			DC.W	$0096 ; hss
			DC.W	$0000 ; hfs
			DC.W	$0000 ; hee
			DC.W	$0000 ; next line offset
			DC.W	$0140 ; vwrap
			DC.W	$0005 ; vco
			DC.W	$0186 ; vco hi
			DC.W	$0000 ; $ffff820a
			DC.W	$0100 ; spshift

TC480_VGA:	DC.W	$011C ; hht
			DC.W	$00D7 ; hbb
			DC.W	$0015 ; hbe
			DC.W	$0302 ; hdb
			DC.W	$00DB ; hde
			DC.W	$00F0 ; hss
			DC.W	$0000 ; hfs
			DC.W	$0000 ; hee
			DC.W	$0000 ; next line offset
			DC.W	$01E0 ; vwrap
			DC.W	$0004 ; vco
			DC.W	$0182 ; vco hi
			DC.W	$0000 ; $ffff820a
			DC.W	$0100 ; spshift


TC320_TV:	DC.W	$00FE ; hht
			DC.W	$00CB ; hbb
			DC.W	$0027 ; hbe
			DC.W	$002E ; hdb
			DC.W	$008F ; hde
			DC.W	$00D8 ; hss
			DC.W	$0000 ; hfs
			DC.W	$0000 ; hee
			DC.W	$0000 ; next line offset
			DC.W	$0140 ; vwrap
			DC.W	$0000 ; vco
			DC.W	$0183 ; vco hi
			DC.W	$0200 ; $ffff820a
			DC.W	$0100 ; spshift
		
			.ALIGN 16

; val/flush bits (9bit table lookup)

zig_zag_scan:
			dc.w	0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5
			dc.w	12,19,26,33,40,48,41,34,27,20,13,6,7,14,21,28
			dc.w	35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51
			dc.w	58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63

default_intra_matrix:
			dc.b	 8, 16, 19, 22, 26, 27, 29, 34
			dc.b	16, 16, 22, 24, 27, 29, 34, 37
			dc.b	19, 22, 26, 27, 29, 34, 34, 38
			dc.b	22, 22, 26, 27, 29, 34, 37, 40
			dc.b	22, 26, 27, 29, 32, 35, 40, 48
			dc.b	26, 27, 29, 32, 35, 40, 48, 58
			dc.b	26, 27, 29, 34, 38, 46, 56, 69
			dc.b	27, 29, 35, 38, 46, 56, 69, 83
last_vert:	dc.w	-1
frame_count:dc.l	0
start_time:	dc.l	0
end_time:	dc.l	0
			
ld_quant_scale:
			ds.l	1
MBAmax:		ds.l	1
dc_dct_pred:ds.w 	3
horizontal_size:
			ds.w	1
vertical_size:
			ds.w	1
mb_width:	ds.w	1
mb_height:	ds.w	1
coded_picture_width:
			ds.w	1
coded_picture_height:
			ds.w	1
ld_rdptr:	ds.l	1

			.ALIGN 16
			

			bss
			
saved_res:	ds.l	32

