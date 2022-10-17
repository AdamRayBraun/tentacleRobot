import oscP5.*;
import netP5.*;
import peasy.PeasyCam;

PeasyCam cam;
OscP5 oscP5;

// temp
int b;
int bChange = 5;
boolean animating = false;
long lastFrame;
// int frameRate = 20;
int frameRate = 200;

int boardIndex = 0;

void setup() {
  size(800, 800, P3D);
  oscP5 = new OscP5(this, 9999);
  cam = new PeasyCam(this, 400);
  setupVertebrae();
}

void draw(){
  background(0);
  if (animating){
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
  } else if (key == ' '){
    animating = !animating;
    println("animating : " + animating);
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
    default:
      println("WARN: received OSC w/ unknown addr: " + theOscMessage.addrPattern());
      break;
  }
}
