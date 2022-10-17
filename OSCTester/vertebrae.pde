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

  public boolean isConnected = false;

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
    if (!this.isConnected){
      println("ERR: vertebrae id: " + this.id + " is being ran but not connected");
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
}
