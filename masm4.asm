;*****************************************************************************
;Name:		David Cruz & Neal Hitzfield
;Program:	MASM4.asm
;Class:		CS3B
;Lab:		MASM4
;Date:		May 3, 2018 at 11:59 PM
;Purpose:
;	Use the String1 and String2 libraries to create a text editor
;*****************************************************************************

.486
.model flat, c
.stack 100h
option casemap:none

ExitProcess 		PROTO Near32 stdcall, dVal:dword
putstring 			PROTO Near32 stdcall, lpStringToPrint:dword
memoryallocBailey	PROTO Near32 stdcall, dSize:dword

extern String_equals: Near32, String_equalsIgnoreCase: Near32,
	   String_copy: Near32, String_substring_1: Near32, String_substring_2: Near32,
	   String_charAt: Near32, String_startsWith_1: Near32, String_startsWith_2: Near32,
	   String_endsWith: Near32
	   
extern String_indexOf_1: Near32, String_indexOf_2:Near32, String_indexOf_3:Near32,
       String_lastIndexOf_1: Near32, String_lastIndexOf_2: Near32, String_lastIndexOf_3: Near32,
       String_concat: Near32, String_replace: Near32, String_toLowerCase: Near32,
	   String_toUpperCase: Near32

	MAX_LINE_LENGTH = 100
	
	Line struct
		text		byte	MAX_LINE_LENGTH dup (?),0
		align 		dword
		next		dword	0
	Line ends

	mMenu macro
		invoke putstring, addr strMenu0
		invoke putstring, addr strMenu1
		invoke putstring, addr strMenu2
		invoke putstring, addr strMenu2a
		invoke putstring, addr strMenu2b
		invoke putstring, addr strMenu3
		invoke putstring, addr strMenu4
		invoke putstring, addr strMenu5
		invoke putstring, addr strMenu6
		invoke putstring, addr strMenu7
		invoke putstring, addr strMenu8
		invoke putstring, addr strMenu9
	endm

.data
	;;;;;;;;;;;;;;;;;;;; MENU ;;;;;;;;;;;;;;;;;;;;;
	strMenu0	byte	4 dup (32), 201,7 dup(205)," MASM 4 TEXT EDITOR ", 7 dup (205),187,13,10,0
	strMenu1	byte	4 dup (32), 186, "<1> View all strings              ",186,13,10,0
	strMenu2	byte	4 dup (32), 186, "<2> Add String                    ",186,13,10,0
	strMenu2a	byte	4 dup (32), 186, "    <a> From Keyboard             ",186,13,10,0
	strMenu2b	byte	4 dup (32), 186, "    <b> From File [input.txt]     ",186,13,10,0
	strMenu3	byte	4 dup (32), 186, "<3> Delete String                 ",186,13,10,0
	strMenu4	byte	4 dup (32), 186, "<4> Edit String                   ",186,13,10,0
	strMenu5	byte	4 dup (32), 186, "<5> String Search                 ",186,13,10,0
	strMenu6	byte	4 dup (32), 186, "<6> Memory Consumption            ",186,13,10,0
	strMenu7	byte	4 dup (32), 186, "<7> Save File                     ",186,13,10,0
	strMenu8	byte	4 dup (32), 186, "<8> Quit                          ",186,13,10,0
	strMenu9	byte	4 dup (32), 200, 34 dup(205),188,13,10,0

	head		dword	0
	tail		dword	0
.code

String_length proc, _string1: ptr byte
	mov eax, 0
	mov esi, _string1

	.while byte ptr [esi] != 0 ; for each character in ESI that is not NULL
		inc esi				   ; move to the next character
		inc eax				   ; increment the count of characters
	.endw
	ret
String_length endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; newLine
; Allocates memory for a new line and places it at the end of the linked list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
newLine proc
	invoke memoryallocBailey, sizeof Line
	mov (Line ptr [eax]).next, 0
	
	.if head == 0
		mov head, eax
	.else
		mov esi, tail
		mov (Line ptr [esi]).next, eax
	.endif

	mov tail, eax
	ret
newLine endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; addLine
; Creates a new node and adds text to it
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
addLine proc, text: ptr byte
	call newLine

	mov esi, text					; store the address of the text to add
	mov edi, eax 					; address to store the text
	mov ecx, 0						; LCV that iterates over each char
	.while byte ptr [esi + ecx] != 0	; iterate until we find a \0 NULL
		mov al, byte ptr [esi + ecx]	; get the char at position ecx
		mov byte ptr [edi + ecx], al	; move it into the string
		inc ecx							; goto next char
	.endw

	ret
addLine endp

printDocument proc
	mov esi, head

	.while esi != 0
		invoke putstring, esi
		mov esi, (Line ptr [esi]).next
	.endw

	ret
printDocument endp

_main:
	mMenu
	push offset strMenu0
	call addLine
	add esp, 4
	push offset strMenu1
	call addLine
	add esp, 4
	push offset strMenu2
	call addLine
	add esp, 4
	push offset strMenu3
	call addLine
	add esp, 4
	push offset strMenu4
	call addLine
	add esp, 4
	call printDocument

	invoke ExitProcess, 0
end _main