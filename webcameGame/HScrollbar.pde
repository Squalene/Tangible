class HScrollbar {
  float barWidth;  //Bar's width in pixels
  float barHeight; //Bar's height in pixels
  //The position is established in the surface referential : starting from top left corner of the surface
  float xPosition;  //Bar's x position in pixels
  float yPosition;  //Bar's y position in pixels
  
  float sliderPosition, newSliderPosition;    //Position of slider
  float sliderPositionMin, sliderPositionMax; //Max and min values of slider
  
  boolean locked;     //Is the mouse clicking and dragging the slider now?
  boolean active;    //Choose whether the scrollbar is active or not. When inactive, don't do anything. Can be set from the outside with setActive.
  
  SurfaceContainer surface; 

  /**
   * @brief Creates a new horizontal scrollbar
   * 
   * @param x The x position of the top left corner of the bar in pixels
   * @param y The y position of the top left corner of the bar in pixels
   * @param w The width of the bar in pixels
   * @param h The height of the bar in pixels
   */
  HScrollbar (float x, float y, float w, float h,SurfaceContainer surface) {
    barWidth = w;
    barHeight = h;
    xPosition = x;
    yPosition = y;
    this.surface=surface;
    
    sliderPosition = xPosition + barWidth/2 - barHeight/2;
    newSliderPosition = sliderPosition;
    
    sliderPositionMin = xPosition;
    sliderPositionMax = xPosition + barWidth - barHeight;
    
    active = true;
  }

  /**
   * @brief Updates the state of the scrollbar according to the mouse movement
   */
  void update() {

    if (mousePressed && isActive()) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newSliderPosition = constrain(mouseX-surface.getX() - barHeight/2, sliderPositionMin, sliderPositionMax);
    }
    if (abs(newSliderPosition - sliderPosition) > 1) {
      sliderPosition = sliderPosition + (newSliderPosition - sliderPosition);
    }
  }

  /**
   * @brief Clamps the value into the interval
   * 
   * @param val The value to be clamped
   * @param minVal Smallest value possible
   * @param maxVal Largest value possible
   * 
   * @return val clamped into the interval [minVal, maxVal]
   */
  float constrain(float val, float minVal, float maxVal) {
    return min(max(val, minVal), maxVal);
  }

  /**
   * @brief Gets whether the mouse is hovering the scrollbar
   *
   * @return Whether the mouse is hovering the scrollbar
   */
  boolean isMouseOver() {
    return (mouseX>xPosition+surface.getX() && mouseX<xPosition+surface.getX()+barWidth && 
            mouseY>yPosition+surface.getY() && mouseY<yPosition+surface.getY()+barHeight);
  }
  
   /**
   * @brief Gets whether the mouse is hovering the scrollbar and we are currently not moving the platform of the game
   *
   * @return Whether the mouse is hovering the scrollbar and we are currently not moving the platform of the game
   */
  boolean isActive() {
    return (isMouseOver() && active);
  }

  /**
   * @brief Draws the scrollbar in its current state
   */ 
  void display() {
        
    surface.graphic.pushMatrix();
    surface.graphic.noStroke();
    surface.graphic.fill(SCROLLBAR_BACKROUND);
    surface.graphic.rect(xPosition, yPosition, barWidth, barHeight);
    if (isActive() || locked) {
     surface.graphic.fill(SCROLLBAR_SLIDER_COLOR_MOUSE_OVER);
    }
    else {
     surface.graphic.fill(SCROLLBAR_SLIDER_COLOR_MOUSE_NOT_OVER);
    }
    surface.graphic.rect(sliderPosition, yPosition, barHeight, barHeight);
    surface.graphic.popMatrix();
  }

  /**
   * @brief Gets the slider position
   * 
   * @return The slider position in the interval [0,1] corresponding to [leftmost position, rightmost position]
   */
  float getPos() {
    return (sliderPosition - xPosition)/(barWidth - barHeight);
  }
  
  /**
   * @brief Gets the slider position scale to a different interval
   * 
   * @return The slider position in the interval [min,max] corresponding to [leftmost position, rightmost position]
   */
  float getPosBounded(float min, float max){
    return getPos() * (max-min) + min;
  }
  
   /**
   * @brief Set whether the scrollbar is active or not
   */
  void setActive(boolean a){
    this.active = a;
  }
}
