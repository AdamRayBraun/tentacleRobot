void moveTentacleToUser(){
  // if we have at least one person detected
  if (blobs.size() > 0){
    // get position of oldest blob
    PVector personPos = blobs.get(0).getCenter();

    float xDifference = tentacleX - personPos.x;
    float yDifference = tentacleY - personPos.y;

    stroke(255, 0, 0);
    strokeWeight(5);
    noFill();
    line(tentacleX, tentacleY, personPos.x, personPos.y);
    line(tentacleX, tentacleY + kinectDepthH, personPos.x, personPos.y + kinectDepthH);

    // if (xDifference > userDistanceThresh){
    //
    // }
  }
}

void wiggle(){

}
