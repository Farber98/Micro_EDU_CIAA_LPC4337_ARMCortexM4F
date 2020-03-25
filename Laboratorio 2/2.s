
    .cpu cortex-m4              // Indica el procesador de destino  
    .syntax unified             // Habilita las instrucciones Thumb-2
    .thumb                      // Usar instrucciones Thumb y no ARM

    .include "configuraciones/lpc4337.s"

/**
* Programa principal, siempre debe ir al principio del archivo
*/
    .section .data // Define la sección de variables (RAM)
    base:
        .space 12 // Reserva un espacio de tres palabras (debe ser que agarra de a bytes, 12x8)

    @ base: //Defino la variable base (vector)
    @     .equ size, 16 //Reservo 16 
    @     .byte size
    .section .text // Define la sección de código (FLASH)
    .global reset // Define el punto de entrada del código
    .func main

reset:
    BL configurar

    LDR R0,=base // Apunto R0 a la direccion del numero de 64 bits
    MOV R2,#57 // Cargo en R2 la parte alta del numero de 64 bits
    STR R2,[R0] // Guardo en la direccion de base la parte alta
    MOV R2,#10 // Cargo en R2 la parte baja del numero de 64 bits
    STR R2,[R0,#4] // Guardo en la direccion de base la parte baja
    MOV R1, #0xFFFFFFF5
    BL suma // Llamo a la subrutina
    
stop:
    B stop // Lazo infinito para terminar

suma:
    LDR R2,[R0,#4] // Cargo en R2 la parte baja
    ADC R1,R2 // Realizo la suma de 1 con parte baja
    STR R1, [R0,#4]     //Guardo resultado parte baja en memroia
    BGE sumocarry //Si no entra en 32 bits, entra al sumocarry
    BX LR // Retorno al programa principal

sumocarry:
    LDR R2,[R0] // Traigo la parte alta de memoria
    ADD R2,#1 // Le sumo 1
    STR R2, [R0] //Guardo la suma en la parte alta
    BX LR // Retorno al programa principal