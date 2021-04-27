%% TurtleSim_01.m
% TurtleSim ansteuern um ein Quadrat zu fahren
% zeitgesteuert
% EMR - Version vom 13.05.2020 - gitHub
%-------------------------------------
% !! Das hier funktioniert leider nicht !!
% system('roscore')
% system('rosrun turtlesim turtlesim_node')
% system("gnome-terminal -- 'rosrun turtlesim turtlesim_node'")
% https://answers.ros.org/question/255008/roslaunch-on-matlab/
% system(['export LD_LIBRARY_PATH="LD_path";' 'roslaunch turtlesim_shell.launch &']);
% system(['export LD_LIBRARY_PATH="LD_path";' 'roslaunch turtlesim_shell.launch & echo $!']);

%ROS_Node_init_localhost;
%disp 'Did you start rosrun turtlesim turtlesim_node ?'
%disp '$ rosrun turtlesim turtlesim_node'

% check if Windows PC has got Python 2.7 installed
% pyenv

%% --- Start Matlab Global Node  => nur wenn es ihn nicht schon gibt
% => rosnode list gibt Fehler aus
try
    rosnode list
catch exp   % Error from rosnode list
    rosinit  % only if error: rosinit   
    % IP des Windows-PCs 192.168.1.104
   setenv('ROS_HOSTNAME','192.168.1.104')
   %setenv('ROS_IP','192.168.1.104')
   setenv('ROS_MASTER_URI','http://192.168.1.142:11311')
   % Ip des ROS-Master-PCs 192.168.1.142
   rosinit('http://192.168.1.142:11311/')
end
    %% 
%--- Anmelden des Topics beim ROS-Master -----
    myPublisher = rospublisher ('/turtle1/cmd_vel', 'geometry_msgs/Twist');

%---  zunaechst leere Message in diesem Topic erzeugen -- 
    myMsg = rosmessage(myPublisher);
    
    for i=0:3        % 4 Ecken => 4mal ausfuehren
        disp(i)
        % 3m gereadeaus fahren
        %--- Message mit Daten fuellen ---
        myMsg.Linear.X = 3;
        %... und absenden
        send(myPublisher,myMsg);
        pause(3); % wait n seconds
        %---- 3 Sekunden diese Message ausfuehren ---
        
        %---- Message auf Null setzen, sonst beleibt der alte Wert
        myMsg.Linear.X = 0;
        send(myPublisher,myMsg);
        
        %----- 90-Grad Drehung - zeigesteuert ---
        myMsg.Angular.Z = pi/2;
        send(myPublisher,myMsg);
        
        pause(1); % wait n seconds
        myMsg.Angular.Z = 0.0;
        send(myPublisher,myMsg);
        
    end
    
