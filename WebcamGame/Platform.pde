class Platform {

  //Constant for world size 

  float xLength;
  float yLength;
  float zLength;
  int platformColor;
  final PVector position=new PVector(0, 0, 0);

  Platform(float xLength, float yLength, float zLength, int platformColor) {

    this.xLength=xLength;
    this.yLength=yLength;
    this.zLength=zLength;
    this.platformColor = platformColor;
  }

  void display(PGraphics surface) {

    surface.fill(platformColor);
    surface.box(xLength, yLength, zLength);
  }

 /**
 * Control if a vector is insid the plateform boundaries.
 * 
 * @param p: position of the other vector.
 */
  boolean isOnPlatform(PVector p) {
    return p.x>this.maxX() && p.x<this.minX() && p.z>this.maxZ() && p.z<this.minZ() &&  p.y==this.groundLevel();
  }
  
 /**
 * Control if a circular object is fully on the plateform.
 * 
 * @param position: position of the other circular shape.
 * @param radius: radius of the other circular shape.
 */
  boolean isOnPlatformCircle(PVector position,float radius){
    
    return position.x+radius<this.maxX() && position.x-radius>this.minX() 
    && position.z+radius<this.maxZ() && position.z-radius>this.minZ();
  }
  
  
  
  /**
  * return the ground level of the plateform (on y axis)
  */
  float groundLevel() {
    return position.y-yLength/2;
  }

  /**
  * return the maximum coordinate of the platform on x axis
  */
  float maxX() {
    return xLength/2;
  }

  /**
  * return the minimum coordinate of the platform on x axis
  */
  float minX() {
    return -xLength/2;
  }

  /**
  * return the maximum coordinate of the platform on z axis
  */
  float maxZ() {
    return zLength/2;
  }

  /**
  * return the minimum coordinate of the platform on z axis
  */
  float minZ() {
    return -zLength/2;
  }
}
