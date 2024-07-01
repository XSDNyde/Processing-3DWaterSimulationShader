PImage label, rock, checker, wet, waterHeight, delta;
float[] f_delta, f_water;
PShape can, terrain, water;
float angle;
PVector[] pv_vel, pv_vel_delta, pv_acc;
PImage m_output;
String m_savePath;
float sum_water;
boolean[] m_border;

final float g_VEL_DAMPING_FACTOR = 1.0;
final float g_VEL_REFLECTION_FACTOR = 1.0/2.0;
final float g_TIME_FACTOR = 1.0/2.0;
final int g_NUM_ITERATIONS = 1;

CameraManager m_cam = new CameraManager();
PGraphics3D m_g3d;
PMatrix3D m_inv;

PFont m_font;
PShape ui;

float mouse_translate_x, mouse_translate_y, mouse_angle_x, mouse_angle_y, mouse_zoom;

PShader landShader, waterShader;

PMatrix pmat;

int pcount, fcount, ocount;

boolean skipPassA = false, skipPassB = false, runOnce = true;
int passAOnlyEvery = 1, passBOnlyEvery = 1; // run pass only every 1,2,3... frame

void setup() {
  size(800, 600, P3D);
  frameRate(60);
  
  m_g3d = (PGraphics3D)(this.g);
  m_font = createFont( "Arial", 32, false );
  textFont( m_font );
  
  // create a UI overlay
  ui = createUI();
  
  rock = loadImage("rock.jpg");
  checker = loadImage("checker13_512x64.png");
  wet = loadImage("wet.jpg");
  waterHeight = loadImage("waterHeight9_512x64.png");
  f_delta = new float[waterHeight.width*waterHeight.height];
  f_water = new float[waterHeight.width*waterHeight.height];
  //can = createCan(100, 200, 32, label);
  terrain = createTerrain(512, 64, rock);
  water = createTerrain(512, 64, wet);
  landShader = loadShader("landfrag.glsl", "landvert.glsl");
  landShader.set("heightMap", checker);
  waterShader = loadShader("waterfrag.glsl", "watervert.glsl");
  waterShader.set("heightMap", checker);
  waterShader.set("waterHeightMap", waterHeight);
  
  pcount = 0;
  fcount = 0;
  ocount = 0;
  
  m_output = new PImage(waterHeight.width, waterHeight.height, ARGB);

  pv_vel = new PVector[waterHeight.width*waterHeight.height];
  pv_vel_delta = new PVector[waterHeight.width*waterHeight.height];
  pv_acc = new PVector[waterHeight.width*waterHeight.height];
  
  m_border = new boolean[waterHeight.width*waterHeight.height];
  
  checker.loadPixels();
  waterHeight.loadPixels();
  for(int i = 0; i < waterHeight.width*waterHeight.height; ++i) {
    f_water[i] = max(red(waterHeight.pixels[i]), red(checker.pixels[i]));
    //print(" ");print(int(f_water[i]));print("x");print(int(red(checker.pixels[i])));
    //if(i%waterHeight.width == waterHeight.width-1) println();
    pv_vel[i] = new PVector(0.0, 0.0);
    pv_vel_delta[i] = new PVector(0.0, 0.0);
    pv_acc[i] = new PVector(0.0, 0.0); 
  } 
}

