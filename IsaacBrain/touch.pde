void handleRecievedTouch(int id, int shortTouch){
  for (int i = 0; i < pcbVertebrae.NUM_VERTEBRAE; i++){
    if (id == pcbVertebrae.addresses[i]){
      // pcbVertebrae.vertebrae.get(i).lastTouchTime = (shortTouch == 1) ? millis() : millis() - 3000;
      pcbVertebrae.vertebrae.get(i).lastTouchTime = millis();
      return;
    }
  }
}

void handleReceivedTouchPoll(int id, int touchAmt){
  for (int i = 0; i < pcbVertebrae.NUM_VERTEBRAE; i++){
    if (id == pcbVertebrae.addresses[i]){
      pcbVertebrae.vertebrae.get(i).lastTouchPoll = touchAmt;
      return;
    }
  }
}
