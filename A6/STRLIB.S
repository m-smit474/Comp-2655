; Name:		Matt Smith
; MRU E-mail:	msmit474@mtroyal.ca
; Course:	COMP 2655-001
; Assignment:	6
; Due Date:	Monday, December 9th, 2019 at 11:59 p.m.
; Instructor:	Paul Pospisil
; 
; Source File:	a6.s
;
;	Assumptions:
; Length and Size of string type must be valid ( >= 0)
;
;	Limitations:
; Only works with the String Type struct
;
;	Program Status
; Tested and partially working:
; I ran both versions of the test driver and the string scan and 
; substring functions are not working correctly. I suspect this
; is an issue with pass by reference because destination seems
; to be unaffected.

		xdef	StrLen,StrSize,StrConcat,SubStr,StrScan,StrCmp,StrPrint

		include	gemdos.i	; Function calls
GEMDOS:		equ	1		;

LENGTH:		equ	-1		; String type offsets
SIZE:		equ	-2		;
STRING:		equ	0		;

FALSE:		equ	0		; Boolean values
TRUE:		equ	-1		;



;----- Subroutines -----

StrLen:					; UBYTE StrLen (stringType string)

SL_STRING:		equ	8	; Parameter offset
SL_RESULT:		equ	12	; 

		link	a6,#0		; Setup
		movem.l	a0,-(sp)	; Saved environment		
		
		move.l	SL_STRING(a6),a0 ; create string pointer
		move.b	LENGTH(a0),SL_RESULT(a6)


		movem.l	(sp)+,a0	; Restore registers
		unlk	a6		;
		rts			;



StrSize:				; UBYTE StrSize (stringType string)


SS_STRING:		equ	8	; Parameter offset
SS_RESULT:		equ	12	; 

		link	a6,#0		; Setup
		movem.l	a0,-(sp)	; Saved environment		
		
		move.l	SS_STRING(a6),a0 ; create string pointer
		move.b	SIZE(a0),SS_RESULT(a6)


		movem.l	(sp)+,a0	; Restore registers
		unlk	a6		;
		rts			;




StrConcat:				; void StrConcat (stringType *destination,
					;		  stringType source,
					;		  BOOL *error)

CAT_DST		equ	8		; Parameter offsets
CAT_SRC		equ	12		;
CAT_ERR		equ	16		;

; d2 -> i
; d3 -> j
; d4 -> count
; d5 -> space
; a3 -> error
; a4 -> source
; a5 -> dest
					; Setup
		link	a6,#0		; Stack frame
		movem.l	d2-d5/a3-a5,-(sp)	; Saved environment

		move.l	CAT_DST(a6),a5	; Load parameters
		move.l	CAT_SRC(a6),a4	;
		move.l	CAT_ERR(a6),a3	;

		move.b	SIZE(a5),d5	; space = dst.size
		sub.b	LENGTH(a5),d5	; space = space - dst.length
		move.b	#FALSE,(a3)	; *error = false

		cmp.b	LENGTH(a4),d5	; if src.length <= space
		blt	CAT_ELSE	;

		move.b	LENGTH(a5),d2	; i = dst.length
		clr.b	d3		; j = 0
		move.b	LENGTH(a4),d4	; count = src.length

join:		tst.b	d4		; while count > 0
		beq	CAT_EXIT	;
		
		move.b	STRING(a4,d3),STRING(a5,d2)

		addq.b	#1,d2		; i++
		addq.b	#1,d3		; j++
		subq.b	#1,d4		; count--
		bra	join		;


CAT_ELSE:	move.b	#TRUE,(a3)	; *error = true

CAT_EXIT:	movem.l	(sp)+,d2-d5/a3-a5	; Restore registers
		unlk	a6		; Clean up stack frame
		rts			; Return


SubStr:					; void SubStr (stringType *destination,
					;	       UBYTE start, UBYTE length,
					;	       stringType source, BOOL *error)

SUB_DEST:	equ	8			; Parameter offset
SUB_START	equ	12			;
SUB_LENGTH:	equ	14			;
SUB_SOURCE	equ	16			;
SUB_ERROR	equ	20			;

; a3 -> source
; a4 -> destination
; a5 -> error
; d3 -> start
; d4 -> length
; d5 -> index
; d6 -> max

		link	a6,#0			; Setup
		movem.l	d3-d6/a3-a5,-(sp)	;

		move.l	SUB_SOURCE(a6),a3	; create pointers
		move.l	SUB_DEST(a6),a4		; 
		move.l	SUB_ERROR(a6),a5	;
	
		move.b	SUB_START(a6),d3	; Load parameters
		move.b	SUB_LENGTH(a6),d4	;

		clr.l	d5			; index = 0
		move.b	SIZE(a4),d6		; max = dest -> size
		move.b	#TRUE,(a5)		; *error = true

		cmp.b	SIZE(a3),d3		; if start > src.size
		bls	SUB_ELSE		;
		move.b	#FALSE,(a5)		; *error = false
		bra	SUB_EXIT		;
		
SUB_ELSE:	cmp.b	d6,d4			; if length > max
		bls	copy			;
		move.b	#FALSE,(a5)		; *error = false

copy:		tst.b	d4			; while length > 0
		beq	SUB_EXIT		; 
		cmp.b	d5,d6			; && index < max
		bls	SUB_EXIT		;

						; dst.string[index] = src.string[start]
		move.b	STRING(a3,d3),STRING(a4,d5)

		addq.b	#1,d5			; index++
		addq.b	#1,d3			; start++
		subq.b	#1,d4			; length--
		bra	copy			;

