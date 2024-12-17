section .bss
    nstr resb 4
    a resb 1

section .data
    endl dq 10
    n dq 0
    number dq 0
    pow dq 0
    fi1 dq 1
    fi2 dq 0

section .text
    global _start

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, nstr
    mov rdx, 4
    syscall

    mov rsi, nstr
    call toint
    mov [n], rax

    loop:
        mov rax, [n]
        cmp rax, 0
        jz done
        mov rax, [fi1]
        add rax, [fi2]
        mov [number], rax
        call writenumber
        call printendl

        mov rax, [fi1]
        mov [fi2], rax
        mov rax, [number]
        mov [fi1], rax

        mov rax, [n]
        dec rax
        mov [n], rax
        jmp loop
    done:

    mov rax, 60
    mov rdi, 0
    syscall

toint:
    mov rax, 0
    loopint:
        movzx rbx, byte [rsi]
        test rbx, rbx
        jz doneint
        cmp rbx, '0'
        jl doneint
        cmp rbx, '9'
        jg doneint
        imul rax, 10
        sub rbx, '0'
        add rax, rbx
        inc rsi
    jmp loopint
    doneint:
ret

writenumber:
    mov rax, [number]
    mov rbx, 1
    powloop:
        mov rdx, 0
        mov rcx, 10
        div rcx
        cmp rax, 0
        jz endpowloop
        imul rbx, 10
    jmp powloop
    endpowloop:
    mov [pow], rbx

    printnumber:
        mov rdx, 0
        mov rax, [number]
        mov rcx, [pow]
        div rcx
        mov rdx, 0
        mov rcx, 10
        div rcx
        add rdx, 48
        mov [a], rdx
        mov rax, 1
        mov rdi, 1
        mov rsi, a
        mov rdx, 1
        syscall
        mov rdx, 0
        mov rax, [pow]
        mov rcx, 10
        div rcx
        mov [pow], rax
        cmp rax, 0
        jz done_print
    jmp printnumber
    done_print:
ret

printendl:
    mov rax, 1
    mov rdi, 1
    mov rsi, endl
    mov rdx, 1
    syscall
ret