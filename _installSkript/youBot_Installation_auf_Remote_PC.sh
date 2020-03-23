# youBot Installation auf Remote-PC
# OJ fuer robotik.bocholt@w-hs.de
# SS2020

#!/bin/bash
# script to setup youbot-Workspace

echo -e "\033[34m ---------- EMR SS20 - youBot Workspace einrichten  ------------ \033[0m "

echo "Shellskript zur Installation der Treiber-Pakete" 

sudo apt-get dist-upgrade
pwd
cd ~/catkin_ws/src/

git clone http://github.com/youbot/youbot_navigation -b hydro-devel
git clone http://github.com/youbot/youbot_driver -b hydro-devel
git clone http://github.com/youbot/youbot_driver_ros_interface.git -b indigo-devel
git clone http://github.com/youbot/youbot_description.git -b jade-devel
git clone http://github.com/youbot/youbot_simulation.git
git clone http://github.com/wnowak/brics_actuator.git
git clone https://github.com/pschillinger/youbot_integration.git
git clone https://github.com/pal-robotics-forks/point_cloud_converter
git clone https://github.com/team-vigir/flexbe_behavior_engine.git
git clone https://github.com/wnowak/youbot_applications.git
git clone https://github.com/wnowak/youbot_moveit.git

sudo apt-get dist-upgrade -y   #-y ist ohne Ja Abfrage
sudo apt-get update -y
sudo apt-get install ros-melodic-urg-node -y
sudo apt-get install ros-melodic-scan-tools -y
sudo apt-get install ros-melodic-map-server -y
sudo apt-get install ros-melodic-slam-gmapping -y
sudo apt-get install ros-melodic-amcl -y
sudo apt-get install ros-melodic-move-base -y

echo -e "\033[31m Erstelle catkin_pkg \033[0m"
catkin_create_pkg emr std_msgs rospy roscpp

echo -e "\033[31m Aktualisiere alle Abhaengigkeiten der ROS-Pakete \033[0m"
rosdep update
rosdep install --from-paths src --ignore-src -r -y

sudo setcap cap_net_raw+ep devel/lib/youbot_driver_ros_interface/youbot_driver_ros_interface

echo -e "\033[31m to do: add at bottom ~/catkin_ws/src/youbot_navigation/youbot_navigation_common/CMakeLists.txt
Z14
## by OJ since ros.h was not found
INCLUDE_DIRECTORIES(
	include
	${catkin_INCLUDE_DIRS}
)
\033[0m" 

echo -e "\033[31m to do:   $ cd ~/catkin_ws/  ...   catkin_make \033[0m"

