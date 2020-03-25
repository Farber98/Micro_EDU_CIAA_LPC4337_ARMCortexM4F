.cpu cortex-m4 // Indica el procesador de destino
.syntax unified // Habilita las instrucciones Thumb-2
.thumb // Usar instrucciones Thumb y no ARM
.include "configuraciones/lpc4337.s"

.include "configuraciones/rutinas.s"
/****************************************************************************/
/* Definiciones de macros */
/****************************************************************************/
// Recursos utilizados por el canal Rojo del led RGB
.equ LED_R_PORT, 2
.equ LED_R_PIN, 0
.equ LED_R_BIT, 0
.equ LED_R_MASK, (1 << LED_R_BIT)
// Recursos utilizados por el canal Verde del led RGB
.equ LED_G_PORT, 2
.equ LED_G_PIN, 1
.equ LED_G_BIT, 1
.equ LED_G_MASK, (1 << LED_G_BIT)
// Recursos utilizados por el canal Azul del led RGB
.equ LED_B_PORT, 2
.equ LED_B_PIN, 2
.equ LED_B_BIT, 2
.equ LED_B_MASK, (1 << LED_B_BIT)
// Recursos utilizados por el led RGB
.equ LED_GPIO, 5
.equ LED_MASK, ( LED_R_MASK | LED_G_MASK | LED_B_MASK )
// Recursos utilizados por la primera tecla
.equ TEC_1_PORT, 3
.equ TEC_1_PIN, 1
.equ TEC_1_BIT, 8
.equ TEC_1_MASK, (1 << TEC_1_BIT)
// Recursos utilizados por la segunda tecla
.equ TEC_2_PORT, 3
.equ TEC_2_PIN, 2
.equ TEC_2_BIT, 9
.equ TEC_2_MASK, (1 << TEC_2_BIT)
// Recursos utilizados por la tercera tecla
.equ TEC_3_PORT, 1
.equ TEC_3_PIN, 2
.equ TEC_3_BIT, 9
.equ TEC_3_MASK, (1 << TEC_3_BIT)
// Recursos utilizados por el teclado
.equ TEC_GPIO, 5
.equ TEC_MASK, ( TEC_1_MASK | TEC_2_MASK)
/****************************************************************************/
/* Vector de interrupciones */
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
    .word   systick_isr+1       // 15: System tick service routine
    .word   handler+1       // 16: IRQ 0: DAC service routine
    .word   handler+1       // 17: IRQ 1: M0APP service routine
    .word   handler+1       // 18: IRQ 2: DMA service routine
    .word   0               // 19: Reserved entry
    .word   handler+1       // 20: IRQ 4: FLASHEEPROM service routine
    .word   handler+1       // 21: IRQ 5: ETHERNET service routine
    .word   handler+1       // 22: IRQ 6: SDIO service routine
    .word   handler+1       // 23: IRQ 7: LCD service routine
    .word   handler+1       // 24: IRQ 8: USB0 service routine
    .word   handler+1       // 25: IRQ 9: USB1 service routine
    .word   handler+1       // 26: IRQ 10: SCT service routine
    .word   handler+1       // 27: IRQ 11: RTIMER service routine
    .word   timer_isr+1     // 28: IRQ 12: TIMER0 service routine
    .word   handler+1       // 29: IRQ 13: TIMER1 service routine
    .word   handler+1       // 30: IRQ 14: TIMER2 service routine
    .word   handler+1       // 31: IRQ 15: TIMER3 service routine
    .word   handler+1       // 32: IRQ 16: MCPWM service routine
    .word   handler+1       // 33: IRQ 17: ADC0 service routine
    .word   handler+1       // 34: IRQ 18: I2C0 service routine
    .word   handler+1       // 35: IRQ 19: I2C1 service routine
    .word   handler+1       // 36: IRQ 20: SPI service routine
    .word   handler+1       // 37: IRQ 21: ADC1 service routine
    .word   handler+1       // 38: IRQ 22: SSP0 service routine
    .word   handler+1       // 39: IRQ 23: SSP1 service routine
    .word   handler+1       // 40: IRQ 24: USART0 service routine
    .word   handler+1       // 41: IRQ 25: UART1 service routine
    .word   handler+1       // 42: IRQ 26: USART2 service routine
    .word   handler+1       // 43: IRQ 27: USART3 service routine
    .word   handler+1       // 44: IRQ 28: I2S0 service routine
    .word   handler+1       // 45: IRQ 29: I2S1 service routine
    .word   handler+1       // 46: IRQ 30: SPIFI service routine
    .word   handler+1       // 47: IRQ 31: SGPIO service routine
    .word   handler+1       // 48: IRQ 32: PIN_INT0 service routine
    .word   handler+1       // 49: IRQ 33: PIN_INT1 service routine
    .word   handler+1       // 50: IRQ 34: PIN_INT2 service routine
    .word   handler+1       // 51: IRQ 35: PIN_INT3 service routine
    .word   handler+1       // 52: IRQ 36: PIN_INT4 service routine
    .word   handler+1       // 53: IRQ 37: PIN_INT5 service routine
    .word   handler+1       // 54: IRQ 38: PIN_INT6 service routine
    .word   handler+1       // 55: IRQ 39: PIN_INT7 service routine
    .word   handler+1       // 56: IRQ 40: GINT0 service routine
    .word   handler+1       // 56: IRQ 40: GINT1 service routine

/****************************************************************************/
/* Definicion de variables globales */
/****************************************************************************/
.section .data // Define la sección de variables (RAM)
tabla: .byte 0xBF,0x06,0x5B,0x4F,0x66
       .byte 0x6D,0xFD,0x07,0xFF,0xEF

