

// Defin pins

int reverseSwitch = 2;  // Push button for reverse
int driverPUL = 4;    // PUL- pin
int driverDIR = 5;    // DIR- pin
//int spd = A0;     // Potentiometer

// Variables

int pd = 500;       // Pulse Delay period
boolean setdir = HIGH; // Set Direction

void setup() {

  pinMode(driverPUL, OUTPUT);
  pinMode(driverDIR, OUTPUT);
}

void loop() {
    pd = 1500; // 2000 - 50
    digitalWrite(driverDIR,setdir);
    digitalWrite(driverPUL,HIGH);
    delayMicroseconds(pd);
    digitalWrite(driverPUL,LOW);
    delayMicroseconds(pd);
}
