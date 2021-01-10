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

#include <stdbool.h>

#include "camera.h"
#include "display.h"
#include "io.h"
#include "system.h"


#define FRAME_SIZE  (76800)

#define WIDTH	320
#define HEIGHT	240

#define BURST_LEN 16

#define BUFFER_LEN (2*FRAME_SIZE)

#define FB0 HPS_0_BRIDGES_BASE

#define FB1 HPS_0_BRIDGES_BASE+10*BUFFER_LEN

//#define DOUBLE_BUFFERING


int main()
{
	printf("start\n");
	//framebuffer initialisation
	uint32_t fb[] = {FB0, FB1};
	uint16_t exposure = 0x00ff;
	uint8_t ord = 0;

	//camera initialisaion
	camera_dev camera;
	camera_create(&camera, I2C_0_BASE, CAMERA_0_BASE);
	camera_initial_setup(&camera);
	camera_settings(&camera, BURST_LEN, WIDTH*2, HEIGHT*2);
	camera_address(&camera, fb[ord]);
	camera_red_gain(&camera, 8, 1, 0);
	camera_green_gain(&camera, 8, 1, 0);
	camera_blue_gain(&camera, 8, 1, 0);

	//display initialisation
	LCD_Init();
	BURST_COUNT_WR(BURST_LEN);
	LCD_Clear(0x0000);

	//first picture
	camera_capture(&camera, exposure);

	while(!camera_is_finished(&camera));

	while(1) {
		//swap buffers

#ifdef DOUBLE_BUFFERING
		ord = !ord;
		printf("swapping_buffers\n");

		display_buffer_addr(fb[!ord]);
		display_buffer_len(BUFFER_LEN); //launch display


		camera_address(&camera, fb[ord]);
		camera_capture(&camera, exposure);


		while(!camera_is_finished(&camera));
		while(!display_is_finished());



#else

		camera_address(&camera, 0);
		camera_capture(&camera, exposure);
		while(!camera_is_finished(&camera));


		display_buffer_addr(0);
		display_buffer_len(BUFFER_LEN); //launch display

		while(!display_is_finished());

		waitms(33);
#endif
	}

	return 0;
}
