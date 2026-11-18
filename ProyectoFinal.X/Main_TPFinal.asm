; PIC16F887 Configuration Bit Settings
#include "p16f887.inc"

; CONFIG1
; __config 0x20D9
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
 
 ;Declarar Variables
    TEMPB	EQU 0x20    ;guarda ADRESH
    TEMPD_L	EQU 0x21
    TEMPD_H	EQU 0x22
    TEMPD_INIT	EQU 0x23
    CONT	EQU 0x24
    ESTADO	EQU 0x25
    
    U_DUTY	EQU 0x26
    D_DUTY	EQU 0x27
    C_DUTY	EQU 0x28
	
    U_TEMP	EQU 0x2C
    D_TEMP	EQU 0x2D
 
    U_SP	EQU 0x2E
    D_SP	EQU 0x2F
    C_SP	EQU 0x30
    
    U_SP_EDIT	EQU 0x32
    D_SP_EDIT	EQU 0x33
    C_SP_EDIT	EQU 0x34
	
    U_SP_AUX	EQU 0x36
    D_SP_AUX	EQU 0x37
    C_SP_AUX	EQU 0X50
    EDIT_IND	EQU 0x38
    SP		EQU 0x39
    CONTROL	EQU 0x3A
    PULSO	EQU 1	    ;el bit 1 es la bandera con la que se accede a atender pulso
    TECLA_ASIGNADA EQU 2    ;el bit 2 es la bandera con la que se accede a EJECUTAR
    ACT_DUTY	EQU 3
    FILA	EQU 0x3B
    COLUMNA	EQU 0x3C
    TECLA	EQU 0x3D
    DELAY	EQU 0x3E    ;registro para contar el delay antirebote
    INDICE	EQU 0x3F
    LED_BUS	EQU 0x40
    DATA_EN	EQU 0x41
    DATA_AUX	EQU 0x42
    ;C_TEMP	EQU 0x45
	
    TEMP_CTRL	EQU 0x46
    SP_ADC	EQU 0x47
    CNTRL_E     EQU 0x48
    SP_TMP_L    EQU 0x49
    SP_TMP_H    EQU 0x4A
    PWM_H	EQU 0x4B
    PWM_L	EQU 0x4C
    TMP_L       EQU 0x4D
    TMP_H       EQU 0x4E
    CONT_CTRL	EQU 0x4F
    DUTY_AUX	EQU 0x51
    CONT_DUTY	EQU 0x52
    DUTY_H	EQU 0x53
    DUTY_L	EQU 0x54
    DUTY_INIT	EQU 0x55
    INT_L       EQU 0x56
    INT_H       EQU 0x57
	
    W_TEMP	EQU 0x70
    STATUS_TEMP	EQU 0x71
    PCLATH_TEMP	EQU 0x72
	
    ORG 0x00
GOTO INIT

ORG 0x04
GOTO	ISR

INIT:
    BANKSEL ANSEL
    MOVLW   0x20
    MOVWF   ANSEL   ; Pone RE0 como analógico y el resto como digital
    BANKSEL ANSELH
    CLRF    ANSELH  ; Pone en 0 ANSELH (PORTB a modo digital)
    BANKSEL TRISA
    CLRF    TRISA   ;En el puerto A están las salidas para el teclado
    BANKSEL PORTA
    CLRF    PORTA
    BANKSEL TRISC
    CLRF    TRISC
    BANKSEL PORTC
    CLRF    PORTC
    BANKSEL TRISD
    CLRF    TRISD
    BANKSEL PORTD
    CLRF    PORTD
    BANKSEL TRISB
    MOVLW   0xF0
    MOVWF   TRISB   ;En el puerto B están las entradas para el teclado y las salidas de los enables de los displays
    BANKSEL PORTB
    CLRF    PORTB
    MOVF    PORTB,W
    MOVLW   0xFF
    MOVWF   PORTD
    
    ;Pull ups internas
    BANKSEL OPTION_REG
    BCF	    OPTION_REG,7 ;Habilito las pull-up del puerto B
    MOVLW   0xF0
    MOVWF   WPUB    ;Habilito solo las que usamos (RB0 tiene externa)
    
