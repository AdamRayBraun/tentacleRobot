ArrayList<Vertebrae> vertebrae = new ArrayList<Vertebrae>();

int NUM_VERTEBRAE = 25;

void setupVertebrae(){
  for (int v = 0; v < NUM_VERTEBRAE; v++){
    vertebrae.add(new Vertebrae(v));
  }
}

class Vertebrae {
  private final String ledAddress       = "/led";
  private final String handShakeAddress = "/handshake";
  private final int outPort             = 7777;
  private final int heartbeatTimeout    = 15000;

  private NetAddress remoteLocation;
  private String ip;
  private int id;
  private long lastHeartbeat;

  // render vars
  private int ySpacing = 50;
  private int ledRadius = 100;
  private int ledSize = 20;

  public boolean isConnected = false;

  int[] ledVals = { 0, 0, 0, 0};

  Vertebrae(int id){
    this.id = id;
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
    ledVals[0] = led1Val;
    ledVals[1] = led2Val;
    ledVals[2] = led3Val;
    ledVals[3] = led4Val;
    
    if (!this.isConnected){
      // println("ERR: vertebrae id: " + this.id + " is being ran but not connected");
      return;
    }

    OscMessage msg = new OscMessage(this.ledAddress);
    msg.add(led1Val);
    msg.add(led2Val);
    msg.add(led3Val);
    msg.add(led4Val);
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
    OscMessage msg = new OscMessage(this.handShakeAddress);
    msg.add(unhex(IDtoMAC[this.id - 1][0]));
    msg.add(unhex(IDtoMAC[this.id - 1][1]));
    oscP5.send(msg, this.remoteLocation);
  }

  public void render(){
    pushMatrix();

    stroke(100);

    translate(0, this.id * ySpacing, 0);
    translate(-ledRadius, 0, 0);
    fill(this.ledVals[0]);
    box(ledSize);

    translate(+ledRadius, 0, +ledRadius);
    fill(this.ledVals[1]);
    box(ledSize);

    translate(+ledRadius, 0, -ledRadius);
    fill(this.ledVals[2]);
    box(ledSize);

    translate(-ledRadius, 0, -ledRadius);
    fill(this.ledVals[3]);
    box(ledSize);

    popMatrix();
  }
}
