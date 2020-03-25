.cpu cortex-m4          // Indica el procesador de destino
    .syntax unified         // Habilita las instrucciones Thumb-2
    .thumb                  // Usar instrucciones Thumb y no ARM

    .include "configuraciones/lpc4337.s" //da acceso a rutinas para prender y apagar los leds
    .include "configuraciones/rutinas.s"

/****************************************************************************/
/* Definiciones de macros                                                   */
/****************************************************************************/

// Recursos utilizados para prender los digitos
    .equ ENABLE_D1_PORT,    0
    .equ ENABLE_D1_PIN,     0
    .equ ENABLE_D1_BIT,     0
    .equ ENABLE_D1_MASK,    (1 << ENABLE_D1_BIT)

    .equ ENABLE_D2_PORT,    0
    .equ ENABLE_D2_PIN,     1
    .equ ENABLE_D2_BIT,     1
    .equ ENABLE_D2_MASK,    (1 << ENABLE_D2_BIT)

    .equ ENABLE_D3_PORT,    1
    .equ ENABLE_D3_PIN,     15
    .equ ENABLE_D3_BIT,     2
    .equ ENABLE_D3_MASK,    (1 << ENABLE_D3_BIT)

    .equ ENABLE_D4_PORT,    1
    .equ ENABLE_D4_PIN,     17
    .equ ENABLE_D4_BIT,     3
    .equ ENABLE_D4_MASK,    (1 << ENABLE_D4_BIT)

    .equ ENABLE_D_MASK,       (ENABLE_D1_MASK | ENABLE_D2_MASK | ENABLE_D3_MASK | ENABLE_D4_MASK)
    .equ ENABLE_D_GPIO,      0
// Recursos utilizados para el segmento A
    .equ A_PORT,    4
    .equ A_PIN,     0
    .equ A_BIT,     0
    .equ A_MASK,    (1 << A_BIT)

// Recursos utilizados para el segmento B
    .equ B_PORT,    4
    .equ B_PIN,     1
    .equ B_BIT,     1
    .equ B_MASK,    (1 << B_BIT)
// Recursos utilizados para el segmento C
     .equ C_PORT,    4
     .equ C_PIN,     2
     .equ C_BIT,     2
     .equ C_MASK,    (1 << C_BIT)
// Recursos utilizados para el segmento D
     .equ D_PORT,    4
     .equ D_PIN,     3
     .equ D_BIT,     3
     .equ D_MASK,    (1 << D_BIT)
// Recursos utilizados para el segmento E
    .equ E_PORT,    4
    .equ E_PIN,     4
    .equ E_BIT,     4
    .equ E_MASK,    (1 << E_BIT)
// Recursos utilizados para el segmento F
    .equ F_PORT,    4
    .equ F_PIN,     5
    .equ F_BIT,     5
    .equ F_MASK,    (1 << F_BIT)
// Recursos utilizados para el segmento G
     .equ G_PORT,    4
     .equ G_PIN,     6
     .equ G_BIT,     6
     .equ G_MASK,    (1 << G_BIT)
// Recursos utilizados para el segmento DP
     .equ DP_PORT,    6
     .equ DP_PIN,     8
     .equ DP_BIT,     16
     .equ DP_MASK,    (1 << DP_BIT)
     .equ DP_GPIO,      5

// Recursos utilizados por el led RGB
    .equ SEGM_GPIO,      2
    .equ SEGM_MASK,      (A_MASK |B_MASK |C_MASK |D_MASK |E_MASK |F_MASK |G_MASK)

// Recursos utilizados por la primera tecla
    .equ TEC_1_PORT,    4
    .equ TEC_1_PIN,     8
    .equ TEC_1_BIT,     12
    .equ TEC_1_MASK,    (1 << TEC_1_BIT)

// Recursos utilizados por la segunda tecla
    .equ TEC_2_PORT,    4
    .equ TEC_2_PIN,     9
    .equ TEC_2_BIT,     13
    .equ TEC_2_MASK,    (1 << TEC_2_BIT)

// Recursos utilizados por la tercera tecla
    .equ TEC_3_PORT,    4
    .equ TEC_3_PIN,     10
    .equ TEC_3_BIT,     14
    .equ TEC_3_MASK,    (1 << TEC_3_BIT)

// Recursos utilizados por la cuarta tecla
    .equ TEC_4_PORT,    6
    .equ TEC_4_PIN,     7
    .equ TEC_4_BIT,     15
    .equ TEC_4_MASK,    (1 << TEC_4_BIT)

