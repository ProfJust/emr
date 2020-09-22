# youBot Installation auf Remote-PC
# OJ fuer robotik.bocholt@w-hs.de
# SS2020
#edited 22.09.2020

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
#git clone http://github.com/youbot/youbot_description.git -b jade-devel
# bessere Alternative 
git clone https://github.com/mas-group/youbot_description.git
#git clone http://github.com/youbot/youbot_simulation.git
# bessere Alternative 
git clone https://github.com/mas-group/youbot_simulation.git
git clone http://github.com/wnowak/brics_actuator.git
git clone https://github.com/pschillinger/youbot_integration.git
git clone https://github.com/FlexBE/youbot_behaviors.git
git clone https://github.com/pal-robotics-forks/point_cloud_converter
git clone https://github.com/team-vigir/flexbe_behavior_engine.git
git clone https://github.com/wnowak/youbot_moveit.git
#kein catkin-pkg  git clone https://github.com/ros-controls/ros_control.git -b kinetic-devel
git clone https://github.com/ros-controls/realtime_tools.git -b kinetic-devel
git clone https://github.com/ros-controls/control_toolbox.git -b kinetic-devel
git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git -b kinetic-devel





# braucht man nicht wirklich: git clone https://github.com/wnowak/youbot_applications.git
# android_app needs BLUETOOTH_INCLUDE_DIR => delete directory
#cd catkin_ws/src/youbot_applications/
#rm -r  android_app_pc_client
#rm -r keyboard_remote_control

sudo apt-get dist-upgrade -y   #-y ist ohne Ja Abfrage
sudo apt-get update -y
sudo apt-get install ros-kinetic-urg-node -y
sudo apt-get install ros-kinetic-scan-tools -y
sudo apt-get install ros-kinetic-map-server -y
sudo apt-get install ros-kinetic-slam-gmapping -y
sudo apt-get install ros-kinetic-amcl -y
sudo apt-get install ros-kinetic-move-base -y
sudo apt-get install ros-kinetic-pr2-msgs -y
sudo apt-get install ros-kinetic-joint-trajectory-controller -y
sudo apt-get install ros-kinetic-joint-trajectory-action-tools -y
sudo apt-get install ros-kinetic-rqt-joint-trajectory-controller -y
sudo apt-get install ros-kinetic-ros-control -y
sudo apt-get install ros-kinetic-astra-camera -y
sudo apt-get install ros-kinetic-astra-launch -y
sudo apt-get install ros-kinetic-moveit* -y





cd ~/catkin_ws/src
#echo -e "\033[34m Erstelle catkin_pkg \033[0m"
#catkin_create_pkg emr std_msgs rospy roscpp

echo -e "\033[34m Aktualisiere alle Abhaengigkeiten der ROS-Pakete \033[0m"
rosdep update
rosdep install --from-paths src --ignore-src -r -y

sudo setcap cap_net_raw+ep ~/catkin_ws/devel/lib/youbot_driver_ros_interface/youbot_driver_ros_interface

echo -e "\033[34m add at bottom ~/catkin_ws/src/youbot_navigation/youbot_navigation_common/CMakeLists.txt \033[0m" 
#Z14
## by OJ since ros.h was not found
#INCLUDE_DIRECTORIES(
#	include
#	${catkin_INCLUDE_DIRS}
#)


## Erganze Zeilen in CMakeLists since catkion_make says ros.h was not found
cd ~/catkin_ws/src/youbot_navigation/youbot_navigation_common/
echo "## by OJ since ros.h was not found" >> CMakeLists.txt
echo "INCLUDE_DIRECTORIES(" >> CMakeLists.txt
echo "include" >> CMakeLists.txt
#Avoid variable substitution with /var or 'var '
echo "\${catkin_INCLUDE_DIRS}" >> CMakeLists.txt
echo ")" >> CMakeLists.txt



#echo -e "\033[34m to do:   $ cd ~/catkin_ws/  ...   catkin_make \033[0m"
cd ~/catkin_ws/
catkin_make

echo -e "\033[34m EMR - SS20 - Workspace is installed - have fun!  \033[0m"
echo -e "\033[32m $ roslaunch emr youbot_emr_simulation.launch \033[0m"

