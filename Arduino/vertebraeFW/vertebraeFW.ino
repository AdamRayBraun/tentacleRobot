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

// initial waiting for OTA after booting
#define STATE_UPDATE     3

#define STARTING_STATE STATE_CLUSTERED

#include <Arduino.h>
#include <ArduinoOTA.h>
#include <FastLED.h>
#include "LED.h"

#include <WiFi.h>
#include <esp_now.h>

int state;
bool touched = false;

void setup()
{
  Serial.begin(115200);

  setupLeds();
  setupTouch();
  getIDfromMac();

  changeState(STARTING_STATE);
  Serial.println("setup done");
}

void changeState(int newState)
{
  state = newState;

  Serial.print("changing state to: ");
  Serial.println(newState);

  switch(state){
    case STATE_CLUSTERED:
      updateStatusLed(0, 100, 0);
      setupEspNow();
      break;

    case STATE_UPDATE:
      updateStatusLed(0, 0, 100);
      setupOTA();
      break;
  }
}

void loop()
{
  switch(state){
    case STATE_INDIVIDUAL:
      randomWaves();
      checkForTouch();
      updateAllLeds();
      break;

    case STATE_CLUSTERED:
      handleENowRx();
      updateAllLeds();
      checkForTouch();
      break;

    case STATE_UPDATE:
      ArduinoOTA.handle();
      OTAwaitingBlink();
      break;

    case STATE_DEBUG:
      // Serial.print(touchReading1());
      // Serial.print(" ");
      // Serial.println(20);
      // oscDebugTouchVals();
      delay(250);
      break;
  }
}
