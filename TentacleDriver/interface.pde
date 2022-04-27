void keyPressed(){
  if (key == 'f'){
    depthMode = DEPTH_FLAT_THRESH;
  } else if (key == 'a'){
    depthMode = DEPTH_ALL;
  } else if (key == '['){
    if (minBlobSize > 1) minBlobSize -= 100;
    println(minBlobSize);
  } else if (key == ']'){
    minBlobSize += 100;
    println(minBlobSize);
  }
}

void mousePressed(){
  println(mouseX + ", " + mouseY);
  if (USING_KINECT) println(depthData[(mouseY / scale) * kinectDepthW + (mouseX / scale)]);
}
