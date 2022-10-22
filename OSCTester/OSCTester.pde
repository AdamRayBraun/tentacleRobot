import oscP5.*;
import netP5.*;
import peasy.PeasyCam;

PeasyCam cam;
OscP5 oscP5;

// temp
int b;
int bChange = 5;
long lastFrame;
// int frameRate = 20;
int frameRate = 10;

int boardIndex = 0;

final int anim_none   = 0;
final int anim_simple = 1;
final int anim_noise  = 2;
int anim_mode = anim_noise;

void setup() {
  size(700, 700, P3D);
  oscP5 = new OscP5(this, 9999);
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
            vertebrae.get(v).sendLedVals(200, 200, 200, 200);
          } else {
            vertebrae.get(v).sendLedVals(0, 0, 0, 0);
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
    if (v.isConnected){
      v.cheackHeartbeat();
    }
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

void oscEvent(OscMessage theOscMessage) {
  switch(theOscMessage.addrPattern()){
    case "/register/":
      int id = int(theOscMessage.get(0).intValue());
      vertebrae.get(id).setupConnection(theOscMessage.netAddress().address(), id);
      break;
    case "/heartbeat/":
      vertebrae.get(theOscMessage.get(0).intValue()).registerHeartbeat();
      break;
    case "/touchVal/":
      vertebrae.get(theOscMessage.get(0).intValue()).registerTouch(theOscMessage.get(0).intValue(), theOscMessage.get(0).intValue());
      println(theOscMessage.get(0).intValue());
      break;
    case "/touchValDebug/":
      println(theOscMessage.get(0).intValue() + " with touch values of " + theOscMessage.get(1).intValue() + ", " + theOscMessage.get(2).intValue());
      break;
    default:
      println("WARN: received OSC w/ unknown addr: " + theOscMessage.addrPattern());
      break;
  }
}
