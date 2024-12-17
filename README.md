## Assembly Task 2

Source: https://github.com/UITlogn/Assembly-task-2

### Bài 5: Tìm xâu con [substr.s]

Viết hàm ```compare``` để so khớp xâu $T$ với một đoạn con trong xâu $S$, chỉ đơn giản là chạy một biến từ đầu đến cuối và so khớp từng vị trí (đánh số từ 0 đến len-1)
```asm
; hàm so khớp xâu s[...rsi] với t
; nếu khớp thì in ra vị trí rsi - len(t) + 1 và tăng ans lên 1
; truyền vào rdi = độ dài xâu t - 1
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
```

Muốn biết độ dài xâu $T$ thì phải viết thêm hàm ```getsize``` để lấy được dài (tính từ đầu cho đến khi gặp kí tự kết thúc xâu).
```asm
; truyền vào con trỏ rsi trỏ tới đầu xâu, kết quả trả về rax là độ dài
getsize:
    cmp byte [rsi + rax], 0
    jz sizedone
    inc rax
    jmp getsize
    sizedone:
    dec rax
ret
```
Việc duyệt qua các đoạn con liên tiêp trong $S$ có độ dài đúng bằng $T$ cần phải đảm bảo không để bị tràn (gọi tới vùng nhớ nằm ngoài xâu $S$).
Mình chọn mốc để duyệt là điểm cuối của xâu con chứ không phải điểm đầu (vì sẵn có biến để gán với khi loop thì so sánh với 0 cho tiện hoặc nếu cần package thành hàm).
```asm
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
```

### Bài 6: Đảo ngược xâu [reverse.s]

Dùng hàm ```getsize``` của bài trước, chạy 2 biến $i$, $j$ từ ngoài vào ($i$ từ $0$, $j$ từ $size-1$) và hoán đổi giá trị tại $s[i]$ với $s[j]$.
```asm
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
```

### Bài 7: In N số Fibonaci [fibo.s]

Đầu tiên là phải chuyển đổi được số $N$ nhập vào sang số nguyên. Hàm ```toint``` truyền vào biến con trỏ rsi , duyệt qua từng kí tự, kiểm tra nếu là chữ số $0 \le rsi \le 9$ thì thêm vào biến lưu số nguyên, nhân 10 kết quả đang có và cộng vào thành hàng đơn vị
```asm
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
```
Phần tính và in số fibonaci thì chỉ đơn giản là cần 3 biến, 2 biến lưu 2 số fibonaci liền trước và một biến là số hiện tại = tổng 2 số trước đó. Sau khi tính và in ra xong thì đẩy số hiện tại thành số liền trước và tiếp tục
```asm
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
```


### Bài 8: Tổng A + B lớn [bignum.s]

Khác với bài 4 thì bài này là không chuyển về số nguyên vì số quá lớn, quá 64bit nên không thể lưu cũng nhưu tính toán, nên sẽ giữ nguyên dạng xâu để tính phép cộng theo từng hàng từ đơn vị nhỏ nhất đến lớn nhất như toán lớp 1.
Để các hàng có cùng cấp đơn vị (cùng hệ số mũ) với nhau thì mình sẽ đảo ngược hai xâu a với b lại để cộng theo hàng đơn giản từ vị trí 0 tới hết ($c[i] = a[i] + b[i] +$ nhớ). Nếu kết quả lớn hơn 9 thì phải -10 (để chỉ lấy 1 hàng đơn vị) và thêm nhớ cho lượt sau (cụ thể là nhớ 1 đơn vị).

```asm
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
```
