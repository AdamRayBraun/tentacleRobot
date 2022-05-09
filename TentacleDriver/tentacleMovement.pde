// position of the tentacle compared to the camera
PVector tentacleBase = new PVector(239, 320, 200);

int userDistanceThresh = 10;
final int pulsePRev = 40000;

final byte MOTOR_TOP_X = 0;
final byte MOTOR_TOP_Y = 1;
final byte MOTOR_BOTTOM_X = 2;
final byte MOTOR_BOTTOM_Y = 3;

int motorPositions[]          = new int[4];
float motorWaves[]            = new float[4];
float wiggleSinSpeeds[]       = {0.001, 0.005, 0.2, 0.1};
final int maxMotorPositions[] = {400, 400, 400, 400};

int moveTowardsSpeed = 20;

int wiggleSpeed = 300;
long lastWiggleUpdate;

// Qi Qi variables
float motorX, motorY;
float armDirectionAngle;
float rad;

final int motorMaxStepsX = 2000;
final int motorMaxStepsY = 2000;
final int motorUpdatePeriod = 1000;
long lastMotorUpdate;

void moveTentacleToUser(){
  // if we have at least one person detected
  if (blobs.size() > 0){
    // get position of oldest blob
    PVector personPos = blobs.get(0).getCenter();

    // PVector personPos = new PVector(mouseX, mouseY); // for debugging

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

    //Calculate armDirectionAngle
    rad = sqrt(sq(personPos.x - tentacleBase.x) + sq(personPos.y - tentacleBase.y));
    if(personPos.y - tentacleBase.y > 0){
      armDirectionAngle = acos((personPos.x - tentacleBase.x) / rad);
    }
    else{
      armDirectionAngle = 2 * PI - acos((personPos.x - tentacleBase.x) / rad);
    }
    //Adjust Angle Error
    armDirectionAngle = armDirectionAngle + PI / 18;
    if (armDirectionAngle > 2 * PI){
      armDirectionAngle -= 2 * PI ;
    }

    //Calculate motorX
    if(armDirectionAngle < PI){
      motorX = -(2 / PI) * armDirectionAngle + 1;
    }
    else{
      motorX = (2 / PI) * armDirectionAngle - 3;
    }
    motorX = -motorX;

    //Calculate motorY
    if(armDirectionAngle < PI / 2){
      motorY = (2 / PI) * armDirectionAngle;
    }
    else if (armDirectionAngle < PI * 3 / 2){
      motorY = -(2 / PI) * armDirectionAngle + 2;
    }
    else{
      motorY = (2 / PI) * armDirectionAngle - 4;
    }
    motorY = -motorY;

    //enlarge motorX&Y
    if (motorX >= 0){
      motorX = sqrt(motorX);
    }
    else{
      motorX = -sqrt(-motorX);
    }
    if (motorY >= 0){
      motorY = sqrt(motorY);
    }
    else{
      motorY = -sqrt(-motorY);
    }

    text(motorX + "\n" + motorY, tentacleBase.x, tentacleBase.y + kinectDepthH + 60);

    if (millis() - lastMotorUpdate > motorUpdatePeriod){
      lastMotorUpdate = millis();
      moveTentacle(MOTOR_BOTTOM_X, (int)(motorX * motorMaxStepsX));
      moveTentacle(MOTOR_BOTTOM_Y, (int)(motorY * motorMaxStepsY));
    }
  }
}

void wiggle(){
  if (millis() - lastWiggleUpdate > wiggleSpeed){
    lastWiggleUpdate = millis();
    motorWaves[MOTOR_BOTTOM_X] += wiggleSinSpeeds[MOTOR_BOTTOM_X];
    motorPositions[MOTOR_BOTTOM_X] = floor(sin(motorWaves[MOTOR_BOTTOM_X]) * motorMaxStepsX);

    motorWaves[MOTOR_BOTTOM_Y] += wiggleSinSpeeds[MOTOR_BOTTOM_Y];
    motorPositions[MOTOR_BOTTOM_Y] = floor(sin(motorWaves[MOTOR_BOTTOM_Y]) * motorMaxStepsY);

    //Qi Qi limit motor move
    float addXY = sqrt( sq(motorPositions[MOTOR_BOTTOM_X]) + motorPositions[MOTOR_BOTTOM_Y]) / motorMaxStepsX ;
    if ( addXY > 1 ){
      motorPositions[MOTOR_BOTTOM_X] = (int)(motorPositions[MOTOR_BOTTOM_X] / addXY);
      motorPositions[MOTOR_BOTTOM_Y] = (int)(motorPositions[MOTOR_BOTTOM_Y] / addXY);
    }

    // println(motorPositions[MOTOR_BOTTOM_X] + ", " + motorPositions[MOTOR_BOTTOM_Y]);
  }

  if (millis() - lastMotorUpdate > motorUpdatePeriod){
    moveTentacle(MOTOR_BOTTOM_X, motorPositions[MOTOR_BOTTOM_X]);
    moveTentacle(MOTOR_BOTTOM_Y, motorPositions[MOTOR_BOTTOM_Y]);
  }
}
