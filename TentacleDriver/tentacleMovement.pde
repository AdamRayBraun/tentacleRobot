// position of the tentacle compared to the camera
PVector tentacleBase = new PVector(243, 229, 200);

int userDistanceThresh = 10;
final int pulsePRev = 8000;

final byte MOTOR_TOP_X = 0;
final byte MOTOR_TOP_Y = 1;
final byte MOTOR_BOTTOM_X = 2;
final byte MOTOR_BOTTOM_Y = 3;

int motorPositions[]          = new int[4];
float motorWaves[]            = new float[4];
float wiggleSinSpeeds[]       = {0.001, 0.005, 0.1, 0.01};
final int maxMotorPositions[] = {400, 400, 400, 400};

int moveTowardsSpeed = 20;

int wiggleSpeed = 300;
long lastWiggleUpdate;

// Qi Qi variables
float motorX, motorY;
float armDirectionAngle;

final int motorMaxSteps = 2000;

long lastMotorUpdate;
final int motorUpdatePeriod = 1000;
float rad;

void moveTentacleToUser(){
  // if we have at least one person detected
  if (blobs.size() > 0){
    // get position of oldest blob
    // PVector personPos = blobs.get(0).getCenter();

    PVector personPos = new PVector(mouseX, mouseY);

    float distanceXY = PVector.dist(personPos, tentacleBase);

    // draw guide for debugging
    stroke(255, 0, 0);
    strokeWeight(4);
    noFill();
    line(tentacleBase.x, tentacleBase.y, personPos.x, personPos.y);
    line(tentacleBase.x, tentacleBase.y + kinectDepthH, personPos.x, personPos.y + kinectDepthH);
    fill(255, 0, 0);
    textSize(20);
    text(degrees(armDirectionAngle), tentacleBase.x + 10, tentacleBase.y + kinectDepthH);

    // QiQi start
    //Calculate armDirectionAngle
    rad = sqrt ( sq(personPos.x - tentacleBase.x) + sq(personPos.y - tentacleBase.y) ) ;
    if(personPos.y - tentacleBase.y > 0){
      armDirectionAngle = acos( ( personPos.x - tentacleBase.x) / rad ) ;
    }
    else{
      armDirectionAngle = 2 * PI - acos( ( personPos.x - tentacleBase.x) / rad);
    }

    //Calculate motorX
    if(armDirectionAngle < PI ){
      motorX = - ( 2 / PI ) * armDirectionAngle + 1 ;
    }
    else{
      motorX =   ( 2 / PI ) * armDirectionAngle - 3 ;
    }

    //Calculate motorY
    if(armDirectionAngle < PI / 2 ){
      motorY =   ( 2 / PI ) * armDirectionAngle ;
    }
    else if(armDirectionAngle < PI * 3 / 2 ){
      motorY = - ( 2 / PI ) * armDirectionAngle + 2 ;
    }
    else{
      motorY =   ( 2 / PI ) * armDirectionAngle - 4 ;
    }
    motorY = -motorY;

    text(motorX + "\n" + motorY, tentacleBase.x, tentacleBase.y + kinectDepthH + 60);

    if (millis() - lastMotorUpdate > motorUpdatePeriod){
      lastMotorUpdate = millis();
      moveTentacle(MOTOR_BOTTOM_X, (int)(motorX * motorMaxSteps));
      moveTentacle(MOTOR_BOTTOM_Y, (int)(motorY * motorMaxSteps));
    }
  }
}

void wiggle(){
  // increment all 4 motor sine wave values
  // for (byte m = 0; m < 4; m++){

  if (millis() - lastWiggleUpdate > wiggleSpeed){
    lastWiggleUpdate = millis();

      byte m = 2;
      motorWaves[m] += wiggleSinSpeeds[m];
      motorPositions[m] = floor(sin(motorWaves[m]) * maxMotorPositions[m]);

      moveTentacle(m, motorPositions[m]);

    // for (byte m = 2; m < 4; m++){
    //   motorWaves[m] += wiggleSinSpeeds[m];
    //   motorPositions[m] = floor(sin(motorWaves[m]) * maxMotorPositions[m]);
    //
    //   moveTentacle(m, motorPositions[m]);
    // }
  }

  // TODO wiggle eye lid occasionally
}
