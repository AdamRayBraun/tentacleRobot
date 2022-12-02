void handleRecievedTouch(int id, int shortTouch){

}

void handleReceivedTouchPoll(int id, int touchAmt){
  for (int i = 0; i < pcbVertebrae.NUM_VERTEBRAE; i++){
    if (id == pcbVertebrae.addresses[i]){
      pcbVertebrae.vertebrae.get(i).lastTouchPoll = touchAmt;
    }
  }
}
