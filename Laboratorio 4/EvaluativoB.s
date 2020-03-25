.cpu cortex-m4 // Indica el procesador de destino
.syntax unified // Habilita las instrucciones Thumb-2
.thumb // Usar instrucciones Thumb y no ARM

.include "configuraciones/lpc4337.s"
.include "configuraciones/rutinas.s"


/****************************************************************************/
/* Definiciones de macros */
/****************************************************************************/

// Recursos utilizados por el habilitador dig3
    .equ LED4_PORT, 1
    .equ LED4_PIN, 15
    .equ LED4_MAT, 1
    .equ LED4_TMR, 0

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

// Recursos utilizados por el teclado
    .equ TEC_GPIO,      5
    .equ TEC_MASK,      (TEC_1_MASK | TEC_2_MASK)

/****************************************************************************/

// Recursos utilizados por el Segmento A del display
    .equ SEG_A_PORT,    4
    .equ SEG_A_PIN,     0
    .equ SEG_A_BIT,     0
    .equ SEG_A_MASK,    (1 << SEG_A_BIT)

// Recursos utilizados por el Segmento B del display
    .equ SEG_B_PORT,    4
    .equ SEG_B_PIN,     1
    .equ SEG_B_BIT,     1
    .equ SEG_B_MASK,    (1 << SEG_B_BIT)

// Recursos utilizados por el Segmento C del display
    .equ SEG_C_PORT,    4
    .equ SEG_C_PIN,     2
    .equ SEG_C_BIT,     2
    .equ SEG_C_MASK,    (1 << SEG_C_BIT)

// Recursos utilizados por el Segmento D del display
    .equ SEG_D_PORT,    4
    .equ SEG_D_PIN,     3
    .equ SEG_D_BIT,     3
    .equ SEG_D_MASK,    (1 << SEG_D_BIT)

// Recursos utilizados por el Segmento E del display
    .equ SEG_E_PORT,    4
    .equ SEG_E_PIN,     4
    .equ SEG_E_BIT,     4
    .equ SEG_E_MASK,    (1 << SEG_E_BIT)

// Recursos utilizados por el Segmento F del display
    .equ SEG_F_PORT,    4
    .equ SEG_F_PIN,     5
    .equ SEG_F_BIT,     5
    .equ SEG_F_MASK,    (1 << SEG_F_BIT)

// Recursos utilizados por el Segmento G del display
    .equ SEG_G_PORT,    4
    .equ SEG_G_PIN,     6
    .equ SEG_G_BIT,     6
    .equ SEG_G_MASK,    (1 << SEG_G_BIT)

// Recursos utilizados por los 7 segmentos del display
    .equ SEG_GPIO,      2
    .equ SEG_MASK,      ( SEG_A_MASK | SEG_B_MASK | SEG_C_MASK | SEG_D_MASK | SEG_E_MASK | SEG_F_MASK | SEG_G_MASK )

/****************************************************************************/
// Recursos utilizados por el digito 1
    .equ DIG_1_PORT,    0
    .equ DIG_1_PIN,     0
    .equ DIG_1_BIT,     0
    .equ DIG_1_MASK,    (1 << DIG_1_BIT)

// Recursos utilizados por el digito 2
    .equ DIG_2_PORT,    0
    .equ DIG_2_PIN,     1
    .equ DIG_2_BIT,     1
    .equ DIG_2_MASK,    (1 << DIG_2_BIT)


// Recursos utilizados por el digito 4
    .equ DIG_4_PORT,    1
    .equ DIG_4_PIN,     17
    .equ DIG_4_BIT,     3
    .equ DIG_4_MASK,    (1 << DIG_4_BIT)


// Recursos utilizados por los digitos
    .equ DIG_GPIO,      0
    .equ DIG_MASK,      ( DIG_1_MASK | DIG_2_MASK | DIG_4_MASK )
/****************************************************************************/
/* Vector de interrupciones */
/****************************************************************************/


