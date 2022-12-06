#define LED_COUNT  16

Adafruit_NeoPixel leds(LED_COUNT, end_effector_led_pin, NEO_GRB + NEO_KHZ800);


void setupEndEffector()
{
  leds.begin();
  leds.show();
  leds.setBrightness(255);

  endEffectorLedRing(10, 10, 10);
}

void endEffectorLedRing(int r, int g, int b){
  for(int i = 0; i < LED_COUNT; i++) {
    leds.setPixelColor(i, constrain(r, 0, 255), constrain(g, 0, 255), constrain(b, 0, 255));
  }
  leds.show();
}
