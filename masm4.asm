;*****************************************************************************
;Name:		David Cruz & Neal Hitzfield
;Program:	MASM4.asm
;Class:		CS3B
;Lab:		MASM4
;Date:		May 10, 2018 at 11:59 PM
;Purpose:
;	Use the String1 and String2 libraries to create a text editor
;*****************************************************************************

.486
.model flat, c
.stack 100h
option casemap:none

include     \masm32\include\windows.inc
include     \masm32\include\kernel32.inc
include     \masm32\include\user32.inc
includelib  \masm32\lib\kernel32.lib
includelib  \masm32\lib\user32.lib

ExitProcess 		PROTO Near32 stdcall, dVal:dword
putstring 			PROTO Near32 stdcall, lpStringToPrint:dword
memoryallocBailey	PROTO Near32 stdcall, dSize:dword
getstring			PROTO Near32 stdcall, lpStringToGet:dword, dlength:dword
ascint32			PROTO Near32 stdcall, lpStringToConvert:dword  
intasc32			PROTO Near32 stdcall, lpStringToHold:dword, dval:dword

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
		invoke putstring, addr strMenuTop
		invoke putstring, addr strMenuMem
		mPrintMem
		invoke putstring, addr strMenuByte
		invoke putstring, addr strMenuSep
		invoke putstring, addr strMenu1
		invoke putstring, addr strMenu2
		invoke putstring, addr strMenu2a
		invoke putstring, addr strMenu2b
		invoke putstring, addr strMenu3
		invoke putstring, addr strMenu4
		invoke putstring, addr strMenu5
		invoke putstring, addr strMenu6
		invoke putstring, addr strMenu7
		invoke putstring, addr strMenuEnd
	endm

	mInput macro
		invoke putstring, addr strInputPrompt
		invoke getstring, addr strInput, 2
		
		push offset strInput

		push offset strOption1
		call String_equalsIgnoreCase
		add esp, 4	; leave strInput on stack
		.if al == 1
			invoke putstring, addr strCrlf
			invoke putstring, addr strCrlf
			call printDocument
			jmp INPUT_END
		.endif

		push offset strOption2a
		call String_equalsIgnoreCase
		add esp, 4
		.if al == 1
			call getLineKeyboard
			jmp INPUT_END
		.endif

		push offset strOption2b
		call String_equalsIgnoreCase
		add esp, 4
		.if al == 1
		    call getFromFile
		    jmp INPUT_END
		.endif

		push offset strOption3
		call String_equalsIgnoreCase
		add esp, 4
		.if al == 1
			call deletePrompt
			jmp INPUT_END
		.endif

		push offset strOption4
		call String_equalsIgnoreCase
		add esp, 4
		.if al == 1
			call editPrompt
			jmp INPUT_END
		.endif

		push offset strOption5
		call String_equalsIgnoreCase
		add esp, 4
		.if al == 1
			call searchPrompt
			jmp INPUT_END
		.endif

		push offset strOption7
		call String_equalsIgnoreCase
		add esp, 4
		.if al == 1
			mov bShouldExit, 1
			jmp INPUT_END
		.endif

		invoke putstring, addr strInvalidCommand

	INPUT_END: 
		invoke putstring, addr strCrlf
		invoke putstring, addr strCrlf
		add esp, 4 ; clean up command from stack, then continue
	endm

	mPrintDocLine macro line
		invoke putstring, addr strDocumentLeft

		.if dLineNum <= 999
			invoke putstring, addr strSpace
		.endif
		.if dLineNum <= 99
			invoke putstring, addr strSpace
		.endif
		.if dLineNum <= 9
			invoke putstring, addr strSpace
		.endif

		invoke intasc32, addr strLineNum, dLineNum
		invoke putstring, addr strLineNum

		invoke putstring, addr strDocumentSep
		invoke putstring, line

		push line
		call String_length
		pop line
		mov cx, MAX_LINE_LENGTH
		sub cx, ax
		.repeat
			invoke putstring, addr strSpace
		.untilcxz

		invoke putstring, addr strDocumentRight
		inc dLineNum
	endm

	mPrintSearchLine macro line, lineNum
		invoke putstring, addr strSearchLeft

		.if lineNum <= 999
			invoke putstring, addr strSpace
		.endif
		.if lineNum <= 99
			invoke putstring, addr strSpace
		.endif
		.if lineNum <= 9
			invoke putstring, addr strSpace
		.endif

		invoke intasc32, addr strLineNum, lineNum
		invoke putstring, addr strLineNum

		invoke putstring, addr strSearchSep
		invoke putstring, line

		push line
		call String_length
		add esp, 4
		
		mov cx, MAX_LINE_LENGTH
		sub cx, ax
		.repeat
			invoke putstring, addr strSpace
		.untilcxz

		invoke putstring, addr strSearchRight
	endm

	mPrintMem macro
		invoke intasc32, addr strMemUse, dMemUse

		.if dMemUse <= 9999999
			invoke putstring, addr strZero
		.endif
		.if dMemUse <= 999999
			invoke putstring, addr strZero
		.endif
		.if dMemUse <= 99999
			invoke putstring, addr strZero
		.endif
		.if dMemUse <= 9999
			invoke putstring, addr strZero
		.endif
		.if dMemUse <= 999
			invoke putstring, addr strZero
		.endif
		.if dMemUse <= 99
			invoke putstring, addr strZero
		.endif
		.if dMemUse <= 9
			invoke putstring, addr strZero
		.endif

		invoke putstring, addr strMemUse
	endm

