;**********************************************************************
; Program:  String2.asm
; Name:     Neal Hitzfield
; Class:    CS3B
; Date:     April 17, 2018
; Purpose:  Define String operations for MASM3
;***********************************************************************

.486
.model flat, c
.stack 100h

ExitProcess PROTO Near32 stdcall, dVal:dword
memoryallocBailey	PROTO NEAR32 stdcall, dSize:dword

extern String_length: Near32

	.data

	.code
;***********************************************************************
String_indexOf_1 proc, string1: ptr byte, char: ptr byte
; Returns the index of first occurrence of the specified character 
; ch in the string.
;***********************************************************************

    mov esi, string1             ; get address of string1
    mov edi, char                ; get address of char

    mov eax, -1                  ; have eax return -1 if index not found
    xor ebx, ebx                 ; clear index count
    .while byte ptr [esi] != 0   ; while not null
        mov dl, byte ptr [esi]   ; get a char from string1
        mov dh, byte ptr [edi]   ; get the char to compare to
        .if dl == dh             ; if they are equal
            mov eax, ebx         ; save the index value
            ret                  ; return, we have found the first occurrence
        .endif 
        inc esi                  ; otherwise increment to next char
        inc ebx                  ; increment index counter
    .endw
	
    ret                          ; index is in eax
String_indexOf_1 endp

;***********************************************************************
String_indexOf_2 proc, string1: ptr byte, char: ptr byte, fromIndex: dword
; Same as indexOf method however it starts searching in the string 
; from the specified fromIndex.
;***********************************************************************

    push string1
    call String_length           ; get length of source string
    add esp, 4

    .if fromIndex > eax || fromIndex < 0 ; check if the parameter index is out of bounds
        mov eax, -1             ; if out of bounds, return -1
        ret
    .endif

    mov esi, string1             ; get address of string1
    add esi, fromIndex           ; add to that address the index to start searching from
    mov edi, char                ; get address of char to find

    mov eax, -1                  ; have eax return -1 if index not found
    xor ebx, ebx                 ; clear index count
    .while byte ptr [esi] != 0   ; while string1 not null
        mov dl, byte ptr [esi]   ; get a char from string1
        mov dh, byte ptr [edi]   ; get the char to compare to
        .if dl == dh             ; if equal
            mov eax, ebx         ; save the index count
			add eax, fromIndex   ; add start index to final result
            ret                  ; return, we have found the first occurrence
		.endif
		inc esi                  ; otherwise increment to next char 
		inc ebx                  ; increment index counter
	.endw

	ret                          ; index is in eax
String_indexOf_2 endp

;***********************************************************************
String_indexOf_3 proc, string1: ptr byte, string2: ptr byte
; This method returns the index of first occurrence of 
; specified substring str.
;***********************************************************************
    mov esi, string1                        ; store string1 address in esi
    mov edi, string2                        ; store other string's address in edi
    xor ebx, ebx                            ; clear string1 index counter
    xor ecx, ecx                            ; clear substring index counter
    mov eax, -1                             ; have eax return -1 if index not found

    .while byte ptr [esi] != 0              ; while string1 not null
        mov dl, byte ptr [edi]              ; get a char from strOther
        mov dh, byte ptr [esi]              ; get a char from string1
        .if dh == dl                        ; if they are equal
            push esi                        ; save current position of string1
            push edi                        ; save current position of strOther
            .while byte ptr [edi] != 0      ; while strOther is not null
                mov cl, byte ptr [edi]      ; get a char from strOther
                mov ch, byte ptr [esi]      ; get a char from string1
                .if cl != ch                ; if they are not equal
                    .break                  ; exit inner while loop
                .endif 
                inc esi                     ; else go to next char in string1
                inc edi                     ; else go to next char in strOther
                inc ecx                     ; else increment substring index counter
            .endw
            .if byte ptr [edi] == 0         ; if strOther had been completely traversed
                mov eax, ebx                ; save string1 index count in eax
                ret                         ; return, we have found the first occurrence
            .endif
            pop edi                         ; restore old address position of strOther
            pop esi                         ; restore old address position of string1
        .endif
        inc esi                             ; else go to next char in string1
        inc ebx                             ; else increment string1 index counter 
    .endw
    ret                                     ; index is in eax
