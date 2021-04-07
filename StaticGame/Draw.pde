void draw() {

  drawGame();
  image(gameSurface.graphic, gameSurface.positionX, gameSurface.positionY);

  drawBottomPane();
  image(bottomPane.graphic, bottomPane.positionX, bottomPane.positionY);

  drawTopView();
  image(topView.graphic, topView.positionX, topView.positionY);

  drawScoreBoard();
  image(scoreboard.graphic, scoreboard.positionX, scoreboard.positionY);

  drawBarChart();
  image(barChart.graphic, barChart.positionX, barChart.positionY);
  
  //horizontalScrollbar.update();
  //horizontalScrollbar.display();

  drawScrollbarPane();
  image(scrollbarPane.graphic, scrollbarPane.positionX, scrollbarPane.positionY);
}


void drawEditing(PGraphics surface) {

  surface.pushMatrix();

  drawValues(surface);

  surface.translate(surface.width/2, surface.height/2, 0);
  surface.rotateX(-PI/2);

  surface.scale(GAME_EDITING_SCALE); //Will scale the platform, the particleSystem and the ball.
  platform.display(surface);
  ball.displayGame(surface);


  if (particleSystem!=null) {
    particleSystem.displayGame(surface);
  }
  surface.popMatrix();
}


void drawPlaying(PGraphics surface) {

  drawValues(surface);

  surface.pushMatrix();

  surface.translate(surface.width/2, surface.height/2, 0);
  surface.rotateX(rotX);
  surface.rotateY(rotY);
  surface.rotateZ(rotZ);

  surface.stroke(BLACK);

  surface.scale(GAME_PLAYING_SCALE); //Will scale the Platform, its axis, the particleSystem and the ball.

  platform.display(surface);

  ball.update();
  ball.displayGame(surface);


  if (particleSystem!=null) {
    particleSystem.update();
    particleSystem.displayGame(surface);
  }

  drawAxis(surface);
  surface.popMatrix();
}




/**
 * Draw the Values of the angles/speed in the upper left corner of the screen 
 */
void drawValues(PGraphics surface) {
  surface.pushMatrix();

  surface.fill(RED);
  surface.textSize(TEXT_SIZE_GAME);
  surface.text("RotationX: "+degrees(rotX), 0, TEXT_SIZE_GAME, 0);

  surface.fill(GREEN);
  surface.textSize(TEXT_SIZE_GAME);
  surface.text("RotationY: "+degrees(rotY), 0, 2*TEXT_SIZE_GAME, 0);

  surface.fill(BLUE);
  surface.textSize(TEXT_SIZE_GAME);
  surface.text("RotationZ: "+degrees(rotZ), 0, 3*TEXT_SIZE_GAME, 0);

  surface.fill(BLACK);
  surface.textSize(TEXT_SIZE_GAME);
  surface.text("Speed: "+speed, 0, 4*TEXT_SIZE_GAME, 0);

  surface.popMatrix();
}

/**
 * Draw the axis and their corresponding texts (X/Y/Z) 
 */
void drawAxis(PGraphics surface) {

  final float axisLength = Math.max(Math.max(PLATFORM_X_LENGTH, PLATFORM_Y_LENGTH), PLATFORM_Z_LENGTH)/2;

  surface.stroke(RED);
  surface.line(-axisLength*PLATFORM_AXIS_RATIO, 0, 0, +axisLength*PLATFORM_AXIS_RATIO, 0, 0);
  surface.fill(RED);
  surface.textSize(TEXT_SIZE_GAME);
  surface.text("X", +axisLength*PLATFORM_AXIS_RATIO, axisLength*AXIS_LETTER_SHIFT, 0);

  surface.stroke(GREEN);
  surface.line(0, -axisLength*PLATFORM_AXIS_RATIO, 0, 0, +axisLength*PLATFORM_AXIS_RATIO, 0);
  surface.fill(GREEN);
  surface.textSize(TEXT_SIZE_GAME);
  surface.text("Y", axisLength*AXIS_LETTER_SHIFT, +axisLength*PLATFORM_AXIS_RATIO, 0);

  surface.stroke(BLUE);
  surface.line(0, 0, -axisLength*PLATFORM_AXIS_RATIO, 0, 0, +axisLength*PLATFORM_AXIS_RATIO);
  surface.fill(BLUE);
  surface.textSize(TEXT_SIZE_GAME);
  surface.text("Z", axisLength*AXIS_LETTER_SHIFT, 0, +axisLength*PLATFORM_AXIS_RATIO);
}

