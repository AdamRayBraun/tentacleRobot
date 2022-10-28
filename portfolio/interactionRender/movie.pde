Movie mov;
int posX, posY, posZ;
boolean playingMovie = true;

void setupMovie(){
  mov = new Movie(this, "entrance1.mp4");
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
