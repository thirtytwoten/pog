Table table;
int initMillis = 0;
float x,y,z,pulse;
float scale = 1.0;

float xAvg, yAvg, zAvg;
float eyeX, eyeY, eyeZ, centerX, centerY, centerZ; //camera vars

PShape sun;
PImage suntex;

void setup() {
 table = loadTable("data/pog.csv", "header");
 
 size(1024, 768, P3D);
 frameRate(30);
 noStroke();
 fill(255);
 
 pointLight(255,  255,  255,  0,  0,  0); 
 sphereDetail(40);
 suntex = loadImage("sun.jpg");
 sun = createShape(SPHERE, 1);
 sun.setTexture(suntex);
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
  
  camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, -xAvg, -yAvg, -zAvg);

  pushMatrix();
  translate(width/2, height/2, -300);
  //rotateY(PI * frameCount / 300);
  sun.scale(scale);
  translateSun(millis()/1000.0);
  shape(sun);
  popMatrix();
}

void translateSun(float t) {
 float t2 = t * t;
 float xpos = x * t2;
 float ypos = y * t2;
 float zpos = z * t2;
 
 //println(xpos + ", " + ypos + ", " + zpos);
 // float pos = sqrt(xpos * xpos + ypos * ypos + zpos * zpos);
 // println(pos);
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