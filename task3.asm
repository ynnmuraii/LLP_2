section .data
    a3: dd 2.0                   ; Значение a
    b3: dd 0.5                  ; Значение b
    x3: dd 0.0                    ; Результат вычислений

section .text
global main

main:
    mov rbp, rsp

task3:
    ; x = e^arccos(b)-a
    ; так как арккосинуса нет то переписываем через арктан arccos(x) = 2*arctan(sqrt( (1-x)/(1+x)) )
    ; итого:  x = e^2*arctan(sqrt( (1-b)/(1+b)) ) -a
    ;ПОЛИЗ e 2 arctan sqrt 1 b - 1 b + / * ^ a -
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
    fstp st1                       ; Убираем ST1, сохраняем результат на вершине стека

    ; Вычитаем a
    fld dword [a3]                 ; ST0 = a
    fsubp st1, st0                 ; ST1 = ST1 - ST0 = e^(...) - a, выталкиваем ST0

    ; Сохраняем результат в x35    fstp dword [x3]                ; x3 = e^(2 * arctan(...)) - a

    ; Завершаем программу
    xor eax, eax
    ret