;Inicialización de variables
    ;COMPLETAR
    BANKSEL	TEMPB
    CLRF	TEMPB	
    MOVLW	.60
    MOVWF	TEMPB
    CLRF	TEMPD_L	
    CLRF	TEMPD_H	
    CLRF	TEMPD_INIT	
    CLRF	CONT	
    CLRF	ESTADO	
    MOVLW	0x01
    MOVWF	ESTADO
    CLRF	U_DUTY	
    CLRF	D_DUTY	
    CLRF	C_DUTY	
    CLRF	0x29
    MOVLW	.10
    MOVWF	0x2A
    MOVLW	.11
    MOVWF	0x2B
    CLRF	U_TEMP	
    CLRF	D_TEMP	
    ;CLRF	C_TEMP
    CLRF	U_SP	
    CLRF	D_SP	
    CLRF	C_SP
    CLRF	0x31
    CLRF	U_SP_EDIT	
    CLRF	D_SP_EDIT	
    CLRF	C_SP_EDIT
    CLRF	0x35
    CLRF	U_SP_AUX	
    CLRF	D_SP_AUX
    CLRF	C_SP_AUX
    CLRF	EDIT_IND
    BSF		EDIT_IND,3
    CLRF	DATA_EN
    BSF		DATA_EN,0	;se enciende el pimer bit de los enables
    CLRF	DATA_AUX
    MOVLW	.20
    MOVWF	SP				
    CLRF	CONTROL	
    MOVLW	0xFE
    MOVWF	FILA	
    CLRF	COLUMNA	
    CLRF	TECLA	
    CLRF	DELAY	
    CLRF	INDICE	
    CLRF	LED_BUS	
    CLRF	W_TEMP	
    CLRF	STATUS_TEMP	
    CLRF	PCLATH_TEMP
    CLRF	TEMP_CTRL
    CLRF	SP_ADC
    CLRF	CNTRL_E
    CLRF	SP_TMP_L
    CLRF	SP_TMP_H
    CLRF	PWM_L
    CLRF	PWM_H
    CLRF	TMP_H
    CLRF	TMP_L
    CLRF	CONT_CTRL
    CLRF	CONT_DUTY
    CLRF	DUTY_H
    CLRF	DUTY_L
    CLRF	DUTY_INIT
    CLRF	INT_L
    CLRF	INT_H
    
    BANKSEL INTCON
    BCF	    INTCON,GIE      ; Deshabilito globalmente las interrupciones
    
    ; Configuración de ADC
    BANKSEL ADCON1
    MOVLW   0x00            ; ADFM=0 (justif. izquierda), Vref = VDD/VSS
    MOVWF   ADCON1
    BANKSEL ADCON0
    MOVLW   b'10010101'       ; ADCS=01 (Fosc/8), CHS=0101 (AN5), GO=0, ADON=1
    MOVWF   ADCON0
    
    ;--- CCP2 con Special Event Triger del ADC ---
    BANKSEL CCP2CON
    MOVLW   b'00111011'	
    MOVWF   CCP2CON

    ; Configuración de TMR1
    BANKSEL PIR1
    BCF     PIR1,TMR1IF
    BANKSEL PIE1
    BCF     PIE1,TMR1IE ; Deshabilitar interrupcion Timer1
    BANKSEL T1CON
    MOVLW   0x31	; prescaler en 8
    MOVWF   T1CON       ; Encender Timer1
    
    ;--- PWM en CCP1 (RC2) ---
    BANKSEL PR2
    MOVLW   0xF9            ; periodo de 1 ms
    MOVWF   PR2
    BANKSEL CCPR1L
    CLRF    CCPR1L          ; duty inicial = 0
    CLRF    CCPR1H
    MOVLW   0x0C            ; modo PWM, bits bajos de duty = 00
    MOVWF   CCP1CON
    
    BANKSEL CCPR2H
    MOVLW   0xF4
    MOVWF   CCPR2H
    MOVLW   0x24
    MOVWF   CCPR2L ;timer 1 larga ADC cada 0,5 seg (N = 62500, P = 8)
    
    BANKSEL T2CON
    MOVLW   0x05            ; TMR2 ON, prescaler 1:4
    MOVWF   T2CON
    
    ;Configuración interrupciones por cambio del puerto B
    BANKSEL IOCB
    MOVLW   0xF0
    MOVWF   IOCB ;habilito las interrupciones por cambio de los pines del puerto B
    
    BANKSEL INTCON
    BSF     INTCON,PEIE
    BCF	    INTCON,RBIF
    BSF	    INTCON,RBIE
    BANKSEL PIR1
    BCF     PIR1,ADIF
    BCF    PIR1,TMR2IF
    BCF    PIR2,CCP2IF
    BANKSEL PIE1
    BSF	    PIE1,ADIE
    BSF	    PIE1,TMR2IE
    BCF	    PIE2,CCP2IE ;no usamos esta, dejenla tranquila
    BANKSEL INTCON
    BSF     INTCON,GIE      ; Habilitar interrupciones globales
    
    GOTO    LOOP

