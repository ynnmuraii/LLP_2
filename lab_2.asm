%include "io64.inc"

section .data
    newline db 10, 0

    ; Переменные для задания 1
    float_num1: dd 5.5
    result_up1: dd 0.0
    result_down1: dd 0.0
    ctrl_word1: dw 0

    ; Переменные для задания 2
    x_val: dd 0.3               ; Входное значение x (0 < x < 1)
    one: dd 1.0
    minus_one: dd -1.0
    zero: dd 0.0
    max_iter: dd 10             ; Количество итераций для аппроксимации
    ln2: dd 0.69314718          ; Значение ln(2)
    neg_one: dd -1.0
    
    ; Переменные для задания 3
    a3: dd 5.0
    b3: dd -1.0
    e3: dd 2.71828
    x3: dd 0.0

    ; Переменные для задания 4
    y4: dd -0.5
    x4: dd 3.0
    a4: dd 1.0
    result_cos4: dd 0.0

section .bss
    log2_result: resd 1

section .text
global main

main:
    mov rbp, rsp; for correct debugging
    
task1: ; Округление вверх и вниз
    fstcw [ctrl_word1]

    ; Округление вверх (к +∞)
    mov ax, [ctrl_word1]
    or ax, 0x0800
    mov [ctrl_word1], ax
    fldcw [ctrl_word1]

    fld dword [float_num1]
    fistp dword [result_up1]

    mov eax, [result_up1]
    PRINT_STRING "1) "
    PRINT_DEC 4, eax

    ; Округление вниз (к -∞)
    mov ax, [ctrl_word1]
    and ax, 0xF3FF
    or ax, 0x0400
    mov [ctrl_word1], ax
    fldcw [ctrl_word1]

    fld dword [float_num1]
    fistp dword [result_down1]

    mov eax, [result_down1]
    PRINT_STRING ", "
    PRINT_DEC 4, eax
    PRINT_STRING newline

    jmp task2
    
task2: ; Приближенное вычисление логарифма по основанию 2 с использованием SSE
    movss xmm0, dword [x_val]
    comiss xmm0, dword [zero]
    jbe error_negative_x
    comiss xmm0, dword [one]
    jae error_x_out_of_range

    movss xmm1, xmm0
    subss xmm1, dword [one]

    movss xmm2, xmm1              ; term = t
    movss xmm3, xmm1              ; sum = t
    movss xmm4, dword [one]       ; n = 1.0
    mov ecx, dword [max_iter]

taylor_loop:
    cmp ecx, 0
    je taylor_end

    addss xmm4, dword [one]

    mulss xmm2, xmm1

    ; Меняем знак на каждом шаге
    mulss xmm2, dword [neg_one]

    movss xmm5, xmm2
    divss xmm5, xmm4

    addss xmm3, xmm5

    dec ecx
    jmp taylor_loop

taylor_end:
    ; Теперь xmm3 содержит приближённое значение ln(x)
    ; Вычисляем log2(x) = ln(x) / ln(2)
    divss xmm3, dword [ln2]       ; xmm3 = ln(x) / ln(2)
    
    jmp task3

error_negative_x:
    PRINT_STRING "3) Error: x must be greater than 0."
    PRINT_STRING newline
    
    jmp task3

error_x_out_of_range:
    PRINT_STRING "3) Error: x must be less than 0."
    PRINT_STRING newline

    jmp task3
    
task3: ; Решение уравнения cos(ln(x + a)) = b
    finit

    ; Вычисляем 1 - b
    fld1
    fld dword [b3]
    fsubp st1, st0

    ; Вычисляем 1 + b
    fld1
    fld dword [b3]
    faddp st1, st0

    ; Делим (1 - b) / (1 + b)
    fdiv

    ; Вычисляем sqrt((1 - b) / (1 + b))
    fsqrt

    ; Вычисляем арктангенс
    fld1
    fpatan           ; st0 = arctg(sqrt(...))

    ; Умножаем результат на 2
    fld1
    fld1
    faddp st1, st0   ; st0 = 2
    fmulp st1, st0   ; st0 = 2 * arctg(sqrt(...))

    ; Вычисляем экспоненту e^(2 * arctg(sqrt(...)))
    fld st0
    fldl2e           ; st0 = log2(e)
    fmulp st1, st0   ; st0 = (2 * arctg(...)) * log2(e)
    fld st0
    frndint
    fsub st1, st0
    fxch
    f2xm1            ; st0 = 2^(дробная часть) - 1
    fld1
    fadd             ; st0 = 2^(дробная часть)
    fscale
    fstp st1
    fstp st1

    ; Вычитаем a
    fld dword [a3]
    fsubp st1, st0   ; st0 = e^(...) - a

    fstp dword [x3]

    jmp task4
    
task4: ; Проверка условия y < cos(x - a)

    ; Вычисление cos(x - a)
    fld dword [x4]
    fsub dword [a4]
    fcos
    fstp dword [result_cos4]

    ; Сравнение с y
    fld dword [result_cos4]
    fld dword [y4]
    fcomip
    jb less_label

    PRINT_STRING "4) y is not less than cos(x - a)"
    jmp end_label

less_label:
    PRINT_STRING "4) y is less than cos(x - a)"
    jmp end_label

end_label:
    xor eax, eax
    ret
