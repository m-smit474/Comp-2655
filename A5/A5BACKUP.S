; Name:		Matt Smith
; MRU E-mail:	msmit474@mtroyal.ca
; Course:	COMP 2655-001
; Assignment:	5
; Due Date:	Tuesday, November 19th, 2019 at 11:59 p.m.
; Instructor:	Paul Pospisil
; 
; Source File:	a5.s
;
;	Assumptions:
; Text document must be named "text.txt"
; Text document must be in the format: 4 character code followed by new line
; Code must only use valid characters (r,g,b,y,m,p)
;
;	Limitations:
; Game requires codes to be generated before hand
;
;	Program Status
; Tested and fully working:
; The parts that were coded for this assignment were the reading of
; characters from a file, taking a valid guess, comparing the guess
; to the actual code while there were still codes to read and the 
; player wanted to continue.
;
;	Testing
; I tested my code incrementelly as I was writing it. I started with 
; the "simplest" parts of the translation and made sure these were working.
; This was the message that is printed as the game boots up, the two do-while
; loops, what happens after a game is played. Once I had those parts tested
; and working I began working on the more complex translations that were 
; needed for when the game was being played. These were the comparisions of
; fields in the game structure and manipulation of the game structure. I tested
; these in the debugger to verify the values were as expected. Once the game
; was fully coded I ran the provided text file and made sure the game
; worked as expected. I also ran my own test file with the following data:
;
;	DATA		EXPECTED	ACTUAL		REASON
;
;	rbgy		Accepted	Accepted	To test every valid colour option
;
;	ympr		Accepted	Accepted	To test every valid colour options
;
;	Multiple codes	Game runs 	Game ran	Seeing that do-while loop works properly
;			multiple times	multiple times	also that file is being read correctly
;
;	Multiple codes	Game stops	Game stopped	Testing if the user can end the game 
;			after 'N'
;
;
;	Register Table
; d7 - index i
; d6 - index j
; d1 - number of bytes in file
; d0 - IO / Various calculations
; a0 - String pointer
; a1 - Game structure pointer


CR		equ	13		; Carrage Return
LF		equ	10		; Line Feed
NULL		equ	0		; Null
TAB		equ	9		; Horizontal Tab
TRUE		equ	1		; Boolean values
FALSE		equ	0		; 

PLACES		equ	4		; Constants
ATTEMPTS	equ	10		;
NEWLINE_SZ	equ	2		;

PATTERN		equ	0		; Structure Offsets
EXACT_M		equ	4		;
COLOUR_M	equ	5		;
GUESS		equ	6		;
WORKING		equ	10		;
GAME_SZ		equ	14		;


		xref	FileOpen	; Provided Subroutines
		xref	FileReset	;
		xref	FileClose	;
		xref	FileCharRead	;
		xref	Exit		;
		xref	KbdCharRead	;
		xref	ScrnCharWrite	;

start:		jsr	FileOpen	;
		tst.l	d0		; 0 if file was opened successfully
		bne	fail		; Failed to open file
					; 
		lea	MSG,a0		; Welcome message
greeting:	move.b	(a0)+,d0	;
		beq	after		;
		jsr	ScrnCharWrite	;
		bra	greeting	;


after:		clr.l	d0		; size = # of bytes in file
		addi.l	#PLACES,d0	;
		addi.l	#NEWLINE_SZ,d0	;
		divu	d0,d1		; size = size / (Places + Newline size)
		move.w	d1,size		;

play:					; Start of game
		lea	game,a1		;

; Read pattern
		clr.l	d7		; i = 0
load:		cmpi.b	#PLACES,d7	;
		beq	prepare		;
		jsr	FileCharRead	; game.pattern[i] = readChar
		move.b	d0,PATTERN(a1,d7)
		addi.b	#1,d7		; i++
		bra	load		;

prepare:	jsr	FileCharRead	; Clear newline characters
		jsr	FileCharRead	;

		lea	HEADER,a0	; Print out header
header:		move.b	(a0)+,d0	;
		beq	begin		;
		jsr	ScrnCharWrite	;
		bra	header		;


begin:		clr.b	attempt		; attempt = 0
inGame:		addi.b	#1,attempt	; attempt++
		move.b	#FALSE,valid	; valid = false
validGuess:	cmpi.b	#TRUE,valid	;
		beq	compare		;
		move.b	attempt,d0	; 
		addi.b	#'0',d0		; Convert attempt to char
		jsr	ScrnCharWrite	;
		move.b	#TAB,d0		;
		jsr	ScrnCharWrite	;

		clr.l	d7		; i = 0
