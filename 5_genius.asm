$mod51

; start switch
start_sw	EQU	P3.0

; input switches
red_sw		EQU	P2.0
green_sw	EQU	P2.1
yellow_sw	EQU	P2.2
blue_sw		EQU	P2.3

; output LED's
red_led		EQU	P2.4
green_led	EQU	P2.5
yellow_led	EQU	P2.6
blue_led	EQU	P2.7

; status LCD
LCD 		EQU P1
EN			EQU P3.7
RS			EQU P3.6
	
counter		EQU	30h
input_val	EQU	31h
data_x		EQU	40h

ORG	00h
	AJMP	START

ORG	03h
	RETI

ORG	0bh
	RETI

ORG	13h
	RETI

ORG	1bh
	RETI

ORG	23h
	RETI

ORG	25h
	RETI

;delays
DELAY_SHORT:
	MOV	r7, #0ffh
	DJNZ	r7, $
	RET

DELAY_MEDIUM:
	MOV	r6, #0ffh
LOOP_DELAY_MEDIUM:
	ACALL	delay_short
	DJNZ	r6, loop_delay_medium
	RET

DELAY_LONG:
	MOV	r5, #04h
LOOP_DELAY_LONG:
	ACALL	delay_medium
	DJNZ	r5, loop_delay_long
	RET

; atraso de 2ms	
TEMPO: 
	MOV R0, #250D
	MOV R1, #4D
CONT:
 	DJNZ R0, CONT
	MOV R0, #248D
	DJNZ R1,CONT	
	RET

; lcd prints looser
; to be used after incorrect input sequence
FLASH_WRONG:
	ACALL LIMPA_LCD

	MOV R6, A

	MOV R7,#0D
	MOV DPTR,#NOME1
	LCALL TEMPO
ESCREVENDO1:
	LCALL DATA_LCD
	CJNE A, #0,EX_ESCRITA1 ;ESCREVE UMA LETRA NO LCD

;PULANDO LINHA
	CLR RS
	MOV LCD, #0C0H
	SETB EN
	CLR EN
	LCALL TEMPO

	MOV R7,#0H
	MOV DPTR,#NOME4
	LCALL TEMPO
ESCREVENDO1_2:
	LCALL DATA_LCD
	CJNE A,#0,EX_ESCRITA1_2

	MOV A, R6
	RET

EX_ESCRITA1:
	LCALL DATA_LCD2
	JMP ESCREVENDO1

EX_ESCRITA1_2:
	LCALL DATA_LCD2
	JMP ESCREVENDO1_2
	
; lcd prints correct
; to be used after every correct user input sequence
FLASH_RIGHT:
	ACALL LIMPA_LCD

	MOV R6, A

	MOV R7,#0D
	MOV DPTR,#NOME2
	LCALL TEMPO
ESCREVENDO2:
	LCALL DATA_LCD
	CJNE A, #0,EX_ESCRITA2 ;ESCREVE UMA LETRA NO LCD

;PULANDO LINHA
	CLR RS
	MOV LCD, #0C0H
	SETB EN
	CLR EN
	LCALL TEMPO

	MOV R7,#0H
	MOV DPTR,#NOME5
	LCALL TEMPO
ESCREVENDO2_2:
	LCALL DATA_LCD
	CJNE A,#0,EX_ESCRITA2_2

	MOV A,R3
	CLR EN
	SETB RS
	MOV LCD,A
	SETB EN
	CLR EN
	LCALL TEMPO

	MOV A, R6
	RET

EX_ESCRITA2:
	LCALL DATA_LCD2
	JMP ESCREVENDO2

EX_ESCRITA2_2:
	LCALL DATA_LCD2
	JMP ESCREVENDO2_2
	
; lcd prints winner
; to be used after counter is maxed out
FLASH_WIN:
	ACALL LIMPA_LCD

	MOV R6, A

	MOV R7,#0D
	MOV DPTR,#NOME3
	LCALL TEMPO
ESCREVENDO3:
	LCALL DATA_LCD
	CJNE A, #0,EX_ESCRITA3 ;ESCREVE UMA LETRA NO LCD

;PULANDO LINHA
	CLR RS
	MOV LCD, #0C0H
	SETB EN
	CLR EN
	LCALL TEMPO

	MOV R7,#0H
	MOV DPTR,#NOME4
	LCALL TEMPO
ESCREVENDO3_2:
	LCALL DATA_LCD
	CJNE A,#0,EX_ESCRITA3_2

	MOV A, R6
	RET

EX_ESCRITA3:
	LCALL DATA_LCD2
	JMP ESCREVENDO3

EX_ESCRITA3_2:
	LCALL DATA_LCD2
	JMP ESCREVENDO3_2

; flash the red led
FLASH_RED:
	CLR		red_led
	ACALL	DELAY_LONG
	SETB	red_led
	RET

