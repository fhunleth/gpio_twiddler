# Variables to override
#
# CC            C compiler
# CROSSCOMPILE	crosscompiler prefix, if any
# CFLAGS	compiler flags for compiling all C files
# ERL_CFLAGS	additional compiler flags for files using Erlang header files
# ERL_EI_LIBDIR path to libei.a
# LDFLAGS	linker flags for linking all binaries
# ERL_LDFLAGS	additional linker flags for projects referencing Erlang libraries

# Look for the EI library and header files
# For crosscompiled builds, ERL_EI_INCLUDE_DIR and ERL_EI_LIBDIR must be
# passed into the Makefile.
ifeq ($(ERL_EI_INCLUDE_DIR),)
ERL_ROOT_DIR = $(shell erl -eval "io:format(\"~s~n\", [code:root_dir()])" -s init stop -noshell)
ifeq ($(ERL_ROOT_DIR),)
   $(error Could not find the Erlang installation. Check to see that 'erl' is in your PATH)
endif
ERL_EI_INCLUDE_DIR = "$(ERL_ROOT_DIR)/usr/include"
ERL_EI_LIBDIR = "$(ERL_ROOT_DIR)/usr/lib"
endif

# Set Erlang-specific compile and linker flags
ERL_CFLAGS ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR) -lncurses

SO_LDFLAGS = -fPIC -shared -dynamiclib

CFLAGS ?= -fPIC -Wall -Wextra -Wno-unused-parameter
CC ?= $(CROSSCOMPILER)gcc

CFLAGS += -O2 -std=gnu99

.PHONY: all clean

all: priv priv/twiddler_nif.so priv/twiddler_c

%.o: %.c
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

priv:
	mkdir -p priv

priv/twiddler_nif.so: src/twiddler_nif.o src/twiddler_common.o
	$(CC) $^ $(ERL_LDFLAGS) $(LDFLAGS) $(SO_LDFLAGS) -o $@

priv/twiddler_c: src/twiddler_c.o src/twiddler_common.o
	$(CC) $^ $(ERL_LDFLAGS) $(LDFLAGS) -o $@

clean:
	rm -fr priv src/*.o
