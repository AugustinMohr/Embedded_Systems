/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>

#include "camera.h"
#include "display.h"
#include "io.h"
#include "system.h"


#define FRAME_SIZE  (76800)

#define BUFFER_LEN (sizeof(uint16_t)*FRAME_SIZE)

#define FB0 HPS_0_BRIDGES_BASE

#define FB1 HPS_0_BRIDGES_BASE+BUFFER_LEN


int main()
{
	//framebuffer initialisation
	uint32_t fb[] = {FB0, FB1};
	uint16_t exposure = 0x0fff;
	uint8_t ord = 0;

	//camera initialisaion
	camera_dev camera;
	camera_create(&camera, I2C_0_BASE, CAMERA_0_BASE);
	camera_initial_setup(&camera);
	camera_settings(&camera, 16, 640, 480);
	camera_address(&camera, fb[ord]);

	//display initialisation
	LCD_Init();
	BURST_COUNT_WR(16);
	LCD_Clear(0x0000);
	display_buffer_len(BUFFER_LEN);

	//first picture
	camera_capture(&camera, exposure);

	while(!camera_is_finished(&camera));

	while(1) {
		//swap buffers
		ord = !ord;

		display_buffer_addr(fb[!ord]);
		camera_address(&camera, fb[ord]);

		camera_capture(&camera, exposure);
		//trigger display

		//while(!display_is_finished()); //wait for display to finish
		while(!camera_is_finished(&camera));
	}









	return 0;
}
