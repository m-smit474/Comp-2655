; Name:		Matt Smith
; MRU E-mail:	msmit474@mtroyal.ca
; Course:	COMP 2655-001
; Assignment:	3, Part 2
; Due Date:	Friday, October 11th, 2019 at 11:59 p.m.
; Instructor:	Paul Pospisil
; 
; Source File:	first.s
;
;
;	This program evaluates the function
;
;		y = ((8 * x^2 - 5 * x + 1997) % 10000) / 10
; User enters the x value and the y value is printed on the next line
;  
;	Assumptions:
; The x value is an unsigned 3 digit integer
; The y value is also an unsigned 3 digit integer
;
;	Limitations:
; Only deals with 3 digit unsigned integers, so largest x value is
; 999 and smallest x value is 000
;
;	Program Status
; Tested and working:
; The parts that were coded for this program were reading in the x value,
; performing the equation above on the x value and printing out the 
; y value. All of these functions are working correctly and were
; tested using the following method:
;
; Testing input/output - This was the first stage of testing and was
;			 done by reading in a single character and
;			 printing out that character. This was done
;			 to see if the subroutines were working
;			 as expected.
;
; Testing calculations - This was done by calculating the out x values
;			 by hand to see what the expected y value is.
;			 Then running the program and comparing the
;			 actual result.
; 
; Test cases - | Input | Expected | Actual | Reason for test |
;		 000	 199	    199	     Smallest x value
;		 999	 101	    101      Largest x value
;		 032	 002	    002	     Single digit output
;		 255	 092	    092	     Two digit output
;		 588	 500	    500	     Trailing 0's in output
;		 400	 999	    999	     Largest y value
;		 653	 000	    000	     Smallest y value
;		 
;
;	Register Table
;d0 - input:  d0 is used to read in byte as a character
;     output: d0 is used to write out a byte as a character
;d1 - the first digit (MS digit)
;d2 - the second digit
;d3 - the third digit (LS digit)
;d4 - the x value
;d5 - holds various values for calculation
;d7 - the y value

;CR	equ	13	   ; Carrage Return (not working)
;LF	equ	10	   ; Line Feed (not working)

start:		move.b	#13,d0	   ; Move cursor to the left
		jsr	write_char ; 
		
		jsr	read_char  ; Read in x value as
		move.b	d0,d1	   ; three character digits
		jsr	read_char  ; 
		move.b	d0,d2      ; 
		jsr	read_char  ; 
		move.b	d0,d3      ; 

		sub.b	#'0',d1    ; Convert characters to
		sub.b	#'0',d2    ; integers
		sub.b	#'0',d3    ; 

		move.w	#0,d4      ; Convert 3 integers
		add.w	d1,d4	   ; to one x value
		mulu.w	#10,d4	   ; 
		add.w	d2,d4	   ; 
		mulu.w	#10,d4	   ; 
		add.w	d3,d4	   ; 


	; Execute formula on x value
		move.w	d4,d5	   ; temp = x
		mulu.w	#8,d5	   ; temp = x * 8
		mulu.w	d4,d5	   ; temp = temp * x
		move.l	d5,d7	   ; y = temp
		mulu.w	#5,d4	   ; x = 5x
		sub.l	d4,d7	   ; y = y - x
		add.l	#1997,d7   ; y = y + 1997
		divu.w	#10000,d7  ; y = y / 10000
		move.w	#0,d7	   ; Clear quotient
		swap	d7	   ; Gets remainder
		divu.w	#10,d7	   ; y = y / 10


	; Seperate y into 3 digits
		move.w	d7,d3	   ; third digit = y
		divu.w	#10,d3     ; get last digit of y
		move.w	#0,d3      ; clear low order bits
		swap	d3         ; puts remainder in LS bits

		move.w	d7,d2	   ; second digit = y
		divu.w	#100,d2    ; get second digit of y
		move.w	#0,d2  	   ; clear low order bits
		swap	d2	   ; move remainder into low bits
		divu.w	#10,d2	   ; gets middle digit

		move.w	d7,d1	   ; get first digit of y
		divu.w	#100,d1	   ;

	; Convert back to characters
		add.b	#'0',d1	   ;
		add.b	#'0',d2	   ;
		add.b	#'0',d3	   ;

	; New line
		move.b	#13,d0	   ; Carrage Return
		jsr	write_char ; 
		move.b	#10,d0	   ; Line Feed
		jsr	write_char ; 

	; Print digits
		move.b	d1,d0	   ; 
		jsr	write_char ;  
		move.b	d2,d0	   ; 
		jsr	write_char ; 
		move.b	d3,d0	   ; 
		jsr	write_char ;  

		jsr	exit


;----- SUBROUTINE: read_char -----
;
; PURPOSE: waits for and reads a single keystroke from the keyboard.
;
; CALLER OUTPUT: returns the ASCII value of the key in the low byte
;                of D0.
;
; IMPORTANT: NOTE THAT THE HIGHER_ORDER BYTES OF D0 ARE UNDEFINED.
;            DON'T ASSUME THEY ARE ZEROED OUT!
;
; E.G. CALL:	jsr	read_char
;		... now use D0.b ...

read_char:	movem.l	d1-d2/a0-a2,-(sp)
		move.w	#1,-(sp)
		trap	#1
		addq.l	#2,sp	
		movem.l	(sp)+,d1-d2/a0-a2
		rts


;----- SUBROUTINE: write_char -----
;
; PURPOSE: writes a single character to the screen.
;
; CALLER INPUT: takes the ASCII value of the character in the low byte
;               of D0.
;
; E.G. CALL:	move.b	#'a',d0
;		jsr	write_char

write_char:	movem.l	d0-d2/a0-a2,-(sp)
		and.w	#$00FF,d0
		move.w	d0,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.l	#4,sp
		movem.l	(sp)+,d0-d2/a0-a2
		rts


;----- SUBROUTINE: exit -----
;
; PURPOSE: terminates the program.  This routine never returns.

exit:		clr.w	-(sp)
		trap	#1
