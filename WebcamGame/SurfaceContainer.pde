class SurfaceContainer {

  //Top left position
  final private int positionX;
  final private int positionY;

  PGraphics graphic;

  SurfaceContainer (int width_, int height_, String mode, int positionX, int positionY) {
    this.graphic= createGraphics(width_, height_, mode); 

    this.positionX=positionX;
    this.positionY=positionY;
  }
  
  boolean isIn(int x,int y){
    return (x>positionX && x<positionX+graphic.width && y>positionY && y<positionY+graphic.height);
  }
  
  int getX(){
    return positionX;
  }
  
  int getY(){
    return positionY;
  }
  
  int getWidth(){
    return graphic.width;
  }
  
  int getHeight(){
     return graphic.height;
  }
  
}
