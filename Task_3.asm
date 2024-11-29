
;3. Modular Program with Subroutines for Factorial Calculation (4 Marks) 
;    a. Develop a program that: 
;        i. Computes the factorial of a number received as input. 
;        ii. Uses a separate subroutine (function-like code block) to perform the calculation. 
;        iii. Uses the stack to preserve registers, demonstrating an understanding of modular code and register handling. 
;        iv. Places the final result in a general-purpose register. 
;    b. Documentation Requirement: Document how registers are managed, 
;        particularly how values are preserved and restored in the stack

section .data
    prompt db "Enter a number: ", 0
    prompt_len equ $ - prompt
    result_msg db "Factorial is: ", 0
    result_msg_len equ $ - result_msg
    input_buffer db 32       ; Buffer for input
    input_buffer_len equ $ - input_buffer

section .bss
    number resd 1            ; Variable to store the input number

section .text
    global _start

_start:
    ; Prompt user to enter a number
    mov eax, 4               ; syscall: sys_write
    mov ebx, 1               ; file descriptor: stdout
    mov ecx, prompt          ; message address
    mov edx, prompt_len      ; message length
    int 0x80                 ; interrupt to invoke syscall

    ; Read the number from the user
    mov eax, 3               ; syscall: sys_read
    mov ebx, 0               ; file descriptor: stdin
    mov ecx, input_buffer    ; input buffer address
    mov edx, input_buffer_len ; max input length
    int 0x80                 ; interrupt to invoke syscall

    ; Convert input string to integer
    xor eax, eax             ; Accumulator for number
    xor ebx, ebx             ; Temporary for digit conversion
    lea esi, [input_buffer]  ; Address of input buffer
.convert_loop:
    mov bl, byte [esi]       ; Load next character
    cmp bl, 10               ; Check for newline
    je .convert_done
    sub bl, '0'              ; Convert ASCII to numeric
    imul eax, eax, 10        ; Shift number left
    add eax, ebx             ; Add the new digit
    inc esi                  ; Move to next character
    jmp .convert_loop
.convert_done:
    mov [number], eax        ; Store the number in memory

    ; Call the factorial subroutine
    mov eax, [number]        ; Load the input number into eax
    push eax                 ; Push the input onto the stack
    call factorial           ; Call the factorial subroutine
    add esp, 4               ; Clean up the stack

    ; Result is now in eax, prepare to output it
    mov eax, 4               ; syscall: sys_write
    mov ebx, 1               ; file descriptor: stdout
    mov ecx, result_msg      ; Output message
    mov edx, result_msg_len  ; Length of the message
    int 0x80                 ; interrupt to invoke syscall

    ; Convert factorial result to string and output it
    push eax                 ; Save the result on the stack
    call print_int           ; Print the result in eax
    add esp, 4               ; Clean up the stack

    ; Exit the program
    mov eax, 1               ; syscall: sys_exit
    xor ebx, ebx             ; Exit code 0
    int 0x80                 ; interrupt to invoke syscall

; Subroutine: factorial
; Input: eax (number to calculate factorial for)
; Output: eax (factorial result)
factorial:
    push ebp                 ; Save base pointer
    mov ebp, esp             ; Establish new stack frame
    push ebx                 ; Preserve ebx (used in recursion)

    cmp eax, 1               ; Base case: if n <= 1
    jle .base_case

    ; Recursive case: n * factorial(n-1)
    dec eax                  ; eax = n-1
    push eax                 ; Push n-1 onto the stack
    call factorial           ; Recursively call factorial
    add esp, 4               ; Clean up the stack
    mov ebx, eax             ; Save recursive result in ebx
    mov eax, [ebp+8]         ; Restore n from stack
    imul eax, ebx            ; eax = n * factorial(n-1)
    jmp .return

.base_case:
    mov eax, 1               ; Factorial of 0 or 1 is 1

.return:
    pop ebx                  ; Restore ebx
    pop ebp                  ; Restore base pointer
    ret                      ; Return to the caller

; Subroutine: print_int
; Input: eax (integer to print)
; Output: none (uses syscall to print the integer)
print_int:
    mov esi, esp             ; Save current stack pointer
    mov ebx, 10              ; Divisor for decimal conversion
    xor ecx, ecx             ; Counter for digit storage
.convert_loop:
    xor edx, edx             ; Clear remainder
    div ebx                  ; Divide eax by 10
    add dl, '0'              ; Convert remainder to ASCII
    push edx                 ; Push digit onto stack
    inc ecx                  ; Increment digit count
    test eax, eax            ; Check if quotient is zero
    jnz .convert_loop

    ; Print digits from the stack
.print_digits:
    dec ecx                  ; Decrement counter
    pop eax                  ; Get the next digit
    mov [esp], al            ; Prepare for syscall
    mov eax, 4               ; syscall: sys_write
    mov ebx, 1               ; file descriptor: stdout
    lea ecx, [esp]           ; Address of the digit
    mov edx, 1               ; Write one byte
    int 0x80                 ; interrupt to invoke syscall
    test ecx, ecx            ; Check if more digits are left
    jnz .print_digits
    mov esp, esi             ; Restore original stack pointer
    ret
