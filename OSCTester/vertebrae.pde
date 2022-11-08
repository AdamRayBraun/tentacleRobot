ArrayList<Vertebrae> vertebrae = new ArrayList<Vertebrae>();

int NUM_VERTEBRAE = 20;
byte[] ids = {3, 4, 5, 25, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22};
int ledSize = 20;

// UART vars
Serial bus;
final byte packet_header   = (byte)0x69;
final byte packet_footer   = (byte)0x42;
final byte packet_flag_led = (byte)0x10;
final byte packet_len      = 11;

// perlin noise vars
float noiseOffset;
float noiseIncrement = 0.003;
int noiseLod = 15;
float noiseFalloff = 0.25;
float noiseScale = 0.1;

void setupVertebrae(){
  bus = new Serial(this, BUS_NAME, 115200);

  for (int v = 0; v < NUM_VERTEBRAE; v++){
    vertebrae.add(new Vertebrae(ids[v]));
  }
}

class Vertebrae {
  private byte id;
  private int ySpacing = 50;
  private int ledRadius = 100;
  byte[] txPacket = new byte[packet_len];

  ArrayList<vLED> leds = new ArrayList<vLED>();

  public byte neoR, neoG, neoB;

  Vertebrae(byte id){
    this.id = id;
    leds.add(new vLED(new PVector(-ledRadius, this.id * ySpacing, -ledRadius)));
    leds.add(new vLED(new PVector( ledRadius, this.id * ySpacing, -ledRadius)));
    leds.add(new vLED(new PVector( ledRadius, this.id * ySpacing, ledRadius)));
    leds.add(new vLED(new PVector(-ledRadius, this.id * ySpacing, ledRadius)));

    txPacket[0]              = packet_header;
    txPacket[1]              = packet_flag_led;
    txPacket[packet_len - 1] = packet_footer;
  }

  public void setLedVals(int led1Val, int led2Val, int led3Val, int led4Val){
    leds.get(0).val = led1Val;
    leds.get(1).val = led2Val;
    leds.get(2).val = led3Val;
    leds.get(3).val = led4Val;
  }

  public void updateLeds(){
    txPacket[2] = this.id;
    txPacket[3] = (byte)leds.get(0).val;
    txPacket[4] = (byte)leds.get(1).val;
    txPacket[5] = (byte)leds.get(2).val;
    txPacket[6] = (byte)leds.get(3).val;
    txPacket[7] = neoR;
    txPacket[8] = neoG;
    txPacket[9] = neoB;

    bus.write(txPacket);
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

  vLED(PVector loc){
    this.loc = loc;
  }

  public void pNoise(){
    this.val = noise(this.loc.x * noiseScale, (this.loc.y * noiseScale) + noiseOffset , this.loc.z * noiseScale) * 255;
  }

  public void render(){
    pushMatrix();
    translate(this.loc.x, this.loc.y, this.loc.z);
    stroke(200);
    fill(this.val);
    box(ledSize);
    popMatrix();
  }
}

void changeNoiseDetail(){
  noiseDetail(noiseLod,noiseFalloff);
  println("Noise lod: " + noiseLod + " , falloff: " + noiseFalloff);
}
