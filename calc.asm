TITLE Sum and Average Calculator with Input Validation     (Proj6_SCRUGHAP.asm)

; Author: Paul Scrugham
; Last Modified: 3/14/2021
; OSU email address: scrughap@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 3/14/2021
; Description: A program that prompts the user to enter signed integers, displays the array of integers
;	entered, the sum, and the average. 
;	- Implements the procedure ReadVal to convert the ASCII user input into integer values, validates 
;	that the ASCII characters are signed integers and fit in a 32-bit register, and stores the resulting integer 
;	value in a location in memory.
;	- Implements the procedure WriteVal to convert a signed integer to its ASCII character representation
;	and writes the ASCII representation to the console.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Prints a text prompt and receives a user input signed integer as ASCII values
;
; Preconditions: None
;
; Postconditions: changes registers EAX, ECX, EDX
;
; Receives:
;	prompt = string to print before user input
;	input_address = address to store string
;	count = maximum size of input string
;	num_bytes = address of parameter
;
; Returns: 
;	input_address = address of input string
;	num_bytes = address containing the number of characters entered
; ---------------------------------------------------------------------------------
mGetString MACRO prompt:REQ, input_address:REQ, count:REQ, num_bytes:REQ
	PUSH	EAX
	PUSH	ECX
	PUSH	EDX
	MOV		EDX, prompt
	CALL	WriteString
	
	MOV		EDX, input_address
	MOV		ECX, count
	CALL	ReadString
	MOV		num_bytes, EAX
	POP		EDX
	POP		ECX
	POP		EAX

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints a string at an address in memory
;
; Preconditions: None
;
; Postconditions: changes register EDX
;
; Receives: output_address = string address
;
; Returns: None (prints a string to the console)
; ---------------------------------------------------------------------------------
mDisplayString MACRO input_address:REQ
	PUSH	EDX
	MOV		EDX, input_address
	CALL	WriteString
	POP		EDX

ENDM

NUM_ARRAY_SIZE	EQU		10
STRING_MAX_SIZE	EQU		20

.data

num_array	SDWORD	NUM_ARRAY_SIZE DUP(?)
inString	BYTE	STRING_MAX_SIZE DUP(?)
outString	BYTE	STRING_MAX_SIZE DUP(?)
inBytes		DWORD	?
sum			SDWORD	0
average		SDWORD	?
outNum		SDWORD	0
intro_1		BYTE	"Sum and Average Calculator with Input Validation, by Paul Scrugham.",13,10,0
prompt_1	BYTE	"Please provide 10 signed decimal integers.",13,10
			BYTE	"Each number must fit inside a 32 bit register. After entering the numbers, "
			BYTE	"the list of numbers, their sum, and average will be displayed.",13,10,0
prompt_2	BYTE	"Please enter a signed number: ",0
prompt_3	BYTE	"You entered the following numbers:",13,10,0
prompt_4	BYTE	"The sum of these numbers is: ",13,10,0
prompt_5	BYTE	"The rounded average is: ",13,10,0
prompt_6	BYTE	"Thanks for using the Sum and Average Calculator!",13,10,0
prompt_7	BYTE	"   The running subtotal is: ",0
prompt_8	BYTE	"   Please try again: ",0
spacing		BYTE	". ",0
invalid_1	BYTE	"   ERROR: please enter a signed number that fits in a 32-bit register.",13,10,0
e_credit_1	BYTE	"EC #1: Number each line of user input and display a running subtotal of the user’s valid numbers.",13,10,0

.code
main PROC
;	write name of program and programmer to console
	mDisplayString OFFSET intro_1
	CALL	CrLf

;	write extra credit description
	mDisplayString OFFSET e_credit_1
	CALL	CrLf

;	write description of program to console
	mDisplayString OFFSET  OFFSET prompt_1
	CALL	CrLf

;	get user input as string and store integers in array
	MOV		ECX, NUM_ARRAY_SIZE
	MOV		EDI, OFFSET num_array

_inputVals:
;	number user input
	MOV		EBX, NUM_ARRAY_SIZE
	SUB		EBX, ECX
	INC		EBX
	PUSH	EBX
	PUSH	OFFSET inString
	PUSH	OFFSET outString
	CALL	WriteVal
	mDisplayString OFFSET spacing

