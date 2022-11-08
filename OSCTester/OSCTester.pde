final String BUS_NAME = "/dev/tty.wchusbserial53820015941";

import peasy.PeasyCam;
import processing.serial.*;

PeasyCam cam;

long lastFrame;
int frameRate = 30;
int boardIndex = 0;

final int anim_none   = 0;
final int anim_simple = 1;
final int anim_noise  = 2;
int anim_mode = anim_noise;

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
            vertebrae.get(v).updateLeds();
          } else {
            vertebrae.get(v).setLedVals(0, 0, 0, 0);
            vertebrae.get(v).updateLeds();
          }
        }
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

    case anim_none:
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
  } else if (key == 'q'){
    noiseLod -= 1;
    changeNoiseDetail();
  } else if (key == 'w'){
    noiseLod += 1;
    changeNoiseDetail();
  } else if (key == 'a'){
    noiseFalloff -= 0.05;
    changeNoiseDetail();
  } else if (key == 's'){
    noiseFalloff += 0.05;
    changeNoiseDetail();
  } else if (key == 'z'){
    noiseScale -= 0.1;
    println("noiseScale: " + noiseScale);
  } else if (key == 'x'){
    noiseScale += 0.1;
    println("noiseScale: " + noiseScale);
  }
}
