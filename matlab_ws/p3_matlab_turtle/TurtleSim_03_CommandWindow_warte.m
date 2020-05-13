%------------------------------------------------------------------
% TurtleSim_03a_CommandWindow.m
% Die Turtle mit Konsolen-Befehlen im Matlab CommandWindow stuern
%------------------------------------------------------------------

% Wichtig: zunächst ROS-Node anmelden mit
% IP des ROS-Master-Rechners hier eintragen
rosinit('http://192.168.2.150:11311','NodeName','/Acer')

%--- Anmelden des Topics beim ROS-Master -----
myPublisher = rospublisher ('turtle1/cmd_vel', 'geometry_msgs/Twist');
%youBot myPublisher = rospublisher ('cmd_vel', 'geometry_msgs/Twist');

%---  zunächst leere Message in diesem Topic erzeugen --
myMsg = rosmessage(myPublisher);

%---- Globale Variablen ----
meter=0;
go = true;
var ='X';
dir ='Linear';
axisChar = 'x';

while go == true
    eingabeRichtung  % -- Unterprozedur --
    if go==false 
        break;
    end
    
    fahrenRichtung % -- Unterprozedur --
    
    % ROS-Msg zum losfahren
    myMsg.(dir).(var)=speed;
    send(myPublisher,myMsg); % => ROS
    
    warten % -- Unterprozedur --
    
    % ROS-Msg zum Anhalten (speed = 0)
    speed = 0;
    myMsg.(dir).(var)=speed; 
    send(myPublisher,myMsg); % => ROS
end
rosshutdown;