String_indexOf_3 endp

;***********************************************************************
String_lastIndexOf_1 proc
; It returns the last occurrence of the character ch in the string.
;***********************************************************************
    push ebp
    mov ebp, esp
	
    mov esi, [ebp + 8]           ; store string1 address in esi
    mov edi, [ebp + 12]          ; store char address in edi
    mov dl, byte ptr [edi]       ; store the char in dl
    mov ebx, 0                   ; clear the index count
    xor eax, eax                 ; clear return value
	
    .while byte ptr [esi] != 0
        cmp byte ptr [esi], dl   ; check for the char
        jz save
        jmp skip
    save:
        mov eax, ebx             ; save the current index position
    skip:
        inc esi                  ; go to next index
        inc ebx                  ; increment index counter
    .endw
	
    .if eax == 0
        mov eax, -1              ; if char was not found, return -1
    .endif
	
    pop ebp
    ret                          ; index is in eax
String_lastIndexOf_1 endp

;***********************************************************************
String_lastIndexOf_2 proc, string1: ptr byte, char: ptr byte, fromIndex: dword
; Same as lastIndexOf_1 method, but it starts search from fromIndex.
;***********************************************************************
    push string1
    call String_length           ; get length of source string
    add esp, 8
	
    .if fromIndex > eax          ; check if the parameter index is out of bounds
        mov eax, -1              ; if out of bounds, return -1
        ret
    .endif
	
    mov esi, [ebp + 8]           ; store string1 address in esi
    add esi, [ebp + 16]          ; go to starting point in string
    mov edi, [ebp + 12]          ; store char address in edi
    mov dl, byte ptr [edi]       ; move the char to dl
    mov ebx, 0                   ; clear the index count
    xor eax, eax                 ; clear return value
	
    .while byte ptr [esi] != 0
        cmp byte ptr [esi], dl   ; check for the char
        jz save
        jmp skip
    save:
        mov eax, ebx             ; save the current index position
    skip:
        inc esi	                 ; go to next index
        inc ebx                  ; increment index counter
    .endw
	
    .if eax == 0
        mov eax, -1              ; if char was not found, return -1
    .endif

    ret                          ; index is in eax
String_lastIndexOf_2 endp

;***********************************************************************
String_lastIndexOf_3 proc, string1: ptr byte, strOther: ptr byte
; Returns the index of last occurrence of string str.
;***********************************************************************
    mov esi, string1                        ; store string1 address in esi
    mov edi, strOther                       ; store other string's address in edi
    xor ebx, ebx                            ; clear string1 index counter
    xor ecx, ecx                            ; clear substring index counter
    xor eax, eax                            ; clear return value
	
    .while byte ptr [esi] != 0              ; while string1 not null
        mov dl, byte ptr [edi]              ; get a char from strOther
        mov dh, byte ptr [esi]              ; get a char from string1
        .if dh == dl                        ; if they are equal
            push esi                        ; save current position of string1
            push edi                        ; save current position of strOther
            .while byte ptr [edi] != 0      ; while strOther is not null
                mov cl, byte ptr [edi]      ; get a char from strOther
                mov ch, byte ptr [esi]      ; get a char from string1
                .if cl != ch                ; if they are not equal
                    .break                  ; exit inner while loop
                .endif 
                inc esi                     ; else go to next char in string1
                inc edi                     ; else go to next char in strOther
                inc ecx                     ; else increment substring index counter
            .endw
            .if byte ptr [edi] == 0         ; if strOther had been completely traversed
                mov eax, ebx                ; save string1 index count in eax
            .endif
            pop edi                         ; restore old address position of strOther
            pop esi                         ; restore old address position of string1
        .endif
        inc esi                             ; else go to next char in string1
        inc ebx                             ; else increment string1 index counter 
    .endw

    ret                                     ; index is in eax
String_lastIndexOf_3 endp

