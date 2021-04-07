import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.Map;
import java.util.Random;

PImage findConnectedComponents(PImage input, boolean onlyBiggest) {

  PImage result= createImage(input.width, input.height, RGB);

  input.loadPixels();
  result.loadPixels();

  // First pass: label the pixels and store labels' equivalences

  int[] labels = new int[input.width*input.height];
  List<TreeSet<Integer>> labelsEquivalences = new ArrayList<TreeSet<Integer>>();

  //We create a set with the pixels equivalent to black (only 0) just to simplify the later gets
  TreeSet<Integer> equivalenceToBlack = new TreeSet();
  equivalenceToBlack.add(0);
  labelsEquivalences.add(equivalenceToBlack);

  int currentLabel= 1;

  for (int y=0; y<input.height; ++y) {
    for (int x=0; x<input.width; ++x) {
      if (input.pixels[y*input.width + x] == WHITE) {

        TreeSet<Integer> neighboursLabels = new TreeSet();

        // We check the ligne above and the cell before
        if (isInRange(x-1, y-1, input.width, input.height) && labels[(y-1)*input.width + x-1] != 0) {
          neighboursLabels.add(labels[(y-1)*input.width + x-1]);
        }
        if (isInRange(x, y-1, input.width, input.height) && labels[(y-1)*input.width + x] != 0) {
          neighboursLabels.add(labels[(y-1)*input.width + x]);
        }
        if (isInRange(x+1, y-1, input.width, input.height) && labels[(y-1)*input.width + x+1] != 0) {
          neighboursLabels.add(labels[(y-1)*input.width + x+1]);
        }
        if (isInRange(x-1, y, input.width, input.height) && labels[y*input.width + x-1] != 0) {
          neighboursLabels.add(labels[y*input.width + x-1]);
        }

        // If no label was assigned to the neigbors, we assign a new one
        if (neighboursLabels.isEmpty()) {
          labels[y*input.width + x] = currentLabel;

          //Create a new input in labelsEquivalences
          TreeSet<Integer> t = new TreeSet();
          t.add(currentLabel);
          labelsEquivalences.add(t);
          ++currentLabel;
        }
        // Otherwise, we take the smallest label
        else {
          labels[y*input.width + x] = neighboursLabels.first();

          //Update the equivalence classes

          TreeSet<Integer> common = new TreeSet();
          for (Integer i : neighboursLabels) {
            common.addAll(labelsEquivalences.get(i));
          }
          for (Integer i : common) {
            labelsEquivalences.set(i, common);
          }
        }
      } else {
        labels[y*input.width + x] = 0; // Black pixel will have label 0
      }
    }
  }


  // Second pass: re-label the pixels by their equivalent class
  // if onlyBiggest==true, count the number of pixels for each label


  //This set will contain only the final labels after pass 2
  TreeSet<Integer> remainingLabels = new TreeSet();

  Map<Integer, Integer>  labelCount = new HashMap();


  for (int y=0; y<input.height; ++y) {
    for (int x=0; x<input.width; ++x) {

      Integer labelCurrent = labels[y*input.width + x]; 

      if (labelCurrent != 0) {
        Integer smallestLabelCurrent = labelsEquivalences.get(labelCurrent).first();
        labels[y*input.width + x] = smallestLabelCurrent;
        remainingLabels.add(smallestLabelCurrent);

        if (onlyBiggest) {
          if (labelCount.containsKey(smallestLabelCurrent)) {
            labelCount.put(smallestLabelCurrent, labelCount.get(smallestLabelCurrent)+1);
          } else {
            labelCount.put(smallestLabelCurrent, 1);
          }
        }
      }
    }
  }

  // Finally:
  // if onlyBiggest==false, output an image with each blob colored in one uniform color
  // if onlyBiggest==true, output an image with the biggest blob in white and others in black

  if (onlyBiggest) {

    Integer biggestKey = 0;
    Integer biggestValue = 0;

    for (Map.Entry<Integer, Integer> e : labelCount.entrySet()) {
      if (e.getValue() > biggestValue) {
        biggestValue = e.getValue();
        biggestKey = e.getKey();
      }
    }


    for (int y=0; y<input.height; ++y) {
      for (int x=0; x<input.width; ++x) {
        result.pixels[y*input.width + x] = (labels[y*input.width + x] == biggestKey && biggestKey != 0 )? color(255) : color(0);
      }
    }
  } else {

    //Here we choose randomly the color for the differents areas
    Map<Integer, Integer>  labelColor = new HashMap();
    Random rand = new Random();
    for (Integer i : remainingLabels) {
      labelColor.put(i, color(rand.nextInt(256), rand.nextInt(256), rand.nextInt(256))); //Pick a random color
    }


    for (int y=0; y<input.height; ++y) {
      for (int x=0; x<input.width; ++x) {
        if (labels[y*input.width + x] == 0) {
          result.pixels[y*input.width + x] = color(0);
        } else {

          result.pixels[y*input.width + x] = labelColor.get(labels[y*input.width + x]);
        }
      }
    }
  }

  result.updatePixels();

  return result;
}

/**
 * Check whether the (x,y) coordinates are inside the image.
 *
 * @param x: the x coordinate.
 * @param y: the y coordinate.
 * @param imageWidth: the width of the image.
 * @param imageHeight: the height of the image.
 *
 * @return true if the (x,y) coordinates are inside the image, false otherwise.
 */
boolean isInRange(int x, int y, int imageWidth, int imageHeight) {
  return x>=0 && x<imageWidth && y>=0 && y<imageHeight;
}


/**
 * Return an image where only the green bord in the image is white and the rest black
 *
 * @param img: the image.
 *
 * @return an image with the edge of the green border well defined
 */
PImage boardDetection(PImage img) {

  PImage colorThresholdBard = thresholdHSBBlackWhite(img, MIN_HUE, MAX_HUE, MIN_SAT, MAX_SAT, MIN_BRIGHT, MAX_BRIGHT);
  PImage blob = findConnectedComponents(colorThresholdBard, true);

  return blob;
}
