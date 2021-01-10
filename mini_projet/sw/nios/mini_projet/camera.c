
#include "camera.h"

#include "system.h"


#define I2C_FREQ              (50000000) /* Clock frequency driving the i2c core: 50 MHz in this example (ADAPT TO YOUR DESIGN) */
#define TRDB_D5M_I2C_ADDRESS  (0xba)

bool trdb_d5m_write(i2c_dev *i2c, uint8_t register_offset, uint16_t data) {
    uint8_t byte_data[2] = {(data >> 8) & 0xff, data & 0xff};

    int success = i2c_write_array(i2c, TRDB_D5M_I2C_ADDRESS, register_offset, byte_data, sizeof(byte_data));

    if (success != I2C_SUCCESS) {
        return false;
    } else {
        return true;
    }
}

bool trdb_d5m_read(i2c_dev *i2c, uint8_t register_offset, uint16_t *data) {
    uint8_t byte_data[2] = {0, 0};

    int success = i2c_read_array(i2c, TRDB_D5M_I2C_ADDRESS, register_offset, byte_data, sizeof(byte_data));

    if (success != I2C_SUCCESS) {
        return false;
    } else {
        *data = ((uint16_t) byte_data[0] << 8) + byte_data[1];
        return true;
    }
}


void camera_create(camera_dev * cam, uint32_t i2c_base, uint32_t cam_base) {
	cam->base = cam_base;
    i2c_dev i2c = i2c_inst((void *) i2c_base);
    i2c_init(&i2c, I2C_FREQ);
    cam->i2c = i2c;
}


bool camera_initial_setup(camera_dev * cam) {
	bool success = true;
	success &= trdb_d5m_write(&cam->i2c, 0x00D, 0x0001);
	success &= trdb_d5m_write(&cam->i2c, 0x00D, 0x0000);
	success &= trdb_d5m_write(&cam->i2c, 0x001, 54);
	success &= trdb_d5m_write(&cam->i2c, 0x002, 16);
	success &= trdb_d5m_write(&cam->i2c, 0x003, 1919);
	success &= trdb_d5m_write(&cam->i2c, 0x004, 2559);
	success &= trdb_d5m_write(&cam->i2c, 0x022, 0x0033);
	success &= trdb_d5m_write(&cam->i2c, 0x023, 0x0033);
	success &= trdb_d5m_write(&cam->i2c, 0x00A, 0x0080);
	success &= trdb_d5m_write(&cam->i2c, 0x01E, 0x0140);
	return success;
}

bool camera_red_gain(camera_dev * cam, uint8_t analog, uint8_t multiplier, uint16_t digital) {
	bool success = true;
	//red gain
	uint16_t red_gain = analog | (multiplier << 6);
	success &= trdb_d5m_write(&cam->i2c, 0x02D, red_gain);

	return success;
}

bool camera_green_gain(camera_dev * cam, uint8_t analog, uint8_t multiplier, uint16_t digital) {
	bool success = true;
	//green gain
	uint16_t green_gain = analog | (multiplier << 6);
	success &= trdb_d5m_write(&cam->i2c, 0x02E, green_gain);
	success &= trdb_d5m_write(&cam->i2c, 0x02B, green_gain);

	return success;
}

bool camera_blue_gain(camera_dev * cam, uint8_t analog, uint8_t multiplier, uint16_t digital) {
	bool success = true;
	//blue gain
	uint16_t blue_gain = analog | (multiplier << 6);
	success &= trdb_d5m_write(&cam->i2c, 0x02C, blue_gain);

	return success;
}

void camera_capture(camera_dev * cam, uint16_t exposure) {
	uint32_t control = (exposure << CAMERA_CONTROL_EXP) | (1 << CAMERA_CONTROL_START) | (1 << CAMERA_CONTROL_TRIGGER);
	IOWR_32DIRECT(cam->base, 0, control);
}

void camera_settings(camera_dev * cam, uint8_t burst_size, uint16_t width, uint16_t height) {
	uint32_t settings = (burst_size << CAMERA_SETTINGS_BURST) | (height << CAMERA_SETTINGS_HEIGHT) | (width << CAMERA_SETTINGS_WIDTH);
	IOWR_32DIRECT(cam->base, CAMERA_SETTINGS_BASE, settings);
}

void camera_address(camera_dev * cam, uint32_t address) {
	IOWR_32DIRECT(cam->base, CAMERA_ADDRESS_BASE, address);
	uint32_t lol = IORD_32DIRECT(cam->base, CAMERA_ADDRESS_BASE);
}

bool camera_is_finished(camera_dev * cam) {
	uint32_t ctrl = IORD_32DIRECT(cam->base, CAMERA_CONTROL_BASE);
	return ctrl & (1 << CAMERA_CONTROL_IF);
}
