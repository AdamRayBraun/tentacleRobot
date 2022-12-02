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

// looking at individual vars
float twoOverPI = 2 / PI;
float rad, armDirectionAngle, bottomScale;

// looking up down left right vars
long lastMovement;
boolean movementFlag;
int lookingPeriod = 1000;

// debugging / calibrating
PGraphics debugCanvas;
boolean lookAtMouse = false;

void setupMovement(){
  tentacleBase = new PVector(isaacConfig.getInt("baseX"),
                             isaacConfig.getInt("baseY"),
                             isaacConfig.getInt("baseZ"));

  debugCanvas = createGraphics(kinectDepthW, kinectDepthH, P3D);
}

// point end effector towards chosen audience blob
void lookAtIndividual(){
  PVector personPos;

  if (lookAtMouse){
    // follow mouse position if debugging
    int mouseDebugX = (int)constrain((mouseX - debugImgPos.x), 0, kinectDepthW);
    int mouseDebugY = (int)constrain((mouseY - debugImgPos.y), 0, kinectDepthH);
    personPos = new PVector(mouseDebugX, mouseDebugY);
  } else {
    if (blobDetector.blobs.size() > blobTargetIndex){
      // get position of blob to pay attention to
      personPos = blobDetector.blobs.get(blobTargetIndex).getCenter();
    } else {
      pickNewTarget();
      return;
    }
  }

  // get distance between blob and robot base
  float distanceXY = PVector.dist(personPos, tentacleBase);

  // calculate angle between Isaac and person of interest
  float rad = sqrt(sq(personPos.x - tentacleBase.x) + sq(personPos.y - tentacleBase.y));

  if (personPos.y - tentacleBase.y > 0){
    armDirectionAngle = acos((personPos.x - tentacleBase.x) / rad);
  } else {
    armDirectionAngle = TWO_PI - acos((personPos.x - tentacleBase.x) / rad);
  }

  // adjust for angle error
  armDirectionAngle = armDirectionAngle + PI / 18 + map( rad, 0, 350, - (PI / 180) * 1, (PI / 180) * 30);//correct twisting
  if (armDirectionAngle >= TWO_PI) armDirectionAngle -= TWO_PI;

  // scale bottom motor positions
  bottomScale = map(rad, 0, 350, 1.9, 0.9);       // 1.5 0.7
  // bottomScale = constrain(bottomScale, 0.5, 1.9); // 0.5 1.5 ///////////////////////
  bottomScale = constrain(bottomScale, 0.0, 1.0); // 0.5 1.5

  //convert coordinates and send to motor
  moveMotorsWithPolarCoordinates();

  // check for change of person of interest
  if (millis() - chosenTargetTime > targetAttentionSpan){
    chosenTargetTime = millis();
    pickNewTarget();
  }

  if (showDebugPersonDetection){
    debugCanvas.beginDraw();
    debugCanvas.clear();
    debugCanvas.stroke(255, 0, 0);
    debugCanvas.strokeWeight(4);
    debugCanvas.noFill();
    debugCanvas.line(tentacleBase.x, tentacleBase.y, personPos.x, personPos.y);
    debugCanvas.line(tentacleBase.x, tentacleBase.y + kinectDepthH, personPos.x, personPos.y + kinectDepthH);
    debugCanvas.fill(255, 0, 0);
    debugCanvas.textSize(20);
    debugCanvas.text(degrees(armDirectionAngle), tentacleBase.x + 10, tentacleBase.y + kinectDepthH);
    debugCanvas.endDraw();
  }
}

//Isaac behaviour. Should have rad, armDirectionAngle, bottomScale ready
void lookUpDown(){
  float delta = 0.3;

  if (millis() - lastMovement > lookingPeriod){
    bottomScale = movementFlag ? bottomScale + delta : bottomScale - delta;
    moveMotorsWithPolarCoordinates();
    lastMovement = millis();
    movementFlag = !movementFlag;
  }
}

void lookLeftRight(){
  float delta = 0.2;

  if (millis() - lastMovement > lookingPeriod){
    armDirectionAngle = movementFlag ? armDirectionAngle + delta : armDirectionAngle - delta;
    moveMotorsWithPolarCoordinates();
    lastMovement = millis();
    movementFlag = !movementFlag;
  }
}


//use rad, armDirectionAngle, bottomScale
void moveMotorsWithPolarCoordinates(){
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

  // calculate bottom Y motor
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
  motorPositions[motors.MOTOR_TOP_Y] *= -1;

  // scale bottom motor positions
  motorPositions[motors.MOTOR_BOTTOM_X] *= bottomScale * 1.1;
  motorPositions[motors.MOTOR_BOTTOM_Y] *= bottomScale * 0.8;

  // Move motors
  if (millis() - lastMotorUpdate > motorUpdatePeriod){
    lastMotorUpdate = millis();
    for (byte m = 0; m < motors.NUM_MOTORS; m++){
      motors.moveMotors(m, (int)(motorPositions[m] * motors.maxMotorSteps[m]));
    }
  }
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
