
;2. Array Manipulation with Looping and Reversal (6 Marks) 
;    a. Implement a program that: 
;        i. Accepts an array of integers (e.g., five values) as input from the user. 
;        ii. Reverses the array in place. 
;        iii. Outputs the reversed array. 
;    b. Requirements: 
;        i. Avoid using additional memory to store the reversed array. 
;        ii. Use loops to perform the reversal. 
;    c. Documentation Requirement: Comment each step of your reversal 
;        process and explain any challenges with handling memory directly



; File: reverse_array.asm
; Purpose: Accept an array of integers, reverse it in place, and output the reversed array.

section .data
    ; Define prompts and storage for user messages
    prompt db "Enter 5 integers (space separated): ", 0
    output db "Reversed array: ", 0
    buffer db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    array dd 0, 0, 0, 0, 0 ; Integer array (5 elements)
    array_size equ 5       ; Define array size for easy modification

section .bss
    temp resd 1           ; Temporary storage for swapping integers

section .text
global _start

_start:
    ; Step 1: Display prompt to enter integers
    mov eax, 4           ; syscall: write
    mov ebx, 1           ; file descriptor: stdout
    mov ecx, prompt      ; address of prompt string
    mov edx, 36          ; length of the prompt
    int 0x80             ; make system call

    ; Step 2: Read integers from user input
    mov eax, 3           ; syscall: read
    mov ebx, 0           ; file descriptor: stdin
    mov ecx, buffer      ; buffer to store input
    mov edx, 20          ; maximum characters to read
    int 0x80             ; make system call

    ; Step 3: Parse integers into the array
    lea esi, buffer      ; Point to the input buffer
    lea edi, array       ; Point to the array
    xor ecx, ecx         ; Counter for array index

parse_loop:
    lodsb                   ; Load byte from buffer to AL
    cmp al, ' '             ; Check if the byte is a space
    je parse_continue       ; If space, skip to the next byte
    cmp al, 0               ; Check if end of string
    je parse_end            ; End parsing if null terminator
    sub al, '0'             ; Convert ASCII to integer
    mov [edi + ecx*4], eax  ; Store in array
    inc ecx                 ; Increment index
    jmp parse_loop
    
parse_continue:
    jmp parse_loop       ; Repeat until parsing ends

parse_end:
    ; Step 4: Reverse the array in place
    xor esi, esi         ; ESI = start index (0)
    mov edi, array_size  ; EDI = end index (array_size - 1)
    dec edi              ; Adjust for 0-based indexing

reverse_loop:
    cmp esi, edi         ; Check if start index >= end index
    jge reverse_done     ; Exit loop if indices meet or cross

    ; Swap array[ESI] and array[EDI]
    mov eax, [array + esi*4] ; Load array[ESI] into EAX
    mov ebx, [array + edi*4] ; Load array[EDI] into EBX
    mov [array + esi*4], ebx ; Store EBX in array[ESI]
    mov [array + edi*4], eax ; Store EAX in array[EDI]

    inc esi              ; Move start index forward
    dec edi              ; Move end index backward
    jmp reverse_loop     ; Repeat until fully reversed

reverse_done:
    ; Step 5: Output the reversed array
    mov eax, 4           ; syscall: write
    mov ebx, 1           ; file descriptor: stdout
    mov ecx, output      ; Address of output string
    mov edx, 18          ; Length of output string
    int 0x80             ; Display "Reversed array: "

    ; Print reversed array elements
    xor ecx, ecx         ; Reset index to 0

output_loop:
    mov eax, [array + ecx*4] ; Load array[ECX] element
    add eax, '0'          ; Convert integer to ASCII
    mov [buffer], eax     ; Store in buffer
    mov eax, 4            ; syscall: write
    mov ebx, 1            ; file descriptor: stdout
    lea ecx, buffer       ; Load buffer address
    mov edx, 1            ; Write single character
    int 0x80              ; System call
    inc ecx               ; Increment index
    cmp ecx, array_size   ; Check if all elements are printed
    jl output_loop        ; Loop if not done

    ; Exit program
    mov eax, 1           ; syscall: exit
    xor ebx, ebx         ; exit code 0
    int 0x80             ; make system call