ISR:
	MOVWF    W_TEMP		; Guardamos contexto
	SWAPF   STATUS,W
	MOVWF   STATUS_TEMP
	MOVF    PCLATH,W
	MOVWF   PCLATH_TEMP
	CLRF    PCLATH

	BANKSEL PIR1
	BTFSC   PIR1,TMR2IF
	CALL    ATENDER_TIMER2
	BTFSC   PIR1,ADIF
	CALL    ATENDER_ADC
	BANKSEL INTCON
	BTFSC   INTCON,RBIF
	CALL    ATENDER_RBI

	MOVF    PCLATH_TEMP,W	    ; Restauramos PCLATH
	MOVWF   PCLATH
	SWAPF   STATUS_TEMP,W	    ; Restauramos STATUS
	MOVWF   STATUS
	SWAPF    W_TEMP,F	    ; Restauramos W
	SWAPF   W_TEMP,W

	RETFIE
    
ATENDER_TIMER2:
	BANKSEL PIR1
	BCF	    PIR1,TMR2IF
	CALL    LOOP_DISPLAY	;actualiza displays
	BTFSC   CONTROL,PULSO	;verifica si hay un pulso pendiente de confirmar
	CALL    VALIDAR_PULSO
	BTFSC   CONTROL,TECLA_ASIGNADA ;verifica si se asignó una tecla al pulso
	CALL    EJECUTAR   ;ejecuta la acción en base al estado y la tecla
	RETURN
    
ATENDER_ADC:
	BANKSEL ADRESH		    ; Leemos parte baja
	MOVF    ADRESH,W
	BANKSEL TEMPB
	ANDLW	0xFE
	MOVWF   TEMPB	;para di splays
	MOVWF   TEMP_CTRL	;para control
	BANKSEL PIR1		    ; Limpiamos bandera de interrupcion
	BCF	PIR1,ADIF
	BANKSEL CONTROL
	BSF	CONTROL,ACT_DUTY
	;CALL    ESCALAR_SP
	RETURN

	;Rutina de interrupción del puerto B
ATENDER_RBI:
	BANKSEL	INTCON
	BTFSS   INTCON, RBIE ;si corresponde, entra en la rutina
	RETURN
	BCF	INTCON,RBIE ;deshabilita las interrupciones del puerto B
	BANKSEL	PORTB
	MOVF    PORTB,W	;actualiza el latch del puerto
	BANKSEL	INTCON
	BCF	INTCON,RBIF ;baja la bandera
	BANKSEL DELAY
	MOVLW   .20
	MOVWF   DELAY   ;carga el delay
	BSF	CONTROL,PULSO   ;levanta la bandera
	RETURN
	