.data
	;;;;;;;;;;;;;;;;;;;; MENU ;;;;;;;;;;;;;;;;;;;;;
	strMenuTop	byte	4 dup (32), 201,15 dup(205), 181, " MASM 4 TEXT EDITOR ", 198, 14 dup (205),187,13,10,0
	strMenuMem	byte	4 dup (32), 186, " Data Structure Memory Consumption: ", 0
	strMenuByte byte	" bytes ",186,13,10,0
	strMenuSep	byte	4 dup (32), 199, 51 dup (196), 182, 13, 10, 0
	strMenu1	byte	4 dup (32), 186, " <1> View all strings", 30 dup (32), 186,13,10,0
	strMenu2	byte	4 dup (32), 186, " <2> Add String", 36 dup (32), 186,13,10,0
	strMenu2a	byte	4 dup (32), 186, "     <a> From Keyboard", 29 dup (32),186,13,10,0
	strMenu2b	byte	4 dup (32), 186, "     <b> From File [input.txt]", 21 dup (32),186,13,10,0
	strMenu3	byte	4 dup (32), 186, " <3> Delete String", 33 dup (32), 186,13,10,0
	strMenu4	byte	4 dup (32), 186, " <4> Edit String", 35 dup (32),186,13,10,0
	strMenu5	byte	4 dup (32), 186, " <5> String Search", 33 dup (32),186,13,10,0
	strMenu6	byte	4 dup (32), 186, " <6> Save File", 37 dup (32),186,13,10,0
	strMenu7	byte	4 dup (32), 186, " <7> Quit", 42 dup (32),186,13,10,0
	strMenuEnd	byte	4 dup (32), 200, 51 dup(205),188,13,10,0

	;;;;;;;;;;;;;;;;;;;;; INPUT ;;;;;;;;;;;;;;;;;;;;;
	strInput			byte	2 dup (?),0
	strInputPrompt		byte	13,10,"Enter a command: ", 0
	strInvalidCommand 	byte	13,10,"Invalid command!", 0

	strOption1			byte	"1",0
	strOption2a			byte	"2a",0
	strOption2b			byte	"2b",0
	strOption3			byte	"3",0
	strOption4			byte	"4",0
	strOption5			byte	"5",0
	strOption6			byte	"6",0
	strOption7			byte	"7",0

	;;;;;;;;;;;;;;;;;;; PRINT DOCUMENT ;;;;;;;;;;;;;;;;;;;;;;
	strDocumentEmpty	byte	"<The document is empty>",0
	strDocumentTop		byte	201, 4 dup (205), 209, MAX_LINE_LENGTH dup (205), 187, 13, 10, 0
	strDocumentLeft		byte	186, 0
	strDocumentSep		byte	179, 0
	strDocumentRight	byte	186,13,10,0
	strDocumentBottom	byte	200, 4 dup(205), 207, MAX_LINE_LENGTH dup (205), 188,13,10,0

	dLineNum			dword	?
	strLineNum			byte	4 dup (?),0

	;;;;;;;;;;;;;;;;;;; ADD TEXT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	strEnterText		byte	13,10,"Enter some text: ", 0
	strKeyboardLine		byte	MAX_LINE_LENGTH dup (?), 0
	strGetline          byte    13,10,"Enter some text. Enter a single CTRL-D to stop: ", 0

	;;;;;;;;;;;;;;;;;;; DELETE LINE ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	strSelectLine		byte	13,10,"Enter a line number: ",0
	strLineInput		byte	4 dup (?),0
	strLineDNE          byte    13,10,"Line number error!",0

	;;;;;;;;;;;;;;;;;;;; SEARCH FOR TEXT ;;;;;;;;;;;;;;;;;;;;;;
	strSearchTop		byte	201, 5 dup (205), MAX_LINE_LENGTH dup (205), 187, 13, 10, 0
	strSearchHeadLeft	byte	186, " SEARCH RESULTS FOR ", 34, 0
	strSearchEndQuote	byte	34, 0	
	strSearchHeadSep	byte	204, 4 dup (205), 209, MAX_LINE_LENGTH dup (205), 185, 13, 10, 0
	strSearchLeft		byte	186, 0
	strSearchSep		byte	179, 0
	strSearchRight		byte	186,13,10,0
	strSearchBottom		byte	200, 4 dup (205), 207, MAX_LINE_LENGTH dup (205), 188, 13, 10, 0

	;;;;;;;;;;;;;;;;;; FORMATTING ;;;;;;;;;;;;;;;;;;;;;;;;;;
	strSpace		byte	32, 0
	strCrlf			byte	13,10,0
	strZero			byte	"0",0

	;;;;;;;;;;;;;;;;;; FLOW CONTROL ;;;;;;;;;;;;;;;;;;;;;;;
	bShouldExit		byte	0

	;;;;;;;;;;;;;;;;;; MEMORY MANAGEMENT ;;;;;;;;;;;;;;;;;;;;;;;;;
	heap		dword	0		
	head		dword	0
	tail		dword	0
	dMemUse		dword	0
	strMemUse	byte	8 dup (?), 0
	dLinesUsed  dword   ?
	
    ;;;;;;;;;;;;;;;;;; FILE HANDLING ;;;;;;;;;;;;;;;;;;;;;;;
	strFileName        byte "input.txt",0
	strFileOpenError   byte "Cannot open file.",13,10
	strFileLine        byte	MAX_LINE_LENGTH dup (?), 0
	dFileSize          dword ?
	dBuffer            dword ?
	dBytesRead         dword ?
	hFileHandle        HANDLE ?
	strLineLenError    byte 13,10,"Error, too many characters on one line in the file.",13,10,0

