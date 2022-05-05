#define LED_PIN    4
#define LED_COUNT  16

Adafruit_NeoPixel leds(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);

Servo eyelidServoL, eyelidServoR;

void setupEndEffector()
{
  leds.begin();
  leds.show();
  leds.setBrightness(255);
  endEffectorLedRing();

  eyelidServoL.attach(eyelid_servo_pin_L);
  eyelidServoR.attach(eyelid_servo_pin_R);
}

void setEndEffectorLEDBrightness(int brightness)
{
  analogWrite(end_effector_led_pin, constrain(brightness, 0, 255));
}

void setEyelidPosition(int position)
{
  int pos = constrain(position, 0, 180);
  eyelidServoL.write(pos);
  eyelidServoR.write(180 - pos);
}

void endEffectorLedRing(){
  for(int i = 0; i < LED_COUNT; i++) {
    leds.setPixelColor(i, 255, 255, 255);
  }
  leds.show();
}
