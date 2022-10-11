/*
  Firmware for Have We Met's vertabrae PCBs

  Each ESP32-Pico-D4 based PCB has 3 touch inputs and 4 LED outputs

  Programmed w/ Arduino v1.8.10
  M5Stack board library v2.0.0

  Adan Ray Braun
*/

// config
#define EN_SERIAL     true
#define EN_LEDS       true
#define EN_TOUCH      true

#include <Arduino.h>

#define TOUCH_1 33
#define TOUCH_2 0
#define TOUCH_3 32

#define ssid "H&M"
#define password "weLoveInternetting"

void setup()
{
  #ifdef EN_SERIAL
    Serial.begin(115200);
  #endif

  #ifdef EN_LEDS
  setupLeds();
  #endif

  #ifdef EN_TOUCH
    setupTouch();
  #endif
}

void loop()
{
  fadeLeds();
}
