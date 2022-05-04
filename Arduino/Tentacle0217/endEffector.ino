Servo eyelidServo;

void setupEndEffector()
{
  pinMode(end_effector_led_pin, OUTPUT);

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
