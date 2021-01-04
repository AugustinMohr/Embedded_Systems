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
#include <io.h>

// defines
#define LCD_CONTROLLER_0_BASE   0x0
#define BUFFER_ADDRESS_OFFSET   (4 * 0b0000)
#define BUFFER_LENGTH_OFFSET    (4 * 0b0001)
#define LCD_COMMAND_OFFSET      (4 * 0b0010)
#define LCD_DATA_OFFSET         (4 * 0b0011)

#define PIO_LEDS_BASE 0x10000810

int main(void)
{
    printf("start:\n");

    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x0001);
    IOWR_8DIRECT(PIO_LEDS_BASE, 1, 0x00);

    return 0;
}
