#define TOUCH_1 33
#define TOUCH_2 0
#define TOUCH_3 32

#define touchThreshDebug 30
#define touchHold        1000

unsigned long lastTouch;

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
  }
}

void checkForTouch()
{
  if (touchReading() < touchThreshDebug){
    lastTouch = millis();
    touched = true;
  }

  if (touched = true){
    if (millis() - lastTouch > touchHold) touched = false;
  }
}

int touchReading()
{
  return touchRead(TOUCH_3);
}
