import mqtt.*;

MQTTClient client;

boolean led1, led2, led3, led4 = false;
double lastAnimUpdate;
int allLedBrightness;

void setup() {
  client = new MQTTClient(this);
  client.connect("mqtt://localhost", "processing");
}

void draw(){
  // if (millis() - lastAnimUpdate > animFrameRate){
  //   if (3)
  //   allLedBrightness++;
  //   client.publish("50:24/ledAll", String(allLedBrightness));
  //   lastAnimUpdate = millis();
  // }
}

void keyPressed() {
  client.publish("esp32/output", "on");

  if (key == '1'){
    led1 = !led1;
    String value = (led1) ? "0" : "255";
    client.publish("50:24/led1", value);
  } else if (key == '2'){
    led2 = !led2;
    String value = (led2) ? "0" : "255";
    client.publish("50:24/led2", value);
  } else if (key == '3'){
    led3 = !led3;
    String value = (led3) ? "0" : "255";
    client.publish("50:24/led3", value);
  } else if (key == '4'){
    led4 = !led4;
    String value = (led4) ? "0" : "255";
    client.publish("50:24/led4", value);
  }
}

void clientConnected() {
  println("client connected");

  client.subscribe("50:24/heartbeat");
}

void messageReceived(String topic, byte[] payload) {
  println("new message: " + topic + " - " + new String(payload));
}

void connectionLost() {
  println("connection lost");
}
