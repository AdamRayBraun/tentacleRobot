// perlin noise vars
float noiseOffset;
float noiseIncrement = 0.003;
int noiseLod = 1;
float noiseFalloff = 1;
float noiseScale = 0.1;

Vertebrae pcbVertebrae;

void setupVertebrae(){
  pcbVertebrae = new Vertebrae(this, PCBConfig);
}

class Vertebrae{
  public final int NUM_VERTEBRAE = 20;
  public final byte[] addresses = {
                                    3, 4, 5, 25, 7, 8, 9, 10, 11, 12, 13,
                                    14, 15, 16, 17, 18, 19, 20, 21, 22
                                  };

  public ArrayList<Vertebra> vertebrae = new ArrayList<Vertebra>();

  public boolean selectPCB = false;
  public int selectPCBIndex = 0;

  private PApplet par;

  private Serial bus;
  private String busPort;
  private int busBaud;
  private boolean SERIAL_DEBUG = false;

  // packet flags
  private final byte packet_header           = (byte)0x69;
  private final byte packet_footer           = (byte)0x42;
  private final byte packet_len              = 11;

  private final byte packet_flag_touch       = (byte)0x30;
  private final byte packet_flag_touchPoll_A = (byte)0x33;

  Vertebrae(PApplet par, JSONObject conf){
    this.par = par;

    this.busPort      = conf.getString("PCB_PORT");
    this.busBaud      = conf.getInt("PCB_BAUD");
    this.SERIAL_DEBUG = conf.getBoolean("SERIAL_DEBUG");

    for (byte v = 0; v < NUM_VERTEBRAE; v++){
      this.vertebrae.add(new Vertebra(v));
    }

    if (!PCBS_EN) {
      return;
    }

    this.bus = new Serial(this.par, this.busPort, this.busBaud);
  }

  public void updateAllLeds(){
    if (!PCBS_EN) {
      return;
    }

    for (byte v = 0; v < this.NUM_VERTEBRAE; v++){
      this.vertebrae.get(v).updateLedPacket();
      this.bus.write(this.vertebrae.get(v).txPacket);
    }
  }

  public void changeNoiseDetail(){
    noiseDetail(noiseLod, noiseFalloff);
    println("Noise lod: " + noiseLod + " , falloff: " + noiseFalloff);
  }

  public void checkForPCBTouch(){
    if (!PCBS_EN) {
      return;
    }

    while (this.bus.available() > 0) {
      byte[] rxBuffer = new byte[this.packet_len];
      this.bus.readBytesUntil(this.packet_footer, rxBuffer);

      if (rxBuffer == null) return;

      if (rxBuffer[0] == this.packet_header){
        switch(rxBuffer[1]){
          case packet_flag_touch:
            handleRecievedTouch(int(rxBuffer[2]), int(rxBuffer[3]));

            if (this.SERIAL_DEBUG){
              print("touch from: ");
              print(rxBuffer[2]);
              print(", short touch: ");
              println(rxBuffer[3]);
            }
            break;

          case packet_flag_touchPoll_A:
            handleReceivedTouchPoll(rxBuffer[2], rxBuffer[3]);

            if (this.SERIAL_DEBUG){
              print("poll from: ");
              print(rxBuffer[2]);
              print(": ");
              println(rxBuffer[3]);
            }
            break;
        }
      }
    }
    this.bus.clear();
  }

  public void sendTouchPoll(){
    if (!PCBS_EN) {
      return;
    }

    if (this.selectPCB){
      this.vertebrae.get(this.selectPCBIndex).updateTouchPollPacket(false);
      this.bus.write(this.vertebrae.get(this.selectPCBIndex).txPacket);
    } else {
      this.vertebrae.get(0).updateTouchPollPacket(true);
      this.bus.write(this.vertebrae.get(0).txPacket);
    }
  }

  public void sendOTAMsg(){
    if (!PCBS_EN) {
      return;
    }

    if (this.selectPCB){
      this.vertebrae.get(this.selectPCBIndex).updateOTAPacket(false);
      this.bus.write(this.vertebrae.get(this.selectPCBIndex).txPacket);
    } else {
      this.vertebrae.get(0).updateOTAPacket(true);
      this.bus.write(this.vertebrae.get(0).txPacket);
    }
  }

  public void render(){
    for (Vertebra v : vertebrae){
      v.render();
    }

    if (this.selectPCB){
      vertebrae.get(selectPCBIndex).renderHighlight();
    }
  }
}



