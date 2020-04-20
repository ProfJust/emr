// hello_world.cpp
// by OJ at 27-02-2018
//---------------------------------
#include </opt/ros/kinetic/include/ros/ros.h>
int main (int argc, char** argv){
	ros::init(argc,argv,"hello_ROS");
	ros::NodeHandle nh;
	ROS_INFO_STREAM("Hello, ROS !!");

}
