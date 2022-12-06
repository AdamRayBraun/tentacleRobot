Motors motors;

void setupMotors(){
  motors = new Motors(this, motorConfig);
}

class Motors {
  public final byte NUM_MOTORS     = 4;
  public final byte MOTOR_TOP_X    = 1; // SWAPPED
  public final byte MOTOR_TOP_Y    = 0; // SWAPPED
  public final byte MOTOR_BOTTOM_X = 2;
  public final byte MOTOR_BOTTOM_Y = 3;

  public final int maxMotorSteps[] = {10000, 6000, 2000, 2000};//Top Y, X ,BottomX, Y

  private PApplet par;
  private Serial bus;
  private String busPort;
  private int busBaud;
  private boolean SERIAL_DEBUG = false;

  // packet structure
  private final byte packet_len                 = 6;
  private final byte packet_pos_flag            = 1;
  private final byte packet_pos_data            = 2;
  private final byte packet_pos_footer          = packet_len - 1;

  // packet values
  private final byte packet_header              = (byte)0x69;
  private final byte packet_footer              = (byte)0x42;
  private final byte packet_flag_motor_top_x    = (byte)0x10;
  private final byte packet_flag_motor_top_y    = (byte)0x11;
  private final byte packet_flag_motor_bottom_x = (byte)0x12;
  private final byte packet_flag_motor_bottom_y = (byte)0x13;
  private final byte packet_flag_stepper_home   = (byte)0x09;
  private final byte packet_flag_change_state   = (byte)0x60;
  private final byte packet_flag_STOP           = (byte)0xFF;

  private final byte[] motorFlags = {
                                     packet_flag_motor_top_x,
                                     packet_flag_motor_top_y,
                                     packet_flag_motor_bottom_x,
                                     packet_flag_motor_bottom_y
                                    };

  // heartbeat vars
  private long lastHeartbeatCheck;
  private final int heartbeatTimer = 3000;
  private boolean reconnectingArduino = false;

  private byte[] txPacket          = new byte[this.packet_len];

  private int[] lastMotorPositions = new int[4];

  Motors(PApplet par, JSONObject motConfig){
    this.par = par;

    if (!MOTORS_EN) {
      return;
    }

    this.busPort      = motConfig.getString("MOTOR_PORT");
    this.busBaud      = motConfig.getInt("MOTOR_BAUD");
    this.SERIAL_DEBUG = motConfig.getBoolean("SERIAL_DEBUG");

    this.bus = new Serial(this.par, this.busPort, this.busBaud);

    this.txPacket[0]                 = packet_header;
    this.txPacket[packet_pos_footer] = packet_footer;
  }

  public void run(){
    this.uartRx();
    this.checkForBusDropout();
  }

  public void moveMotors(byte motor, int position){
    if (motor < 0 || motor > 3){
      println("ERR: unknown motor index requested to move: " + motor);
      return;
    }

    this.txPacket[this.packet_pos_flag]     = this.motorFlags[motor];
    this.txPacket[this.packet_pos_data]     = byte((position > 0) ? 0 : 1);
    this.txPacket[this.packet_pos_data + 1] = byte((position >> 8) & 0xFF);
    this.txPacket[this.packet_pos_data + 2] = byte(position & 0xFF);
    this.lastMotorPositions[motor]          = position;

    uartTx(this.txPacket);

    gui.topMotorSlider.setValue((float)lastMotorPositions[MOTOR_TOP_X],
                               (float)lastMotorPositions[MOTOR_TOP_Y]);

    gui.bottomMotorSlider.setValue((float)lastMotorPositions[MOTOR_BOTTOM_X],
                                  (float)lastMotorPositions[MOTOR_BOTTOM_Y]);
  }

  public void homeMotors(){
    this.txPacket[this.packet_pos_flag] = this.packet_flag_stepper_home;
    uartTx(this.txPacket);
  }

  private void uartTx(byte[] packet){
    if (!MOTORS_EN){
      return;
    }

    try{
      this.bus.write(packet);
    } catch(Exception e){
      e.printStackTrace();
    }

    if (this.SERIAL_DEBUG){
      String out = "Sending to arduino:\t";
      for (int a = 0; a < packet.length; a++){
        out += hex(packet[a]);
        out += " ";
      }
      println(out);
    }
  }

  private void uartRx(){
    if (!MOTORS_EN){
      return;
    }

    while (this.bus.available() > 0) {
      String rxMsg = this.bus.readStringUntil(10); // 10 = \n
      if (rxMsg != null) {
        println(rxMsg);
      }
    }
    this.bus.clear();
  }

  private void checkForBusDropout(){
    if (!MOTORS_EN){
      return;
    }

    if (millis() - this.lastHeartbeatCheck > this.heartbeatTimer){
      this.lastHeartbeatCheck = millis();
      String[] ports = Serial.list();
      boolean portStillConnected = false;

      // check if arduino port is still found by processing
      for (int p = 0; p < ports.length; p++){
        String[] m1 = match(this.busPort, ports[p]);
        if (m1 != null){
          portStillConnected = true;
          return;
        }
      }

      if (!portStillConnected) this.reconnectingArduino = true;

      if (this.reconnectingArduino){
        try {
          printArray(Serial.list());
          this.bus.clear();
          this.bus.stop();
          this.bus = new Serial(this.par, this.busPort, this.busBaud);
          reconnectingArduino = false;
        } catch(Exception e) {
          println("ERR trying to re-open port, retrying...");
          delay(1000);
        }
      }
    }
  }
}