LOOP:
	BANKSEL CONTROL
	BTFSC   CONTROL,ACT_DUTY
	CALL    MULT25	;acondiciona la medicón para mostrar en displays
	BTFSC   CONTROL,ACT_DUTY
	CALL   CALC_DUTY	;baja la bandera
	GOTO LOOP
	
CALC_DUTY:
; CNTRL_E = SP_ADC - TEMP_CTRL
; PWM = 44 * CNTRL_E
    BANKSEL CONTROL
    BCF     CONTROL,ACT_DUTY
    ; CNTRL_E = SP_ADC - TEMP_CTRL
    MOVF    TEMP_CTRL,W
    SUBWF   SP_ADC,W
; Si la temperatura supera al setpoint
; PWM = 0
    BTFSS   STATUS,C
    GOTO    DUTY_CERO
    MOVWF   CNTRL_E
    ; Integrador
    MOVF    CCPR1L,W
    BTFSC   STATUS,Z
    GOTO    NO_INTEG
    MOVF    CNTRL_E,W
    ADDWF   INT_L,F
    BTFSC   STATUS,C
    INCF    INT_H,F
NO_INTEG:
    ; PWM = 32 * CNTRL_E
    CLRF    PWM_H
    MOVF    CNTRL_E,W
    MOVWF   PWM_L
    MOVLW   .5
    MOVWF   CONT_CTRL
MUL32:
    BCF     STATUS,C
    RLF     PWM_L,F
    RLF     PWM_H,F
    DECFSZ  CONT_CTRL,F
    GOTO    MUL32
    ; TMP = 8 * CNTRL_E
    CLRF    TMP_H
    MOVF    CNTRL_E,W
    MOVWF   TMP_L
    MOVLW   .3
    MOVWF   CONT_CTRL
MUL8:
    BCF     STATUS,C
    RLF     TMP_L,F
    RLF     TMP_H,F
    DECFSZ  CONT_CTRL,F
    GOTO    MUL8
    ; PWM += TMP
    MOVF    TMP_L,W
    ADDWF   PWM_L,F
    MOVF    TMP_H,W
    BTFSC   STATUS,C
    ADDLW   .1
    ADDWF   PWM_H,F
    ; TMP = 4 * CNTRL_E
    CLRF    TMP_H
    MOVF    CNTRL_E,W
    MOVWF   TMP_L
    MOVLW   .2
    MOVWF   CONT_CTRL
MUL4:
    BCF     STATUS,C
    RLF     TMP_L,F
    RLF     TMP_H,F
    DECFSZ  CONT_CTRL,F
    GOTO    MUL4
    ; PWM += TMP
    MOVF    TMP_L,W
    ADDWF   PWM_L,F
    MOVF    TMP_H,W
    BTFSC   STATUS,C
    ADDLW   .1
    ADDWF   PWM_H,F
    ; Acción integral
    ; PWM += INT_H
    MOVF    INT_H,W
    ADDWF   PWM_L,F
    BTFSC   STATUS,C
    INCF    PWM_H,F
    
    ; Saturación
    MOVF    PWM_H,F
    BTFSS   STATUS,Z
    GOTO    SATURAR
    MOVF    PWM_L,W
    MOVWF   CCPR1L
    MOVWF   DUTY_AUX
    CALL    DISP_DUTY
    RETURN
SATURAR:
    MOVLW   0xFF
    MOVWF   CCPR1L
    MOVWF   DUTY_AUX
    CALL    DISP_DUTY
    RETURN
DUTY_CERO:
    CLRF    CCPR1L
    CLRF    DUTY_AUX
    CALL    DISP_DUTY
    RETURN

