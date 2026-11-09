; PIC16F887 Configuration Bit Settings
#include "p16f887.inc"

; CONFIG1
; __config 0x20D9
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
;Declarar Variables

 
 
 ORG 0x00
    GOTO INIT

 ORG 0x04
    GOTO ISR
    
 ORG 0x05
INIT:
    ;CORREGIR
    BANKSEL ANSEL
    CLRF    ANSEL           ; Pone en 0 ANSEL (PORTA y PORTE a modo digital)
    CLRF    ANSELH          ; Pone en 0 ANSELH (PORTB a modo digital)
    BANKSEL TRISA
    CLRF    TRISA   ;En el puerto A están las salidas para el teclado
    BANKSEL PORTA
    CLRF    PORTA
    BANKSEL TRISB
    MOVLW   0xF0
    MOVWF   TRISB   ;En el puerto B están las entradas para el teclado
    BANKSEL PORTB
    MOVLW   0xF0
    MOVWF   PORTB
    MOVF    PORTB,W
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
    MOVLW   .5
    MOVWF   TMR0
    
    ;Inicialización de variables
    ;COMPLETAR
    TEMPB	EQU 0x20
    TEMPD_L	EQU 0x21
    TEMPD_H	EQU 0x22
    TEMPD_INIT	EQU 0x23
    CONT	EQU 0x24
    ESTADO	EQU 0x25
    UNIDAD	EQU 0x26
    DECENA	EQU 0x27
    CENTENA	EQU 0x28
    
	
 
    BANKSEL INTCON
    BCF	    INTCON,GIE      ; Deshabilito globalmente las interrupciones
    
    ;Configuración interrupciones por cambio del puerto B
    BANKSEL IOCB
    MOVLW   0xF0
    MOVWF   IOCB ;habilito las interrupciones por cambio de los pines del puerto B
    
    ; Configuración de interrupciones
    BANKSEL INTCON
    BCF	    INTCON,T0IF     ; Borro bandera de TMR0
    BCF     INTCON,RBIF	    ; Borro bandera de cambio de PORTB
    BSF     INTCON,T0IE     ; Habilitar interrupción TMR0
    BSF     INTCON,RBIE	    ; Habilitar interrupción por cambio
    BSF     INTCON,GIE      ; Habilitar interrupciones globales
    
    GOTO    MAIN
    
ISR:
    BTFSC   INTCON,T0IF
    CALL    ATENDER_TIMER0
    BTFSC   INTCON,RBIF
    CALL    ATENDER_RBI
    RETFIE

MAIN:
    ;COMPLETAR
    GOTO    MAIN

MULT25:	    ;Escala la señal de 0 a 255 a una escala de 0 a 100
	MOVLW	.4
	MOVWF	CONT
	MOVF	TEMPB, W
	MOVWF	TEMPD_L
	MOVWF	TEMPD_INIT
MULT16:
	CLRF	STATUS,C
	RLF	TEMPD_H, F
	CLRF	STATUS,C
	RLF	TEMPD_L, F
	BTFSC	STATUS,C
	INCF	TEMPD_H, F
	DECFSZ	CONT,F
	GOTO	MULT16
	MOVLW	.9
	MOVWF	CONT	
	GOTO	SUMAR9

SUMAR9:
	MOVF	TEMPD_INIT,W
	ADDWF	TEMPD_L, F
	BTFSC	STATUS, C
	INCF	TEMPD_H, F
	DECFSZ	CONT, F
	GOTO	SUMAR9
	MOVLW	.6
	MOVWF	CONT

DIVIDIR_64:
	CLRF	STATUS, C
	RRF	TEMPD_L, F
	CLRF	STATUS, C
	RRF	TEMPD_H, F
	BTFSC	STATUS, C
	BSF	TEMPD_L,7
	DECFSZ	CONT, F
	GOTO	DIVIDIR64
	CLRF	DECENA
	CLRF	UNIDAD
	CLRF	CENTENA
	GOTO 	SEPARAR_DATO

SEPARAR_DATO:	;Separa en unidad, decena y centena la variable TEMPD_L en BCD no empaquetado
	BCF		STATUS, C
	MOVLW	.10
	SUBWF	TEMPD_L, F
	BTFSS	STATUS,C
	GOTO 	GUARDAR
	INCF	DECENA, F
	GOTO	SEPARAR_DATO

