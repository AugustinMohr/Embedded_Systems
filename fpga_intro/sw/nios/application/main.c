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
#include <inttypes.h>
#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"
#include <unistd.h>

#define BASE_ADDRESS    0x00000000
#define DISP_MODE       (4*0b00)
#define CPU_DISP        (4*0b01)
#define TIME            (4*0b10)

int main()
{


    IOWR_32DIRECT(BASE_ADDRESS, TIME,0x23595000);
    IOWR_32DIRECT(BASE_ADDRESS, DISP_MODE,0x00000001);
    int temp;
    //printf("init \n");
    while(1)
    {
        //printf("test \n");
        temp = IORD_32DIRECT(BASE_ADDRESS, TIME);

        printf("%08x \n", temp);
        for(int i = 0; i <5000000; i++){
            ;
        }
    }

}
