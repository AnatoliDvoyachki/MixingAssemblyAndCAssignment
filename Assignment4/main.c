#include <avr/io.h>
#include <stdio.h>
#include <stdint.h>
#include <avr/delay.h>
#include <atmega2560_drivers.h>
#include "assignment4.h"
#include <stdbool.h>

int main(void)
{
    init_stdio(0, 10000000L);
	hal_create();
	bool on_off = false;
	int lights = 0;
	float temperature = 0.0;
	
    while(1){
 		
		//get the temperature
		temperature = (hal_get_adc_value() * 1.1) / 1024;
 		float celsius = temperature * 50;
		
		//display the temperature
		lights = (int)((celsius - 20) / 2.5);
		for (int i = 0; i < 8; i++) {
			if(i <= lights){
				hal_set_led(i, 1);
			}else{
				hal_set_led(i, 0);
			}
		}
		
		//turn data logging on and off
		if(hal_is_pressed(1))
			on_off = true;
		if(!hal_is_pressed(0) && on_off){
			printf("%.1f", celsius);
		}else{
			on_off = false;
		}
		
		_delay_ms(200);
	}
	
	return 0;
}