void draw() {    
  background(0);
  ++pcount;
  ++fcount;
  
  
  shader(landShader); 
  shape(terrain);
  waterShader.set("heightMap", checker);
  waterShader.set("waterHeightMap", waterHeight);
  shader(waterShader); 
  shape(water);
  
  //for(int i = 0; i < 20; ++i) f_water[waterHeight.width*waterHeight.height/2+i] += 100.0;
  if(pcount >= 1) {  
  pcount = 0;
  for(int it = 0; it < g_NUM_ITERATIONS; ++it) {
  // Resets for both passes
  for(int i = 0; i < waterHeight.width*waterHeight.height; ++i) {
    f_delta[i] = 0.0;
    pv_acc[i].x = 0.0;
    pv_acc[i].y = 0.0;
    pv_vel_delta[i].x = 0.0;
    pv_vel_delta[i].y = 0.0;
  }
  checker.loadPixels();
  // PASS A: Velocity based movement
  if(!skipPassA && (fcount % passAOnlyEvery == 0)) {
  for(int i = 1; i < waterHeight.height-1; ++i) {
    for(int j = 1; j < waterHeight.width-1; ++j) {
      // read from pv_vel, move and store in pv_vel_delta
      float water_in_vertex = max(f_water[i*waterHeight.width+j] - red(checker.pixels[i*checker.width+j]), 0.0);;
      float vel_x = pv_vel[i*waterHeight.width+j].x;
      float vel_y = pv_vel[i*waterHeight.width+j].y;
      if(abs(vel_x) + abs(vel_y) > water_in_vertex) {
        // not enough water to move
        float factor = water_in_vertex / (abs(vel_x) + abs(vel_y));
        vel_x *= factor;
        vel_y *= factor;
      }
      //println("Water available: "+water_in_vertex+" | X Vel: "+vel_x+" | Y Vel: "+vel_y);
      if(vel_y < 0) {
        // move north
        vel_y = min(abs(vel_y), max(f_water[i*waterHeight.width+j] - red(checker.pixels[(i-1)*checker.width+j]), 0.0));
        f_delta[(i-1)*checker.width+j] += vel_y;
        pv_vel_delta[(i-1)*checker.width+j].y -= vel_y;
        //pv_vel_delta[i*checker.width+j].x += vel_x_reflected;
        //print(" Moved North: "+vel_x);
      }
      else {
        // move south
        vel_y = min(abs(vel_y), max(f_water[i*waterHeight.width+j] - red(checker.pixels[(i+1)*checker.width+j]), 0.0));
        f_delta[(i+1)*checker.width+j] += vel_y;
        pv_vel_delta[(i+1)*checker.width+j].y += vel_y;
        //pv_vel_delta[i*checker.width+j].x -= vel_x;
        //print(" Moved South: "+vel_x);
      }
      if(vel_x < 0) {
        // move west
        vel_x = min(abs(vel_x), max(f_water[i*waterHeight.width+j] - red(checker.pixels[i*checker.width+j-1]), 0.0));
        f_delta[i*checker.width+j-1] += vel_x;
        pv_vel_delta[i*checker.width+j-1].x -= vel_x;
        //pv_vel_delta[i*checker.width+j].y += vel_y;
        //print(" Moved West: "+vel_y);
      }
      else {
        // move east
        vel_x = min(abs(vel_x), max(f_water[i*waterHeight.width+j] - red(checker.pixels[i*checker.width+j+1]), 0.0));
        f_delta[i*checker.width+j+1] += vel_x;
        pv_vel_delta[i*checker.width+j+1].x += vel_x;
        //pv_vel_delta[i*checker.width+j].y -= vel_y;
        //print(" Moved East: "+vel_y);
      }
      if(vel_x < 0 || vel_y < 0) { println("NEGATIVE AMOUNT!!!"); while(true) {;} }
      // remove water from center
      f_delta[i*checker.width+j] -= (vel_x + vel_y);
      //println(" Water removed: "+(vel_x + vel_y));
    }
  }
  float sum_water_delta = 0.0;
  m_output.loadPixels();
  for(int i = 0; i < waterHeight.height*waterHeight.width; ++i) {
    pv_vel[i].x = pv_vel_delta[i].x;
    pv_vel[i].y = pv_vel_delta[i].y;
    m_output.pixels[i] = color(127, 127+int(pv_vel_delta[i].x), 127+int(pv_vel_delta[i].y), 255);
    f_water[i] = max(f_water[i], red(checker.pixels[i])) + f_delta[i];
    sum_water_delta += f_delta[i];
    //print(int(f_delta[i])+" ");
    //print(int(pv_vel[i].x) + "x" + int(pv_vel[i].y));print(" ");
    //if(i%waterHeight.width == waterHeight.width-1) println();
    f_delta[i] = 0.0;
  }
  m_output.updatePixels();
  m_savePath = savePath("vel_delta_out"+nf(ocount, 4)+".png");
  //if(fcount % 1 == 0) { ++ocount; m_output.save(m_savePath); }
  //println("Sum of water in Delta: "+sum_water_delta);
  // PASS B: Gravity caused Advection and Acceleration
  }
  if(!skipPassB && (fcount % passBOnlyEvery == 0)) {
    runOnce = false;
  float center, north, east, south, west;
  for(int i = 1; i < waterHeight.height-1; ++i) {
    for(int j = 1; j < waterHeight.width-1; ++j) {
      if(f_water[i*waterHeight.width+j] > red(checker.pixels[i*checker.width+j])) {
        //calculate creep effects
        center = f_water[i*waterHeight.width+j];
        north = red(checker.pixels[(i-1)*checker.width+j]);
        east =  red(checker.pixels[i*checker.width+j+1]);
        south = red(checker.pixels[(i+1)*checker.width+j]);
        west =  red(checker.pixels[i*checker.width+j-1]);
        
        float[] values = {center, north, east, south, west};
        easierStep(red(checker.pixels[i*checker.width+j]), values, f_delta, j, i);
        
      }
      //waterHeight.pixels[i*waterHeight.width+j] = color(red(waterHeight.pixels[i*waterHeight.width+j])-1, 0, 0);
      //print(i);print("x");print(j);print(" Index: ");println(i*waterHeight.width+j);
    }
  }
  }
  float sum = 0;
  sum_water = 0;
  int offset;
  waterHeight.loadPixels();
  m_output.loadPixels();
  checker.loadPixels();
  for(int i = 0; i < waterHeight.height*waterHeight.width; ++i) {
    f_water[i] = max(f_water[i], red(checker.pixels[i])) + f_delta[i];
  }
  if(false) for(int i = 1; i < waterHeight.height-1; ++i) {
    for(int j = 1; j < waterHeight.width-1; ++j) {
      // does not contain water
      //println("Water: "+int(f_water[i*waterHeight.width+j])+" | Ground: "+red(checker.pixels[i*waterHeight.width+j]));
    if(floor(f_water[i*waterHeight.width+j]) <= red(checker.pixels[i*waterHeight.width+j])) {
      // check if neighbor pixels contain water
      float average_height_neigh = 0.0;
      float num_contain_water = 0.0;
      if(f_water[(i-1)*checker.width+j] > red(checker.pixels[(i-1)*checker.width+j])) {
        average_height_neigh += f_water[(i-1)*checker.width+j];
        ++num_contain_water;
      }
      if(f_water[i*checker.width+j+1] > red(checker.pixels[i*checker.width+j+1])) {
        average_height_neigh += f_water[i*checker.width+j+1];
        ++num_contain_water;
      }
      if(f_water[(i+1)*checker.width+j] > red(checker.pixels[(i+1)*checker.width+j])) {
        average_height_neigh += f_water[(i+1)*checker.width+j];
        ++num_contain_water;
      }
      if(f_water[i*checker.width+j-1] > red(checker.pixels[i*checker.width+j-1])) {
        average_height_neigh += f_water[i*checker.width+j-1];
        ++num_contain_water;
      }
      f_water[i*waterHeight.width+j] = min(red(checker.pixels[i*waterHeight.width+j]), average_height_neigh/num_contain_water);
      //println("AverageLevel: "+average_height_neigh/num_contain_water);
    }
    }
  }
  for(int i = 0; i < waterHeight.height*waterHeight.width; ++i) {
    //print(red(delta.pixels[i]));print(" ");print(red(waterHeight.pixels[i]));
    //if(f_delta[i] >= 0) offset = ceil(f_delta[i]);
    //else offset = floor(f_delta[i]);
    //f_water[i] += f_delta[i];
    //print((f_delta[i]>0)?"+":(f_delta[i]==0?"0":"-"));
    //print(int(pv_acc[i].x) + "x" + int(pv_acc[i].y));print(" ");
    //print(int(f_delta[i])+" ");
    //if(i%waterHeight.width == waterHeight.width-1) println();
      

    sum += f_delta[i];
    sum_water += f_water[i];
    waterHeight.pixels[i] = color(f_water[i],0.0,0.0);
    
    pv_vel[i].mult(g_VEL_DAMPING_FACTOR);
    pv_vel[i].add(pv_acc[i]);
    m_output.pixels[i] = color(127, 127+int(pv_vel[i].x), 127+int(pv_vel[i].y), 255);
  }
  //print("Sum of all deltas = ");println(sum);
  //print("Sum of all water = ");println(sum_water);
  
  waterHeight.updatePixels();
  m_output.updatePixels();
  //checker.updatePixels();
  }
  }
  
  m_cam.setCamera();
  
  // back to default shader for ui and text
  resetShader();
  // take us to camera space, draw directly after near plane
  m_inv = m_g3d.cameraInv;
  pushMatrix();
  applyMatrix(m_inv);
  translate(0,0,-m_g3d.cameraNear-1);
  shape(ui);
  stroke(255,0,0);
  fill(255);
  textAlign( LEFT );
  scale(0.05);
  text( m_g3d.OPENGL_VERSION, -width, height);
  fill(0);
  textAlign( LEFT, TOP );
  text( "FPS: "+int(frameRate), -width+2, -height+2);
  text( "Water Cnt: "+int(sum_water), -width+2, -height+32);
  text( "Vertices: "+waterHeight.width*waterHeight.height, -width+2, -height+62);
  popMatrix();
  
  
  //saveFrame("vid#######.png");
  m_savePath = savePath("acc_out"+nf(ocount, 4)+".png");
  //if(fcount % 1 == 0) { ++ocount; m_output.save(m_savePath); }
}



