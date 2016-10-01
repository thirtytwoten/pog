import processing.serial.*;

Serial port;
Table table;

String fileName;

int writeRate = 500; // how many readings to take before writing to file 
int readCount = 0; // counts the number of readings between writes

float x, y, z, pulse;

void setup() {
 size(400, 400, P3D); 
 
 fileName = str(year()) + str(month()) + str(day()) + str(hour()) + str(minute()); // create unique filename for each run
 table = new Table();
 table.addColumn("id");
 table.addColumn("time");
 table.addColumn("x");
 table.addColumn("y");
 table.addColumn("z");
 table.addColumn("pulse");
 
 port = new Serial(this, Serial.list()[1], 115200);
}

void draw() {

}

void serialEvent(Serial port) {
  String val = port.readStringUntil('\n');
  if (val != null) {
    val = trim(val);
    println(val);
    float sensorVals[] = float(split(val, ","));
    
    x = sensorVals[1];
    y = sensorVals[2];
    z = sensorVals[3];
    pulse = sensorVals[4];
    
    TableRow newRow = table.addRow();
    newRow.setInt("id", table.lastRowIndex());
    newRow.setFloat("time", sensorVals[0]);
    newRow.setFloat("x", x);
    newRow.setFloat("y", y);
    newRow.setFloat("z", z);
    newRow.setFloat("pulse", pulse);
    
    readCount++;
    
    if (readCount % writeRate == 0) {
      saveTable(table, "data/" + fileName + ".csv");
    }
  }
}