//------------------------------------------
// Westfälische Hochschule - FB Maschinenbau
// Labor für Mikrolektronik und Robotik
// Modul Embedded Robotics -Prof. O. Just
//--------------------------------------------------------
// hello_ros_node.cpp
// Version vom 20.04.2020
//--------------------------------------------------------
// Unser erster ROS-Knoten in C++
// Usage: 
// Ordner "hello_ros_node" in den catkin_ws/src verschieben
// kompilieren mit $ catkin_make
// starten mit rosrum hello_ros_node hello_ros_node
//---------------------------------------------------------
#include </opt/ros/noetic/include/ros/ros.h>

int main (int argc, char** argv){
	ros::init(argc,argv,"hello_ROS");
	ros::NodeHandle nh;
	ROS_INFO_STREAM("Hello, ROS !!");

}

		