void drawGame () {


  gameSurface.graphic.beginDraw();

  gameSurface.graphic.background(GAME_SURFACE_BACKGROUND);

  switch(gameState) {

  case PLAYING: 
    drawPlaying(gameSurface.graphic);
    break;

  case EDITING: 
    drawEditing(gameSurface.graphic);
    break;
  }
  gameSurface.graphic.endDraw();
}

void drawBottomPane() {
  bottomPane.graphic.beginDraw();

  bottomPane.graphic.noStroke();
  bottomPane.graphic.background(BOTTOM_PANE_SURFACE_BACKGROUND);

  bottomPane.graphic.endDraw();
}

void drawTopView() {

  float scalePlatform = topView.getWidth()/platform.xLength;


  topView.graphic.beginDraw();

  topView.graphic.noStroke();
  topView.graphic.background(TOP_VIEW_SURFACE_BACKGROUND);

  topView.graphic.pushMatrix();
  topView.graphic.translate(topView.getHeight()/2, topView.getWidth()/2); //Use the center as origin, just like in the game
  topView.graphic.scale(scalePlatform);

  ball.displayTopView(topView.graphic, BALL_COLOR);

  if (particleSystem!=null) {
    particleSystem.displayTopView(topView.graphic, BOSS_COLOR, CYLINDER_COLOR);
  }

  topView.graphic.popMatrix();
  topView.graphic.endDraw();
}

void drawScoreBoard() {

  final int TEXT_SIZE = 20;
  final int TEXT_PADDING_WIDTH = 10;
  final int TEXT_PADDING_HEIGHT = scoreboard.getHeight()/8;

  scoreboard.graphic.beginDraw();
  scoreboard.graphic.pushMatrix();

  scoreboard.graphic.background(SCOREBOARD_SURFACE_BORDER);

  scoreboard.graphic.pushMatrix();
  scoreboard.graphic.fill(SCOREBOARD_FILLING_INSIDE);
  scoreboard.graphic.noStroke();
  scoreboard.graphic.rect(SCOREBOARD_CONTOUR_WIDTH, SCOREBOARD_CONTOUR_WIDTH, scoreboard.getWidth()-(2*SCOREBOARD_CONTOUR_WIDTH), scoreboard.getHeight()-(2*SCOREBOARD_CONTOUR_WIDTH));
  scoreboard.graphic.popMatrix();

  scoreboard.graphic.fill(TEXT_COLOR_SCOREBOARD);
  scoreboard.graphic.textSize(TEXT_SIZE);
  scoreboard.graphic.text("Total score: ", TEXT_PADDING_WIDTH, TEXT_PADDING_HEIGHT);
  scoreboard.graphic.text(score, TEXT_PADDING_WIDTH, 2*TEXT_PADDING_HEIGHT);

  scoreboard.graphic.text("Velocity: ", TEXT_PADDING_WIDTH, 4*TEXT_PADDING_HEIGHT);
  scoreboard.graphic.text(ball.getVelocity().mag(), TEXT_PADDING_WIDTH, 5*TEXT_PADDING_HEIGHT);

  scoreboard.graphic.text("Last score: ", TEXT_PADDING_WIDTH, 7*TEXT_PADDING_HEIGHT);
  scoreboard.graphic.text(lastScore, TEXT_PADDING_WIDTH, 8*TEXT_PADDING_HEIGHT);

  scoreboard.graphic.popMatrix();
  scoreboard.graphic.endDraw();
}

