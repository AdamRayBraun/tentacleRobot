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

void runVertebrae(){
  pcbVertebrae.handleTouchRx();
}

class Vertebrae{
  public final int NUM_VERTEBRAE = 20;
  public final byte[] addresses = {
                                    3, 4, 5, 25, 7, 8, 9, 10, 11, 12, 13,
                                    14, 15, 16, 17, 18, 19, 20, 21, 22
                                  };

  private PApplet par;

  private ArrayList<Vertebra> vertebrae = new ArrayList<Vertebra>();

  private Serial bus;
  private String busPort;
  private int busBaud;
  private boolean SERIAL_DEBUG = false;

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
    for (byte v = 0; v < this.NUM_VERTEBRAE; v++){
      this.vertebrae.get(v).updateLedPacket();
      this.bus.write(this.vertebrae.get(v).txPacket);
    }
  }

  public void changeNoiseDetail(){
    noiseDetail(noiseLod, noiseFalloff);
    println("Noise lod: " + noiseLod + " , falloff: " + noiseFalloff);
  }

  public void handleTouchRx(){
    if (!PCBS_EN) {
      return;
    }

    while (this.bus.available() > 0) {
      String rxMsg = this.bus.readStringUntil(10); // 10 = \n
      if (rxMsg != null) {
        String[] list = split(rxMsg, ',');

        if (this.SERIAL_DEBUG){
          print("touch from: ");
          println(list[0]);
        }
      }
    }
    this.bus.clear();
  }
}



class Vertebra {
  public byte neoR, neoG, neoB;

  // UART vars
  private final byte packet_header   = (byte)0x69;
  private final byte packet_footer   = (byte)0x42;
  private final byte packet_flag_led = (byte)0x10;
  private final byte packet_len      = 11;

  public byte[] txPacket = new byte[packet_len];

  private byte id;
  private int ySpacing = 50;
  private int ledRadius = 100;
  private ArrayList<vLED> leds = new ArrayList<vLED>();

  Vertebra(byte id){
    this.id = id;
    this.leds.add(new vLED(new PVector(-this.ledRadius, this.id * this.ySpacing, -this.ledRadius)));
    this.leds.add(new vLED(new PVector( this.ledRadius, this.id * this.ySpacing, -this.ledRadius)));
    this.leds.add(new vLED(new PVector( this.ledRadius, this.id * this.ySpacing, this.ledRadius)));
    this.leds.add(new vLED(new PVector(-this.ledRadius, this.id * this.ySpacing, this.ledRadius)));

    txPacket[0]                   = this.packet_header;
    txPacket[1]                   = this.packet_flag_led;
    txPacket[this.packet_len - 1] = this.packet_footer;
  }

  public void setLedVals(int led1Val, int led2Val, int led3Val, int led4Val){
    this.leds.get(0).val = led1Val;
    this.leds.get(1).val = led2Val;
    this.leds.get(2).val = led3Val;
    this.leds.get(3).val = led4Val;
  }

  public void updateLedPacket(){
    this.txPacket[2] = pcbVertebrae.addresses[this.id];
    this.txPacket[3] = (byte)this.leds.get(0).val;
    this.txPacket[4] = (byte)this.leds.get(1).val;
    this.txPacket[5] = (byte)this.leds.get(2).val;
    this.txPacket[6] = (byte)this.leds.get(3).val;
    this.txPacket[7] = this.neoR;
    this.txPacket[8] = this.neoG;
    this.txPacket[9] = this.neoB;
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
  private int ledSize = 20;

  vLED(PVector loc){
    this.loc = loc;
  }

  public void pNoise(){
    this.val = noise(this.loc.x * noiseScale, (this.loc.y * noiseScale) + noiseOffset , this.loc.z * noiseScale) * 60;
  }

  public void render(){
    pushMatrix();
    translate(this.loc.x, this.loc.y, this.loc.z);
    stroke(200);
    fill(this.val);
    box(this.ledSize);
    popMatrix();
  }
}
