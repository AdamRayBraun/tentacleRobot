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
// #define steps    12
#define steps    6
LED *leds[NUM_LEDS];

// status LED
CRGB statLed[1];

// individual animation vars
#define animationFrameRate 8
#define passiveWaveMin     0
#define passiveWaveMax     100
#define speedChangeRate    3000

unsigned long lastAnimationFrame, lastSpeedChange;
bool ledIncreasing[4] = {true, true, true, true};
float ledSpeeds[4] = { 0.01, 0.01, 0.01, 0.01};
int ledWavePos[4];

// OTA blinking animation
bool blinkOn;

void setupLeds()
{
  // side emitting LEDs
  for (int l = 0; l < NUM_LEDS; l++) {
    leds[l] = new LED(l, LED_PINS[l], steps);
  }

  FastLED.addLeds<SK6812, 27, GRB>(statLed, 1); // built in WS2812
}

void randomWaves()
{
  if (millis() - lastAnimationFrame > animationFrameRate){
    for (byte l = 0; l < NUM_LEDS; l++){
      if (ledIncreasing[l]){
        // leds[l]->_val += ledSpeeds[l];
        // float newTarget = leds[l]->_val + ledSpeeds[l];
        // leds[l]->updateTarget(newTarget);
        leds[l]->_targetVal += ledSpeeds[l];
        if (leds[l]->_targetVal > passiveWaveMax) ledIncreasing[l] = false;
      } else {
        // leds[l]->_val -= ledSpeeds[l];
        // float newTarget = leds[l]->_val - ledSpeeds[l];
        // leds[l]->updateTarget(newTarget);
        leds[l]->_targetVal -= ledSpeeds[l];
        if (leds[l]->_targetVal < passiveWaveMin) ledIncreasing[l] = true;
      }
    }

    lastAnimationFrame =  millis();
  }

  if (millis() - lastSpeedChange > speedChangeRate){
    for (byte l = 0; l < NUM_LEDS; l++){
      ledSpeeds[l] = (float)(random(1, 500) / 1000.0);
    }
    lastSpeedChange = millis();
  }
}

void updateLeds(int ledFlag, int newBrightness)
{
  newBrightness = constrain(newBrightness, 0, 255);

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
}

void updateLedTarget(int ledFlag, int newTarget)
{
  newTarget = constrain(newTarget, 0, 255);

  leds[ledFlag]->updateTarget(newTarget);
}

void updateAllLeds()
{
  for (byte l = 0; l < NUM_LEDS; l++){
    leds[l]->run();
  }
}

void updateStatusLed(byte r, byte g, byte b){
  statLed[0].setRGB(r, g, b);
  FastLED.show();
}

void OTAwaitingBlink(){
  if (millis() - lastAnimationFrame > 1200){
    blinkOn = !blinkOn;

    if (blinkOn){
      updateStatusLed(50, 50, 50);
    } else {
      updateStatusLed(50, 50, 50);
    }

    lastAnimationFrame = millis();
  }
}
