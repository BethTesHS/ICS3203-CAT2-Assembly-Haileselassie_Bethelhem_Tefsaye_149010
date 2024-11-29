
; 1. Control Flow and Conditional Logic
;    a. Write a program that: 
;        i. Prompts for a user input number. 
;        ii. Uses branching logic to classify the number as “POSITIVE,” 
;            “NEGATIVE,” or “ZERO.” 
;        iii. Use both conditional and unconditional jumps in the program 
;            to handle these cases effectively. 
;    b. Documentation Requirement: In your comments, explain why you chose 
;        specific jump instructions and how each one impacts the program flow

section .data
    prompt db "Enter a number: ", 0
    positive_msg db "POSITIVE.", 0
    negative_msg db "NEGATIVE.", 0
    zero_msg db "ZERO.", 0
    space db "", 0

section .bss
    input resb 10  ; Reserve space for user input

section .text
    global _start

_start:
    ; Print the prompt message
    mov eax, 4           ; syscall: sys_write
    mov ebx, 1           ; file descriptor: stdout
    mov ecx, prompt      ; message address
    mov edx, 15          ; message length
    int 0x80             ; make kernel call

    ; Read the input from the user
    mov eax, 3           ; syscall: sys_read
    mov ebx, 0           ; file descriptor: stdin
    mov ecx, input       ; buffer to store input
    mov edx, 10          ; max bytes to read
    int 0x80             ; make kernel call

    ; Convert input string to integer
    mov esi, input       ; load input buffer address
    call str_to_int      ; convert string to integer
    mov ebx, eax         ; store the integer in ebx for comparison

    ; Check if the number is zero
    cmp ebx, 0           ; compare number with 0
    je is_zero           ; if zero, jump to is_zero

    ; Check if the number is negative
    jl is_negative       ; if less than zero, jump to is_negative

    ; Otherwise, the number is positive
    jmp is_positive      ; unconditional jump to is_positive

is_zero:
    ; Print "ZERO" message
    mov eax, 4           ; syscall: sys_write
    mov ebx, 1           ; file descriptor: stdout
    mov ecx, zero_msg    ; message address
    mov edx, 4          ; message length
    int 0x80             ; make kernel call
    jmp end_program      ; unconditional jump to end_program

is_negative:
    ; Print "NEGATIVE" message
    mov eax, 4           ; syscall: sys_write
    mov ebx, 1           ; file descriptor: stdout
    mov ecx, negative_msg ; message address
    mov edx, 8          ; message length
    int 0x80             ; make kernel call
    jmp end_program      ; unconditional jump to end_program

is_positive:
    ; Print "POSITIVE" message
    mov eax, 4           ; syscall: sys_write
    mov ebx, 1           ; file descriptor: stdout
    mov ecx, positive_msg ; message address
    mov edx, 8          ; message length
    int 0x80             ; make kernel call

end_program:
    ; Exit the program
    mov eax, 1           ; syscall: sys_exit
    xor ebx, ebx         ; exit code 0
    int 0x80             ; make kernel call

; Subroutine: Convert string to integer
str_to_int:
    xor eax, eax       ; Clear EAX (result)
    xor ebx, ebx       ; Clear EBX (negative flag)
    xor edx, edx       ; Clear EDX (temporary register)

    ; Check for optional '-' sign
    mov al, byte [esi] ; Load the first character
    cmp al, '-'        ; Compare it with '-'
    jne parse_digits   ; If not '-', go to parse_digits
    inc esi            ; Skip the '-' character
    mov ebx, 1         ; Set negative flag

parse_digits:
    ; Loop to process each digit
    mov ecx, 0         ; ECX will store the result

digit_loop:
    mov al, byte [esi] ; Load the next character
    cmp al, 0          ; Check for null terminator
    je finished        ; If null terminator, we're done
    sub al, '0'        ; Convert ASCII to numerical digit
    cmp al, 9          ; Ensure it's a valid digit (0-9)
    ja finished        ; If not, exit (optional error handling)

    imul ecx, ecx, 10  ; Multiply current result by 10
    add ecx, eax       ; Add the current digit
    inc esi            ; Move to the next character
    jmp digit_loop     ; Repeat the loop

finished:
    cmp ebx, 1         ; Check if the number is negative
    jne end_conversion ; If not negative, skip negation
    neg ecx            ; Negate the result

end_conversion:
    mov eax, ecx       ; Move the result to EAX
    ret                ; Return to caller