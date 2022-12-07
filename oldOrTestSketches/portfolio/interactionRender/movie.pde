Movie mov;
boolean playingMovie = true;
int currentMovieIndex;

String[] movieNames = {
                        "0 - Violent touch",
                        "1 - waking up",
                        "2 - humans walking past",
                        "3 - group of humans",
                        "4 - Human moving around Isaac",
                        "5 - Isaac looking around Human",
                        "6 - Isaac greeting unfamiliar human",
                        "7 - Isaac greeting familiar Human",
                        "8 - Isaac hugging familiar human",
                        "9 - Isaac touched by unfamiliar human",
                      };

void setupMovie(){
  changeMovie(0);
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
  if (newMov < 0 || newMov > 10){
    println("ERR: wrong mov index: " + newMov);
    return;
  }

  mov = new Movie(this, (String)(newMov + ".mp4"));
  mov.loop();
  currentMovieIndex = newMov;
}