LOOP_DISPLAY:
	BANKSEL PORTB
	CLRF    PORTB
	BCF	PORTC,4
	BANKSEL INDICE	    ;guarda la parte alta de la direcci?n de la tabla
	MOVLW   HIGH TABLA
	MOVWF   PCLATH	
	BANKSEL PORTB
	CLRF    PORTB
	BANKSEL DATA_EN
	MOVF    DATA_EN,W
	MOVWF   DATA_AUX	    ;guardo el dato de enable en la var auxiliar
	BTFSC   DATA_EN,4
	GOTO    MOSTRAR_LEDS    ;si tiene que mostrar los leds salta a la rutina corresp
	MOVF    ESTADO,W	    ;sino calcula el dato que tiene que mostrar según 
	ADDWF   ESTADO,W	    ;el estado y el enable de datos
	ADDWF   ESTADO,W
	ADDWF   ESTADO,W
	ADDLW   0x26
	MOVWF   FSR
    BUCLE_DIS:
	BTFSC   DATA_AUX,0	;busca que display tiene que mostrar para cargar la variable correspondiente
	GOTO    LLAMAR_TABLA    ;cuando lo encuentra va a la tabla
	RRF	DATA_AUX, 1	;Rota a la derecha
	INCF    FSR, 1		;Incrementa FSR
	GOTO    BUCLE_DIS	;Vuelve al ciclo
    LLAMAR_TABLA:
	MOVF    INDF,W
	CALL    TABLA
	BANKSEL PORTD		;carga el dato en PORTD
	MOVWF   PORTD
	BANKSEL PORTB
	BANKSEL DATA_EN
	MOVF    DATA_EN,W	
	MOVWF   PORTB
	BCF	STATUS,C
	RLF	DATA_EN,F	;desplaza la variable DATA_EN para la siguiente iteraci?n
	;MOVLW   0x01
	;BTFSC   DATA_EN,4
	;MOVWF   DATA_EN
	RETURN
    MOSTRAR_LEDS:
	CLRF    LED_BUS
	MOVLW   .3
	SUBWF   ESTADO,W
	BTFSS   STATUS,Z
	GOTO	 RETORNAR_LEDS
	BTFSC   EDIT_IND,0
	BSF	    LED_BUS,7
	BTFSC   EDIT_IND,1
	BSF	    LED_BUS,6
	BTFSC   EDIT_IND,2
	BSF	    LED_BUS,5
	BTFSC   EDIT_IND,3
	BSF	    LED_BUS,4
	MOVF    LED_BUS,W
	BANKSEL PORTD	;carga el dato en PORTD
	MOVWF   PORTD
	BANKSEL PORTC
	BSF	PORTC,4
    RETORNAR_LEDS:
	MOVLW   0x01	;siguiente iteración en el primer display
	MOVWF   DATA_EN
	RETURN
    
MULT25:	    ;Escala la señal de 0 a 255 a una escala de 0 a 100
	BANKSEL	TEMPD_H
	MOVLW	.4
	MOVWF	CONT
	CLRF	TEMPD_H
	MOVF	TEMPB, W
	MOVWF	TEMPD_L
	MOVWF	TEMPD_INIT
    MULT16:
	BCF	STATUS,C
	RLF	TEMPD_H, F
	BCF	STATUS,C
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
	BCF	STATUS, C
	RRF	TEMPD_L, F
	BCF	STATUS, C
	RRF	TEMPD_H, F
	BTFSC	STATUS, C
	BSF	TEMPD_L,7
	DECFSZ	CONT, F
	GOTO	DIVIDIR_64
	CLRF	U_TEMP
	CLRF	D_TEMP
	;CLRF	C_TEMP
	GOTO 	SEPARAR_DATO
    SEPARAR_DATO:	;Separa en unidad, decena y centena la variable TEMPD_L en BCD no empaquetado
	MOVLW   .10
	SUBWF   TEMPD_L,F
	BTFSC   STATUS,C
	GOTO    SUMA_DECENA
	MOVLW   .10
	ADDWF    TEMPD_L,F
	GOTO    GUARDAR
    SUMA_DECENA:
	INCF     D_TEMP,F
	GOTO    SEPARAR_DATO
    GUARDAR:
	MOVF	TEMPD_L, W
	MOVWF	U_TEMP
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
    BANKSEL DELAY
    MOVF    DELAY,F
    BTFSS   STATUS,Z	;verifico que el tiempo de antirebote haya terminado
    GOTO    DECREMENTAR	;si no pasó decremento el conatdor
    BANKSEL PORTB
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
    GOTO    SALIR  
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
EJECUTAR:
    BANKSEL ESTADO
    MOVLW   .3
    SUBWF   ESTADO,W
    BTFSS   STATUS,Z
    GOTO    MOSTRAR_VAR	    ;muestra la variable que corresponda o cambia de estado segun corresponda
    GOTO    EDITAR	    ;busca la acción que tiene que ejecutar