// Recursos utilizados por el teclado
    .equ TEC_GPIO,      5
    .equ TEC_MASK,      ( TEC_1_MASK | TEC_2_MASK | TEC_3_MASK | TEC_4_MASK )

/****************************************************************************/
/* Vector de interrupciones                                                 */
/****************************************************************************/

    .section .isr           // Define una seccion especial para el vector
    .word   stack           //  0: Initial stack pointer value
    .word   reset+1         //  1: Initial program counter value
    .word   handler+1       //  2: Non mascarable interrupt service routine
    .word   handler+1       //  3: Hard fault system trap service routine
    .word   handler+1       //  4: Memory manager system trap service routine
    .word   handler+1       //  5: Bus fault system trap service routine
    .word   handler+1       //  6: Usage fault system tram service routine
    .word   0               //  7: Reserved entry
    .word   0               //  8: Reserved entry
    .word   0               //  9: Reserved entry
    .word   0               // 10: Reserved entry
    .word   handler+1       // 11: System service call trap service routine
    .word   0               // 12: Reserved entry
    .word   0               // 13: Reserved entry
    .word   handler+1       // 14: Pending service system trap service routine
    .word   systick_isr+1   // 15: System tick service routine
    .word   handler+1       // 16: Interrupt IRQ service routine


/****************************************************************************/
/* Definicion de variables globales                                         */
/****************************************************************************/

    .section .data          // Define la sección de variables (RAM)

PUNTO: .byte 1
c1: .byte 0
tabla: .byte 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F
ANTERIOR: .byte 0x01

/****************************************************************************/
/* Programa principal                                                       */
/****************************************************************************/

    .global reset           // Define el punto de entrada del código
    .section .text          // Define la sección de código (FLASH)
    .func main              // Inidica al depurador el inicio de una funcion
reset:

// Mueve el vector de interrupciones al principio de la segunda RAM
    LDR R1,=VTOR
    LDR R0,=#0x10080000
    STR R0,[R1]

// Llama a una subrutina para configurar el systick
        BL systick_init

