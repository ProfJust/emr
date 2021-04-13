# anpassen der .bashrcn auf Remote-PC
# OJ fuer robotik.bocholt@w-hs.de
# SS2021

#!/bin/bash
# script to setup youbot-Workspace

echo -e "\033[34m ---------- EMR SS21 - .bashrc editieren  ------------ \033[0m "

echo "Shellskript zum Einfuegen der ROS - Konfiguration" 

sudo apt-get dist-upgrade
pwd
cd ~/

echo "###  ROS - Umgebungsvariablen setzen ###
source /opt/ros/noetic/setup.bash
source ~/catkin_ws/devel/setup.bash

export ROS_PACKAGE_PATH=~/catkin_ws/src:/opt/ros/noetic/share
# local =>Gazebo
export ROS_MASTER_URI=http://127.0.0.1:11311
export ROS_HOSTNAME=127.0.0.1
# global => real youBot
# export ROS_MASTER_URI=http://192.168.0.40:11311
# export ROS_HOSTNAME=192.168.0.41
export LC_NUMERIC=en_US.UTF-8
###############################################
" >> .bashrc
#echo "export PYTHONPATH=$PYTHONPATH:$ROS_ROOT/core/roslib/src" >> .bashrc
#Avoid variable substitution with /var or 'var '
#echo "\${catkin_INCLUDE_DIRS}" >> CMakeLists.txt



#echo -e "\033[34m to do:   $ cd ~/catkin_ws/  ...   catkin_make \033[0m"
echo -e "\033[34m EMR - SS21 - .bashrc configurated   \033[0m"