MOSTRAR_VAR:		    ;se accede cuando el estado no sea editando
    MOVF    TECLA,W
    SUBLW   0x0C 
    BTFSC   STATUS,Z ;verifico que sea 12
    GOTO    TECLA_A
    MOVF    TECLA,W
    SUBLW   0x0D
    BTFSC   STATUS,Z ;verifico que sea 13
    GOTO    TECLA_B
    GOTO    RETORNAR
   
EDITAR:	;se accede cuando el estado es editando
    MOVF    TECLA,W
    SUBLW   0x09    ;verifica si la tecla es menor o igual a 9 (números)
    BTFSS   STATUS,C
    GOTO    ENCONTRAR_OPERACION ;si es mayor hay que realizar una operación
    GOTO    ACT_NUM		;sino hay que modificar un número
    
ENCONTRAR_OPERACION:
    MOVLW   0x0A
    SUBWF   TECLA,F
    BTFSC   STATUS,Z	    ;si es 0 la tecla es * (10)
    GOTO    TECLA_ASTERISCO ;funcion de *
    DECF    TECLA,F	    ;le resto uno al resultado, acortando el rango de valores
    BTFSC   STATUS,Z	    ;si es cero la tecla es # (11)
    GOTO    TECLA_NUMERAL   ;funcion de #
    DECF    TECLA,F
    BTFSC   STATUS,Z	    ;si es 0 la tecla es A (12)
    GOTO    RETORNAR	    ;funcion de A, en este caso no hace nada
    DECF    TECLA,F
    BTFSC   STATUS,Z	    ;si es 0 la tecla es B (13)
    GOTO    RETORNAR	    ;función de B, en este caso no hace nada
    DECF    TECLA,F
    BTFSS   STATUS,Z	    ;si es 0 la tecla es C (14)
    GOTO    TECLA_D	    ;si no es cero solo puede ser D (15)
    GOTO    TECLA_C	    ;función de C
    
ACT_NUM:    ;meto el dato numérico (0 a 9) en la variable  correspondiente
    BTFSS   EDIT_IND,2
    GOTO    SIG_ACT_NUM
    MOVF    D_SP_EDIT,W
    IORWF   U_SP_EDIT,W
    BTFSS   STATUS,Z
    GOTO    RETORNAR
    MOVF    TECLA,W
    BTFSC   STATUS,Z
    GOTO    EDITAR_ACT_NUM
    MOVWF   C_SP_AUX
    MOVLW   .1
    SUBWF   C_SP_AUX,F
    BTFSC   STATUS,Z
    GOTO    EDITAR_ACT_NUM
    GOTO    RETORNAR
EDITAR_ACT_NUM:
    MOVF    TECLA,W
    MOVWF   C_SP_EDIT
    GOTO    TECLA_D
SIG_ACT_NUM:
    BTFSC   C_SP_EDIT,0
    GOTO    RETORNAR
    MOVF    TECLA,W
    BTFSC   EDIT_IND,0	;busca la ubicación del cursor
    MOVWF   U_SP_EDIT	;pone el número leído en la variable corresponciente
    BTFSC   EDIT_IND,1
    MOVWF   D_SP_EDIT
    GOTO    TECLA_D
    
