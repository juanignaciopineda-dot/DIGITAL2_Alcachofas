; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

#include "p16f887.inc"

; CONFIG1
; __config 0x20D9
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_ON & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
 ;Variables//
 
bcdl	    EQU 0x20		;guarda la unidad del numero en BCD
bcdh	    EQU 0x21		;guarda la decena del numero en BCD
cont_aux    EQU 0x22	;variable auxiliar para el delay del pulsador
cont_D	    EQU 0x23		;contador en binario para el byte de leds
control	    EQU 0x25	;bit 0, para cambiar entre unidad y decena
dig	    EQU 0
soltado	    EQU 1
indice	    EQU 0x26
cont1	    EQU 0x27
cont2	    EQU 0x28

ORG 0x00
    GOTO INIT
ORG 0x05
 INIT:
    ;Inicialización de Puertos//
    BANKSEL ANSEL
    CLRF    ANSEL           ; Pone en 0 ANSEL (PORTA y PORTE a modo digital)
    CLRF    ANSELH          ; Pone en 0 ANSELH (PORTB a modo digital)
    BANKSEL TRISD
    CLRF    TRISD           ; TRISD = 0x00 -> Los 8 pines de PORTD como SALIDAS (LEDs)
    BANKSEL TRISB
    MOVLW   0x01
    MOVWF   TRISB	    ; TRISB, bit 0 = 1 -> Pin RB0 como ENTRADA (Pulsador)
			    ; resto de pines como salidas (Display)    
    BANKSEL TRISE
    CLRF    TRISE	    ;TRISE = 0x00 -> los 5 pines del PORTE como SALIDAS (NPN de los Display)
    BANKSEL PORTB
    CLRF    PORTB
    BANKSEL PORTD
    CLRF    PORTD           ; Apaga todos los LEDs al energizar el circuito
    
    
    ;Inicialización de Variables
    CLRF control
    CLRF cont_D
    CLRF bcdl
    CLRF bcdh
    MOVLW 0x09
    MOVWF cont_aux
    CLRF indice
    CLRF cont1
    CLRF cont2
    
  MAIN:
    BTFSS PORTB,0	    ;si el botón se presinó va a la rutina BOTONPRESINADO
    CALL BOTONPRESIONADO
    BTFSC PORTB,0	    ;verifica si se soltó el pulsador
    BCF control,soltado	    ;pone en cero soltado (terminó la pulsación)
    CALL LOOPDISPLAY	    ;llama a la rutina LOOPDISPLAY
    GOTO MAIN	    
    
  BOTONPRESIONADO:    
    DECFSZ cont_aux	    ;si es 0 decrementa la variable aux en 1 
    RETURN
    BTFSS control,soltado
    CALL INCREMENTAR	    ;cuando llegue a 0 (ya se decrementó 10 veces) llama a incrementar ;debería ser 0x0B para que decremente 10 veces
    RETURN 
  
  INCREMENTAR:
    BSF	    control,soltado ;espera hasta soltar el botón
    MOVLW   0x09	    ;reinicia el cont_aux a 9
    MOVWF   cont_aux	    
    INCF    cont_D,f	    ;incrementa en uno cont_D
    MOVLW   0x64	    
    SUBWF   cont_D,W	    ;si Cont_D llega a 100 lo pone en 0 ;le está restando a cont_d , hay que usar un avariable auxiliar
    BTFSC   STATUS,Z
    CLRF    cont_D
    INCF    bcdl,f	    ;incrementa en 1 BCDL (unidad)
    MOVLW   0x0A	     
    SUBWF   bcdl,W	    ;si BCDL es 10 lo pone en 0 y suma uno a BCDH, sino retorna
    BTFSS   STATUS,Z	    
    RETURN
    CLRF    bcdl
    INCF    bcdh,f
    MOVLW   0x0A	    
    SUBWF   bcdh,W	    ;si BCDH llega a 10 lo pone en 0 y luego retorna
    BTFSC   STATUS,Z
    CLRF    bcdh
    RETURN
    
  LOOPDISPLAY:
    BANKSEL indice	    ;guarda la parte alta de la dirección de la tabla
    MOVLW   HIGH TABLA
    MOVWF   PCLATH
    BANKSEL PORTE
    CLRF    PORTE	    ;apaga los displays
    BTFSS   control,dig	    ;si dig esta en 0 mueve BCDL a W
    MOVF    bcdl,w
    BTFSC   control,dig	    ;si dig esta en 1 mueve BCDL a W
    MOVF    bcdh,w
    CALL    TABLA
    
    BANKSEL PORTB
    MOVWF PORTB
    BTFSS   control,dig	    ;si dig esta en 0 enciente el 7 seg de la unidad
    BSF	    PORTE,0
    BTFSC   control,dig	    ;si dig esta en 1 enciende el 7 seg de la decena
    BSF	    PORTE,1
    
    MOVLW   0x01	    ;complemento el bit 0 de la variable dig
    XORWF   control,f
    
    BANKSEL PORTD	    ;actualiza el valor del contador binario en el byte de leds
    MOVF    cont_D, w
    MOVWF   PORTD
    
    ;CALL DELAY5MS
    RETURN
    
  DELAY5MS:
    MOVLW 0x0A       ; cont1 = 10
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