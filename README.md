# emr
Software zum Modul EMR Embedded Robotics SS21

Nachdem Ubuntu Focal Fossa 20.4 (LTS) installiert wurde 
als erstes einen catkin-Workspace Ordner erstellen

Terminal öffnen mit STRG+ALT+T. Hinter dem Prompt $ die Befehle eingeben

>$ mkdir catkin_ws

>$ cd catkin_ws

>$ mkdir src

Klone das Repositorium nach catkin_ws/src
>$ cd catkin_ws/src/

>$ git clone https://github.com/ProfJust/emr.git

ggf. ist es vorher erforderlich noch git zu installieren:
>$ sudo apt install git

Jetzt sollte der Ordner emr geclont worden sein.

Erstellen des youBot-Workspace mit Shellskript
>$ cd emr/_installSkript/

ggf. erstmal ROS installieren, dazu dem Skript 
die Ausführungsrechte geben und dann ausführen
>$ chmod +x ROS_Noetic_Installation_auf_Remote_PC.sh

>$ ./ROS_Noetic_Installation_auf_Remote_PC.sh 

Danach sämtliche für unseren youBot benötigte Software
Pakete installieren

>$ chmod +x youBot_Noetic_Installation_auf_Remote_PC.sh

>$ ./youBot_Noetic_Installation_auf_Remote_PC.sh

ggf. noch die .bahsrc konfigurieren
>$ chmod +x edit_bashrc_for_emr.sh 

>$ ./edit_bashrc_for_emr.sh 

Nun sollte man den youBots in unsere Gazebo-Arena
starten können

>$ roslaunch emr_worlds youbot_arena.launch
