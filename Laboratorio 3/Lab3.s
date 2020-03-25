    .cpu cortex-m4          // Indica el procesador de destino
    .syntax unified         // Habilita las instrucciones Thumb-2
    .thumb                  // Usar instrucciones Thumb y no ARM

    .include "configuraciones/lpc4337.s" //da acceso a rutinas para prender y apagar los leds
    .include "configuraciones/rutinas.s"

/****************************************************************************/
/* Definiciones de macros                                                   */
/****************************************************************************/

// Recursos utilizados por el canal Rojo del led RGB
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

   // .equ ENABLE_D4_PORT,    1
   // .equ ENABLE_D4_PIN,     17
 //   .equ ENABLE_D4_BIT,     3
  //  .equ ENABLE_D4_MASK,    (1 << ENABLE_D4_BIT)

    .equ ENABLE_MASK,       (ENABLE_D1_MASK  | ENABLE_D2_MASK | ENABLE_D3_MASK)
    .equ ENABLE_GPIO,      0

// Recursos utilizados por el canal Rojo del led RGB
    .equ A_PORT,    4
    .equ A_PIN,     0
    .equ A_BIT,     0
    .equ A_MASK,    (1 << A_BIT)

// Recursos utilizados por el canal Rojo del led RGB
    .equ B_PORT,    4
    .equ B_PIN,     1
    .equ B_BIT,     1
    .equ B_MASK,    (1 << B_BIT)

// Recursos utilizados por el canal Rojo del led RGB
     .equ C_PORT,    4
     .equ C_PIN,     2
     .equ C_BIT,     2
     .equ C_MASK,    (1 << C_BIT)

// Recursos utilizados por el canal Rojo del led RGB
     .equ D_PORT,    4
     .equ D_PIN,     3
     .equ D_BIT,     3
     .equ D_MASK,    (1 << D_BIT)

// Recursos utilizados por el canal Rojo del led RGB
    .equ E_PORT,    4
    .equ E_PIN,     4
    .equ E_BIT,     4
    .equ E_MASK,    (1 << E_BIT)

// Recursos utilizados por el canal Rojo del led RGB
    .equ F_PORT,    4
    .equ F_PIN,     5
    .equ F_BIT,     5
    .equ F_MASK,    (1 << F_BIT)

// Recursos utilizados por el canal Rojo del led RGB
     .equ G_PORT,    4
     .equ G_PIN,     6
     .equ G_BIT,     6
     .equ G_MASK,    (1 << G_BIT)

// Recursos utilizados por el canal Rojo del led RGB
    // .equ DP_PORT,    6
    // .equ DP_PIN,     8
    // .equ DP_BIT,     16
    // .equ DP_MASK,    (1 << DP_BIT)
    // .equ DP_GPIO,      5

// Recursos utilizados por el led RGB
    .equ LED_GPIO,      2
    .equ LED_MASK,      (A_MASK |B_MASK |C_MASK |D_MASK |E_MASK |F_MASK |G_MASK)

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


// Recursos utilizados por el teclado
    .equ TEC_GPIO,      5
    .equ TEC_MASK,      ( TEC_1_MASK | TEC_2_MASK | TEC_3_MASK )

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

espera:
    .zero 1    //Variable compartida con el tiempo de espera
cuenta: .hword 0x00                 // Variable compartida con el tiempo de espera
tabla: .byte 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F
reiniciar : .byte 0x00
ANTERIOR: .byte 0x01
espera1 : .byte 0x01

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
    //STR R0,[R1,#(ENABLE_D4_PORT << 7 | ENABLE_D4_PIN << 2)]

//Configuro el DP aparte de los leds ya que su funcion es distinta
    //LDR R1,=SCU_BASE
    // 7MOV R0,#(SCU_MODE_INACT | SCU_MODE_INBUFF_EN | SCU_MODE_ZIF_DIS | SCU_MODE_FUNC4)//cargo la mascara
    //STR R0,[R1,#(DP_PORT << 7 | DP_PIN << 2)]

