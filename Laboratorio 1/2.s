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

@ base: //Defino la variable base (vector)
@     .equ size, 16 //Reservo 16 
@     .byte size

base: //En teoria estamos reservando 16 lugares de memoria
    .hword 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 

reset:
    BL configurar

    LDR R1,=base //En R1 guardo la direccion base
    ADD R2, R1, #32 //Condicion de parada
    LDR R0,=0x55 //En R0 guardo 0x55    

reloj:
    ADD R1, R1, #2 //En R1 guardo base + 2
    //Uso strh porque half word = 16 bits
    STRH R0,[R1] //En la direccion de memoria de R1, guardo R0 (que es 0x55).

    CMP R1,R2 //Seteamos la bandera Z
    BEQ stop //Hago salto (brunch) a STOP si Z=1

    B reloj

stop:
    B stop              // Lazo infinito para terminar la ejecucion

    .align
    .pool
    .endfunc

/**
* Inclusion de las funciones para configurar los teminales GPIO del procesador
*/
    .include "ejemplos/digitos.s"
