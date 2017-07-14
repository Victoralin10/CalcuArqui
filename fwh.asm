; Title:            Calculadora
; Author:           Victor Cueva Llanos
; Email:            Ingvcueva@gmail.com
; Leer readme.txt
datos segment
    endl    db 10, 13, '$'
    msg1    db "Ingresar expresion: ", '$'
    msg2    db "Resultado: ", '$'
; procesamiento del la expresion
    opStack     db 100 dup(0)
    numStack    dw 100 dup(0)
    lop     dw 0
    lnum    dw 0
    isn     db 0
    num     dw 0
    c       db 0
; copute_last_operator
    aux1    dw 0
    aux2    dw 0
; compute_pow
    a_compute_pow_b dw 0    ; Base
    a_compute_pow_e dw 0    ; Exponente
    o_compute_pow   dw 0    ; Resultado
; print_int
    a_print_int1 dw 0       ; numero a imprimir
datos ends

pila segment
    dw 1024 dup('?')
pila ends

codigo segment
    assume cs:codigo, ds:datos, ss:pila
principal proc far
    mov ax, datos
    mov ds, ax
    mov ax, pila
    mov ss, ax

    mov dx, offset msg1
    mov ah, 9
    int 21h

    call p_procesar_expresion

    mov ah, 9
    mov dx, offset msg2
    int 21h

    mov ax, numStack
    mov a_print_int1, ax
    call p_print_int

    mov ah, 4ch
    int 21h
principal endp

; procedimiento para procesar la expresion
p_procesar_expresion proc
p_procesar_expresion_loop:
    mov ah, 1
    int 21h

    mov c, al
    cmp byte ptr c, 13
    je p_procesar_expresion_end
    cmp byte ptr c, '0'
    jl p_procesar_expresion_nodigit
    cmp byte ptr c, '9'
    jg p_procesar_expresion_nodigit
    call p_procesar_digit
    jmp p_procesar_expresion_loop
p_procesar_expresion_nodigit:
    call p_procesar_num
    call p_procesar_nodigit
    jmp p_procesar_expresion_loop
p_procesar_expresion_end:
    call p_procesar_num
    call p_compress1
    ret
p_procesar_expresion endp

; procesar caracter no digit
p_procesar_nodigit proc near
    cmp byte ptr c, '('
    je p_procesar_expresion_paropen
    cmp byte ptr c, ')'
    je p_procesar_expresion_parclose
    cmp byte ptr c, '+'
    je p_procesar_expresion_plusminus
    cmp byte ptr c, '-'
    je p_procesar_expresion_plusminus
    cmp byte ptr c, '^'
    je p_procesar_expresion_pow
    jmp p_procesar_expresion_muldiv
p_procesar_expresion_paropen:
    lea bx, opStack
    add bx, lop
    mov byte ptr [bx], '('
    inc lop
    jmp p_procesar_nodigit_end
p_procesar_expresion_parclose:
    call p_compress1
    dec lop
    jmp p_procesar_nodigit_end
p_procesar_expresion_plusminus:
    call p_compress1
    lea bx, opStack
    add bx, lop
    mov al, c
    mov [bx], al
    inc lop
    jmp p_procesar_nodigit_end
p_procesar_expresion_pow:
    lea bx, opStack
    add bx, lop
    mov byte ptr [bx], '^'
    inc lop
    jmp p_procesar_nodigit_end
p_procesar_expresion_muldiv:
    call p_compress2
    lea bx, opStack
    add bx, lop
    mov al, c
    mov [bx], al
    inc lop
p_procesar_nodigit_end:
    ret
p_procesar_nodigit endp

; procedimiento que agrega el numero formado si existe
p_procesar_num proc near
    cmp byte ptr isn, 1
    jne p_procesar_num_end
    lea bx, numStack
    add bx, lnum
    add bx, lnum
    mov ax, num
    mov [bx], ax
    inc lnum
    mov word ptr num, 0
    mov byte ptr isn, 0
p_procesar_num_end:
    ret
p_procesar_num endp

; procedimiento para procesar un digito
p_procesar_digit proc near
    mov ax, num
    mov bx, 10
    mul bx
    mov dl, c
    sub dl, '0'
    xor dh, dh
    add ax, dx
    mov num, ax
    mov byte ptr isn, 1
    ret