class Vertebra {
  // UART vars
  private final byte packet_header           = (byte)0x69;
  private final byte packet_footer           = (byte)0x42;
  private final byte packet_flag_led         = (byte)0x10;
  private final byte packet_flag_touchThresh = (byte)0x20;
  private final byte packet_flag_touchPoll_Q = (byte)0x22;
  private final byte packet_flag_ota         = (byte)0x30;
  private final byte packet_len              = 11;

  private final byte broadcastAdr            = (byte)0x68;

  public byte[] txPacket = new byte[packet_len];

  private byte id;

  // LED render vars
  private int ySpacing = 50;
  private int yPos;
  private int yOffset = 700;
  private int ledRadius = 40;

  // LED mem vars
  public byte neoR, neoG, neoB;
  private ArrayList<vLED> leds = new ArrayList<vLED>();

  // touch vars
  public int lastTouchPoll = 70;

  Vertebra(byte id){
    this.id = id;
    this.yPos = (this.id * this.ySpacing) + this.yOffset;
    this.leds.add(new vLED(new PVector(-this.ledRadius, this.yPos, -this.ledRadius)));
    this.leds.add(new vLED(new PVector( this.ledRadius, this.yPos, -this.ledRadius)));
    this.leds.add(new vLED(new PVector( this.ledRadius, this.yPos,  this.ledRadius)));
    this.leds.add(new vLED(new PVector(-this.ledRadius, this.yPos,  this.ledRadius)));

    this.txPacket[0]                   = this.packet_header;
    this.txPacket[this.packet_len - 1] = this.packet_footer;
  }

  public void setLedVals(int led1Val, int led2Val, int led3Val, int led4Val){
    this.leds.get(0).val = led1Val;
    this.leds.get(1).val = led2Val;
    this.leds.get(2).val = led3Val;
    this.leds.get(3).val = led4Val;
  }

  public void updateLedPacket(){
    this.txPacket[1] = this.packet_flag_led;
    this.txPacket[2] = pcbVertebrae.addresses[this.id];
    this.txPacket[3] = (byte)this.leds.get(0).val;
    this.txPacket[4] = (byte)this.leds.get(1).val;
    this.txPacket[5] = (byte)this.leds.get(2).val;
    this.txPacket[6] = (byte)this.leds.get(3).val;
    this.txPacket[7] = this.neoR;
    this.txPacket[8] = this.neoG;
    this.txPacket[9] = this.neoB;
  }

  public void updateTouchPollPacket(boolean broadcast){
    this.txPacket[1] = this.packet_flag_touchPoll_Q;
    this.txPacket[2] = broadcast ? broadcastAdr : pcbVertebrae.addresses[this.id];
  }

  public void updateOTAPacket(boolean broadcast){
    this.txPacket[1] = this.packet_flag_ota;
    this.txPacket[2] = broadcast ? broadcastAdr : pcbVertebrae.addresses[this.id];
  }

  public void updateStatusLed(byte r, byte g, byte b){
    this.neoR = r;
    this.neoG = g;
    this.neoB = b;
  }

  public void registerTouch(int touchedSide, int shortTouch){
    switch(touchedSide){
      case 1:
        println("Vert " + this.id + " touched on side: 1");
        break;
      case 2:
        println("Vert " + this.id + " touched on side: 2");
        break;
    }
  }

  public void render(){
    for (vLED l : leds){
      l.render();
    }

    if (!showTouchPoll) return;

    fill(255);
    textSize(20);
    pushMatrix();
    translate(this.ledRadius * 2, this.yPos, 0);
    text(this.lastTouchPoll, 0, 0);
    popMatrix();
  }

  public void renderHighlight(){
    pushMatrix();
    translate(0, this.yPos, 0);
    noFill();
    strokeWeight(1);
    stroke(255);
    box(this.ledRadius * 3, this.ySpacing / 2, this.ledRadius * 3);
    popMatrix();
  }

  public void pNoise(){
    for (vLED l : leds){
      l.pNoise();
    }
    noiseOffset += noiseIncrement;
  }
}

class vLED{
  public PVector loc;
  public float val;
  private int ledSize = 10;

  vLED(PVector loc){
    this.loc = loc;
  }

  public void pNoise(){
    this.val = noise(this.loc.x * noiseScale, (this.loc.y * noiseScale) + noiseOffset , this.loc.z * noiseScale) * 60;
  }

  public void render(){
    pushMatrix();
    translate(this.loc.x, this.loc.y, this.loc.z);
    strokeWeight(1);
    stroke(255);
    fill(this.val);
    box(this.ledSize);
    popMatrix();
  }
}