GUARDAR:
	MOVF	TEMPD_L, W
	MOVWF	UNIDAD
	MOVLW	.10
	SUBWF	DECENA,W
	BTFSS	STATUS, Z
	RETURN
	INCF	CENTENA, F	
	CLRF	DECENA
	RETURN

    

    
;Rutina de interrupción de timer0  
ATENDER_TIMER0:

    
;Rutina de interrupción del puerto B
ATENDER_RBI:
    BTFSS   INTCON, RBIE ;si corresponde, entra en la rutina
    RETURN
    BCF	    INTCON,RBIE ;deshabilita las interrupciones del puerto B
    MOVF    PORTB,W	;actualiza el latch del puerto
    BCF	    INTCON,RBIF ;baja la bandera
    MOVLW   .20
    MOVWF   DELAY   ;carga el delay
    BSF	    CONTROL,PULSO   ;levanta la bandera
    RETURN

;Rutina de actualización de los displays
;CORREGIR PARA MOSTRAR LOS REGISTROS CORRESPONDIENTES AL TP_FINAL
LOOP_DISPLAY:
    BANKSEL INDICE	    ;guarda la parte alta de la direcci?n de la tabla
    MOVLW   HIGH TABLA
    MOVWF   PCLATH
    BANKSEL PORTC
    CLRF    PORTC	    ;apaga los displays
    MOVLW   0x30	    
    BTFSC   CONTROL, ESTADO ;le carga el primer valor de las variablas DIS
    ADDLW   0x05	    ;si esta en EDITAR le carga el primer valor de las variables EDIT
    MOVWF   FSR		    ;direcciona DIS_U si estado es 0 y EDIT_U si estado es 1
    MOVF    DATA_EN,W	    ;carga la variable auxilar
    MOVWF   DATA_AUX
    BTFSS   DATA_AUX,4	    ;si no tiene que encender los LEDS muestra los display en BUCLE
    GOTO    BUCLE
    MOVLW   0x00
    CALL    CONFIG_LEDS
    GOTO    SALTA2
  BUCLE:		;busca que display tiene que mostrar para cargar la variable correspondiente
    BTFSC   DATA_AUX,0	
    GOTO    SALTA	;Si es 1 (Si), salta 4 instrucciones hacia abajo
    RRF	    DATA_AUX, 1 ;Rota a la derecha
    INCF    FSR, 1	;Incrementa FSR
    GOTO    BUCLE	;Vuelve al ciclo
  SALTA:
    MOVF    INDF, W	;cuando encuentra la variable, la carga en W y va a la tabla
    CALL    TABLA
  SALTA2:
    BANKSEL PORTD	;carga el dato en PORTD
    MOVWF   PORTD
    BANKSEL PORTC	;enciende el DISPLAY o LED segun corresponda
    MOVF    DATA_EN,W	
    MOVWF   PORTC
    RLF	    DATA_EN,F	;desplaza la variable DATA_EN para la siguiente iteraci?n
    BTFSS   DATA_EN,5	; 00100000
    RETURN
    MOVLW   0x01	;si el "1" va al bit 6 lo mueve al bit 0
    MOVWF   DATA_EN
    RETURN
  CONFIG_LEDS:
    CLRF    LED_BUS
    BTFSS   CONTROL,ESTADO
    RETURN
    BSF	    LED_BUS,0
    BTFSC   EDIT_IND,0
    BSF	    LED_BUS,7
    BTFSC   EDIT_IND,1
    BSF	    LED_BUS,6
    BTFSC   EDIT_IND,2
    BSF	    LED_BUS,5
    BTFSC   EDIT_IND,3
    BSF	    LED_BUS,4
    MOVF    LED_BUS,W
    RETURN

;Rutina de rearmado del teclado  
REARMAR:
    BCF	    INTCON,RBIE	;deshabilita las interrupciones del puerto B	
    BCF	    CONTROL,PULSO   ;baja la bandera de pulso
    CLRF    PORTA   ;resstablece el puerto A
    MOVF    PORTB,W ;actualiza los latch del puerto B
    BCF	    INTCON,RBIF	    ;Baja la bandera de interrupcion del puerto B
    BSF	    INTCON,RBIE	    ;habilita las interrupciones del puerto B
    RETURN
    
  ;Rutina de validación del pulso
