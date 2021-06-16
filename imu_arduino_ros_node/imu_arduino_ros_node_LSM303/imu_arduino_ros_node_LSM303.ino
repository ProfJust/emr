/*
 * Pubslisht IMU Daten
 * OJ 11-6-2021 "
 */
#include <Wire.h>
#include <LSM303.h>

LSM303 sensor;
char imu_report[80];


#include <ros.h>
#include <std_msgs/String.h>

ros::NodeHandle  nh;
std_msgs::String str_msg;
ros::Publisher imu_pub("imu_report_topic", &str_msg);

void setup()
{
  //initiate Sensor I2C
  Wire.begin();
  sensor.init();
  sensor.enableDefault();

  //Initiate ROS Node
  nh.initNode();
  nh.advertise(imu_pub);
}

void loop()
{
 // Eingabe
  sensor.read();

//Verabeitung
  snprintf(imu_report, sizeof(imu_report), "Acc:  x: %6d   y: %6d  z: %6d",sensor.a.x, sensor.a.y, sensor.a.z);
  str_msg.data = imu_report;
  imu_pub.publish( &str_msg );
  nh.spinOnce();
  delay(1000);
}


 
