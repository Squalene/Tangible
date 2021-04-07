/**
 * Convolute an image with the given kernel. The pixel values of the returned image are a grey-scale (red=green=blue) obtained 
 * by computing the convolution using the sum of the values of the kernel as scaleFactor and the brightness of each pixel. 
 * The kernel.size/2 pixels of the borders are not computed and just returned as black.
 *
 * @param img: the image.
 * @param kernel: the kernel.
 *
 * @return a new image of the convolution.
 */
PImage convoluteImageGreyScale(PImage img, float[][] kernel) {
  PImage result= createImage(img.width, img.height, ALPHA);

  float scaleFactor = kernelNormFactor(kernel);

  img.loadPixels();
  result.loadPixels();

  float[] convolutionValues = computeConvolutionValue(img, kernel, scaleFactor);

  for (int i=0; i<img.width * img.height; ++i) {
    result.pixels[i] = color(convolutionValues[i]);
  }

  result.updatePixels();
  return result;
}

/**
 * Compute the gaussianBlur of an image
 *
 * @param img: the image.
 *
 * @return the gaussianBlur of an image
 */
PImage gaussianBlur(PImage img) {
  return convoluteImageGreyScale(img, GAUSSIAN_KERNEL);
}


/**
 * Compute the values of the convolution of an image with a given kernel and a given scaleFactor 
 * and return them in a 1 dimensional array. The kernel.size/2 pixels of the borders are not 
 * computed and just returned with the value 0.
 *
 * @param img: the image.
 * @param kernel: the kernel.
 * @param scaleFactor: the scaleFactor used to multiply every value.
 *
 * @return a 1D array with the values of the convolution
 */
float[] computeConvolutionValue(PImage img, float[][] kernel, float scaleFactor) {
  assert(kernel[0].length%2 == 1 && kernel.length%2 == 1); //We want the kernel to be (odd x odd)

  float[] result= new float[img.width*img.height];

  img.loadPixels();
  for (int x=kernel[0].length/2; x<img.width-kernel[0].length/2; x++) {

    for (int y=kernel.length/2; y<img.height-kernel.length/2; y++) {

      //compute one value by traversing the kernel
      float total=0;
      for (int xK=0; xK<kernel[0].length; xK++) {

        for (int yK=0; yK<kernel.length; yK++) {
          color pixelVal = img.pixels[(x-kernel[0].length/2+xK)+(y-kernel.length/2+yK)*img.width];
          total+=kernel[yK][xK] * brightness(pixelVal);
        }
      }
      result[y*img.width+x]= total*scaleFactor;
    }
  }

  return result;
}

/**
 * Compute the scharr to detect the edges
 *
 * @param img: the image.
 *
 * @return an image with the edges well defined
 */
PImage scharr(PImage img) {

  PImage result = createImage(img.width, img.height, ALPHA);

  img.loadPixels();
  result.loadPixels();

  float []sumV = computeConvolutionValue(img, V_KERNEL, kernelNormFactor(V_KERNEL));
  float [] sumH = computeConvolutionValue(img, H_KERNEL, kernelNormFactor(H_KERNEL));

  float [] euclideanDistance = new float [img.height*img.width];  
  float max=0;

  for (int i=0; i<img.width*img.height; ++i) {
    euclideanDistance[i] =  euclideanDistance(sumV[i], sumH[i]);
    max = Math.max(max, euclideanDistance[i]);
  }

  //Rescale the intensity in range [0,255]. We also go on the border because the value was 0 (will be set to black).
  for (int y=0; y<img.height; y++) {
    for (int x=0; x<img.width; x++) {
      int val = (int)((euclideanDistance[y*img.width+x]/max)*MAX_INTENSITY);
      result.pixels[y*img.width+x]= color(val);
    }
  }

  result.updatePixels();

  return result;
}

/**
 * Return an image where almost only the border of the green bord in the image are white and the rest black
 *
 * @param img: the image.
 *
 * @return an image with the edge of the green border well defined
 */
PImage edgeDetection(PImage img) {

  PImage colorThresholdBard = thresholdHSBBlackWhite(img, MIN_HUE, MAX_HUE, MIN_SAT, MAX_SAT, MIN_BRIGHT, MAX_BRIGHT);

  PImage gaussianBlur = gaussianBlur(colorThresholdBard); // Usefull to remove noise in scharr process
  PImage scharrBoard = scharr(gaussianBlur);
  PImage IntensityThreshold = thresholdBinary(scharrBoard, FINAL_BRIGHTNESS_THRESHOLD);



  return IntensityThreshold;
}

/**
 * Return a float value representing the norm factor of the kernel (the sum of each value of the kernel)
 *
 * @param kernel: the kernel.
 *
 * @return the norm factor
 */
float kernelNormFactor(float [][] kernel) {

  int total=0;
  for (int i =0; i<kernel.length; ++i) {
    for (int j =0; j<kernel[0].length; ++j) {
      total+=kernel[i][j];
    }
  }
  return total==0? 1: 1.0f/total;
}

/**
 * Return the norm of the vector represented by two floats
 *
 * @param x: x position.
 * @param y: y position.
 *
 * @return the norm
 */
float euclideanDistance(float x, float y) {
  return sqrt(x*x + y*y);
}
