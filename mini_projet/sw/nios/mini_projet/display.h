#ifndef DISPLAY_H
#define DISPLAY_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "io.h"
#include "system.h"

// defines
#define BUFFER_ADDRESS_OFFSET   (4 * 0b0000)
#define BUFFER_LENGTH_OFFSET    (4 * 0b0001)
#define LCD_COMMAND_OFFSET      (4 * 0b0010)
#define LCD_DATA_OFFSET         (4 * 0b0011)
#define BURST_COUNT_OFFSET      (4 * 0b0100)
#define FINISHED_OFFSET         (4 * 0b0101)
#define INTERRUPT_ENABLE_OFFSET (4 * 0b0110)
#define LCD_ON_OFFSET           (4 * 0b0111)

#define LCD_CONTROLLER_0_BASE   DISPLAY_0_BASE


#define BUFFER_LENGTH           0x00025800 //1 228 800 bits, 153 600 bytes
#define BUFFER1_OFFSET          0x00000000
#define BUFFER2_OFFSET          (BUFFER1_OFFSET + BUFFER_LENGTH)

// colours
#define RED 0xf800
#define GREEN 0x07e0
#define BLUE 0x001f
#define BLACK  0x0000
#define WHITE 0xffff

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
void BURST_COUNT_WR(uint data);
void test(uint verbose);
void upload_image(void);
void LCD_ON(uint on);
void LCD_INTERRUPT_ENABLE(uint on);


//wrappers for clarity
#define display_buffer_len 	BUFF_LEN_WR
#define display_buffer_addr	BUFF_ADD_WR








#endif
