; the test driver program for assignment 6.
; The purpose is to test the 7 string functions
; that the assignment requires the students to
; write. These functions are:
;
; ubyte StrLen (stringType *string)
; ubyte StrSize (stringType *string)
; void StrConcat (stringType *dest, stringType *src, bool *&)
; void SubStr (stringType *dest, ubyte start, ubyte length, stringType *src, bool*)
; int StrScan (stringType *source, stringType *target)
; int StrCmp (stringType *string1, stringType *string2)
; void StrPrint (stringType *string)

	xref	StrLen,StrSize,StrConcat,SubStr,StrScan,StrCmp,StrPrint

	include	C:\devpac\incdir\gemdos.i

GEMDOS	equ	1

; stringType
MAX_SZ	equ	-2
LENGTH	equ	-1
STRING	equ	0

TRUE	equ	-1
FALSE	equ	0

start:
	pea	pgm_header
	jsr	print_cstring
	addq.l	#4,sp

	pea	pause_msg
	jsr	pause
	addq.l	#4,sp


	move.b	#FALSE,d5		; puase msg just printed = FALSE
	pea	test_strings
	jsr	reset
	addq.l	#4,sp
	
	pea	str_start
	jsr	print_cstring
	addq.l	#4,sp
	pea	strings
	jsr	printAll
	addq.l	#4,sp

	pea	pause_msg
	jsr	pause
	addq.l	#4,sp

; StrConcat tests
cat_tst:
	pea	cat_header
	jsr	print_cstring
	addq.l	#4,sp

	lea	cat_src,a2
	lea	cat_dst,a3
	lea	cat_reason,a4
	clr.b	d6						; pause_counter = 0
	move.w	cat_test_count,d7		; number strConcat tests - 8
	subq.w	#1,d7
cat_loop:
	pea	result_flag
	move.l	(a2)+,-(sp)
	move.l	(a3),-(sp)
	pea	src_msg
	pea	dst_msg
	pea	cat_msg
	move.l	(a4)+,-(sp)
	jsr	print_test
	add.l	#16,sp		; clean messages off, leave strings and error on the stack
	jsr	StrConcat

	pea	eoln
	jsr	print_cstring
	addq.l	#4,sp

	pea	result_msg
	jsr	print_cstring
	add.l	#16,sp
	move.l	(a3)+,-(sp)
	jsr	print_one
	addq.l	#4,sp
	tst.b	result_flag
	beq	cat_next
	pea	cat_error
	jsr	print_cstring
	addq.l	#4,sp
cat_next:
	pea	eoln
	jsr	print_cstring
	addq.l	#4,sp

	move.b	#FALSE,d5
	addq.b	#1,d6
	cmp.b	#2,d6
	blo		cat_skip
	move.b	#TRUE,d5
	clr.b	d6
	pea	pause_msg
	jsr	pause
	addq.l	#4,sp
cat_skip:
	dbra	d7,cat_loop

; SubStr tests
	pea	test_strings
	jsr	reset
	addq.l	#4,sp
	
sub_tst:
	tst.b	d5
	bne	sub_omit

	pea	pause_msg
	jsr	pause
	addq.l	#4,sp
sub_omit:
	move.w	#1,d7
	pea	sub_header
	jsr	print_cstring
	addq.l	#4,sp

	lea	sub_src,a2
	lea	sub_dst,a3
	lea	sub_reason,a4
	lea	sub_start,a5
	lea	sub_length,a6
	clr.b	d6						; pause_counter = 0
	move.w	sub_test_count,d7		; number SubStr tests - 7
	subq.w	#1,d7

sub_loop:
	move.l	(a4)+,-(sp)
	jsr	print_cstring
	addq.l	#4,sp
	
	move.l	(a3),-(sp)
	move.l	(a2),-(sp)
	pea	dst_msg
	pea	src_msg
	pea	empty_string
	pea	sub_before
	jsr	print_test
	lea	24(sp),sp
	pea	result_flag
	move.l	(a2),-(sp)
	move.b	(a6)+,-(sp)
	move.b	(a5)+,-(sp)
	move.l	(a3),-(sp)
	jsr	SubStr
	lea	16(sp),sp

	pea	eoln
	jsr	print_cstring
	addq.l	#4,sp
	
	move.l	(a3)+,-(sp)	
	move.l	(a2)+,-(sp)
	pea	dst_msg
	pea	src_msg
	pea	empty_string
	pea	sub_after
	jsr	print_test
	add.l	#24,sp		; clean everything off the stack

	tst.b	result_flag
	beq	sub_next
	pea	sub_error
	jsr	print_cstring
	addq.l	#4,sp
