; PIC16F887 Configuration Bit Settings
#include "p16f887.inc"

; CONFIG1
; __config 0x20D9
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_ON & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
ESTADOS	    EQU 0x20
DSEG	    EQU 0x21
USEG	    EQU 0x22
DCENT	    EQU 0x23
UCENT	    EQU 0x24
CRONO	    EQU 0x25
DIV	    EQU 0x26
CONT	    EQU 0x27
AUX	    EQU 0x28
PULSADO	    EQU 1
ESPERAR	    EQU 2
CONTPULSO   EQU 0x30

    ORG 0x00
    GOTO INIT

    ORG 0x04
    GOTO ISR
    
    ORG 0x05
INIT:
    ;Inicialización de Puertos//
    BANKSEL ANSEL
    CLRF    ANSEL           ; Pone en 0 ANSEL (PORTA y PORTE a modo digital)
    CLRF    ANSELH          ; Pone en 0 ANSELH (PORTB a modo digital)
    BANKSEL TRISA	    
    MOVLW   b'11111111'	    ;no se usa
    MOVWF   TRISA
    BANKSEL TRISB
    MOVLW   b'11111111'	    ;Entrada para pulsador
    MOVWF   TRISB
    BANKSEL TRISC	    
    CLRF    TRISC	    ;Para los NPN (multiplexado)
    BANKSEL TRISD
    CLRF    TRISD           ;Salidas 7 segmentos
    
    BANKSEL OPTION_REG	    ;inicia el time0 con un prescaler de 32
    MOVLW   b'10000100'
    MOVWF   OPTION_REG
    BANKSEL TMR0	    ;inicializa el timer0 con 100
    MOVLW   0x64
    MOVWF   TMR0
    BANKSEL INTCON
    BCF	    INTCON,GIE       ; Deshabilito globalmente las interrupciones
    BCF	    INTCON,T0IF      ; Borro bandera de TMR0
    BCF	    INTCON,INTF      ; Borro bandera externa

    BSF	    INTCON,T0IE      ; Habilito interrupción TMR0
    BSF	    INTCON,INTE      ; Habilito interrupción RB0/INT

    BSF	    INTCON,GIE       ; Habilito globalmente las interrup
    
    
    ;Inicialización de Variables//
    MOVLW   0x01
    MOVWF   ESTADOS
    MOVLW   0x01
    MOVWF   CRONO
    CLRF    DSEG
    CLRF    USEG
    CLRF    DCENT
    CLRF    UCENT
    CLRF    DIV
    CLRF    CONT
    MOVLW   .200
    MOVWF   CONTPULSO
   
   
ISR:
    BTFSC   INTCON,T0IF
    CALL    SERVICIO_TIMER0
    BTFSC   INTCON,INTF
    CALL    SERVICIO_INTE
    RETFIE
    
MAIN:
    GOTO MAIN

SERVICIO_TIMER0:
    BCF	    INTCON,T0IF
    BANKSEL TMR0
    MOVLW   .100
    MOVWF   TMR0
    MOVLW   .1
    ANDWF   ESTADOS,W
    BTFSS   STATUS,Z		;si el primer bit es 0, incrementa el contador
    GOTO    SALTAR
    BTFSC   DIV,0
    CALL    INCREMENTAR
    INCF    DIV
SALTAR:
    CALL    LOOPDISPLAY
    CALL    VALIDAR_PULSO
    RETURN
    
    
SERVICIO_INTE:
    BCF	    INTCON,INTF
    BTFSC   AUX,PULSADO
    RETURN
    BCF	    INTCON,INTE
    MOVLW   .10
    MOVWF   CONT
    BSF	    AUX,PULSADO
    RETURN
    
LOOPDISPLAY:
    ;BANKSEL INDICE	    ;guarda la parte alta de la dirección de la tabla
    MOVLW   HIGH TABLA
    MOVWF   PCLATH
    BANKSEL PORTD	    
    CLRF    PORTD	    ;apaga los 7 segmenos de los display
    BTFSC   CRONO,0	    ;si CRONO esta en 0001 mueve UCENT a W
    MOVF    UCENT,w
    BTFSC   CRONO,1	    ;si CRONO esta en 0010 mueve DCENT a W
    MOVF    DCENT,w
    BTFSC   CRONO,2	    ;si CRONO esta en 0100 mueve USEG a W
    MOVF    USEG,W
    BTFSC   CRONO,3	    ;si CRONO esta en 1000 mueve DSEG a W
    MOVF    DSEG,W
    CALL    TABLA
    
    BANKSEL PORTD	    ;puerto donde están los 7 segmentos
    MOVWF   PORTD
    
    BANKSEL PORTC	    ;puerto donde están los NPN del multiplexado
    MOVF    CRONO,W
    MOVWF   PORTC	    ;Habilita el NPN del Display Correspondiente
    
    BCF    STATUS,C	    ;se limpia el carry y se rota a la izquierda la 
    RLF	    CRONO,F	    ;variable CRONO
    BTFSS   CRONO,4	    ;se verifica si el "1" pasó al bit 4
    RETURN
    MOVLW   0x01	    ;si llegó se lo vuelve a poner en el bit 0
    MOVWF   CRONO
    RETURN

