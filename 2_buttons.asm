$mod51
inicio: 

	jnb P2.4, led1
	jnb P2.5, led2
	jnb P2.6, led3
	jnb P2.7, led4
	jmp inicio

led1: clr P2.0
	setb P2.0
	jmp inicio

led2: clr P2.1
	setb P2.1
	jmp inicio

led3: clr P2.2
	setb P2.2
	jmp inicio

led4: clr P2.3
	setb P2.3
	jmp inicio

END
