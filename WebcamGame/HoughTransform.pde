import java.util.Collections;

final float DISCRETIZATION_STEPS_PHI = 0.06f;
final float DISCRETIZATION_STEPS_R = 2.5f; 
final int PHI_DIM = (int) (Math.PI / DISCRETIZATION_STEPS_PHI +1);

float[] tabSin = new float[PHI_DIM];
float[] tabCos = new float[PHI_DIM];

/**
 * Compute the hough algorithm to detect the lines on an image where the edges are filtered
 *
 * @param edgeImg: the image with the sharp edges
 * @param nLines: the maximum number of lines that we want to keep.
 *
 * @return A list of the best nLines represented in the (phi,r) space 
 */
List<PVector> hough(PImage edgeImg, int nLines) {


  //The max radius is the image diagonal, but it can be also negative 
  int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +edgeImg.height*edgeImg.height) * 2) / DISCRETIZATION_STEPS_R +1); // our accumulator
  int [] accumulator = binHoughVotes(edgeImg, rDim);

  ArrayList<PVector> lines = chooseBestLines (accumulator, nLines, rDim);

  return lines;
}

PImage displayAccumulator(int[] accumulator, int rDim) {

  PImage accumulatorImg = createImage(rDim, PHI_DIM, ALPHA);
  accumulatorImg.loadPixels();

  for (int i = 0; i < accumulator.length; ++i) {
    accumulatorImg.pixels[i] = color(min(255, accumulator[i]));
    //System.out.println(accumulator[i]);
  }
  // You may want to resize the accumulator to make it easier to see:

  accumulatorImg.updatePixels();
  accumulatorImg.resize(400, 400);

  return accumulatorImg;
}

/**
 * Display the lines on an image
 *
 * @param lines: the list of points in [r,phi] space.
 * @param imgWidth: the width of the image.
 *
 */
void displayLines (List<PVector> lines, int imgWidth) {

  for (int idx = 0; idx < lines.size(); idx++) { 
    PVector line=lines.get(idx);
    float r = line.x; 
    float phi = line.y;
    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)
    // compute the intersection of this line with the 4 borders of // the image
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = imgWidth;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi)); 
    int y3 = imgWidth;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    // Finally, plot the lines
    stroke(204, 102, 0); 
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    } else {
      if (x1 > 0) {
        if (y2 > 0)
          line(x1, y1, x2, y2); 
        else
          line(x1, y1, x3, y3);
      } else
        line(x2, y2, x3, y3);
    }
  }
}


/**
 * Make the bins vote for their lines.
 *
 * @param edgeImg: the image.
 * @param rDim: the number of bins in the R-dimension.
 *
 * @return an accumulator with the number of votes for the corresponding r/phi pair
 */
int[] binHoughVotes(PImage edgeImg, int rDim) {

  int[] accumulator = new int[PHI_DIM * rDim];

  // Fill the accumulator: on edge points (ie, white pixels of the edge 
  // image), store all possible (r, phi) pairs describing lines going 
  // through the point.

  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {

        for (int phiIndex=0; phiIndex<PHI_DIM; ++phiIndex) {

          int rIndex = (int)(x*tabCos[phiIndex]+y*tabSin[phiIndex]) +rDim/2;

          accumulator[phiIndex*rDim+rIndex]+=1;
        }
      }
    }
  }
  return accumulator;
}

/**
 * Choose the best lines and return them.
 *
 * @param accumulator: the accumulator of the votes for each r/phi pair.
 * @param nLines: the number of lines that we want to keep.
 * @param rDim: the number of bins in the R-dimension.
 *
 * @return a list of vector (r,phi) corresponding to the best nLines lines.
 */
ArrayList<PVector> chooseBestLines (int[] accumulator, int nLines, int rDim) {

  final int MIN_VOTES=100;
  final int RAD = 5;

  ArrayList<Integer> bestCandidates = new ArrayList();

  for (int idx = 0; idx < accumulator.length; idx++) { 
    if (accumulator[idx] > MIN_VOTES) {
      if (accumulator[idx] > valueBiggestNeighbor(accumulator, idx, RAD, rDim)) {
        bestCandidates.add(idx);
      }
    }
  }
  Collections.sort(bestCandidates, new HoughComparator(accumulator));

  ArrayList<PVector> lines=new ArrayList<PVector>(); 


  for (int i=0; i<Math.min(nLines, bestCandidates.size()); ++i) {
    int idx = bestCandidates.get(i);
    // first, compute back the (r, phi) polar coordinates:
    int accPhi = (int) (idx / (rDim));
    int accR = idx - (accPhi) * (rDim);
    float r = (accR - (rDim) * 0.5f) * DISCRETIZATION_STEPS_R; 
    float phi = accPhi * DISCRETIZATION_STEPS_PHI; 
    lines.add(new PVector(r, phi));
  }

  return lines;
}

