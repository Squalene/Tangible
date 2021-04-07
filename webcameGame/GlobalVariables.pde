//Constants for text
final static float TEXT_SIZE_GAME=16;
final static float TEXT_B_BOSS_SIZE = 42;
final static int SHIFT_FOR_TEXT_CENTER = (int)(TEXT_B_BOSS_SIZE/3);


//Constants for main window size
final static int WINDOW_HEIGHT=800;
final static int WINDOW_WIDTH=1000;

//Constants for surface
final static int PADDING_BORDER_ELEMENTS = 10;
final static int PADDING_BETWEEN_ELEMENTS = 15;
final static int SCOREBOARD_CONTOUR_WIDTH = 2; //White area of the scoreboard
final static int BAR_CHART_NUMBER_MAX_RECTANGLES_HORIZONTAL = 30;
final static int BAR_CHART_NUMBER_MAX_RECTANGLES_VERTICAL = 40;


//Constants for sensibility
final static float WHEEL_SPEED_RATIO=0.02;
final static float MOUSE_DRAG_ANGLE_RATIO=0.004;
final static float MAX_SPEED=2;
final static float MIN_SPEED = 0.5;

//Constants for Platform size
final static float PLATFORM_X_LENGTH=400;
final static float PLATFORM_Y_LENGTH=30; 
final static float PLATFORM_Z_LENGTH=PLATFORM_X_LENGTH;
final static float MAX_PLATFORM_ANGLE = PI/3;

//Constants for colors
final static int RED=#FF0000;
final static int GREEN=#00FF00;
final static int BLUE=#0000FF;
final static int BLACK=#000000;
final static int WHITE=#FFFFFF;

final static int PLATFORM_COLOR=#D1D1D1; //Grey
final static int GAME_SURFACE_BACKGROUND = WHITE;
final static int BOTTOM_PANE_SURFACE_BACKGROUND=#003366; //#ffecb3; // Dark blue
final static int TOP_VIEW_SURFACE_BACKGROUND = #e6e6ff;//#000099; //Light blue
final static int BALL_COLOR = RED;  
final static int BOSS_COLOR = BOTTOM_PANE_SURFACE_BACKGROUND;
final static int CYLINDER_COLOR = WHITE;
final static int SCOREBOARD_SURFACE_BORDER = WHITE; //Color of the border of the scoreboard
final static int SCOREBOARD_FILLING_INSIDE = BOTTOM_PANE_SURFACE_BACKGROUND; //real color of the inside of the scoreboard
final static int TEXT_COLOR_SCOREBOARD = WHITE;
final static int BARCHART_SURFACE_BACKGROUND = TOP_VIEW_SURFACE_BACKGROUND;
final static int BARCHART_RECTANGLE_COLOR = BOTTOM_PANE_SURFACE_BACKGROUND;
final static int SCROLLBAR_PANE_SURFACE_BACKGROUND = BOTTOM_PANE_SURFACE_BACKGROUND;
final static int SCROLLBAR_SLIDER_COLOR_MOUSE_OVER = RED;
final static int SCROLLBAR_SLIDER_COLOR_MOUSE_NOT_OVER = #ff6666; //Light red
final static int SCROLLBAR_BACKROUND = TOP_VIEW_SURFACE_BACKGROUND;

//Constant for frameRate
final static int FRAME_RATE = 60;

//Constants for Axis/letters
final static float PLATFORM_AXIS_RATIO= 4.0/3;
final static float AXIS_LETTER_SHIFT= 1.0/45;

//Constant for physics
final static float NORMAL_FORCE=1;
final static float GRAVITY = 0.9;
final static float MU=0.1;
final static float CYLINDER_BOUNCE_RATIO = 1;
final static float PLATFORM_EDGE_BOUNCE_RATIO = 0.9;
final static float FRICTION_MAGNITUDE=NORMAL_FORCE*MU;

//Constant for graphics

static SurfaceContainer gameSurface;
static SurfaceContainer bottomPane;
static SurfaceContainer topView;
static SurfaceContainer scoreboard;
static SurfaceContainer barChart;
static SurfaceContainer scrollbarPane;

//Constants for the game
static final float GAME_PLAYING_SCALE = 0.75;
static final float GAME_EDITING_SCALE = GAME_PLAYING_SCALE;

// Object variables
MovingBall ball;
Platform platform;
ParticleSystem particleSystem;
HScrollbar horizontalScrollbar;

