/*
   Arduino and MPU6050 Accelerometer and Gyroscope Sensor Tutorial
*/
#include <Wire.h>
//for MPU6050
const int MPU = 0x68; // MPU6050 I2C address
float AccX, AccY, AccZ;
float GyroX, GyroY, GyroZ;
float accAngleX, accAngleY, accAngleZ, gyroAngleX, gyroAngleY, gyroAngleZ;

//for calculate movement
float tenX=1,tenY=0,tenZ=0;//tentacle position value
float X1=1,Y1=1,Z1=1;//human position for interaction
const float Pi = 3.14159;
float tenAngle, tenR;//for polar coordinates
float Angle1, R1;//for polar coordinates

void setup() {
  Serial.begin(9600);
  Wire.begin();                      // Initialize comunication
  Wire.beginTransmission(MPU);       // Start communication with MPU6050 // MPU=0x68
  Wire.write(0x6B);                  // Talk to the register 6B
  Wire.write(0x00);                  // Make reset - place a 0 into the 6B register
  Wire.endTransmission(true);        //end the transmission
  ///*
  // Configure Accelerometer Sensitivity - Full Scale Range (default +/- 2g)
  Wire.beginTransmission(MPU);
  Wire.write(0x1C);                  //Talk to the ACCEL_CONFIG register (1C hex)
  Wire.write(0x10);                  //Set the register bits as 00010000 (+/- 8g full scale range)
  Wire.endTransmission(true);
  // Configure Gyro Sensitivity - Full Scale Range (default +/- 250deg/s)
  Wire.beginTransmission(MPU);
  Wire.write(0x1B);                   // Talk to the GYRO_CONFIG register (1B hex)
  Wire.write(0x10);                   // Set the register bits as 00010000 (1000deg/s full scale)
  Wire.endTransmission(true);
  delay(20);
}
void loop() {
  // === Read acceleromter data === //
  Wire.beginTransmission(MPU);
  Wire.write(0x3B); // Start with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU, 6, true); // Read 6 registers total, each axis value is stored in 2 registers
  //For a range of +-2g, we need to divide the raw values by 16384, according to the datasheet
  AccX = (Wire.read() << 8 | Wire.read()) / 16384.0; // X-axis value加速度
  AccY = (Wire.read() << 8 | Wire.read()) / 16384.0; // Y-axis value
  AccZ = (Wire.read() << 8 | Wire.read()) / 16384.0; // Z-axis value
  // Calculating Roll and Pitch from the accelerometer data
  accAngleX = (atan(AccX / sqrt(pow(AccY, 2) + pow(AccZ, 2))) * 180 / PI); // -AccErrorX ~(0.58) See the calculate_IMU_error()custom function for more details
  accAngleY = (atan(AccY / sqrt(pow(AccX, 2) + pow(AccZ, 2))) * 180 / PI); // -AccErrorY ~(-1.58)
  accAngleZ = (atan(AccZ / sqrt(pow(AccX, 2) + pow(AccY, 2))) * 180 / PI);
  
  // Print the values on the serial monitor
  Serial.print(AccX);//Projection of gravity on x axis
  Serial.print("/");
  Serial.print(AccY);
  Serial.print("/");
  Serial.print(AccZ);
  Serial.print("===");
  Serial.print(accAngleX);//Angle between the x axis and gravity_>0:upward;<0:downward
  Serial.print("/");
  Serial.print(accAngleY);
  Serial.print("/");
  Serial.println(accAngleZ);
}



//everything below move to another file
void CalculateMovement(){
//tentacle position: tenX,tenY,tenZ,tenAngle, tenR
//human position: X1,Y1,Z1,Angle1, R1
//Axis Angle: accAngleX, accAngleY, accAngleZ
//assume z axis points outward

//convert XYvalue to polar coordinates
  tenR=sqrt(sq(tenX)+sq(tenY));
  tenAngle=acos(tenY/tenR);
  if(tenX<0){
    tenAngle=2*Pi-tenAngle;
  }
  R1=sqrt(sq(X1)+sq(Y1));
  Angle1=acos(Y1/R1);
  if(X1<0){
    Angle1=2*Pi-Angle1;
  } 
  
//left right movement
  if(tenAngle<Angle1){  
    tenAngleIncrease();//tenAngle++
  }
  else{  
    tenAngleDecrease();//tenAngle--
  }

//Up down movement
  if(tenZ<Z1){
    tenZIncrease();
  }
  else{
    tenZDecrease();
  }
    
}

void tenAngleIncrease(){
  //tenAngle++
  if(abs(accAngleX)>abs(accAngleY)){
    if(accAngleX>0){
      MotorY2();//pull wire Y- 
    }
    else{
      MotorY1();//pull wire Y+ 
    }   
  }
  else{
    if(accAngleY>0){
      MotorX1();//pull wire X+ 
    }
    else{
      MotorX2();//pull wire X-
    } 
  }
}
void tenAngleDecrease(){
  //tenAngle--
  if(abs(accAngleX)>abs(accAngleY)){
    if(accAngleX>0){
      MotorY1();//pull wire Y+
    }
    else{
      MotorY2();//pull wire Y- 
    }   
  }
  else{
    if(accAngleY>0){
      MotorX2();//pull wire X- 
    }
    else{
      MotorX1();//pull wire X+
    } 
  }
}
void tenZIncrease(){
  //tenZ++
  if(abs(accAngleX)>abs(accAngleY)){
    if(accAngleX>0){
      MotorX1();//pull wire X+
    }
    else{
      MotorX2();//pull wire X- 
    }   
  }
  else{
    if(accAngleY>0){
      MotorY1();//pull wire Y+ 
    }
    else{
      MotorY2();//pull wire Y-
    } 
  }
}
void tenZDecrease(){
  //tenZ--
  if(abs(accAngleX)>abs(accAngleY)){
    if(accAngleX>0){
      MotorX2();//pull wire X-
    }
    else{
      MotorX1();//pull wire X+
    }   
  }
  else{
    if(accAngleY>0){
      MotorY2();//pull wire Y- 
    }
    else{
      MotorY1();//pull wire Y+
    } 
  }
}

void MotorX1(){
  //pull wire X+ for a certain amount
  Serial.println("X+");
}
void MotorX2(){
  //pull wire X- for a certain amount
  Serial.println("X-");
}
void MotorY1(){
  //pull wire Y+ for a certain amount
  Serial.println("Y+");
}
void MotorY2(){
  //pull wire Y- for a certain amount
  Serial.println("Y-");
}
