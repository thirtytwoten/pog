int scale = 3;

void setup() {
  // init serial communication at 115200 baud
  Serial.begin(115200);
}

void loop() {
  int rawX = analogRead(A0);
  int rawY = analogRead(A1);
  int rawZ = analogRead(A2);
  
  int pulse = analogRead(A3);

  // scale accelerometer ADC readings into common units
  float scaledX = mapf(rawX, 0, 675, -scale, scale); // 3.3/5 * 1023 =~ 675
  float scaledY = mapf(rawY, 0, 675, -scale, scale);
  float scaledZ = mapf(rawZ, 0, 675, -scale, scale);

  Serial.print(scaledX);
  Serial.print(",");
  Serial.print(scaledY);
  Serial.print(",");
  Serial.print(scaledZ);
  Serial.print(",");
  Serial.println(pulse);

  delay(30); // "minimum delay of 2 ms between sensor reads (500 Hz)" //// 4ms? niquist freq?
}

// mapf, same functionality as Arduino's standard map fn, but w/ floats
float mapf(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

