#include "twiddler_common.h"

#include <fcntl.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

int twiddler_init(struct twiddler_info **infop)
{
    struct twiddler_info *info = malloc(sizeof(struct twiddler_info));
    if (info == NULL)
        return -1;

    info->fd = open("/dev/mem", O_RDWR | O_CLOEXEC);
    if (info->fd < 0)
        return -1;

    info->gpio1_base = mmap(0, GPIO1_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
            info->fd, GPIO1_START_ADDR);
    if (info->gpio1_base == MAP_FAILED)
        return -1;

    // Force output mode
    info->gpio1_base[GPIO_OE] = info->gpio1_base[GPIO_OE] & ~GPIO_PIN_28;

    *infop = info;

    return 0;
}

int twiddler_free(struct twiddler_info *info)
{
    close(info->fd);
    free(info);

    return 0;
}