; flash the green led
FLASH_GREEN:
	CLR		green_led
	ACALL	DELAY_LONG
	SETB	green_led
	RET

; flash the yellow led
FLASH_YELLOW:
	CLR		yellow_led
	ACALL	DELAY_LONG
	SETB	yellow_led
	RET

; flash the blue led
FLASH_BLUE:
	CLR		blue_led
	ACALL	DELAY_LONG
	SETB	blue_led
	RET

; add extra random byte to data sequence
ADD_RANDOM:
	MOV	A, #data_x
	ADD	A, counter
	MOV	R0, A
	MOV	A, TL0

	; divide timer value by 2 - fix odd/even issues
	MOV	B, #02h
	DIV	AB

	; isolate lowest 2 bits (random byte will be 0 - 3)
	MOV	B, #040h	
	MUL	AB
	MOV	B, #040h
	DIV	AB

	MOV	@R0, A
	INC	counter
	RET

; read input switch
; store value in input_val
; input_val is modified as follows:
; 0 - red switch was pressed
; 1 - green switch was pressed
; 2 - yellow switch was pressed
; 3 - blue switch was pressed
READ_SWITCH:
	JNB	red_sw, RED_SW_WAIT_RELEASE
	JNB	green_sw, GREEN_SW_WAIT_RELEASE
	JNB	yellow_sw, YELLOW_SW_WAIT_RELEASE
	JNB	blue_sw, BLUE_SW_WAIT_RELEASE
	AJMP	READ_SWITCH

RED_SW_WAIT_RELEASE:
	JB		red_sw, RED_SW_INPUT
	AJMP	RED_SW_WAIT_RELEASE

GREEN_SW_WAIT_RELEASE:
	JB		green_sw, GREEN_SW_INPUT
	AJMP	GREEN_SW_WAIT_RELEASE

YELLOW_SW_WAIT_RELEASE:
	JB		yellow_sw, YELLOW_SW_INPUT
	AJMP	YELLOW_SW_WAIT_RELEASE

BLUE_SW_WAIT_RELEASE:
	JB		blue_sw, BLUE_SW_INPUT
	AJMP	BLUE_SW_WAIT_RELEASE

RED_SW_INPUT:
	MOV	input_val, #00h
	RET

GREEN_SW_INPUT:
	MOV	input_val, #01h
	RET

YELLOW_SW_INPUT:
	MOV	input_val, #02h
	RET

BLUE_SW_INPUT:
	MOV	input_val, #03h
	RET
	
; flash entire sequence of data
FLASH_SEQUENCE:
	MOV	R0, #00h
FLASH_SEQUENCE_LOOP:
	MOV	A, counter
	SUBB	A, R0
	JZ	FLASH_SEQUENCE_LOOP_END
	
	MOV	A, #data_x
	ADD	A, R0
	MOV	R1, A
	MOV	A, @R1

	; if data is 0 - flash red led
	JZ	FLASH_SEQUENCE_RED
	
	; if data is 1 - flash green led
	SUBB	A, #01h
	JZ	FLASH_SEQUENCE_GREEN

	; if data is 2 - flash yellow led
	SUBB	A, #01h
	JZ	FLASH_SEQUENCE_YELLOW
	
	; else (data is 3) - flash blue led
	AJMP	FLASH_SEQUENCE_BLUE
	
FLASH_SEQUENCE_RED:
	ACALL	FLASH_RED
	AJMP	FLASH_SEQUENCE_OVER

FLASH_SEQUENCE_GREEN:
	ACALL	FLASH_GREEN
	AJMP	FLASH_SEQUENCE_OVER

FLASH_SEQUENCE_YELLOW:
	ACALL	FLASH_YELLOW
	AJMP	FLASH_SEQUENCE_OVER

FLASH_SEQUENCE_BLUE:
	ACALL	FLASH_BLUE

FLASH_SEQUENCE_OVER:
	ACALL	DELAY_MEDIUM
	INC	R0
	AJMP	FLASH_SEQUENCE_LOOP

FLASH_SEQUENCE_LOOP_END:
	RET

; read switch and compare user input to stored data
ACCEPT_INPUT:
	MOV	R0, #00h	
	MOV	R4, #00h
ACCEPT_INPUT_LOOP:
	MOV	A, counter
	SUBB	A, R0
	JZ	ACCEPT_INPUT_LOOP_END

	ACALL	READ_SWITCH
	
	MOV	A, #data_x
	ADD	A, R0
	MOV	R1, A
	MOV	A, @R1
	
	SUBB	A, INPUT_VAL
	JZ	ACCEPT_INPUT_LOOP_CONT
	MOV	R4, #01h
	AJMP	ACCEPT_INPUT_LOOP_END

