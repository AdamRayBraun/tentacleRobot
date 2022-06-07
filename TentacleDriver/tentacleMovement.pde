// position of the tentacle compared to the camera
PVector tentacleBase = new PVector(239, 320, 200);

final byte MOTOR_TOP_X    = 0;
final byte MOTOR_TOP_Y    = 1;
final byte MOTOR_BOTTOM_X = 2;
final byte MOTOR_BOTTOM_Y = 3;

// general motor variables
int motorPositions[]        = new int[4];
final int maxMotorSteps[]   = {6000, 6000, 2000, 2000};
final int motorUpdatePeriod = 1000;
long lastMotorUpdate;

// WIGGLE variables
float motorWaves[]          = new float[4];
float wiggleSinSpeeds[]     = {0.1, 0.08, 0.1, 0.12};
float sinAmplitude[]        = {0, 0, 0, 0};
int wiggleSpeed             = 300;
int wiggleIncreaseSpeed     = 80;
long lastWiggleUpdate;

// EYE_CONTACT variables
float bottomMotorX, bottomMotorY, topMotorX, topMotorY, farOrNot;
float armDirectionAngle;
float rad;
//float checkDistance = 1 ;
//float topScale = 0.5 ;

// AUDIENCE LOOK AROUND variables
int audienceLookAroundPositions[] = {0, 0, 0, 0};

// AUDIENCE_LOOK variables
int audienceLookPositions[] = {0, 0, 0, 0};

// PRESENT_BODY variables
int presentBodyPositions[]  = {0, 0, 0, 0};

// PRESENT_WAIST variables
int presentWaistPositions[] = {0, 0, 0, 0};

// PRESENT_HEAD variables
int presentHeadPositions[]  = {0, 0, 0, 0};

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

    //Calculate bottomMotorX
    if(armDirectionAngle < PI){
      bottomMotorX = -(2 / PI) * armDirectionAngle + 1;
    }
    else{
      bottomMotorX = (2 / PI) * armDirectionAngle - 3;
    }
    bottomMotorX = -bottomMotorX;

    //Calculate bottomMotorY
    if(armDirectionAngle < PI / 2){
      bottomMotorY = (2 / PI) * armDirectionAngle;
    }
    else if (armDirectionAngle < PI * 3 / 2){
      bottomMotorY = -(2 / PI) * armDirectionAngle + 2;
    }
    else{
      bottomMotorY = (2 / PI) * armDirectionAngle - 4;
    }
    bottomMotorY = -bottomMotorY;

    //enlarge bottomMotorX&Y
    if (bottomMotorX >= 0){
      bottomMotorX = sqrt(bottomMotorX);
    }
    else{
      bottomMotorX = -sqrt(-bottomMotorX);
    }
    if (bottomMotorY >= 0){
      bottomMotorY = sqrt(bottomMotorY);
    }
    else{
      bottomMotorY = -sqrt(-bottomMotorY);
    }

    text(bottomMotorX + "\n" + bottomMotorY, tentacleBase.x, tentacleBase.y + kinectDepthH + 60);

    //Calculate farOrNot, distance = rad
    farOrNot = map( rad , 0, 1.5, -1, 1 );
    if ( farOrNot > 1 ){
      farOrNot = 1 ;
    }

    //Calculate topMotorX&Y
    topMotorX = bottomMotorX * farOrNot ;
    topMotorY = bottomMotorY * farOrNot ;

    //move Motors
    if (millis() - lastMotorUpdate > motorUpdatePeriod){
      lastMotorUpdate = millis();
      moveTentacle(MOTOR_BOTTOM_X, (int)(bottomMotorX * maxMotorSteps[MOTOR_BOTTOM_X]));
      moveTentacle(MOTOR_BOTTOM_Y, (int)(bottomMotorY * maxMotorSteps[MOTOR_BOTTOM_Y]));
      moveTentacle(MOTOR_TOP_X,    (int)(topMotorX * maxMotorSteps[MOTOR_TOP_X]));
      moveTentacle(MOTOR_TOP_Y,    (int)(topMotorY * maxMotorSteps[MOTOR_TOP_Y]));
    }
  }
}

