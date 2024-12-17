section .bss
    a resb 44
    b resb 44
    c resb 44

section .data
    sizeA dq 0
    sizeB dq 0
    sizeC dq 0
    maxsize dq 0

section .text
    global _start

_start:
    ; nhập a
    mov rax, 0
    mov rdi, 0
    mov rsi, a
    mov rdx, 33
    syscall
    ; đảo ngược a
    mov rax, 0
    lea rbp, a
    call getsize
    mov [sizeA], rax
    call reverse

    ; nhập b
    mov rax, 0
    mov rdi, 0
    mov rsi, b
    mov rdx, 33
    syscall
    ; đảo ngược b
    mov rax, 0
    lea rbp, b
    call getsize
    mov [sizeB], rax
    call reverse

    mov rax, [sizeA]
    mov [sizeC], rax    ; sizeC = sizeA
    mov rax, [sizeB]
    cmp [sizeC], rax    ; maximize(sizeC, sizeB)
    jge pass
    mov [sizeC], rax
    pass:


    ; a += b
    mov rsi, 0
    mov cl, 0
    loop:
        cmp rsi, [sizeC]
        jz done

        mov al, 0               ; al = (i < sizeA ? a[i] : 0)
        cmp rsi, [sizeA]
        jge nxt1
            mov al, [a + rsi]
            sub al, '0'
        nxt1:

        mov bl, 0               ; bl = (i < sizeB ? b[i] : 0)
        cmp rsi, [sizeB]
        jge nxt2
            mov bl, [b + rsi]
            sub bl, '0'
        nxt2:

        add cl, al              ; cl (đã có phần nhớ) += al + bl
        add cl, bl

        mov dl, 0
        cmp cl, 9
        jle nxt3                ; nếu cl > 9 thì nhớ hàng chục cho biến dl
            sub cl, 10
            add dl, 1
        nxt3:
        
        add cl, '0'
        mov [c + rsi], cl
        mov cl, dl              ; +dl vào lại cl để cho bước tiếp theo
        
        inc rsi
        jmp loop
    done:

    cmp cl, 0               ; nếu chạy hết vòng lặp mà cl != 0
    jz final                
        add cl, '0'         
        mov [c + rsi], cl   ; thì thêm phần nhớ vào cuối kết quả (sẽ đảo ngược thành đầu)
        mov rax, [sizeC]    ; tăng kích thước đáp án lên 1
        add rax, 1
        mov [sizeC], rax
    final:

    ; đảo ngược lại để in đáp án
    lea rbp, c
    mov rax, [sizeC]
    call reverse

    ; in đáp án
    mov rax, 1
    mov rdi, 1
    mov rsi, c
    mov rdx, [sizeC]
    syscall

    mov rax, 60
    mov rdi, 0
    syscall

getsize:    ; hàm lấy độ dài xâu mà rbp đang trỏ tới
    cmp byte [rbp + rax], 0
    jz sizedone
    inc rax
    jmp getsize
    sizedone:
    dec rax
ret

reverse:    ; hàm đảo ngược xâu mà rbp đang tham chiếu
    mov rsi, 0      ; i = 0
    mov rdi, rax    ; j = len - 1
    dec rdi
    revloop:
        cmp rsi, rdi
        jge revdone ; if i >= j: done
        ;swap
        mov al, [rbp + rsi]
        mov dl, [rbp + rdi]
        mov [rbp + rsi], dl
        mov [rbp + rdi], al
        ;i++, j--
        add rsi, 1
        sub rdi, 1
        jmp revloop
    revdone:
ret
