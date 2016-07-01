#ifndef TWIDDLER_COMMON_H
#define TWIDDLER_COMMON_H

#include <stdint.h>

#define REG_OFFSET(X)   ((X)/sizeof(uint32_t))

// See AM335x Technical Reference Manual table 2-3
#define GPIO1_START_ADDR 0x4804C000
#define GPIO1_SIZE       0x1000

// See AM335x Technical Reference Manual section 25.4.1
#define GPIO_OE             REG_OFFSET(0x134)
#define GPIO_CLEARDATAOUT   REG_OFFSET(0x190)
#define GPIO_SETDATAOUT     REG_OFFSET(0x194)

// Use GPIO 1_28 (Beaglebone Black -> P9 pin 12)
#define GPIO_PIN_28        (1<<28)

struct twiddler_info {
    int fd;

    volatile uint32_t *gpio1_base;
};

int twiddler_init(struct twiddler_info **infop);
int twiddler_free(struct twiddler_info *info);

#endif
