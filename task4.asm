%include "io64.inc"

section .data
    ; Переменные для задания 4
    y4: dq 46.0 
    x4: dq 6.0          
    a4: dq 1.5   
    x_minus_a: dq 0.0           ; Значение x - a
    exp_x_minus_a: dq 0.0       ; Значение e^(x - a)
    exp_neg_x_minus_a: dq 0.0   ; Значение e^-(x - a)
    cosh_result4: dq 0.0        ; Результат cosh(x - a)

    msg_result_true db "4) y is less than or equal to cosh(x - a)", 0
    msg_result_false db "4) y is greater than cosh(x - a)", 0

section .bss

section .text
global main

main:
    mov rbp, rsp ; for correct debugging

    ; Вычисляем x - a
    fld qword [x4]       ; ST0 = x
    fsub qword [a4]      ; ST0 = x - a
    fstp qword [x_minus_a]

    ; Вычисляем e^(x - a)
    fld qword [x_minus_a]    ; ST0 = x - a
    fldl2e                   ; ST0 = log2(e), ST1 = x - a
    fmulp st1, st0           ; ST0 = (x - a) * log2(e)
    
    ; Вычисляем 2^{(x - a) * log2(e)}
    fld st0                  ; Дублируем экспоненту
    frndint                  ; ST0 = целая часть n
    fsub st1, st0            ; ST1 = дробная часть f = экспонента - n
    fxch st1                 ; ST0 = f, ST1 = n
    f2xm1                    ; ST0 = 2^{f} - 1
    fld1                     ; ST0 = 1, ST1 = 2^{f} - 1, ST2 = n
    faddp st1, st0           ; ST0 = 2^{f}
    fscale                   ; ST0 = 2^{n+f}
    fstp st1                 ; Очистка стека
    fstp qword [exp_x_minus_a]

    ; Вычисляем e^-(x - a)
    fld qword [x_minus_a]    ; ST0 = x - a
    fchs                     ; ST0 = -(x - a)
    fldl2e                   ; ST0 = log2(e), ST1 = -(x - a)
    fmulp st1, st0           ; ST0 = - (x - a) * log2(e)
    
    ; Вычисляем 2^{- (x - a) * log2(e)}
    fld st0                  ; Дублируем экспоненту
    frndint                  ; ST0 = целая часть n
    fsub st1, st0            ; ST1 = дробная часть f = экспонента - n
    fxch st1                 ; ST0 = f, ST1 = n
    f2xm1                    ; ST0 = 2^{f} - 1
    fld1                     ; ST0 = 1, ST1 = 2^{f} - 1, ST2 = n
    faddp st1, st0           ; ST0 = 2^{f}
    fscale                   ; ST0 = 2^{n+f}
    fstp st1                 ; Очистка стека
    fstp qword [exp_neg_x_minus_a]

    ; Вычисляем cosh(x - a)
    fld qword [exp_x_minus_a]      ; ST0 = e^(x - a)
    fld qword [exp_neg_x_minus_a]  ; ST0 = e^-(x - a), ST1 = e^(x - a)
    faddp st1, st0                 ; ST0 = e^(x - a) + e^-(x - a)
    fld1                           ; ST0 = 1, ST1 = сумма
    fadd st0, st0                  ; ST0 = 2
    fdivp st1, st0                 ; ST0 = (e^(x - a) + e^-(x - a)) / 2
    fstp qword [cosh_result4]

    ; Проверяем условие y <= cosh(x - a)
    fld qword [y4]                ; ST0 = y
    fld qword [cosh_result4]      ; ST0 = cosh(x - a), ST1 = y
    fcompp                        ; Сравниваем ST0 и ST1, очищаем стек

    fstsw ax                      ; Сохраняем статусное слово FPU в AX
    sahf                          ; Загружаем AH в флаги процессора

    jae condition_true            ; Если CF=0, то y <= cosh(x - a)

    ; Условие не выполнено
    PRINT_STRING msg_result_false
    NEWLINE
    jmp end

condition_true:
    ; Условие выполнено
    PRINT_STRING msg_result_true
    NEWLINE

end:
    xor eax, eax
    ret
