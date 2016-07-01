#include "twiddler_common.h"
#include <string.h>

#include <err.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

static void usage(const char *program_name)
{
    printf("%s twiddles GPIOs.\n", program_name);
    printf("\n");
    printf("Usage: %s [OPTION]...\n", program_name);
    printf("\n");
    printf("Options:\n");
    printf("  -n <count>   Twiddle this many times\n");
    printf("  -s           Use the sysfs interface\n");

    exit(EXIT_FAILURE);
}

static void twiddle_sysfs(int count)
{
    // Linux GPIO 60 is GPIO1,28 and BBB P9_12
    int fd = open("/sys/class/gpio/gpio60/value", O_WRONLY | O_CLOEXEC);
    if (fd < 0)
        err(EXIT_FAILURE, "open");

    for (int i = 0; i < count; i++) {
        if (write(fd, "1\n", 2) < 0)
            err(EXIT_FAILURE, "write(1)");
        if (write(fd, "0\n", 2) < 0)
            err(EXIT_FAILURE, "write(1)");
    }

    close(fd);
}

static void twiddle_mmap(int count)
{
    struct twiddler_info *info;
    if (twiddler_init(&info) < 0)
        errx(EXIT_FAILURE, "twiddler_init failed");

    for (int i = 0; i < count; i++) {
        info->gpio1_base[GPIO_SETDATAOUT] = GPIO_PIN_28;
        info->gpio1_base[GPIO_CLEARDATAOUT] = GPIO_PIN_28;
    }

    twiddler_free(info);
}

int main(int argc, char *argv[])
{
    bool use_sysfs = false;
    int count = 10000;
    int opt;

    while ((opt = getopt(argc, argv, "n:s")) != -1) {
        switch (opt) {
        case 'n':
            count = strtol(optarg, NULL, 0);
            break;

        case 's':
            use_sysfs = true;
            break;

        default:
            usage(argv[0]);
            break;
        }
    }

    if (use_sysfs)
        twiddle_sysfs(count);
    else
        twiddle_mmap(count);

    exit(EXIT_SUCCESS);
}
