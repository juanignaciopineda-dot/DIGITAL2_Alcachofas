; PIC16F887 Configuration Bit Settings
#include "p16f887.inc"

; CONFIG1
; __config 0x20D9
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_ON & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
 DIS_U EQU 0x30
 DIS_D EQU 0x31
 DIS_C EQU 0x32
 DIS_M EQU 0x33
 LED_IND EQU 0x34
 EDIT_U EQU 0x35
 EDIT_D EQU 0x36
 EDIT_C EQU 0x37
 EDIT_M EQU 0x38
 EDIT_IND EQU 0x39
 FILA EQU 0x40
 COLUMNA EQU 0x41
 TECLA EQU 0x42
 CONTROL EQU 0x43 ;Almnacenamos bits de control (banderas y estados) bit 0 = estado, 0 = confirmado, 1 = editando
 PULSO	EQU 1	;el bit 1 es la bandera con la que se accede a atender pulso
 TECLA_ASIGNADA EQU 2 ;el bit 2 es la bandera con la que se accede a EJECUTAR
 REPOSO EQU 0x00    ;REPOSO es el estado del teclado cuando no se mapea, tiene todas las filas en alto
 DELAY EQU 0x44 ;registro para contar el delay antirebote
 
 ORG 0x00
    GOTO INIT

 ORG 0x04
    GOTO ISR
    
 ORG 0x05
INIT:
    BANKSEL ANSEL
    CLRF    ANSEL           ; Pone en 0 ANSEL (PORTA y PORTE a modo digital)
    CLRF    ANSELH          ; Pone en 0 ANSELH (PORTB a modo digital)
    BANKSEL TRISA
    CLRF    TRISA   ;En el puerto A están las salidas para el teclado
    BANKSEL TRISB
    MOVLW   0xFF
    MOVWF   TRISB   ;En el puerto B están las entradas para el teclado
    BANKSEL TRISC
    CLRF    TRISC
    BANKSEL TRISD
    CLRF    TRISD
    
    ;Pull ups internas
    BCF	    OPTION_REG,7 ;Habilito las pull-up del puerto B
    MOVLW   0xF0
    MOVWF   WPUB    ;Habilito solo las que usamos (RB0 tiene externa)
    
    BANKSEL INTCON
    BCF	    INTCON,GIE       ; Deshabilito globalmente las interrupciones
    BCF	    INTCON,T0IF      ; Borro bandera de TMR0
    BCF	    INTCON,INTF      ; Borro bandera externa

    BSF	    INTCON,T0IE      ; Habilito interrupción TMR0
    BSF	    INTCON,INTE      ; Habilito interrupción RB0/INT

    BSF	    INTCON,GIE       ; Habilito globalmente las interrupción
    
    ;Inicialización de variables
    CLRF    DIS_U
    CLRF    DIS_D
    CLRF    DIS_C
    CLRF    DIS_M
    CLRF    EDIT_U
    CLRF    EDIT_D
    CLRF    EDIT_C
    CLRF    EDIT_M
    CLRF    LED_IND	;A CHEQUEAR CON NAHUEL
    CLRF    EDIT_IND	;A CHEQUEAR CON NAHUEL
    CLRF    CONTROL	;Inicia en estado 0 con las banderas abajo
    CLRF    TECLA
    CLRF    COLUMNA
    MOVLW   0x01
    MOVWF   FILA
    MOVLW   0x14
    MOVWF   DELAY
    
    GOTO    MAIN
    
ISR:
    BTFSC   INTCON,T0IF
    CALL    ATENDER_TIMER0
    BTFSC   INTCON,INTF
    CALL    ATENDER_RBI
    RETFIE
    
MAIN:
    GOTO    MAIN
    
ATENDER_TIMER0:
    
  
ATENDER_RBI:
    
    
LOOP_DISPLAY:

    
REARMAR:
    BCF	    INTCON,RBIE	;deshabilita las interrupciones del puerto B	
    BCF	    CONTROL,PULSO   ;baja la bandera de pulso
    MOVF    REPOSO,W
    MOVWF   PORTA   ;resstablece el peurto A
    MOVF    PORTB,W ;actualiza los latch del puerto B
    BCF	    INTCON,RBIF	    ;Baja la bandera de interrupcion del puerto B
    BSF	    INTCON,RBIE	    ;habilita las interrupciones del puerto B
    RETURN
    
VALIDAR_PULSO:
    MOVF    DELAY,F
    BTFSS   STATUS,Z	;verifico que el tiempo de antirebote haya terminado
    GOTO    DECREMENTAR
    MOVF    PORTB,W
    BTFSC   STATUS,Z	;si z = 1 no hay pulsación
    CALL    REARMAR	;se reestablece el teclado
    BTFSS   STATUS,Z	;si z = 0 hay una tecla pulsada
    CALL    PROCE_TECLA	;se busca la tecla
    RETURN
  DECREMENTAR:
    DECF    DELAY,F
    RETURN
    
PROCE_TECLA:
    
    
    
CALCULAR_TECLA:
    

    
    END
