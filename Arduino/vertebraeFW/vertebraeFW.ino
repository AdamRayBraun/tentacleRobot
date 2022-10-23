/*
  Firmware for Have We Met's vertabrae PCBs

  Each ESP32-Pico-D4 based PCB has 3 touch inputs and 4 LED outputs (+onboard RGB status led)

  Programmed w/ Arduino v1.8.10
  M5Stack board library v2.0.0

  Adan Ray Braun
*/

// MVP twinkle LEDs that brighten with touch, solo PCBs
#define STATE_INDIVIDUAL 0

// Each PCBs receives led commands over OSC
#define STATE_CLUSTERED  1

// Debug / testing
#define STATE_DEBUG      2

#define STARTING_STATE STATE_CLUSTERED

int state;

#include <Arduino.h>
#include <ArduinoOTA.h>
#include <FastLED.h>
#include "LED.h"

//OSC
#include <ESPmDNS.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <OSCMessage.h>
#include <OSCBundle.h>
#include <OSCData.h>

bool touched = false;

void setup()
{
  Serial.begin(115200);

  setupLeds();
  setupTouch();

  changeState(STARTING_STATE);

  switch(state){
    case STATE_INDIVIDUAL:
      break;

    case STATE_CLUSTERED:
      updateStatusLed(0, 0, 100);
      setupOSC();
      setupOTA();
      break;

    case STATE_DEBUG:
      break;
  }
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
      runOSC();
      updateAllLeds();
      checkForTouch();
      ArduinoOTA.handle();
      break;

    case STATE_DEBUG:
      Serial.print(touchReading1());
      Serial.print(" ");
      Serial.println(20);
      delay(200);
      break;
  }
}
