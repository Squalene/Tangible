void settings() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT, P3D);
}

void setup() {
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  
  loadImages();
  setupWebcam();
  
  frameRate(FRAME_RATE);
  
  //Used for image Processing
  imgproc = new ImageProcessing();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);

  //Constants for every surfaces
  final int GAME_SURFACE_WIDTH=WINDOW_WIDTH;
  final int GAME_SURFACE_HEIGHT=(int)(WINDOW_HEIGHT*(3.0/4));
  
  final int BOTTOM_PANE_SURFACE_WIDTH=WINDOW_WIDTH;
  final int BOTTOM_PANE_SURFACE_HEIGHT= WINDOW_HEIGHT-GAME_SURFACE_HEIGHT;
  
  final int TOP_VIEW_SURFACE_HEIGHT= BOTTOM_PANE_SURFACE_HEIGHT-2*PADDING_BORDER_ELEMENTS;
  final int TOP_VIEW_SURFACE_WIDTH = TOP_VIEW_SURFACE_HEIGHT;
  
  final int SCOREBOARD_SURFACE_WIDTH = TOP_VIEW_SURFACE_WIDTH;
  final int SCOREBOARD_SURFACE_HEIGHT = TOP_VIEW_SURFACE_WIDTH;
  final int SCOREBOARD_START_WIDTH = PADDING_BORDER_ELEMENTS + TOP_VIEW_SURFACE_WIDTH + PADDING_BETWEEN_ELEMENTS;
  final int SCOREBOARD_START_HEIGHT = GAME_SURFACE_HEIGHT + PADDING_BORDER_ELEMENTS;
  
  
  final int BAR_CHART_SURFACE_WIDTH = WINDOW_WIDTH - (SCOREBOARD_START_WIDTH+SCOREBOARD_SURFACE_WIDTH)- PADDING_BETWEEN_ELEMENTS - PADDING_BORDER_ELEMENTS;
  final int BAR_CHART_SURFACE_HEIGHT = (int)(TOP_VIEW_SURFACE_HEIGHT*(4.0/5));
  final int BAR_CHART_START_WIDTH = SCOREBOARD_START_WIDTH+SCOREBOARD_SURFACE_WIDTH+PADDING_BETWEEN_ELEMENTS;
  final int BAR_CHART_START_HEIGHT = SCOREBOARD_START_HEIGHT;
  
  
  
  final int SCROLLBAR_SURFACE_WIDTH = BAR_CHART_SURFACE_WIDTH;
  final int SCROLLBAR_SURFACE_HEIGHT = BOTTOM_PANE_SURFACE_HEIGHT - BAR_CHART_SURFACE_HEIGHT - 3*PADDING_BORDER_ELEMENTS;
  final int SCROLLBAR_START_WIDTH =  BAR_CHART_START_WIDTH;
  final int SCROLLBAR_START_HEIGHT = BAR_CHART_START_HEIGHT + BAR_CHART_SURFACE_HEIGHT + PADDING_BORDER_ELEMENTS;
    
  //Constants for the scrollbar:
  final int HSCROLLBAR_WIDTH = SCROLLBAR_SURFACE_WIDTH/2;
  final int HSCROLLBAR_HEIGHT = SCROLLBAR_SURFACE_HEIGHT/2;

  
  gameSurface = new SurfaceContainer(GAME_SURFACE_WIDTH,GAME_SURFACE_HEIGHT, P3D,0,0);
  bottomPane = new SurfaceContainer (BOTTOM_PANE_SURFACE_WIDTH,BOTTOM_PANE_SURFACE_HEIGHT,P2D,0,GAME_SURFACE_HEIGHT);
  topView = new SurfaceContainer (TOP_VIEW_SURFACE_WIDTH,TOP_VIEW_SURFACE_HEIGHT,P2D,PADDING_BORDER_ELEMENTS,GAME_SURFACE_HEIGHT+PADDING_BORDER_ELEMENTS);
  scoreboard = new SurfaceContainer(SCOREBOARD_SURFACE_WIDTH, SCOREBOARD_SURFACE_HEIGHT, P2D,SCOREBOARD_START_WIDTH,SCOREBOARD_START_HEIGHT);
  barChart = new SurfaceContainer(BAR_CHART_SURFACE_WIDTH, BAR_CHART_SURFACE_HEIGHT, P2D,BAR_CHART_START_WIDTH,BAR_CHART_START_HEIGHT);
  scrollbarPane = new SurfaceContainer (SCROLLBAR_SURFACE_WIDTH, SCROLLBAR_SURFACE_HEIGHT, P2D,SCROLLBAR_START_WIDTH,SCROLLBAR_START_HEIGHT);
  
  oldScores = new int[NBR_MAX_ELEMENTS];
  
  platform=new Platform(PLATFORM_X_LENGTH,PLATFORM_Y_LENGTH,PLATFORM_Z_LENGTH, #D1D1D1);
  ball= new MovingBall(new PVector(0, -BALL_RADIUS +platform.groundLevel(), 0), new PVector(0, 0, 0), BALL_RADIUS, BALL_IMAGE_NAME);
  gameState= GameState.PLAYING;
  particleSystem=null;
  horizontalScrollbar = new HScrollbar( scrollbarPane.getWidth()/4, scrollbarPane.getHeight()/4, HSCROLLBAR_WIDTH, HSCROLLBAR_HEIGHT,scrollbarPane);
  
}