.section .isr // Define una seccion especial para el vector
    .word stack // 0: Initial stack pointer value
    .word reset+1 // 1: Initial program counter value
    .word handler+1 // 2: Non mascarable interrupt service routine
    .word handler+1 // 3: Hard fault system trap service routine
    .word handler+1 // 4: Memory manager system trap service routine
    .word handler+1 // 5: Bus fault system trap service routine
    .word handler+1 // 6: Usage fault system tram service routine
    .word 0 // 7: Reserved entry
    .word 0 // 8: Reserved entry
    .word 0 // 9: Reserved entry
    .word 0 // 10: Reserved entry
    .word handler+1 // 11: System service call trap service routine
    .word 0 // 12: Reserved entry
    .word 0 // 13: Reserved entry
    .word handler+1 // 14: Pending service system trap service routine
    .word handler+1 // 15: System tick service routine
    .word handler+1 // 16: IRQ 0: DAC service routine
    .word handler+1 // 17: IRQ 1: M0APP service routine
    .word handler+1 // 18: IRQ 2: DMA service routine
    .word 0 // 19: Reserved entry
    .word handler+1 // 20: IRQ 4: FLASHEEPROM service routine
    .word handler+1 // 21: IRQ 5: ETHERNET service routine
    .word handler+1 // 22: IRQ 6: SDIO service routine
    .word handler+1 // 23: IRQ 7: LCD service routine
    .word handler+1 // 24: IRQ 8: USB0 service routine
    .word handler+1 // 25: IRQ 9: USB1 service routine
    .word handler+1 // 26: IRQ 10: SCT service routine
    .word handler+1 // 27: IRQ 11: RTIMER service routine
    .word timer_isr+1 // 28: IRQ 12: TIMER0 service routine
    .word handler+1 // 29: IRQ 13: TIMER1 service routine
    .word handler+1 // 30: IRQ 14: TIMER2 service routine
    .word handler+1 // 31: IRQ 15: TIMER3 service routine
    .word handler+1 // 32: IRQ 16: MCPWM service routine
    .word handler+1 // 33: IRQ 17: ADC0 service routine
    .word handler+1 // 34: IRQ 18: I2C0 service routine
    .word handler+1 // 35: IRQ 19: I2C1 service routine
    .word handler+1 // 36: IRQ 20: SPI service routine
    .word handler+1 // 37: IRQ 21: ADC1 service routine
    .word handler+1 // 38: IRQ 22: SSP0 service routine
    .word handler+1 // 39: IRQ 23: SSP1 service routine
    .word handler+1 // 40: IRQ 24: USART0 service routine
    .word handler+1 // 41: IRQ 25: UART1 service routine
    .word handler+1 // 42: IRQ 26: USART2 service routine
    .word handler+1 // 43: IRQ 27: USART3 service routine
    .word handler+1 // 44: IRQ 28: I2S0 service routine
    .word handler+1 // 45: IRQ 29: I2S1 service routine
    .word handler+1 // 46: IRQ 30: SPIFI service routine
    .word handler+1 // 47: IRQ 31: SGPIO service routine
    .word handler+1 // 48: IRQ 32: PIN_INT0 service routine
    .word handler+1 // 49: IRQ 33: PIN_INT1 service routine
    .word handler+1 // 50: IRQ 34: PIN_INT2 service routine
    .word handler+1 // 51: IRQ 35: PIN_INT3 service routine
    .word handler+1 // 52: IRQ 36: PIN_INT4 service routine
    .word handler+1 // 53: IRQ 37: PIN_INT5 service routine
    .word handler+1 // 54: IRQ 38: PIN_INT6 service routine
    .word handler+1 // 55: IRQ 39: PIN_INT7 service routine
    .word handler+1 // 56: IRQ 40: GINT0 service routine
    .word handler+1 // 56: IRQ 40: GINT1 service routine

/****************************************************************************/
/* Definicion de variables globales                                         */
/****************************************************************************/

    .section .data          // Define la sección de variables (RAM)

factor:                     //guarda factor de trabajo
    .byte 50
    
estado:
    .byte 0                 //empieza prendido el led cuando entra a la primera int

contador:                     //Valor del numero a mostrar
    .byte 5

/****************************************************************************/
/* Programa principal */
/****************************************************************************/

    .global reset // Define el punto de entrada del código
    .section .text // Define la sección de código (FLASH)

.func main // Inidica al depurador el inicio de una funcion

