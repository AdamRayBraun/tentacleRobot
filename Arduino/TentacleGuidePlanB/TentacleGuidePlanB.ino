float motorX, motorY;
const float Pi = 3.14159;
float tenX, tenY, tenZ;//tentacle position value
float X1, Y1, Z1;//human position for interaction
float Angle;

void setup() {
  // put your setup code here, to run once:

}

void loop() {
  // put your main code here, to run repeatedly:
  //Calculate Angle
  if(X1 - tenX > 0){
    Angle = acos(Y1 - tenY);
  }
  else{
    Angle = 2 * Pi - acos(Y1 - tenY);
  }

  //Calculate motorX
  if(Angle < Pi / 4){
    motorX = -2 / Pi * Angle -1 / 2;
  }
  else if(Angle < Pi * 5 / 4){
    motorX = 2 / Pi * Angle -3 / 2;
  }
  else{
    motorX = -2 / Pi * Angle + 7 / 2;
  }

  //Calculate motorY
  if(Angle < Pi * 3 / 4){
    motorY = 2 / Pi * Angle -1 / 2;
  }
  else if(Angle < Pi * 7 / 4){
    motorY = -2 / Pi * Angle + 5 / 2;
  }
  else{
    motorY = 2 / Pi * Angle -9 / 2;
  }
}
