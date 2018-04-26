;*****************************************************************************
;Name:		David Cruz & Neal Hitzfield
;Program:	MASM3.asm
;Class:		CS3B
;Lab:		MASM3
;Date:		April 19, 2018 at 11:59 PM
;Purpose:
;	Use the String1 and String2 libraries
;*****************************************************************************

.486
.model flat, c
.stack 100h
option casemap:none

extern String_equals: Near32, String_equalsIgnoreCase: Near32,
	   String_copy: Near32, String_substring_1: Near32, String_substring_2: Near32,
	   String_charAt: Near32, String_startsWith_1: Near32, String_startsWith_2: Near32,
	   String_endsWith: Near32
	   
extern String_indexOf_1: Near32, String_indexOf_2:Near32, String_indexOf_3:Near32,
       String_lastIndexOf_1: Near32, String_lastIndexOf_2: Near32, String_lastIndexOf_3: Near32,
       String_concat: Near32, String_replace: Near32, String_toLowerCase: Near32,
	   String_toUpperCase: Near32
	
	.data
	
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

_main:

end _main