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
    base: 
    .hword 0x00,  0x00,   0x00,  0x00,   0x00,  0x00 //6 direcciones de memoria consecutivos
    //     seg[0] seg[1] min[0] min[1] hora[0] hora[1]
    //      base  base+1  base+2 base+3 base+4 base+5
    .global reset               // Define el punto de entrada del codigo

    .func mainS


reset:
    BL configurar

@   Se guardara asi:  23:    5         9    :     5      9
@                        [base+3]  [base+2]   [base+1] [base]

@   Uso de registros:
@       R0: 
@       R1: 
@       R4: puntero a base
@       R5: Sera auxiliar para traer dato de memoria, modificarlo y mandarlo a memoria
@       R6: lo uso para apuntar a base +1, base +2...
@       R7: Contador de divisor, arranca en 0
@       R8: Limite de divisor, vale 1000
@       R9: Guardo constante para comparaciones de condicionales

    LDR R4, =base //Guardo direccion de base (seg0)
    MOV R7, #0 //R7 será divisor, inicia en 0
    MOV R8, #1000 //Limite del divisor

actualizar:
    ADD R7, #1 //Incremente divisor en 1
    CMP R7, R8
    BNE condUno //Si div no es igual a 1000, salto, sino...
    MOV R7, #0 //Divisor en 0
    //Incremento a seg[0]: traigo de memoria, incremento en registro y guardo en memoria
    LDR R5, [R4]
    ADD R5, #1
    STR R5, [R4]

condUno:
    MOV R9, #10 //Guardamos constante de condicion en un registro
    LDR R5, [R4] //Traigo a seg0 a registro
    CMP R9, R5
    BMI condDos //Si seg[0]<10, no hago nada, sino...
    MOV R5, #0 // Guardo constante 0...
    STR R5, [R6] // Guardo 0 en seg0
    //Incremento a seg[1]: traigo de memoria, incremento en registro y guardo en memoria
    MOV R6, #1 // Guardo cte 1 en registro...
    LDR R5, [R4,R6] //...Para apuntar a base+1 (seg1) y guardar en registro
    ADD R5, #1 
    STR R5, [R4,R6]

condDos:
    MOV R9, #6  //Guardamos constante de condicion en un registro
    //seg1 ya quedo guardado en registro de antes
    CMP R9, R5
    BMI condTres //Si seg[1]<6, no hago nada, sino...
    MOV R9, #0 // Guardo constante 0...
    STR R9, [R4,R6] // Guardo 0 en seg1
    //Incremento a min[0]: traigo de memoria, incremento en registro y guardo en memoria
    MOV R6, #2 // Guardo cte 2 en registro...
    LDR R5, [R4,R6] //...Para apuntar a base+2 (min0) y guardar en registro
    ADD R5, #1 
    STR R5, [R4,R6]

condTres:
    MOV R9, #10  //Guardamos constante de condicion en un registro
    //min0 quedo guardado en registro de antes
    CMP R9, R5 
    BMI condCuatro //Si min0 <10, no hago nada, sino...
    MOV R9, #0 // Guardo constante 0...
    STR R9, [R4,R6] // Guardo 0 en min0
    //Incremento a min[1]: traigo de memoria, incremento en registro y guardo en memoria
    MOV R6, #2 // Guardo cte 3 en registro...
    LDR R5, [R4,R6] //...Para apuntar a base+3 (min1) y guardar en registro
    ADD R5, #1 
    STR R5, [R4,R6]

condCuatro:
    MOV R9, #6  //Guardamos constante de condicion en un registro
    //min1 quedo guardado en registro de antes
    CMP R9, R5 
    BMI condCinco //Si min1<6, no hago nada, sino...
    MOV R9, #0 // Guardo constante 0...
    STR R9, [R4,R6] // Guardo 0 en min1
    //Incremento a hora[1]: traigo de memoria, incremento en registro y guardo en memoria
    MOV R6, #2 // Guardo cte 4 en registro...
    LDR R5, [R4,R6] //...Para apuntar a base+4 (hora0) y guardar en registro
    ADD R5, #1 
    STR R5, [R4,R6]

condCinco:
    MOV R9, #4  //Guardamos constante de condicion en un registro
    //hora0 quedo guardado en registro deantes
    CMP R9, R5 
    BNE condSeis //Si hora0 <4, salto a condicion 6, sino tambien verifico...
    MOV R9, #2  //Guardamos constante de condicion en un registro
    MOV R6, #5 // Guardo cte 5 en registro...
    LDR R5, [R4,R6] //...Para apuntar a base+5 (hora1) y guardar en registro
    CMP R9, R4 
    BNE condSeis //Si hora1 no es igual a 2, salto a condicion 6, sino...

    MOV R9, #0 // Guardo constante 0...
    STR R9, [R4,R6] // Guardo 0 en hora1
    MOV R6, #4 // Guardo cte 4 en registro...
    STR R9, [R4,R6] //...Para apuntar a base+4 (hora0) y guardar 0

condSeis:
    MOV R9, #10  //Guardamos constante de condicion en un registro
    STR R5, [R4,R6] //Guardo valor de hora0 en registro
    CMP R9, R5 
    BMI actualizar //Si hora0<10, no hago nada, sino...
    MOV R9, #0 // Guardo constante 0...
    STR R9, [R4,R6] // Guardo 0 en hora
    //Incremento a hora[1]: traigo de memoria, incremento en registro y guardo en memoria
    MOV R6, #5 // Guardo cte 5 en registro...
    LDR R5, [R4,R6] //...Para apuntar a base+5 (hora1) y guardar en registro
    ADD R5, #1 
    STR R5, [R4,R6]
    
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