getGuess:	cmpi.b	#PLACES,d7	; i < PLACES
		beq	verify		;
		jsr	KbdCharRead	;
		move.b	d0,GUESS(a1,d7)	;
		addi.b	#1,d7		; i++
		bra	getGuess	;
		

verify:		move.b	#TRUE,valid	; valid = true
		clr.l	d7		; i = 0
good:		cmpi.b	#FALSE,valid	; while(valid && i < PLACES)
		beq	confirm		;
		cmpi.b	#PLACES,d7	;
		beq	confirm		;
		move.b	GUESS(a1,d7),ch	; ch = game.guess[i]
		addi.b	#1,d7		; i++
		cmpi.b	#'r',ch		;
		beq	good		;
		cmpi.b	#'g',ch		;
		beq	good		;
		cmpi.b	#'b',ch		;
		beq	good		;
		cmpi.b	#'y',ch		;
		beq	good		;
		cmpi.b	#'m',ch		;
		beq	good		;
		cmpi.b	#'p',ch		;
		beq	good		;
		move.b	#FALSE,valid	; valid = false
		bra	good		;

confirm:	cmpi.b	#TRUE,valid	; if (!valid)
		beq	compare		;

		lea	INVALID,a0	;
invalid:	move.b	(a0)+,d0	;
		beq	validGuess	;
		jsr	ScrnCharWrite	;
		bra	invalid		;



compare:	clr.l	d7		; i = 0
comp_loop:	cmpi.b	#PLACES,d7	; i < PLACES
		beq	exact		;
					; game.working[i] = game.pattern[i]
		move.b	PATTERN(a1,d7),WORKING(a1,d7)
		addi.b	#1,d7		; i++
		bra	comp_loop	;

		

exact:		clr.b	EXACT_M(a1)	; game.exact_matches = 0
		clr.l	d7		; i = 0
e_matches:	cmpi.b	#PLACES,d7	; i < PLACES
		beq	colour		;
					; if (game.guess[i] == game.working[i])
		move.b	WORKING(a1,d7),d0
		cmp.b	GUESS(a1,d7),d0
		bne	not_exact	;
		addi.b	#1,EXACT_M(a1)	; game.matches++
					; game.guess[i] = 'X'
					; game.working[i] = 'X'
		move.b	#'X',GUESS(a1,d7)
		move.b	#'X',WORKING(a1,d7)

not_exact:	addi.b	#1,d7		; i++
		bra	e_matches	;


colour:		clr.b	COLOUR_M(a1)	; game.colour_matches = 0
		cmpi.b	#PLACES,COLOUR_M(a1)
		beq	success		; if (game.exact_m != PLACES)

		clr.l	d7		; i = 0
c_matches:	cmpi.b	#PLACES,d7	; while (i < PLACES)
		beq	success		;
		cmpi.b	#'X',GUESS(a1,d7)
		beq	skip		; if (game.guess[i] != 'X')

		clr.l	d6		; j = 0
		move.b	#FALSE,match	; match = false