void wiggle(){
  if (millis() - lastWiggleUpdate > wiggleSpeed){
    lastWiggleUpdate = millis();

    for (byte m = 0; m < 4; m++){
      motorWaves[m] += wiggleSinSpeeds[m];
      motorPositions[m] = floor(sin(motorWaves[m]) * maxMotorSteps[m]);
    }

    // Limit bottom section combined extension
    float addBottomXY = sqrt(sq(motorPositions[MOTOR_BOTTOM_X]) + motorPositions[MOTOR_BOTTOM_Y]) / maxMotorSteps[MOTOR_BOTTOM_X];
    if ( addBottomXY > 1 ){
      motorPositions[MOTOR_BOTTOM_X] = (int)(motorPositions[MOTOR_BOTTOM_X] / addBottomXY);
      motorPositions[MOTOR_BOTTOM_Y] = (int)(motorPositions[MOTOR_BOTTOM_Y] / addBottomXY);
    }

    // Limit bottom section combined extension
    float addTopXY = sqrt(sq(motorPositions[MOTOR_TOP_X]) + motorPositions[MOTOR_TOP_Y]) / maxMotorSteps[MOTOR_TOP_X];
    if ( addTopXY > 1 ){
      motorPositions[MOTOR_TOP_X] = (int)(motorPositions[MOTOR_TOP_X] / addTopXY);
      motorPositions[MOTOR_TOP_Y] = (int)(motorPositions[MOTOR_TOP_Y] / addTopXY);
    }
  }

  if (millis() - lastMotorUpdate > motorUpdatePeriod){
    for (byte m = 0; m < 4; m++){
      moveTentacle(m, motorPositions[m]);
    }
  }
}

void wiggleIncreasing(){
  if (millis() - lastWiggleUpdate > wiggleSpeed){
    lastWiggleUpdate = millis();

    for (byte m = 0; m < 4; m++){
      motorWaves[m] += wiggleSinSpeeds[m];
      motorPositions[m] = floor(sin(motorWaves[m]) * sinAmplitude[m]);
    }

    byte motorsFinished = 0;
    for (byte m = 0; m < 4; m++){
      int amplitudeIncrease = maxMotorSteps[m] / wiggleIncreaseSpeed;
      if (sinAmplitude[m] >= maxMotorSteps[m]){
        sinAmplitude[m] = maxMotorSteps[m];
        motorsFinished++;
      } else{
        sinAmplitude[m] += amplitudeIncrease;
      }
      if (motorsFinished >= 4) changeState(WIGGLE);
    }

    // Limit bottom section combined extension
    float addBottomXY = sqrt(sq(motorPositions[MOTOR_BOTTOM_X]) + motorPositions[MOTOR_BOTTOM_Y]) / maxMotorSteps[MOTOR_BOTTOM_X];
    if ( addBottomXY > 1 ){
      motorPositions[MOTOR_BOTTOM_X] = (int)(motorPositions[MOTOR_BOTTOM_X] / addBottomXY);
      motorPositions[MOTOR_BOTTOM_Y] = (int)(motorPositions[MOTOR_BOTTOM_Y] / addBottomXY);
    }

    // Limit bottom section combined extension
    float addTopXY = sqrt(sq(motorPositions[MOTOR_TOP_X]) + motorPositions[MOTOR_TOP_Y]) / maxMotorSteps[MOTOR_TOP_X];
    if ( addTopXY > 1 ){
      motorPositions[MOTOR_TOP_X] = (int)(motorPositions[MOTOR_TOP_X] / addTopXY);
      motorPositions[MOTOR_TOP_Y] = (int)(motorPositions[MOTOR_TOP_Y] / addTopXY);
    }
  }

  if (millis() - lastMotorUpdate > motorUpdatePeriod){
    for (byte m = 0; m < 4; m++){
      moveTentacle(m, motorPositions[m]);
    }
  }
}

void lookAroundAudience(){
  for (byte m = 0; m < 4; m++){
    moveTentacle(m, audienceLookAroundPositions[m]);
  }
}

void lookTowardsAudience(){
  for (byte m = 0; m < 4; m++){
    moveTentacle(m, audienceLookPositions[m]);
  }
}

void presentBody(){
  for (byte m = 0; m < 4; m++){
    moveTentacle(m, presentBodyPositions[m]);
  }
}

void presentWaist(){
  for (byte m = 0; m < 4; m++){
    moveTentacle(m, presentWaistPositions[m]);
  }
}

void presentHead(){
  for (byte m = 0; m < 4; m++){
    moveTentacle(m, presentHeadPositions[m]);
  }
}

void moveHome(){
  for (byte m = 0; m < 4; m++){
    moveTentacle(m, 0);
  }
}
