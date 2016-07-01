// This was run on an Arduino Uno R3

#include <FastGPIO.h> // See https://github.com/pololu/fastgpio-arduino/

void setup()
{
  FastGPIO::Pin<12>::setOutput(LOW);
}

void loop()
{
  for (;;) {
    FastGPIO::Pin<12>::setOutputValueHigh();
    FastGPIO::Pin<12>::setOutputValueLow();
  }
}
