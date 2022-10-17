import oscP5.*;
import netP5.*;

OscP5 oscP5;

// temp
int b;
int bChange = 5;
boolean animating = false;
long lastFrame;
int frameRate = 20;

void setup() {
  oscP5 = new OscP5(this, 9999);

  setupVertebrae();
}

void draw(){
  if (animating){
    if (millis() - lastFrame > frameRate){
      b += bChange;

      if (b > 255 || b < 0 ) bChange *= -1;

      for (Vertebrae v : vertebrae){
        if (v.isConnected){
          v.sendLedVals(b, b, b, b);
        }
      }

      lastFrame = millis();
    }
  }

  for (Vertebrae v : vertebrae){
    if (v.isConnected){
      v.cheackHeartbeat();
    }
  }
}

void keyPressed(){
  if (key == '['){
    frameRate--;
  } else if (key == ']'){
    frameRate++;
  }
  println("new frameRate: " + frameRate);
}

void mousePressed() {
  animating = !animating;
  println("animating : " + animating);
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
