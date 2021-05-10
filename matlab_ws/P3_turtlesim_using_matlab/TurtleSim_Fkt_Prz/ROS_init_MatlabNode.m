%% ROS_Node_init_localhost.m
% Initialisiert die Verbindung zwischen Matlab und dem ROS
% Startet den Matlab-ROS-Knoten
% Variante für ROS-Master auf 'localhost'
% EMR - Version vom 13.05.2020 - gitHub
%--------------------------------------------------------------
%  vorher starten:
% 'roscore' nicht von Matlab aus moeglich
% 'rosrun  turtlesim turtlesim_node'  auch nicht
% ------------------------------------------------------------

%% --- Start Matlab Global Node  => nur wenn es ihn nicht schon gibt
% => rosnode list gibt Fehler aus
try
    rosnode list
catch exp   % Error from rosnode list
   % only if error: rosinit   
   % localhost or IP
   % rosinit  wenn ROS-Master auf localhost
   % sonst die IP des ROS-Masters
   % siehe Terminal mit $roscore
   % -> started roslaunch server http://192.168.1.142:35877
   rosinit
end
% ....