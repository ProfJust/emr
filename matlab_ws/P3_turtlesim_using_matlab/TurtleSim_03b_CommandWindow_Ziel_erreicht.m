%------------------------------------------------------------------
% TurtleSim_03b_CommandWindow_Ziel_erreicht.m
%
% Die Turtle mit Konsolen-Befehlen im Matlab CommandWindow steuern
%------------------------------------------------------------------
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
meter=0;
go = true;
var ='X';
dir ='Linear';
axisChar = 'x';
epsilon = 0.1;  % Umgebung der Soll_Position

%%
while 1
    % Hole Benutzereingabe
    [speed, way, dir, movement] = EingabeTurtleCommand();
    if dir =='Q'
        disp("Beende Skript ");
        return;
    end
    
    StartposeX = mySub.LatestMessage.X;
    StartposeY = mySub.LatestMessage.Y;
    StartposeTheta = mySub.LatestMessage.Theta;
    
    % ROS-Msg zum losfahren
    myMsg.(movement).(dir)=speed;
    send(myPublisher,myMsg); % => ROS
    
    % Setze erste Pose für while- Bdg (matlab do..while vorhanden ??)
    poseX = StartposeX;
    poseY = StartposeY;
    poseTheta = StartposeTheta;
    
    switch dir
        case 'X'
            % --- epsilon Umgenung erreicht? -----
            sollX = StartposeX + way *cos(poseTheta);
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
            
        case 'Y'
            disp('TurtleSim kann nicht in y-Richtung verfahren');
            
        case 'Z'
            % Begrenzung auf den Bereich 0..2pi
            sollTheta = StartposeTheta + way/180*pi()
            if sollTheta > pi()
                sollTheta = sollTheta - 2* pi()
            end
            if sollTheta < -pi()
                sollTheta = sollTheta + 2* pi()
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
    myMsg.(movement).(dir)=speed;
    send(myPublisher,myMsg); % => ROS
end








