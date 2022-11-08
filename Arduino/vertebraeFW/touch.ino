#define TOUCH_1_PIN 33
#define TOUCH_2_PIN 0
#define TOUCH_3_PIN 32

#define TOUCH_1 0
#define TOUCH_2 1
#define TOUCH_3 2

#define NUM_TOUCH 3

#define shortTouchTime 300
#define longTouchTime  1000
#define debounceThresh 100

int touchThreshold = 20;

int touchPins[NUM_TOUCH] = {TOUCH_1_PIN, TOUCH_2_PIN, TOUCH_3_PIN};

unsigned long buttonDownTime[NUM_TOUCH];
unsigned long lastTouch[NUM_TOUCH];
bool lastTouchDebouceState[NUM_TOUCH] = {false, false, false};
bool lastTouchState[NUM_TOUCH];
bool touchState[NUM_TOUCH];

unsigned int lastTouched;
int touchTime = 3000;

void setupTouch()
{
  pinMode(TOUCH_1_PIN, INPUT);
  pinMode(TOUCH_2_PIN, INPUT);
  pinMode(TOUCH_3_PIN, INPUT);
}

void checkForTouch()
{
  touchDebounce(TOUCH_1);
  touchDebounce(TOUCH_3);

  // if (touched){
  //   if (millis() - lastTouched > touchTime){
  //     touched = false;
  //   }
  //
  //   for (byte l = 0; l < NUM_LEDS; l++){
  //     leds[l]->updateTarget(255);
  //   }
  // }
}

void touchOutput(int touchIndex, bool isShortTouch)
{
  switch(state){
    case STATE_INDIVIDUAL:

      break;

    case STATE_CLUSTERED:
      sendTouchMsg(touchIndex, isShortTouch);
      break;

    case STATE_UPDATE:
      if (!isShortTouch) changeState(STATE_CLUSTERED);
      break;

    case STATE_DEBUG:
      break;
  }

  Serial.println("touched");
  touched = true;
  lastTouched = millis();
}

void touchDebounce(int touchIndex)
{
  bool touchReading = touchRead(touchPins[touchIndex]) > touchThreshold;

  if (touchReading != lastTouchDebouceState[touchIndex]){
    lastTouch[touchIndex] = millis();
  }

  if ((millis() - lastTouch[touchIndex]) > debounceThresh){
    if (touchReading != touchState[touchIndex]){
      touchState[touchIndex] = touchReading;
    }
  }

  lastTouchDebouceState[touchIndex] = touchReading;

  // no touch -> touch
  if (touchState[touchIndex] == true && lastTouchState[touchIndex] == false){
    buttonDownTime[touchIndex] = millis();
  }

  // touch -> no touch
  if (touchState[touchIndex] == false && lastTouchState[touchIndex] == true){
    int touchedTime = millis() - buttonDownTime[touchIndex];

    // long touch
    if (touchedTime > longTouchTime){
      touchOutput(touchIndex, false);

    // short touch
  } else if (touchedTime > shortTouchTime && touchedTime < longTouchTime) {
      touchOutput(touchIndex, true);
    }
  }

  lastTouchState[touchIndex] = touchState[touchIndex];
}

int touchReading1()
{
  return touchRead(TOUCH_1_PIN);
}

int touchReading2()
{
  return touchRead(TOUCH_3_PIN);
}

void updateTouchThresh(int newThresh)
{
  touchThreshold = newThresh;
}

int getTouchThreshold()
{
  return touchThreshold;
}
