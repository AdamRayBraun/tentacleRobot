void setupEndEffectorLed()
{
  pinMode(end_effector_led_pin, OUTPUT);
}

void setEndEffectorLEDBrightness(int brightness)
{
  analogWrite(end_effector_led_pin, constrain(brightness, 0, 255));
}
