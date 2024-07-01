//PShape createCan(float r, float h, int detail, PImage tex) {
//  textureMode(NORMAL);
//  PShape sh = createShape();
//  sh.beginShape(QUAD_STRIP);
//  sh.noStroke();
//  sh.texture(tex);
//  for (int i = 0; i <= detail; i++) {
//    float angle = TWO_PI / detail;
//    float x = sin(i * angle);
//    float z = cos(i * angle);
//    float u = float(i) / detail;
//    sh.normal(x, 0, z);
//    sh.vertex(x * r, -h/2, z * r, u, 0);
//    sh.vertex(x * r, +h/2, z * r, u, 1);    
//  }
//  sh.endShape(); 
//  return sh;
//}

PShape createTerrain(int size_x, int size_y, PImage tex) {
  //PImage heightmap = checker;
  //heightmap.copy(tex, 0,0, tex.width,tex.height, 0,0, tex.width,tex.height);
  //heightmap.filter(GRAY);
  textureMode(NORMAL);
  PShape sh = createShape();
  sh.beginShape(QUAD_STRIP);
  sh.noStroke();
  sh.texture(tex);
  for(int i = 0; i < size_y-1; ++i) {
    for(int j = 0; j < size_x; ++j) {
      sh.normal(0, -1, 0);
      sh.vertex(j,0,i,1.0/size_x/2.0+float(j)/size_x,1.0/size_y/2.0+float(i)/size_y);
      sh.vertex(j,0,i+1,1.0/size_x/2.0+float(j)/size_x,1.0/size_y/2.0+float(i+1)/size_y);    
    }
    sh.vertex(size_x-1,0,i+1,1.0/size_x/2.0+float(size_x-1)/size_x,1.0/size_y/2.0+float((i+1))/size_y);
    sh.vertex(size_x-1,0,i+1,1.0/size_x/2.0+float(size_x-1)/size_x,1.0/size_y/2.0+float((i+1))/size_y);
    sh.vertex(0,0,i+1,1.0/size_x/2.0,1.0/size_y/2.0+float((i+1))/size_y);
    sh.vertex(0,0,i+1,1.0/size_x/2.0,1.0/size_y/2.0+float((i+1))/size_y); 
  }
  sh.endShape();
  return sh;
}

PShape createUI() {
  PShape ui = createShape();
  ui.beginShape(QUAD);
  ui.noStroke();
  ui.fill(255);
  ui.vertex(-40, -25);
  ui.vertex(-40, -30);
  ui.vertex(-20, -30);
  ui.vertex(-20, -25);
  ui.endShape();
  return ui;
}
