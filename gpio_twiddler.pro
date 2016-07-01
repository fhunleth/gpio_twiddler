QT += core
QT -= gui

CONFIG += c++11

TARGET = gpio_twiddler
CONFIG += console
CONFIG -= app_bundle

TEMPLATE = app

SOURCES += \
    src/twiddler_common.c \
    src/twiddler_nif.c \
    src/twiddler_c.c

HEADERS += \
    src/twiddler_common.h
