Table table;
int initMillis = 0;
float x,y,z, dt, pos, pulse;
float scale = 1.0;

float xAvg, yAvg, zAvg;
float eyeX, eyeY, eyeZ, centerX, centerY, centerZ; //camera vars

PShape sun;
PImage suntex;

PShape[] stars;
PVector[] starPositions;
int trailPosition = 0;
PVector lastSpot;

void setup() {
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
 centerZ = -300;
 
 translate(width/2, height/2, -300);
 
 stars = new PShape[100];
 starPositions = new PVector[stars.length];
 
 //lastSpot = new PVector(width/2,height/2,-300);
 lastSpot = new PVector(0,0,0);
 
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
  sun.setFill(color(millis()/1000 % 360, (pulse - 280) * 5, 360));
  sun.scale(scale);
  translateSun();
  drawTrail();
  shape(sun);
  popMatrix();
}

void drawTrail() {
  for(int i = 0; i < stars.length; i++) {
    if (starPositions[i] != null) {
         stars[i] = createShape(SPHERE, 4);
         stars[i].translate(starPositions[i].x, starPositions[i].y, starPositions[i].z);
         println(i + ": " + starPositions[i]);
         shape(stars[i]);
    }
  }
}

void translateSun() {
 int scale = 1000;
 float t2 = dt * dt * scale;
 float xpos = x * t2;
 float ypos = y * t2;
 float zpos = z * t2;
 
 //println(xpos + ", " + ypos + ", " + zpos);
 //pos += sqrt(xpos * xpos + ypos * ypos + zpos * zpos);
 //println(pos);
 sun.translate(xpos, ypos, zpos);
 lastSpot = new PVector(
                         lastSpot.x + xpos,
                         lastSpot.y + ypos,
                         lastSpot.z + zpos
                        );
 starPositions[trailPosition] = lastSpot;
 trailPosition = (trailPosition + 1) % stars.length;                              
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
 xAvg = xAvg / n;
 yAvg = yAvg / n;
 zAvg = zAvg / n;
 println("averages: " + xAvg + ", " + yAvg + ", " + zAvg);
}