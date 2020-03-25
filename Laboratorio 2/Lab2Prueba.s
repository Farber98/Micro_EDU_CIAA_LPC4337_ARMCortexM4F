.cpu cortex-m4              // Indica el procesador de destino  
    .syntax unified             // Habilita las instrucciones Thumb-2
    .thumb                      // Usar instrucciones Thumb y no ARM

    .include "configuraciones/lpc4337.s"

/**
* Programa principal, siempre debe ir al principio del archivo
*/
    .section .text              // Define la seccion de codigo (FLASH)
    .global reset               // Define el punto de entrada del codigo
   
    .func main

reset:
    BL configurar

reloj:
    LDR R6,=tabla
    LDR R10,=Digitos

    MOV R9,#0x00

    MOV R8,#0x00
    LDR R7,=120
inicio:
    LDRB R0,[R10]
    LDRB R1,[R10,#1]
    ADD R8,#1
    CMP R7,R8
    IT EQ
    BLEQ Cambio
    LDR R2,=100000
    MOV R5,#0x00
    LDR R3,=GPIO_PIN2
    ADD R4,R6,R0
    LDRB R4,[R4]
    STR R4,[R3]

    // Prendido de todos bits gpio de los digitos
    LDR R3,=GPIO_PIN0
    LDR R4,=0x01
    STR R4,[R3]
lazo:    
    CMP R2,R5

    ADD R5,#1
    BNE lazo
    LDR R2,=100000
    MOV R5,#0x00
    LDR R3,=GPIO_PIN2
    ADD R4,R6,R1
    LDRB R4,[R4]
    STR R4,[R3]
    LDR R3,=GPIO_PIN0
    LDR R4,=0x02
    STR R4,[R3]
lazo2:    
    CMP R2,R5
    ADD R5,#1
    BNE lazo2
    B inicio



Cambio:
    MOV R8,#0
    LDRB R2,[R10,#1]
    LDRB R3,[R10]
    ADD R3,#1
    CMP R3,#10
    ITTE EQ
    STREQ R9,[R10]
    ADDEQ R2,#1
    STRNE R3,[R10]
    CMP R2,#6
    ITE EQ
    STREQ R9,[R10,#1]
    STRNE R2,[R10,#1]
    BX LR

    .align
    .pool
tabla: .byte 0xBF,0x06,0x5B,0x4F,0x66
       .byte 0x6D,0xFD,0x07,0xFF,0xEF
    .endfunc
Digitos: .byte 0x00,0x00
/**
* Inclusion de las funciones para configurar los teminales GPIO del procesador
*/
    .include "ejemplos/digitos.s"
    