void drawBarChart() {
  
  final float BAR_CHART_RECTANGLE_WIDTH_MAX = ((float)barChart.getWidth()-(2*PADDING_BORDER_ELEMENTS))/BAR_CHART_NUMBER_MAX_RECTANGLES_HORIZONTAL;
  
  
  updateScore();
  barChart.graphic.beginDraw();
  barChart.graphic.pushMatrix();

  barChart.graphic.fill(BARCHART_RECTANGLE_COLOR);
  barChart.graphic.stroke(WHITE);

  barChart.graphic.background(BARCHART_SURFACE_BACKGROUND);
  barChart.graphic.translate(PADDING_BORDER_ELEMENTS, barChart.getHeight()*(1.0/2));
  
  barChart.graphic.line(-PADDING_BORDER_ELEMENTS, 0, barChart.getWidth()-PADDING_BORDER_ELEMENTS, 0);
  
  final float RECTANGLE_WIDTH = horizontalScrollbar.getPosBounded(SCROLLBAR_MIN_BOUND, SCROLLBAR_MAX_BOUND)*BAR_CHART_RECTANGLE_WIDTH_MAX;
  final int NBR_ELEMENT_TO_PRINT = (int)(((float)barChart.getWidth()-(2*PADDING_BORDER_ELEMENTS))/RECTANGLE_WIDTH);
  
  if(nbrElement<=NBR_ELEMENT_TO_PRINT){
    for(int i=0; i<nbrElement; ++i){
      displayOneColumn(i, oldScores[i], barChart.graphic, RECTANGLE_WIDTH);
    }
  }
  else{
     int head=((nbrElement-NBR_ELEMENT_TO_PRINT)%oldScores.length);

    for (int i=0; i<NBR_ELEMENT_TO_PRINT; ++i) {
      int k=(head+i)%oldScores.length;
      displayOneColumn(i, oldScores[k], barChart.graphic, RECTANGLE_WIDTH);
    }
  }

  barChart.graphic.popMatrix();
  barChart.graphic.endDraw();
}


void displayOneColumn(int columnNumber, int nbrRect, PGraphics surface, float rectangleWidth){
  
    final float BAR_CHART_RECTANGLE_HEIGHT = ((float)barChart.getHeight()-(2*PADDING_BORDER_ELEMENTS))/BAR_CHART_NUMBER_MAX_RECTANGLES_VERTICAL;
    
    surface.pushMatrix();
    
    if (nbrRect<0) {
      for (int j=0; j>nbrRect; --j) {
        nbrRect = Math.max(nbrRect, -BAR_CHART_NUMBER_MAX_RECTANGLES_VERTICAL/2);
        surface.rect(columnNumber*rectangleWidth, -j*BAR_CHART_RECTANGLE_HEIGHT, rectangleWidth, BAR_CHART_RECTANGLE_HEIGHT);
      }
    } else {
      nbrRect = Math.min(nbrRect, BAR_CHART_NUMBER_MAX_RECTANGLES_VERTICAL/2);
      for (int j=0; j<nbrRect; ++j) {
        surface.rect(columnNumber*rectangleWidth, (-j-1)*BAR_CHART_RECTANGLE_HEIGHT, rectangleWidth, BAR_CHART_RECTANGLE_HEIGHT);
      }
    }  
    surface.popMatrix();
}


void drawScrollbarPane(){
  scrollbarPane.graphic.beginDraw();

  scrollbarPane.graphic.background(SCROLLBAR_PANE_SURFACE_BACKGROUND);  
  
  horizontalScrollbar.update();
  horizontalScrollbar.display();
  

  scrollbarPane.graphic.endDraw();
}
