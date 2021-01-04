#include <stdio.h>
#include <ILI9341.h>
#include "system.h"
#include "io.h"

#define AS 
#define AS_CS
#define AS_WRITE
#define AS_WRITEDATA


char* filename = "/mnt/host/image.ppm"
FILE *foutput = fopen(filename, "w");

if (!foutput) {
 printf("Error: could not open \"%s\" for writing\n", filename);
 return false;
}

/* Use fprintf function to write to file through file pointer */
fprintf(foutput, "Writing text to file\n");


int main() {
	LCD_Init();
	buffer_address = 0;
	buffer_length = 0;

	// default LCD initialisation commands

	// Give the buffer address and buffer length 
	IOWR_DIRECT32(AS, AS_CS, 1);
	IOWR_DIRECT32(AS, AS_WRITEDATA, buffer_address);
	IOWR_DIRECT32(AS, AS_ADDRESS, BUFFER_ADDRESS);	
	IOWR_DIRECT32(AS, AS_WRITE, 1);

	IOWR_DIRECT32(AS, AS_ADDRESS, BUFFER_LENGTH);
	IOWR_DIRECT32(AS, AS_WRITEDATA, buffer_length);
	// Set the 
  	while(1) {
  	}
}
