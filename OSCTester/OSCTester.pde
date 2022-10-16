import oscP5.*;
import netP5.*;

OscP5 oscP5;

// temp
boolean on;

void setup() {
  oscP5 = new OscP5(this, 9999);

  setupVertebrae();
}

void draw(){}

void mousePressed() {
  if (on){
    for (Vertebrae v : vertebrae){
      if (v.isConnected){
        v.sendLedVals(250, 250, 250, 250);
      }
    }
  } else {
    for (Vertebrae v : vertebrae){
      if (v.isConnected){
        v.sendLedVals(0, 0, 0, 0);
      }
    }
  }

  on = !on;
}

void oscEvent(OscMessage theOscMessage) {
  print("### received : ");
  print(theOscMessage.addrPattern());
  println(" from: " + theOscMessage.netAddress().address());

  switch(theOscMessage.addrPattern()){
    case "/register/":
      int id = int(theOscMessage.get(0).intValue());
      vertebrae.get(id).setupConnection(theOscMessage.netAddress().address());
      break;
    default:
      println("WARN: received OSC w/ unknown addr: " + theOscMessage.addrPattern());
      break;
  }
}
