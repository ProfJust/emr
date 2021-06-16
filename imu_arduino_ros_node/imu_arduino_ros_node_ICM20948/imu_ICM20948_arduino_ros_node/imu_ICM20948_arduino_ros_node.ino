/*
 * Pubslisht IMU Daten im ROS
 * OJ 11-6-2021 "
 */
 //---------------------------------------------------------------
// WHS OJ we use Arduino Nano with ATmega328P (Old Bootloader)
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
// Header
 imu_msg.header.stamp = nh.now();
//Orientation (Quaternion erforderlich, Euler vom Sensor)
  imu_msg.orientation.x = mag.magnetic.x; 
  imu_msg.orientation.y =  mag.magnetic.y; 
  imu_msg.orientation.z =  mag.magnetic.z; 
  // 'struct sensors_vec_t' has no member named 'w'   imu_msg.orientation.w = gyro.gyro.w;

// angular_velocity
  imu_msg.angular_velocity.x = accel.acceleration.x;
  imu_msg.angular_velocity.y = accel.acceleration.y;
  imu_msg.angular_velocity.z = accel.acceleration.z;
  
// linear_acceleration in m/(s*s)
  imu_msg.linear_acceleration.x = gyro.gyro.x;         
  imu_msg.linear_acceleration.y = gyro.gyro.y;  
  imu_msg.linear_acceleration.z = gyro.gyro.z;      
  
  imu_pub.publish( &imu_msg );
  nh.spinOnce();
  delay(1000);
}


 