ACCEPT_INPUT_LOOP_CONT:

	INC	R0
	AJMP	ACCEPT_INPUT_LOOP

ACCEPT_INPUT_LOOP_END:
	RET

INIT:
	; timer 0 - 16 bit mode
	MOV	TMOD, #01h
	SETB	TR0
	
	MOV	PSW, #00h
	MOV	IE, #00h

	; initialize counter
	MOV	counter, #00h

	RET

START:
	ACALL	INIT
	ACall	INICIALIZAR_LCD

	MOV R6, A
	MOV R7,#0D
	MOV DPTR,#NOME4
	LCALL TEMPO
ESCREVENDO:
	LCALL DATA_LCD
	CJNE A, #0,EX_ESCRITA ;ESCREVE UMA LETRA NO LCD
	MOV A, R6
	ACALL WAIT_START_SW
EX_ESCRITA:
	LCALL DATA_LCD2
	JMP ESCREVENDO
	
; wait for user to press and release start switch
WAIT_START_SW:
	jb	start_sw, $
	jnb	start_sw, $

; wait for user to press and release dificult switch

	ACALL LIMPA_LCD
	MOV R6, A
	MOV R7,#0D
	MOV DPTR,#NOME6
	LCALL TEMPO
ESCOLHENDO:
	LCALL DATA_LCD
	CJNE A, #0,EX_ESCOLHA ;ESCREVE UMA LETRA NO LCD

;PULANDO LINHA
	CLR RS
	MOV LCD, #0C0H
	SETB EN
	CLR EN
	LCALL TEMPO

	MOV R7,#0H
	MOV DPTR,#NOME7
	LCALL TEMPO
ESCOLHENDO_2:
	LCALL DATA_LCD
	CJNE A,#0,EX_ESCOLHA_2

	MOV A, R6
	ACALL DIFICULDADE

EX_ESCOLHA:
	LCALL DATA_LCD2
	JMP ESCOLHENDO

EX_ESCOLHA_2:
	LCALL DATA_LCD2
	JMP ESCOLHENDO_2

DIFICULDADE:
	JNB	red_sw, FACIL
	JNB	green_sw, MEDIO
	JNB	yellow_sw, DIFICIL
	JNB	blue_sw, EXTREMO
	SJMP DIFICULDADE

FACIL:
	ACALL MOSTRAR_FACIL
	MOV R2, #8
	ACALL COMECAR
MEDIO:
	ACALL MOSTRAR_MEDIO
	MOV R2, #14
	ACALL COMECAR
DIFICIL:
	ACALL MOSTRAR_DIFICIL
	MOV R2, #20
	ACALL COMECAR
EXTREMO:
	ACALL MOSTRAR_EXTREMO
	MOV R2, #31

COMECAR:
	ACALL	DELAY_LONG
	ACALL	DELAY_LONG

	ACALL LIMPA_LCD

	MOV R6, A
	MOV R7,#0D
	MOV DPTR,#NOME12
	LCALL TEMPO
COMECANDO:
	LCALL DATA_LCD
	CJNE A, #0,EX_COMECAR ;ESCREVE UMA LETRA NO LCD

	MOV A, R6
	ACALL LOOP

EX_COMECAR:
	LCALL DATA_LCD2
	JMP COMECANDO

LOOP:
	ACALL	DELAY_LONG
	ACALL	DELAY_LONG

	ACALL	ADD_RANDOM
	ACALL	FLASH_SEQUENCE
	ACALL	ACCEPT_INPUT
	
	ACALL	DELAY_LONG
	ACALL	DELAY_LONG

	MOV	A, R4
	JZ	CONT1
	
	ACALL	FLASH_WRONG
	MOV	counter, #00h
	AJMP	WAIT_START_SW
	
CONT1:
	MOV	A, counter
	ADD A, #48
	MOV R3, A
	SUBB A, #48
	SUBB A, R2
	JNZ	 CONT2  ; sera um vencedor acertando 10 vezes
	
	ACALL	FLASH_WIN
	MOV	counter, #00h
	AJMP	WAIT_START_SW

CONT2:
	ACALL	FLASH_RIGHT
	ACALL	DELAY_LONG
	AJMP	LOOP

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
; limpar tela

LIMPA_LCD:
	
	SETB EN
	CLR RS
	MOV LCD, #01H 	; limpa o lcd e coloca o cursor na primeira posicao
	CLR EN
	RET

;*****************************************************************************	
; escreve

DATA_LCD:
	MOV A, R7
	MOVC A, @A + DPTR ; MOVE O CONTEÚDO DO ENDEREÇO QUE ESTÁ SENDO PASSADO PARA O ACUMULADOR
	INC R7
	RET

DATA_LCD2:
	CLR EN
	SETB RS
	MOV LCD,A
	SETB EN
	CLR EN
	LCALL TEMPO
	RET

