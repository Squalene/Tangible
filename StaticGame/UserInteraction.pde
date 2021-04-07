//To prevent huge difference gap
void mousePressed() {

  if(gameSurface.isIn(mouseX,mouseY)){
    pressedInGameSurface = true;
    horizontalScrollbar.setActive(false);
  }
  
  switch(gameState) {
  case PLAYING: 
    {
      clickedOnce=true;
    }
    break;

  case EDITING: 
    {

      float x=mouseX-gameSurface.graphic.width/2;
      float z=mouseY-gameSurface.graphic.height/2;

      PVector position = new PVector(x, platform.groundLevel(), z);

      if (platform.isOnPlatformCircle(position, ParticleSystem.CYLINDER_RADIUS) 
        && !ball.isOverlappingCircle(position, ParticleSystem.CYLINDER_RADIUS)) {

        particleSystem=new ParticleSystem(position);
      }
    }
    break;
  }
}


void mouseDragged() {

  if (gameState==GameState.PLAYING && pressedInGameSurface) {
    float diffX=xPrev-mouseX;
    float diffY=yPrev-mouseY;
    
    xPrev=mouseX;
    yPrev=mouseY;

    //To prevent huge difference gap
    if (clickedOnce) {
      diffX=0;
      diffY=0;
      clickedOnce=false;
    }

    addRotX(diffY*MOUSE_DRAG_ANGLE_RATIO*speed);

    addRotZ(-diffX*MOUSE_DRAG_ANGLE_RATIO*speed);
  }
}

void mouseReleased() {
    pressedInGameSurface = false;
    horizontalScrollbar.setActive(true);

}

void mouseWheel(MouseEvent event) {
  addSpeed(WHEEL_SPEED_RATIO* event.getCount());
} 

//Not needed
void keyPressed() { 
  //if (key == CODED) {
  //  if (keyCode == UP) {
  //    addRotX(PI/18);
  //  } else if (keyCode == DOWN) {
  //    addRotX(-PI/18);
  //  } else if (keyCode == RIGHT) {
  //    rotY += PI/18;
  //  } else if (keyCode == LEFT) {
  //    rotY -= PI/18;
  //  } else if (keyCode == TAB ) {
  //    rotZ += PI/18;
  //  }
  //}

  if (key == CODED) {
    if (keyCode == SHIFT) { 
      gameState=GameState.EDITING;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) { 
      gameState=GameState.PLAYING;
    }
  }
}
