# anpassen der .bashrcn auf Remote-PC
# OJ fuer robotik.bocholt@w-hs.de
# SS2020

#!/bin/bash
# script to setup youbot-Workspace

echo -e "\033[34m ---------- EMR SS20 - .bashrc editieren  ------------ \033[0m "

echo "Shellskript zum Einfuegen der ROS - Konfiguration" 

sudo apt-get dist-upgrade
pwd
cd ~/


## Erganze Zeilen in CMakeLists since catkion_make says ros.h was not found
echo "###  ROS - Umgebungsvariablen setzen ###" >> .bashrc
echo "source /opt/ros/melodic/setup.bash" >> .bashrc
echo "## IP des PCs auf dem der Master laeuft ## " >> .bashrc
echo "## Gazebo => localhost " >> .bashrc
echo "export ROS_MASTER_URI=http://localhost:11311/" >> .bashrc
echo "## IP dieses Rechners " >> .bashrc
echo "export ROS_IP=192.168.129.104" >> .bashrc
echo "ROS_PACKAGE_PATH=~/catkin_ws/src:/opt/ros/meloduc/share"
echo "source devel/setup.bash" >> .bashrc

#echo "export PYTHONPATH=$PYTHONPATH:$ROS_ROOT/core/roslib/src" >> .bashrc
#Avoid variable substitution with /var or 'var '
#echo "\${catkin_INCLUDE_DIRS}" >> CMakeLists.txt



#echo -e "\033[34m to do:   $ cd ~/catkin_ws/  ...   catkin_make \033[0m"
echo -e "\033[34m EMR - SS20 - .bashrc configurated   \033[0m"