;	call ReadVal to get integers inputs as strings
	PUSH	OFFSET prompt_8
	PUSH	OFFSET outNum
	PUSH	STRING_MAX_SIZE
	PUSH	OFFSET invalid_1
	PUSH	OFFSET inBytes
	PUSH	OFFSET inString
	PUSH	OFFSET prompt_2
	CALL	ReadVal

;	store validated number in array
	MOV		EAX, outNum
	MOV		[EDI], EAX
	ADD		EDI, TYPE num_array

;	accumulate sum
	ADD		sum, EAX

;	write message for subtotal
	mDisplayString OFFSET prompt_7

;	write value for subtotal
	PUSH	sum
	PUSH	OFFSET inString
	PUSH	OFFSET outString
	CALL	WriteVal
	CALL	CrLf

	DEC		ECX
	CMP		ECX, 0
	JNE		_inputVals
	CALL	CrLf

;	write message to console for array printing
	mDisplayString OFFSET prompt_3

;	write values from array to console
	MOV		ESI, OFFSET num_array
	MOV		ECX, NUM_ARRAY_SIZE

_outputVals:
; loop through values in array
;	call WriteVal to print integers as strings to the console
	MOV		EAX, [ESI]
	PUSH	EAX
	PUSH	OFFSET inString
	PUSH	OFFSET outString
	CALL	WriteVal

;	separate printed values with comma and space
	CMP		ECX, 1
	JE		_incCounter
	MOV		AL, ','
	CALL	WriteChar
	MOV		AL, ' '
	CALL	WriteChar

_incCounter:
	ADD		ESI, TYPE num_array
	LOOP	_outputVals

	CALL	CrLf
	CALL	CrLf

;	print sum message to console
	mDisplayString OFFSET prompt_4

;	call WriteVal to print integer sum to console as string
	PUSH	sum
	PUSH	OFFSET inString
	PUSH	OFFSET outString
	CALL	WriteVal

	CALL	CrLf
	CALL	CrLf

;	find average of numbers
	MOV		EAX, sum
	MOV		EBX, NUM_ARRAY_SIZE
	CDQ
	IDIV	EBX
	MOV		average, EAX

;	print average message to console
	mDisplayString OFFSET prompt_5

;	call WriteVal to print integer average to console as string
	PUSH	average
	PUSH	OFFSET inString
	PUSH	OFFSET outString
	CALL	WriteVal
	CALL	CrLf
	CALL	CrLf

;	print farewell message
	mDisplayString OFFSET prompt_6

	Invoke ExitProcess,0		; exit to operating system
main ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Prompts the user for an integer input from the console as a string and converts 
;	it to an integer value stored in memory. Validates that the input string only 
;	contains integer values, with the exception of a '+' or '-' at the front to 
;	indicate sign.
;
; Preconditions: Input string must represent a signed integer value that fits in
;	a 32-bit register. ReadVal will print an error message if the converted
;	integer is larger.
;
; Postconditions: Updates the value at output address to the converted, signed
;	integer value. Changes registers EAX, EBX, ECX, EDX, ESI, EDI.
;
; Receives: 
;	[EBP + 32]	= address for prompt to retry entry after invalid input
;	[EBP + 28]	= address for output integer value
;	[EBP + 24]	= maximum size for input string
;	[EBP + 20]	= address for error message 
;	[EBP + 16]	= address to store number of bytes (characters) from the input string
;	[EBP + 12]	= address of input string
;	[EBP + 8]	= address of prompt to print at each user entry
;
; Returns:
;	[EBP + 28]	= address for output integer value
;	Changes values at address in [EBP + 16], [EBP + 12]
; ---------------------------------------------------------------------------------
ReadVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI

_inputLoop:
;	macro to get input string and the number of bytes entered
	mGetString [EBP + 8], [EBP + 12], [EBP + 24], [EBP + 16]
	JMP		_initialize

_retryInput:
;	macro with prompt for retrying a valid input
	mGetString [EBP + 32], [EBP + 12], [EBP + 24], [EBP + 16]
	
_initialize:
	MOV		ECX, [EBP + 16]
	MOV		ESI, [EBP + 12]
	MOV		EDI, [EBP + 28]
	MOV		EAX, 0
	MOV		[EDI], EAX					; clear value at address of output integer

