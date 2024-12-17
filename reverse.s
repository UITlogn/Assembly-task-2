section .bss
    s resb 33
    a resb 33

section .data
    endl db 10
    size dq 1
    number dq 1
    pow dq 1

section .text
    global _start

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, s
    mov rdx, 33
    syscall

    mov rsi, s      ; đặt con trỏ rsi vào đầu xâu s và gọi hàm để đảo ngược
    call reverse

    mov rax, 1
    mov rdi, 1
    mov rsi, s
    mov rdx, 33
    syscall

    mov rax, 60
    mov rdi, 0
    syscall

getsize:    ; hàm lấy độ dài xâu mà rsi đang trỏ tới
    cmp byte [rsi + rax], 0
    jz sizedone
    inc rax
    jmp getsize
    sizedone:
    dec rax
ret

reverse:
    mov rax, 0
    call getsize
    mov rsi, 0      ; i = 0
    mov rdi, rax    ; j = s.size() - 1
    dec rdi
    revloop:
        cmp rsi, rdi
        jge revdone ; if i >= j: done
        ;swap(s[i], s[j])
        mov al, [s + rsi]
        mov dl, [s + rdi]
        mov [s + rsi], dl
        mov [s + rdi], al
        ;i++, j--
        add rsi, 1
        sub rdi, 1
        jmp revloop
    revdone:
ret