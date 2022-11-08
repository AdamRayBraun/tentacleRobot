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

#include <WiFi.h>
#include <esp_now.h>

bool touched = false;

void setup()
{
  Serial.begin(115200);

  setupLeds();
  setupTouch();
  getIDfromMac();
  changeState(STARTING_STATE);

  switch(state){
    case STATE_INDIVIDUAL:
      // setupWifi();
      // setupOTA();
      break;

    case STATE_CLUSTERED:
      updateStatusLed(0, 0, 100);
      // setupOSC();
      setupEspNow();
      setupOTA();
      break;

    case STATE_DEBUG:
      break;
  }

  Serial.println("setup done");
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
      updateAllLeds();
      break;

    case STATE_CLUSTERED:
      handleENowRx();
      updateAllLeds();
      checkForTouch();
      break;

    case STATE_DEBUG:
      // Serial.print(touchReading1());
      // Serial.print(" ");
      // Serial.println(20);
      // oscDebugTouchVals();
      delay(250);
      break;
  }
  ArduinoOTA.handle();
}