/* ************************
   **** HELPER METHODS ****
   ************************ */

void easierStep(float height_at, float[] values, float[] delta_tex, int pix_pos_x, int pix_pos_y) {
  float diff_abs = max(0.0, values[0]-height_at);
  float actually_distributed = 0.0;
  float diff1, diff2, diff3, diff4;
  diff1 = constrain(values[0] - values[1], 0.0, diff_abs);
  diff2 = constrain(values[0] - values[2], 0.0, diff_abs);
  diff3 = constrain(values[0] - values[3], 0.0, diff_abs);
  diff4 = constrain(values[0] - values[4], 0.0, diff_abs);
  float factor = 1.0 / 5.0 * g_TIME_FACTOR;
  // NORTH
  f_delta[(pix_pos_y-1)*waterHeight.width+pix_pos_x] += diff1*factor;
  pv_acc[(pix_pos_y-1)*waterHeight.width+pix_pos_x].y += -diff1*factor;
  // EAST
  f_delta[pix_pos_y*waterHeight.width+pix_pos_x+1] += diff2*factor;
  pv_acc[pix_pos_y*waterHeight.width+pix_pos_x+1].x += diff2*factor;
  // SOUTH
  f_delta[(pix_pos_y+1)*waterHeight.width+pix_pos_x] += diff3*factor;
  pv_acc[(pix_pos_y+1)*waterHeight.width+pix_pos_x].y += diff3*factor;
  // WEST
  f_delta[pix_pos_y*waterHeight.width+pix_pos_x-1] += diff4*factor;
  pv_acc[pix_pos_y*waterHeight.width+pix_pos_x-1].x += -diff4*factor;
  // CENTER
  f_delta[pix_pos_y*waterHeight.width+pix_pos_x] -= (diff1+diff2+diff3+diff4)*factor;
  
  if(false) {
    print("Diff_abs = ");print(diff_abs);print(" | Other diffs: ");print(diff1);print(" ");print(diff2);print(" ");print(diff3);print(" ");print(diff4);println();
    print("Values ");print(values[0]);print(" ");print(height_at);println();
  }
}

