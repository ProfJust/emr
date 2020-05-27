
Anleitung zum Implementieren des Gazebomodells der Arena:
20.05.20 by OJ

- git clone emr/emr_worlds
- catkin_make
- Ordner des Gazebo Modells "arena_robotiklabor" kopieren und am Zielcomputer eingefügen in: ~/.gazebo/models


Gazebo youBot in der Arena:
  $ roslaunch emr_worlds youbot_arena.launch
  
Nur Arena starten:
  $ roslaunch emr_worlds arena_robotiklabor.launch
