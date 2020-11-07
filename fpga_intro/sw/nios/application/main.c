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



int main()
{
    IOWR_8DIRECT(0x00000000, 0b000, 1);
    while(1) {

        for(int i = 0; i<8; i++) {
            printf("test \n");
            uint8_t output = 0b00000000;
            IOWR_8DIRECT(0x00000000, 0b010, output);
            output = (0b00000000 << i);
            IOWR_8DIRECT(0x00000000, 0b010, output);
            for(int k = 0; k<10000000;k++)
                ;
        }


    }



}
