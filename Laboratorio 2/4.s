/* 2) Escriba un programa para inicializar con 0x55 un vector. El tamaño de los datos del vector es
de 16 bits y la cantidad de elementos se encuentra en la dirección base (también de 16 bits).
El vector comienza en la dirección base+2.  */

    .cpu cortex-m4              // Indica el procesador de destino  
    .syntax unified             // Habilita las instrucciones Thumb-2
    .thumb                      // Usar instrucciones Thumb y no ARM

    .include "configuraciones/lpc4337.s"

/**
* Programa principal, siempre debe ir al principio del archivo
*/
    .section .text              // Define la seccion de codigo (FLASH)
    .global reset               // Define el punto de entrada del codigo

    .func mainS


reset:
    BL configurar

    MOV R7, #0 //R7 será divisor, inicia en 0
    MOV R8, #1000 //Limite del divisor

    MOV R0, #0 //R0 es seg[0], inicia en 0
    MOV R1, #0 //R1 es seg1
    MOV R2, #0 //R2 es min0
    MOV R3, #0 //R3 es min1
    MOV R4, #0 //R4 es hora0
    MOV R5, #0 //R5 es hora1

actualizar:
    ADD R7, #1 //Incremente divisor en 1
    CMP R7, R8
    BNE condUno //Si no es igual, salto
    MOV R7, #0
    ADD R0, #1

condUno:
    MOV R9, #10 //Guardamos constante de condicion en un registro
    CMP R9, R0
    BMI condDos //Si es negativo, salto
    MOV R0, #0
    ADD R1, #1

condDos:
    MOV R9, #6  //Guardamos constante de condicion en un registro
    CMP R9, R1 
    BMI condTres //Si es negativo, salto
    MOV R1, #0
    ADD R2, #1

condTres:
    MOV R9, #10  //Guardamos constante de condicion en un registro
    CMP R9, R2 
    BMI condCuatro //Si es negativo, salto
    MOV R2, #0
    ADD R3, #1

condCuatro:
    MOV R9, #6  //Guardamos constante de condicion en un registro
    CMP R9, R1 
    BMI condCinco //Si es negativo, salto
    MOV R3, #0
    ADD R4, #1

condCinco:
    MOV R9, #2  //Guardamos constante de condicion en un registro
    CMP R9, R5 
    BNE condSeis //Si es negativo, salto
    MOV R9, #4  //Guardamos constante de condicion en un registro
    CMP R9, R4 
    BNE condSeis //Si es negativo, salto
    MOV R4, #0
    MOV R5, #0

condSeis:
    MOV R9, #10  //Guardamos constante de condicion en un registro
    CMP R9, R4 
    BMI actualizar //Si es negativo, salto
    MOV R4, #0
    ADD R5, #1
    B actualizar
    
stop:
    B stop              // Lazo infinito para terminar la ejecucion

    .align
    .pool
    .endfunc

/**
* Inclusion de las funciones para configurar los teminales GPIO del procesador
*/
    .include "ejemplos/digitos.s"
