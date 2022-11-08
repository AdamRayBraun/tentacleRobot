ArrayList<Vertebrae> vertebrae = new ArrayList<Vertebrae>();

int NUM_VERTEBRAE = 25;
int ledSize = 20;

// perlin noise vars
float noiseOffset;
float noiseIncrement = 0.003;
int noiseLod = 15;
float noiseFalloff = 0.25;
float noiseScale = 0.1;

void setupVertebrae(){
  for (int v = 0; v < NUM_VERTEBRAE; v++){
    vertebrae.add(new Vertebrae(v));
  }
}

class Vertebrae {
  private final String ledAddress         = "/led";
  private final String statLedAddress     = "/statLed";
  private final String handShakeAddress   = "/handshake";
  private final String stateChangeAddress = "/newState";
  
  private final int outPort             = 7777;
  private final int heartbeatTimeout    = 15000;

  private NetAddress remoteLocation;
  private String ip;
  private int id;
  private long lastHeartbeat;

  // render vars
  private int ySpacing = 50;
  private int ledRadius = 100;

  public boolean isConnected = false;

  ArrayList<vLED> leds = new ArrayList<vLED>();

  Vertebrae(int id){
    this.id = id;
    leds.add(new vLED(new PVector(-ledRadius, this.id * ySpacing, -ledRadius)));
    leds.add(new vLED(new PVector( ledRadius, this.id * ySpacing, -ledRadius)));
    leds.add(new vLED(new PVector( ledRadius, this.id * ySpacing, ledRadius)));
    leds.add(new vLED(new PVector(-ledRadius, this.id * ySpacing, ledRadius)));
  }

  public void setupConnection(String ip, int id){
    if (this.isConnected){
      println("WARN: this vertebrae already registered, id: " + this.id);
      return;
    }

    this.id = id;
    this.ip = ip;
    this.remoteLocation = new NetAddress(this.ip, this.outPort);
    this.isConnected = true;
    this.lastHeartbeat = millis();
    println("New Vertebrae registered, id: " + id);

    sendHandShake();
  }

  public void sendLedVals(int led1Val, int led2Val, int led3Val, int led4Val){
    leds.get(0).val = led1Val;
    leds.get(1).val = led2Val;
    leds.get(2).val = led3Val;
    leds.get(3).val = led4Val;

    if (!this.isConnected){
      return;
    }

    OscMessage msg = new OscMessage(this.ledAddress);
    msg.add(led1Val);
    msg.add(led2Val);
    msg.add(led3Val);
    msg.add(led4Val);
    oscP5.send(msg, this.remoteLocation);
  }

  public void updateLeds(){
    if (!this.isConnected){
      return;
    }

    OscMessage msg = new OscMessage(this.ledAddress);
    msg.add((int)(leds.get(0).val));
    msg.add((int)(leds.get(1).val));
    msg.add((int)(leds.get(2).val));
    msg.add((int)(leds.get(3).val));
    oscP5.send(msg, this.remoteLocation);
  }

  public void registerHeartbeat(){
    this.lastHeartbeat = millis();
  }

  public void cheackHeartbeat(){
    if (millis() - this.lastHeartbeat > heartbeatTimeout){
      this.isConnected = false;
      println("ERR: vertebrae heartbeat lost, id: " + this.id);
    }
  }

  private void sendHandShake(){
    if (!this.isConnected){
      return;
    }

    OscMessage msg = new OscMessage(this.handShakeAddress);
    msg.add(unhex(IDtoMAC[this.id - 1][0]));
    msg.add(unhex(IDtoMAC[this.id - 1][1]));
    oscP5.send(msg, this.remoteLocation);
  }

  public void updateStatusLed(int r, int g, int b){
    if (!this.isConnected){
      return;
    }

    OscMessage msg = new OscMessage(this.statLedAddress);
    msg.add(r);
    msg.add(g);
    msg.add(b);
    oscP5.send(msg, this.remoteLocation);
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

  public void changeSate(int newState){
    if (newState < 0 || newState > 2){
      println("ERR: trying to send PCB state change with unknown state index: " + newState);
      return;
    }

    OscMessage msg = new OscMessage(this.stateChangeAddress);
    msg.add(newState);
    oscP5.send(msg, this.remoteLocation);
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
