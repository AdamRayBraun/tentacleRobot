// position of the tentacle compared to the camera
PVector tentacleBase = new PVector(239, 320, 200);

final byte MOTOR_TOP_X    = 0;
final byte MOTOR_TOP_Y    = 1;
final byte MOTOR_BOTTOM_X = 2;
final byte MOTOR_BOTTOM_Y = 3;

// general motor vars
int motorPositions[]        = new int[4];
final int maxMotorSteps[]   = {6000, 6000, 2000, 2000};
final int motorUpdatePeriod = 1000;
long lastMotorUpdate;

// WIGGLE vars
float motorWaves[]          = new float[4];
float wiggleSinSpeeds[]     = {0.1, 0.1, 0.1, 0.1};
float sinAmplitude[]        = {0, 0, 0, 0};
int wiggleSpeed             = 300;
int wiggleIncreaseSpeed     = 300; 
long lastWiggleUpdate;

// EYE_CONTACT variables
float motorX, motorY;
float armDirectionAngle;
float rad;

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
      moveTentacle(MOTOR_BOTTOM_X, (int)(motorX * maxMotorSteps[MOTOR_BOTTOM_X]));
      moveTentacle(MOTOR_BOTTOM_Y, (int)(motorY * maxMotorSteps[MOTOR_BOTTOM_Y]));
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

    for (byte m = 0; m < 4; m++){
      int amplitudeIncrease = maxMotorSteps[m] / wiggleIncreaseSpeed;
      byte motorsFinished = 0;
      if (sinAmplitude[m] < maxMotorSteps[m] - amplitudeIncrease){
        sinAmplitude[m] += amplitudeIncrease;
      } else{
        sinAmplitude[m] = maxMotorSteps[m];
        motorsFinished++;
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
