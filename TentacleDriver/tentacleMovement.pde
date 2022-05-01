// position of the tentacle compared to the camera
PVector tentacleBase = new PVector(301, 239, 200);

int userDistanceThresh = 100;

final byte MOTOR_TOP_X = 0;
final byte MOTOR_TOP_Y = 1;
final byte MOTOR_BOTTOM_X = 2;
final byte MOTOR_BOTTOM_Y = 3;

int motorPositions[]       = new int[4];
float motorWaves[]         = new float[4];
float wiggleSinSpeeds[]    = {0.001, 0.005, 0.02, 0.01};
final int maxMotorSpeeds[] = {400, 400, 400, 400};

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
      // TODO
    }
  }
}

void wiggle(){
  // increment all 4 motor sine wave values
  for (byte m = 0; m < 4; m++){
    motorWaves[m] += wiggleSinSpeeds[m];
    motorPositions[m] = floor(sin(motorWaves[m]) * maxMotorSpeeds[m]);

    moveTentacle(m, abs(motorPositions[m]), (motorPositions[m] > 0) ? true : false);
  }

  println(motorPositions[2]);

  // TODO wiggle eye lid occasionally
}
