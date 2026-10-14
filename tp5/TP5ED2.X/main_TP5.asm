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
 ESTADO	EQU 0
 PULSO	EQU 1	;el bit 1 es la bandera con la que se accede a atender pulso
 TECLA_ASIGNADA EQU 2 ;el bit 2 es la bandera con la que se accede a EJECUTAR
 REPOSO EQU 0x00    ;REPOSO es el estado del teclado cuando no se mapea, tiene todas las filas en alto
 DELAY EQU 0x44 ;registro para contar el delay antirebote
 DATA_EN EQU 0x45
 DATA_AUX EQU 0x46
 INDICE EQU 0x47
 
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
    MOVLW   0xF0
    MOVWF   TRISB   ;En el puerto B están las entradas para el teclado
    MOVWF   PORTB
    BANKSEL TRISC
    CLRF    TRISC
    BANKSEL TRISD
    CLRF    TRISD
    
    ;Pull ups internas
    BCF	    OPTION_REG,7 ;Habilito las pull-up del puerto B
    MOVLW   0xF0
    MOVWF   WPUB    ;Habilito solo las que usamos (RB0 tiene externa)
    
    ; Configuración de Timer0
    BANKSEL OPTION_REG
    BCF     OPTION_REG,T0CS    ; Reloj interno Fosc/4
    BCF     OPTION_REG,PSA     ; Prescaler asignado a TMR0
    BCF     OPTION_REG,PS2
    BCF     OPTION_REG,PS1
    BSF     OPTION_REG,PS0     ; Prescaler 1:4

    ; Carga inicial de Timer0
    BANKSEL TMR0
    MOVLW   .6
    MOVWF   TMR0
    
    
    ; Configuración de interrupciones
    BANKSEL INTCON
    BCF	    INTCON,GIE      ; Deshabilito globalmente las interrupciones
    BCF	    INTCON,T0IF     ; Borro bandera de TMR0
    BCF     INTCON,RBIF	    ; Borro bandera de cambio de PORTB
    BSF     INTCON,T0IE     ; Habilitar interrupción TMR0
    BSF     INTCON,RBIE	    ; Habilitar interrupción por cambio
    BSF     INTCON,GIE      ; Habilitar interrupciones globales
    
    ;Inicialización de variables
    CLRF    DIS_U
    CLRF    DIS_D
    CLRF    DIS_C
    CLRF    DIS_M
    CLRF    EDIT_U ;EDIT_IND en 0001
    CLRF    EDIT_D
    CLRF    EDIT_C
    CLRF    EDIT_M ;EDIT_IND en 1000
    CLRF    LED_IND	
    CLRF    EDIT_IND	
    CLRF    CONTROL	;Inicia en estado 0 con las banderas abajo
    CLRF    TECLA
    CLRF    COLUMNA
    MOVLW   0x01
    MOVWF   FILA
    CLRF    DELAY
    CLRF    DATA_EN
    BSF	    DATA_EN,0
    CLRF    DATA_AUX
    CLRF    INDICE
    
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
    BCF INTCON,T0IF
    BANKSEL TMR0
    MOVLW .5
    MOVWF TMR0
    CALL LOOP_DISPLAY
    BTFSC CONTROL,PULSO
    CALL VALIDAR_PULSO
    BTFSC CONTROL,TECLA_ASIGNADA
    CALL EJECUTAR
    RETURN
  
ATENDER_RBI:
    BTFSS INTCON, RBIE
    RETURN
    BCF INTCON,RBIF
    BCF INTCON,RBIE
    MOVLW .20
    MOVWF DELAY
    BSF CONTROL,PULSO
    RETURN
    
LOOP_DISPLAY:
    BANKSEL INDICE ;guarda la parte alta de la dirección de la tabla
    MOVLW HIGH TABLA
    MOVWF PCLATH
    BANKSEL PORTC
    CLRF PORTC ;apaga los displays
    MOVLW 0x30
    BTFSC CONTROL, ESTADO
    ADDLW 0x05
    MOVWF FSR
    MOVF DATA_EN,W
    MOVWF DATA_AUX

  BUCLE:
    BTFSC DATA_AUX,0
     GOTO $+4 ;Si es 1 (Si), salta 4 instrucciones hacia abajo
    RRF DATA_AUX, 1 ;Rota a la derecha
    INCF FSR, 1 ;Incrementa FSR
    GOTO BUCLE ;Vuelve al ciclo
    MOVF INDF, W
    CALL TABLA

    BANKSEL PORTD
    MOVWF PORTD
    BANKSEL PORTC
    MOVF DATA_EN,W
    MOVWF PORTC
    RLF DATA_EN,F
    BTFSS DATA_EN,4 ; 00010000
    RETURN
    MOVLW 0x01
    MOVWF DATA_EN
    RETURN
    
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
    SUBLW   0xF0
    BTFSC   STATUS,Z	;si z = 1 no hay pulsación
    CALL    REARMAR	;se reestablece el teclado
    BTFSS   STATUS,Z	;si z = 0 hay una tecla pulsada
    CALL    PROCE_TECLA	;se busca la tecla
    RETURN
  DECREMENTAR:
    DECF    DELAY,F
    RETURN
    
PROCE_TECLA:
    MOVLW   0xFF
    MOVWF   PORTA
    BSF	    STATUS,C ;seteo el carry para no tener un falso cero en FILA
    CALL    ITERAR_TECLAS
    BTFSC   COLUMNA,7	;si no se detectó una tecla
    GOTO SALIR  
    MOVWF   COLUMNA ;cargo el dato de la columna encontrada
    CALL    CALCULAR_TECLA
    ADDWF   COLUMNA,F	;le sumo el valor de la fila
    MOVWF   TECLA
    MOVLW   0xFE
    MOVWF   FILA    ;reseteo FILA
    BSF	    CONTROL,TECLA_ASIGNADA ;levanto la bandera
  SALIR:
    CALL    REARMAR
    RETURN
    

