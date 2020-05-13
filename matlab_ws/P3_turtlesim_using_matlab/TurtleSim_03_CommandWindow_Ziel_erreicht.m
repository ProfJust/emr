%------------------------------------------------------------------
% TurtleSim_03_CommandWindow_Ziel_erreicht.m
% Die Turtle mit Konsolen-Befehlen im Matlab CommandWindow stuern
%------------------------------------------------------------------

% Wichtig: zunächst ROS-Node anmelden mit
% IP des ROS-Master-Rechners hier eintragen
% rosinit('http://192.168.2.150:11311','NodeName','/Acer')

%--- Anmelden des Topics beim ROS-Master -----
myPublisher = rospublisher ('turtle1/cmd_vel', 'geometry_msgs/Twist');
%youBot myPublisher = rospublisher ('cmd_vel', 'geometry_msgs/Twist');
% Subscriber anmelden
mySub = rossubscriber ('/turtle1/pose');
%---  zunächst leere Message in diesem Topic erzeugen --
myMsg = rosmessage(myPublisher);

%---- Globale Variablen ----
meter=0;
go = true;
var ='X';
dir ='Linear';
axisChar = 'x';
epsilon = 0.1;  % Umgebung der Soll_Position

while go == true
    eingabeRichtung  % -- Unterprozedur --
    if go==false 
        break;
    end
    
    fahrenRichtung % -- Unterprozedur --
    
    StartposeX = mySub.LatestMessage.X;
    StartposeY = mySub.LatestMessage.Y;
    StartposeTheta = mySub.LatestMessage.Theta;
    
    % ROS-Msg zum losfahren
    myMsg.(dir).(var)=speed;
    send(myPublisher,myMsg); % => ROS
    
    % Setze erste Pose für while- Bdg (matlab do..while vorhanden ??)
    poseX = StartposeX;
    poseY = StartposeY;
    poseTheta = StartposeTheta;
    
    switch axisChar
        case 'x'
               % --- epsilon Umgenung erreicht? -----
               sollX = StartposeX + meter *cos(poseTheta); 
             while ~((sollX <= poseX + epsilon) && (sollX >= poseX - epsilon))
                send(myPublisher,myMsg) % => ROS
                % muss wiederholt werden, sonst bleibt Turtle stehen
                poseX = mySub.LatestMessage.X
                poseY = mySub.LatestMessage.Y
                poseTheta = mySub.LatestMessage.Theta;  %Theta in PI
             end
             % Debug Ausgabe
                str = sprintf('X-Soll: %f X-Ist: %f', sollX, poseX);
                disp(str) 
             
             
        case 'y'
             disp('TurtleSim hat nicht in y-Richtung verfahren');
        case 'z'
            % Begrenzung auf den Bereich 0..2pi
            sollTheta = StartposeTheta + meter/180*pi()
            if sollTheta > 2* pi()
                sollTheta = sollTheta - 2* pi()
            end
           
            % --- epsilon Umgenung erreicht? -----
            while ~((sollTheta <= poseTheta + epsilon) && (sollTheta >= poseTheta - epsilon))
                send(myPublisher,myMsg) % => ROS
                % muss wiederholt werden, sonst bleibt Turtle stehen
                
                % Debug Ausgabe
                str = sprintf('Theta-Soll: %f Ist: %f', sollTheta, poseTheta);
                disp(str) 
                
                poseX = mySub.LatestMessage.X;
                poseY = mySub.LatestMessage.Y;
                poseTheta = mySub.LatestMessage.Theta;
               % pause(0.1);                              
            end
    end
   
    
    % ROS-Msg zum Anhalten (speed = 0)
    speed = 0;
    myMsg.(dir).(var)=speed; 
    send(myPublisher,myMsg); % => ROS
end
rosshutdown;







