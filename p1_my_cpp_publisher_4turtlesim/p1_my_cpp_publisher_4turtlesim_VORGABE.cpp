//------------------------------------------
// Westfälische Hochschule - FB Maschinenbau
// Labor für Mikrolektronik und Robotik
// Modul Embedded Robotics -Prof. O. Just
//------------------------------------------
// p1_my_cpp_publisher_4turtlesim
// Version vom 14.04.2021
//------------------------------------------
// ROS -Publisher für die Steuerung der
// Turtle-Bot Simulation
// siehe auch:
// A Gentle Introduction to ROS von J.O.Kane
//------------------------------------------
#include </ros/ros.h>

// ROS-Klasse für den Nachrichten-Typ einbinden
#include <geometry_msgs/Twist.h>
#include <stdlib.h> //wegen rand() und srand()

// Funktion zum lesen einer Taste ohne Enter - s.u.
int getch(void);

//---------------------------------------------
int main (int argc, char **argv){
	// ROS initialisieren , Weitergabe der Startparameter
	ros::init(argc, argv,"publish_velocity");
	// Eine eigenen Knoten instanzieren
	ros::NodeHandle myNh; 
	// Die Template-Funktion mit dem Datentyp der Parameter versehen
	ros::Publisher myPub = myNh.advertise<geometry_msgs::Twist>("turtle1/cmd_vel",1000);  
	ros::Rate rate(2); // Senderate 2Hz

	srand(time(0)); //Zufallsgenerator seeden

	while(ros::ok()){  //Endlosschleife bis rosshutdown
		// Instanziere Message
		geometry_msgs:: Twist myMsg;
				
		myMsg.linear.x  =     double(rand())/double(RAND_MAX);	
		myMsg.angular.z = 2 * double(rand())/double(RAND_MAX);

		// senden der msg
		myPub.publish(myMsg);

		//Konsolen-Ausgabe von rosout (wie printf())
		ROS_INFO("Sende Zufalls-Werte für velocity linear %f angular %f",
			myMsg.linear.x , 
			myMsg.angular.z);
		
		// Warte bis zur nächsten Sendung
		rate.sleep();
	}
}

//-----------------------------------------------------------
// Funktion zum holen eine Taste ohne Enter 
//vgl. https://www.c-plusplus.net/forum/272087-full
//-----------------------------------------------------------
#include <termio.h>
int getch(void){
  struct termios term, oterm;
  int fd = 0;
  int c = 0;
  //Attribute holen
  tcgetattr(fd, &oterm);
  memcpy(&term, &oterm, sizeof(term));
  term.c_lflag = term.c_lflag & (!ICANON);
  term.c_cc[VMIN] = 0;
  term.c_cc[VTIME] = 1;
  //neue Attribute setzen
  tcsetattr(fd, TCSANOW, &term);

  //Zeichen holen
  c = getchar(); 

  //alte Attribute setzen
  tcsetattr(fd, TCSANOW, &oterm);
  return c; // gibt -1 zurück, wenn kein Zeichen gelesen wurde
}
		
