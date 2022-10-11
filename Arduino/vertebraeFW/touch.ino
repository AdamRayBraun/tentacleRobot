#define touchThreshDebug 50

void setupTouch()
{
  pinMode(TOUCH_1, INPUT);
  pinMode(TOUCH_2, INPUT);
  pinMode(TOUCH_3, INPUT);
}

void testTouch()
{
  if (touchRead(TOUCH_1) < touchThreshDebug || touchRead(TOUCH_1) < touchThreshDebug || touchRead(TOUCH_1) < touchThreshDebug){
    Serial.println("touched");
  } else {

  }

}
