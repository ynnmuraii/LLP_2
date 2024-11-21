%include "io64.inc" 

section .data
    ; Переменные для задания 1
    float_num1: dd -5.5
    result_up1: dd 0.0 
    result_down1: dd 0.0
    ctrl_word1: dw 0  

    ; Переменные для задания 2
    x_val: dd 0.3                  ; Входное значение x (0 < x < 1)
    one: dd 1.0 
    minus_one: dd -1.0 
    zero: dd 0.0 
    max_iter: dd 10                ; Количество итераций для аппроксимации
    ln2: dd 0.69314718             ; Значение ln(2)
    neg_one: dd -1.0               ; Для смены знака
    
    ; Переменные для задания 3
    a3: dd 5.0
    b3: dd -1.0  
    e3: dd 2.71828                 ; Приближённое значение числа e
    x3: dd 0.0

section .text
global main

main:
    mov rbp, rsp  
    
task1: ; Округление вверх и вниз
    fstcw [ctrl_word1]  

    ; Округление вверх (к +∞)
    mov ax, [ctrl_word1]
    or ax, 0x0800                  ; Устанавливаем биты 10 и 11 для округления вверх
    mov [ctrl_word1], ax           ; Сохраняем изменённое контрольное слово
    fldcw [ctrl_word1]             ; Загружаем новое контрольное слово в FPU

    fld dword [float_num1] 
    fistp dword [result_up1]       ; Округляем и сохраняем в result_up1, выталкиваем из стека FPU

    mov eax, [result_up1] 
    PRINT_STRING "1) "  
    PRINT_DEC 4, eax 

    ; Округление вниз (к -∞)
    mov ax, [ctrl_word1]
    and ax, 0xF3FF                 ; Очищаем биты 10 и 11 (режим округления)
    or ax, 0x0400                  ; Устанавливаем биты для округления вниз
    mov [ctrl_word1], ax           ; Сохраняем изменённое контрольное слово
    fldcw [ctrl_word1]             ; Загружаем новое контрольное слово в FPU

    fld dword [float_num1]  
    fistp dword [result_down1]     ; Округляем и сохраняем в result_down1, выталкиваем из стека FPU

    mov eax, [result_down1] 
    PRINT_STRING ", " 
    PRINT_DEC 4, eax 
    NEWLINE

    jmp task2  
    
task2: ; Приближенное вычисление логарифма по основанию 2 с использованием SSE
    movss xmm0, dword [x_val]
    comiss xmm0, dword [zero]
    jbe error_negative_x 
    comiss xmm0, dword [one]
    jae error_x_out_of_range 

    movss xmm1, xmm0
    subss xmm1, dword [one]        ; xmm1 = x - 1

    movss xmm2, xmm1               ; xmm2 = term = t = x - 1
    movss xmm3, xmm1               ; xmm3 = sum = t
    movss xmm4, dword [one]        ; xmm4 = n = 1.0
    mov ecx, dword [max_iter]

taylor_loop:
    cmp ecx, 0
    je taylor_end

    addss xmm4, dword [one]        ; n = n + 1

    mulss xmm2, xmm1               ; term = term * (x - 1)

    ; Меняем знак на каждом шаге
    mulss xmm2, dword [neg_one]    ; term = -term

    movss xmm5, xmm2               ; xmm5 = term
    divss xmm5, xmm4               ; xmm5 = term / n

    addss xmm3, xmm5               ; sum = sum + (term / n)

    dec ecx                        ; ecx = ecx - 1
    jmp taylor_loop                ; Повторяем цикл

taylor_end:
    ; Теперь xmm3 содержит приближённое значение ln(x)
    ; log2(x) = ln(x) / ln(2)
    divss xmm3, dword [ln2]        ; xmm3 = ln(x) / ln(2)
    
    jmp task3 

error_negative_x:
    PRINT_STRING "3) Error: x must be greater than 0."
    NEWLINE
    
    jmp task3

error_x_out_of_range:
    PRINT_STRING "3) Error: x must be less than 1."
    NEWLINE

    jmp task3
    
task3: 
    ; Изначально cos(ln(x + a)) = b -> Решение -> x = e^arccos(b)-a
    ; Т.к. arccos нет, то переписываем через arctan: arccos(x) = 2*a1ёrctan(sqrt( (1-x)/(1+x)) )
    ; x = e^2*arctan(sqrt( (1-b)/(1+b)) ) -a
    ; ПОЛИЗ e 2 arctan sqrt 1 b - 1 b + / * ^ a -
    
    ; Вычисляем 1 - b
    fld1                           ; ST0 = 1.0
    fld dword [b3]                 ; ST0 = b, ST1 = 1.0
    fsubp st1, st0                 ; ST1 = ST1 - ST0 = 1.0 - b, выталкиваем ST0

    ; Вычисляем 1 + b
    fld1                           ; ST0 = 1.0
    fld dword [b3]                 ; ST0 = b, ST1 = 1.0, ST2 = (1.0 - b)
    faddp st1, st0                 ; ST1 = ST1 + ST0 = 1.0 + b, выталкиваем ST0

    ; Делим (1 - b) / (1 + b)
    fdiv                           ; ST0 = ST1 / ST0 = (1 - b) / (1 + b), выталкиваем ST1

    ; Вычисляем sqrt((1 - b) / (1 + b))
    fsqrt                          ; ST0 = sqrt(ST0)

    ; Вычисляем арктангенс
    fld1                           ; ST0 = 1.0, ST1 = sqrt(...)
    fpatan                         ; ST0 = arctg(ST1 / ST0), выталкиваем ST1

    ; Умножаем результат на 2
    fld1                           ; ST0 = 1.0, ST1 = arctg(...)
    fld1                           ; ST0 = 1.0, ST1 = 1.0, ST2 = arctg(...)
    faddp st1, st0                 ; ST1 = ST1 + ST0 = 2.0, выталкиваем ST0
    fmulp st1, st0                 ; ST1 = ST1 * ST0 = 2.0 * arctg(...), выталкиваем ST0

    ; Вычисляем экспоненту e^(2 * arctg(sqrt(...)))
    fld st0                        ; ST0 = ST0 (дублируем вершину стека)
    fldl2e                         ; ST0 = log2(e), ST1 = исходный ST0, ST2 = ...
    fmulp st1, st0                 ; ST1 = ST1 * ST0 = (2 * arctg(...)) * log2(e), выталкиваем ST0

    fld st0                        ; ST0 = ST0 (дублируем экспоненту)
    frndint                        ; ST0 = целая часть экспоненты (n)
    fsub st1, st0                  ; ST1 = ST1 - ST0 = дробная часть (f)
    fxch                           ; Обмениваем ST0 и ST1: ST0 = f, ST1 = n

    f2xm1                          ; ST0 = 2^(f) - 1
    fld1                           ; ST0 = 1.0, ST1 = 2^(f) - 1, ST2 = n
    faddp st1, st0                 ; ST1 = ST1 + ST0 = 1.0 + (2^(f) - 1) = 2^(f)
    fscale                         ; ST0 = ST0 * 2^(ST1) = 2^(n + f) = e^(...)
    fstp st1  

    fstp st1 

    ; Вычитаем a
    fld dword [a3]                 ; ST0 = a
    fsubp st1, st0                 ; ST1 = ST1 - ST0 = e^(...) - a, выталкиваем ST0

end_label:
    xor eax, eax     
    ret   
