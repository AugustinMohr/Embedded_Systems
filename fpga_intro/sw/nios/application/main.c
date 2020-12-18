
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

    //Sets the time of the RTC and the Display mode to hours/minutes/seconds
    IOWR_32DIRECT(BASE_ADDRESS, TIME,0x23595000);
    IOWR_32DIRECT(BASE_ADDRESS, DISP_MODE,0x00000001);



    //Reads the time and prints it in the console
    int temp;
    while(1)
    {

        temp = IORD_32DIRECT(BASE_ADDRESS, TIME);

        printf("%08x \n", temp);
        for(int i = 0; i <5000000; i++){
            ;
        }
    }

}









