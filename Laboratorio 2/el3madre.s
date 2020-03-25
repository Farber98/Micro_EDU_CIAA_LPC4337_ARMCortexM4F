
    .cpu cortex-m4              // Indica el procesador de destino  
    .syntax unified             // Habilita las instrucciones Thumb-2
    .thumb                      // Usar instrucciones Thumb y no ARM

    .include "configuraciones/lpc4337.s"

/**
* Programa principal, siempre debe ir al principio del archivo
*/
    .section .text              // Define la seccion de codigo (FLASH)

base: 
    .word 0x08,  0x00,   0x00,  0x00,   0x00,  0x00 //6 direcciones de memoria consecutivos
    //     seg[0] seg[1] min[0] min[1] hora[0] hora[1]
    //      base  base+1  base+2 base+3 base+4 base+5

    .global reset               // Define el punto de entrada del codigo
    .func mainS

reset:
    BL configurar

    LDR R1, =base //Guardo direccion del LSB de segundos
    MOV R7, #1
    MOV R8, #2


@   Se guardara asi:  23:5     9    :     5      9
@                          [base+2]   [base+1] [base]

@   Uso de registros:
@       R0: Guarda cte 0 por consigna
@       R1: Direccion de seg[0] (direccion LSB, por consigna)
@       R2: Sera auxiliar para traer dato de memoria, modificarlo y mandarlo a memoria
@       R3: lo uso para apuntar a base +1, base +2...
@       R7: Contador de divisor, arranca en 0
@       R8: Limite de divisor, vale 1000
inicio:
    LDR R1, =base //Guardo direccion del LSB de segundos

    ADD R7, #1 //Incremento divisor en 1
    CMP R7,R8 //Comparo divisor con 1000
    BNE seguimos //Si es falso, no hago nada. Sino...
    MOV R7, #0 //Pongo divisor en 0
    LDR R2, [R1] //Voy a seg[0] y lo traigo
    ADD R2, #1 //Incremento en 1
    STR R2, [R1] //Guardo el valor incrementado



seguimos:
    LDR R1, =base //Guardo direccion del LSB de segundos
    MOV R0, #1 //Guardo 1 en R0
    BL subrutina // Llamo a la subrutina

    @ MOV R0, #1 //Guardo 1 en R0
    ADD R1, #8 //Guardo direccion de LSB de minutos
    BL subrutina // Llamo a la subrutina
    B inicio

stop:
    B stop              // Lazo infinito para terminar la ejecucion

subrutina:
condUno:
    MOV R9, #10 //Guardamos constante de condicion en un registro
    LDR R2, [R1]
    CMP R2, R9
    BMI condDos //Si seg[0]<10, no hago nada y salto
    MOV R2,#0 // Sino, guardo constante 0...
    STR R2, [R1] //...para poner seg[0] en 0 
    LDR R2, [R1,#4] //Voy a seg[1] y lo traigo
    ADD R2, #0x1  //Incremento en 1
    STR R2, [R1,#4] //Guardo el valor incrementado
    
condDos:
    MOV R9, #6 //Guardamos constante de condicion en un registro
    LDR R2, [R1,#4] //Traigo seg1 a registro
    CMP R2, R9
    BMI salgo //Si <6, salgo de subrutina
    MOV R2, #0 // Sino, guardo constante 0...
    STR R2, [R1,#4] //...para poner seg[1] en 0 
    LDR R2, [R1,#8] //Voy a min0 y lo traigo
    ADD R2, #1  //Incremento en 1
    STR R2, [R1,#8] //Guardo el valor incrementado
    
salgo:
    BX LR

    .align
    .pool
    .endfunc

/**
* Inclusion de las funciones para configurar los teminales GPIO del procesador
*/
    .include "ejemplos/digitos.s"