sub_next:
	pea	eoln
	jsr	print_cstring
	addq.l	#4,sp

	move.b	#FALSE,d5
	addq.b	#1,d6
	cmp.b	#2,d6
	blo		sub_skip
	move.b	#TRUE,d5
	clr.b	d6
	pea	pause_msg
	jsr	pause
	addq.l	#4,sp
sub_skip:
	dbra	d7,sub_loop

; StrScan tests
	pea	test_strings
	jsr	reset
	addq.l	#4,sp
	
scan_tst:
	tst.b	d5
	bne	scan_omit
	pea	pause_msg
	jsr	pause
	addq.l	#4,sp
scan_omit:
	pea	sc_header
	jsr	print_cstring
	addq.l	#4,sp
	
	lea	sc_src,a2
	lea	sc_tgt,a3
	lea	sc_reason,a4
	clr.b	d6						; pause_counter = 0
	move.w	sc_test_count,d7		; number StrScan tests - 9
	subq.w	#1,d7
scan_loop:
	subq.l	#2,sp
	move.l	(a3)+,-(sp)
	cmp.w	#2,d7
	bhi	scan_ignore
	bne	scan_chg_8
	move.l	(sp),a5
	move.b	#3,-1(a5)
	move.b	#"t",(a5)+
	move.b	#"h",(a5)+
	move.b	#"e",(a5)+
	bra	scan_ignore
scan_chg_8:
	cmp.w	#1,d7
	bne	scan_chg_9
	move.l	(sp),a5
	move.b	#7,-1(a5)
	move.b	#"j",(a5)+
	move.b	#"u",(a5)+
	move.b	#"m",(a5)+
	move.b	#"p",(a5)+
	move.b	#"e",(a5)+
	move.b	#"d",(a5)+
	move.b	#" ",(a5)
	bra	scan_ignore
scan_chg_9:
	move.l	(sp),a5
	move.b	#3,-1(a5)
	move.b	#"d",(a5)+
	move.b	#"o",(a5)+
	move.b	#"g",(a5)+
	
scan_ignore:	
	move.l	(a2)+,-(sp)
	pea	target_msg
	pea	source_msg
	pea	sc_msg
	move.l	(a4)+,-(sp)
	jsr	print_test
	lea	16(sp),sp		; clean messages off, leave strings and result space on the stack

	jsr	StrScan
	addq.l	#8,sp
	
	pea	eoln
	jsr	print_cstring
	addq.l	#4,sp

	move.w	(sp)+,d0
	bmi	scan_not_found
	pea	sc_found
	jsr	print_cstring
	addq.l	#4,sp
	move.b	d0,-(sp)
	jsr	write_number
	addq.l	#2,sp
	pea	eoln
	jsr	print_cstring
	addq.l	#4,sp
	bra	scan_next
scan_not_found:
	pea	sc_notfound
	jsr	print_cstring
	addq.l	#4,sp
scan_next:
	pea	eoln
	jsr	print_cstring
	addq.l	#4,sp

	move.b	#FALSE,d5
	addq.b	#1,d6
	cmp.b	#3,d6
	blo		scan_skip
	move.b	#TRUE,d5
	clr.b	d6
	pea	pause_msg
	jsr	pause
	addq.l	#4,sp
scan_skip:
	dbra	d7,scan_loop

; StrCmp tests
	pea	test_strings
	jsr	reset
	addq.l	#4,sp
	
cmp_tst:
	tst.b	d5
	bne	cmp_omit
	clr.b	d6
	pea	pause_msg
	jsr	pause
	addq.l	#4,sp
cmp_omit:
	pea	cmp_header
	jsr	print_cstring
	addq.l	#4,sp
	lea	cmp_reason,a4
	lea	compares,a3
	move.w	cmp_test_count,d7		; number StrCmp tests - 6
	subq.w	#1,d7
