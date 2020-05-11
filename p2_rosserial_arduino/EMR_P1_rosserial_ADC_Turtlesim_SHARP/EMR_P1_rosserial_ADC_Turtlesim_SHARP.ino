//-------------- EMR -----------------------------------
// P2 - Poti steuert TurtleSim
// rosserial ADC Turtlesim Example
// Poti und LDR steuern Turtlesim
// $ roscore
// $ rosrun rosserial_python serial_node.py /dev/ttyACM0
// $ rosrun turtlesim turtlesim_node
//################# mit SHARP-Sensor ######
// Combo-Board an J4 (A8-A15) und J27 (D40-47)
// Nutzt dort das LCD, eine LED und das Poti /den LDR
// Sharp Sensor an J1 (A0)
// sendet die Daten über rosserial an den turtlesim
// LDR => Speed der Turtle
// Poti => Richtung der Turtle
// Bei kurzem Abstand stoppt die Turtle
//--------------------------------------------------

#if (ARDUINO >= 100)
#include <Arduino.h>
#else
#include <WProgram.h>
#endif
#include <ros.h>
#include <geometry_msgs/Twist.h>
#include <LiquidCrystal.h>

// initialize the library with the numbers of the interface pins
//                RS EN D4 D5 D6 D7
//LiquidCrystal lcd(4, 5, 0, 1, 2, 3); //J2 Combo Board Port B => LCD
LiquidCrystal lcd(44, 45, 40, 41, 42, 43); //J27 Combo Board Port B => LCD

//###### ACHTUNG: rosserial benötigt PIN D0 und D1 (Serial) 
//                     => nicht für LCD verfügbar ########

ros::NodeHandle nh;
// namespace :: class bezeichner
geometry_msgs::Twist twist_msg;
//ros::Publisher p("adc", &adc_msg);
//ros::Publisher p("turtle1/cmd_vel", &twist_msg);
ros::Publisher p("cmd_vel", &twist_msg);


//--- Die Hardware Pins ----
#define SharpPin A0
#define LEDPin A15
#define LDRPin A8
#define POTIPin A9
int sharpValue = 0;
char LCDstr[17];

void setup() {
  // set up the LCD's number of columns and rows:
    lcd.begin(16, 2);
  // Print a message to the LCD.
    lcd.setCursor(0, 0);  
    lcd.print("Sharp Test ");
   // Toggle LED 
   pinMode(LEDPin, OUTPUT);
  // Init ROS 
    nh.initNode();
    nh.advertise(p);
}

//---- We average the analog reading to elminate some of the noise ---
int averageAnalog(int pin) {
  int v = 0;
  for (int i = 0; i < 4; i++) v += analogRead(pin);
  return v / 4;
}

void loop() {
  sharpValue = averageAnalog(SharpPin); //AD-Wandlung
  //----- Ausgabe LCD ----
  sprintf(LCDstr,"AD: %04d", sharpValue);
  lcd.setCursor(0, 1);  
  lcd.write(LCDstr);  
  
  //----- Ausgabe ROS ----
  if (sharpValue <= 300) {
    //Turtle Go
    twist_msg.linear.x = ((double) averageAnalog(LDRPin)) / 1023 * 0.8; //Youbot < 0.8
    twist_msg.angular.z = 2 * ((double) averageAnalog(POTIPin)) / 1023.0 - 1;
  }
  else {
    // Turtle Stop
    twist_msg.linear.x = 0;  //Youbot < 0.8
    twist_msg.angular.z = 0;
  }
  p.publish(&twist_msg);
  nh.spinOnce();

  //--- Blink LED ----
  digitalWrite(LEDPin, digitalRead(LEDPin) ? LOW : HIGH);
  delay(200);
}
