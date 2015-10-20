$mod51

ADC_DATA EQU P0                        ; Define Name to Port Pins
ADC_EOC BIT P3.2
ADC_ALE_SC BIT P3.4
ADC_OE BIT P3.5

LCD EQU P1
EN	EQU P3.7
RS	EQU P3.6

ORG 0000H
	SJMP INICIO

ORG 0Bh
	cpl P3.1		;complementa o clock (P3.1)
	reti



ORG 0030H
INICIO:
        MOV ADC_DATA,#0FFH      	;Assign port 1 as I/P port     
	    ACall INICIALIZAR_LCD
        ACALL DELAY

	;habilitacao das interrupcoes	
	mov ie,#10000011b	;habilitacao da interrupcao INT0 e do timer0	
	mov ip,#00000010b	;prioridade maxima para interrupcao do timer0	
	;setb it0

	;timer_0 configurado para gerar interrupcao, clock interno e modo auto-reload
	mov tmod,#00001010b
	mov tl0,#0FDh		;contagem de apenas 2us	
	mov th0,#0FDh		;valor de reload para o timer 
	mov r0,#030h		;move para r0 30h	
	setb tr0		;inicia contagem de tempo, alternancia do sinal a cada 1us

;*********************************************************************	    
MAIN: 

            ACALL ADC_CON        
            ACALL DATA_LCD
            SJMP MAIN

;*********************************************************************
;ADC Programming Start
	
ADC_CON:
            SETB ADC_EOC              ; Make EOC AS Input Port
            CLR ADC_ALE_SC
            CLR ADC_OE
	    
BACK:
            SETB ADC_ALE_SC           ; Give High to Low Pulse to Latch Address and for Start of Conversion
            ACALL DELAY
            CLR ADC_ALE_SC

HERE12:
            JB ADC_EOC,HERE12         ; Wait till ADC Complete Its Task
HERE11:
            JNB ADC_EOC,HERE11        ; After ADC Put Data To Output Signal Goes High Again 
            SETB ADC_OE               ; Set OE High For converted Data to Available on Controller,
            ACALL DELAY               ; For Further Operation
                                    
            MOV A,ADC_DATA            ; Load Data To Acc.
            CLR ADC_OE                ; Save Converted Digital Data on Memory
                                                                                        
            RET   
                       

;*********************************************************************
;inicializar lcd e configura-lo

INICIALIZAR_LCD:

	SETB EN 	; habilita o lcd
	CLR	 RS	; ajuste para passar instrucao
	MOV LCD, #38H 	; configura para 8 bits a duas linhas
			; e a matriz de caracter para 5x7

	CLR EN		;desabilita o lcd
	
	LCALL TEMPO	;a short delay
	
	SETB EN 	
	CLR	 RS	
	MOV LCD, #38H 	
			
	CLR EN		
	
	LCALL TEMPO	
	
	SETB EN
	CLR RS
	MOV LCD, #0EH 	; modo cursor piscante
	CLR EN	
	
	LCALL TEMPO
	
	SETB EN
	CLR RS
	MOV LCD, #06H 	; modo cursor com auto incremento para a direita
	CLR EN
	
	LCALL TEMPO
	
	SETB EN
	CLR RS
	MOV LCD, #01H 	; limpa o lcd e coloca o cursor na primeira posicao
	CLR EN
	
	LCALL TEMPO
	
RET

;*****************************************************************************		
; App. 243 µ Sec.

DELAY:        
            MOV R3,#1
HERE1:
            MOV R1,#10
HERE2:
            MOV R2,#10
HERE3:
            DJNZ R2,HERE3
            DJNZ R1,HERE2
            DJNZ R3,HERE1
            
	    RET
	
;*****************************************************************************	
; atraso de 2ms	

TEMPO: 
	MOV R0, #250D
	MOV R1, #4D
CONT: 	DJNZ R0, CONT
	MOV R0, #248D
	DJNZ R1,CONT
	
	RET

;*****************************************************************************	
; limpar tela

DATA_LCD:
	
	SETB EN
	CLR RS
	MOV LCD, #01H 	; limpa o lcd e coloca o cursor na primeira posicao
	CLR EN

;*****************************************************************************		        
; converter dados lidos em binario para decimal e transferir para o lcd (faixa de valores de 0 a 9)

BINARY_TO_BCD:

	SETB RS          ;Telling the LCD that the data which is being send is to be displayed

;tabela de enderecos para os numeros
	
	MOV 030h,30		;0		
	MOV 031h,31		;1		
	MOV 032h,32		;2
	MOV 033h,33		;3	
	MOV 034h,34		;4
	MOV 035h,35		;5	
	MOV 036h,36		;6	
	MOV 037h,37		;7	
	MOV 038h,38		;8
	MOV 039h,39		;9

	MOV R6,#030h	;move para R6 30h	
	MOV R5, #00h	;contador inicia com o numero 0
	
VERIFICA:
	SUBB A, #26 	;subtrair acumulador de 26 com o limite inferior	
	JC FINISH
	INC R5
	SJMP VERIFICA 

FINISH:	
	;soma número desejado + endereço base da tabela de número	
	mov A, R6	
	add A, R5	

	MOV P1, A
	SETB EN         
	ACALL TEMPO 	
	CLR   EN 

	MOV R7, 6

ESPERA:
	ACALL TEMPO
	DJNZ R7, ESPERA


;*****************************************************************************		        
; converter dados lidos em binario para decimal e transferir para o lcd (de 0 a 255 - nao usado)
	
;	MOV B, #64h	; 100
;	DIV AB		;/ 100 
;	MOV R5, A	; store cents in R5 
;	MOV A, B	; get remainder 
;	MOV B, #0AH	; 10
;	DIV AB		; / 10
;	MOV R7, A	; save tens in R7 
;	MOV A, B	; get units
;	MOV R6,A	; save units in R6


;	MOV A, R5 
;	ADD A, #30h 

;	MOV P1, A
;	SETB EN         ;EN is High
;	ACALL TEMPO    	;a short delay    	
;	CLR   EN        ;EN is low to make a  high-low pulse 

;	MOV A, R7 
;	ADD A, #30h 

;	MOV P1, A
;	SETB EN         
;	ACALL TEMPO  	
;	CLR   EN        
	
;	MOV A, R6 
;	ADD A, #30h  
    

RET 		; return to main

END