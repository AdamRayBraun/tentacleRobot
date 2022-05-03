// position of the tentacle compared to the camera
PVector tentacleBase = new PVector(301, 239, 200);

int userDistanceThresh = 100;
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

void moveTentacleToUser(){
  // if we have at least one person detected
  if (blobs.size() > 0){
    // get position of oldest blob
    PVector personPos = blobs.get(0).getCenter();

    float distanceXY = PVector.dist(personPos, tentacleBase);

    stroke(255, 0, 0);
    strokeWeight(4);
    noFill();
    line(tentacleBase.x, tentacleBase.y, personPos.x, personPos.y);
    line(tentacleBase.x, tentacleBase.y + kinectDepthH, personPos.x, personPos.y + kinectDepthH);

    if (distanceXY > userDistanceThresh){
      if ((tentacleBase.x - personPos.x)  > 0){
        // increment pos x
        if (lastMotorPositions[MOTOR_BOTTOM_X] < maxMotorPositions[MOTOR_BOTTOM_X]){
          lastMotorPositions[MOTOR_BOTTOM_X] += moveTowardsSpeed;
          moveTentacle(MOTOR_BOTTOM_X, lastMotorPositions[MOTOR_BOTTOM_X]);
        }
      } else {
        // increment neg x
        if (lastMotorPositions[MOTOR_BOTTOM_X] > -maxMotorPositions[MOTOR_BOTTOM_X]){
          lastMotorPositions[MOTOR_BOTTOM_X] -= moveTowardsSpeed;
          moveTentacle(MOTOR_BOTTOM_X, lastMotorPositions[MOTOR_BOTTOM_X]);
        }
      }

      if ((tentacleBase.y - personPos.y)  > 0){
        // increment pos x
        if (lastMotorPositions[MOTOR_BOTTOM_Y] < maxMotorPositions[MOTOR_BOTTOM_Y]){
          lastMotorPositions[MOTOR_BOTTOM_Y] += moveTowardsSpeed;
          moveTentacle(MOTOR_BOTTOM_Y, lastMotorPositions[MOTOR_BOTTOM_Y]);
        }
      } else {
        // increment neg x
        if (lastMotorPositions[MOTOR_BOTTOM_Y] > -maxMotorPositions[MOTOR_BOTTOM_Y]){
          lastMotorPositions[MOTOR_BOTTOM_Y] -= moveTowardsSpeed;
          moveTentacle(MOTOR_BOTTOM_Y, lastMotorPositions[MOTOR_BOTTOM_Y]);
        }
      }
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
