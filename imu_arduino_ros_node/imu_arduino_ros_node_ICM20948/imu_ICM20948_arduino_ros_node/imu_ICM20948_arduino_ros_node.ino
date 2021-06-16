/*
 * Pubslisht IMU Daten im ROS
 * OJ 16-6-2021 "
 */
 //---------------------------------------------------------------
// WHS OJ we use Arduino Nano with ATmega328P (Old Bootloader)  
// => to small RAM, 
// Arduino Uno Wifi => to small RAM, 
//Globale Variablen verwenden 2225 Bytes (108%) des dynamischen Speichers, -177 Bytes für lokale Variablen verbleiben. Das Maximum sind 2048 Bytes.
//Nicht genug Arbeitsspeicher; unter http://www.arduino.cc/en/Guide/Troubleshooting#size finden sich Hinweise, um die Größe zu verringern.
//Fehler beim Kompilieren für das Board Arduino Uno WiFi.

// Arduino Mega2560 RAM OK (32%)


// Stemma QT-Kabel 
// rot      +3V3
// schwarz  GND
// gelb     SCL Arduino Nano A5
// blau     SDA Arduino Nano A4
//
// OJ 16.2.21
// $ roscore
// rosrun rosserial_python serial_node.py /dev/ttyUSB0
//----------------------------------------------------------------
#include <Wire.h>
#include "Eul2Quat.h"

#include <Adafruit_ICM20X.h>
#include <Adafruit_ICM20948.h>
#include <Adafruit_Sensor.h>
Adafruit_ICM20948 icm;

#include <ros.h>
#include <sensor_msgs/Imu.h>
ros::NodeHandle  nh;
sensor_msgs::Imu imu_msg;
ros::Publisher imu_pub("imu_report_topic", &imu_msg);

void setup()
{
  //initiate Sensor I2C
  icm.begin_I2C(); 
  //---- ggf. konfigurieren ----
  // icm.setAccelRange(ICM20948_ACCEL_RANGE_16_G);
  // icm.setGyroRange(ICM20948_GYRO_RANGE_2000_DPS);
  //  icm.setAccelRateDivisor(4095);
  //  icm.setGyroRateDivisor(255);
  // icm.setMagDataRate(AK09916_MAG_DATARATE_10_HZ);
  imu_msg.header.frame_id = 0;
  imu_msg.orientation.x = 0.0;
  imu_msg.orientation.y = 0.0;
  imu_msg.orientation.z = 0.0;
  imu_msg.orientation.w = 0.0;
 

  //Initiate ROS Node
  nh.initNode();
  nh.advertise(imu_pub);
}

void loop()
{
 // Eingabe
 /* Get a new normalized sensor event */
  sensors_event_t accel;
  sensors_event_t gyro;
  sensors_event_t mag;
  sensors_event_t temp;
  
  icm.getEvent(&accel, &gyro, &temp, &mag);


//--- Verabeitung => https://learn.adafruit.com/adafruit-tdk-invensense-icm-20948-9-dof-imu/arduino
// https://www.adafruit.com/product/4554
// der ICM20948 liefert:
// • 3-Axis Gyroscope with Programmable FSR of ±250 dps, ±500 dps, ±1000 dps, and ±2000 dps
// • 3-Axis Accelerometer with Programmable FSR of ±2g, ±4g, ±8g, and ±16g
// • 3-Axis Compass with a wide range to ±4900 µT

// Beschreibung einer IMU https://wiki.ardumower.de/index.php?title=Inertialsensor_-_IMU
//
// diese Daten müssen korrekt in die Nachricht eingetragen werden
// http://docs.ros.org/en/melodic/api/sensor_msgs/html/msg/Imu.html
// Accelerations should be in m/s^2 (not in g's), and rotational velocity should be in rad/sec
// If you have no estimate for one of the data elements (e.g. your IMU doesn't produce an orientation 
// estimate), please set element 0 of the associated covariance matrix to -1
// If you are interpreting this message, please check for a value of -1 in the first element of each 
// covariance matrix, and disregard the associated estimate.

 imu_msg.header.stamp = nh.now();
//Orientation (Quaternion erforderlich, Euler vom Sensor)

Quaternion myOrientQuat = Eul2Quat(mag.magnetic.x, mag.magnetic.y, mag.magnetic.z ); 

  imu_msg.orientation.x =  myOrientQuat.x;
  imu_msg.orientation.y =  myOrientQuat.y;
  imu_msg.orientation.z =  myOrientQuat.z;
  imu_msg.orientation.w =  myOrientQuat.w;

  for (int i=0; i<9; i++) {
    float orient_cov_matrix[9] = {0.01, 0.0, 0.0,  0.0, 0.0, 0.0,  0.0, 0.0, 0.0};
    imu_msg.orientation_covariance[i] = orient_cov_matrix[i];
  }

// angular_velocity kommt vom Gyroscope
// vgl .https://www.programcreek.com/python/example/99836/sensor_msgs.msg.Imu Example 8
// Gyro Range 2000deg/s, OK rad/sec ist korrekt
  imu_msg.angular_velocity.x = gyro.gyro.x;   
  imu_msg.angular_velocity.y = gyro.gyro.y;     
  imu_msg.angular_velocity.z = gyro.gyro.z;   


 // The covariance matrix describes the "uncertainty" in different directions.
 // Where a bigger value in the matrix indicates that you are more "uncertain" about your pose. 
 // Suppose the following 1D example. We have a robot that when we tell it, it has to move 1 meter, it can move either 95 cm or 105 cm.
 // After 1 meter the covariance is 5 cm, because the robot could be at any point between 95cm and 105cm. 
 // x,y,z, x', y', z',  x'', y'', z''
 for (int i=0; i<9; i++){
  float ang_vel_cov_matrix[9] = {0.0, 0.0, 0.0,  0.0, 0.0, 0.0,  0.0, 0.0, 0.0};
  imu_msg.angular_velocity_covariance[i] = ang_vel_cov_matrix[i];
 }
  
// linear_acceleration in m/(s*s), Ja stimmt laut Testprogramm
  imu_msg.linear_acceleration.x = accel.acceleration.x;
  imu_msg.linear_acceleration.y = accel.acceleration.y;
  imu_msg.linear_acceleration.z = accel.acceleration.z;   

 for (int i=0; i<9; i++){
  float lin_acc_cov_matrix[9] = {0.0, 0.0, 0.0,  0.0, 0.0, 0.0,  0.0, 0.0, 0.0};
  imu_msg.linear_acceleration_covariance[i] = lin_acc_cov_matrix[i];
 }
  
  imu_pub.publish( &imu_msg );
  nh.spinOnce();
  delay(1000);
}


 
