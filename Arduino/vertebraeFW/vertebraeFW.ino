/*
  Firmware for Have We Met's vertabrae PCBs

  Each ESP32-Pico-D4 based PCB has 3 touch inputs and 4 LED outputs

  Programmed w/ Arduino v1.8.10
  M5Stack board library v2.0.0

  Adan Ray Braun
*/

// config
#define EN_OSC       true

#define STATE_INDIVIDUAL 0
#define STATE_CLUSTERED  1
int state = STATE_INDIVIDUAL;

#include <Arduino.h>
#include <WiFi.h>
#include "LED.h"

#ifdef EN_OSC
  #include <WiFiUdp.h>
  #include <OSCMessage.h>
  #include <OSCBundle.h>
  #include <OSCData.h>
#endif

boolean touched = false;

void setup()
{
  Serial.begin(115200);

  setupLeds();
  setupTouch();

  #ifdef EN_OSC
    setupOSC();
  #endif

  changeState(STATE_CLUSTERED);
}

void changeState(int newState)
{
  state = newState;
}

void loop()
{
  switch(state){
    case STATE_INDIVIDUAL:
      randomWaves();
      checkForTouch();
      break;

    case STATE_CLUSTERED:
      #ifdef EN_OSC
        runOSC();
      #endif
      break;
  }
}