cmp_lp:
	subq.l	#2,sp
	move.l	(a3)+,-(sp)
	move.l	(a3)+,-(sp)
	pea	cmp_str2
	pea	cmp_str1
	pea	cmp_msg
	move.l	(a4)+,-(sp)
	jsr	print_test
	lea	16(sp),sp		; clean messages off, leave strings and result space on the stack

	pea	eoln
	jsr	print_cstring
	addq.l	#4,sp
	
	jsr	StrCmp
	addq.l	#8,sp
	tst.w	(sp)+
	beq	prt_eq
	blt	prt_less
	pea	cmp_great
	bra	prt_msg
prt_eq:	pea	cmp_eq
	bra	prt_msg
prt_less:
	pea	cmp_less
prt_msg:
	jsr	print_cstring
	addq.l	#4,sp

	pea	eoln
	jsr	print_cstring
	addq.l	#4,sp
	
	addq.b	#1,d6
	cmp.b	#3,d6
	blo		prt_skip
	clr.b	d6
	pea	pause_msg
	jsr	pause
	addq.l	#4,sp
prt_skip:
	dbra	d7,cmp_lp

done:	jsr	Exit
	clr.w	-(sp)
	move.w	#p_term,-(sp)
	trap	#GEMDOS

pgm_header:
	dc.b	"This program relies on the StrSize, StrLen and StrPrint from YOUR Strlib",13,10
	dc.b	"If they do NOT exist this program will not function correctly!",13,10,0
	
str_start:
	dc.b	"Strings being used are:",10,13,0
	even
strings:
	dc.l	s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,0

test_strings:
	dc.b	40
	dc.b	0
s0:	ds.b	40

	dc.b	25
	dc.b	0
s1:	ds.b	25

	dc.b	30
	dc.b	0
s2:	ds.b	30

	dc.b	20
	dc.b	0
s3:	ds.b	20

	dc.b	44
	dc.b	0
s4:	ds.b	44

	dc.b	25
	dc.b	0
s5:	ds.b	25

	dc.b	20
	dc.b	0
s6:	ds.b	20

	dc.b	50
	dc.b	0
s7:	ds.b	50

	dc.b	5
	dc.b	0
s8:	ds.b	5

	dc.b	13
	dc.b	0
s9:	ds.b	13

	dc.b	10
	dc.b	0
s10:	ds.b	10

empty_string:
		dc.b	0
eoln:	dc.b	10,13,0,0
pause_msg:
	dc.b	"Press any key to continue",13,10,0

	even
cat_header
	dc.b	10,13,"StrConcat tests",10,13,0
cat_test1:
	dc.b	"1 - Join two empty strings",10,13,0
cat_test2:
	dc.b	"2 - Dest is !empty - src is empty - result is dest",10,13,0
cat_test3:
	dc.b	"3 - Dest is empty - src is !empty - result fits",10,13,0
cat_test4:
	dc.b	"4 - both !empty - dest is full - join would overflow dest",10,13,0
cat_test5:
	dc.b	"5 - both !empty - src is full - join would overflow dest",10,13,0
cat_test6:
	dc.b	"6 - both !empty - join would overflow dest",10,13,0
cat_test7:
	dc.b	"7 - both !empty - result exactly fits into dest",10,13,0
cat_test8:
	dc.b	"8 - both !empty - after dest.size < dest.max",10,13,0
src_msg:	dc.b	"SRC:  ",0
dst_msg:	dc.b	"DEST: ",0
result_msg:	dc.b	"RESULT: ",0
cat_msg:
	dc.b	"concatenated with",10,13,0
cat_error:
	dc.b	"*** ERROR: Destination does not have sufficient space",10,13,0
cc_bad:	dc.b	"invalid concat -- dest is now:",10,13,0

	even
cat_test_count:
	dc.w	8
cat_reason:
	dc.l	cat_test1,cat_test2,cat_test3,cat_test4,cat_test5,cat_test6
	dc.l	cat_test7,cat_test8,0

cat_src:
	dc.l	s9,s8,s2,s10,s4,s2,s3,s6
