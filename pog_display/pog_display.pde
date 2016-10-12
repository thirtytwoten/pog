int tx, ty, radius, l;
PGraphics tunnelEffect;
PImage textureImg;
 
// build lookup table
int[][] distanceTable;
int[][] angleTable;
int[][] shadeTable;
int w, h;
PFont f;

//

Table table;
int initMillis = 0;
float x,y,z, dt, pos, pulse;
float scale = 1.0;

float xAvg, yAvg, zAvg;
float eyeX, eyeY, eyeZ, centerX, centerY, centerZ; //camera vars

PShape sun;
PImage suntex;

void setup() {
 tunnelSetup();
 table = loadTable("data/pog.csv", "header");
 
 size(1024, 768, P3D);
 frameRate(30);
 noStroke();
 colorMode(HSB, 360);
 
 pointLight(255,  255,  255,  0,  0,  0); 
 sphereDetail(40);
 suntex = loadImage("sun.jpg");
 sun = createShape(SPHERE, 1);
 //sun.setTexture(suntex);
 calcAvgAccel();
 
 //camera defaults
 eyeX = width/2.0;
 eyeY = height/2.0;
 eyeZ = (height/2.0) / tan(PI*30.0 / 180.0);
 centerX = width/2.0;
 centerY = height/2.0;
 centerZ = -1200;
 
 translate(width/2, height/2, -300);
 
}

void draw() {
  updateData();
 
  sun.scale(1/scale);
  scale = pulse/2.5;
  background(0);
  lights();
  
  camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, -xAvg, -yAvg, -zAvg);

  pushMatrix();
  translate(width/2, height/2, -300);
  //rotateY(PI * frameCount / 300);
  sun.setFill(color(0, pulse, pulse));
  sun.scale(scale);
  translateSun();
  tunnelDraw();
  shape(sun);
  popMatrix();
  
  
  //sphere(100);
}

void translateSun() {
 int scale = 1000;
 float t2 = dt * dt * scale;
 float xpos = x * t2;
 float ypos = y * t2;
 float zpos = z * t2;
 
 //println(xpos + ", " + ypos + ", " + zpos);
 pos += sqrt(xpos * xpos + ypos * ypos + zpos * zpos);
 println(pos);
 sun.translate(xpos, ypos, zpos);
 eyeX += xpos;
 eyeY += ypos;
 eyeZ += zpos;
  
 centerX += xAvg * t2;
 centerY += yAvg * t2;
 centerZ += zAvg * t2;
  
 print(eyeX + ", ");
 print(eyeY + ", ");
 print(eyeZ + ", ");
 print(centerX + ", ");
 print(centerY + ", ");
 println(centerZ);
 
 //ellipse(200, 200, pulse / 4, pulse / 4);
}

void updateData() {
 if (initMillis == 0) {
    initMillis = millis();
  }
  int millis = millis() - initMillis;
  TableRow row = getRowAtTime(millis);
  float t1 = table.getRow(max(row.getInt("id") - 1, 0)).getFloat("time");
  float t2 = row.getFloat("time");
  dt = (t2 - t1) / 1000;
  println(dt);
  x = row.getFloat("x");
  y = row.getFloat("y");
  z = row.getFloat("z");
  pulse = row.getFloat("pulse");
  //println(row.getInt("id") + ": " + row.getInt("time") + ", " + x + ", " + y + ", " + z + ", " + pulse); 
}

TableRow getRowAtTime(int millis) {
  TableRow row = null;
  while(row == null) {
    row = table.findRow(str(millis) + ".0", "time");
    millis++;
  }
  return row;
}

void calcAvgAccel() {
 for (TableRow row : table.rows()) {
   xAvg += row.getFloat("x");
   yAvg += row.getFloat("y");
   zAvg += row.getFloat("z");
 }
 int n = table.getRowCount();
 float t = table.getRow(n-1).getFloat(1) / 1000.0;
 xAvg = xAvg / n;
 yAvg = yAvg / n;
 zAvg = zAvg / n;
 println("averages: " + xAvg + ", " + yAvg + ", " + zAvg);
}

void tunnelSetup() {
   
  // Load texture 351 x 216
  textureImg = loadImage("sun.jpg");
  textureImg.loadPixels();
   
   
  // Create buffer screen
  tunnelEffect = createGraphics(320, 200, P3D);
  w = tunnelEffect.width;
  h = tunnelEffect.height;
 
  float ratio = 32.0;
  int angle;
  int depth;
  int shade = 0;
 
  // Make the tables twice as big as the screen.
  // The center of the buffers is now the position (w,h).
  distanceTable= new int[2 * w][2 * h];
  angleTable= new int[2 * w][2 * h];
 
  for (int tx = 0; tx < w*2; tx++)
  {
    for (int ty = 0; ty < h*2; ty++)
    {
      depth = int(ratio * textureImg.height
                  / sqrt(float((tx - w) * (tx - w) + (ty - h) * (ty - h)))) ;
      angle = int(0.5 * textureImg.width * atan2(float(ty - h),
                  float(tx - w)) / PI) ;
 
      // The distance table contains for every pixel of the
      // screen, the inverse of the distance to the center of
      // the screen this pixel has.
      distanceTable[tx][ty] = depth ;
 
      // The angle table contains the angle of every pixel of the screen,
      // where the center of the screen represents the origin.
      angleTable[tx][ty] = angle ;
    }
  }   
}

void tunnelDraw() {
 tunnelEffect.beginDraw();
  tunnelEffect.loadPixels();
 
 
  //float timeDisplacement = millis() / 1000.0;
  float timeDisplacement = pos / 4;
 
  // Calculate the shift values out of the time value
  int shiftX = int(textureImg.width * .2 * timeDisplacement+300); // speed of zoom
  int shiftY = int(textureImg.height * .15 * timeDisplacement+300); //speed of spin
 
  // Calculate the look values out of the time value
  // by using sine functions, it'll alternate between
  // looking left/right and up/down
  int shiftLookX = w / 2 + int(w / 4 * sin(timeDisplacement));
  int shiftLookY = h / 2 + int(h / 4 * sin(timeDisplacement * 1.5));
 
  for (int ty = 0; ty < h; ty++)  {
   for (int tx = 0; tx < w; tx++)      {
       
     // Make sure that x + shiftLookX never goes outside
     // the dimensions of the table
     int texture_x = constrain((distanceTable[tx + shiftLookX][ty + shiftLookY]
                                + shiftX) % textureImg.width ,0, textureImg.width);
       
     int texture_y = (angleTable[tx + shiftLookX][ty + shiftLookY]
                      + shiftY) % textureImg.height;
       
     tunnelEffect.pixels[tx+ty*w] = textureImg.pixels[texture_y
                        * textureImg.width + texture_x];
 
     // Test lookuptables
     // tunnelEffect.pixels[tx+ty*w] = color( 0,texture_x,texture_y);
   }
  }
 
  tunnelEffect.updatePixels();
  tunnelEffect.endDraw();
 
  // Display the results
  image(tunnelEffect, 0, 0, width, height); 
}