
#include <Wire.h>
#include "SparkFun_BMA400_Arduino_Library.h"
#include <math.h>
#include <Preferences.h>


//using two i2c bus
TwoWire I2CBus1 = TwoWire(0);
TwoWire I2CBus2 = TwoWire(1);


//defining all the pins
const int LED_Pin = 2;
const int RECALIBRATION_PIN = 25;
const int RECALIBRATION_HOLD_TIME = 5000;


//i2c enable for 1st sensor
const int SDA1_pin = 22;
const int SCL1_pin = 21;


//i2c enable for 2nd sensor
const int SDA2_pin = 33;
const int SCL2_pin = 32;


BMA400 accelerometer1;
BMA400 accelerometer2;
uint8_t i2cAddress = BMA400_I2C_ADDRESS_DEFAULT;


Preferences preferences;


float alpha = 0.05;
float filteredRoll1 = 0, filteredPitch1 = 0;
float filteredRoll2 = 0, filteredPitch2 = 0;


float offsetX1 = 0.0, offsetY1 = 0.0, offsetZ1 = 0.0;
float offsetX2 = 0.0, offsetY2 = 0.0, offsetZ2 = 0.0;


bool countingRECALIBRATION = false;
unsigned long RECALIBRATIONStart = 0;
bool calibration_done = false;


void setup() {
  Serial.begin(115200);
  delay(1000);
  


  I2CBus1.begin(SDA1_pin, SCL1_pin);
  I2CBus2.begin(SDA2_pin, SCL2_pin);


  if (accelerometer1.beginI2C(i2cAddress, I2CBus1) != BMA400_OK)
    Serial.println("Error: BMA400 #1 not connected!");
  else
    Serial.println("BMA400 #1 connected.");


  if (accelerometer2.beginI2C(i2cAddress, I2CBus2) != BMA400_OK)
    Serial.println("Error: BMA400 #2 not connected!");
  else
    Serial.println("BMA400 #2 connected.");


  pinMode(LED_Pin, OUTPUT);
  pinMode(RECALIBRATION_PIN, INPUT_PULLDOWN);  ( PULLUP)


//checking for preferences
  preferences.begin("tilt", true);
  bool savedOffset = preferences.getBool("calibrated", false);
  preferences.end();


  if (!savedOffset) {
    Serial.println("No saved calibration. Calibrating...");
    calibrateSensors();
  } else {
    preferences.begin("tilt", false);
    offsetX1 = preferences.getFloat("refX1", 0.0);
    offsetY1 = preferences.getFloat("refY1", 0.0);
    offsetZ1 = preferences.getFloat("refZ1", 0.0);
    offsetX2 = preferences.getFloat("refX2", 0.0);
    offsetY2 = preferences.getFloat("refY2", 0.0);
    offsetZ2 = preferences.getFloat("refZ2", 0.0);
    preferences.end();
    Serial.println("Calibration loaded.");
  }
 delay(5000);
}


void loop() {
  monitorRECALIBRATIONButton();


  accelerometer1.getSensorData();
  accelerometer2.getSensorData();


  float x1 = accelerometer1.data.accelX - offsetX1;
  float y1 = accelerometer1.data.accelY - offsetY1;
  float z1 = accelerometer1.data.accelZ - offsetZ1;


  float x2 = accelerometer2.data.accelX - offsetX2;
  float y2 = accelerometer2.data.accelY - offsetY2;
  float z2 = accelerometer2.data.accelZ - offsetZ2;


//due orientation the roll and pitch for both is different
  float roll1 = atan2(y1, sqrt(x1 * x1 + z1 * z1)) * 180.0 / M_PI;
  float pitch1 = atan2(-x1, sqrt(y1 * y1 + z1 * z1)) * 180.0 / M_PI;


  float pitch2 = atan2(y2, sqrt(x2 * x2 + z2 * z2)) * 180.0 / M_PI; // roll → pitch2
  float roll2 = atan2(-x2, sqrt(y2 * y2 + z2 * z2)) * 180.0 / M_PI; // pitch → roll2


  filteredRoll1 = alpha * roll1 + (1 - alpha) * filteredRoll1;
  filteredPitch1 = alpha * pitch1 + (1 - alpha) * filteredPitch1;
  filteredRoll2 = alpha * roll2 + (1 - alpha) * filteredRoll2;
  filteredPitch2 = alpha * pitch2 + (1 - alpha) * filteredPitch2;


  // Lamp logic
  if (abs(filteredRoll1) > 5 || abs(filteredPitch1) > 5 || abs(filteredRoll2) > 5 || abs(filteredPitch2) > 5 ) {
    digitalWrite(Lamp_Pin, HIGH);}
  else {
    digitalWrite(Lamp_Pin, LOW);
  }
Serial.println("Roll and Pitch from both sensors:");


  // printing sensor  1 value
  Serial.print("Sensor 1 -> Roll: ");
  Serial.print(filteredRoll1, 2);
  Serial.print("°, Pitch: ");
  Serial.print(filteredPitch1, 2);
  Serial.println("°");


//printing sensor 2 value
  Serial.print("Sensor 2 -> Roll: ");
  Serial.print(filteredRoll2, 2);
  Serial.print("°, Pitch: ");
  Serial.print(filteredPitch2, 2);
  Serial.println("°");


  Serial.println("------------------------");
  delay(20);
}


//button logic
void monitorRECALIBRATIONButton() {
  if (digitalRead(RECALIBRATION_PIN) == HIGH) {
    if (!countingRECALIBRATION) {
      countingRECALIBRATION = true;
      RECALIBRATIONStart = millis();
    } else if ((millis() - RECALIBRATIONStart >= RECALIBRATION_HOLD_TIME) && !calibration_done) {
      calibrateSensors();
      calibration_done = true;
    }
  } else {
    countingRECALIBRATION = false;
    calibration_done = false;
  }
}
//calibration function
void calibrateSensors() {
  Serial.println("Calibrating both sensors... Keep device still.");


  float sumX1 = 0, sumY1 = 0, sumZ1 = 0;
  float sumX2 = 0, sumY2 = 0, sumZ2 = 0;
  int samples = 100;


  for (int i = 0; i < samples; i++) {
    accelerometer1.getSensorData();
    accelerometer2.getSensorData();


    sumX1 += accelerometer1.data.accelX;
    sumY1 += accelerometer1.data.accelY;
    sumZ1 += accelerometer1.data.accelZ;


    sumX2 += accelerometer2.data.accelX;
    sumY2 += accelerometer2.data.accelY;
    sumZ2 += accelerometer2.data.accelZ;


    delay(10);
  }


  offsetX1 = sumX1 / samples;
  offsetY1 = sumY1 / samples;
  offsetZ1 = (sumZ1 / samples) - 1.0;


  offsetX2 = sumX2 / samples;
  offsetY2 = sumY2 / samples;
  offsetZ2 = (sumZ2 / samples) - 1.0;


  preferences.begin("tilt", false);
  preferences.putFloat("refX1", offsetX1);
  preferences.putFloat("refY1", offsetY1);
  preferences.putFloat("refZ1", offsetZ1);
  preferences.putFloat("refX2", offsetX2);
  preferences.putFloat("refY2", offsetY2);
  preferences.putFloat("refZ2", offsetZ2);
  preferences.putBool("calibrated", true);
  preferences.end();


  Serial.println("Calibration complete and saved.");
}

