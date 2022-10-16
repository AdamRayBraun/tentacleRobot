// PWM GPIO pins
const int LED_PINS[] = { 22, 18, 19, 21 };

// PWM definitions
#define PWM_CHANNEL_1  0
#define PWM_CHANNEL_2  1
#define PWM_CHANNEL_3  2
#define PWM_CHANNEL_4  3

// Comms LED update flags
#define UPDATE_LED_ALL 0
#define UPDATE_LED_1   1
#define UPDATE_LED_2   2
#define UPDATE_LED_3   3
#define UPDATE_LED_4   4

// LED object definitions
#define NUM_LEDS 4
#define steps    12
LED *leds[NUM_LEDS];

// individual animation vars
#define animationFrameRate 30
#define ledFrameRate       1
#define passiveWaveMin     0
#define passiveWaveMax     30
#define speedChangeRate    2000

unsigned long lastAnimationFrame, lastLEDUpdate, lastSpeedChange;
byte ledTargets[4];
bool ledIncreasing[4];
float ledSpeeds[4] = { 0.01, 0.01, 0.01, 0.01};

void setupLeds()
{
  for (int l = 0; l < NUM_LEDS; l++) {
    leds[l] = new LED(l, LED_PINS[l], steps);
  }
}

void pulseAnimation()
{
  if (millis() - lastAnimationFrame > animationFrameRate){
    for (byte l = 0; l < NUM_LEDS; l++){
      ledTargets[l] = random(0, 150);
    }
    lastAnimationFrame = millis();
  }

  if (millis() - lastLEDUpdate > ledFrameRate){
    for (byte l = 0; l < NUM_LEDS; l++){
      leds[l]->fadeTo(ledTargets[l]);
    }

    updateAllLeds();
    lastLEDUpdate = millis();
  }
}

void randomWaves()
{
  if (touched){
    for (byte l = 0; l < NUM_LEDS; l++){
      leds[l]->_val = 255;
      ledIncreasing[l] = false;
    }
  } else {
    if (millis() - lastAnimationFrame > animationFrameRate){
      for (byte l = 0; l < NUM_LEDS; l++){
        if (ledIncreasing[l]){
          leds[l]->_val += ledSpeeds[l];
          if (leds[l]->_val > passiveWaveMax) ledIncreasing[l] = false;
        } else {
          leds[l]->_val -= ledSpeeds[l];
          if (leds[l]->_val < passiveWaveMin) ledIncreasing[l] = true;
        }
      }
    }

    if (millis() - lastSpeedChange > speedChangeRate){
      for (byte l = 0; l < NUM_LEDS; l++){
        ledSpeeds[l] = random(1, 20) / 1000.0;
      }
      lastSpeedChange = millis();
    }
  }
  updateAllLeds();
}

void updateLeds(int ledFlag, int newBrightness)
{
  switch(ledFlag){
    case UPDATE_LED_ALL:
      ledcWrite(PWM_CHANNEL_1, newBrightness);
      ledcWrite(PWM_CHANNEL_2, newBrightness);
      ledcWrite(PWM_CHANNEL_3, newBrightness);
      ledcWrite(PWM_CHANNEL_4, newBrightness);
      break;

    case UPDATE_LED_1:
      ledcWrite(PWM_CHANNEL_1, newBrightness);
      break;

    case UPDATE_LED_2:
      ledcWrite(PWM_CHANNEL_2, newBrightness);
      break;

    case UPDATE_LED_3:
      ledcWrite(PWM_CHANNEL_3, newBrightness);
      break;

    case UPDATE_LED_4:
      ledcWrite(PWM_CHANNEL_4, newBrightness);
      break;

    default:
      Serial.print("WARN: trying to update unknown LED id: ");
      Serial.println(ledFlag);
      break;
  }

  Serial.print("updating led ");
  Serial.print(ledFlag);
  Serial.print(" to ");
  Serial.println(newBrightness);
}

void updateAllLeds()
{
  for (byte l = 0; l < NUM_LEDS; l++){
    leds[l]->run();
  }
}