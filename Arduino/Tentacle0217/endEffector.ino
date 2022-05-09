#define LED_COUNT  16

Adafruit_NeoPixel leds(LED_COUNT, end_effector_led_pin, NEO_GRB + NEO_KHZ800);

Servo eyelidServoL, eyelidServoR;

void setupEndEffector()
{
  leds.begin();
  leds.show();
  leds.setBrightness(255);

  eyelidServoL.attach(eyelid_servo_pin_L);
  eyelidServoR.attach(eyelid_servo_pin_R);
}

void setEyelidPosition(int position)
{
  int pos = constrain(position, 0, 180);
  eyelidServoL.write(pos);
  eyelidServoR.write(180 - pos);
}

void endEffectorLedRing(int r, int g, int b){
  for(int i = 0; i < LED_COUNT; i++) {
    leds.setPixelColor(i, constrain(r, 0, 255), constrain(g, 0, 255), constrain(b, 0, 255));
  }
  leds.show();
}