;*****************************************************************************
; exibindo dificuldade escolhida

MOSTRAR_FACIL:
	ACALL LIMPA_LCD
	MOV R6, A
	MOV R7,#0D
	MOV DPTR,#NOME6
	LCALL TEMPO
ESCOLHENDO_FACIL:
	LCALL DATA_LCD
	CJNE A, #0,EX_FACIL ;ESCREVE UMA LETRA NO LCD

;PULANDO LINHA
	CLR RS
	MOV LCD, #0C0H
	SETB EN
	CLR EN
	LCALL TEMPO

	MOV R7,#0H
	MOV DPTR,#NOME8
	LCALL TEMPO
ESCOLHENDO_FACIL_2:
	LCALL DATA_LCD
	CJNE A,#0,EX_FACIL_2

	MOV A, R6
	RET

EX_FACIL:
	LCALL DATA_LCD2
	JMP ESCOLHENDO_FACIL

EX_FACIL_2:
	LCALL DATA_LCD2
	JMP ESCOLHENDO_FACIL_2

MOSTRAR_MEDIO:
	ACALL LIMPA_LCD
	MOV R6, A
	MOV R7,#0D
	MOV DPTR,#NOME6
	LCALL TEMPO
ESCOLHENDO_MEDIO:
	LCALL DATA_LCD
	CJNE A, #0,EX_MEDIO ;ESCREVE UMA LETRA NO LCD

;PULANDO LINHA
	CLR RS
	MOV LCD, #0C0H
	SETB EN
	CLR EN
	LCALL TEMPO

	MOV R7,#0H
	MOV DPTR,#NOME9
	LCALL TEMPO
ESCOLHENDO_MEDIO_2:
	LCALL DATA_LCD
	CJNE A,#0,EX_MEDIO_2

	MOV A, R6
	RET

EX_MEDIO:
	LCALL DATA_LCD2
	JMP ESCOLHENDO_MEDIO

EX_MEDIO_2:
	LCALL DATA_LCD2
	JMP ESCOLHENDO_MEDIO_2

MOSTRAR_DIFICIL:
	ACALL LIMPA_LCD
	MOV R6, A
	MOV R7,#0D
	MOV DPTR,#NOME6
	LCALL TEMPO
ESCOLHENDO_DIFICIL:
	LCALL DATA_LCD
	CJNE A, #0,EX_DIFICIL ;ESCREVE UMA LETRA NO LCD

;PULANDO LINHA
	CLR RS
	MOV LCD, #0C0H
	SETB EN
	CLR EN
	LCALL TEMPO

	MOV R7,#0H
	MOV DPTR,#NOME10
	LCALL TEMPO
ESCOLHENDO_DIFICIL_2:
	LCALL DATA_LCD
	CJNE A,#0,EX_DIFICIL_2

	MOV A, R6
	RET

EX_DIFICIL:
	LCALL DATA_LCD2
	JMP ESCOLHENDO_DIFICIL

EX_DIFICIL_2:
	LCALL DATA_LCD2
	JMP ESCOLHENDO_DIFICIL_2

MOSTRAR_EXTREMO:
	ACALL LIMPA_LCD
	MOV R6, A
	MOV R7,#0D
	MOV DPTR,#NOME6
	LCALL TEMPO
ESCOLHENDO_EXTREMO:
	LCALL DATA_LCD
	CJNE A, #0,EX_EXTREMO ;ESCREVE UMA LETRA NO LCD

;PULANDO LINHA
	CLR RS
	MOV LCD, #0C0H
	SETB EN
	CLR EN
	LCALL TEMPO

	MOV R7,#0H
	MOV DPTR,#NOME11
	LCALL TEMPO
ESCOLHENDO_EXTREMO_2:
	LCALL DATA_LCD
	CJNE A,#0,EX_EXTREMO_2

	MOV A, R6
	RET

EX_EXTREMO:
	LCALL DATA_LCD2
	JMP ESCOLHENDO_EXTREMO

EX_EXTREMO_2:
	LCALL DATA_LCD2
	JMP ESCOLHENDO_EXTREMO_2


;*****************************************************************************	  
;VALORES PARA SEREM ESCRITOS	  

NOME1:
	DB 'LOSER',0
NOME2:
	DB 'CORRECT',0
NOME3:
	DB 'WINNER',0
NOME4:
	DB 'PRESS START',0
NOME5:
	DB 'NIVEL: ',0
NOME6:
	DB 'DIFICULDADE: ',0
NOME7:
	DB '1    2    3    4',0
NOME8:
	DB 'FACIL',0
NOME9:
	DB 'MEDIO',0
NOME10:
	DB 'DIFICIL',0
NOME11:
	DB 'EXTREMO',0
NOME12:
	DB 'STARTING',0


END