reset:

    // Mueve el vector de interrupciones al principio de la segunda RAM
    LDR R1,=VTOR
    LDR R0,=#0x10080000
    STR R0,[R1]

    // Configura el pin del habilitador del dig3 como salida TMAT
    LDR R1,=SCU_BASE
    MOV R0,#(SCU_MODE_INACT | SCU_MODE_INBUFF_EN | SCU_MODE_ZIF_DIS | SCU_MODE_FUNC4)
    STR R0,[R1,#(LED4_PORT << 7 | LED4_PIN << 2)]

    // Configura los pines de las teclas como gpio con pull-up
    MOV R0,#(SCU_MODE_PULLUP | SCU_MODE_INBUFF_EN | SCU_MODE_ZIF_DIS | SCU_MODE_FUNC0)
    STR R0,[R1,#(TEC_1_PORT << 7 | TEC_1_PIN << 2)]
    STR R0,[R1,#(TEC_2_PORT << 7 | TEC_2_PIN << 2)]

    // Configura los pines de los segmentos del display
    //de los digitoscomo gpio sin pull-up
    MOV R0,#(SCU_MODE_INACT | SCU_MODE_INBUFF_EN | SCU_MODE_ZIF_DIS | SCU_MODE_FUNC0)
    STR R0,[R1,#(SEG_A_PORT << 7 | SEG_A_PIN << 2)]
    STR R0,[R1,#(SEG_B_PORT << 7 | SEG_B_PIN << 2)]
    STR R0,[R1,#(SEG_C_PORT << 7 | SEG_C_PIN << 2)]
    STR R0,[R1,#(SEG_D_PORT << 7 | SEG_D_PIN << 2)]
    STR R0,[R1,#(SEG_E_PORT << 7 | SEG_E_PIN << 2)]
    STR R0,[R1,#(SEG_F_PORT << 7 | SEG_F_PIN << 2)]
    STR R0,[R1,#(SEG_G_PORT << 7 | SEG_G_PIN << 2)]
    STR R0,[R1,#(DIG_1_PORT << 7 | DIG_1_PIN << 2)]
    STR R0,[R1,#(DIG_2_PORT << 7 | DIG_2_PIN << 2)]
    STR R0,[R1,#(DIG_4_PORT << 7 | DIG_4_PIN << 2)]

    // Apaga todos los bits gpio de los segmentos y apago habilitadores de digitos
    LDR R1,=GPIO_CLR0
    LDR R0,=SEG_MASK
    STR R0,[R1,#(SEG_GPIO << 2)]
    LDR R0,=DIG_MASK
    STR R0,[R1,#(DIG_GPIO << 2)]

    // Configura los bits gpio de los segmentos como salidas
    LDR R1,=GPIO_DIR0
    LDR R0,[R1,#(SEG_GPIO << 2)]
    ORR R0,#SEG_MASK
    STR R0,[R1,#(SEG_GPIO << 2)]
    LDR R0,[R1,#(DIG_GPIO << 2)]
    ORR R0,#DIG_MASK
    STR R0,[R1,#(DIG_GPIO << 2)]


    // Configura los bits gpio de los botones como entradas
    LDR R1,=GPIO_DIR0
    LDR R0,[R1,#(TEC_GPIO << 2)]
    AND R0,#~TEC_MASK
    STR R0,[R1,#(TEC_GPIO << 2)]

    // Cuenta con clock interno
    LDR R1,=TIMER0_BASE
    MOV R0,#0x00
    STR R0,[R1,#CTCR]

    // Prescaler de 95 para una frecuencia de 1 MHz
    MOV R0,#95
    STR R0,[R1,#PR]

    // El valor inicial de la cuenta para que empiece a funcionar
    LDR R0,=100000
    STR R0,[R1,#MR1]

    // El registro de match 0 provoca reset del contador e interrupcion
    MOV R0,#(MR1R | MR1I)
    STR R0,[R1,#MCR]

    // Define el estado inicial y toggle on match del led
    MOV R0,#(3 << (4 + (2 * LED4_MAT)))
    STR R0,[R1,#EMR]

    // Limpieza del contador
    MOV R0,#CRST
    STR R0,[R1,#TCR]

    // Inicio del contador
    MOV R0,#CEN
    STR R0,[R1,#TCR]

    // Limpieza del pedido pendiente en el NVIC
    LDR R1,=NVIC_ICPR0
    MOV R0,(1 << 12)
    STR R0,[R1]

    // Habilitacion del pedido de interrupcion en el NVIC
    LDR R1,=NVIC_ISER0
    MOV R0,(1 << 12)
    STR R0,[R1]

    //Mando numero convertido al display
    LDR R7, =tabla
    LDR R8, =contador
    LDRB R1,[R8]
    LDR R2,[R7,R1]

    // Actualiza las salida de los segmentos
    LDR R6,=GPIO_PIN0
    STR R2,[R6,#(SEG_GPIO << 2)]

    MOV R3,#0           //guarda estado anterior tecla 1
    MOV R4,#0           //guarda estado anterior tecla 2

    CPSIE I // Rehabilita interrupciones
main:
    LDR R2,=factor
    LDRB R1,[R2]

    //leo estado actual teclas
    LDR R0,[R6,#(TEC_GPIO << 2)]

    //Hago un not bit a bit pq las teclas son con pull up
    //y paso por la mascara para filtrar teclas
    LDR R5,=TEC_MASK
    BIC R0,R5,R0

tecla1:
    ANDS  R5,R0,#(1 << TEC_1_BIT)
    ITT NE
    MOVNE R3,#0     //actualiza estado
    BNE tecla2      //si no esta apretada que salte
    CMP R3,#1
    BEQ tecla2      //si ya estaba apretada que salte
    MOV R3,#1
    //aumenta cuenta on
    CMP R1, #90
    BEQ tecla2
    ADD R1, #10      //aumenta duty cycle
    STRB R1, [R2]   //actualiza el valor en memoria de factor
    
    push {R1, R2, R6}
        LDR R7, =tabla
        LDR R1, =contador
        LDRB R2, [R1]
        ADD R2, #1
        STRB R2, [R1]
        LDR R2,[R7,R2]

        // Actualiza las salida de los segmentos
        LDR R6,=GPIO_PIN0
        STR R2,[R6,#(SEG_GPIO << 2)]
    POP {R1, R2, R6}

tecla2:
    ANDS  R5,R0,#(1 << TEC_2_BIT)
    ITT NE
    MOVNE R4,#0     //actualiza estado
    BNE main      //si no esta apretada que salte
    CMP R4,#1
    BEQ main      //si ya estaba apretada que salte
    MOV R4,#1
    CMP R1, #10
    BEQ main
    SUB R1, #10      //disminuye duty cycle
    STRB R1, [R2]   //actualiza el valor en memoria
    
    push {R1, R2, R6}
        LDR R7, =tabla
        LDR R1, =contador
        LDRB R2, [R1]
        SUB R2, #1
        STRB R2, [R1]
        LDR R2,[R7,R2]

        // Actualiza las salida de los segmentos
        LDR R6,=GPIO_PIN0
        STR R2,[R6,#(SEG_GPIO << 2)]

    pop {R1, R2, R6}

    B main

.pool // Almacenar las constantes de código
.endfunc

/****************************************************************************/
/* Rutina de servicio para la interrupcion del timer */
/****************************************************************************/

.func timer_isr

timer_isr:

    // Limpio el flag de interrupcion
    LDR R3,=TIMER0_BASE
    LDR R0,[R3,#IR]
    STR R0,[R3,#IR]

    LDR R0,=estado
    LDRB R1,[R0]
    CMP R1,#0
    BEQ apagado

encendido:
    MOV R1,#0
    STRB R1,[R0]
    LDR R0, =factor
    LDRB R0, [R0]
    //al factor lo multiplicaremos por 100 pues
    //el periodo que elegi es de 10000
    MOV R2,#100
    MUL R2, R2, R0
    LDR R1,=TIMER0_BASE

    STR R2,[R1,#MR1]

    // Limpieza del contador
    MOV R0,#CRST
    STR R0,[R1,#TCR]

    // Inicio del contador
    MOV R0,#CEN
    STR R0,[R1,#TCR]

    BX LR
apagado:
    MOV R1,#1
    STRB R1,[R0]
    LDR R0, =factor
    LDRB R0, [R0]
    //tiempo apagado = 10000 - 100*factor
    MOV R2,#100
    MUL R2, R2, R0
    LDR R0,=10000
    SUB R2,R0, R2
    LDR R1,=TIMER0_BASE

    STR R2,[R1,#MR1]

    // Limpieza del contador
    MOV R0,#CRST
    STR R0,[R1,#TCR]

    // Inicio del contador
    MOV R0,#CEN
    STR R0,[R1,#TCR]

    // Retorno
    BX LR

.pool // Almacenar las constantes de código
.endfunc


/****************************************************************************/
/* Rutina de servicio generica para excepciones */
/* Esta rutina atiende todas las excepciones no utilizadas en el programa. */
/* Se declara como una medida de seguridad para evitar que el procesador */
/* se pierda cuando hay una excepcion no prevista por el programador */
/****************************************************************************/
.func handler
handler:
LDR R0,=set_led_1 // Apuntar al incio de una subrutina lejana
BLX R0 // Llamar a la rutina para encender el led rojo
B handler // Lazo infinito para detener la ejecucion
.pool // Almacenar las constantes de codigo
.endfunc

//////////////////////////////////////////////////7
.pool
tabla:  .byte 0x3F,0x06,0x5B,0x4F,0x66
        .byte 0x6D,0x7D,0x07,0x7F,0x6F
