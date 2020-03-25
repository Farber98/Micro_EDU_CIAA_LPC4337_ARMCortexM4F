/*3) [Recomendado] Escriba un programa que agregue un bit de paridad a una cadena de caracteres
ASCII. La finalización de la cadena esta marcada con el valor 0x00 y el bloque comienza
en la dirección base. Se debe poner en 1 el bit más significativo de cada caracter si y sólo si
esto hace que el número total de unos en ese byte sea par. */

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

@ base: //Defino la variable base
@     .equ size, 8 //Reservo 8 
@     .bword size //no se si tengo que hacer eto oguardar una cadena en flash

base: .byte //Define variable base de 1 byte (8bits)

@ cadena: //Defino la variable cadena
@     .equ size, 32 //Reservo 8 
@     .word size

cadena: .asciz "PERRO"//Defino variable cadena de 32 bits

reset:
    BL configurar
    
    LDR R0,=0x00 //R0 sera el contador de 1s, guardo 0
    LDR R1,=base //En R1 guardo la direccion base
    
    LDR R3,=0x00 //R3 sera el TERMIANDOR NULO
    LDR R4,=8 //R4 sera el limite del byte
    LDR R5,=0 //R5 guardo contador que llega hasta 8
    //R6 lo usamos como auxuliar despues
    //R7 lo mismo
reloj:
    LDR R6, [R1] //Registro aux para poder hacer pingo el caracter
    LDR R7, [R1] //Lo mismo que arriba, solo que R7 no lo tocamos
    CMP R7, R3 //Si son iguales, ya recorri toda la cadena
    BEQ stop //Entonces termino el programa

 bitabit:
    LSR R6, R6, #1 //Shifteo un 0 al MSB, y el LSB va al carry
    ADD R5, R5, #1 //Cuento un shifteo
    CMP R5, R4 //Si ya recorri todo el caracter
    BEQ paridad //Salto a control de paridad
    BCS tengouno //Si el carry vale 1, tengo un uno en el byte y lo sumo al contador

tengouno:
    ADD R0, R0, #1
    B bitabit
 
paridad:
    //controlo si es oar o no, lo modfico y paso a sig caract
    LDR R5, #0
    CMP R0, #1
    BEQ modificar
    CMP R0, #3
    BEQ modificar
    CMP R0, #5
    BEQ modificar
    CMP R0, #7
    BEQ modificar
    ADD R1, R1, #1 //Muevo el puntero al sgte caracter
    B reloj

modificar:
    ADD R7, R7, 0x80 //Sumo 1000 0000 (agrego 1 al MSB)
    STR R7, [R1] //En la direccion de R1 guardo R7
    ADD R1, R1, #1  //Muevo el puntero al sgte caracter
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
