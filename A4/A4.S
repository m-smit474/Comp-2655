; Name:		Matt Smith
; MRU E-mail:	msmit474@mtroyal.ca
; Course:	COMP 2655-001
; Assignment:	4, Part 2
; Due Date:	Friday, November 1st, 2019 at 11:59 p.m.
; Extension:	Sunday, November 3rd, 2019 at 11:59 p.m.
; Instructor:	Paul Pospisil
; 
; Source File:	a4.s
;
;	This program takes a text document and left justifies it
;
;  
;	Assumptions:
; Text document must be named "text.txt"
; Text document must start with a 2 digit line length
; Text document must end with a new line
;
;	Limitations:
; Line length must be 2 digits
; Maximum line length is 40
;
;	Program Status
; Tested and partially working:
; The parts that were coded for this assignment were reading and 
; calculating the line length, putting the maximum amount of words
; on a line and printing those words out. My program only does left
; justification. I tested my program in a few different ways:
;
; Testing input/output  - This was the first stage of testing and was
;			  done by reading in a single character and
;			  printing out a character until EOF. This was done
;			  to see if the subroutines were working
;			  as expected as well as to test my read until
;			  end of file loop.
;
; Testing ingnoring	- This was done by starting with a simple text
; whitespace		  file and seeing if it could ignore new lines
;			  and spaces then later testing tabs as well.
;
; Testing justification - This was done by adding various whitespace
;			  to the text document to try and mess up
;			  the justification. 
;
;	Register Table
; d7 - line length / first digit
; d6 - second digit / letter count
; d5 - line fill level
; d4 - index for loops
; d2 - used for various calculations
; d1 - number of bytes in file
; d0 - IO
; a0 - word array pointer OR string pointer
; a1 - line array pointer
; a2 - line pointer with fill level offset

CR		equ	13		; Carrage Return
LF		equ	10		; Line Feed
NULL		equ	0		; Null
TAB		equ	9		; Horizontal Tab

		xref	FileOpen	; Provided Subroutines
		xref	FileReset	;
		xref	FileClose	;
		xref	FileCharRead	;
		xref	Exit		;
		xref	KbdCharRead	;
		xref	ScrnCharWrite	;

start:		jsr	FileOpen	; Try to open file
		tst.l	d0		; 0 if file was opened successfully
		bne	fail		; Failed to open file
					; 

		clr.l	d5		; line fill level = 0
	
		jsr	FileCharRead	; Read first digit of line length
		move.l	d0,d7		;
		sub.l	#1,d1		; 
		jsr	FileCharRead	; Read second digit of line length
		move.l	d0,d6		;
		sub.l	#1,d1		;

		sub.l	#'0',d7		; Convert char to int
		sub.l	#'0',d6		; 

		mulu.w	#10,d7		; Calculate line length
		add.l	d6,d7		;

		lea	word,a0		; Word pointer
		lea	line,a1		; Line Pointer 

inFile:		tst.l	d1		; d1 contains file size in bytes
		beq	outFile		; Need a counted loop
					; Read 1 byte (1 char)
		clr.b	d6		; count = 0
		lea	word,a0		; reset word pointer
		
addWord:	jsr	FileCharRead	; Ignore whitespace
		sub.l	#1,d1		; Decrement file size
		cmpi.b	#CR,d0		; 
		beq	check		;
		cmpi.b	#LF,d0		;
		beq	check		;
		cmpi.b	#' ',d0		;
		beq	check		;
		cmpi.b	#TAB,d0		;
		beq	check		; 
					; Not whitespace

		move.b	d0,(a0)+	; Word[i] = letter
		add.b	#1,d6		; count++
		bra	addWord
		
check:		tst.b	d6		; count > 0
		bls	inFile		; 
		clr.l	d2		; x = fill level + count
		move.b	d5,d2		;
		add.b	d6,d2		;
		add.b	#1,d2		;
		cmp.b	d7,d2		; x + 1 > line length
		bls	else		; 
					; word doesn't fit on line
		lea	line,a2		; add spaces to rest of line
		adda.l	d5,a2		; fill level offset
spaces:		cmp.b	d7,d5		;
		beq	full		;
		move.b	#' ',(a2)+	;
		add.b	#1,d5		;
		bra	spaces

full:		sub.b	#1,d5		; Stops at -1 not 0
		lea	line,a1		; Reset line pointer
print:		move.b	(a1)+,d0	; Print line
		jsr	ScrnCharWrite	;
		dbra	d5,print	; fillLevel--

		clr.l	d5		; Reset fill level
		move.b	#CR,d0		; Print new line
		jsr	ScrnCharWrite	;
		move.b	#LF,d0		;
		jsr	ScrnCharWrite	;

		lea	line,a2		; Add word that didn't fit
		lea	word,a0		;
extra:		tst.b	d6		;
		beq	inFile		;
		move.b	(a0)+,(a2)+	; Copy word
		sub.b	#1,d6		; Count--
		add.b	#1,d5		; fillLevel++
		bra	extra		; Loop back


else:		lea	line,a2		; add word to line
		adda.l	d5,a2		; fill level offset
		tst.b	d5
		beq	first
		move.b	#' ',(a2)+	; line[fillLevel] = ' '
		add.b	#1,d5		; fillLevel++

first:		clr.l	d4		; Counted loop
		move.b	d6,d4		;
		lea	word,a0		; Reset word pointer
copy:		tst.b	d4		; While count > 0
		beq	inFile		;
		move.b	(a0)+,(a2)+	; line[fillLevel] = word[index]
		sub.b	#1,d4		; count--
		add.b	#1,d5		; fillLevel++
		bra	copy

		
outFile:	jsr	FileClose	; Only done if file opened

final:		lea	line,a1		;
		sub.b	#1,d5		;
printFin:	move.b	(a1)+,d0	; Print last line 
		jsr	ScrnCharWrite	;
		dbra	d5,printFin	; fillLevel--

		move.b	#CR,d0		; new line
		jsr	ScrnCharWrite	;
		move.b	#LF,d0		;
		jsr	ScrnCharWrite	;
		bra	finish		; skip fail


fail:		lea	str,a0		; Create pointer
error:		move.b	(a0)+,d0	;
		beq	finish		; Done once Null is encountered
		jsr	ScrnCharWrite	;
		bra	error		; Loop back
				

finish:		jsr	Exit		; Ends the program

str:		dc.b	"Couldn't Open File.",CR,LF,NULL
word:		ds.b	40
line:		ds.b	40