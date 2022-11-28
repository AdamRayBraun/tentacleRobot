// Isaac vars
PVector tentacleBase;

// audience vars
int blobTargetIndex;
long chosenTargetTime;
final int targetAttentionSpan = 8000;

// wiggle movement vars
final int motorUpdatePeriod = 1000; // making faster risks motor stalling at rapid large movement changes
float motorPositions[]      = new float[4];
float motorWaves[]          = new float[4];
float wiggleSinSpeeds[]     = {0.1, 0.08, 0.1, 0.12};
int wiggleSpeed             = 300;
long lastWiggleUpdate;
long lastMotorUpdate;

void setupMovement(){
  tentacleBase = new PVector(isaacConfig.getInt("baseX"),
                             isaacConfig.getInt("baseY"),
                             isaacConfig.getInt("baseZ"));
}

// point end effector towards chosen audience blob
void lookAtIndividual(){
  if (blobDetector.blobs.size() < blobTargetIndex){
    pickNewTarget();
    return;
  }

  // get position of blob to pay attention to
  PVector personPos = blobDetector.blobs.get(blobTargetIndex).getCenter();

  // get distance between blob and robot base
  float distanceXY = PVector.dist(personPos, tentacleBase);

  // calculate angle between Isaac and person of interest
  float rad = sqrt(sq(personPos.x - tentacleBase.x) + sq(personPos.y - tentacleBase.y));

  float armDirectionAngle, bottomScale;

  if (personPos.y - tentacleBase.y > 0){
    armDirectionAngle = acos((personPos.x - tentacleBase.x) / rad);
  } else {
    armDirectionAngle = TWO_PI - acos((personPos.x - tentacleBase.x) / rad);
  }

  // adjust for angle error
  armDirectionAngle += PI / 18 + map(rad, 0, 350, - (PI / 180), (PI / 180) * 30); // correct twisting
  if (armDirectionAngle >= TWO_PI) armDirectionAngle -= TWO_PI;

  float twoOverPI = 2 / PI;

  // calculate bottom X motor
  if (armDirectionAngle < PI){
    motorPositions[motors.MOTOR_BOTTOM_X] = -twoOverPI * armDirectionAngle + 1;
  } else {
    motorPositions[motors.MOTOR_BOTTOM_X] = twoOverPI * armDirectionAngle - 3;
  }

  motorPositions[motors.MOTOR_BOTTOM_X] *= -1;

  // enlarge bottom X motor
  if (motorPositions[motors.MOTOR_BOTTOM_X] >= 0){
    motorPositions[motors.MOTOR_BOTTOM_X] = sqrt(motorPositions[motors.MOTOR_BOTTOM_X]);
  }
  else{
    motorPositions[motors.MOTOR_BOTTOM_X] = -sqrt(-motorPositions[motors.MOTOR_BOTTOM_X]);
  }

  // calculate botton Y motor
  if(armDirectionAngle < HALF_PI){
    motorPositions[motors.MOTOR_BOTTOM_Y] = twoOverPI * armDirectionAngle;
  }
  else if (armDirectionAngle < PI * 1.5){
    motorPositions[motors.MOTOR_BOTTOM_Y] = -(twoOverPI) * armDirectionAngle + 2;
  }
  else{
    motorPositions[motors.MOTOR_BOTTOM_Y] = twoOverPI * armDirectionAngle - 4;
  }
  motorPositions[motors.MOTOR_BOTTOM_Y] *= -1;

  // enlarge bottom Y motor
  if (motorPositions[motors.MOTOR_BOTTOM_Y] >= 0){
    motorPositions[motors.MOTOR_BOTTOM_Y] = sqrt(motorPositions[motors.MOTOR_BOTTOM_Y]);
  } else {
    motorPositions[motors.MOTOR_BOTTOM_Y] = -sqrt(-motorPositions[motors.MOTOR_BOTTOM_Y]);
  }

  // calculate top motor behaviour
  float farOrNot = map(rad, 0, 350, -3, 2);

  // calculate top motor positions
  motorPositions[motors.MOTOR_TOP_X] = motorPositions[motors.MOTOR_BOTTOM_X] * farOrNot;
  motorPositions[motors.MOTOR_TOP_Y] = motorPositions[motors.MOTOR_BOTTOM_Y] * farOrNot;

  motorPositions[motors.MOTOR_TOP_X] = constrain(motorPositions[motors.MOTOR_TOP_X], -1, 1);
  motorPositions[motors.MOTOR_TOP_Y] = constrain(motorPositions[motors.MOTOR_TOP_Y], -1, 1);

  // swap?
  motorPositions[motors.MOTOR_BOTTOM_X] *= -1;
  motorPositions[motors.MOTOR_BOTTOM_Y] *= -1;

  // scale bottom motor positions
  bottomScale = map(rad, 0, 350, 1.9, 0.9);       // 1.5 0.7
  bottomScale = constrain(bottomScale, 0.5, 1.9); // 0.5 1.5
  motorPositions[motors.MOTOR_BOTTOM_X] *= bottomScale * 1.1;
  motorPositions[motors.MOTOR_BOTTOM_Y] *= bottomScale * 0.8;

  // Move motors
  if (millis() - lastMotorUpdate > motorUpdatePeriod){
    lastMotorUpdate = millis();
    for (byte m = 0; m < motors.NUM_MOTORS; m++){
      motors.moveMotors(m, (int) motorPositions[m] * motors.maxMotorSteps[m]);
    }
  }

  // check for change of person of interest
  if (millis() - chosenTargetTime > targetAttentionSpan){
    chosenTargetTime = millis();
    pickNewTarget();
  }
  // TODO:
  // debugging lines between the base and detected person
}