.code

String_length proc uses esi, _string1: ptr byte
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
	invoke HeapAlloc, heap, HEAP_ZERO_MEMORY, sizeof Line
	add dMemUse, sizeof Line
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

printDocument proc
	.if head == 0
		invoke putstring, addr strDocumentEmpty
		ret
	.endif

	mov esi, head
	mov dLineNum, 1

	invoke putstring, addr strDocumentTop

	.while esi != 0
		mPrintDocLine esi
		mov esi, (Line ptr [esi]).next
	.endw

	invoke putstring, addr strDocumentBottom

	ret
printDocument endp

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
    inc dLinesUsed
	ret
addLine endp

deleteLine proc uses ebx ecx edx esi edi, lineNum: dword
	.if head == 0
		ret
	.endif
	.if lineNum == 0
		mov edi, head
		invoke HeapFree, heap, 0, edi
		mov edx, (Line ptr [edi]).next
		mov head, edx
		sub dMemUse, sizeof Line

		ret
	.endif

	mov esi, head
	mov ecx, lineNum
	dec ecx
	.while ecx != 0
		mov esi, (Line ptr [esi]).next
		dec ecx
	.endw
	
	mov edi, (Line ptr [esi]).next
	mov edx, (Line ptr [edi]).next
	mov (Line ptr [esi]).next, edx

	ret
