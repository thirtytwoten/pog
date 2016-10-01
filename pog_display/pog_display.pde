Table table;
int initMillis = 0;
float x,y,z,pulse;

void setup() {
 size(400,400,P3D);
 frameRate(30);
 table = loadTable("data/pog.csv", "header");
 println(table.getRowCount() + " rows in table");
}

void draw() {
  if (initMillis == 0) {
    initMillis = millis();
  }
  int millis = millis() - initMillis;
  TableRow row = getRowAtTime(millis);
  x = row.getFloat("x");
  y = row.getFloat("y");
  z = row.getFloat("z");
  pulse = row.getFloat("pulse");
  println(row.getInt("id") + ": " + row.getInt("time") + ", " + x + ", " + y + ", " + z + ", " + pulse);
}

TableRow getRowAtTime(int millis) {
  TableRow row = null;
  while(row == null) {
    row = table.findRow(str(millis) + ".0", "time");
    millis++;
  }
  return row;
}