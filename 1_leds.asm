$mod51

INICIO1:

mov R0, #1b

INICIO2:

	mov P2, R0

	CPL P2.0
	CPL P2.1	
	CPL P2.2
	CPL P2.3

	
	mov R1,#1010000b 

DELAY:

	mov R2,#1010000b

DELAY2:
	
	mov R3, #111111b

DELAY3:
	
	nop 
	dec R3
	cjne R3, #0b, DELAY3
	dec R2
	cjne R2, #0b, delay2
	dec R1

cjne R1, #0b, DELAY

	mov A, R0 
	rl A
	mov R0, A

cjne R0, #10000b, inicio2

jmp inicio1


END