cat_dst:
	dc.l	s8,s3,s9,s4,s10,s9,s9,s1


sub_header:
	dc.b	10,13,"SubStr tests",10,13,0
sub_t1:	dc.b	"1 - SubStr (empty, 10, 6, !empty but 10 > src.used) --> empty dst & ERROR",10,13,0
sub_t2:	dc.b	'2 - SubStr (empty, 0 , 0 , empty) --> empty dst',10,13,0
sub_t3:	dc.b	'3 - SubStr ("this is a string", 10, 6, dest) --> dest = "strin" & ERROR',10,13,0
sub_t4:	dc.b	'4 - SubStr ("not my", 0, 0,  "a hazy day") --> dest = ""',10,13,0
sub_t5:	dc.b	'5 - SubStr ("the quick brown...", 0, 13, "") from start --> dest = "the quick bro"',10,13,0
sub_t6:	dc.b	'6 - SubStr ("a hazy day", 4, 1, "") from middle of src and length == 1 --> dest = "z"',10,13,0
sub_t7:	dc.b	'7 - SubStr ("the quick brown ... dog", 41, 3, "") from end of src --> dest = "dog"',10,13,0
sub_before:
	dc.b	"BEFORE performing SubStr",10,13,0
sub_after:
	dc.b	"AFTER performing SubStr",10,13,0
sub_error:
	dc.b	"*** ERROR: SubStr generated an error",10,13,0
result_flag:
	dc.b	0
	even
sub_test_count:
	dc.w	7
sub_reason:
	dc.l	sub_t1,sub_t2,sub_t3,sub_t4,sub_t5,sub_t6,sub_t7,0

sub_src:
	dc.l	s1,s9,s0,s6,s4,s6,s4
sub_dst:
	dc.l	s10,s8,s8,s3,s9,s7,s8
sub_start:
	dc.b	10,0,10,0,0,4,41
sub_length:
	dc.b	6,0,6,0,13,1,3
		
sc_header:	dc.b	10,13,"StrScan tests",10,13,0
target_msg:	dc.b	"TARGET:  ",0
source_msg:	dc.b	"SOURCE:  ",0
sc_t1:	dc.b	"1 - scan for empty target in empty src",10,13,0
sc_t2:	dc.b	'2 - scan for non-empty target in empty src',10,13,0
sc_t3:	dc.b	'3 - scan for empty target in non-empty src',10,13,0
sc_t4:	dc.b	'4 - both non-empty src.len < target.length',10,13,0
sc_t5:	dc.b	'5 - both non-empty src.len >= target.length, but not found',10,13,0
sc_t6:	dc.b	'6 - both non-empty src.len == target.length & found',10,13,0
sc_t7:	dc.b	'7 - both non-empty src.len > target.length & found at start',10,13,0
sc_t8:	dc.b	'8 - both non-empty src.len > target.length & found in middle',10,13,0
sc_t9:	dc.b	'9 - both non-empty src.len > target.length & found at send',10,13,0

sc_found:
	dc.b	"*** Target found in source at position: ",0
sc_notfound:
	dc.b	"*** Target NOT found in source",10,13,0
sc_msg:
	dc.b	"scanned for",10,13,0
	even
sc_test_count:
	dc.w	9
sc_reason:
	dc.l	sc_t1,sc_t2,sc_t3,sc_t4,sc_t5,sc_t6,sc_t7,sc_t8,sc_t9,0

sc_src:
	dc.l	s8,s8,s4,s10,s4,s5,s4,s4,s4
sc_tgt:
	dc.l	s9,s10,s9,s1,s1,s2,s10,s10,s10

cmp_header:
	dc.b	10,13,"StrCmp tests",10,13,0
cmp_str1:	dc.b	"STR1:  ",0
cmp_str2:	dc.b	"STR2:  ",0
cmp_t1:	dc.b	"1 -  STR1 == STR2 - both Empty strings",10,13,0
cmp_t2:	dc.b	'2 - STR1 < STR2 - str1 is Empty string',10,13,0
cmp_t3:	dc.b	'3 - STR1 > STR2 - str2 is Empty string',10,13,0
cmp_t4:	dc.b	'4 - STR1 == STR2',10,13,0
cmp_t5:	dc.b	'5 - STR1 < STR2',10,13,0
cmp_t6:	dc.b	'6 - STR1 > STR2',10,13,0
cmp_msg:
	dc.b	"compared with",10,13,0
