/* 3) [Recomendado] Extraiga de la solución desarrollada por usted para el ejercicio 4 del laboratorio
1 el código necesario para implementar una subrutina transparente que realice el
incremento de los segundos representados como dos dígitos BCD almacenados en dos direcciones
consecutivas de memoria. La misma recibe el valor numérico 1 en el registro R0 y la
dirección de memoria donde está almacenado el dígito menos significativo en el registro R1.
La subrutina devuelve en el registro R0 el valor 1 si ocurre un desbordamiento de los segundos
y se debe efectuar un incremento en los minutos, o 0 en cualquier otro caso. */

    .cpu cortex-m4              // Indica el procesador de destino  
    .syntax unified             // Habilita las instrucciones Thumb-2
    .thumb                      // Usar instrucciones Thumb y no ARM

    .include "configuraciones/lpc4337.s"

/**
* Programa principal, siempre debe ir al principio del archivo
*/
    .section .text              // Define la seccion de codigo (FLASH)

base: 
    .hword 0x00, 0x00 //2 direcciones de memoria consecutivos

    .global reset               // Define el punto de entrada del codigo
    .func mainS

reset:
    BL configurar

@   Se guardara asi:  23:59:     5      9
@                             [base+1] [base]

@   Uso de registros:
@       R0: Guarda cte 0 por consigna
@       R1: Direccion de seg[0] (direccion LSB, por consigna)
@       R2: Sera auxiliar para traer dato de memoria, modificarlo y mandarlo a memoria
@       R7: Contador de divisor, arranca en 0
@       R8: Limite de divisor, vale 1000

    MOV R0, #1 //Guardo 1 en R0
    LDR R1, =base //Guardo direccion del LSB
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
    LDR R2, [R1,#1] //Traigo valor de seg[1] a registro
    ADD R2, #1 //Sumo 1 a seg[1]
    STR R2, [R1,#1] //Guardo la suma en la direccion de seg[1]

condDos:
    MOV R9, #6  //Guardamos constante de condicion en un registro
    MOV R0, #0 //Guardo 0 en caso de que no haya desbordamiento
    CMP R9, R2  
    BMI salir //Si seg[1]<6, vuelvo al inicio ; Sino, se produce el desbordamiento
    MOV R2, #0 // Guardo constante 0...
    STR R2, [R1] //...para poner seg[1] en 0 
    MOV R0, #1 //Guardo 1 en R0 porque se produjo un desbordamiento
    
    /*   INCREMENTOS DE LOS MINUTOS? Pense que trabajabamos solo con segundos 
    deberia acceder al valor de memoria donde esta min[1] y modificarlo    */

salir:
    BX LR // Retorno al programa principal

    .align
    .pool
    .endfunc

/**
* Inclusion de las funciones para configurar los teminales GPIO del procesador
*/
    .include "ejemplos/digitos.s"
