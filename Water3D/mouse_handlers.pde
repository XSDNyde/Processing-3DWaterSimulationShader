/* ********************
   **** Mouse View ****
   ******************** */
   
void mouseWheel(MouseEvent event) {
  mouse_zoom = event.getCount() / 10.0;
  if(event.getCount() > 0) m_cam.forward();
  if(event.getCount() < 0) m_cam.backward();
}

void mouseDragged(MouseEvent event) 
{
  if(event.isShiftDown()) {
    mouse_translate_x = (mouseX-pmouseX) / 10.0;
    mouse_translate_y = (mouseY-pmouseY) / 10.0;
  }
  else {
    mouse_angle_y = radians(mouseX-pmouseX) / 10.0;
    mouse_angle_x = radians(mouseY-pmouseY) / 10.0;
  }
}

void mouseClicked() {
  if(mouseButton == RIGHT) {
    m_cam.printKeyStates();
    
    String path1 = savePath("resultingHeightmap.png");
    String path2 = savePath("resultingDelta.png");
    waterHeight.save(path1);
    delta = new PImage(waterHeight.width, waterHeight.height);
    delta.loadPixels();
    for(int i = 0; i < waterHeight.width*waterHeight.height; ++i) {
      delta.pixels[i] = color(f_delta[i], 0,0);
    }
    delta.updatePixels();
    delta.save(path2);
    exit();
  }
}
