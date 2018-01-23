 #include <avr/io.h>
	.global hal_create
	.global hal_set_led
	.global hal_is_pressed
	.global hal_get_adc_value

hal_create:
	push r16

	ldi r16, 0x00
	out  _SFR_IO_ADDR(DDRA), r16 ;set port A for input
	out _SFR_IO_ADDR(DDRF), r16 ;set port F for input
	ldi r16, 0xFF
	out _SFR_IO_ADDR(DDRB), r16 ;set port B for output
	
	;set ADC registers
	ldi r16, 0x80
	sts ADMUX, r16
	ldi r16, 0x86
	sts ADCSRA, r16

	pop r16
	sei
	ret

hal_is_pressed:
	push r17
	ldi r17, 1
loop:
	cpi r24, 0
	breq end
	lsl r17
	dec r24
	rjmp loop
end:
	in r24, _SFR_IO_ADDR(PINA)
	com r24
	and r24, r17
	pop r17
	ret

hal_get_adc_value:
	push r16
	push r17

	lds r17, ADCSRA   ;start conversion
	sbr r17, 1<<ADSC
	sts ADCSRA, r17					;set ADC Start Conversion bit to 1

KEEP_POLLING:	
	lds r17, ADCSRA
	sbrc r17, ADSC					;skip next instruction if the conversion is over
	rjmp KEEP_POLLING

	lds r24, ADCL					;write the 8 low bits in r24
	lds r25, ADCH					;write the 2 high bits in r25
	
	pop r17
	pop r16
	ret


NEXT:
	lsl R17 
	inc R16
	rjmp COMPARE

hal_set_led:
	push r16
	push r17
	push r18
		
	ldi r16, 0    
	ldi r17, 0b00000001

COMPARE:
	cp r16, r24
	brlt NEXT     
	in r18, _SFR_IO_ADDR(PORTB)
	cpi r22, 0 
	breq FALSE
	com r17 
	and r18, r17
	rjmp OUTPUT
	
FALSE:
	or r18, r17	
	
OUTPUT: 
	out _SFR_IO_ADDR(PORTB), r18

	pop r18
	pop r17
	pop r16

	ret