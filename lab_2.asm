%include "io64.inc"

section .data
    ; Переменные для задания 1
    float_num1: dd 5.5
    result_up1: dd 0.0
    result_down1: dd 0.0
    ctrl_word1: dw 0

    ; Переменные для задания 2
    num2: dd 0.1
    ln2: dd 0.693147
    log_result2: dd 0.0
    
    ; Переменные для задания 3
    a3: dd 5.0
    b3: dd -1.0
    e3: dd 2.71828

    ; Переменные для задания 4
    y4: dd -0.5
    x4: dd 3.0
    a4: dd 1.0
    result_cos4: dd 0.0

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
    PRINT_STRING "; "

    jmp task2
    
task2: ; Приближенное вычисление логарифма по основанию 2

    movss xmm0, [num2]

    ; Нет прямой инструкции для ln в SSE, поэтому используем приближение
    ; Применение x87 для вычисления ln(num1)
    fldln2
    fld dword [num2]
    fyl2x
    fstp dword [log_result2]
    movss xmm0, [log_result2]

    movss xmm1, [ln2]       ; xmm1 = ln(2)
    divss xmm0, xmm1        ; xmm0 = ln(num1) / ln(2)
        
    jmp task3
    
task3: ; Решение уравнения cos(ln(x + a)) = b
    ; Вычисляем выражение x = e^(2 * arctan(sqrt((1 - b) / (1 + b)))) - a

    ; Вычисляем 1 - b
    fld dword [b3]
    fld1
    fsub st0, st1

    ; Вычисляем 1 + b
    fld1
    faddp st2, st0
    fld st1

    ; Делим (1 - b) / (1 + b)
    fdivp st1, st0
    fstp st1

    ; Вычисляем sqrt((1 - b) / (1 + b))
    fsqrt

    ; Вычисляем atan(sqrt((1 - b) / (1 + b)))
    fld1
    fpatan

    ; Умножаем результат на 2
    fadd st0, st0
    
    ; Вычисляем e^(2 * atan(...))
    fld dword [e3]
    fyl2x
    fld1
    fld st1
    fprem
    f2xm1
    fadd
    fscale
    fstp st1

    ; -a
    fld dword [a3]
    fsubr st0, st1
    fstp st1

    fstp st0
    
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