deleteLine endp

editLine proc, lineNum: dword, newText: ptr byte
	.if head == 0
		ret
	.endif

	mov edi, head
	mov ecx, lineNum
	.while ecx != 0
		mov edi, (Line ptr [edi]).next
		dec ecx
	.endw

	mov ecx, 0
	.while byte ptr [edi + ecx] != 0
		mov byte ptr [edi + ecx], 0
		inc ecx
	.endw

	mov esi, newText
	mov ecx, 0
	.while byte ptr [esi + ecx] != 0
		mov al, byte ptr [esi + ecx]
		mov byte ptr [edi + ecx], al
		inc ecx
	.endw

	ret
editLine endp

searchString proc, substring: ptr byte
	mov esi, head
	mov edx, 1

	push substring
	call String_toLowerCase
	add esp, 4

	.while esi != 0
		push esi
		call String_copy		; make a copy of the string from the linked list
		add esp, 4

		push eax
		call String_toLowerCase	; make the copy lowercase
		pop eax

		push substring
		push eax
		call String_indexOf_3	; search for lower(substring) in lower(esi)
		add esp, 8

		.if eax != -1			; if EAX != -1, esi contains substring
			mPrintSearchLine esi, edx	; print the line number and the string
		.endif

		mov esi, (Line ptr [esi]).next	; get the next node with ESI->next
		inc edx							; increase the line number
	.endw
	ret
searchString endp

getLineKeyboard proc
start:
    invoke putstring, addr strGetline
    invoke getstring, addr strKeyboardLine, MAX_LINE_LENGTH
    .if strKeyboardLine == 4        ; if End Of Transmission entered
        ret                         ; Don't make new node, return
    .endif
    push offset strKeyboardLine
    call addLine                    ; create new node
    add esp, 4
    jmp start                       ; keep getting more lines until user enters Ctrl-D
getLineKeyboard endp

deletePrompt proc
	invoke putstring, addr strSelectLine
	invoke getstring, addr strLineInput, 4
	invoke ascint32, addr strLineInput
	dec eax

    test eax, eax                          ; set sign flag if eax is negative
    .if SIGN? || eax > dLinesUsed          ; if input is negative or greater than # of lines
	    invoke putstring, addr strLineDNE  ; print error to user
		ret                                ; return early
    .endif

	push eax
	call deleteLine
	add esp, 4
	ret
deletePrompt endp

editPrompt proc
	invoke putstring, addr strSelectLine
	invoke getstring, addr strLineInput, 4
	invoke ascint32, addr strLineInput
	dec eax

    test eax, eax                          ; set sign flag if eax is negative
    .if SIGN? || eax > dLinesUsed          ; if input is negative or greater than # of lines
	    invoke putstring, addr strLineDNE  ; print error to user
		ret                                ; return early
    .endif

	invoke putstring, addr strEnterText
	invoke getstring, addr strKeyboardLine, MAX_LINE_LENGTH
	push offset strKeyboardLine
	push eax
	call editLine
	add esp, 8
	ret
editPrompt endp

searchPrompt proc
	invoke putstring, addr strEnterText
	invoke getstring, addr strKeyboardLine, MAX_LINE_LENGTH
	invoke putstring, addr strCrlf

	invoke putstring, addr strSearchTop
	invoke putstring, addr strSearchHeadLeft
	invoke putstring, addr strKeyboardLine
	invoke putstring, addr strSearchEndQuote
	
	push offset strKeyboardLine
	call String_length
	add esp, 4
	mov ebx, 83
	sub ebx, eax
	.while ebx != 0
		invoke putstring, addr strSpace
		dec ebx
	.endw

	invoke putstring, addr strSearchRight
	invoke putstring, addr strSearchHeadSep

	push offset strKeyboardLine
	call searchString
	add esp, 4	

	invoke putstring, addr strSearchBottom

	ret
searchPrompt endp

