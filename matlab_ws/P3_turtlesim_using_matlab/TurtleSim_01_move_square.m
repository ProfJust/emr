%% TurtleSim_01.m
% TurtleSim ansteuern um ein Quadrat zu fahren
% zeitgesteuert
% EMR - Version vom 13.05.2020 - gitHub
%-------------------------------------

ROS_Node_init_localhost;

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
    