Digitos: .byte 0x05,0x05,0x04,0x05
espera: .byte 0xF0 // Variable compartida con el tiempo de espera
refresco: .byte 0x01
parado: .byte 0x00
antesP: .byte 0x00
antesR: .byte 0x00
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

// Llama a una subrutina para configurar el systick
BL systick_init
BL configurar

LDR R1,=SCU_BASE
// Configura los pines de las teclas como gpio con pull-up
MOV R0,#(SCU_MODE_PULLDOWN | SCU_MODE_INBUFF_EN | SCU_MODE_ZIF_DIS | SCU_MODE_FUNC4)
STR R0,[R1,#(TEC_1_PORT << 7 | TEC_1_PIN << 2)]
STR R0,[R1,#(TEC_2_PORT << 7 | TEC_2_PIN << 2)]
// Configura los bits gpio de los botones como entradas
LDR R0,[R1,#(TEC_GPIO << 2)]
AND R0,#~TEC_MASK
STR R0,[R1,#(TEC_GPIO << 2)]
// Cuenta con clock interno
    LDR R1,=TIMER0_BASE
    MOV R0,#0x00
    STR R0,[R1,#CTCR]

    // Prescaler de 9.500.000 para una frecuencia de 10 Hz
    LDR R0,=9500000
    STR R0,[R1,#PR]

    // El valor del semperiodo para 1 Hz
    LDR R0,=10
    STR R0,[R1,#MR3]

    // El registro de match 3 provoca reset del contador
    MOV R0,#(MR3R | MR3I)
    STR R0,[R1,#MCR]

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
        CPSIE I     // Rehabilita interrupciones

// Define los punteros para usar en el programa
LDR R4,=GPIO_PIN0
LDR R6,=antesP
LDR R8,=antesR


stop:
B stop

    .align
.pool // Almacenar las constantes de código

.endfunc
/****************************************************************************/
/* Rutina de inicialización del SysTick */
/****************************************************************************/
.func systick_init
systick_init:
CPSID I // Deshabilita interrupciones
// Configurar prioridad de la interrupcion
LDR R1,=SHPR3 // Apunta al registro de prioridades
LDR R0,[R1] // Carga las prioridades actuales
MOV R2,#2 // Fija la prioridad en 2
BFI R0,R2,#29,#3 // Inserta el valor en el campo
STR R0,[R1] // Actualiza las prioridades
// Habilitar el SysTick con el reloj del nucleo
LDR R1,=SYST_CSR
MOV R0,#0x00
STR R0,[R1] // Quita ENABLE
// Configurar el desborde para un periodo de 100 ms
LDR R1,=SYST_RVR
LDR R0,=#(400000 - 1)
STR R0,[R1] // Especifica valor RELOAD
// Inicializar el valor actual del contador
// Escribir cualquier valor limpia el contador
LDR R1,=SYST_CVR
MOV R0,#0
STR R0,[R1] // Limpia COUNTER y flag COUNT
// Habilita el SysTick con el reloj del nucleo
LDR R1,=SYST_CSR
MOV R0,#0x07
STR R0,[R1] // Fija ENABLE, TICKINT y CLOCK_SRC
BX LR // Retorna al programa principal
.align
.pool // Almacena las constantes de código
.endfunc
    /****************************************************************************/
    /* Rutina de servicio para la interrupcion del timer                        */
    /****************************************************************************/
    .func timer_isr
    timer_isr:
    // Limpio el flag de interrupcion
    LDR R3,=TIMER0_BASE
    LDR R0,[R3,#IR]
    STR R0,[R3,#IR]

    // Cambio el estado del pin GPIO del led
    LDR R0,=parado
    LDRB R0,[R0]
    CMP R0,#1
    BEQ cambio_exit
    LDR R1,=Digitos
    PUSH {LR}
    BL Cambio // Llama a la subrutina para cambiar los segundos
    POP {LR}
    LDR R1,=Digitos
    ADD R1,#2
    CMP R0,#1
    PUSH {LR}
    IT EQ
    BLEQ Cambio
    POP {LR}
    cambio_exit:
    BX LR // Retorna al programa principal
    Cambio:
        MOV R0,#0
        LDRB R2,[R1,#1]
        LDRB R3,[R1]
        ADD R3,#1
        CMP R3,#10
        ITTE EQ
        STRBEQ R0,[R1]
        ADDEQ R2,#1
        STRBNE R3,[R1]
        CMP R2,#6
        ITTE EQ
        STRBEQ R0,[R1,#1]
        MOVEQ R0,#1
        STRBNE R2,[R1,#1]
        BX LR
.endfunc
/****************************************************************************/
/* Rutina de servicio para la interrupcion del SysTick */
/****************************************************************************/
.func systick_isr
systick_isr:
LDR R0,=refresco
LDRB R1,[R0]
ADD R1,#1
CMP R1,#5
IT EQ
MOVEQ R1,#1
STRB R1,[R0]

PUSH {R1}
SUB R1,#1
LDR R3,=Digitos
LDRB R0,[R3,R1]
PUSH {LR}
BL Conversion
POP {LR}
LDR R3,=GPIO_PIN2
STR R0,[R3]
POP {R1}

CMP R1,#4
IT EQ
MOVEQ R1,#8

CMP R1,#3
IT EQ
MOVEQ R1,#4

LDR R3,=GPIO_PIN0
STR R1,[R3]


Conversion:
    LDR R2,=tabla
    ADD R1,R2,R0
    LDRB R0,[R1]
    BX LR
    .align
.pool // Almacena las constantes de código
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
.align
.pool // Almacenar las constantes de codigo
.endfunc


 .include "ejemplos/digitos.s"