// Configura los pines de los leds como gpio sin pull-up
    LDR R1,=SCU_BASE    //apunto al registro
    MOV R0,#(SCU_MODE_INACT | SCU_MODE_INBUFF_EN | SCU_MODE_ZIF_DIS | SCU_MODE_FUNC0)//cargo la mascara
    STR R0,[R1,#(A_PORT << 7 | A_PIN << 2)]	// genera el desplazamiento del SPSPX automaticamente es lo mismo q hacerlo manuelanmebte
    STR R0,[R1,#(B_PORT << 7 | B_PIN << 2)]
    STR R0,[R1,#(C_PORT << 7 | C_PIN << 2)]
    STR R0,[R1,#(D_PORT << 7 | D_PIN << 2)]
    STR R0,[R1,#(E_PORT << 7 | E_PIN << 2)]
    STR R0,[R1,#(F_PORT << 7 | F_PIN << 2)]
    STR R0,[R1,#(G_PORT << 7 | G_PIN << 2)]
    STR R0,[R1,#(ENABLE_D1_PORT << 7 | ENABLE_D1_PIN << 2)] // genera el desplazamiento del SPSPX automaticamente es lo mismo q hacerlo manuelanmebte
    STR R0,[R1,#(ENABLE_D2_PORT << 7 | ENABLE_D2_PIN << 2)]
    STR R0,[R1,#(ENABLE_D3_PORT << 7 | ENABLE_D3_PIN << 2)]
    STR R0,[R1,#(ENABLE_D4_PORT << 7 | ENABLE_D4_PIN << 2)]

//Configuro el DP aparte de los leds ya que su funcion es distinta
    LDR R1,=SCU_BASE
    MOV R0,#(SCU_MODE_INACT | SCU_MODE_INBUFF_EN | SCU_MODE_ZIF_DIS | SCU_MODE_FUNC4)//cargo la mascara
    STR R0,[R1,#(DP_PORT << 7 | DP_PIN << 2)]

// Configura los pines de las teclas como gpio con pull-up
    MOV R0,#(SCU_MODE_PULLUP | SCU_MODE_INBUFF_EN | SCU_MODE_ZIF_DIS | SCU_MODE_FUNC4)
    STR R0,[R1,#(TEC_1_PORT << 7 | TEC_1_PIN << 2)]
    STR R0,[R1,#(TEC_2_PORT << 7 | TEC_2_PIN << 2)]
    STR R0,[R1,#(TEC_3_PORT << 7 | TEC_3_PIN << 2)]
    STR R0,[R1,#(TEC_4_PORT << 7 | TEC_4_PIN << 2)]

// Apaga todos los display, led y dp
    LDR R1,=GPIO_CLR0
    LDR R0,=SEGM_MASK
    STR R0,[R1,#(SEGM_GPIO << 2)]
    LDR R0,=ENABLE_D_MASK
    STR R0,[R1,#(ENABLE_D_GPIO << 2)]
    LDR R0,=DP_MASK
    STR R0,[R1,#(DP_GPIO << 2)]


// Configura los bits gpio de los leds como salidas
    LDR R1,=GPIO_DIR0

    LDR R0,[R1,#(SEGM_GPIO << 2)]
    LDR R2,=SEGM_MASK
    ORR R0,R2
    STR R0,[R1,#(SEGM_GPIO << 2)]

    LDR R0,[R1,#(ENABLE_D_GPIO << 2)]
    LDR R2,=ENABLE_D1_MASK
    ORR R0,R2
    STR R0,[R1,#(ENABLE_D_GPIO << 2)]

    LDR R0,[R1,#(ENABLE_D_GPIO << 2)]
    ORR R0,#ENABLE_D2_MASK
    STR R0,[R1,#(ENABLE_D_GPIO << 2)]

    LDR R0,[R1,#(ENABLE_D_GPIO << 2)]
    ORR R0,#ENABLE_D3_MASK
    STR R0,[R1,#(ENABLE_D_GPIO << 2)]

    LDR R0,[R1,#(ENABLE_D_GPIO << 2)]
    ORR R0,#ENABLE_D4_MASK
    STR R0,[R1,#(ENABLE_D_GPIO << 2)]

    LDR R0,[R1,#(DP_GPIO << 2)]
    ORR R0,#DP_MASK
    STR R0,[R1,#(DP_GPIO << 2)]

// Configura los bits gpio de los botones como entradas
    LDR R0,[R1,#(TEC_GPIO << 2)]
    AND R0,#~TEC_MASK
    STR R0,[R1,#(TEC_GPIO << 2)]

// Define los punteros para usar en el programa
    LDR R4,=GPIO_PIN0 // 5 tecla(bit 16 DP), 2 leds,0 enable

//Defino los registros para determinar si se apreto o no la tecla
    MOV R5,#0 //tecla AUMENTAR
    MOV R2,#0 //tecla DISMINUIR
    MOV R8,#0 //punto
    mov r6,#0 //tecla izq
    mov r3,#0 //tecla der

refrescar:
// Carga el estado arctual de las teclas
    LDR   R0,[R4,#(TEC_GPIO << 2)]

// Verifica SI ESTA APRETADA LA TECLA 1 --> AUMENTO
    AND  R1,R0,#(1 << TEC_1_BIT)
    mvn r5,r5
    ands r5,r1
    it ne
    blne aumento
    mov r5,r1

// Verifico si esta apretado la tecla 2 --> Disminuyo
    AND  R1,R0,#(1 << TEC_2_BIT)
    MVN R2,R2
    ANDS R2,R1
    IT NE
    BLNE disminuyo
    MOV R2,R1

// Verifica si esta apretada la tecla 3 --> muevo a la derecha el punto
    AND  R1,R0,#(1 << TEC_3_BIT)
    mvn r3,r3
    ands r3,r1
    it ne
    blne derecha
    mov r3,r1

// verifico si esta apretada la tecla 4 --> muevo el punto a la izquierda
    AND  R1,R0,#(1 << TEC_4_BIT)
    MVN R6,R6
    ANDS R6,R1
    IT NE
    BLNE izquierda
    MOV R6,R1

// Repite el lazo de refresco indefinidamente
    B     refrescar

stop:
    B stop

derecha:
        ldr r7,=PUNTO
        ldrb r8,[r7]
        cmp r8,#1
        ite eq
        moveq r8,#8  //lo pongo al punto en el 4 segmento
        lsrne r8,#1  //sino desplazo 1 a la derecha
        strb r8,[r7]
        bx lr

izquierda:
        ldr r7,=PUNTO
        ldrb r8,[r7]
        cmp r8,#8
        ite eq // si el punto esta en la cuarta posicion
        moveq r8,#1// lo pongo en la primera posicion
        lslne r8,#1//sino lo desplazo 1 a la izquierda
        strb r8,[r7]
        bx lr

aumento:
        ldr r7,=PUNTO
        ldrb r9,[r7]  //traigo la ubicacion del punto
        lsr r9,#1
        cmp r9,#4
        it eq
            subeq r9,#1
        ldr r7,=c1
        ldrb r8,[r7,r9]
        add r8,#1
        cmp r8,#10
        it eq
            moveq r8,#0
        strb r8,[r7,r9]
        bx lr

disminuyo:
        ldr r7,=PUNTO
        ldrb r9,[r7]
        lsr r9,#1
        cmp r9,#4
        it eq
            subeq r9,#1
        ldr r7,=c1
        ldrb r8,[r7,r9]
        sub r8,#1
        cmp r8,#-1
        it eq
             moveq r8,#9
        strb r8,[r7,r9]
        bx lr
.pool
.endfunc
/****************************************************************************/
/* Rutina de inicialización del SysTick                                     */
/****************************************************************************/
    .func systick_init
systick_init:
    CPSID I                 // Deshabilita interrupciones

    // Configurar prioridad de la interrupcion
    LDR R1,=SHPR3           // Apunta al registro de prioridades
    LDR R0,[R1]             // Carga las prioridades actuales
    MOV R2,#2               // Fija la prioridad en 2 podriamos no haberlo hecho
    BFI R0,R2,#29,#3        // Inserta el valor en el campo
    STR R0,[R1]             // Actualiza las prioridades

    // Habilitar el SysTick con el reloj del nucleo
    LDR R1,=SYST_CSR
    MOV R0,#0x00
    STR R0,[R1]             // Quita ENABLE

    // Configurar el desborde para un periodo de 100 ms
    LDR R1,=SYST_RVR
    LDR R0,=#(240000 - 1)
    STR R0,[R1]             // Especifica valor RELOAD

    // Inicializar el valor actual del contador
    // Escribir cualquier valor limpia el contador
    LDR R1,=SYST_CVR
    MOV R0,#0
    STR R0,[R1]             // Limpia COUNTER y flag COUNT

    // Habilita el SysTick con el reloj del nucleo
    LDR R1,=SYST_CSR
    MOV R0,#0x07
    STR R0,[R1]             // Fija ENABLE, TICKINT y CLOCK_SRC

    CPSIE I                 // Rehabilita interrupciones
    BX  LR                  // Retorna al programa principal
    .pool                   // Almacena las constantes de código
    .endfunc

/****************************************************************************/
/* Rutina de servicio para la interrupcion del SysTick                      */
/****************************************************************************/
    .func systick_isr
systick_isr:

    LDR  R0,=ANTERIOR         // Apunta R0 a ANTERIOR
    LDRB R1,[R0]            // Carga el valor de ANTERIOR
    CMP R1,#8             // ME FIJO SI LLEGO AL 4 DIGITO
    ITE EQ
        MOVEQ R1,#1         //SI LLEGA AL 4 DIGITO LO VUELVO AL PRIMERO
    LSLNE R1,#1             //SINO LO LLEGA DESPLAZANDO A LA IZQ
    STR R1,[R0]

//APAGO TODO
    LDR R2,=GPIO_CLR0
    LDR R0,=SEGM_MASK            //APAGO LOS SEGMENTOS
    STR R0,[R2,#(SEGM_GPIO << 2)]

    LDR R0,=ENABLE_D_MASK       //APAGO LOS DIGITOS
    STR R0,[R2,#(ENABLE_D_GPIO << 2)]

    LDR R0,=DP_MASK             //APAGO EL DP
    STR R0,[R2,#(DP_GPIO << 2)]

    LDR R0,=c1
    LSR R3,R1,#1
    CMP R3,#4
    IT EQ
    SUBEQ R3,#1
    LDRB R2,[R0,R3]

    LDR R0,=GPIO_SET0
    STR R1,[R0]

    LDR R0,=GPIO_SET2
    ldr r3,=tabla
    LDR R2,[R3,R2]
    STR R2,[R0]

    LDR R3,=PUNTO
    LDRB R3,[R3]

    CMP R3,R1
    ITTT EQ
    LDREQ R2,=GPIO_SET5
    MOVEQ R1,(1 << DP_BIT)
    STREQ R1,[R2]

    BX   LR                 // Retorna al programa principal
    .pool                   // Almacena las constantes de código
    .endfunc

/****************************************************************************/
/* Rutina de servicio generica para excepciones                             */
/* Esta rutina atiende todas las excepciones no utilizadas en el programa.  */
/* Se declara como una medida de seguridad para evitar que el procesador    */
/* se pierda cuando hay una excepcion no prevista por el programador        */
/****************************************************************************/
    .func handler
handler:
    LDR R0,=set_led_1       // Apuntar al incio de una subrutina lejana
    BLX R0                  // Llamar a la rutina para encender el led rojo
    B handler               // Lazo infinito para detener la ejecucion
    .pool                   // Almacenar las constantes de codigo
    .endfunc
