#include "twiddler_common.h"
#include <stdlib.h>

#include "erl_nif.h"

static int twiddler_load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info)
{
    struct twiddler_info *info;
    if (twiddler_init(&info) < 0)
        return -1;

    *priv_data = info;

    return 0;
}

static void twiddler_unload(ErlNifEnv *env, void *priv_data)
{
    struct twiddler_info *info = priv_data;

    twiddler_free(info);
}

static ERL_NIF_TERM twiddler_gpio_high(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    struct twiddler_info *info = enif_priv_data(env);

    info->gpio1_base[GPIO_SETDATAOUT] = GPIO_PIN_28;

    return enif_make_int(env, 1);
}

static ERL_NIF_TERM twiddler_gpio_low(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    struct twiddler_info *info = enif_priv_data(env);

    info->gpio1_base[GPIO_CLEARDATAOUT] = GPIO_PIN_28;

    return enif_make_int(env, 0);
}

static ErlNifFunc twiddler_funcs[] =
{
    {"gpio_high",     0, twiddler_gpio_high,     0},
    {"gpio_low",      0, twiddler_gpio_low,    0},
};

ERL_NIF_INIT(Elixir.GpioTwiddler.Nif, twiddler_funcs, twiddler_load, NULL, NULL, twiddler_unload)
