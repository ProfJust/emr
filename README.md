# emr
Software zum Modul EMR Embedded Robotics SS21

Klone das Repositorium nach catkin_ws/src
$ cd catkin_ws/src/
$ git clone https://github.com/ProfJust/emr.git

Erstellen des youBot-Workspace mit Shellskript

$ cd emr/_installSkript/

$ chmod +x youBot_Noetic_Installation_auf_Remote_PC.sh

$ ./youBot_Noetic_Installation_auf_Remote_PC.sh

$ chmod +x edit_bashrc_for_emr.sh 

$ ./edit_bashrc_for_emr.sh 

$ roslaunch emr_worlds youbot_arena