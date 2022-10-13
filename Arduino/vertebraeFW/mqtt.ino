#ifdef EN_MQTT

#define ssid            "H&M"
#define password        "weLoveInternetting"
#define heartbeatPeriod 8000

const char* mqtt_laptop_server = "192.168.194.105";
const char* broadCastTopic     = "broadcast";

WiFiClient espClient;
PubSubClient client(espClient);
String idRxTopicBase, ledTopic1, ledTopic2, ledTopic3, ledTopic4, ledTopicAll, heartbeatTopic;

unsigned long lastMqttHeartbeat;

void setup_wifi()
{
  delay(10);

  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  unsigned long wifiTimeOut = millis();
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");

    if (millis() - wifiTimeOut > 20000){
      Serial.println("ERR: Timed out trying to connect to wifi for NTP, restarting...");
      delay(2000);
      ESP.restart();
    }
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.print("MAC: ");
  Serial.println(WiFi.macAddress().c_str());
}

void setupMQTT()
{
  setup_wifi();
  client.setServer(mqtt_laptop_server, 1883);
  client.setCallback(mqttRX);
  idRxTopicBase  = WiFi.macAddress().substring(12, 17); // get last 4 digits of unique MAC address
  ledTopic1      = idRxTopicBase + "/led1";
  ledTopic2      = idRxTopicBase + "/led2";
  ledTopic3      = idRxTopicBase + "/led3";
  ledTopic4      = idRxTopicBase + "/led4";
  ledTopicAll    = idRxTopicBase + "ledAll";
  heartbeatTopic = idRxTopicBase + "/heartbeat";
}

void mqttRX(char* topic, byte* message, unsigned int length)
{
  int ledUpdateFlag = -1;
  String topicStr = String(topic);

  if (topicStr == broadCastTopic){

  } else if (topicStr == ledTopicAll){
    ledUpdateFlag = 0;
  } else if (topicStr == ledTopic1){
    ledUpdateFlag = 1;
  } else if (topicStr == ledTopic2){
    ledUpdateFlag = 2;
  } else if (topicStr == ledTopic3){
    ledUpdateFlag = 3;
  } else if (topicStr == ledTopic4){
    ledUpdateFlag = 4;
  } else {
    return;
  }

  if (ledUpdateFlag != -1){
    String msgValue;
    for (int i = 0; i < length; i++) {
      msgValue += (char)message[i];
    }

    updateLeds(ledUpdateFlag, msgValue.toInt());
  }
}

void reconnectMqtt() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");

    const char* clientName = "vertebrae";

    if (client.connect(clientName)){
      client.subscribe(ledTopic1.c_str());
      client.subscribe(ledTopic2.c_str());
      client.subscribe(ledTopic3.c_str());
      client.subscribe(ledTopic4.c_str());
      client.subscribe(broadCastTopic);

      Serial.println("connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void runMqtt()
{
  if (!client.connected()) {
    reconnectMqtt();
  }
  client.loop();

  handleMqttHeartbeat();
}

void handleMqttHeartbeat()
{
  if (millis() - lastMqttHeartbeat > heartbeatPeriod){
    client.publish(heartbeatTopic.c_str(), "HB");
    lastMqttHeartbeat = millis();
  }
}

#endif
