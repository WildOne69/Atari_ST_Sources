		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl�nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil�nge
		move.l	20(sp),a3		; f�r R�ckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#2,d1			; Bufferl�nge < 2
		blt.s	raus			; Raus!
		
		cmp.w	#$9119,(a1)		; vergleichen
		bne.s	raus			; stimmt nicht? -> raus
		
		moveq	#2,d0			; ganz sicher erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4)+,(a3)+		; eintragen
		move.l	(a4),(a3)		; ..
		
raus:	rts
*********
ext:	dc.b	"CEL PIC",0
; CEL: Autodesk-Format