/**
 * Compute the biggest value of the neighbors (the diagonal is included).
 *
 * @param accumulator: the accumulator of the votes for each r/phi pair.
 * @param centerIdx: the index of the point that we are using.
 * @param radius: the radius in which we should search.
 * @param rDim: the number of bins in the R-dimension.
 *
 * @return the biggestValue found in the neighborhood.
 */
int valueBiggestNeighbor(int[] accumulator, int centerIdx, int radius, int rDim) {

  int rowIndex = centerIdx/rDim; //Index of the row of the center
  int columnIndex = centerIdx % rDim; //Index of the column of the center

  int maxValue = Integer.MIN_VALUE;

  for (int i=-radius; i<radius; ++i) {
    for (int j=-radius; j<radius; ++j) {
      //System.out.println(i +"        "+ j);

      if (!(i==0 && j==0) && isInsideBounds(rowIndex, columnIndex, rDim, i, j)) {
        maxValue = Math.max(maxValue, accumulator[(rowIndex+i)*rDim+(columnIndex+j)]);
      }
    }
  }


  return maxValue;
}

/**
 * Check if the value corresponding to this radius is inside the bounds
 *
 * @param rowIndex: the index of the row of the center.
 * @param columnIndex: the index of the column of the center.
 * @param rDim: the number of bins in the R-dimension.
 * @param i: the current offset along y axis (phi).
 * @param j: the current offset along x axis (r).
 *
 * @return true if the value is inside the bounds.
 */
boolean isInsideBounds(int rowIndex, int columnIndex, int rDim, int i, int j) {
  return ((rowIndex + i)<PHI_DIM && (rowIndex + i)>0) && ((columnIndex + j)<rDim && (columnIndex + j)>0);
}


/**
 * Detects lines in the image and display them on the input image
 *
 * @param img: the image.
 *
 * @return a list of PVector corresponding to the (r,phi) tuples 
 *         in parameter space of every lines on the image
 */
List<PVector> lineDetection (PImage img) {

  PImage colorThresholdBard = thresholdHSBBlackWhite(img, MIN_HUE, MAX_HUE, MIN_SAT, MAX_SAT, MIN_BRIGHT, MAX_BRIGHT);
  PImage gaussianBlur = gaussianBlur(colorThresholdBard); // Usefull to remove noise in scharr process
  PImage blob = findConnectedComponents(gaussianBlur, true);
  PImage scharrBoard = scharr(blob);//Edge detection
  PImage IntensityThreshold = thresholdBinary(scharrBoard, FINAL_BRIGHTNESS_THRESHOLD);//Suppression of pixels with low brightness
  List<PVector> lines = hough(IntensityThreshold, NUMBER_LINES);
  imgproc.image(IntensityThreshold, img.width, 0);
  
  return lines;
}

/**
 * Precompute values of sin and cos used in hough transform
 */
void precomputeTable() {

  float ang = 0;
  float inverseR = 1.f/DISCRETIZATION_STEPS_R;

  for (int accPhi=0; accPhi<PHI_DIM; ang+=DISCRETIZATION_STEPS_PHI, accPhi++) {
    // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
    tabSin[accPhi]=(float)(Math.sin(ang)*inverseR);
    tabCos[accPhi]=(float)(Math.cos(ang)*inverseR);
  }
}

/**
 * Finds the four corners of the board
 *
 * @param img: the image.
 *
 * @return list of the four corners of the board.
 */
List<PVector> findCorners(PImage img) {

  final int MAX_QUAD_AREA = (int)((0.95)*img.width*img.height);
  final int MIN_QUAD_AREA = (int)((0.05)*img.width*img.height);
  final boolean VERBOSE = false;

  List<PVector> lines = lineDetection(img);
  QuadGraph graph = new QuadGraph();
  List<PVector> corners = graph.findBestQuad(lines, img.width, img.height, MAX_QUAD_AREA, MIN_QUAD_AREA, VERBOSE);

  return corners;
}