p_procesar_digit endp

; compress1
p_compress1 proc near
p_compress1_loop:
    cmp lop, 0
    je p_compress1_end
    lea bx, opStack
    add bx, lop
    cmp byte ptr [bx - 1], '('
    je p_compress1_end

    call p_compute_last_operator
    jmp p_compress1_loop
p_compress1_end:
    ret
p_compress1 endp

; compress2
p_compress2 proc near
p_compress2_loop:
    cmp lop, 0
    jle p_compress2_end
    lea bx, opStack
    add bx, lop
    cmp byte ptr [bx - 1], '*'
    je p_compress2_tag1
    cmp byte ptr [bx - 1], '^'
    je p_compress2_tag1
    jmp p_compress2_end
p_compress2_tag1:
    call p_compute_last_operator
    jmp p_compress2_loop
p_compress2_end:
    ret
p_compress2 endp

; procesar el ultimo operador de la pila
p_compute_last_operator proc near
    dec lop
    dec lnum

    lea bx, numStack
    add bx, lnum
    add bx, lnum
    mov ax, [bx - 2]
    mov aux1, ax
    mov ax, [bx]
    mov aux2, ax

    lea bx, opStack
    add bx, lop
    cmp byte ptr [bx], '+'
    je p_compute_last_operator_suma
    cmp byte ptr [bx], '-'
    je p_compute_last_operator_resta
    cmp byte ptr [bx], '*'
    je p_compute_last_operator_mul
    cmp byte ptr [bx], '/'
    je p_compute_last_operator_div
    cmp byte ptr [bx], '^'
    je p_compute_last_operator_exp
p_compute_last_operator_suma:
    mov ax, aux1
    add ax, aux2
    mov aux1, ax
    jmp p_compute_last_operator_end
p_compute_last_operator_resta:
    mov ax, aux1
    sub ax, aux2
    mov aux1, ax
    jmp p_compute_last_operator_end
p_compute_last_operator_mul:
    mov ax, aux1
    imul word ptr aux2
    mov aux1, ax
    jmp p_compute_last_operator_end
p_compute_last_operator_div:
    mov ax, aux1
    xor dx, dx
    mov dh, ah
    and dh, 128
    cmp dh, 0
    je p_compute_last_operator_di1
    mov dx, 0FFFFh
p_compute_last_operator_di1:
    idiv word ptr aux2
    mov aux1, ax
    jmp p_compute_last_operator_end
p_compute_last_operator_exp:
    mov ax, aux1
    mov a_compute_pow_b, ax
    mov ax, aux2
    mov a_compute_pow_e, ax
    call p_compute_pow
    mov ax, o_compute_pow
    mov aux1, ax
p_compute_last_operator_end:
    lea bx, numStack
    add bx, lnum
    add bx, lnum

    mov ax, aux1
    mov [bx - 2], ax
    ret
p_compute_last_operator endp

; Procedimiento para calcular potencia
p_compute_pow proc near
    mov ax, 1
    mov cx, a_compute_pow_e
    cmp cx, 0
    jle p_compute_pow_end

    mov bx, a_compute_pow_b
p_compute_pow_loop:
    imul bx
    loop p_compute_pow_loop
p_compute_pow_end:
    mov o_compute_pow, ax
    ret
p_compute_pow endp

; Procedimiento para imprimir un entero
p_print_int proc near
    mov ax, a_print_int1    ; recuperamos el numero a imprimir
    mov dh, ah              ; vemos  
    and dh, 128             ; si es
    cmp dh, 0               ; negativo
    je print_int_label1     ; si no es negativo vamos de frente a imprimir
    mov bx, -1              ; 
    imul bx                 ; si es negativo lo multiplicamos por -1

    push ax         
    mov ah, 2
    mov dl, '-'             ; tambien mostramos el signo '-'
    int 21h
    pop ax
print_int_label1:
    mov cx, 0
    mov bx, 10
printeloop1:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz printeloop1

    mov ah, 2
printeloop2:
    pop dx
    add dx, '0'
    int 21h

    loop printeloop2

    ret
p_print_int endp

; Procedimiento para imprimir fin de linea
print_endl proc near
    mov dx, offset endl
    mov ah, 9
    int 21h
    ret
print_endl endp

codigo ends
end principal