// choose new random blob to pay attention to
void pickNewTarget(){
  if (blobDetector.blobs.size() > 0) blobTargetIndex = floor(random(0, blobDetector.blobs.size()));
}

// semi random sin wave waggling of all motors
void wiggle(){
  if (millis() - lastWiggleUpdate > wiggleSpeed){
    lastWiggleUpdate = millis();

    for (byte m = 0; m < 4; m++){
      motorWaves[m] += wiggleSinSpeeds[m];
      motorPositions[m] = floor(sin(motorWaves[m]) * motors.maxMotorSteps[m]);
    }

    // Limit bottom section combined extension
    float combinedBottomXY = sqrt(sq(motorPositions[motors.MOTOR_BOTTOM_X]) + motorPositions[motors.MOTOR_BOTTOM_Y]) / motors.maxMotorSteps[motors.MOTOR_BOTTOM_X];
    if (combinedBottomXY > 1){
      motorPositions[motors.MOTOR_BOTTOM_X] = (int)(motorPositions[motors.MOTOR_BOTTOM_X] / combinedBottomXY);
      motorPositions[motors.MOTOR_BOTTOM_Y] = (int)(motorPositions[motors.MOTOR_BOTTOM_Y] / combinedBottomXY);
    }

    // Limit bottom section combined extension
    float combinedTopXY = sqrt(sq(motorPositions[motors.MOTOR_TOP_X]) + motorPositions[motors.MOTOR_TOP_Y]) / motors.maxMotorSteps[motors.MOTOR_TOP_X];
    if (combinedTopXY > 1){
      motorPositions[motors.MOTOR_TOP_X] = (int)(motorPositions[motors.MOTOR_TOP_X] / combinedTopXY);
      motorPositions[motors.MOTOR_TOP_Y] = (int)(motorPositions[motors.MOTOR_TOP_Y] / combinedTopXY);
    }
  }

  if (millis() - lastMotorUpdate > motorUpdatePeriod){
    for (byte m = 0; m < 4; m++){
      motors.moveMotors(m, (int) motorPositions[m]);
    }
  }
}

void homeMotors(){
  for (byte m = 0; m < 4; m++){
    motors.moveMotors(m, 0);
  }
}