matches:	cmpi.b	#TRUE,match	; while (!match && j < PLACES)
		beq	skip		;
		cmpi.b	#PLACES,d6	;
		beq	skip		;
		cmpi.b	#'X',WORKING(a1,d6)
		beq	not_colour	; if (game.working[j] != 'X'
		move.b	GUESS(a1,d7),d0	
		cmp.b	WORKING(a1,d6),d0
		bne	not_colour	; if (game.guess[i] == game.working[j])
		move.b	#'X',WORKING(a1,d6)	; game.working[j] = 'X'
		addi.b	#1,COLOUR_M(a1)		; game.colour_m++
		move.b	#TRUE,match		; match = true

not_colour:	addi.b	#1,d6		; j++
		bra	matches		;

skip:		addi.b	#1,d7		; i++
		bra	c_matches	;


success:	cmpi.b	#PLACES,EXACT_M(a1)	; if (game.exact_m == PLACES)
		bne	not_it		;
		lea	CONGRATS,a0	;
congrats:	move.b	(a0)+,d0	; Correct code was entered
		beq	again		;
		jsr	ScrnCharWrite	;
		bra	congrats	;

not_it:		move.b	#TAB,d0		; Guess was not correct
		jsr	ScrnCharWrite	;
		move.b	EXACT_M(a1),d0	;
		addi.b	#'0',d0		; Convert to char
		jsr	ScrnCharWrite	;
		move.b	#TAB,d0		;
		jsr	ScrnCharWrite	;
		move.b	COLOUR_M(a1),d0	;
		addi.b	#'0',d0		; Convert to char
		jsr	ScrnCharWrite	;
		move.b	#CR,d0		; Newline
		jsr	ScrnCharWrite	;
		move.b	#LF,d0		; 
		jsr	ScrnCharWrite	;
		move.b	#CR,d0		; 
		jsr	ScrnCharWrite	;

again:		cmpi.b	#ATTEMPTS,attempt
		beq	outGame		;
		cmpi.b	#PLACES,EXACT_M(a1)
		bne	inGame		;


outGame:	cmpi.b	#PLACES,EXACT_M(a1)
		beq	over		;
		lea	NO_MORE,a0	;
noMore:		move.b	(a0)+,d0	; You are out of guesses
		beq	reveal		;
		jsr	ScrnCharWrite	;
		bra	noMore		;

reveal:		clr.l	d7		; i = 0
answer:		cmpi.b	#PLACES,d7	; While( i < places)
		beq	over		;       Print answer
		move.b	PATTERN(a1,d7),d0
		jsr	ScrnCharWrite	;
		addi.b	#1,d7		;       i++
		bra	answer		;
		

over:		subi.w	#1,size		; size--
		beq	finish		; Do while conditions

		lea	ANOTHER,a0	; Play another game
ask:		move.b	(a0)+,d0	;
		beq	check		;
		jsr	ScrnCharWrite	;
		bra	ask		;

check:		jsr	KbdCharRead	; User enters answer as Y or N
		move.b	d0,play_on	;
		cmp.b	#'n',play_on	;
		beq	finish		;
		cmp.b	#'N',play_on	;
		beq	finish		;

		move.b	#CR,d0		; New line
		jsr	ScrnCharWrite	;
		move.b	#LF,d0		;
		jsr	ScrnCharWrite	;
		move.b	#CR,d0		; New line
		jsr	ScrnCharWrite	;
		move.b	#LF,d0		;
		jsr	ScrnCharWrite	;
		move.b	#CR,d0		; 
		jsr	ScrnCharWrite	;
		bra	play		;





fail:		lea	FNO,a0		; Error Message
err_msg:	move.b	(a0)+,d0	;
		beq	finish		; Null terminator
		jsr	ScrnCharWrite	; 
		bra	err_msg		; Loop back	

finish:		jsr	Exit


;---   My Data   ---
size:		dc.w	1
		even
play_on:	dc.b	1
		even
game:		ds.b	GAME_SZ
		even
attempt:	dc.b	1
		even
valid:		dc.b	1
		even
match:		dc.b	1
		even
ch:		dc.b	1
		even

FNO:		dc.b	"fail to open the text.txt file - program terminated",CR,LF,NULL
		even

MSG:		dc.b	CR,LF,TAB,TAB,TAB,"Welcome to my mastermind game",CR,LF,CR,LF
		dc.b	"Matsermind is a game of coode breaking. The computer",CR,LF
		dc.b	"will generate a code for you to break.",CR,LF,CR,LF
		dc.b	"The code is composed of 4 characters being:",CR,LF
		dc.b	TAB,"(r)ed, (b)lue, (g)reen, (y)ellow, (m)agenta, & (p)urple",CR,LF
		dc.b	"with duplicate colours being allowed.",CR,LF,CR,LF
		dc.b	"You will enter guesses of exactly 4 lowercase letters.",CR,LF
		dc.b	"Raw input is being used so:",CR,LF
		dc.b	TAB,"do NOT press the ENTER key",CR,LF
		dc.b	TAB,"do NOT use the backspace/delete keys",CR,LF
		dc.b	"Invalid colours are caught and will NOT count as a guess.",CR,LF,CR,LF
		dc.b	"The computer will tell you how many exact matches",CR,LF
		dc.b	"and colour matches are in your guess.",CR,LF
		dc.b	"A round terminates if you match all 4 colours or exceed 10 guesses."
		dc.b	CR,LF,CR,LF,NULL
		even

ANOTHER:	dc.b	CR,LF,CR,"do you wish to play again? (Y/N)",NULL
		even

HEADER:		dc.b	"Attempt",TAB,"Guess",TAB,"Exact",TAB,"Colour",CR,LF,CR,NULL
		even

NO_MORE:	dc.b	"You are out of guesses - the correct code was: ",NULL
		even

INVALID:	dc.b	"  invalid colour selected - re-enter your guess",CR,LF,CR,NULL
		even
CONGRATS:	dc.b	TAB,"Congratulations -- you have guessed correctly!",CR,LF,CR,NULL
		even