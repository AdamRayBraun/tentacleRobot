Movie mov;
int posX, posY, posZ;
boolean playingMovie = true;

void setupMovie(){
  mov = new Movie(this, "1.mp4");
  mov.loop();
}

void playMovie(){
  cam.beginHUD();
  image(mov, 0, 0, width, height);
  cam.endHUD();
}
void movieEvent(Movie m){
  m.read();
}

void changeMovie(int newMov){
  if (newMov < 1 || newMov > 10){
    println("ERR: wrong mov index: " + newMov);
  }

  mov.stop();
  mov = new Movie(this, (String)(newMov + ".mp4"));
  mov.loop();
}
