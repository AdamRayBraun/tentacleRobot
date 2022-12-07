boolean drawingInstructions = false;
boolean shiftHeld           = false;
int depthChange             = 20;
int kinectWindowChange      = 10;
int posIncrement            = 50;

void drawInstructions(){
  if (drawingInstructions){
    String instructions = "";
    instructions += "Frame rate: " + frameRate + "\n";
    instructions += "\n";
    instructions += "Toggle depth window with 'w'\n";
    instructions += "\n";
    instructions += "Depth window : " + depthMin + ", " + depthMax + "\n";
    instructions += "  - '-' / '+' to change depthMin\n";
    instructions += "  - '[' / ']' to change depthMax\n";
    instructions += "\n";
    instructions += "Depth X window between " + kinectXMin + " and " + kinectXMax + "\n";
    instructions += "  - 'z' / 'x' to change X min\n";
    instructions += "  - 'c' / 'v' to change X max\n";
    instructions += "\n";
    instructions += "Depth Y window between " + kinectYMin + " and " + kinectYMax + "\n";
    instructions += "  - 'u' / 'i' to change Y min\n";
    instructions += "  - 't' / 'y' to change Y maxn\n";
    instructions += "\n";
    instructions += "Current skip factor : " + pointSkip + "\n";
    instructions += "  - Change with 'g' & 'h'\n";
    instructions += "\n";
    instructions += "Point size : " + pointDiam + "\n";
    instructions += "  - '<' / '>' to change\n";
    instructions += "\n";
    instructions += "Camera\n";
    instructions += "  - Drag to rotate\n";
    instructions += "  - Drag + CMD to pan\n";
    instructions += "  - Scroll to zoom\n";
    instructions += "  - Double click resets camera\n";
    instructions += "  - Hold shift to constrain rotation axis\n";
    instructions += "  - SPACE to print out current camera params\n";
    instructions += "\n";
    instructions += "Toggle movie playback with `p` key\n";
    instructions += "\n";
    instructions += "Point colour: " + pointCol + "\n";
    instructions += "  - change with 'j' & 'k'\n";
    instructions += "\n";
    instructions += "current bg movie: " + movieNames[currentMovieIndex] + "\n";
    instructions += "  - `0` to `9` to change bg render\n";
    instructions += "\n";
    instructions += "bg movies: \n";

    for (int m = 0; m < 10; m++){
      instructions += "- " + movieNames[m] + "\n";
    }

    cam.beginHUD();
    fill(255);
    text(instructions, 20, 20);
    cam.endHUD();
  }
}

void keyPressed(){
  if (key == '?' || key == '/'){
    drawingInstructions = !drawingInstructions;
  } else if (key == 'w'){
    useDepthWindow = !useDepthWindow;
  } else if (key == '-' || key == '_'){
    if (depthMin > 0) depthMin -= depthChange;
  } else if (key == '=' || key == '+'){
    if (depthMin < depthMax) depthMin += depthChange;
  } else if (key == '[' || key == '{'){
    if (depthMax > depthMin) depthMax -= depthChange;
  } else if (key == ']' || key == '}'){
    depthMax += depthChange;
  } else if (key >= 48 && key <= 57){
    changeMovie(int(key) - 48);
  } else if (key == ',' || key == '<'){
    if (pointDiam > 0.2) pointDiam -= 0.2;
  } else if (key == '.' || key == '>'){
    pointDiam += 0.2;
  } else if (key == ' '){
    String currentCam = "CurrentCamera:\n";
    currentCam += "x, y, z, distance : " +
                  cam.getLookAt()[0] + ", " +
                  cam.getLookAt()[1] + ", " +
                  cam.getLookAt()[2] + ", " +
                  cam.getDistance() + "\n";
    println(currentCam);
  } else if (key == 'v'){
    if (kinectXMin > kinectWindowChange) kinectXMin -= kinectWindowChange;
  } else if (key == 'c'){
    if (kinectXMin < kinect2.depthWidth - kinectXMax) kinectXMin += kinectWindowChange;
  } else if (key == 'z'){
    if (kinectXMax > kinectXMin) kinectXMax -= kinectWindowChange;
  } else if (key == 'x'){
    if (kinectXMax < kinect2.depthWidth - kinectWindowChange) kinectXMax += kinectWindowChange;
  } else if (key == 'i'){
    if (kinectYMin > kinectWindowChange) kinectYMin -= kinectWindowChange;
  } else if (key == 'u'){
    if (kinectYMin < kinect2.depthHeight - kinectYMax) kinectYMin += kinectWindowChange;
  } else if (key == 't'){
    if (kinectYMax > kinectYMin) kinectYMax -= kinectWindowChange;
  } else if (key == 'y'){
    if (kinectYMax < kinect2.depthHeight - kinectWindowChange) kinectYMax += kinectWindowChange;
  } else if (key == 'p'){
    playingMovie = !playingMovie;
    if (playingMovie){
      mov.play();
    } else {
      mov.pause();
    }
  } else if (key == 'g'){
    if (pointSkip > 1) pointSkip--;
  } else if (key == 'h'){
    pointSkip++;
  } else if (key == 'j'){
    if (pointCol > 1) pointCol -= 5;
  } else if (key == 'k'){
    if (pointCol < 255) pointCol += 5;
  }
}
