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

// Install EKF Filter
git clone https://github.com/ros-planning/robot_pose_ekf.git
sudo apt-get install liborocos-bfl-dev


// Starten der Nodes
// $ roscore
// rosrun rosserial_python serial_node.py /dev/ttyUSB0  /ttyACM0
// roslaunch robot_pose_ekf robot_pose_ekf.launch 
// roslaunch emr_worlds youbot_arena.launch

/* remaining ERROR
 *  [ERROR] [1624289785.492709399, 11.942000000]: Covariance specified for measurement on topic wheelodom is zero
[ERROR] [1624289785.525946507, 11.976000000]: Covariance specified for measurement on topic wheelodom is zero
[ERROR] [1624289785.559621173, 12.010000000]: Covariance specified for measurement on topic wheelodom is zero
[ERROR] [1624289785.568418074, 12.019000000]: filter time older than odom message buffer


http://wiki.ros.org/robot_pose_ekf/Troubleshooting
Covariance specified for measurement on topic xxx is zero

    Each measurement that is processed by the robot pose ekf needs to have a covariance associated with it. 
    The diagonal elements of the covariance matrix cannot be zero. This error is shown when one of the diagonal elements is zero.
    Messages with an invalid covariance will not be used to update the filter. 

    
    
    ??? im /odom Topic ist die covariance null !!!

     header: 
  seq: 18076
  stamp: 
    secs: 615
    nsecs: 151000000
  frame_id: "odom"
child_frame_id: "base_dummy"
pose: 
  pose: 
    position: 
      x: -0.061228041569408136
      y: -0.0012668461805326755
      z: 0.0
    orientation: 
      x: 0.0
      y: 0.0
      z: 0.05462127207519089
      w: 0.9985071440089389
  covariance: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
twist: 
  twist: 
    linear: 
      x: -0.009086312113611161
      y: -0.0010191169787464576
      z: 0.0
    angular: 
      x: 0.0
      y: 0.0
      z: 0.02063455826306626
  covariance: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
---


Quelle odom: Gazebo 
https://answers.ros.org/question/353977/gazebo-change-covariance-matrix/

Hi @MarkusHHN,

Unfortunately, the covariance implementation in that plugin is hard coded, so there is no way to change that.

As I see, you have here two possible solutions:

    Naive approach: You generate a node that subscribes to the odometry from that plugin and change the message covariance values then publish in a new topic and in your control nodes read from this new odometry. This is not a good approach in my honest opinion, but hey, it is there, just for you to know.
    Implement your own plugin: That will allow you to have control over the covariance values. The libgazebo_ros_planar_move is a model plugin, you can implement your own model plugin which can be based on the implementation of the libgazebo_ros_planar_move. This way you will not only have control over the covarriance values but you will be able to implement things like gaussian error, etc.



 */
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
ros::Publisher imu_pub("Imu_data", &imu_msg);

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
    float orient_cov_matrix[9] = {0.05, 0.0, 0.0,  0.0, 0.05, 0.00,  0.0, 0.0, 0.05}; //diagonal Elements cannot be zero
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
  float ang_vel_cov_matrix[9]  = {0.05, 0.0, 0.0,  0.0, 0.05, 0.00,  0.0, 0.0, 0.05}; //diagonal Elements cannot be zero
  imu_msg.angular_velocity_covariance[i] = ang_vel_cov_matrix[i];
 }
  
// linear_acceleration in m/(s*s), Ja stimmt laut Testprogramm
  imu_msg.linear_acceleration.x = accel.acceleration.x;
  imu_msg.linear_acceleration.y = accel.acceleration.y;
  imu_msg.linear_acceleration.z = accel.acceleration.z;   

 for (int i=0; i<9; i++){
  float lin_acc_cov_matrix[9]  = {0.01, 0.01, 0.01,  0.01, 0.01, 0.01,  0.01, 0.01, 0.01}; //diagonal Elements cannot be zero
  imu_msg.linear_acceleration_covariance[i] = lin_acc_cov_matrix[i];
 }
  
  imu_pub.publish( &imu_msg );
  nh.spinOnce();
  delay(1000);
}


 
