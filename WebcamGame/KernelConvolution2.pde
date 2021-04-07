
int[][] matrixProduct(int[][] a, int[][] b) {

  if (a == null || b==null) {
    throw new NullPointerException();
  } else if (a[0].length!= b.length) {

    System.err.println("m1.column!=m2.row");
    throw new IllegalArgumentException();
  }


  int [][] res= new int [a.length][b[0].length];

  for (int i=0; i<a.length; ++i) {

    for (int j=0; j<a[0].length; ++j) {

      int total = 0;
      for (int k=0; k<b.length; ++k) {

        total+=a[i][k]*b[k][j];
      }
      res[i][j]=total;
    }
  }
  return res;
}

int elementWiseMatrixMultiplication(int[][] a, int[][] b) {

  if (a == null || b==null) {
    throw new NullPointerException();
  } else if (a.length!= b.length || a[0].length!= b[0].length) {

    System.err.println("Matrices do not have the same size"); 
    throw new IllegalArgumentException();
  }

  int total=0;

  for (int i=0; i<a.length; ++i) {

    for (int j=0; j<a[0].length; ++j) {

      total+=a[i][j]*b[i][j];
    }
  }
  return total;
}


float [][] convoluteMatrix(int[][] a, float[][] kernel, float scaleFactor) {

  if ( kernel.length %2!=1 || kernel[0].length %2!=1 || kernel.length!= kernel[0].length) {

    System.err.println("Kernel is not valid");
    throw new IllegalArgumentException();
  }

  float [][] result= new float [a.length][a[0].length];

  int [][] aExtended= extendMatrix(a, kernel.length/2, kernel[0].length/2);


  for (int i=0; i<a.length; ++i) {

    for (int j=0; j<a[0].length; ++j) {

      //compute one value a result with kernel
      float total=0;
      for (int k=0; k<kernel.length; ++k) {

        for (int l=0; l<kernel[0].length; ++l) {

          total+=kernel[k][l] * brightness(aExtended[i+k][j+l]);
        }
      }
      //result[i][j]= color(total*scaleFactor);
      result[i][j]= total*scaleFactor;
    }
  }
  return result;
}

int [][] scaleMatrix(int[][] a, float scale) {

  int [][]result = new int[a.length][a[0].length];

  for (int i=0; i<a.length; ++i) {

    for (int j=0; j<a[0].length; ++j) {

      result[i][j]= (int) (scale*a[i][j]);
    }
  }

  return result;
}

int [][] extendMatrix(int[][] a, int h, int w) {


  int [][] result = new int [a.length+2*h][a[0].length+2*w];


  for (int i=0; i<a.length; ++i) {
    for (int j=0; j<a[0].length; ++j) {
      result[i+h][j+w]= a[i][j];
    }
  }

  for (int i=0; i<a[0].length; ++i) {


    int copyHigh=a[0][i];
    int copyLow = a[a.length-1][i];
    for (int j=0; j<h; ++j) {

      result[j][w+i]=copyHigh;
      result[a.length+h+j][w+i]=copyLow;
    }
  }

  for (int i=0; i<result.length; ++i) {

    int copyLeft=result[i][w];
    int copyRight = result[i][a[0].length-1+w];
    for (int j=0; j<w; ++j) {

      result[i][j]=copyLeft;
      result[i][j+a[0].length+w]=copyRight;
    }
  }

  return result;
}

String matrixToString(int [][] a) {

  StringBuilder sb= new StringBuilder();
  if (a!=null) {

    for (int i =0; i<a.length; ++i) {


      sb=sb.append("|");

      for (int j=0; j<a[0].length; ++j) {


        sb=sb.append(a[i][j]);

        if (j!=a[0].length-1) {

          sb=sb.append(" , ");
        }
      }
      sb=sb.append("|\n");
    }
  }

  return sb.toString();
}



PImage convoluteImage(PImage img, float[][] kernel) {

  float normFactor = kernelNormFactor(kernel);

  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);

  result.loadPixels();

  int [][] imageMatrix= vectorToMatrix(img.pixels, img.height, img.width);

  float [][] brightnessResult= convoluteMatrix(imageMatrix, kernel, normFactor); 
  
  int [][] colorResult= brightnessToColor(brightnessResult);
  
  //Useless but needed for equality between expected and our result
  colorResult=createBlackBorder(colorResult);

  result.pixels= matrixToVector(colorResult);

  result.updatePixels();

  return result;
}



int [][] vectorToMatrix(int [] vector, int h, int w) {

  assert(vector!=null && vector.length==h*w);

  int [][] result = new int [h][w];

  for (int i=0; i<h; ++i) {
    for (int j=0; j<w; ++j) {

      result[i][j]=vector[i*w+j];
    }
  }

  return result;
}

int [] matrixToVector(int [][] a) {

  int result [] = new int [a.length*a[0].length];

  for (int i=0; i<a.length; ++i) {
    for (int j=0; j<a[0].length; ++j) {

      result[i*a[0].length+j] = a[i][j];
    }
  }
  return result;
}

int [][] brightnessToColor(float [][] a) {

  int result [][] = new int [a.length][a[0].length];

  for (int i=0; i<a.length; ++i) {
    for (int j=0; j<a[0].length; ++j) {

      result[i][j] = color(a[i][j]);
    }
  }
  return result;
}



int [][] createBlackBorder(int [][] a) {

  int [][] result = a.clone();

  for (int i=0; i<a[0].length; ++i) {
    result[0][i] = color(0);
    result[a.length-1][i] = color(0);
  }

  for (int i=0; i<a.length; ++i) {
    result[i][0] = color(0);
    result[i][a[0].length-1] = color(0);
  }

  return result;
}

float [][] createBlackBorder(float [][] a) {

  float [][] result = a.clone();

  for (int i=0; i<a[0].length; ++i) {
    result[0][i] = 0;
    result[a.length-1][i] = 0;
  }

  for (int i=0; i<a.length; ++i) {
    result[i][0] = 0;
    result[i][a[0].length-1] = 0;
  }

  return result;
}
