$mod51

ORG 0000H
ADC_DATA EQU P0                        ; Define Name to Port Pins
ADC_EOC BIT P3.2
ADC_ALE_SC BIT P3.4
ADC_OE BIT P3.5
EN	EQU P3.7
RS	EQU P3.6
LCD EQU P1




            MOV ADC_DATA,#0FFH      ;Assign port 1 as I/P port

            ACALL DELAY
MAIN: 
            ACall ADC_CON        
            MOV P1,A
            SJMP MAIN

;ADC Programming Start

ADC_CON:
            SETB ADC_EOC               ; Make EOC AS Input Port
            CLR ADC_ALE_SC
            CLR ADC_OE
	    
BACK:
            SETB ADC_ALE_SC           ; Give High to Low Pulse to Latch Address and for Start of Conversion
            ACALL DELAY
            CLR ADC_ALE_SC

HERE12:
            JB ADC_EOC,HERE12         ;Wait till ADC Complete Its Task
HERE11:
            JNB ADC_EOC,HERE11        ;After ADC Put Data To Output Signal Goes High Again 
            SETB ADC_OE               ; Set OE High For converted Data to Available on Controller,
            ACALL DELAY               ; For Further Operation
                                    
            MOV A,ADC_DATA            ;Load Data To Acc.
            CLR ADC_OE                ; Save Converted Digital Data on Memory
                                                                                        
            RET   
                       
; Delay 
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

;------------------------------------------------------------------

ORG 00H

ACALL INICIALIZAR_LCD

	MOV R1,#1D
	MOV R7,#0D
	MOV DPTR,#NOME1
ESCREVENDO1:
	MOV A, R7
	MOVC A, @A + DPTR ; MOVE O CONTEÚDO DO ENDEREÇO QUE ESTÁ SENDO PASSADO PARA O ACUMULADOR
	INC R7
	CJNE A, #0,EX_ESCRITA ;ESCREVE UMA LETRA NO LCD
	
;PULANDO LINHA
	CLR RS
	MOV LCD, #0C0H
	SETB EN
	CLR EN
	LCALL TEMPO
	
	MOV R7,#0H
	MOV DPTR,#NOME2
ESCREVENDO2:
	MOV A, R7
	MOVC A, @A + DPTR
	INC R7
	CJNE A,#0,EX_ESCRITA2
	
LOOP:
	JMP LOOP

EX_ESCRITA:
	CLR EN
	SETB RS
	MOV LCD,A
	SETB EN
	CLR EN
	LCALL TEMPO
	JMP ESCREVENDO1
	
EX_ESCRITA2:
	CLR EN
	SETB RS
	MOV LCD,A
	SETB EN
	CLR EN
	LCALL TEMPO
	JMP ESCREVENDO2
	
;*********************************************************************
;FUNÇÃO PARA CONFIGURAR O LCD PARA UM DETERMINADO MODO DE OPERAÇÃO
INICIALIZAR_LCD:
	SETB EN ;HABILITA O LCD
	CLR	 RS	;AJUSTE PARA PASSAR INSTRUÇÃO
	MOV LCD, #38H ; configura para 8 bits a duas linhas
				  ; e a matriz de caracter para 5x7
	CLR EN	;DESABILITA O LCD
	
	;TEMPO PARA O LCD SE AJUSTAR AO COMANDO
	LCALL TEMPO
	
	SETB EN ;HABILITA O LCD
	CLR	 RS	;AJUSTE PARA PASSAR INSTRUÇÃO
	MOV LCD, #38H ; configura para 8 bits a duas linhas
				  ; e a matriz de caracter para 5x7
	CLR EN	;DESABILITA O LCD
	
	;TEMPO PARA O LCD SE AJUSTAR AO COMANDO
	LCALL TEMPO
	
	SETB EN
	CLR RS
	MOV LCD, #0FH ; CURSOR PISCANTE
	CLR EN
	
	LCALL TEMPO
	
	SETB EN
	CLR RS
	MOV LCD, #06H ;CURSOR COM AUTO INCREMENTO PARA A DIREITA
	CLR EN
	
	LCALL TEMPO
	
	SETB EN
	CLR RS
	MOV LCD, #01H ;LIMPA O LCD E COLOCA O CURSOR NA PRIMEIRA POSIÇÃO DO LCD
	CLR EN
	
	LCALL TEMPO
	
RET
	
	
;*****************************************************************************	
; ATRASO DE 2ms	
TEMPO: 
	MOV R0, #250D
	MOV R1, #4D
CONT: DJNZ R0, CONT
	  MOV R0, #248D
	  DJNZ R1,CONT
RET
;*****************************************************************************	  

;NOMES PARA SEREM ESCRITOS	  
NOME1:
	DB 'FELIPE RIBAS',0
NOME2:
	DB 'IAGO ALEKSANDER',0
END

