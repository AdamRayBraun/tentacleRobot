long lastLedFrame;
int ledFrameRate = 30;
int ledBoardIndex = 0;

final int anim_none         = 0;
final int anim_simple       = 1;
final int anim_noise        = 2;
final int anim_touch        = 3;
final int anim_touch_noise  = 4;

int anim_mode = anim_simple;

final int STATE_INDIVIDUAL = 0;
final int STATE_CLUSTERED  = 1;
final int STATE_DEBUG      = 2;

boolean touched   = false;
boolean touchDrag = false;

void animateLeds(){
  switch(anim_mode){
    case anim_simple:
      if (millis() - lastLedFrame > ledFrameRate){
        for (int v = 0; v < pcbVertebrae.NUM_VERTEBRAE; v++){
          if (v == ledBoardIndex){
            pcbVertebrae.vertebrae.get(v).setLedVals(200, 200, 200, 200);
          } else {
            pcbVertebrae.vertebrae.get(v).setLedVals(0, 0, 0, 0);
          }
        }

        pcbVertebrae.updateAllLeds();

        ledBoardIndex++;
        if (ledBoardIndex > pcbVertebrae.NUM_VERTEBRAE - 1) ledBoardIndex = 0;
        lastLedFrame = millis();
      }
      break;

    case anim_noise:
      if (millis() - lastLedFrame > ledFrameRate){
        for (Vertebra v : pcbVertebrae.vertebrae){
          v.pNoise();
        }
        pcbVertebrae.updateAllLeds();
        lastLedFrame = millis();
      }
      break;

    case anim_touch_noise:
      if (millis() - lastLedFrame > ledFrameRate){
        pcbVertebrae.updateAllLeds();
        lastLedFrame = millis();
      }
      break;

    case anim_none:
      if (millis() - lastLedFrame > ledFrameRate){
        for (Vertebra v : pcbVertebrae.vertebrae){
          v.setLedVals(0, 0, 0, 0);
        }
        pcbVertebrae.updateAllLeds();
        lastLedFrame = millis();
      }
      break;
  }
}
