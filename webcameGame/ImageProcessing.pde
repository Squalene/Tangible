class ImageProcessing extends PApplet {

  PVector boardRotationRadiansBounded = new PVector();
  TwoDThreeD twoDThreeDConverter;
  //Variables for kalman estimation:
  final static float Q = 3;
  final static float R = 12;
  final static int FRAMES_OF_ESTIMATION = 5;
  List<PVector> lastMeasuredCorners = new ArrayList();
  List<KalmanFilter2D> kalmans = new ArrayList();
  


  void settings() {
    size(WINDOW_WIDTH_WEBCAM *2 , WINDOW_HEIGHT_WEBCAM );
  }

  void setup() {  

    //Precompute sin and cos into an array
    precomputeTable();

    opencv = new OpenCV(this, 100, 100);
    
    for(int i=0; i<4; ++i){
      kalmans.add(new KalmanFilter2D(Q, R));
      lastMeasuredCorners.add(new PVector());
    }
    
    drawWebcam(); //To inititialise webcamImg

    twoDThreeDConverter = new TwoDThreeD(webcamImg.width, webcamImg.height, 0);
        
  }

  void draw() {
    

    drawWebcam();
    
    if(mustReMeasureCorners()){
      List<PVector> tmp = findCorners(webcamImg);
      if(!tmp.isEmpty()){
         lastMeasuredCorners = tmp; // We only update it if we were able to find corners
      }
    }
    
    List<PVector> cornerPredictions = new ArrayList();
    
    for(int i=0; i<kalmans.size(); ++i){
      cornerPredictions.add(kalmans.get(i).predict_and_correct(lastMeasuredCorners.get(i)));
    }


    //Transfert quad corners to homogenous coordinate
    for (PVector corner : cornerPredictions) {
      corner.z = 1;
    }


    PVector boardRotationRadians = twoDThreeDConverter.get3DRotations(cornerPredictions);
    boardRotationRadiansBounded = boundVectorAngles(boardRotationRadians);


    image(webcamImg, 0, 0);
    displayCornersAndLines(lastMeasuredCorners);
  }



  PVector getRotation() {
    return boardRotationRadiansBounded;
  }

  /**
   * Add or substract pi to every angles of a vector such that it stays between -PI/2 and PI/2
   *
   * @param vectRad: the vector with angles in radian.
   *
   * @return the new vector with every angles bounded.
   */
  PVector boundVectorAngles (PVector vectRad) {
    PVector newVect = new PVector();
    newVect.x = boundAngle(vectRad.x);
    newVect.y = boundAngle(vectRad.y);
    newVect.z = boundAngle(vectRad.z);

    System.out.println(newVect);

    return newVect;
  }


  /**
   * Add or substract pi to an angle such that it stays between -PI/2 and PI/2
   *
   * @param angle:  the angle in radian.
   *
   * @return the new bounded angle.
   */
  private float boundAngle (float angle) {

    if (angle>PI/2) {
      angle -= PI;
    }
    if (angle<-PI/2) {
      angle += PI;
    }

    return angle;
  }

  /**
   * Display the corners of a rectangular shape and a line between them
   *
   * @param corners: A list containing the corners
   *
   */
  void displayCornersAndLines(List<PVector> corners) {

    pushMatrix();

    final color COLOR_BORDERS_LINES = color(255, 0, 0);
    final color COLOR_INSIDE_CIRCLE = WHITE;
    final int OPACITY = 150;

    stroke(COLOR_BORDERS_LINES); 
    for (int i=0; i<corners.size(); ++i) {
      PVector p1 = corners.get(i);
      PVector p2 = corners.get((i+1)%corners.size());
      line(p1.x, p1.y, p2.x, p2.y);
    }

    for (PVector p : corners) {
      fill(COLOR_INSIDE_CIRCLE, OPACITY);
      circle(p.x, p.y, 30);
    }

    popMatrix();
  }

  void setupWebcam () {

    println("Begin setupWebcam");
    String[] cameras = Capture.list(); 
    println("YO");
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(cameras[i]);
      }
    }

    //select your predefined resolution from the list:
    //cam = new Capture(this, cameras[0]);
    //If you're using gstreamer1.0 (Ubuntu 16.10 and later),
    //select your resolution manually instead:
    cam = new Capture(this, WEBCAM_RESOLUTION_WIDTH, WEBCAM_RESOLUTION_HEIGHT);
    println("Captured Camera ");
    cam.start();
  }

  void drawWebcam() {
    println("Begin drawWebcam");
    if (cam.available() == true) {
      println("Reading Camera ");
      cam.read();
    }
    webcamImg = cam.get();
    image(webcamImg, 0, 0);
  }

  /**
   * Return true if we must recompute the values for the 4 corners with the whole pipeline of imageProcessing.
   */
  boolean mustReMeasureCorners() {
    return (frameCount%FRAMES_OF_ESTIMATION) == 0;
  }
}
