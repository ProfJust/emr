%---------------------------------------------------------
% TurtleSim_03a_CommandWindow_zeitgesteuert.m
% Die Turtle mit Eingaben im Matlab CommandWindow steuern
% zeitgesteuert
% --------------------------------------------------------
% Nutzt die Funktionen ROS_Node_init_localhost
% EingabeTurtleCommand() und move4Time()
%---------------------------------------------------------
% EMR - 13.5.2020
%---------------------------------------------------------

ROS_Node_init_localhost;

%%
% ---- Subscriber anmelden ----
    mySub = rossubscriber ('/turtle1/pose');
%--- Publisher Anmelden -----
    myPublisher = rospublisher ('turtle1/cmd_vel', 'geometry_msgs/Twist');
%---  zunächst leere Message von diesem Typ/Topic erzeugen --
    myMsg = rosmessage(myPublisher);

%---- Globale Variablen ----
% way=0;
% dir ='X';
% movement ='Linear';
% axisChar = 'x';

while 1
    % Hole Benutzereingabe
    [speed, way, dir, movement] = EingabeTurtleCommand(); 
    if dir =='Q'
        disp("Beende Skript ");
        return;
    end
        
    % Fahren für berechnete Zeit
    goTime = move4Time(speed, way, dir);  
    tic;  %starte Zeitmessung
    
    while (toc <= goTime) %hole Zeit => toc
        % ROS-Msg zum losfahren
        myMsg.(movement).(dir)=speed;
        send(myPublisher,myMsg); % => ROS
    end
    
   
    
    % ROS-Msg zum Anhalten (speed = 0)
    speed = 0;
    myMsg.(movement).(dir)=speed;
    send(myPublisher,myMsg); % => ROS
end








