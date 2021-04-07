class ParticleSystem {

  final static float CYLINDER_RADIUS=30;
  final static float CYLINDER_HEIGHT=45;
  final static int BOSS_INDEX=0;
  final static float BOSS_SCALE=60;
  final static String BOSS_OBJ="robotnik.obj";
  final static String BOSS_TEXTURE="robotnik.png";


  final int NUM_ATTEMPTS = 1000;
  final static float CYLINDER_SPAWN_TIME=1;//Time in seconds between two new cylinders

  private float previousBossAngle;
  private PShape bossShape;



  boolean isDead;
  float cylinderRadius;
  float cylinderHeight;

  ArrayList<Cylinder> cylinders;
  PVector origin;


  ParticleSystem(PVector origin, float cylinderRadius, float cylinderHeight) {
    this.cylinderRadius=cylinderRadius;
    this.cylinderHeight=cylinderHeight;
    this.origin= origin.copy();
    cylinders=new ArrayList();
    this.cylinders.add(new Cylinder(this.origin, this.cylinderRadius, this.cylinderHeight));
    isDead=false;
    initBoss();
  }

  ParticleSystem(PVector origin) {
    this(origin, CYLINDER_RADIUS, CYLINDER_HEIGHT);
  }

  void addCylinder() {

    PVector center;

    for (int i=0; i<NUM_ATTEMPTS; i++) {
      // Pick a cylinder and its center.
      int index=int(random(this.cylinders.size()));
      center= this.cylinders.get(index).center.copy();// Try to add an adjacent cylinder.
      float angle= random(TWO_PI);

      center.x += sin(angle) * 2*this.cylinderRadius;
      center.z += cos(angle) * 2*this.cylinderRadius;

      if (checkPosition(center)) {
        this.cylinders.add(new Cylinder(center, this.cylinderRadius, this.cylinderHeight));
        score -= LOST_POINTS;
        break;
      }
    }
  }

  boolean checkPosition(PVector center) {

    if (!platform.isOnPlatformCircle(center, this.cylinderRadius) 
      || ball.isOverlappingCircle(center, this.cylinderRadius)) {
      return false;
    }
    for (Cylinder c : cylinders) {
      if (!(checkOverlap(center, c.center))) {
        return false;
      }
    }
    return true;
  }

  boolean checkOverlap(PVector c1, PVector c2) {
    return((Math.pow(c1.x-c2.x, 2)+Math.pow(c1.z-c2.z, 2)>Math.pow(2*CYLINDER_RADIUS, 2)));
  }

  void update() {
    if (!isDead) {
      if (xSecondsElapsed(CYLINDER_SPAWN_TIME)) {
        addCylinder();
      }
      followBall();
    }
  }


  void ballCollision(int i, float ballVelocity) {
    //When we hit the boss, all other cylinders disappear
    lastScore = score;
    if (i==BOSS_INDEX) {
      this.cylinders=new ArrayList();
      this.origin=null;
      isDead=true;
      score += (int)(ballVelocity*POINTS_WON_FACTOR*BOSS_POINTS);
    } else {
      cylinders.remove(i);
      score += (int)(ballVelocity*POINTS_WON_FACTOR*CYLINDER_POINTS);
    }
  }

  void displayGame(PGraphics surface) {
    for (Cylinder c : cylinders) {
      c.display(surface);
    }
    if (!isDead) {
      drawBoss(surface);
    }
  }

  void displayTopView(PGraphics surface, int bossColor, int cylinderColor) {

    surface.pushMatrix();

    for (int i=0; i< cylinders.size(); ++i) {
      Cylinder cylinder = cylinders.get(i);
      if (i == BOSS_INDEX) {
        surface.fill(bossColor);
        surface.ellipse(cylinder.center.x, cylinder.center.z, 2*cylinder.radius, 2*cylinder.radius);
        surface.pushMatrix();
        surface.fill(WHITE);
        surface.textSize(TEXT_B_BOSS_SIZE);
        surface.text("B", cylinder.center.x - SHIFT_FOR_TEXT_CENTER, cylinder.center.z + SHIFT_FOR_TEXT_CENTER);
        surface.popMatrix();
      } else {
        surface.fill(cylinderColor);
        surface.ellipse(cylinder.center.x, cylinder.center.z, 2*cylinder.radius, 2*cylinder.radius);
      }
    }

    surface. popMatrix();
  }

  void initBoss() {
    bossShape = loadShape(BOSS_OBJ);   

    this.bossShape.rotate(PI, 1.0, 0.0, 0.0);
    this.bossShape.rotate(PI, 0.0, 1.0, 0.0);
    previousBossAngle=0;
    followBall();
  }

  void drawBoss(PGraphics surface) {

    surface.pushMatrix();

    Cylinder bossCylinder= cylinders.get(BOSS_INDEX);
    PVector bossPosition=bossCylinder.center;
    surface.translate(bossPosition.x, bossPosition.y-bossCylinder.cylinderHeight, bossPosition.z);
    surface.scale(BOSS_SCALE);
    surface.shape(bossShape);

    surface.popMatrix();
  }

  void followBall() {
    PVector fixedBossAxis=new PVector(0, 0, 1);
    PVector ball2DPosition=new PVector(ball.center.x, 0, ball.center.z);
    PVector boss3DPosition=this.cylinders.get(BOSS_INDEX).center;
    PVector boss2DPosition=new PVector(boss3DPosition.x, 0, boss3DPosition.z);

    PVector bossToBall=ball2DPosition.sub(boss2DPosition);

    float angleBossBall=angleBetween(bossToBall, fixedBossAxis);

    this.bossShape.rotate(angleBossBall-previousBossAngle, 0, 1, 0);

    previousBossAngle=angleBossBall;
  }


  float angleBetween(PVector v1, PVector v2) {
    float a = atan2(v2.z, v2.x) - atan2(v1.z, v1.x);
    if (a < 0) a += TWO_PI;
    return a;
  }
}
