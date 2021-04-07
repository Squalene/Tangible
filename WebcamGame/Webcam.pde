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
