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
  } else if (key == 'h'){
    txPacket[packet_pos_flag] = packet_flag_stepper_home;
    serialTx(txPacket);
  } else if (key == 'w'){
    txPacket[packet_pos_flag] = packet_flag_change_state;
    txPacket[packet_pos_data] = STATE_WIGGLE;
    serialTx(txPacket);
  }
}

void mousePressed(){
  println(mouseX + ", " + mouseY);
  if (USING_KINECT) println(depthData[(mouseY / scale) * kinectDepthW + (mouseX / scale)]);
}