cmp_eq:
	dc.b	"str1 == str2",10,13,0
cmp_less:
	dc.b	"str1 < str2",10,13,0
cmp_great:
	dc.b	"str1 > str2",10,13,0
	even

cmp_test_count:
	dc.w	6
cmp_reason:
	dc.l	cmp_t1,cmp_t2,cmp_t3,cmp_t4,cmp_t5,cmp_t6,0
compares:
	dc.l	s9,s8,s2,s9,s7,s5,s2,s5,s3,s1,s4,s0

	even

; void printAll (stringType* str[])

PA_ARY	equ	8

printAll:
	link	a6,#0
	movem.l	d0-d5/a0-a3,-(sp)

	move.l	PA_ARY(a6),a3
	clr.w	d5
	clr.b	d4
pa_loop:
	tst.l	(a3)			; end of array?
	beq	pa_done

	pea	pa_msg			; write title
	jsr	print_cstring
	addq.l	#4,sp
	move.b	d4,-(sp)
	jsr	write_number
	addq.l	#2,sp
	addq.b	#1,d4
	pea	eoln
	jsr	print_cstring
	addq.l	#4,sp

	move.l	(a3)+,-(sp)
	jsr	print_one
	addq.l	#4,sp
	bra	pa_loop

pa_done:
	movem.l	(sp)+,d0-d5/a0-a3
	unlk	a6
	rts

pa_msg:	dc.b	"String ",0


print_one:
	link	a6,#0
	movem.l	d0-d4/a0-a3,-(sp)

	move.l	8(a6),a3		; print 3 items of string

	pea	quote_str
	jsr	print_cstring
	addq.l	#4,sp
	
	move.l	a3,-(sp)
	jsr	StrPrint
	addq.l	#4,sp

	pea	quote_str
	jsr	print_cstring
	addq.l	#4,sp
	
	pea	len_str
	jsr	print_cstring
	addq.l	#4,sp
	
	subq.l	#2,sp
	move.l	a3,-(sp)
	jsr	StrLen
	addq.l	#4,sp
	jsr	write_number
	addq.l	#2,sp

	pea	max_str
	jsr	print_cstring
	addq.l	#4,sp

	subq.l	#2,sp
	move.l	a3,-(sp)
	jsr	StrSize
	addq.l	#4,sp
	jsr	write_number
	addq.l	#2,sp

	pea	eoln
	jsr	print_cstring
	addq.l	#4,sp

	movem.l	(sp)+,d0-d4/a0-a3
	unlk	a6
	rts

quote_str:
	dc.b '"',0
len_str:
	dc.b	"  len = ",0
max_str:
	dc.b	"  max = ",0

PC_STR	equ	8

print_cstring:
	link	a6,#0
	movem.l	d0-d2/a0-a3,-(sp)
	move.l	PC_STR(a6),-(sp)
	move.w	#c_conws,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp
	movem.l	(sp)+,d0-d2/a0-a3
	unlk	a6
	rts

PS_MSG	equ	8
pause:	link	a6,#0
	movem.l	d0-d2/a0-a2,-(sp)

	move.l	PS_MSG(a6),-(sp)
	jsr	print_cstring
	addq.l	#4,sp

	move.w	#c_necin,-(sp)
	trap	#GEMDOS
	addq.l	#2,sp

	pea	eoln
	jsr	print_cstring
	addq.l	#4,sp

	movem.l	(sp)+,d0-d2/a0-a2
	unlk	a6
	rts

; void write_number (byte number)

;  This procedure writes out a byte sized number to the screen.

; ALGORITHM
;  The digits are extracted in reverse order, so the stack is used for
;  digit reversal

; REGISTER TABLE
; d0	- number to print
; d1	- digit counter
; d2	- remainder of division
;	- character to print
;
; a6	- Frame Pointer


WN_NUMBER	EQU	8		; number offset in stack

