#define LED_1 22
#define LED_2 18
#define LED_3 19
#define LED_4 21

#define PWM_CHANNEL    0
#define PWM_FREQ       500
#define PWM_RESOLUTION 8

const int MAX_DUTY_CYCLE = (int)(pow(2, PWM_RESOLUTION) - 1);
const int DELAY_MS       = 4;

void setupLeds()
{
  ledcSetup(PWM_CHANNEL, PWM_FREQ, PWM_RESOLUTION);

  ledcAttachPin(LED_1, PWM_CHANNEL);
  ledcAttachPin(LED_2, PWM_CHANNEL);
  ledcAttachPin(LED_3, PWM_CHANNEL);
  ledcAttachPin(LED_4, PWM_CHANNEL);

  // pinMode(LED_1, OUTPUT);
  // pinMode(LED_2, OUTPUT);
  // pinMode(LED_3, OUTPUT);
  // pinMode(LED_4, OUTPUT);
}

void fadeLeds()
{
  for(int dutyCycle = 0; dutyCycle <= MAX_DUTY_CYCLE; dutyCycle++){
    ledcWrite(PWM_CHANNEL, dutyCycle);
    delay(DELAY_MS);
  }

  for(int dutyCycle = MAX_DUTY_CYCLE; dutyCycle >= 0; dutyCycle--){
    ledcWrite(PWM_CHANNEL, dutyCycle);
    delay(DELAY_MS);
  }
}
