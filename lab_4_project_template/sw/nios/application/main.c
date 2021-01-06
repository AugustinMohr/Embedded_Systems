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
#include <stdlib.h>
#include "io.h"
//#include "system.h"

void LCD_Init(void);
void LCD_reset(void);
void waitms(int t);
void LCD_WR_DATA(uint data);
void LCD_WR_REG(uint data);
void LCD_Clear(uint Color);
void LCD_SetCursor(uint Xpos, uint Ypos);
void LCD_Swiss(uint size);
void MEM_WR(uint offset, uint data);
void BUFF_ADD_WR(uint data);
void BUFF_LEN_WR(uint data);

// defines
#define LCD_CONTROLLER_0_BASE   0x00
#define BUFFER_ADDRESS_OFFSET   (4 * 0b0000)
#define BUFFER_LENGTH_OFFSET    (4 * 0b0001)
#define LCD_COMMAND_OFFSET      (4 * 0b0010)
#define LCD_DATA_OFFSET         (4 * 0b0011)

#define HPS_0_BRIDGES_BASE      0x40000000
#define BUFFER_LENGTH           0x00023800 //1 228 800 bits, 153600 bytes, in hex 23800
#define BUFFER1_OFFSET          0x00000000
#define BUFFER2_OFFSET          (BUFFER1_OFFSET + BUFFER_LENGTH)


#define PIO_LEDS_BASE 0x10000810

// colours
#define RED 0xf800
#define GREEN 0x07e0
#define BLUE 0x001f
#define BLACK  0x0000
#define WHITE 0xffff

void waitms(int t) {
    while(t--) {
        for(int i = 0; i < 3125; i++) {
            ;
        }
    }
}

void LCD_WR_DATA(uint data) {
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_DATA_OFFSET, data);
}

void LCD_WR_REG(uint data) {
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, data);
}

void LCD_Init(void) {

    // software reset
    LCD_reset();
    waitms(120);

    LCD_WR_REG(0x0011); //Exit Sleep
    LCD_WR_REG(0x00CF);
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x0081);
        LCD_WR_DATA(0X00c0);

    LCD_WR_REG(0x00ED);
        LCD_WR_DATA(0x0064);
        LCD_WR_DATA(0x0003);
        LCD_WR_DATA(0X0012);
        LCD_WR_DATA(0X0081);

    LCD_WR_REG(0x00E8);
        LCD_WR_DATA(0x0085);
        LCD_WR_DATA(0x0001);
        LCD_WR_DATA(0x00798);

    LCD_WR_REG(0x00CB);
        LCD_WR_DATA(0x0039);
        LCD_WR_DATA(0x002C);
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x0034);
        LCD_WR_DATA(0x0002);

    LCD_WR_REG(0x00F7);
        LCD_WR_DATA(0x0020);

    LCD_WR_REG(0x00EA);
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x0000);

    LCD_WR_REG(0x00B1);
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x001b);

    LCD_WR_REG(0x00B6);
        LCD_WR_DATA(0x000A);
        LCD_WR_DATA(0x00A2);

    LCD_WR_REG(0x00C0);    //Power control
        LCD_WR_DATA(0x0005);   //VRH[5:0]

    LCD_WR_REG(0x00C1);    //Power control
        LCD_WR_DATA(0x0011);   //SAP[2:0];BT[3:0]

    LCD_WR_REG(0x00C5);    //VCM control
        LCD_WR_DATA(0x0045);       //3F
        LCD_WR_DATA(0x0045);       //3C

     LCD_WR_REG(0x00C7);    //VCM control2
         LCD_WR_DATA(0X00a2);

    LCD_WR_REG(0x0036);    // Memory Access Control
        LCD_WR_DATA(0x0008);//48

    LCD_WR_REG(0x00F2);    // 3Gamma Function Disable
        LCD_WR_DATA(0x0000);

    LCD_WR_REG(0x0026);    //Gamma curve selected
        LCD_WR_DATA(0x0001);

    LCD_WR_REG(0x00E0);    //Set Gamma
        LCD_WR_DATA(0x000F);
        LCD_WR_DATA(0x0026);
        LCD_WR_DATA(0x0024);
        LCD_WR_DATA(0x000b);
        LCD_WR_DATA(0x000E);
        LCD_WR_DATA(0x0008);
        LCD_WR_DATA(0x004b);
        LCD_WR_DATA(0X00a8);
        LCD_WR_DATA(0x003b);
        LCD_WR_DATA(0x000a);
        LCD_WR_DATA(0x0014);
        LCD_WR_DATA(0x0006);
        LCD_WR_DATA(0x0010);
        LCD_WR_DATA(0x0009);
        LCD_WR_DATA(0x0000);

    LCD_WR_REG(0X00E1);    //Set Gamma
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x001c);
        LCD_WR_DATA(0x0020);
        LCD_WR_DATA(0x0004);
        LCD_WR_DATA(0x0010);
        LCD_WR_DATA(0x0008);
        LCD_WR_DATA(0x0034);
        LCD_WR_DATA(0x0047);
        LCD_WR_DATA(0x0044);
        LCD_WR_DATA(0x0005);
        LCD_WR_DATA(0x000b);
        LCD_WR_DATA(0x0009);
        LCD_WR_DATA(0x002f);
        LCD_WR_DATA(0x0036);
        LCD_WR_DATA(0x000f);

    LCD_WR_REG(0x002A);
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x00ef);

     LCD_WR_REG(0x002B);
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x0001);
        LCD_WR_DATA(0x003f);

    LCD_WR_REG(0x003A);
        LCD_WR_DATA(0x0055);

    LCD_WR_REG(0x00f6);
        LCD_WR_DATA(0x0001);
        LCD_WR_DATA(0x0030);
        LCD_WR_DATA(0x0000);

    LCD_WR_REG(0x0029); //display on


    LCD_WR_REG(0x0036); // Memory access control (MADCTL B5 = 1)
        LCD_WR_DATA(0x0028); // MY MX MV ML_BGR MH 0 0 -> 0b0010 0000


    LCD_WR_REG(0x002A); // Column Address Set
        LCD_WR_DATA(0x0000); // SC0-7
        LCD_WR_DATA(0x0000); // SC8-15 -> 0x0000
        LCD_WR_DATA(0x0001); // EC0-7
        LCD_WR_DATA(0x003F); // EC8-15 -> 0x013F


    LCD_WR_REG(0x002B); // Page Address Set
        LCD_WR_DATA(0x0000); // SP0-7
        LCD_WR_DATA(0x0000); // SP8-15 -> 0x0000
        LCD_WR_DATA(0x0000); // EP0-7
        LCD_WR_DATA(0x00EF); // EP8-15 -> 0x00EF
        LCD_WR_REG(0x0029);
}

