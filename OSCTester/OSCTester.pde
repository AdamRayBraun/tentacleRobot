final String BUS_NAME = "/dev/tty.wchusbserial53820015941";

final boolean usingHardware = true;

import peasy.PeasyCam;
import processing.serial.*;

PeasyCam cam;

long lastFrame;
int frameRate = 30;
int boardIndex = 0;

final int anim_none   = 0;
final int anim_simple = 1;
final int anim_noise  = 2;
final int anim_touch  = 3;

int anim_mode = anim_touch;

final int STATE_INDIVIDUAL = 0;
final int STATE_CLUSTERED  = 1;
final int STATE_DEBUG      = 2;

void setup() {
  size(700, 700, P3D);
  cam = new PeasyCam(this, 400);
  setupVertebrae();
  changeNoiseDetail();
}

void draw(){
  background(0);

  switch(anim_mode){
    case anim_simple:
      if (millis() - lastFrame > frameRate){
        for (int v = 0; v < NUM_VERTEBRAE; v++){
          if (v == boardIndex){
            vertebrae.get(v).setLedVals(200, 200, 200, 200);
          } else {
            vertebrae.get(v).setLedVals(0, 0, 0, 0);
          }
        }

        updateAllLeds();

        boardIndex++;
        if (boardIndex > NUM_VERTEBRAE - 1) boardIndex = 0;
        lastFrame = millis();
      }
      break;

    case anim_noise:
      if (millis() - lastFrame > frameRate){
        for (Vertebrae v : vertebrae){
          v.pNoise();
          v.updateLeds();
        }
        lastFrame = millis();
      }
      break;

    case anim_touch:
      for (Vertebrae v : vertebrae){
        v.pNoise();
      }

      if (touched){
        int touchIndex = floor((int)map(mouseY, height, 0, 0, NUM_VERTEBRAE));
        touchIndex = constrain(touchIndex, 0, NUM_VERTEBRAE - 1);
        int touchWidth = (int)(map(mouseX, 0, width, 0, NUM_VERTEBRAE) / 2);
        for (int v = touchIndex - touchWidth; v < touchIndex + touchWidth; v++){
          // byte brightness = (byte)((v - touchIndex) * (255 / touchWidth));
          float brightness = map(abs(v - touchIndex), 0, touchWidth, 255, 0);
          byte b = (byte)brightness;
          if (v >= 0 && v < NUM_VERTEBRAE) vertebrae.get(v).setLedVals(b, b, b, b);
        }
      }

      if (millis() - lastFrame > frameRate){
        updateAllLeds();
        lastFrame = millis();
      }
      break;

    case anim_none:
      if (millis() - lastFrame > frameRate){
        for (Vertebrae v : vertebrae){
          v.setLedVals(0, 0, 0, 0);
          v.updateLeds();
        }
      }
      break;
  }

  for (Vertebrae v : vertebrae){
    v.render();
  }
}

void keyPressed(){
  if (key == '['){
    frameRate--;
    println("new frameRate: " + frameRate);
  } else if (key == ']'){
    frameRate++;
    println("new frameRate: " + frameRate);
  } else if (key == '1'){
    anim_mode = anim_none;
    println("animation off");
  } else if (key == '2'){
    anim_mode = anim_simple;
    println("animation simple");
  } else if (key == '3'){
    anim_mode = anim_noise;
    println("animation noise");
  } else if (key == '4'){
    anim_mode = anim_touch;
    println("animation touch");
  } else if (key == 'q'){
    noiseLod -= 1;
    changeNoiseDetail();
    println("noise Lod: " + noiseLod);
  } else if (key == 'w'){
    noiseLod += 1;
    changeNoiseDetail();
    println("noise Lod: " + noiseLod);
  } else if (key == 'a'){
    noiseFalloff -= 0.05;
    changeNoiseDetail();
    println("noise detail: " + noiseFalloff);
  } else if (key == 's'){
    noiseFalloff += 0.05;
    changeNoiseDetail();
    println("noise detail: " + noiseFalloff);
  } else if (key == 'z'){
    noiseScale -= 0.1;
    println("noiseScale: " + noiseScale);
  } else if (key == 'x'){
    noiseScale += 0.1;
    println("noiseScale: " + noiseScale);
  } else if (key == 't'){
    touched = !touched;
  }
}

void keyReleased(){

}
