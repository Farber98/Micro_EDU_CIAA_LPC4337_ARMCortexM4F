/*5) Escriba un programa para encontrar el mayor elemento en un bloque de datos. El tamaño de
dato es de 8 bits. El resultado debe guardarse en la dirección base, la longitud del bloque está
en la dirección base+1 y el bloque comienza a partir de la dirección base+2 */

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

base: //Defino la variable base
    .equ size, 8 //Reservo 8 bits (tamano de dato)
    .byte size

reset:
    BL configurar

main:
    LDR R0, =base //Guardo en R0 la direccion de base
    LDR R4, #3
    STR R4, [R0,#1] //Guardo el tamano del vector en base+1
    
    //Guardo el valor de los datos:
    LDR R4, 0x3A
    STR R4, [R0,#2]
    LDR R4, 0xAA
    STR R4, [R0,#3] 
    LDR R4, 0xF2
    STR R4, [R0,#4] 

    //Traigo de memoria los datos y longitud del vector, y guardo en registros
    @ LDR R1, [R0,#1] //Tamano vector
    @ ADD R1, R1, #2
    @ LDR R2, [R0,#2] //Primer dato
    @ LDR R3, [R0,#3]//Segundo dato
    @ LDR R4, [R0,#4] //Tercer dato
    
     //R5 guardara el mayor
    LDR R1, #0 //Contador en 0
    LDR R2, #1 //Contador en 1
    LDR R5, [R0,#2] //Tomo el primer dato como el mayor
   
comparaciones:
    LDR R2, [R0,#1] //Guardo en registro el tamano del vector
    CMP R1, R2 //Comparo contador con tamano
    BEQ stop //Entonces, dejo de comparar
    //Sino, hago comparaciones:
    
    ADD R2, R2, #1 //Aumento contador para apuntar al siguiente registro (la primera vez apuntara a 2)
    LDR R3, [R0,R2] //Guardo en registro el dato
    CMP R5,R3  //Si el registro que leemos > al guardado, N=1
    BMI guardomayor

guardomayor:
    LDR R5, R3 //Guardo en R5 el mayor, NO SE COMO SE HACE
    ADD R1, R1, #1 
    B comparaciones
    
stop:
    B stop              // Lazo infinito para terminar la ejecucion

    .align
    .pool
    .endfunc

/**
* Inclusion de las funciones para configurar los teminales GPIO del procesador
*/
    .include "ejemplos/digitos.s"