INCREMENTAR:
    INCF    UCENT	;Incrementa UCENT 
    MOVF    UCENT,W
    ANDLW   0x0A	;Si llega a 10 lo pone en 0
    BTFSS   STATUS,Z	;Si no llega a 10 retorna
    RETURN
    CLRF    UCENT	
    INCF    DCENT	;Incrementa DCENT
    MOVF    DCENT,W	;Si llega a 10 lo pone en 0
    ANDLW   0x0A	;Si no llega a 10 retorna
    BTFSS   STATUS,Z
    RETURN
    CLRF    DCENT
    INCF    USEG	;Incrementa USEG
    MOVF    USEG,W	;Si llega a 10 lo pone en 0
    ANDLW   0x0A	;Si no llega a 10 retorna
    BTFSS   STATUS,Z
    RETURN
    CLRF    USEG
    INCF    DSEG	;Incrementa DSEG
    MOVF    DSEG,W	;Si llega a 10 lo pone en 0
    ANDLW   0x06	;Si no llega a 10 retorna
    BTFSS   STATUS,Z
    RETURN
    CLRF    DSEG
    RETURN
    
VALIDAR_PULSO:
    BTFSS   AUX,PULSADO	    ;si pulsado está en 0 retorna
    RETURN
    BTFSS   AUX,ESPERAR	    ;si esperar está en 0 va a primera pulsación
    GOTO    PRIMERPULSO
    BTFSC   PORTB,3	    ;verifica si el pulsador sigue presionado
    GOTO    CLASIFPULSO	    ;si el botón no esta presionado va a Clasificar Pulso
    MOVF    CONTPULSO,W	    ;empieza a contar para validar el pulso largo
    BTFSS   STATUS,Z
    DECF    CONTPULSO	    ;si CONTPULSO llega a 0 entonces el pulso es largo
    RETURN
    
CLASIFPULSO:
    MOVF    CONTPULSO,W	    
    BTFSS   STATUS,Z	    ;si CONTPULSO llegó a 0 entonces va a PULSO LARGO
    GOTO    PULSOCORTO
    MOVLW   .1		    ;en PULSO LARGO pone el estado en Detenido y 
    MOVWF   ESTADOS	    ;limpia todos los vales de los displays
    CLRF    UCENT
    CLRF    DCENT
    CLRF    USEG
    CLRF    DSEG
    GOTO    RETORNAR

PULSOCORTO:
    MOVLW   .1		    ;limpia el bit 1 de la variable Estado
    ANDWF   ESTADOS,F
    BTFSS   STATUS,Z	    ;si Estado es 01 entonces pone el estado Contando
    INCF    ESTADOS,F	    ;contando = 10
    BTFSC   ESTADOS,1
    GOTO    RETORNAR	    ;si Estado esta en Contando retorna
    MOVLW   .3		    ;si el estado es 00, lo pone en Pausa
    MOVWF   ESTADOS 
    GOTO    RETORNAR
    
PRIMERPULSO:
    DECFSZ  CONT,F	    ;verifica si contador es 0, sino lo decrementa y retorna
    RETURN		    ;si es 0 ya se validó el pulso, verifica si sigue presionado
    BTFSC   PORTB,3	    ;verificar si el pulsador está presionado
    GOTO    RETORNAR	    ;si no sigue presionado entonces va a RETORNAR
    BSF	    AUX,ESPERAR	    ;si sigue presionado levanta la bandera ESPERAR
    RETURN
    
RETORNAR:		    ;limpia las variables auxiliares, la bandera INTF
    BCF	    AUX,PULSADO	    ;y reinicia la interrupcion INTE
    BCF	    AUX,ESPERAR
    MOVLW   .200
    MOVWF   CONTPULSO
    BCF	    INTCON,INTF
    BSF	    INTCON,INTE
    RETURN
    
    ORG 0x0300
TABLA:
    ADDWF PCL,f
    RETLW b'01111110'	;0
    RETLW b'00001010'	;1
    RETLW b'10110110'	;2
    RETLW b'10011110'	;3
    RETLW b'11001010'	;4
    RETLW b'11011100'	;5
    RETLW b'11111100'	;6
    RETLW b'00001110'	;7
    RETLW b'11111110'	;8
    RETLW b'11011110'	;9
    
    END


