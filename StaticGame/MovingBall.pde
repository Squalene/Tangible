class MovingBall {
  
  PImage img;
  PShape ballShape;
  PVector center;
  PVector velocity;
  float radius;

  MovingBall(PVector center, PVector velocity, float radius, String imageName) {
    this.center = center;
    this.velocity = velocity; 
    this.radius=radius;
    initTexture(radius, imageName);
  }

  void update() {
    
    PVector gravityForce=new PVector(0, 0, 0);

    if (isOnTheGround()) {
      gravityForce.x = sin(rotZ) * GRAVITY;
      gravityForce.z = -sin(rotX) * GRAVITY;
    }
        
    PVector friction = velocity.copy(); 
    friction.mult(-1);
    friction.normalize(); 
    friction.mult(FRICTION_MAGNITUDE);
    
    PVector oldVelocity = velocity.copy();
    PVector oldCenter = center.copy();

    //Must add friction 
    //velocity.add(gravityForce);
    velocity.add(gravityForce).add(friction);
    center.add(velocity);

    checkEdges(oldVelocity);
    
    if (particleSystem!=null) {
      checkCollision();
    }
    
    addShapeRotation(oldCenter);
    
  }


  void displayGame(PGraphics surface) {

    surface.pushMatrix();
    surface.noStroke();
    surface.lights();
    surface.translate(center.x, center.y, center.z);
    surface.shape(ball.ballShape);
    surface.stroke(BLACK);

   surface. popMatrix();
  }
  
  void displayTopView(PGraphics surface, int ballColor) {
    surface.pushMatrix();
    
    surface.fill(ballColor);
    surface.ellipse(center.x, center.z, 2*radius, 2*radius);
    
    surface. popMatrix();

  }

  /**
   * Check if the ball is on the ground of the platform.
   */
  boolean isOnTheGround() {
    return center.y == -radius-PLATFORM_Y_LENGTH/2;
  }

  /**
   * Check if a given vector is inside the radius of the ball.
   * 
   * @param p: vector to check.
   */
  boolean isOccupied(PVector p) {
    return( 
      Math.pow(p.x-center.x, 2)+ Math.pow(p.y-center.y, 2)
      +Math.pow(p.z-center.z, 2)<=Math.pow(radius, 2)
      );
  }

  /**
   * Control if a circular object is overlapping with the ball.
   * 
   * @param thatCenter: center of the other circular shape.
   * @param thatRadius: radius of the other circular shape.
   */
  boolean isOverlappingCircle(PVector thatCenter, float thatRadius) {
    return( 
      (Math.pow(thatCenter.x-center.x, 2)+Math.pow(thatCenter.z-center.z, 2)<=Math.pow(radius+thatRadius, 2))
      );
  }

  /**
   * Check colisions with the border of the plateform. Modify the velocity and the location of the ball accordingly.
   */
  void checkEdges(PVector oldVelocity) {

    if (center.x >= platform.maxX() &&  velocity.x>0) {
      velocity.x = -oldVelocity.x* PLATFORM_EDGE_BOUNCE_RATIO;
      center.x=platform.maxX();
    } else if (center.x <=platform.minX() && velocity.x<0 ) {
      velocity.x = -oldVelocity.x * PLATFORM_EDGE_BOUNCE_RATIO;
      center.x=platform.minX();
    }

    if (center.z >= platform.maxZ() &&  velocity.z>0) {
      velocity.z = -oldVelocity.z* PLATFORM_EDGE_BOUNCE_RATIO;
      center.z=platform.maxZ();
    } else if (center.z <= platform.minZ() &&  velocity.z<0) {
      velocity.z = -oldVelocity.z * PLATFORM_EDGE_BOUNCE_RATIO;
      center.z=platform.minZ();
    }

    if (center.y >= -radius+platform.groundLevel()) {
      velocity.y = -oldVelocity.y * PLATFORM_EDGE_BOUNCE_RATIO;
      center.y=-radius+platform.groundLevel() ;
    }
  }

  /**
   * Check collisions with a cylinder obstacle. Modify the velocity and the location of the ball accordingly.
   */
  boolean cylinderCollision(Cylinder cylinder) {
    if (cylinder.isOverlappingCircle(this.center, this.radius)) {
      PVector normal = new PVector(this.center.x-cylinder.center.x, 0, this.center.z-cylinder.center.z).normalize(); 
      PVector direction = normal.copy().mult(this.radius+cylinder.radius);

      this.center = new PVector(cylinder.center.x+direction.x, platform.groundLevel()-this.radius, cylinder.center.z+direction.z);
      this.velocity = this.velocity.sub(normal.mult(this.velocity.dot(normal)*2)).mult(CYLINDER_BOUNCE_RATIO);
      return true;
    }
    return false;
  }

  void checkCollision() {

    for (int i=0; i<particleSystem.cylinders.size(); ++i) {
      if (this.cylinderCollision(particleSystem.cylinders.get(i))) {
        //Inform particle system that there is a collision with one of its cylinders
        particleSystem.ballCollision(i, this.velocity.mag());
      }
    }
  }

  /**
   * Init the texture of the ball
   * 
   * @param radius: radius of ball.
   * @param imageName: name of the image used for the texture.
   */
  void initTexture(float radius, String imageName) {
    this.img= loadImage(imageName);
    this.ballShape = createShape(SPHERE, radius);
    this.ballShape.setStroke(false);
    this.ballShape.setTexture(img);
  }

  /**
   * Add a rotation to the shape of the ball to make more real.
   * Modify shape's rotation
   * 
   * @param oldLocation: location the frame before.
   * @param location: location this frame.
   */
  void addShapeRotation(PVector oldLocation) {
    PVector locationDiff = this.center.copy().sub(oldLocation);
    this.ballShape.rotate(locationDiff.x/(radius), 0.0, 0.0, 1.0);
    this.ballShape.rotate(locationDiff.y/(radius), 0.0, 1.0, 0.0);
    this.ballShape.rotate(locationDiff.z/(radius), -1.0, 0.0, 0.0);
  }
  
  PVector getVelocity(){
    return velocity.copy();
  }
    
    
}