void LCD_Clear(uint Color)
{
        uint index=0;
        LCD_SetCursor(0x00,0x0000);
        LCD_WR_REG(0x002C);
        for(index=0;index<76800;index++)
        {
            LCD_WR_DATA(Color);
        }
}

void LCD_SetCursor(uint Xpos, uint Ypos)
{
     LCD_WR_REG(0x002A);
         LCD_WR_DATA(Xpos>>8);
         LCD_WR_DATA(Xpos&0XFF);
     LCD_WR_REG(0x002B);
         LCD_WR_DATA(Ypos>>8);
         LCD_WR_DATA(Ypos&0XFF);
     LCD_WR_REG(0x002C);
}

void LCD_Swiss(uint size) {

    LCD_WR_REG(0x002c);
    LCD_Clear(RED);
    // 140 - 180, 60 - 140
    LCD_SetCursor(160 - size * 1/2 , 120 - size * 3/2);
    for(int i = 0; i < size; i++) {
        for(int j = 0; j < size; j++) {
            LCD_WR_DATA(WHITE);
        }
        LCD_SetCursor(160 - size * 1/2, 120 - size * 3/2 + i);
    }

    LCD_SetCursor(160 - size * 3/2 , 120 - size * 1/2);
    for(int i = 0; i < size; i++) {
        for(int j = 0; j < 3*size; j++) {
            LCD_WR_DATA(WHITE);
        }
        LCD_SetCursor(160 - size * 3/2, 120 - size * 1/2 + i);
    }

    LCD_SetCursor(160 - size * 1/2 , 120 + size * 1/2);
   for(int i = 0; i < size; i++) {
       for(int j = 0; j < size; j++) {
           LCD_WR_DATA(WHITE);
       }
       LCD_SetCursor(160 - size * 1/2, 120 + size * 1/2 + i);
   }

}

void LCD_reset(void) {
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_COMMAND_OFFSET, 0x0001);
}

void MEM_WR(uint offset, uint data) {
    IOWR_32DIRECT(HPS_0_BRIDGES_BASE, offset, data);
}

void BUFF_ADD_WR(uint data){
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, BUFFER_ADDRESS_OFFSET, data);
}

void BUFF_LEN_WR(uint data){
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, BUFFER_LENGTH_OFFSET, data);
}

void test(void) {
    int verbose = 0;
    printf("sending data to SDRAM... \n");
    // write to SDRAM
    for(int i = 0; i < BUFFER_LENGTH; i = i + 4){
        MEM_WR(BUFFER1_OFFSET + i, 0xffffffff);
    }
    printf("Data successfully sent. reading \n");

    if(verbose == 1){
        unsigned char r;
        for(int i = 0; i < BUFFER_LENGTH; i = i + 4){
            r =  IORD_32DIRECT(HPS_0_BRIDGES_BASE, BUFFER1_OFFSET + i);
            printf("%x \n", r);
        }
    }


    // buffer address
    BUFF_ADD_WR(BUFFER1_OFFSET);
    waitms(1);
    // buffer length
    BUFF_LEN_WR(BUFFER_LENGTH);

    printf("Buffer info sent. \n");
}

int main(void)
{

    printf("start:\n");
    LCD_Init();
    LCD_Clear(0x0000);
    IOWR_8DIRECT(PIO_LEDS_BASE, 1, 0x0);

    test();
    while(1) {
        IOWR_8DIRECT(PIO_LEDS_BASE, 1, 0xAA);
        waitms(1000);
        IOWR_8DIRECT(PIO_LEDS_BASE, 1, 0x55);
        waitms(1000);
    }
}
