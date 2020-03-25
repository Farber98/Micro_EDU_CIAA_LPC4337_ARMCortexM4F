/*7) [Recomendado] Modifique el ejercicio visto en la clase de laboratorio para prender los segmentos
correspondientes a un dígito determinado. El valor a mostrar, que deberá estar entre
0 y 9, se encuentra almacenado en el registro R0. Para la solución deberá utilizar una tabla de
conversión de BCD a 7 segmentos la cual deberá estar almacenada en memoria no volatil. La
asignación de los bits a los correspondientes segmentos del dígito se muestra en la figura que
acompaña al enunciado. */

    .cpu cortex-m4              // Indica el procesador de destino  
    .syntax unified             // Habilita las instrucciones Thumb-2
    .thumb                      // Usar instrucciones Thumb y no ARM

    .include "configuraciones/lpc4337.s"

/**
* Programa principal, siempre debe ir al principio del archivo
*/
    .section .data //Abajo de esto pongo todo lo que guardo en memoria no volatil
tabla: 
    .byte 0x3F, 0b00000110, 0x5B,0b01001111, 0x66, 0x6D, 0x7D, 0x07, 0xFF, 0b01100111, 0x77, 0b01111100, 0b00111001, 0b01011110, 0b01111001, 0b01110001   //Armo la tabla BCD a 7segm
//          0       1       2     3            4    5     6     7     8     9           A       b           c            d          E             F
    .section .text              // Define la seccion de codigo (FLASH)
    .global reset               // Define el punto de entrada del codigo
    .func main

reset:
    BL configurar

reloj:
    // Prendido de todos los bits gpio de los segmentos
    LDR R0,=GPIO_PIN2 //Guardo en R0 la direccion del pin2
    MOV R1,#0x0A //Elijo que numero encender 
    LDR R2, =tabla //Cargo en R2 la direccion tabla, sino no se puede hacer [tabla] en la siguiente linea
    
    //Guardar en la direccion de R1 el numero a mostrar
    LDRB R3, [R2,R1] //Cargo en R3, la direccion tabla + el valor que muevo (es decir el numero a mostrar)
    STR R3,[R0] //Guardo el valor de R3 (la direccion de tabla donde esta el digito a mostrar) en la direccion de GPIO pin2

    // Prendido de todos bits gpio de los digitos
    LDR R2,=GPIO_PIN0 //Guardo en R2 la direccion pin 0
    LDR R0,=0x01 //Elijo que segmento enciendo (en este caso, el primero de derecha a izquierda)
    STR R0,[R2] //Guardo el valor de R0 (el segmento a encender), en la direccion de memoria del pin 0

stop:
    B stop              // Lazo infinito para terminar la ejecucion

    .align
    .pool
    .endfunc

    
/**
* Inclusion de las funciones para configurar los teminales GPIO del procesador
*/
    .include "ejemplos/digitos.s"