ITERAR_TECLAS:
    MOVF    FILA,W
    MOVWF   PORTA
    BTFSS   PORTB,4
    RETLW   0x00
    BTFSS   PORTB,5
    RETLW   0x01
    BTFSS   PORTB,6
    RETLW   0x02
    BTFSS   PORTB,7
    RETLW   0x03
    RLF	    FILA,F
    BTFSC   FILA,4
    GOTO    ITERAR_TECLAS
    MOVLW   0xFE
    MOVWF   FILA
    MOVLW   0x80  
    MOVWF   COLUMNA
    CALL    REARMAR
    RETURN
    
CALCULAR_TECLA:
    BTFSS   FILA,0
    RETLW   0x00
    BTFSS   FILA,1
    RETLW   0x04
    BTFSS   FILA,3
    RETLW   0x08
    RETLW   0x0C
    
EJECUTAR:
    BTFSS   CONTROL,ESTADO
    GOTO    PASAR_EDITANDO
    GOTO    EDITAR
    
    
EDITAR:	;se accede cuando el estado es editando
    MOVF    TECLA,W
    SUBLW   0x09
    BTFSS   STATUS,C
    GOTO    ENCONTRAR_OPERACION
    MOVF    TECLA,W
    GOTO    ACT_NUM
    
ENCONTRAR_OPERACION:
    MOVLW   0x0A
    SUBWF   TECLA,F
    BTFSC   STATUS,C	;si es 0 la tecla es *
    GOTO    CANCELAR	;funcion de *
    DECF    TECLA,F
    BTFSC   STATUS,Z ;si es cero la tecla es #
    GOTO    RETORNAR ;funcion de #, en este estado no hace nada
    DECF    TECLA,F
    BTFSC   STATUS,C	;si es 0 la tecla es A
    GOTO    CURSOR_IZQUIERDA ;funcion de A
    DECF    TECLA,F
    BTFSC   STATUS,C ;si es 0 la tecla es B
    GOTO    CURSOR_DERECHA
    DECF    TECLA,F
    BTFSC   STATUS,C ;si es 0 la tecla es C
    GOTO    BORRAR
    GOTO    CONFIRMAR
    
    
CURSOR_IZQUIERDA:
    RLF	    EDIT_IND,F
    BTFSS   EDIT_IND,4
    GOTO    RETORNAR
    MOVLW   0x01
    MOVWF   EDIT_IND
    GOTO RETORNAR
    
CURSOR_DERECHA:
    RRF	    EDIT_IND,F
    BTFSS   STATUS,C
    GOTO    RETORNAR
    MOVLW   0x01
    MOVWF   EDIT_IND
    GOTO RETORNAR
    
BORRAR:
    CLRF EDIT_U
    CLRF EDIT_D
    CLRF EDIT_C
    CLRF EDIT_M
    MOVLW .1
    MOVWF EDIT_IND
    GOTO RETORNAR
    
ACT_NUM: ;meto el dato en la variable  correspondiente
    BTFSC   EDIT_IND,0
    MOVWF   EDIT_U
    BTFSC   EDIT_IND,1
    MOVWF   EDIT_D
    BTFSC   EDIT_IND,2
    MOVWF   EDIT_C
    BTFSC   EDIT_IND,3
    MOVWF   EDIT_M
    GOTO    CURSOR_IZQUIERDA
    
CANCELAR:
    MOVF    DIS_U,W
    MOVWF   EDIT_U
    MOVF    DIS_D,W
    MOVWF   EDIT_D
    MOVF    DIS_C,W
    MOVWF   EDIT_C
    MOVF    DIS_M,W
    MOVWF   EDIT_M
    BCF	    CONTROL,ESTADO
    GOTO    RETORNAR
    
CONFIRMAR:
    MOVF    EDIT_U,W
    MOVWF   DIS_U
    MOVF    EDIT_D,W
    MOVWF   DIS_D
    MOVF    EDIT_C,W
    MOVWF   DIS_C
    MOVF    EDIT_M,W
    MOVWF   DIS_M
    BCF	    CONTROL,ESTADO
    GOTO    RETORNAR
    
PASAR_EDITANDO:	;se accede cuando el estado no sea editando
    MOVF    TECLA,W
    SUBLW   0x0B 
    BTFSS   STATUS,Z ;verifico que sea 11
    GOTO    RETORNAR  ;si no es 11 no hago nada, no paso a editando
    BSF	    CONTROL,ESTADO  ;si es 11 paso a editando
    MOVLW   0x01
    MOVWF   EDIT_IND	;cargo el indice
    GOTO    RETORNAR
    
RETORNAR:
    CLRF    TECLA   ;borro la tecla
    BCF	    CONTROL,TECLA_ASIGNADA  ;bajo la bandera
    RETURN
    
ORG 0x0300
TABLA:
    ADDWF PCL,f
    RETLW b'00111111'	;0
    RETLW b'00000110'	;1
    RETLW b'01011011'	;2
    RETLW b'01001111'	;3
    RETLW b'01100110'	;4
    RETLW b'01101101'	;5
    RETLW b'01111101'	;6
    RETLW b'00000111'	;7
    RETLW b'01111111'	;8
    RETLW b'01101111'	;9    
    
    END
