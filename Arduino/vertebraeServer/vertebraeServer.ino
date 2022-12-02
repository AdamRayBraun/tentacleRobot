#include <Arduino.h>
#include <WiFi.h>
#include <esp_now.h>

void setup() {
  setupSerial();
  setupEspNow();
}

void loop() {
  handleENowRx();
  handleSerialRx();
}
