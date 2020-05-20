Hier kann man den youBot im SDF-Format mit Gazebo starten und per RQT steuern 
=> d.h. die ROS-Nachrichten sind verbunden mit den Joints

Ordner youbot_sdf im catkin_ws/src-Ordner einfügen und mit catkin_make kompilieren

1.) Leeres Gazebo starten:
$1 roslaunch youbot_sdf empty.launch

2.) in neuer Shell 
$2 rosrun gazebo_ros spawn_model -file ~/catkin_ws/src/youbot_sdf/youbot_sdf_description/model-1_4.sdf -sdf -model youbot

3.) rostopic list zeigt /cmd_vel
4.) rqt robot steering funktioniert
5.) rviz => keine robot_description gefunden

oj@Melodic-HP:~/catkin_ws$ rostopic list
/clock
/cmd_vel
/gazebo/link_states
/gazebo/model_states
/gazebo/parameter_descriptions
/gazebo/parameter_updates
/gazebo/set_link_state
/gazebo/set_model_state
/odom
/rosout
/rosout_agg
/tf



