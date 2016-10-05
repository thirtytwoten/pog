Table table;
int initMillis = 0;
float x,y,z,pulse;
float scale = 1.0;

PShape sun;
PImage suntex;

void setup() {
 size(1024, 768, P3D);
 frameRate(30);
 noStroke();
 fill(255);
 
 pointLight(255,  255,  255,  0,  0,  0); 
 
 sphereDetail(40);
 suntex = loadImage("sun.jpg");
 sun = createShape(SPHERE, 1);
 sun.setTexture(suntex); 
 
 table = loadTable("data/pog.csv", "header");
}

void draw() {
  updateData();
 
  sun.scale(1/scale);
  scale = pulse/3;
  background(0);

  pushMatrix();
  translate(width/2, height/2, -300);
  rotateY(PI * frameCount / 300);
  translate(width/2, height/2, -300);
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
 println(xpos + ", " + ypos + ", " + zpos);
 // float pos = sqrt(xpos * xpos + ypos * ypos + zpos * zpos);
 // println(pos);
 sun.translate(xpos, ypos, zpos);
 
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

//void avergeAccel() {
// table. 
//}