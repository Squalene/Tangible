class Cylinder {

  public PShape openCylinder;
  public PShape bottomCover;
  public PShape topCover;

  final static int cylinderResolution=40;
  float radius;
  float cylinderHeight;
  PVector center;


  Cylinder(PVector location, float radius, float cylinderHeight) {
    this.center = location;
    this.radius=radius;
    this.cylinderHeight=cylinderHeight;
    this.openCylinder=new PShape();
    this.bottomCover=new PShape();
    this.topCover=new PShape();

    build();
  }

  void build() {

    float angle;
    float[] x = new float[cylinderResolution + 1]; 
    float[] z = new float[cylinderResolution + 1];

    //get the x and z position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i; 
      x[i] = sin(angle) * radius;
      z[i] = cos(angle) * radius;
    }
    
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);

    bottomCover = createShape();
    bottomCover.beginShape(TRIANGLE_FAN);

    topCover = createShape();
    topCover.beginShape(TRIANGLE_FAN);


    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) { 
      openCylinder.vertex(x[i], 0, z[i]);
      openCylinder.vertex(x[i], -cylinderHeight, z[i] );
    }
    openCylinder.endShape();
    //draw the top of the cylinder

    topCover.vertex(0, -cylinderHeight, 0);
    bottomCover.vertex(0, 0, 0);

    for (int i=0; i < x.length; i++) {

      topCover.vertex(x[i], -cylinderHeight, z[i]);
      bottomCover.vertex(x[i], 0, z[i]);
    }

    topCover.endShape();
    bottomCover.endShape();
  }


  boolean isOccupied(PVector p) {
    return( 
      (p.y>center.y-cylinderHeight && p.y<center.y) 
      && (Math.pow(p.x-center.x, 2)+Math.pow(p.z-center.z, 2)<=Math.pow(radius, 2))
      );
  }

  boolean isOverlappingCircle(PVector thatCenter, float thatRadius) {
    return( 
      (Math.pow(thatCenter.x-center.x, 2)+Math.pow(thatCenter.z-center.z, 2)<=Math.pow(radius+thatRadius, 2))
      );
  }



  void display(PGraphics surface) {
    surface.pushMatrix();

    surface.translate(center.x, center.y, center.z);
    
    fill(WHITE);
    stroke(BLACK);
    surface.shape(openCylinder);
    surface.shape(bottomCover);
    surface.shape(topCover);

    surface.popMatrix();
  }
  @Override
    public String toString() {
      return "Radius: "+this.radius+" Center:"+this.center+" Height: "+this.cylinderHeight+"\n";
  }
}
