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
#include "io.h"
#include "system.h"

void LCD_Init(void);
void LCD_reset(void);
void waitms(int t);

// defines
#define LCD_CONTROLLER_0_BASE   0x0
#define BUFFER_ADDRESS_OFFSET   (4 * 0b0000)
#define BUFFER_LENGTH_OFFSET    (4 * 0b0001)
#define LCD_COMMAND_OFFSET      (4 * 0b0010)
#define LCD_DATA_OFFSET         (4 * 0b0011)

#define PIO_LEDS_BASE 0x10000810

void waitms(int t) {
    while(t--) {
        for(int i = 0; i < 2000; i++) {
            ;
        }
    }
}

void LCD_Init(void) {

    // software reset
    LCD_reset();
    waitms(120);

    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x0011); // exit sleep
    waitms(1);
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x0036); // Memory access control (MADCTL B5 = 1)
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x0020); // MY MX MV ML_BGR MH 0 0 -> 0b0010 0000
    waitms(1);
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x002A); // Column Address Set
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x0000); // SC0-7
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x0000); // SC8-15 -> 0x0000
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x0001); // EC0-7
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x003F); // EC8-15 -> 0x013F
    waitms(1);
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x002B); // Page Address Set
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x0000); // SP0-7
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x0000); // SP8-15 -> 0x0000
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x0000); // EP0-7
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x00EF); // EP8-15 -> 0x00EF
}
void LCD_reset(void) {
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x0001);
}

int main(void)
{
    printf("start:\n");
    //LCD_Init();

    IOWR_8DIRECT(PIO_LEDS_BASE, 1, 0x0);


    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, (4 * 0b0100), 0x0011);
    int r = IORD_32DIRECT(LCD_CONTROLLER_0_BASE, (4 * 0b0100));

    printf("%d", r);
    while(1) {
        //LCD_Init();
        IOWR_8DIRECT(PIO_LEDS_BASE, 1, 0xFF);
        waitms(1000);
        IOWR_8DIRECT(PIO_LEDS_BASE, 1, 0x00);
        waitms(1000);
    }
}
