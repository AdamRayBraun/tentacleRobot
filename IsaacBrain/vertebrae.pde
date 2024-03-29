// perlin noise vars
float noiseOffset;
float noiseIncrement = 0.003;
int noiseLod = 1;
float noiseFalloff = 1;
float noiseScale = 0.1;
float pcbLedBrightness = 60;
Vertebrae pcbVertebrae;

byte touchThresh = 50;

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

  // touch poll flags
  public boolean polling = false;
  private long lastTouchPoll;
  private int touchPollFreq = 3000;

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
      sendPacket(this.vertebrae.get(v).txPacket);
    }
  }

  public void changeNoiseDetail(){
    noiseDetail(noiseLod, noiseFalloff);
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

  public void handleTouchPolling(){
    if (!this.polling) return;

    if (millis() - lastTouchPoll < touchPollFreq) return;

    if (this.selectPCB){
      this.vertebrae.get(this.selectPCBIndex).updateTouchPollPacket(false);
      sendPacket(this.vertebrae.get(this.selectPCBIndex).txPacket);
    } else {
      this.vertebrae.get(0).updateTouchPollPacket(true);
      sendPacket(this.vertebrae.get(0).txPacket);
    }

    this.lastTouchPoll = millis();
  }

  public void sendTouchThreshUpdate(){
    if (this.selectPCB){
      this.vertebrae.get(this.selectPCBIndex).updateTouchThreshold(touchThresh, false);
      sendPacket(this.vertebrae.get(this.selectPCBIndex).txPacket);
    } else {
      this.vertebrae.get(0).updateTouchThreshold(touchThresh, true);
      sendPacket(this.vertebrae.get(0).txPacket);
    }
  }

  public void sendOTAMsg(){
    if (this.selectPCB){
      this.vertebrae.get(this.selectPCBIndex).updateOTAPacket(false);
      sendPacket(this.vertebrae.get(this.selectPCBIndex).txPacket);
    } else {
      this.vertebrae.get(0).updateOTAPacket(true);
      sendPacket(this.vertebrae.get(0).txPacket);
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

  private void sendPacket(byte[] packet){
    if (!PCBS_EN) {
      return;
    }

    this.bus.write(packet);
  }
}
