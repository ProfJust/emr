# youBot Installation auf Remote-PC
# OJ fuer robotik.bocholt@w-hs.de
# SS2020

#!/bin/bash
# script to setup youbot-Workspace for ROS Noetic
# EMR SS2020 Hebinck, Heid

echo -e "\033[1;92m ---------- Skript zur Einrichtung des youBot Workspace in ROS Noetic ------------ \033[0m "

echo -e "\033[42m ---------- Systemupdates werden ausgefuehrt - Passwort erforderlich  ------------ \033[0m "
cd ~/catkin_ws/src/
sudo apt update -y
sudo apt dist-upgrade -y   #-y ist ohne Ja Abfrage

echo -e "\033[42m ---------- Installation der noetigen ROS-Pakete  ------------ \033[0m "
sudo apt install ros-noetic-urg-node -y
sudo apt install ros-noetic-scan-tools -y #fehlt noch
sudo apt install ros-noetic-map-server -y
sudo apt install ros-noetic-slam-gmapping -y #fehlt noch
sudo apt install ros-noetic-amcl -y
sudo apt install ros-noetic-move-base -y
# sudo apt install ros-noetic-pr2-msgs -y Noch kein noetic-release verfuegbar
git clone https://github.com/GeraldHebinck/pr2_common.git -b msg_only
sudo apt install ros-noetic-joint-trajectory-controller -y
sudo apt install ros-noetic-rqt-joint-trajectory-controller # fuer Armsteuerung mit RQT

git clone https://github.com/GeraldHebinck/emr -b noetic
git clone https://github.com/GeraldHebinck/youbot_navigation.git -b noetic-devel # fork von https://github.com/youbot/youbot_navigation
git clone https://github.com/youbot/youbot_driver -b hydro-devel
git clone https://github.com/GeraldHebinck/youbot_driver_ros_interface.git -b noetic-devel # fork von git clone https://github.com/youbot/youbot_driver_ros_interface.git
git clone https://github.com/GeraldHebinck/youbot_description.git -b noetic-devel # fork von https://github.com/mas-group/youbot_description.git
git clone https://github.com/GeraldHebinck/youbot_simulation.git -b noetic-devel # fork von https://github.com/mas-group/youbot_simulation.git
git clone https://github.com/wnowak/brics_actuator.git
git clone https://github.com/pschillinger/youbot_integration.git
git clone https://github.com/FlexBE/youbot_behaviors.git
git clone https://github.com/pal-robotics-forks/point_cloud_converter
git clone https://github.com/team-vigir/flexbe_behavior_engine.git
git clone https://github.com/wnowak/youbot_moveit.git
# braucht man nicht wirklich: git clone https://github.com/wnowak/youbot_applications.git
# android_app needs BLUETOOTH_INCLUDE_DIR => delete directory
#cd catkin_ws/src/youbot_applications/
#rm -r  android_app_pc_client
#rm -r keyboard_remote_control

echo -e "\033[42m ---------- Aktualisiere alle Abhaengigkeiten der ROS-Pakete ---------- \033[0m"
source ~/.bashrc
rosdep update
rosdep install --from-paths . --ignore-src -r -y

echo -e "\033[42m ---------- Ausfuehren von catkin_make ---------- \033[0m"
cd ~/catkin_ws/
catkin_make

sudo setcap cap_net_raw+ep ~/catkin_ws/devel/lib/youbot_driver_ros_interface/youbot_driver_ros_interface

echo -e "\033[42m ---------- Robotik-Labor Arena in Gazebo einfuegen ---------- \033[0m"
mkdir -p ~/.gazebo/models/arena_robotiklabor
cp ~/catkin_ws/src/emr/emr_worlds/arena_robotiklabor/* -t ~/.gazebo/models/arena_robotiklabor -r

echo -e "\033[42m ---------- youBot Workspace ist installiert - have fun! ----------   \033[0m"
echo -e "\033[42m $ roslaunch emr_worlds youbot_arena.launch \033[0m"

