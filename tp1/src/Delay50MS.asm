cont1 EQU 0x20
cont2 EQU 0x21
cont5s EQU 0x22
var EQU 0x23
estado EQU 0
action EQU 1
cont_aux EQU 0x24

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
 
CLRF var
CLRF cont_aux
 
;Acá se va a realizar toda la lógica del programa llamando
;a las subrutinas y entrando en el modo "Luces" o "Contador"
;dependiendo del estado de un bit aux
;bit ESTADO(1) de var en 0 = modo contador
;bit ESTADO(1) de var en 1 = modo luces
;bit ACTION(0) de var en 0 = en luces pausa la secuencia y en contador no hace nada
;bit ACTION(0) de var en 1 = en luces continua la secuencia y en contador incrementa en 1
 
MAIN:
    
    
CONTADOR:
    BTFSC var, 0	    ;verifica si está en modo Contador
	GOTO LUCES	    ;si lo está salta esta linea y ejecuta el modo Contador
    ;lógica de contador
    CALL BOTONPRESIONADO    ;está presionado?
    BTFSC var,action	;si el bit está en 0 no incrementa
    CALL INCREMENTAR	;incrementa en 1 el contador
	
	CALL DELAY50MS	    ;espera 200ms
	CALL DELAY50MS
	CALL DELAY50MS
	CALL DELAY50MS
    GOTO CONTADOR

INCREMENTAR:
    INCF cont_aux, F    ;incrementa en 1 el contador de leds
    MOVF cont_aux, W	    ;cargo la variable en W
    MOVWF PORTD	    ;aplico los valores del contador en el puerto D

LUCES:
    
    BTFSS var, 0	    ;verifica si está en modo Luces
	GOTO CONTADOR	    ;si lo está saltea esta linea y ejecuta el modo Luces
    CALL BOTONPRESIONADO    ;está presionado?
    ;lógica de luces
    
    GOTO LUCES



BOTONPRESIONADO:	;cambia el valor del bit ACTION si se presiona, y si se presiona
    			;durante mas de 5 segundos cambia el valor del bit ESTADO
    BTFSC PORTB, 0	;Si el boton no está presionado retorna
    RETURN
    
    
    MOVLW 0x64	    ;para hacer 5 s se multiplica Delay x 100,
    MOVWF cont5s
    
    BUCLE_ESPERA:
	DECFSZ cont5s, F    ;hasta que llegue a 0
	GOTO BUCLE_ESPERA
	;si el boton está presionado mas tiempo entonces se cambia el estado del bit ESTADO de VAR
	;y dependiendo de su valor retorna a uno de los 2 estados (Completar)
	    
	
    
    
    
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


