class HoughComparator implements java.util.Comparator<Integer> {

  int[]accumulator;

  public HoughComparator(int[]accumulator) {
    this.accumulator = accumulator;
  }

  @Override public int compare(Integer l1, Integer l2) {
    return (accumulator[l1]>accumulator[l2] || (accumulator[l1]==accumulator[l2]&&l1<l2)) ? -1 : 1;
  }
}
