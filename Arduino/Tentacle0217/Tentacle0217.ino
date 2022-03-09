const int servo1 = 9;
const int servo2 = 10;
const int vrx=A0;
const int vry=A1;
const int sw=7;
int angle1=90;
int angle2=90;
int valueX=0;
int valueY=0;
int valueZ=0;

void setup() {
  pinMode(servo1, OUTPUT);
  pinMode(servo2, OUTPUT);
  pinMode(sw, INPUT_PULLUP);
  Serial.begin(9600);
  servoSet(servo1,angle1);
  servoSet(servo2,angle2);
}

void loop() {
  valueX = analogRead(A0); 
  Serial.print("X:"); 
  Serial.print(valueX, DEC); 
  valueY = analogRead(A1); 
  Serial.print(" | Y:"); 
  Serial.print(valueY, DEC); 
  valueZ = digitalRead(7); 
  Serial.print(" | Z: "); 
  Serial.println(valueZ, DEC); 
  if(valueZ==0){
    servoSet(servo1,angle1);
    servoSet(servo2,angle2);
  }
  if(valueX>900){
    angle1=angle1-2;
    servoMove(servo1,angle1);
  }
  else if(valueX<100){
    angle1=angle1+2;
    servoMove(servo1,angle1);
  }
  if(valueY>900){
    angle2=angle2+2;
    servoMove(servo2,angle2);
  }
  else if(valueY<100){
    angle2=angle2-2;
    servoMove(servo2,angle2);
  }
  //delay(300);
  /*
  for(int i=0;i<25;i++){
    angle1=angle1+5;
    servoMove(servo1,angle1);
    delay(15);
  }
  for(int i=0;i<25;i++){
    angle1=angle1-5;
    servoMove(servo1,angle1);
    delay(15);
  }
  for(int i=0;i<25;i++){
    angle2=angle2+5;
    servoMove(servo2,angle2);
    delay(15);
  }
  for(int i=0;i<25;i++){
    angle2=angle2-5;
    servoMove(servo2,angle2);
    delay(15);
  }
  */
}

void servoSet(int servo,int angle){
  
    digitalWrite(servo,HIGH);
    delayMicroseconds(1500);
    digitalWrite(servo,LOW);
    delay(15);
   
  Serial.println("set");
}

void servoMove(int servo,int angle){
  int j = map(angle,0,180,500,2500);
  
    digitalWrite(servo,HIGH);
    delayMicroseconds(j);
    digitalWrite(servo,LOW);
    delay(15);
  
  //Serial.println(angle);
}
