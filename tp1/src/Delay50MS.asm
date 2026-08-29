cont1 EQU 0x20
cont2 EQU 0x21

PROCESSOR 16F887
#include <xc.inc>

    BANKSEL ANSEL
    CLRF    ANSEL           ; Pone en 0 ANSEL (PORTA y PORTE a modo digital)
    CLRF    ANSELH          ; Pone en 0 ANSELH (PORTB a modo digital)

    BANKSEL TRISD
    CLRF    TRISD           ; TRISD = 0x00 -> Los 8 pines de PORTD como SALIDAS (LEDs)
    BSF     TRISB, 0        ; TRISB, bit 0 = 1 -> Pin RB0 como ENTRADA (Pulsador)
    
    ;BANKSEL OPTION_REG
    ;BCF     OPTION_REG, NOT_RBPU ; Habilita el módulo general de Pull-Ups en PORTB
    ;BANKSEL WPUB
    ;BSF     WPUB, WPUB0     ; Activa la resistencia Pull-Up interna en RB0

    
    BANKSEL PORTD
    CLRF    PORTD           ; Apaga todos los LEDs al energizar el circuito

PSECT resetVec, class=CODE, delta=2
ORG 0x00
    GOTO MAIN

PSECT code, class=CODE, delta=2

MAIN:

    CALL DELAY50MS

AQUI:
    GOTO AQUI


DELAY50MS:

    MOVLW 0x63       ; cont1 = 99
    MOVWF cont1

INICIO:

    MOVLW 0xA7       ; cont2 = 167
    MOVWF cont2

LOOP:

    DECFSZ cont2,F
    GOTO LOOP

    DECFSZ cont1,F
    GOTO INICIO

    RETURN


