import processing.video.*;
import gab.opencv.*;

Capture cam;
OpenCV opencv;

final static int WEBCAM_RESOLUTION_WIDTH = 640;
final static int WEBCAM_RESOLUTION_HEIGHT = 480;
final static int WINDOW_WIDTH_IP = 800;
final static int WINDOW_HEIGHT_IP = 600;
final static int WINDOW_WIDTH_WEBCAM = WEBCAM_RESOLUTION_WIDTH;
final static int WINDOW_HEIGHT_WEBCAM = WEBCAM_RESOLUTION_HEIGHT;
  

final static int MAX_INTENSITY=255;


PImage webcamImg;

PImage board1;
PImage board2;
PImage board3;
PImage board4;
PImage nao;
PImage expectedHSB;
PImage expectedGaussianBlur;
PImage expectedScharr;
PImage blob;
PImage naoBlob;
PImage houghTest;
PImage accumulatorImage;

//color BLACK = color(0, 0, 0);
//color WHITE = color(255, 255, 255);
//color GREEN = color(0, 255, 0);


//Global constants for board detection
final int MIN_HUE = 85;
final int MAX_HUE = 139;
final int MIN_SAT = 65; //Will remove faded color close to white
final int MAX_SAT = 255;
final int MIN_BRIGHT = 10; //Will remove very dark color close to black
final int MAX_BRIGHT = 230;
final int FINAL_BRIGHTNESS_THRESHOLD = 129; // We only keep values that are bright enough to remove noise
final int NUMBER_LINES = 5;



final static float [][] GAUSSIAN_KERNEL= {{9, 12, 9}, 
  {12, 15, 12}, 
  {9, 12, 9}}; 

final static float [][] IDENTITY_KERNEL= {{0, 0, 0}, 
  {0, 1, 0}, 
  {0, 0, 0}}; 

final static float [][] H_KERNEL= {{3, 10, 3}, 
  {0, 0, 0}, 
  {-3, -10, -3}};

final static float [][] V_KERNEL= {{3, 0, -3}, 
  {10, 0, -10}, 
  {3, 0, -3}}; 

/**
 * Load every Images
 */
void loadImages(){
  
    //Load everyImages
    board1 = loadImage("board1.jpg");
    board2 = loadImage("board2.jpg");
    board3 = loadImage("board3.jpg");
    board4 = loadImage("board4.jpg");
    expectedHSB = loadImage("board1Thresholded.bmp");
    expectedGaussianBlur= loadImage("board1Blurred.bmp");
    blob = loadImage("BlobDetection_Test.png");
    naoBlob = loadImage("nao_blob_compressed.jpg");
    expectedScharr = loadImage("board1Scharr_new.bmp");
    nao = loadImage("nao.jpg");
    houghTest = loadImage("hough_test.bmp");
}

/**
 * Return a Black and White image, all pixels with brightness under the threshold will be black otherwise, they will be white
 *
 * @param img: the image.
 * @param treshold: the treshold.
 *
 * @return binary image
 */
PImage thresholdBinary(PImage img, int threshold) {
  // create a new, initially transparent, 'result' image 
  PImage result = createImage(img.width, img.height, RGB); 
  img.loadPixels();
  result.loadPixels();

  for (int i = 0; i < img.width * img.height; i++) {
    float brightness= brightness(img.pixels[i]);
    float newBrightness= brightness>threshold?MAX_INTENSITY:0;

    result.pixels[i]= color(newBrightness, newBrightness, newBrightness);
  }
  result.updatePixels();
  return result;
}

/**
 * Return a Black and White image, all pixels with brightness under the threshold will be white otherwise, they will be black
 *
 * @param img: the image.
 * @param treshold: the treshold.
 *
 * @return binary image
 */
PImage thresholdBinaryInverted(PImage img, int threshold) {
  // create a new, initially transparent, 'result' image 
  PImage result = createImage(img.width, img.height, RGB); 
  img.loadPixels();
  result.loadPixels();

  for (int i = 0; i < img.width * img.height; i++) {

    float brightness= brightness(img.pixels[i]);
    float newBrightness= brightness<threshold?MAX_INTENSITY:0;

    result.pixels[i]= color(newBrightness, newBrightness, newBrightness);
  }
  result.updatePixels();
  return result;
}

/**
 * Return a greyscale image corresponding to its hue only representation
 *
 * @param img: the image.
 *
 * @return hue image
 */
PImage extractHue(PImage img) {

  PImage result = createImage(img.width, img.height, RGB); 
  img.loadPixels();
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    int hue= (int) hue(img.pixels[i]);
    result.pixels[i]= color(hue, hue, hue);
  }
  result.updatePixels();
  return result;
}

/**
 * Return a greyscale image corresponding to its brightness only representation
 *
 * @param img: the image.
 *
 * @return brightness image
 */
PImage extractBrightness(PImage img) {

  PImage result = createImage(img.width, img.height, RGB); 
  img.loadPixels();
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    int brightness= (int) brightness(img.pixels[i]);
    result.pixels[i]= color(brightness, brightness, brightness);
  }
  result.updatePixels();
  return result;
}