;	loop through string at ESI to validate input
_validateInput:
	MOV		EAX, 0
	LODSB

;	check if first value in string is a '+' or '-'
	CMP		ECX, [EBP + 16]
	JNE		_checkRange
	CMP		AL, '-'
	JE		_charTest
	CMP		AL, '+'
	JE		_charTest

_checkRange:
	SUB		AL, 48						; convert ACSII representation to integer
	CMP		AL, 0
	JB		_invalidInput 
	CMP		AL, 9
	JA		_invalidInput

;	test if first value of input string is '-'
	MOV		EDX, [EBP + 12]				; reset EDX to starting address of inString in EDX
	PUSH	EAX
	MOV		EAX, [EDX]
	CMP		AL, '-'
	POP		EAX
	JE		_accumulateNegative
	
;	accumulate integers for positive number
	MOV		EBX, EAX					; store input integer
	MOV		EAX, 10
	IMUL	EAX, [EDI]
	ADD		EAX, EBX
	JO		_invalidInput				; check for overflow
	JMP		_updateMemory

_accumulateNegative:
;	accumulate integers for negative number
	MOV		EBX, EAX					; store input integer
	MOV		EAX, 10
	IMUL	EAX, [EDI]
	SUB		EAX, EBX
	JO		_invalidInput				; check for overflow

_updateMemory:
;	move new value to memory
	MOV		[EDI], EAX					

_innerLoopEnd:
	LOOP	_validateInput
	JMP		_end

_charTest:
	CMP		ECX, 1
	JNE		_innerLoopEnd				; checks if the only character entered was '+' or '-'

_invalidInput:
;	print error message
	mDisplayString [EBP + 20]
	JMP		_retryInput
	
_end:
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		28

ReadVal ENDP


; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Takes a signed integer, converts it to a string of ASCII characters, and prints
;	the result to the console.
;
; Preconditions: input value must be a signed integer and fit in a 32-bit register
;
; Postconditions: Updates the value at output address to the converted, signed
;	integer value. Changes registers EAX, EBX, ECX, ESI, EDI.
;
; Receives: 
;	[EBP + 16]	= input value (integer) to print
;	[EBP + 12]	= address of string to store initial conversion (reversed string)
;	[EBP + 8]	= address of string to store final result of conversion
;
; Returns:
;	[EBP + 8]	= address of string with final result of conversion
;	Changes values at address in [EBP + 12]
; ---------------------------------------------------------------------------------
WriteVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	ESI
	PUSH	EDI
	
	MOV		EDI, [EBP + 12]
	MOV		ECX, 0
	MOV		EAX, [EBP + 16]

;	negate EAX if negative val
	CMP		EAX, 0
	JGE		_convertInt
	NEG		EAX

_convertInt:
; loop to convert each digit of integer to ASCII equivalent
	CMP		EAX, 10
	JB		_end

;	divide integer by 10 and store ASCII equivalent of remainder
	CDQ
	MOV		EBX, 10
	IDIV	EBX
	PUSH	EAX
	MOV		EAX, EDX					; save remainder to convert to string
	ADD		EAX, 48						; convert to ASCII equivalent value
	
;	store ASCII value in string array
	CLD
	STOSB
	INC		ECX
	POP		EAX
	JMP		_convertInt

_end:
; convert last digit to ASCII
	ADD		EAX, 48
	CLD
	STOSB
	INC		ECX

; reverse string of ASCII characters (conversion routine creates a reversed string)
;	copy outString to inString
	MOV		ESI, [EBP + 12]
	MOV		EDI, [EBP + 8]
	ADD		ESI, ECX					; set ESI to end of string
	DEC		ESI

;	add '-' to output string if input integer is negative
	MOV		EAX, [EBP + 16]
	CMP		EAX, 0
	JGE		_reverseLoop
	MOV		AL, '-'
	STOSB

_reverseLoop:
; copy ESI into EDI starting at the end of ESI and beginning of EDI
	STD
	LODSB
	CLD
	STOSB
	LOOP	_reverseLoop

	MOV		EAX, 0						; NULL terminate string
	STOSB

;	call macro to write string to console
	mDisplayString [EBP + 8]

	POP		EDI
	POP		ESI
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		12

WriteVal ENDP

END main
