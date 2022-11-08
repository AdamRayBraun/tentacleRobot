#include <Arduino.h>
#include <WiFi.h>
#include <esp_now.h>

void setup() {
  Serial.begin(115200);
  setupEspNow();
}

void loop() {
  handleENowRx();
  handleSerialRx();
}
