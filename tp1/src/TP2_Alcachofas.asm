PROCESSOR 16F887
    ; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>

  
//Variables//
    cont1 EQU 0x20
    cont2 EQU 0x21
    cont5s EQU 0x22
    var EQU 0x23
    estado EQU 1
    action EQU 0
    cont_aux EQU 0x24

PSECT resetVec, class=CODE, delta=2, abs
ORG 0x00
    PAGESEL MAIN
    GOTO MAIN
PSECT code, class=CODE, delta=2
;Acá se va a realizar toda la lógica del programa llamando
;a las subrutinas y entrando en el modo "Luces" o "Contador"
;dependiendo del estado de un bit aux
;bit ESTADO(1) de var en 0 = modo contador
;bit ESTADO(1) de var en 1 = modo luces
;bit ACTION(0) de var en 0 = en luces pausa la secuencia y en contador no hace nada
;bit ACTION(0) de var en 1 = en luces continua la secuencia y en contador incrementa en 1
 
ORG 0x05
MAIN:
    ;Inicialización de puertos
    BANKSEL ANSEL
    CLRF    ANSEL           ; Pone en 0 ANSEL (PORTA y PORTE a modo digital)
    CLRF    ANSELH          ; Pone en 0 ANSELH (PORTB a modo digital)
    BANKSEL TRISD
    CLRF    TRISD           ; TRISD = 0x00 -> Los 8 pines de PORTD como SALIDAS (LEDs)
    BANKSEL TRISB
    BSF     TRISB, 0        ; TRISB, bit 0 = 1 -> Pin RB0 como ENTRADA (Pulsador)
    BANKSEL PORTD
    CLRF    PORTD           ; Apaga todos los LEDs al energizar el circuito
    ;inicialización de variables
    CLRF var
    CLRF cont_aux
    
CONTADOR:
    BTFSC var, estado	    ;verifica si está en modo Contador
	GOTO LUCES	    ;si lo está salta esta linea y ejecuta el modo Contador
    CALL BOTONPRESIONADO    ;está presionado?
    BTFSC var,action	    ;si el bit está en 0 no incrementa
    CALL INCREMENTAR	    ;incrementa en 1 el contador
    CALL DELAY50MS	    ;espera 50ms
    GOTO CONTADOR

INCREMENTAR:
    INCF cont_aux, F	    ;incrementa en 1 el contador de leds
    MOVF cont_aux, W	    ;cargo la variable en W
    MOVWF PORTD		    ;aplico los valores del contador en el puerto D
    BCF var,action
    GOTO CONTADOR
    
LUCES:
    MOVLW 0x01		    
    MOVWF PORTD		    ;Se enciende el primer led de la secuencia de luces
    
    DESPLAZAMIENTO:
    
    BTFSS var, estado	    ;verifica si está en modo Luces
	GOTO CONTADOR	    ;si lo está saltea esta linea y ejecuta el modo Luces
    CALL BOTONPRESIONADO    ;está presionado?
    
    BTFSC var,action	    ;si el bit action está en 1
	RRF	PORTD,F		    ;desplaza todo el bit a la derecha
    CALL DELAY50MS
    CALL DELAY50MS
    GOTO DESPLAZAMIENTO		    ;retorna a LUCES para no variar el estado de las luces (Pausa)	    ;retorna a LUCES para no variar el estado de las luces (Pausa)

BOTONPRESIONADO:	;|cambia el valor del bit ACTION si se presiona, y si se presiona|
    			;|durante mas de 5 segundos cambia el valor del bit ESTADO       |
    BTFSC PORTB, 0	;Si el boton no está presionado retorna
	RETURN
    CALL DELAY50MS	    ;delay antirrebote
    MOVLW 0x63		    ;para hacer 5 s se multiplica Delay x ,
    MOVWF cont5s
    
    BUCLE_ESPERA:
	BTFSC PORTB, 0	    ;si ya se soltó el boton va a la subrutina de boton soltado
	    GOTO BOTON_SOLTADO
	CALL DELAY50MS
	DECFSZ cont5s, F    ;hasta que llegue a 0, espera un tiempo (ni idea cual es)
	    GOTO BUCLE_ESPERA
    
    MOVLW 0x02
    XORWF var,F		    ;Si contó los 5 segundos y sigue presionado se invierte el bit de ESTADO
    CLRF PORTD		    ;Apago todos los leds
    CLRF cont_aux	    ;Contador en 0
    
    ESPERAR_HASTA_SOLTAR:	    ;espera hasta que el boton efectivamente se suelte
	CALL DELAY50MS
	BTFSS PORTB,0
	GOTO ESPERAR_HASTA_SOLTAR
	BTFSS var,estado	    
	GOTO CONTADOR		    ;si el bit estado está en 0 va a contador
	GOTO LUCES		    ;si el bit estado está en 1 va a luces

    BOTON_SOLTADO:
	MOVLW 0x01
	BTFSS var,estado    ;si el sistema está en estado contador
	BSF var,action	    ;pone en 1 el bit de acción para que el main haga el cambio
	BTFSC var,estado    ;si el sistema está en estado luces
	XORWF var,F	    ;invierte el valor del bit action
	CALL DELAY50MS
	RETURN
	
DELAY50MS:

    MOVLW 0x63       ; cont1 = 99
    MOVWF cont1	     
INICIO_D:
    MOVLW 0xA7       ; cont2 = 167
    MOVWF cont2
LOOP:
    DECFSZ cont2,F	; Cuento desde 167 a 0
    GOTO LOOP
    DECFSZ cont1,F	; disminuyo en 1 cont1 y vuelvo a LOOP
    GOTO INICIO_D
    RETURN