#include <Arduino.h>
#include <WiFi.h>
#include <esp_now.h>

void setup() {
  Serial.begin(115200);
  setupEspNow();
}

byte testy;
long lastUpdate;

void loop() {
  if (millis() - lastUpdate > 33){
    lastUpdate = millis();

    // sendBroadcast(testy, testy, testy, testy, 0, testy, 0);

    sendUpdate(23, testy, testy, 0, 0, 0, testy, 0);
    sendUpdate(24, 0, 0, testy, testy, testy, 0, 0);

    testy += 10;
    if (testy >= 255) testy = 0;
  }

  hanleENowRx();
}
