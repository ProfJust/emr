 //-------------- EMR -----------------------------------
 // P2 - Poti steuert TurtleSim
 // rosserial ADC Turtlesim Example
 // Poti und LDR steuern Turtlesim 
 // $ roscore
 // $ rosrun rosserial_python serial_node.py /dev/ttyACM0
 // $ rosrun turtlesim turtlesim_node 
 //
 // Error: can't open device "/dev/ttyACM0": Permission denied
 // LOESEUNG: sudo chmod 666 /dev/ttyACM0


#if (ARDUINO >= 100)
 #include <Arduino.h>
#else
 #include <WProgram.h>
#endif
#include <ros.h>
#include <geometry_msgs/Twist.h>

ros::NodeHandle nh;
// namespace :: class bezeichner
  geometry_msgs::Twist twist_msg;
//ros::Publisher p("adc", &adc_msg);
  ros::Publisher p("turtle1/cmd_vel", &twist_msg);

#define LED_PIN 44
#define POTI_PIN A9
#define LDR_PIN  A8

void setup(){ 
  pinMode(LED_PIN, OUTPUT);
  nh.initNode();
  nh.advertise(p);
}

//We average the analog reading to elminate some of the noise
int averageAnalog(int pin){
  int v=0;
  for(int i=0; i<4; i++) v+= analogRead(pin);
  return v/4;
}

void loop(){  
    twist_msg.linear.x = ((double) averageAnalog(LDR_PIN))/1023 *0.8;  //Youbot < 0.8
    twist_msg.angular.z = 2* ((double) averageAnalog(POTI_PIN))/1023.0 -1;
  
    p.publish(&twist_msg);
    nh.spinOnce();
    
  // Blink LED
  digitalWrite(LED_PIN, digitalRead(LED_PIN)?LOW:HIGH);  
  delay(200);
}
