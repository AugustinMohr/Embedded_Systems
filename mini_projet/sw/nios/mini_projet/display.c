
#include "display.h"




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

void LCD_ON(uint on) {
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, LCD_ON_OFFSET, on);
}

void LCD_INTERRUPT_ENABLE(uint on){
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, INTERRUPT_ENABLE_OFFSET, 1);
}


void LCD_Init(void) {


    LCD_ON(1);// Turn the LCD on
    LCD_INTERRUPT_ENABLE(0); // Enable interrupts

    // software reset
    LCD_reset();
    waitms(120);

    LCD_WR_REG(0x0011); //Exit Sleep
    LCD_WR_REG(0x00CF);
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x0081);
        LCD_WR_DATA(0X00c0);

    LCD_WR_REG(0x00ED);     // Power on sequence control
        LCD_WR_DATA(0x0064);
        LCD_WR_DATA(0x0003);
        LCD_WR_DATA(0X0012);
        LCD_WR_DATA(0X0081);

    LCD_WR_REG(0x00E8);     // Driver timing control A
        LCD_WR_DATA(0x0085);
        LCD_WR_DATA(0x0001);
        LCD_WR_DATA(0x00798);

    LCD_WR_REG(0x00CB);     // Power control A
        LCD_WR_DATA(0x0039);
        LCD_WR_DATA(0x002C);
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x0034);
        LCD_WR_DATA(0x0002);

    LCD_WR_REG(0x00F7);     // Pump ratio control
        LCD_WR_DATA(0x0020);

    LCD_WR_REG(0x00EA);     // Driver timing control B
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x0000);

    LCD_WR_REG(0x00B1);     // Frame rate control
        LCD_WR_DATA(0x0000);
        LCD_WR_DATA(0x001b);

    LCD_WR_REG(0x00C0);    //Power control
        LCD_WR_DATA(0x0005);   //VRH[5:0]

    LCD_WR_REG(0x00C1);    //Power control
        LCD_WR_DATA(0x0011);   //SAP[2:0];BT[3:0]

    LCD_WR_REG(0x00C5);    //VCM control
        LCD_WR_DATA(0x0045);       //3F
        LCD_WR_DATA(0x0045);       //3C

     LCD_WR_REG(0x00C7);    //VCM control2
         LCD_WR_DATA(0X00a2);

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
        LCD_WR_DATA(0x0028); // MY MX MV ML_BGR MH 0 0 -> 0b0010 1000


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
   LCD_SetCursor(0,0);
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

void BURST_COUNT_WR(uint data){
    IOWR_32DIRECT(LCD_CONTROLLER_0_BASE, BURST_COUNT_OFFSET, data);
}

void test(uint verbose) {

    if(verbose)
        printf("sending data to SDRAM... \n");
    // write to SDRAM
    for(int i = 0; i < BUFFER_LENGTH * 4; i = i + 4){
        MEM_WR(BUFFER1_OFFSET + i, 0x00000000);
    }

    for(int i = 0; i < BUFFER_LENGTH; i = i + 4){

        for(int j = 0; j<120; j++) {
            MEM_WR(BUFFER1_OFFSET + i, 0xf800f800);
            i = i + 4;
        }
        for(int j = 0; j<120; j++) {
            MEM_WR(BUFFER1_OFFSET + i, 0x07e007e0);
            i = i + 4;
        }
            //MEM_WR(BUFFER1_OFFSET + i, 0x008f008f);

    }
    if(verbose)
        printf("Data successfully sent. reading \n");

    if(verbose){
        unsigned char r;
        for(int i = 0; i < BUFFER_LENGTH ; i = i + 4){
            r =  IORD_32DIRECT(HPS_0_BRIDGES_BASE, BUFFER1_OFFSET + i);
            printf("%x \n", r);
        }
    }

    // buffer address
    BUFF_ADD_WR(BUFFER1_OFFSET);
    waitms(1);
    // buffer length
    BUFF_LEN_WR(BUFFER_LENGTH);

    if(verbose)
        printf("Buffer info sent. \n");
}


void upload_image(void) {
    char* filename = "/mnt/host/image_54.ppm";
    int r1, g1, b1, r2, g2, b2, r, w, h, maxComp1, maxComp2, maxComp3, i = 0;
    char format[3];

    FILE *file = fopen(filename, "r");
    if (!file) {
     printf("Error: could not open \"%s\" for reading\n", filename);
     return;
    }
    printf("Reading file...\n");

    fscanf(file, "%2s", &format);
    fscanf(file, "%d", &w);
    fscanf(file, "%d", &h);
    fscanf(file, "%d", &maxComp1);
    fscanf(file, "%d", &maxComp2);
    fscanf(file, "%d", &maxComp3);
    printf("format: %2s\nsize: %d x %d \n%d %d \n",format, w, h, maxComp1, maxComp2, maxComp3);
    printf("Sending info to SDRAM...\n");

    for(i = 0; i < BUFFER_LENGTH; i = i + 4) {
        r1 = ((fgetc(file) >> 3) & 0x1f) << 11;
        g1 = ((fgetc(file) >> 2) & 0x3f) << 5;
        b1 = (fgetc(file) >> 3) & 0x1f;
        r2 = ((fgetc(file) >> 3) & 0x1f) << 11;
        g2 = ((fgetc(file) >> 2) & 0x3f) << 5;
        b2 = (fgetc(file) >> 3) & 0x1f;
        r = (int)(r1  + g1 + b1 + ((r2 + g2 + b2) << 16));
        MEM_WR(BUFFER1_OFFSET + i, r);
    }
    fclose(file);
    printf("Sent image to memory after %d iterations\n", i);

    BUFF_ADD_WR(BUFFER1_OFFSET); // buffer address
    BUFF_LEN_WR(BUFFER_LENGTH); // buffer length
}



uint8_t display_is_finished(void) {
	uint32_t finished = IORD_32DIRECT(LCD_CONTROLLER_0_BASE, FINISHED_OFFSET);
	return finished & 0x1;
}