;***********************************************************************
String_concat proc, string1: ptr byte, str2: ptr byte
; Concatenates the specified string “str” at the end of the string.
;***********************************************************************
    xor eax, eax            ; clear eax
    push string1
    call String_length      ; get string length of string1
    add esp, 4              ; clean up stack
    mov ecx, eax            ; save length
	
    push str2
    call String_length      ; get string length of str2
    add esp, 4              ; clean up stack
    add eax, ecx            ; add the two string lengths
    inc eax	                ; +1 for terminating null
	
    invoke memoryallocBailey, eax  ; allocate the calculated space on heap for new string
	
    xor ecx, ecx
    mov esi, string1
    .while byte ptr [esi + ecx] != 0
        mov dl, byte ptr [esi + ecx]  ; get string1 char from memory
        mov byte ptr [eax + ecx], dl  ; move it into memory of new string
        inc ecx
    .endw
    xor ebx, ebx
    mov esi, str2
    .while byte ptr [esi + ebx] != 0
        mov dl, byte ptr [esi + ebx]  ; get str2 char from memory
        mov byte ptr [eax + ecx], dl  ; move it into memory of new string
        inc ecx
        inc ebx
    .endw
    mov byte ptr [eax + ecx], 0  ; append null to concatenated string
	
    ret                          ; eax contains memory address of new string
String_concat endp

;***********************************************************************
String_replace proc, string1: ptr byte, oldChar: ptr byte, newChar: ptr byte
; Returns new updated string after changing all the occurrences 
; of oldChar with the newChar.
;***********************************************************************
    xor eax, eax
    mov esi, string1                ; get address of string1
    push esi                        ; save the address for later
	
    mov eax, string1                ; move string1 address into eax
    mov ebx, oldChar                ; move oldChar address into ebx
    mov ecx, newChar                ; move newChar address into ecx
	
    .while byte ptr [eax] != 0      ; until the string reaches null
        mov dl, byte ptr [eax]      ; move one byte from old string into dl
        mov dh, byte ptr [ebx]      ; move old char into dh from memory
        .if dl == dh                ; compare the character with oldChar
            mov dl, byte ptr [ecx]  ; move new char into dl from memory
            mov byte ptr [eax], dl  ; replace oldChar with newChar
        .endif
        inc eax                     ; go to next character
    .endw
	
    pop esi                         ; restore address of string1
    .while byte ptr [esi] != 0      ; until null
        mov dl, byte ptr [eax]      ; get a char from updated string
        mov dh, byte ptr [esi]      ; get a char from old string
        mov dh, dl                  ; move the new one where old one was
        inc eax                     ; go to next char in updated string
        inc esi                     ; go to next char in old string
    .endw
	
    ret                             ; original string address holds updated string
String_replace endp

;***********************************************************************
String_toLowerCase proc, string1: ptr byte
; It converts the string to lower case string
;***********************************************************************
    mov esi, string1                ; get string to convert from the stack
    .while byte ptr [esi] != 0      ; while not at the end of string
        mov al, byte ptr [esi]      ; get a char from memory
        .if al < 'A'                ; if the char is less than ascii a 
            jmp skip                ; skip it
        .endif					
        .if al > 'Z'                ; if the char is greater than ascii z
            jmp skip                ; skip it
        .endif
		
        xor byte ptr [esi], 00100000b  ; convert the char to lowercase

        skip:
        inc esi                     ; go to next char
    .endw
    mov eax, esi
	
    ret                             ; converted string address is in eax
String_toLowerCase endp
 
;***********************************************************************
String_toUpperCase proc, string1: ptr byte
;It converts the string to upper case string
;***********************************************************************
    mov esi, string1                ; get string to convert from the stack
    .while byte ptr [esi] != 0      ; while not at the end of string
        mov al, byte ptr [esi]      ; get a char from memory
        .if al < 'a'                ; if the char is less than ascii a 
            jmp skip                ; skip it
        .endif					
        .if al > 'z'                ; if the char is greater than ascii z
            jmp skip                ; skip it
        .endif
		
        and byte ptr [esi], 11011111b  ; convert the char to uppercase

        skip:
        inc esi                     ; go to next char
    .endw
    mov eax, esi                    ; move the string's address into eax
	
    ret                             ; converted string address is in eax
String_toUpperCase endp

end