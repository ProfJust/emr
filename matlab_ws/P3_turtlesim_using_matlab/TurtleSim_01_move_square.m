%% TurtleSim_01.m
% TurtleSim ansteuern um ein Quadrat zu fahren
% zeitgesteuert
% EMR - Version vom 27.04.2021 - gitHub
%-------------------------------------
% !! Das hier funktioniert leider nicht !!
% system('roscore')
% system('rosrun turtlesim turtlesim_node')
% system("gnome-terminal -- 'rosrun turtlesim turtlesim_node'")
% https://answers.ros.org/question/255008/roslaunch-on-matlab/
% system(['export LD_LIBRARY_PATH="LD_path";' 'roslaunch turtlesim_shell.launch &']);
% system(['export LD_LIBRARY_PATH="LD_path";' 'roslaunch turtlesim_shell.launch & echo $!']);

ROS_init_MatlabNode;
disp 'Did you start rosrun turtlesim turtlesim_node ?'
disp '$ rosrun turtlesim turtlesim_node'

    %% 
%--- Anmelden des Topics beim ROS-Master -----
    myPublisher = rospublisher ('turtle1/cmd_vel', 'geometry_msgs/Twist');

%---  zunaechst leere Message in diesem Topic erzeugen -- 
    myMsg = rosmessage(myPublisher);
    
    for i=0:3        % 4 Ecken => 4mal ausfuehren
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
    