SUB_EXIT:	movem.l	(sp)+,d3-d6/a3-a5	; Tear down
		unlk	a6			;
		rts				;



StrScan:				; int StrScan (stringType source, stringType target)

SCAN_SRC:	equ	8			; Parameter offset
SCAN_TGT	equ	12			;
SCAN_RESULT:	equ	16			;

; d0 -> temp char
; d2 -> index
; d3 -> start
; d4 -> count
; d5 -> i
; d6 -> length
; d7 -> same
; a2 -> source
; a3 -> target

		link	a6,#0			; Setup
		movem.l	d0/d2-d7/a2-a3,-(sp)	;
		
		move.l	SCAN_SRC(a6),a2		; Load parameters
		move.l	SCAN_TGT(a6),a3		;

		move.w	#-1,d2			; index = -1
		move.b	#FALSE,d7		; same = false

		clr.b	d4			; count = 0
find:		cmp.b	LENGTH(a2),d4		; while count < src.length
		beq	SCAN_EXIT		;
		tst.b	d7			; && !same
		bne	SCAN_EXIT		;
		
		clr.b	d3			; start = 0
		move.b	STRING(a2,d4),d0	; temp = source.string[count]
		cmp.b	STRING(a3,d3),d0	;
		bne	diff			; if target.string[start] == source.string[count]	
		
		move.w	d4,d2			; index = count

		move.b	#TRUE,d7		; same = true
		move.b	LENGTH(a3),d6		; length = target.length
		move.b	d4,d5			; i = count

look:		tst.b	d6			; while length > 0
		beq	verify			;
		tst.b	d7			; && same
		beq	verify			;

		move.b	STRING(a3,d3),d0
		cmp.b	STRING(a2,d5),d0
		beq	cont			; if src.str[i] != trg.str[start]
		
		move.b	#FALSE,d7		; same = false

cont:		addq.b	#1,d3			; start++
		addq.b	#1,d5			; i++
		subq.b	#1,d6			; length--
		bra	look			;

verify:		tst.b	d7			; if !same
		bne	diff			;
		move.w	#-1,d2			; index = -1
	
diff:		addq.b	#1,d4			; count++
		bra	find			;

SCAN_EXIT:	move.w	d2,SCAN_RESULT(a6)	; Return value
		movem.l	(sp)+,d0/d2-d7/a2-a3	; Teardown
		unlk	a6			;
		rts				;


StrCmp:					; int StrCmp (stringType string1, stringType string2)

SC_STRING_ONE:	equ	8			; Parameter offset
SC_STRING_TWO	equ	12			;
SC_RESULT:	equ	16			;	 

; d5 -> count
; d6 -> difference
; d7 -> index
; a4 -> string 1
; a5 -> string 2

						; Setup
		link	a6,#0			; Stack frame
		movem.l	d5-d7/a4-a5,-(sp)	; Saved environment

		move.l	SC_STRING_TWO(a6),a5	; Create s2 pointer
		move.l	SC_STRING_ONE(a6),a4	; Create s1 pointer

		move.b	LENGTH(a4),d5		; count = first.length
		clr.l	d6			; difference = 0
		clr.l	d7			; index = 0

		cmp.b	LENGTH(a5),d5		; if(s1.length == s2.length) 
		beq	compare			;
		move.b	LENGTH(a5),d5		; count = second.length


compare:	tst.b	d5			; while(count != 0 && difference == 0)
		beq	check			;
		tst.b	d6			;
		bne	check			;
		move.b	(a4)+,d6		; Difference = first.string[index]
		sub.b	(a5)+,d6		; Difference -= second.string[index]		
		subq.b	#1,d5			; count--
		bra	compare			;

check:		tst.b	d6			; Check if difference = 0
		blt	less			;
		tst.b	d6			;
		bgt	more			;
		move.w	d6,SC_RESULT(a6)	; return 0
		bra	SC_EXIT			;

less:		move.w	#-1,SC_RESULT(a6)	; return -1
		bra	SC_EXIT			;

more: 		move.w	#1,SC_RESULT(a6)	; return 1


SC_EXIT:	movem.l	(sp)+,d5-d7/a4-a5	; Restore registers
		unlk	a6			; Clean up stack frame
		rts				; Return




StrPrint:				; void StrPrint (stringType string)

SP_STRING:		equ	8		; Parameter offset
SP_RESULT:		equ	12		;


			link	a6,#0		; Setup
			movem.l	a5/d6-d7,-(sp)	;


			move.l	SP_STRING(a6),a5

						; Print string
			subq.l	#2,sp		; Spot for return value
			move.l	a5,-(sp)	; Input parameters
			jsr	StrLen		;
			addq.l	#4,sp		; Pop off input parameters
			move.b	(sp)+,d7	; move result into d7

						; d7 is count
print:			tst.b	d7		; If count != 0
			beq	SP_EXIT		;
			clr.w	d6		;
			move.b	(a5)+,d6	;
			move.w	d6,-(sp)	; Push char onto stack
			move.w	#c_conout,-(sp)	; Push function
			trap	#GEMDOS		; Call function
			addq.l	#4,sp		; Correct stack
			subq.b	#1,d7		; count--
			bra	print		;






SP_EXIT:		movem.l	(sp)+,a5/d6-d7	; Tear down
			unlk	a6		; 
			rts			;