TECLA_ASTERISCO:   ;funcion de la tecla *   (confirmar)
    MOVF    U_SP_EDIT,W
    MOVWF   U_SP ;pone los valores anteriores (confirmados) en las variables de edición
    MOVWF   U_SP_AUX
    MOVF    D_SP_EDIT,W
    MOVWF   D_SP
    MOVWF   D_SP_AUX
    MOVF    C_SP_EDIT,W
    MOVWF   C_SP
    MOVLW   .100
    MOVWF   SP
    BTFSC   C_SP_EDIT,0
    GOTO    TERMINAR
    CLRF    SP
    MOVF    D_SP_AUX,F
    BTFSC   STATUS,Z
    GOTO    SUMAR_UN_AST
SUMAR_ASTERISCO:
    MOVLW   .10
    ADDWF   SP,F
    DECFSZ  D_SP_AUX,F
    GOTO    SUMAR_ASTERISCO
SUMAR_UN_AST:
    MOVF    U_SP_AUX,W
    ADDWF   SP,F
TERMINAR:
    MOVLW   .2
    MOVWF   ESTADO  
    CALL    ESCALAR_SP
    GOTO    RETORNAR

TECLA_NUMERAL:	;función de la tecla #	(cancelar)
    MOVF    U_SP,W
    MOVWF   U_SP_EDIT ;pone los valores anteriores (confirmados) en las variables de edición
    MOVF    D_SP,W
    MOVWF   D_SP_EDIT
    MOVF    C_SP,W
    MOVWF   C_SP_EDIT
    MOVLW   .2
    MOVWF   ESTADO  
    GOTO    RETORNAR
    
TECLA_A:    ;funcion de A (cambiar de estado)
    BTFSS   ESTADO, 0
    GOTO    SALTO_A	
    BTFSS   ESTADO, 1
    CLRF    ESTADO
    GOTO    RETORNAR
SALTO_A:
    MOVLW   .1
    MOVWF   ESTADO
    GOTO    RETORNAR

TECLA_B: ;función de B (cambiar de estado)
    BTFSS   ESTADO,1
    GOTO    SALTO_B
    MOVLW   .3
    MOVWF   ESTADO
    MOVLW   .4
    MOVWF   EDIT_IND
    GOTO    RETORNAR
SALTO_B:
    MOVLW   .2
    MOVWF   ESTADO
    GOTO    RETORNAR 
    
TECLA_C:    ;función de tecla C (desplazar izq)
    BCF	    STATUS,C
    RLF	    EDIT_IND
    BTFSS   EDIT_IND,3
    GOTO    RETORNAR
    MOVLW   .1
    MOVWF   EDIT_IND
    GOTO    RETORNAR

TECLA_D:    ;función de tecla D (desplazar der)
    BCF	    STATUS,C
    RRF	    EDIT_IND
    MOVF    EDIT_IND,F
    BTFSS   STATUS,Z
    GOTO    RETORNAR
    MOVLW   .4
    MOVWF   EDIT_IND
    GOTO    RETORNAR
    
RETORNAR:   ;reestablece las variables y retorna
    CLRF    TECLA   ;borro la tecla
    BCF	    CONTROL,TECLA_ASIGNADA  ;bajo la bandera
    RETURN
	