/**
 * Return an tresholded version along its Hue, correct pixels will be white and incorrect will be black 
 *
 * @param img: the image.
 * @param thresholdLow: minimum Hue.
 * @param thresholdHigh: maximum Hue.
 *
 * @return tresholded image
 */
PImage tresholdHueRange(PImage img, int thresholdLow, int thresholdHigh ) {

  PImage result = createImage(img.width, img.height, RGB); 
  img.loadPixels();
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    int hue= (int) hue(img.pixels[i]);

    result.pixels[i] = hue>=thresholdLow &&  hue<thresholdHigh? img.pixels[i]: BLACK;
  }
  result.updatePixels();
  return result;
}

/**
 * Return a tresholded version of the image using its HSB reprentation while converting it to black and white
 *
 * @param img: the image.
 * @param minH: minimum Hue.
 * @param maxH: maximum Hue.
 * @param minS: minimum Saturation.
 * @param maxS: maximum Saturation.
 * @param minB: minimum Brightness.
 * @param maxB: maximum Brightness.
 *
 * @return tresholded image
 */
PImage thresholdHSBBlackWhite(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
  return thresholdHSB(img, minH, maxH, minS, maxS, minB, maxB, false);
}

/**
 * Return a tresholded version of the image using its HSB reprentation while keeping its original color
 *
 * @param img: the image.
 * @param minH: minimum Hue.
 * @param maxH: maximum Hue.
 * @param minS: minimum Saturation.
 * @param maxS: maximum Saturation.
 * @param minB: minimum Brightness.
 * @param maxB: maximum Brightness.
 *
 * @return tresholded image
 */
PImage thresholdHSBColor(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
  return thresholdHSB(img, minH, maxH, minS, maxS, minB, maxB, true);
}

/**
 * Return a tresholded version of the image using its HSB reprentation
 *
 * @param img: the image.
 * @param minH: minimum Hue.
 * @param maxH: maximum Hue.
 * @param minS: minimum Saturation.
 * @param maxS: maximum Saturation.
 * @param minB: minimum Brightness.
 * @param maxB: maximum Brightness.
 * @param inColor: if true, keep the original color, else set resulting color to white.
 *
 * @return tresholded image
 */
PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB, boolean inColor) {
  PImage result = createImage(img.width, img.height, RGB); 
  img.loadPixels();
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    int hue= (int) hue(img.pixels[i]);
    int saturation= (int) saturation(img.pixels[i]);
    int brightness = (int) brightness(img.pixels[i]);

    color chosenColor = inColor ? img.pixels[i] : WHITE;

    result.pixels[i] = hue>=minH &&  hue<=maxH &&
      saturation>=minS &&  saturation<=maxS &&
      brightness>=minB && brightness<=maxB ? chosenColor: BLACK;
  }

  result.updatePixels();
  return result;
}


/**
 * Return a boolean indicating if the images are equal
 *
 * @param img1: the 1st image.
 * @param img2: the 2nd image.
 *
 * @return whether the images are equal or not
 */
boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height) {
    return false;
  }

  img1.loadPixels();
  img2.loadPixels();

  for (int i = 0; i < img1.width*img1.height; i++) {

    color pixel1= img1.pixels[i];
    color pixel2= img2.pixels[i];

    if (red(pixel1) != red(pixel2) || green(pixel1)!=green(pixel2) || blue(pixel1)!=blue(pixel2) ) {
      System.out.println( "Pixels index: "+i+ "  Pixels value:  (our) "+ pixel1+ "!=" +pixel2 +" (expected)");
      System.out.print( "Pixel color: "+i+ "  red:  (our) "+ red(pixel1)+ "!=" +red(pixel2) +" (expected)");
      System.out.print( " green:  (our) "+ green(pixel1)+ "!=" +green(pixel2) +" (expected)");
      System.out.println( " blue:  (our) "+ blue(pixel1)+ "!=" +blue(pixel2) +" (expected)");

      return false;
    }
  }
  return true;
}



/**
 * Return an image where all the pixels in a certain color are replaced by another color
 *
 * @param img: the image.
 * @param before: the color that we want to replace.
 * @param after: the color that we will use to replace the other.
 *
 * @return the same image as the input image but where all the "before" pixels are colored in the "after" color
 */
PImage recolorImage(PImage img, color before, color after) {
  PImage result = createImage(img.width, img.height, RGB);

  for (int y=0; y<img.height; ++y) {
    for (int x=0; x<img.width; ++x) {
      result.pixels[y*img.width + x] = img.pixels[y*img.width + x] == before ? after :  img.pixels[y*img.width + x];
    }
  }
  return result;
}


/**
 * Return a new image with the values of pixels of two images added. Useful when 
 * images have 1 distinct component and the rest is black (=0) 
 *
 * @param img1: the first image.
 * @param img2: the second image.
 *
 * @return a new image with the sum of the pixels of the two images.
 */
PImage addImage(PImage img1, PImage img2) {

  assert(img1.width == img2.width && img1.height == img2.height);

  PImage result = createImage(img1.width, img1.height, ALPHA);


  for (int y=0; y<img1.height; ++y) {
    for (int x=0; x<img1.width; ++x) {
      result.pixels[y*img1.width + x] = img1.pixels[y*img1.width + x] + img2.pixels[y*img2.width + x];
    }
  }

  return result;
}
