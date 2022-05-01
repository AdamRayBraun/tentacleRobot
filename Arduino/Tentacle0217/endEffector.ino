Servo eyelidServo;

void setupEndEffector()
{
  pinMode(end_effector_led_pin, OUTPUT);

  eyelidServo.attach(eyelid_servo_pin);
}

void setEndEffectorLEDBrightness(int brightness)
{
  analogWrite(end_effector_led_pin, constrain(brightness, 0, 255));
}

void setEyelidPosition(int position)
{
  eyelidServo.write(constrain(position, 0, 180));
}