ESCALAR_SP:
    ;----------
    ; SP_ADC = 2*SP
    ;----------
    BANKSEL SP_TMP_H
    CLRF    SP_TMP_H
    MOVF    SP,W
    MOVWF   SP_TMP_L
    BCF     STATUS,C
    RLF     SP_TMP_L,F
    BTFSC   STATUS,C
    INCF    SP_TMP_H,F
    MOVF    SP_TMP_L,W
    MOVWF   SP_ADC
    
    ;----------
    ; SP_ADC += SP/2
    ;----------

    MOVF    SP,W
    MOVWF   CONT
    BCF     STATUS,C
    RRF     CONT,F
    MOVF    CONT,W
    ADDWF   SP_ADC,F

    ;----------
    ; SP_ADC += SP/16
    ;----------

    MOVF    SP,W
    MOVWF   CONT
    BCF     STATUS,C
    RRF     CONT,F
    BCF     STATUS,C
    RRF     CONT,F
    BCF     STATUS,C
    RRF     CONT,F
    BCF     STATUS,C
    RRF     CONT,F
    MOVF    CONT,W
    ADDWF   SP_ADC,F

    ;----------
    ; Saturación
    ;----------

    BTFSC   STATUS,C
    GOTO    SAT_SP_ADC

    RETURN

SAT_SP_ADC

    MOVLW   0xFF
    MOVWF   SP_ADC

    RETURN	
    
DISP_DUTY:	    ;Escala la señal de 0 a 255 a una escala de 0 a 100
	BANKSEL	DUTY_H
	CLRF	DUTY_H;TEMPD_H
	MOVF	DUTY_AUX,W;TEMPB, W
	MOVWF	DUTY_L;TEMPD_L
	MOVWF	DUTY_INIT;TEMPD_INIT
    MULT16_D:
	RLF	DUTY_L,F    ;HECHO POR JULIAN
	RLF	DUTY_H,F
	BCF	STATUS,C
	RLF	DUTY_L,F
	RLF	DUTY_H,F
	BCF	STATUS,C
	RLF	DUTY_L,F
	RLF	DUTY_H,F
	BCF	STATUS,C
	RLF	DUTY_L,F
	RLF	DUTY_H,F
	BCF	STATUS,C
	MOVLW	.9
	MOVWF	CONT_DUTY	
	GOTO	SUMAR9_D
    SUMAR9_D:
	MOVF	DUTY_INIT,W;TEMPD_INIT,W
	ADDWF	DUTY_L;TEMPD_L, F
	BTFSC	STATUS, C
	INCF	DUTY_H,F;TEMPD_H, F
	DECFSZ	CONT_DUTY;CONT, F
	GOTO	SUMAR9_D
	MOVLW	.6
	MOVWF	CONT_DUTY;CONT
    DIVIDIR_64_D:
	BCF	STATUS, C
	RRF	DUTY_L,F;TEMPD_L, F
	BCF	STATUS, C
	RRF	DUTY_H,F;TEMPD_H, F
	BTFSC	STATUS, C
	BSF	DUTY_L,7;TEMPD_L,7
	DECFSZ	CONT_DUTY;CONT, F
	GOTO	DIVIDIR_64_D
	CLRF	U_DUTY;U_TEMP
	CLRF	D_DUTY;D_TEMP
	CLRF	C_DUTY
	MOVF	DUTY_L,W
	SUBLW	0x64
	BTFSS	STATUS,Z
	GOTO 	SEPARAR_DATO_D
	INCF	C_DUTY,F
	RETURN
    SEPARAR_DATO_D:	;Separa en unidad, decena y centena la variable TEMPD_L en BCD no empaquetado
	MOVLW   .10
	SUBWF   DUTY_L,F;TEMPD_L,F
	BTFSC   STATUS,C
	GOTO    SUMA_DECENA_D
	MOVLW   .10
	ADDWF   DUTY_L,F;TEMPD_L,F
	GOTO    GUARDAR_D
    SUMA_DECENA_D:
	INCF    D_DUTY;D_TEMP,F
	GOTO    SEPARAR_DATO_D
    GUARDAR_D:
	MOVF	DUTY_L,W;TEMPD_L, W
	MOVWF	U_DUTY;U_TEMP
	RETURN
	
	
ORG 0x0300
TABLA:
    ADDWF PCL,F
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
    RETLW b'00111001'	;C
    RETLW b'01100011'	;°
    END