;------------------------------------------------------
getFromFile PROC
; Opens an existing input file & checks for errors.
; Gets file size & allocates memory.
; Reads from file and creates pointer to dynamic memory buffer.
; Parses the buffer line by line, adding each line to the linked list.
;------------------------------------------------------
    ;;;;; Open the existing input.txt
    invoke CreateFile,                    ; creates file handle in eax
           addr strFileName, GENERIC_READ, 0, 0,\
           OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
    mov hFileHandle, eax                  ; save our new file handle

    ;;;;; Check for errors opening file
    cmp	eax, INVALID_HANDLE_VALUE         ; error opening file?
    jne	file_ok	
    invoke putstring, addr strFileOpenError
    jmp quit

    ;;;;; Get the size of the file to know how much memory to allocate
file_ok:
    invoke GetFileSize, eax, 0            ; determine the size of the file we are dealing with
    mov dFileSize, eax                    ; save the file size
    inc eax                               ; +1 to append a null

    ;;;;; Allocate the memory
    invoke  GlobalAlloc,GMEM_FIXED, eax   ; allocate memory equal to file size
    mov dBuffer, eax                      ; save pointer to memory object
    add eax, dFileSize                    ; move to the end of the buffer
    mov byte ptr [eax], 0                 ; place a null at end of buffer
                                          ; this null will be our EOF flag

    ;;;;; Read the file into the allocated buffer
    invoke  ReadFile, hFileHandle, dBuffer, dFileSize, addr dBytesRead,0

    ;;;;; Parse the buffer, continually adding lines terminated by carriage return
    xor ecx, ecx                          ; clear buffer character count
    xor ebx, ebx                          ; clear the line character count
    mov esi, dBuffer                      ; get address of buffer
    .repeat
        ; Test to see if the last two bytes in a line are carriage return + line feed
        .while byte ptr [esi + ecx] != 13 && byte ptr [esi + ecx + 1] != 10
            .if byte ptr [esi + ecx] == 0 ; if we reached the end of the file
                add esi, ecx              ; move address to end of how much buffer we've read
                sub esi, ebx              ; adjust address to beginning of current line
                mov ecx, ebx              ; move the line's char count into ecx
                cld                       ; clear direction flag
                mov edi, offset strFileLine ; get address of destination
                rep movsb                 ; repeat copy byte from esi to edi until ecx = 0
                mov byte ptr [edi], 0     ; add null to end of strFileLine
                pushad                    ; save all registers
                push offset strFileLine   ; push string address
                call addLine              ; create new node for string
                add esp, 4                ; clean stack
                invoke CloseHandle, hFileHandle ; close the handle
                invoke GlobalFree,dBuffer ; Data is in our linked list, we can free the memory
                popad                     ; restore all registers
                ret                       ; end procedure
            .endif
            inc ecx                       ; increment buffer character counter
            inc ebx                       ; increment line character counter
            .if ebx >= MAX_LINE_LENGTH    ; check if a line in the file was too long
                invoke putstring, addr strLineLenError
                jmp quit                  ; if error caught, return early
            .endif
        .endw

	    push ecx                          ; save buffer character count
	    push esi                          ; save buffer address location
	    add esi, ecx                      ; move address to end of how much buffer we've read
	    sub esi, ebx                      ; adjust address to beginning of current line
	    mov ecx, ebx                      ; move the line's char count into ecx
	    cld                               ; clear direction flag
	    mov edi, offset strFileLine       ; get address of destination
	    rep movsb                         ; repeat copy byte from esi to edi until ecx = 0
	    mov byte ptr [edi], 0             ; add null to end of strFileLine
	    pop esi                           ; restore buffer address location
	    pop ecx                           ; restore buffer chararacter count
	    inc ecx                           ; skip the carriage return
	    inc ecx                           ; skip the newline

	    pushad                            ; save all registers
	    push offset strFileLine           ; push string address
	    call addLine                      ; create new node for string
	    add esp, 4                        ; clean stack
	    popad                             ; restore all registers
	    xor ebx, ebx                      ; clear line character counter
	.until (ecx >= dFileSize)

    ;;;;; Close the file & free memory
    invoke CloseHandle, hFileHandle       ; close the handle
    invoke  GlobalFree,dBuffer            ; Data is in our linked list, we can free the memory
quit:
    ret
getFromFile ENDP

_main:
	call GetProcessHeap
	mov heap, eax

	.while bShouldExit == 0
		mMenu
		mInput
	.endw

	invoke ExitProcess, 0
end _main