// Configura los pines de las teclas como gpio con pull-up
    MOV R0,#(SCU_MODE_PULLUP | SCU_MODE_INBUFF_EN | SCU_MODE_ZIF_DIS | SCU_MODE_FUNC4)
    STR R0,[R1,#(TEC_1_PORT << 7 | TEC_1_PIN << 2)]
    STR R0,[R1,#(TEC_2_PORT << 7 | TEC_2_PIN << 2)]
    STR R0,[R1,#(TEC_3_PORT << 7 | TEC_3_PIN << 2)]
//    STR R0,[R1,#(TEC_4_PORT << 7 | TEC_4_PIN << 2)]

// Apaga todos los display, led y dp
    LDR R1,=GPIO_CLR0
    LDR R0,=LED_MASK
    STR R0,[R1,#(LED_GPIO << 2)]
    LDR R0,=ENABLE_MASK
    STR R0,[R1,#(ENABLE_GPIO << 2)]
   // LDR R0,=DP_MASK
   // STR R0,[R1,#(DP_GPIO << 2)]

// Configura los bits gpio de los leds como salidas
    LDR R1,=GPIO_DIR0

    LDR R0,[R1,#(LED_GPIO << 2)]
    LDR R2,=LED_MASK
    ORR R0,R2
    STR R0,[R1,#(LED_GPIO << 2)]

    LDR R0,[R1,#(ENABLE_GPIO << 2)]
    LDR R2,=ENABLE_D1_MASK
    ORR R0,R2
    STR R0,[R1,#(ENABLE_GPIO << 2)]

   LDR R0,[R1,#(ENABLE_GPIO << 2)]
    ORR R0,#ENABLE_D2_MASK
    STR R0,[R1,#(ENABLE_GPIO << 2)]

    LDR R0,[R1,#(ENABLE_GPIO << 2)]
    ORR R0,#ENABLE_D3_MASK
    STR R0,[R1,#(ENABLE_GPIO << 2)]

   // LDR R0,[R1,#(ENABLE_GPIO << 2)]
   // ORR R0,#ENABLE_D4_MASK
   // STR R0,[R1,#(ENABLE_GPIO << 2)]

  //  LDR R0,[R1,#(DP_GPIO << 2)]
//    ORR R0,#DP_MASK
   // STR R0,[R1,#(DP_GPIO << 2)]

// Configura los bits gpio de los botones como entradas
    LDR R0,[R1,#(TEC_GPIO << 2)]
    AND R0,#~TEC_MASK
    STR R0,[R1,#(TEC_GPIO << 2)]

// Define los punteros para usar en el programa
    LDR R4,=GPIO_PIN0 // 5 tecla(bit 16 DP), 2 leds,0 enable

//Defino los registros para determinar si se apreto o no la tecla
    MOV R5,#0
    MOV R2,#0
    MOV R8,#0
    MOV R3, #0 // reiniciar

refrescar:
// Carga el estado arctual de las teclas
    LDR   R0,[R4,#(TEC_GPIO << 2)]

/*
// corre cronometro
    mvn r5,r5
    ands r5,r1
    it ne
    bl disminuyo
    mov r5,r1

// corre cronometro
    mvn r5,r5
    ands r5,r1
    it ne
    bl aumento
    mov r5,r1

// corre cronometro
    mvn r5,r5
    ands r5,r1
    it ne
    bl aumento
    mov r5,r1
*/

// Prende el canal verde si la tecla dos esta apretada

    AND  R1,R0,#(1 << TEC_2_BIT)
    MVN R2,R2
    ANDS R2,R1
    IT ne
    BLne detener
    MOV R2,R1


// Verifica SI ESTA APRETADO HAY UN 0
    AND  R1,R0,#(1 << TEC_3_BIT)

// Si la tecla derecha esta apretada
    mvn r3,r3
    ands r3,r1
    it ne
    blne volver

    mov r3,r1

// Repite el lazo de refresco indefinidamente
    B     refrescar

inicio:
// Verifica SI ESTA APRETADO HAY UN 0
    AND  R1,R0,#(1 << TEC_1_BIT)

 // Si la tecla esta apretada
    mvn r5,r5
    ands r5,r1
    it ne
    blne volver1
    mov r5,r1


stop:
    B stop

volver1: ldr r7,=reiniciar
ldr r8,[r7]
mov r9,#0x00
cmp r9,r8
it NE
movne r8,#0
str r8,[r7]
bx lr

/*volver: ldr r7,=CONTADOR
ldrh r8,[r7]
add r8,#1
MOV
cmp r8,r9
it eq
moveq r8,#000
strh r8,[r7]
bx lr
*/
volver : ldr r7,=cuenta
ldrh r8,[r7]
add r8,#1
ldr r9,=#0000
cmp r8,r9
it ne
movne r8,#0
strh r8,[r7]
bx lr
aumento: ldr r7,=cuenta
        ldrh r8,[r7]
        add r8,#1
        ldr r9,=#999
        cmp r8,r9
        it eq
        moveq r8,#0
        strh r8,[r7]

        bx lr

detener : ldr r7,=cuenta
        ldrh r8,[r7]
        sub r8,#1
        cmp r8,#-1
        it eq
        ldreq r8,=#999
        strh r8,[r7]
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
    MOV R0,#1
    STR R0,[R1]             // Quita ENABLE

    // Configurar el desborde para un periodo de 100 ms
    LDR R1,=SYST_RVR
    LDR R0,=#(480000 - 1)
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

    LDR  R0,=ANTERIOR        // Apunta R0 a espera
    LDRB R1,[R0]            // Carga el valor de espera
    CMP R1,#8               // Decrementa el valor de espera
    ITE EQ
    MOVEQ R1,#1
    LSLNE R1,#1
    STR R1,[R0]

    LDR R2,=GPIO_CLR0
    LDR R0,=LED_MASK
    STR R0,[R2,#(LED_GPIO << 2)]

    LDR R2,=GPIO_CLR0
    LDR R0,=ENABLE_MASK
    STR R0,[R2,#(ENABLE_GPIO << 2)]


    LDR R0,=cuenta
    LDRH R2,[R0]

    CMP R1,#1
    MOV R3,#10
    ITTT EQ
    UDIVEQ R0,R2,R3
    MULEQ R0,R3
    SUBEQ R2,R0

    PUSH {R4}
    CMP R1,#2
    MOV R3,#100
    MOV R4,#10
    ITTTT EQ
    UDIVEQ R0,R2,R3
    MULEQ R0,R3
    SUBEQ R2,R0
    UDIVEQ R2,R4

    CMP R1,#4
    MOV R3,#1000
    MOV R4,#100
    ITTTT EQ
    UDIVEQ R0,R2,R3
    MULEQ R0,R3
    SUBEQ R2,R0
    UDIVEQ R2,R4

    POP {R4}
    CMP R1,#8
    LDR R3,=#999
    IT EQ
    UDIVEQ R2,R2,R3


    LDR R0,=GPIO_SET0
    STR R1,[R0]

    LDR R0,=GPIO_SET2
    ldr r1,=tabla
    LDR R2,[R1,R2]
    STR R2,[R0]

    LDR  R0,=espera     // Apunta R0 a espera
    LDRB R1,[R0]            // Carga el valor de espera
    SUBS R1,#1              // Decrementa el valor de espera
    BHI  systick_exit       // Espera > 0, No pasaron 10 vece
    PUSH {R0,LR}            // Conserva los registros que uso
    LDR  R0,=toggle_led_3
    cmp R1,#0
    IT EQ
    BLEQ aumento
    //BLX  R0                 // Llama a la subrutina para destellar led
    POP  {R0,LR}            // Recupera los registros conservados
    MOV  R1,400             // Vuelvo a carga espera con 10 iterciones
systick_exit:
    STRB R1,[R0]            // Actualiza la variable esper



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











