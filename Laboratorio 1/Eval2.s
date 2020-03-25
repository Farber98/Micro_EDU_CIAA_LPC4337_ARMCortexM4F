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
    .byte 0x3F, 0b00000110, 0x5B,0b01001111, 0x66, 0x6D, 0x7D, 0x07, 0xFF, 0b01100111 //Armo la tabla BCD a 7segm
//          0       1       2     3            4    5     6     7     8     9       
    .section .text              // Define la seccion de codigo (FLASH)
    .global reset               // Define el punto de entrada del codigo
    .func main

reset:
    BL configurar

primero:
    MOV R1, #0x04 //Guardo en R1 el primer digito a mostrar
    MOV R0, #0x05 //Guardo en R2 el segundo digito a mostrar. Entonces, mostrara R0-R1
    ADD R6, R0, #0 //Para adaptarme al ejercicio 1, guardo R0 en R6
    
    // Prendido de todos los bits gpio de los segmentos
    LDR R0,=GPIO_PIN2
    LDR R2, =tabla //Cargo en R2 la direccion tabla, sino no se puede hacer [tabla]
    
    //Guardar en la direccion de R1 el numero a mostrar
    LDRB R3, [R2,R1] //Cargo en R3, la tabla + el valor que muevo (es decir el numero a mostrar)
    STR R3,[R0] //Guardo el valor de R3 en la direccion de GPIO pin2

    // Prendido de todos bits gpio de los digitos
    LDR R2,=GPIO_PIN0
    LDR R0,=0x01 //Elijo que segmento enciendo (el primero)
    STR R0,[R2] 

    LDR R4, =0x00//Para inicializar el lazo en 0
    LDR R5, =0x186A0 //Condicion de parada (10 000)

lazouno:
    ADD R4, R4, #1 //Incremente contador en 1
    CMP R4, R5 //Comparo si el contador es igual a 10 000
    BEQ segundo //Si TRUE, entonces enciendo el 2do digito
    B lazouno //Sino, repito lazo

segundo:
    // Prendido de todos los bits gpio de los segmentos
    LDR R0,=GPIO_PIN2
    ADD R1, R6, #0 //Para adaptarme al ejercicio 1, traigo de vuelta a R1 el valor de R6
    LDR R2, =tabla //Cargo en R2 la direccion tabla, sino no se puede hacer [tabla]
    
    //Guardar en la direccion de R1 el numero a mostrar
    LDRB R3, [R2,R1] //Cargo en R3, la tabla + el valor que muevo (es decir el numero a mostrar)
    STR R3,[R0] //Guardo el valor de R3 en la direccion de GPIO pin2

    // Prendido de todos bits gpio de los digitos
    LDR R2,=GPIO_PIN0
    LDR R0,=0x02 //Elijo que segmento enciendo
    STR R0,[R2]

    LDR R4, =0x00//Para inicializar el lazo en 0
    LDR R5, =0x186A0 //Condicion de parada

lazodos:
    ADD R4, R4, #1 //Incremente contador en 1
    CMP R4, R5 //Comparo si el contador es igual a 10 000
    BEQ primero //Si TRUE, entonces enciendo el 1er digito de nuevo
    B lazodos //Sino, repito delay

stop:
    B stop              // Lazo infinito para terminar la ejecucion

    .align
    .pool
    .endfunc

    
/**
* Inclusion de las funciones para configurar los teminales GPIO del procesador
*/
    .include "ejemplos/digitos.s"
