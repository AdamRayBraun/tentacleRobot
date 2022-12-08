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
  public ArrayList<vLED> leds = new ArrayList<vLED>();

  // touch vars
  public int lastTouchPoll = 70;
  public long lastTouchTime;
  public int touchHighlightTime = 2000;

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
    changeLightBasedOnTouch();

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

  private void changeLightBasedOnTouch(){
    long timeSinceTouch = millis() - this.lastTouchTime;

    if (timeSinceTouch < this.touchHighlightTime){
      pNoise(false);
      for (vLED l : this.leds){
        l.val = map(timeSinceTouch, 0, this.touchHighlightTime, 255, l.noiseVal);
      }
      this.neoR = this.neoG = this.neoB = (byte)constrain(this.leds.get(0).val, 0, 255);
    } else {
      pNoise(true);
      this.neoR = 0;
      this.neoG = 0;
      this.neoB = 0;
    }
  }

  public void updateTouchPollPacket(boolean broadcast){
    this.txPacket[1] = this.packet_flag_touchPoll_Q;
    this.txPacket[2] = broadcast ? broadcastAdr : pcbVertebrae.addresses[this.id];
  }

  public void updateTouchThreshold(byte newThresh, boolean broadcast){
    this.txPacket[1] = this.packet_flag_touchThresh;
    this.txPacket[2] = broadcast ? broadcastAdr : pcbVertebrae.addresses[this.id];
    this.txPacket[3] = newThresh;
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

  public void pNoise(boolean updateVal){
    for (vLED l : leds){
      l.perlinNoise();
      if (updateVal) l.val = l.noiseVal;
    }
    noiseOffset += noiseIncrement;
  }
}

class vLED{
  public PVector loc;
  public float val;
  public float noiseVal;
  private int ledSize = 10;

  vLED(PVector loc){
    this.loc = loc;
  }

  public void perlinNoise(){
    this.noiseVal = (noise(this.loc.x * noiseScale, (this.loc.y * noiseScale) + noiseOffset , this.loc.z * noiseScale) * 60);
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
