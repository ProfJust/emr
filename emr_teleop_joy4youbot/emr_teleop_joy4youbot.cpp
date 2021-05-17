//------------------------------------------
// Westfälische Hochschule - FB Maschinenbau
// Labor für Mikrolektronik und Robotik
// Modul Embedded Robotics -Prof. O. Just
//--------------------------------------------------------
//  emr_teleop_joy4youBot.cpp
// Version vom 18.05.2021
//--------------------------------------------------------
// Unser erster ROS-Knoten in C++
// Usage: 
// Ordner "youBot_teleop_joy" in den catkin_ws/src verschieben
// kompilieren mit $ catkin_make
// starten mit rosrun emr_teleop_joy4youbot emr_teleop_joy4youbot
//---------------------------------------------------------
//#include </opt/ros/noetic/include/ros/ros.h>

#include <ros/ros.h>
#include <geometry_msgs/Twist.h>
#include <sensor_msgs/Joy.h>


class TeleopBot
{
public:
  TeleopBot();

private:
  void joyCallback(const sensor_msgs::Joy::ConstPtr& joy);

  ros::NodeHandle nh_;

  int linear_, angular_;
  double l_scale_, a_scale_;
  ros::Publisher vel_pub_;
  ros::Subscriber joy_sub_;

};


TeleopBot::TeleopBot():
  linear_(1),
  angular_(2)
{
  //nh_.param("axis_linear", linear_, linear_);
  //nh_.param("axis_angular", angular_, angular_);
  //nh_.param("scale_angular", a_scale_, a_scale_);
  //nh_.param("scale_linear", l_scale_, l_scale_);

  vel_pub_ = nh_.advertise<geometry_msgs::Twist>("/cmd_vel", 1);
  joy_sub_ = nh_.subscribe<sensor_msgs::Joy>("joy", 10, &TeleopBot::joyCallback, this);
}

void TeleopBot::joyCallback(const sensor_msgs::Joy::ConstPtr& joy){
  geometry_msgs::Twist twist;
  //twist.angular.z = a_scale_*joy->axes[angular_];
  //twist.linear.x = l_scale_*joy->axes[linear_];

  if(joy->buttons[4]==1)  //Totman Knopf gedrückt? Links oben
  {
    twist.angular.z = 0.5 * joy->axes[3];
    twist.linear.y = 0.5 * joy->axes[6];
    twist.linear.x = 0.5 * joy->axes[4];
  }
  else 
  {
    twist.angular.z = 0.0;
    twist.linear.y = 0.0;
    twist.linear.x = 0.0;
  }
  
  vel_pub_.publish(twist);
}

int main(int argc, char** argv){
  ROS_INFO("emr_teleop_joy4youbot gestartet");
  ROS_INFO("Totman Button am Logitech F710 links oben, Mode-LED aus");
  ros::init(argc, argv, "joy_teleop_bot");
  TeleopBot teleop_bot;
  ros::spin();
}
