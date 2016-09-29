import processing.serial.*;

Serial port;
Table table;

String fileName;

int writeRate = 500; // how many readings to take before writing to file 
int readCount = 0; // counts the number of readings between writes

void setup() {
 fileName = str(year()) + str(month()) + str(day()) + str(hour()) + str(minute());
 
 table = new Table();
 table.addColumn("id");
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
    
    TableRow newRow = table.addRow();
    newRow.setInt("id", table.lastRowIndex());
    newRow.setFloat("x", sensorVals[0]);
    newRow.setFloat("y", sensorVals[1]);
    newRow.setFloat("z", sensorVals[2]);
    newRow.setFloat("pulse", sensorVals[3]);
    
    readCount++;
    
    if (readCount % writeRate == 0) {
      saveTable(table, "data/" + fileName + ".csv");
    }
  }
}

//void findArduino() {
// // println(Serial.list()); // print available serial ports, chose [#] connected to arduino
// port = new Serial(this, Serial.list()[1], 115200); // arduino should be communicating at 115200 baud
// port.clear(); // flush buffer
// port.bufferUntil('\n'); // set buffer full flag on receipt of carriage return
//}