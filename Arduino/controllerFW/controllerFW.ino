/*

Joystick controller to manually control Isaac.
Reads joystick / button states and sends to main SW sketch

compiled for Arduino uno
*/

// pin connections
#define LEFT_X     A4
#define LEFT_Y     A5
#define LEFT_BUTT  6
#define RIGHT_X    A0
#define RIGHT_Y    A1
#define RIGHT_BUTT 7

// packet structure :
// header, LX1, LX2, LY, LY2, LB, RX1, RX2, RY1, RY2, RB, footer
// analog joystick pot readings split across two bytes for better resolution
#define PACKET_LEN    12
#define PACKET_HEADER 0x69
#define PACKET_FOOTER 0x42

#define debounceDelay 50
#define uartUpdatePeriod 15

int lXpos, lYpos, rXpos, rYpos;

unsigned long lastLDebounce, lastRDebounce, lastUartUpdate;
bool lastLState, lastRState, lState, rState;

byte txBuff[PACKET_LEN];

void setup()
{
  Serial.begin(115200);

  txBuff[0]              = PACKET_HEADER;
  txBuff[PACKET_LEN - 1] = PACKET_FOOTER;

  pinMode(LEFT_X, INPUT);
  pinMode(LEFT_Y, INPUT);
  pinMode(LEFT_BUTT, INPUT_PULLUP);
  pinMode(RIGHT_X, INPUT);
  pinMode(RIGHT_Y, INPUT);
  pinMode(RIGHT_BUTT, INPUT_PULLUP);
}

void loop()
{
  lXpos = analogRead(LEFT_X);
  lYpos = analogRead(LEFT_Y);
  rXpos = analogRead(RIGHT_X);
  rYpos = analogRead(RIGHT_Y);

  debounceButtons();

  if (millis() - lastUartUpdate > uartUpdatePeriod){
    sendUpdate();
    lastUartUpdate = millis();
  }
}

void sendUpdate()
{
  txBuff[1]  = (lXpos >> 8) && 0xFF;
  txBuff[2]  = lXpos && 0xFF;
  txBuff[3]  = (lYpos >> 8) && 0xFF;
  txBuff[4]  = lYpos && 0xFF;

  if (lState){
    txBuff[5] = 1;
    lState = !lState;
  }

  txBuff[6]  = (rXpos >> 8) && 0xFF;
  txBuff[7]  = rXpos && 0xFF;
  txBuff[8]  = (rYpos >> 8) && 0xFF;
  txBuff[9]  = rYpos && 0xFF;

  if (rState){
    txBuff[10] = 1;
    rState = !rState;
  }

  Serial.write(txBuff, PACKET_LEN);
}

void debounceButtons()
{
  unsigned long rightNow = millis();
  bool lReading = digitalRead(LEFT_BUTT);
  bool rReading = digitalRead(RIGHT_BUTT);

  if (lReading != lastLState) lastLDebounce = rightNow;
  if (rReading != lastRState) lastRDebounce = rightNow;

  if (rightNow - lastLDebounce > debounceDelay){
    if (lReading != lState){
      lState = lReading;
    }
  }

  if (rightNow - lastRDebounce > debounceDelay){
    if (rReading != rState){
      rState = rReading;
    }
  }

  lastLState = lReading;
  lastRState = rReading;
}
