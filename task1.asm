%include "io64.inc"

section .data
    ; Переменные для задания 1
    float_num1: dd 5.5
    result_up1: dd 0.0
    result_down1: dd 0.0
    ctrl_word1: dw 0
    
section .text
global main

    
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

end:
    xor eax, eax
    ret