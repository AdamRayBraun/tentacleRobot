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
  } else if (key == 'o'){
    txPacket[packet_pos_flag] = packet_flag_motor_eyelid;
    txPacket[packet_pos_data] = (byte)0;
    serialTx(txPacket);
  } else if (key == 'c'){
    txPacket[packet_pos_flag] = packet_flag_motor_eyelid;
    txPacket[packet_pos_data] = (byte)90;
    serialTx(txPacket);
  }

  byte keyNum = (byte)key;
  if (keyNum >= 48 && keyNum <= 57){
    changeState((byte)(keyNum - 48));
  }
}

void mousePressed(){
  if (mouseY < kinectDepthH){
    println(mouseX + ", " + mouseY);
    if (USING_KINECT) println(depthData[(mouseY / scale) * kinectDepthW + (mouseX / scale)]);
  }
}
