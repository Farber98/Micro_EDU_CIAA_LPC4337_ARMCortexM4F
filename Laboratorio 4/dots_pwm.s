.cpu cortex-m4 // Indica el procesador de destino
.syntax unified // Habilita las instrucciones Thumb-2
.thumb // Usar instrucciones Thumb y no ARM

.include "configuraciones/lpc4337.s"
.include "configuraciones/rutinas.s"


/****************************************************************************/
/* Definiciones de macros */
/****************************************************************************/

// Recursos utilizados por el punto del display
    .equ LED_PORT, 6
    .equ LED_PIN, 8
    .equ LED_MAT, 1
    .equ LED_TMR, 2


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
    .equ TEC_MASK,      (TEC_3_MASK | TEC_4_MASK)


/****************************************************************************/
/* Programa principal */
/****************************************************************************/

.global reset // Define el punto de entrada del código
.section .text // Define la sección de código (FLASH)
.func main // Inidica al depurador el inicio de una funcion

reset:
    // Configura el pin del punto como salida TMAT
    LDR R1,=SCU_BASE
    MOV R0,#(SCU_MODE_INACT | SCU_MODE_INBUFF_EN | SCU_MODE_ZIF_DIS | SCU_MODE_FUNC5)
    STR R0,[R1,#(LED_PORT << 7 | LED_PIN << 2)]

    // Configura los pines de las teclas como gpio con pull-up
    MOV R0,#(SCU_MODE_PULLUP | SCU_MODE_INBUFF_EN | SCU_MODE_ZIF_DIS | SCU_MODE_FUNC4)
    STR R0,[R1,#(TEC_3_PORT << 7 | TEC_3_PIN << 2)]
    STR R0,[R1,#(TEC_4_PORT << 7 | TEC_4_PIN << 2)]

    // Configura los bits gpio de los botones como entradas
    LDR R1,=GPIO_DIR0
    LDR R0,[R1,#(TEC_GPIO << 2)]
    AND R0,#~TEC_MASK
    STR R0,[R1,#(TEC_GPIO << 2)]

    // Cuenta con clock interno
    LDR R1,=TIMER2_BASE
    MOV R0,#0x00
    STR R0,[R1,#CTCR]

    // Prescaler de 95 para una frecuencia de 1 MHz
    MOV R0,#95
    STR R0,[R1,#PR]

    // El valor del periodo para 20 Hz, para que titile a 10Hz
    LDR R0,=50000
    STR R0,[R1,#MR1]

    // El registro de match provoca reset del contador
    MOV R0,#(MR0R << (3 * LED_MAT))
    STR R0,[R1,#MCR]

    // Define el estado inicial y toggle on match del led
    MOV R0,#(3 << (4 + (2 * LED_MAT)))
    STR R0,[R1,#EMR]

    // Limpieza del contador
    MOV R0,#CRST
    STR R0,[R1,#TCR]

    // Inicio del contador
    MOV R0,#CEN
    STR R0,[R1,#TCR]


    LDR R1,=TIMER2_BASE
    MOV R2,#20
    LDR R6,=GPIO_PIN0
    MOV R3,#0           //guarda estado anterior tecla 3
    MOV R4,#0           //guarda estado anterior tecla 4


main:
    LDR R0,[R6,#(TEC_GPIO << 2)]

    //Hago un not bit a bit pq las teclas son con pull up
    //y paso por la mascara para filtrar teclas
    LDR R5,=TEC_MASK
    BIC R0,R5,R0

    // Prende el segmento abajo izquierda si la tecla tres esta apretada
    ANDS  R5,R0,#(1 << TEC_3_BIT)
    ITT NE
    MOVNE R3,#0     //actualiza estado
    BNE tecla4      //si no esta apretada que salte
    CMP R3,#1
    BEQ tecla4      //si ya estaba apretada que salte
    MOV R3,#1
    //aca lo que hace
    CMP R2, #40
    BEQ tecla4

    ADD R2, #4
    LDR R7,=1000000
    UDIV R7,R7,R2
    STR R7,[R1,#MR1]

    // Limpieza del contador
    MOV R7,#CRST
    STR R7,[R1,#TCR]

    // Inicio del contador
    MOV R7,#CEN
    STR R7,[R1,#TCR]

tecla4:
    // Prende el segmento arriba izquierda si la tecla tres esta apretada
    ANDS  R5,R0,#(1 << TEC_4_BIT)
    ITT NE
    MOVNE R4,#0     //actualiza estado
    BNE main      //si no esta apretada que salte
    CMP R4,#1
    BEQ main      //si ya estaba apretada que salte
    MOV R4,#1
    //aca lo que hace
    CMP R2, #4
    BEQ main

    SUB R2, #4
    LDR R7,=1000000
    UDIV R7,R7,R2
    STR R7,[R1,#MR1]

    // Limpieza del contador
    MOV R7,#CRST
    STR R7,[R1,#TCR]

    // Inicio del contador
    MOV R7,#CEN
    STR R7,[R1,#TCR]

    B main

.pool // Almacenar las constantes de código
.endfunc