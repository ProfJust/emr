% TurtleSim_01.m
% TurtleSim ansteuern
% EMR - Version vom 13.05.2020 - gitHub
%-------------------------------------


% --- Start Matlab Global Node  => nur wenn es ihn nicht schon gibt
% => rosnode list gibt Fehler aus
try
    rosnode list
catch exp   % Error from rosnode list
    rosinit  % only if error: rosinit
end
% ....

%--- Anmelden des Topics beim ROS-Master -----
    myPublisher = rospublisher ('turtle1/cmd_vel', 'geometry_msgs/Twist');

%---  zunaechst leere Message in diesem Topic erzeugen -- 
    myMsg = rosmessage(myPublisher);

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

%--- 3 Geradeaus  - zeigesteuert ---
    myMsg.Linear.X = 3;
    send(myPublisher,myMsg);
    pause(3); % wait n seconds 
    myMsg.Linear.X = 0;
    send(myPublisher,myMsg);

%----- 90 Grad Drehung ---
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

%----- 90 Grad Drehung ---
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

%----- 90 Grad Drehung ---
    myMsg.Angular.Z = pi/2;
    send(myPublisher,myMsg);
    pause(1); % wait n seconds 
    myMsg.Angular.Z = 0.0;
    send(myPublisher,myMsg);

pause(5);
