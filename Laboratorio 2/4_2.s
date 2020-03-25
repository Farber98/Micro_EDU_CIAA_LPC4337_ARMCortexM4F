@ 4) [Recomendado] Reimplemente la solución desarrollada por usted para el ejercicio 4 del laboratorio
@ 1 usando dos llamadas sucesivas a la subrutina del ejercicio anterior para incrementar
@ los segundos y minutos.

    .cpu cortex-m4              // Indica el procesador de destino  
    .syntax unified             // Habilita las instrucciones Thumb-2
    .thumb                      // Usar instrucciones Thumb y no ARM

    .include "configuraciones/lpc4337.s"

/**
* Programa principal, siempre debe ir al principio del archivo
*/
    .section .text              // Define la seccion de codigo (FLASH)

base: 
    .hword 0x00,  0x00,   0x00,  0x00,   0x00,  0x00 //6 direcciones de memoria consecutivos
    //     seg[0] seg[1] min[0] min[1] hora[0] hora[1]
    //      base  base+1  base+2 base+3 base+4 base+5

    .global reset               // Define el punto de entrada del codigo
    .func mainS

reset:
    BL configurar

@   Se guardara asi:  23:5     9    :     5      9
@                          [base+2]   [base+1] [base]

@   Uso de registros:
@       R0: Guarda cte 0 por consigna
@       R1: Direccion de seg[0] (direccion LSB, por consigna)
@       R2: Sera auxiliar para traer dato de memoria, modificarlo y mandarlo a memoria
@       R3: lo uso para apuntar a base +1, base +2...
@       R7: Contador de divisor, arranca en 0
@       R8: Limite de divisor, vale 1000

    MOV R0, #1 //Guardo 1 en R0
    LDR R1, =base //Guardo direccion del LSB de segundos
    BL subrutina // Llamo a la subrutina

    MOV R0, #1 //Guardo 1 en R0
    ADD R1, #2 //Guardo direccion de LSB de minutos
    BL subrutina // Llamo a la subrutina

stop:
    B stop              // Lazo infinito para terminar la ejecucion

subrutina:
    MOV R7, #0 //R7 será divisor, inicia en 0
    MOV R8, #1000 //Limite del divisor

actualizar:
    ADD R7, #1 //Incremente divisor en 1
    CMP R7, R8 //Comparo contador con 1000
    BNE condUno //Si no es igual, salto
    MOV R7, #0 //Si no, pongo contador en 0...
    LDR R2, [R1] //Traigo valor de seg[0] a registro
    ADD R2, #1 //Sumo 1 a seg[0]
    STR R2, [R1]  //Guardo la suma en la direccion de seg[0]

condUno:
    @ LDR R2, [R1] //Traigo valor de seg[0] a registro -- NO HACE FALTA, YA GUARDADO DE ANTES
    MOV R9, #10 //Guardamos constante de condicion en un registro
    CMP R9, R2
    BMI condDos //Si seg[0]<10, no hago nada y salto
    MOV R2, #0 // Sino, guardo constante 0...
    STR R2, [R1] //...para poner seg[0] en 0
    MOV R3, #1
    LDR R2, [R1,R3] //Traigo valor de seg[1] a registro
    ADD R2, #1 //Sumo 1 a seg[1]
    STR R2, [R1,R3] //Guardo la suma en la direccion de seg[1]

condDos:
    MOV R9, #6  //Guardamos constante de condicion en un registro
    MOV R0, #0 //Guardo 0 en caso de que no haya desbordamiento
    CMP R9, R2  
    BMI salir //Si seg[1]<6, vuelvo al inicio ; Sino, se produce el desbordamiento
    MOV R2, #0 // Guardo constante 0...
    STR R2, [R1] //...para poner seg[1] en 0 
    MOV R0, #1 //Guardo 1 en R0 porque se produjo un desbordamiento
    
//Incremento de los minutos
    MOV R3, #2 //Guardo 2 en R3...
    LDR R2, [R1,R3] //...Para traer valor de min[0] a registro (base+2)
    ADD R2, #1 //Sumo 1 a min[0]
    STR R2, [R1,R3] //Guardo la suma en la direccion de min[0]

salir:
    BX LR // Retorno al programa principal

    .align
    .pool
    .endfunc

/**
* Inclusion de las funciones para configurar los teminales GPIO del procesador
*/
    .include "ejemplos/digitos.s"
