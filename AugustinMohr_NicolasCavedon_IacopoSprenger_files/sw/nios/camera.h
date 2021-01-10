#ifndef CAMERA_H
#define CAMERA_H

#include <stdio.h>
#include "i2c/i2c.h"
#include "io.h"
#include "system.h"


#define CAMERA_BASE	CAMERA_0_BASE

#define CAMERA_CONTROL_BASE		0
#define CAMERA_CONTROL_TRIGGER	0
#define CAMERA_CONTROL_START	1
#define CAMERA_CONTROL_EXP		2
#define CAMERA_CONTROL_IE		30
#define CAMERA_CONTROL_IF		31

#define CAMERA_SETTINGS_BASE	4
#define CAMERA_SETTINGS_WIDTH	0
#define CAMERA_SETTINGS_HEIGHT	12
#define CAMERA_SETTINGS_BURST	24

#define CAMERA_ADDRESS_BASE		8


typedef struct {
	uint32_t base;
	i2c_dev i2c;
}camera_dev;

void camera_create(camera_dev * cam, uint32_t i2c_base, uint32_t cam_base);
bool camera_initial_setup(camera_dev * cam);
bool camera_red_gain(camera_dev * cam, uint8_t analog, uint8_t multiplier, uint16_t digital);
bool camera_green_gain(camera_dev * cam, uint8_t analog, uint8_t multiplier, uint16_t digital);
bool camera_blue_gain(camera_dev * cam, uint8_t analog, uint8_t multiplier, uint16_t digital);
void camera_capture(camera_dev * cam, uint16_t exposure);
void camera_settings(camera_dev * cam, uint8_t burst_size, uint16_t width, uint16_t height);
void camera_address(camera_dev * cam, uint32_t address);
bool camera_is_finished(camera_dev * cam);
void camera_save_ppm(camera_dev * cam, uint32_t addr);

#endif
