ArrayList<Vertebrae> vertebrae = new ArrayList<Vertebrae>();

int NUM_VERTEBRAE = 25;

void setupVertebrae(){
  for (int v = 0; v < NUM_VERTEBRAE; v++){
    vertebrae.add(new Vertebrae(v));
  }
}

class Vertebrae {
  private final int outPort = 7777;
  private final String ledAddress = "/led";
  private NetAddress remoteLocation;
  private int id;
  private String ip;

  public boolean isConnected = false;

  Vertebrae(int id){
    this.id = id;
  }

  public void setupConnection(String ip){
    if (this.isConnected){
      println("WARN: this vertebrae already registered, id: " + this.id);
      return;
    }

    this.ip = ip;
    this.remoteLocation = new NetAddress(this.ip, this.outPort);
    this.isConnected = true;
    println("New Vertebrae registered, id: " + id);
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

    println("MSG sent, to IP : " + this.ip);
  }
}
