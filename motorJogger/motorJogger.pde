import processing.serial.*;

String ARDUINO_PORT = "/dev/tty.usbmodem1464401";


final byte packet_len = 6;
Serial bus;

byte[] txPacket = new byte[packet_len];

int topXPos;
int topYPos;
int bottomXPos;
int bottomYPos;

int jogAmount = 100;

void setup(){
  size(400, 400);
  bus = new Serial(this, ARDUINO_PORT, 115200);
  txPacket[0] = (byte)0x69;
  txPacket[5] = (byte)0x42;
}

void draw(){
  background(0);
  fill(255);
  textSize(15);
  String gui = " topX:  " + topXPos + "  q & w\n topY:  " + topYPos + "  a & s\n bottomX:  " + bottomXPos + "  o & p\n bottomY:  " + bottomYPos + "  k & l";
  text(gui, 50, 50);

  while (bus.available() > 0) {
    String rxMsg = bus.readStringUntil(10); // 10 = \n
    if (rxMsg != null) {
      println(rxMsg);
    }
  }
  bus.clear();
}

void sendMotorMsg(byte motor, int val){
  byte dir = (byte)((val > 0) ? 0 : 1);

  txPacket[1] = motor;
  txPacket[2] = dir;
  txPacket[3] = byte((val >> 8) & 0xFF);;
  txPacket[4] = byte(val & 0xFF);

  bus.write(txPacket);

  String out = "Sending to arduino:\t";
  for (int a = 0; a < txPacket.length; a++){
    out += hex(txPacket[a]);
    out += " ";
  }
  println(out);
}

void keyPressed(){
 // top X
 if (key == 'q'){
   topXPos -= jogAmount;
   sendMotorMsg((byte)0x10, topXPos);
 } else if (key == 'w'){
   topXPos += jogAmount;
   sendMotorMsg((byte)0x10, topXPos);
 }

 // top Y
 if (key == 'a'){
   topYPos -= jogAmount;
   sendMotorMsg((byte)0x11, topYPos);
 } else if (key == 's'){
   topYPos += jogAmount;
   sendMotorMsg((byte)0x11, topYPos);
 }

 // bottom X
 if (key == 'o'){
   bottomXPos -= jogAmount;
   sendMotorMsg((byte)0x12, bottomXPos);
 } else if (key == 'p'){
   bottomXPos += jogAmount;
   sendMotorMsg((byte)0x12, bottomXPos);
 }

 // bottom Y
 if (key == 'k'){
   bottomYPos -= jogAmount;
   sendMotorMsg((byte)0x13, bottomYPos);
 } else if (key == 'l'){
   bottomYPos += jogAmount;
   sendMotorMsg((byte)0x13, bottomYPos);
 }
}
