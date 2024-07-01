/* ****************************
   **** KEYBOARD MOVEMENTS ****
   **************************** */
   
void keyPressed() {
  if(keyCode == LEFT) m_cam.left();
  if(keyCode == RIGHT) m_cam.right();
  if(keyCode == UP) m_cam.up();
  if(keyCode == DOWN) m_cam.down();
  if(keyCode == 33) m_cam.tiltUp();
  if(keyCode == 34) m_cam.tiltDown();
}