write_number:
	link	a6,#0
	movem.l	d0-2/a0-a2,-(sp)
	clr.l	d1			; char_counter = 0
	clr.l	d0
	move.b	WN_NUMBER(a6),d0	; number

wn_digits:
	divu	#10,d0
	swap	d0
	move.w	d0,-(sp)
	addq.w	#1,d1
	clr.w	d0
	swap	d0
	bne	wn_digits
	subq.w	#1,d1			; reduce counter for dbra
wn_print:				; since digits are on stack 
					; use each in place
	add.w	#"0",(sp)		; convert digit to char
	move.w	#c_conout,-(sp)
	trap	#GEMDOS
	addq.w	#4,sp			; remove fn # and character
	dbra	d1,wn_print		; while counter > -1

	movem.l	(sp)+,d0-d2/a0-a2
	unlk	a6
	rts

Exit:
	pea	e_msg
	jsr	pause
	addq.l	#4,sp
	clr.w	-(sp)
	move.w	#p_term,-(sp)
	trap	#GEMDOS

e_msg:	dc.b	"Press any key to exit",0
; void print_test (mesg1, mesg2, op1_mesg, op2_mesg, op1, op2)
PT_mesg1	equ	8
PT_mesg2	equ	12
PT_d_mesg	equ	16
PT_s_mesg	equ	20
PT_dst	equ	24
PT_src	equ	28

print_test:
	link	a6,#0
	movem.l	d0/a0,-(sp)

	move.l	PT_mesg1(a6),-(sp)
	jsr	print_cstring

	move.l	PT_d_mesg(a6),(sp)
	jsr	print_cstring

	move.l	PT_dst(a6),(sp)
	jsr	print_one
	
	move.l	PT_mesg2(a6),(sp)
	jsr	print_cstring

	move.l	PT_s_mesg(a6),(sp)
	jsr	print_cstring

	move.l	PT_src(a6),(sp)
	jsr	print_one
	addq.l	#4,sp
	
	movem.l	(sp)+,d0/a0
	unlk	a6
	rts

void reset (long block[])
R_BLOCK	equ	8
reset:	
	link	a6,#0
	movem.l	d0-d1/a0-a1,-(sp)
	move.l	total_sz,d0
	divu	#4,d0
	move.w	d0,d1			; number of lonwords in memory block
	subq.w	#1,d1
	clr.w	d0
	swap d0					; number of extra bytes in memory block
	move.l	R_BLOCK(a6),a0
	lea		original,a1
shift_loop:
	move.l	(a1)+,(a0)+
	dbra	d1,shift_loop
extra_loop:
	tst.w	d0
	beq	reset_done
	move.b	(a1)+,(a0)+
	subq.w	#1,d0
	bra	extra_loop
reset_done:	
	movem.l	(sp)+,d0/a0
	unlk	a6
	rts

original:
	dc.b	40
	dc.b	16
o_s0:
	dc.b	"this is a string"
	ds.b	24
	dc.b	25
	dc.b	6
o_s1:
	dc.b	"not me"
	ds.b	19
	dc.b	30
	dc.b	7
o_s2:
	dc.b	"abb acf"
	ds.b	23
	dc.b	20
	dc.b	6
o_s3:
	dc.b	"not my stuff"
	ds.b	8
	dc.b	44
	dc.b	44
o_s4:
	dc.b	"the quick brown fox jumped over the lazy dog"
;		     1234567890123456789012345678901234567890123456789012345
	dc.b	25
	dc.b	7
o_s5:
	dc.b	"abb acf"
	dc.b	"even more stuff"
	ds.b	3
	dc.b	20
	dc.b	10
o_s6:
	dc.b	"a hazy day"
	ds.b	10
	dc.b	50
	dc.b	0
o_s7:
;		     1234567890123456789012345678901234567890123456789012345
	dc.b	"there is actually stuff here, but not visible"
	ds.b	5
	dc.b	5
	dc.b	0
o_s8:
	dc.b	"short"
	dc.b	13
	dc.b	0
o_s9:
	ds.b	13
	dc.b	10
	dc.b	1
o_s10:
	dc.b	'z'
	ds.b	9
	even
the_end:
total_sz
	dc.l	total_sz-original