VALIDAR_PULSO:
    MOVF    DELAY,F
    BTFSS   STATUS,Z	;verifico que el tiempo de antirebote haya terminado
    GOTO    DECREMENTAR	;si no pasó decremento el conatdor
    MOVF    PORTB,W	;leo el puerto para verificar que siga habiendo una
    SUBLW   0xF0	;tecla pulsada
    BTFSS   STATUS,Z	;si z = 1 no hay pulsación y solo rearma y retorna
    GOTO    HAY_TECLA	;si z = 0 hay una tecla pulsada
    CALL    REARMAR	;se reestablece el teclado
    RETURN
  HAY_TECLA:
    CALL    PROCE_TECLA	;se busca la tecla
    RETURN
  DECREMENTAR:
    DECF    DELAY,F	;dedcrementa el contador y vuelve
    RETURN
    
  ;Rutina de procesamiento de la tecla
PROCE_TECLA:
    MOVLW   0xFF
    MOVWF   PORTA   ;pone todo el puerto en alto
    ;BSF	    STATUS,C ;seteo el carry para no tener un falso cero en FILA
    CALL    ITERAR_TECLAS
    MOVWF   COLUMNA	;cargo el dato de la columna encontrada
    BTFSC   COLUMNA,7	;si no se detectó una tecla (la bandera está en COLUMNA) sale
    GOTO SALIR  
    CALL    CALCULAR_TECLA  ;si hay una tecla se calcula su valor
    ADDWF   COLUMNA,W	    ;le sumo el valor de la fila
    MOVWF   TECLA	    ;lo guardo en tecla
    MOVLW   0xFE
    MOVWF   FILA	    ;reseteo FILA
    CLRF    COLUMNA	    ;vuelvo columna a cero
    BSF	    CONTROL,TECLA_ASIGNADA ;levanto la bandera 
  SALIR:
    CALL    REARMAR
    RETURN
ITERAR_TECLAS:
    MOVF    FILA,W
    MOVWF   PORTA   ;pone un cero en una sola fila y busca el cero en las columnas
    BTFSS   PORTB,4
    RETLW   0x00
    BTFSS   PORTB,5
    RETLW   0x01
    BTFSS   PORTB,6
    RETLW   0x02
    BTFSS   PORTB,7
    RETLW   0x03
    BSF	    STATUS,C ;seteo el carry para no tener un falso cero en FILA
    RLF	    FILA,F   ;pasa a la siguiente fila
    BTFSC   FILA,4   ;verifica si se pasó
    GOTO    ITERAR_TECLAS
    MOVLW   0xFE     ;si se pasó, la pulsación fue falsa
    MOVWF   FILA     ;reestablce FILA, levanta una bandera en columna y retorna
    MOVLW   0x80  
    MOVWF   COLUMNA
    RETURN
CALCULAR_TECLA:	    ;retorna con el valor correspondiente a la fila
    BTFSS   FILA,0  ;donde se encontró la tecla
    RETLW   0x00
    BTFSS   FILA,1
    RETLW   0x04
    BTFSS   FILA,2
    RETLW   0x08
    RETLW   0x0C
    
;Rutina de ejecución en base a la función de la tecla
;ESTAS RUTINAS TIENEN QUE CAMBIARSE PARA FUNCIONAR CON LAS FUNCIONES DISEÑADAS
EJECUTAR:
    BTFSS   CONTROL,ESTADO  ;verifica si está editando (estado 1)
    GOTO    PASAR_EDITANDO  ;tiene que verificar si tiene que pasar al estado 1
    GOTO    EDITAR	    ;busca la acción que tiene que ejecutar
PASAR_EDITANDO:	;se accede cuando el estado no sea editando
    MOVF    TECLA,W
    SUBLW   0x0B 
    BTFSS   STATUS,Z ;verifico que sea 11
    GOTO    RETORNAR  ;si no es 11 no hago nada, no paso a editando
    BSF	    CONTROL,ESTADO  ;si es 11 paso a editando
    MOVLW   0x08
    MOVWF   EDIT_IND	;cargo el indice
    GOTO    RETORNAR
