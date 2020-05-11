% TurtleSim_01.m
% TurtleSim ansteuern
% EMR - Version vom 5.05.2020
%-------------------------------------
% open a Shell (STRG+ALT+T)
% Start a ROS master in a Shell   $roscore
% Start TurtleSim in a secomd Shell $rosrun turtlesim turtlesim_node
%----------------------------------------------------
rosshutdown() %Knoten runterfahren, falls noch aktiv
rosinit()

%setenv('ROS_IP','192.168.1.144') % setzen der IP dieses Rechners

% Start Matlab Global Node  => nur wenn es ihn nicht schon gibt
%if ~robotics.ros.internal.Global.isNodeActive
    % IP des Master-PCs (Linux)
    % rosinit('http://192.168.1.142:11311/','NodeName','/RoboMasterWindows')
%end
%--- Anmelden des Topics beim ROS-Master -----
myPublisher = rospublisher ('turtle1/cmd_vel', 'geometry_msgs/Twist');

% in Shell rosrun turtlesim turtlesim_node 

%---  zun�chst leere Message in diesem Topic erzeugen -- 
myMsg = rosmessage(myPublisher);

%--- Message mit Daten f�llen ---
myMsg.Linear.X = 3;
%... und absenden
send(myPublisher,myMsg);
pause(3); % wait n seconds 
%---- 3 Sekunden diese Message ausf�hren ---
%--- Message auf Null setzen, sonst beleibt der alte Wert
myMsg.Linear.X = 0;
send(myPublisher,myMsg);

%----- 90� Drehung ---
myMsg.Angular.Z = pi/2;
send(myPublisher,myMsg);
pause(1); % wait n seconds 
myMsg.Angular.Z = 0.0;
send(myPublisher,myMsg);

%--- 3 Geradeaus  ---
myMsg.Linear.X = 3;
send(myPublisher,myMsg);
pause(3); % wait n seconds 
myMsg.Linear.X = 0;
send(myPublisher,myMsg);

%----- 90� Drehung ---
myMsg.Angular.Z = pi/2;
send(myPublisher,myMsg);
pause(1); % wait n seconds 
myMsg.Angular.Z = 0.0;
send(myPublisher,myMsg);

%--- 3 Geradeaus  ---
myMsg.Linear.X = 3;
send(myPublisher,myMsg);
pause(3); % wait n seconds 
myMsg.Linear.X = 0;
send(myPublisher,myMsg);

%----- 90� Drehung ---
myMsg.Angular.Z = pi/2;
send(myPublisher,myMsg);
pause(1); % wait n seconds 
myMsg.Angular.Z = 0.0;
send(myPublisher,myMsg);

%--- 3 Geradeaus  ---
myMsg.Linear.X = 3;
send(myPublisher,myMsg);
pause(3); % wait n seconds 
myMsg.Linear.X = 0;
send(myPublisher,myMsg);

%----- 90� Drehung ---
myMsg.Angular.Z = pi/2;
send(myPublisher,myMsg);
pause(1); % wait n seconds 
myMsg.Angular.Z = 0.0;
send(myPublisher,myMsg);

pause(5);
%rosshutdown();