//States
public enum GameState {PLAYING,EDITING};
GameState gameState;

//Object constant
final static float BALL_RADIUS=17;
final static String BALL_IMAGE_NAME = "cropedBall.jpg";

//variables for user interaction
boolean clickedOnce=false; //used to ensure that we don't jump on mouse dragged
//boolean isMovingThePlatform = false; //used to avoid to stop moving the platform when we go outside the gameSurface in the same mouseDragged
boolean pressedInGameSurface = false;

//Variables for the angle of the rotation along x/y/z
float rotX=0;
float rotY=0;
float rotZ=0;

//Variable for the speed (sensitivity) of the movements due to mouseDragged
float speed=1.0;

//Variables used to detect movement on x/y directions
float xPrev=0;
float yPrev=0;


//Variables to keep the score:
int score = 0;
int lastScore = 0;
final static float POINTS_WON_FACTOR = 0.05;
final static int BOSS_POINTS = 20;
final static int CYLINDER_POINTS = 10;
final static int LOST_POINTS = 3;
static int[] oldScores;
static int nbrElement = 0;
final static float SCROLLBAR_MIN_BOUND = 0.2;
final static float SCROLLBAR_MAX_BOUND = 1;
final int NBR_MAX_ELEMENTS = (int)(BAR_CHART_NUMBER_MAX_RECTANGLES_HORIZONTAL*(1/SCROLLBAR_MIN_BOUND));

//Variables for imageProcessing
ImageProcessing imgproc;



/**
 * Add the angle "addedAngle" to the previous angle and clamp it in the
 * range ]-maxAngle,maxAngle].
 * 
 * @param newAngle: the newAngle
 * @param maxAngle: Maximum angle.
 * @return: The new angle clamped
 */
float clampAngle(float newAngle, float maxAngle) {

  if (newAngle>PI)
    newAngle-=TWO_PI;

  else if (newAngle<=-PI)
    newAngle+=TWO_PI;

  if (newAngle<0)
    newAngle=Math.max(newAngle, -maxAngle);

  else 
  newAngle=Math.min(maxAngle, newAngle);

  return newAngle;
}

/**
 * Add a rotation in the x axis (modify the variable rotX).
 * 
 * @param rot: Rotation to be added.
 */
void addRotX(float rot) {
  rotX=clampAngle(rotX + rot, MAX_PLATFORM_ANGLE);
}

/**
 * Add a rotation in the y axis (modify the variable rotY).
 * 
 * @param rot: Rotation to be added.
 */
void addRotY(float rot) {
  rotY=clampAngle(rotY + rot, MAX_PLATFORM_ANGLE);
}

/**
 * Add a rotation in the z axis (modify the variable rotZ).
 * 
 * @param rot: Rotation to be added.
 */
void addRotZ(float rot) {
  rotZ=clampAngle(rotZ + rot, MAX_PLATFORM_ANGLE);
}

void setRotX(float rot){
    rotX =  clampAngle(rot, MAX_PLATFORM_ANGLE);
}
void setRotY(float rot){
    rotY =  clampAngle(rot, MAX_PLATFORM_ANGLE);
}
void setRotZ(float rot){
    rotZ =  clampAngle(rot, MAX_PLATFORM_ANGLE);
}
/**
 * Add speed (modify the variable speed) and verify that the resulting 
 * speed is not negativ.
 * 
 * @param addedSpeed: speed to be added.
 */
void addSpeed(float addedSpeed) {
  speed+=addedSpeed;
  speed= Math.max(MIN_SPEED, speed);
  speed =Math.min(speed,MAX_SPEED);
  ;
}

/**
 * Return true if 1 seconds has elapsed since last time
 */
boolean oneSecondElapsed(){
  return xSecondsElapsed(1);
}

/**
 * Return true if x seconds have elapsed since last time
 * 
 * @param x: number of seconds.
 */
boolean xSecondsElapsed(float x){
  return frameCount%((int)(FRAME_RATE*x)) == 0;
}


void updateScore(){
  if(oneSecondElapsed()){
    oldScores[nbrElement % oldScores.length] = score;
    ++nbrElement;
  }
}

//void updateGroundGravity() {
  
//  gravityForce.x = sin(rotZ) * GRAVITY;
//  gravityForce.z = -sin(rotX) * GRAVITY;
  
//}