EDITAR:	;se accede cuando el estado es editando
    MOVF    TECLA,W
    SUBLW   0x09    ;verifica si la tecla es menor o igual a 9 (números)
    BTFSS   STATUS,C
    GOTO    ENCONTRAR_OPERACION ;si es mayor hay que realizar una operación
    GOTO    ACT_NUM		;sino hay que modificar un número
ACT_NUM:    ;meto el dato en la variable  correspondiente
    MOVF    TECLA,W
    BTFSC   EDIT_IND,0	;busca la ubicacióndel cursor
    MOVWF   EDIT_U	;pone el número leído en la variable corresponciente
    BTFSC   EDIT_IND,1
    MOVWF   EDIT_D
    BTFSC   EDIT_IND,2
    MOVWF   EDIT_C
    BTFSC   EDIT_IND,3
    MOVWF   EDIT_M
    GOTO    TECLA_B ;avanza el cursor
ENCONTRAR_OPERACION:
    MOVLW   0x0A
    SUBWF   TECLA,F
    BTFSC   STATUS,Z	;si es 0 la tecla es * (10)
    GOTO    CANCELAR	;funcion de *
    DECF    TECLA,F	;le resto uno al resultado, acortando el rango de valores
    BTFSC   STATUS,Z	;si es cero la tecla es # (11)
    GOTO    RETORNAR	;funcion de #, en este estado no hace nada
    DECF    TECLA,F
    BTFSC   STATUS,Z	;si es 0 la tecla es A (12)
    GOTO    TECLA_A	;funcion de A
    DECF    TECLA,F
    BTFSC   STATUS,Z	;si es 0 la tecla es B (13)
    GOTO    TECLA_B ;función de B
    DECF    TECLA,F
    BTFSS   STATUS,Z	 ;si es 0 la tecla es C (14)
    GOTO    BORRAR	 ;si no es cero solo puede ser D (15)
    GOTO    CONFIRMAR	;función de C
CANCELAR:   ;funcion de *
    MOVF    DIS_U,W
    MOVWF   EDIT_U ;pone los valores anteriores (confirmados) en las variables de edición
    MOVF    DIS_D,W
    MOVWF   EDIT_D
    MOVF    DIS_C,W
    MOVWF   EDIT_C
    MOVF    DIS_M,W
    MOVWF   EDIT_M
    BCF	    CONTROL,ESTADO ;pasa al estado confirmado
    GOTO    RETORNAR
    
TECLA_A:    ;funcion de A
    BTFSS   ESTADO, 0
    GOTO    TEMPSENSOR	
    BTFSS   ESTADO, 1
    CLRF    ESTADO
    GOTO    RETORNAR
TEMPSENSOR:
    MOVLW   .1
    MOVWF   ESTADO
    GOTO    RETORNAR


TECLA_B: ;función de B
    BTFSS   ESTADO, 1
    GOTO    MOSTRAR_SP
    MOVLW   .3
    BTFSS   ESTADO, 0
    MOVWF   ESTADO
    GOTO    RETORNAR
MOSTRAR_SP:
    MOVLW   .2
    MOVWF   ESTADO
    GOTO    RETORNAR

CONFIRMAR:  ;función de C
    MOVF    EDIT_U,W	;pone los valores nuevos (editados) en las variables anteriores
    MOVWF   DIS_U
    MOVF    EDIT_D,W
    MOVWF   DIS_D
    MOVF    EDIT_C,W
    MOVWF   DIS_C
    MOVF    EDIT_M,W
    MOVWF   DIS_M
    BCF	    CONTROL,ESTADO ;pasa al estado confirmado
    GOTO    RETORNAR
BORRAR:	    ;función de D
    CLRF    EDIT_U ;borra las variables de edición
    CLRF    EDIT_D
    CLRF    EDIT_C
    CLRF    EDIT_M
    MOVLW   .1
    MOVWF   EDIT_IND ;reestablece el cursor
    GOTO    RETORNAR ;retorna sin cambiar de estado (sigue en edición)
RETORNAR:   ;reestablece las variables y retorna
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
