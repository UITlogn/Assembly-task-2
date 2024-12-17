section .bss
    s resb 200
    t resb 200
    a resb 8
    lst resb 200

section .data
    space db 32
    endl db 10
    id dq 0
    s_size dq 0
    t_size dq 0
    pow dq 0
    number dq 0
    ans dq 0
    save dq 0

section .text
    global _start

_start:
    ; nhập s
    mov rax, 0
    mov rdi, 0
    mov rsi, s
    mov rdx, 200
    syscall

    ; tính độ dài xâu s
    mov rsi, s
    call getsize
    mov [s_size], rax

    ; nhập t
    mov rax, 0
    mov rdi, 0
    mov rsi, t
    mov rdx, 200
    syscall
    
    ; tính độ dài xâu t
    mov rsi, t
    call getsize
    mov [t_size], rax

    ; chạy rsi = (t_size - 1) -> (s_size - 1)
    ; là vị trí cuối của xâu con trong s sẽ được so khớp với t
    mov rsi, [t_size]
    sub rsi, 1
    loop:
        cmp rsi, [s_size]   ; chạy đến khi rsi = s_size thì dừng
        jz done

        mov [save], rsi     ; vì rsi sẽ bị thay đổi ở hàm compare
        ; nên lưu lại rsi để gán sau khi compare (tại lười sửa biến)

        mov rdi, [t_size]   ; rdi cũng bị thay đổi trong compare nên phải gán lại
        sub rdi, 1
        call compare
        mov rsi, [save]
        
        inc rsi
        jmp loop
    done:

    call printendl      ; in xuống dòng và in số lượng vị trí thỏa mãn
    mov rax, [ans]
    mov [number], rax
    call writenumber

    mov rax, 60
    mov rdi, 0
    syscall

printspace:
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall
ret

printendl:
    mov rax, 1
    mov rdi, 1
    mov rsi, endl
    mov rdx, 1
    syscall
ret

writenumber:    ; hàm cũ ở bài trước nên không comment nữa
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

; hàm lấy độ dài
getsize:
    cmp byte [rsi + rax], 0
    jz sizedone
    inc rax
    jmp getsize
    sizedone:
    dec rax
ret

; hàm so khớp xâu s[...rsi] với t
; nếu khớp thì in ra vị trí rsi - len(t) + 1 và tăng ans lên 1
compare:
    cmploop:
        mov al, [s + rsi]
        mov bl, [t + rdi]
        cmp al, bl
        jnz cmpret

        cmp rdi, 0
        jz cmpdone

        dec rsi
        dec rdi
        jmp cmploop
    cmpdone:
        ; ++ans
        mov rax, [ans]
        add rax, 1
        mov [ans], rax

        ; in ra rax = i - len(t) + 1
        mov rax, [save]
        sub rax, [t_size]
        add rax, 1
        mov [number], rax

        call writenumber
        call printspace
    cmpret:
ret