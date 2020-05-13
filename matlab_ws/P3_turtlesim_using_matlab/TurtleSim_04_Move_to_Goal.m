%------------------------------------------------------------------
% TurtleSim_04_Move_to_Goal.m
% Die Turtle mit Konsolen-Befehlen im Matlab CommandWindow steuern
% Bewegt sich zu einem Ziel in Weltkoordinaten
%------------------------------------------------------------------

% Wichtig: zunächst ROS-Node anmelden mit
% IP des ROS-Master-Rechners hier eintragen
rosinit('http://192.168.2.150:11311','NodeName','/Acer')

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

epsilon = 0.1;  % Umgebung der Soll_Position


%Proc_getGoal % -- Unterprozedur --
goalX = str2double(input('Ziel X: ','s')); % Benutzereingabe
goalY = str2double(input('Ziel Y: ','s')); % Benutzereingabe
%goalTheta = input('Ziel Theta','s'); % Benutzereingabe

startX = mySub.LatestMessage.X;
startY = mySub.LatestMessage.Y;
startTheta = mySub.LatestMessage.Theta;
%
distX = goalX - startX;
distY = goalY - startY;
% Richtung bestimmen
sollTheta = atan2(distY, distX)
sollWeg = sqrt(distX^2 + distY^2)
% Begrenzung auf den Bereich 0..2pi
if sollTheta > 2* pi()
    sollTheta = sollTheta - 2* pi()
end
if sollTheta < 0
    sollTheta = sollTheta + 2* pi()
end


% ------------ Drehung -------------------
var='Z';
dir='Angular';
speed = 0.3;
% ROS-Msg zum losfahren
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS
poseTheta = mySub.LatestMessage.Theta;

% --- epsilon Umgenung erreicht? -----
while ~((sollTheta <= poseTheta + epsilon) && (sollTheta >= poseTheta - epsilon))
    send(myPublisher,myMsg) % => ROS
    % Debug Ausgabe
      str = sprintf('sollTheta: %f poseTheta: %f poseX: %f poseY: %f', sollTheta, poseTheta);
    disp(str)
    poseTheta = mySub.LatestMessage.Theta;
    % pause(0.1);
end

% ROS-Msg zum Anhalten (speed = 0)
speed = 0;
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS

% ------------ X-Fahrt -------------------
var='X';
dir='Linear';
speed = 0.3;
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS
poseX = mySub.LatestMessage.X;
% --- epsilon Umgenung erreicht? -----
while ~((goalX <= poseX + epsilon) && (goalX >= poseX - epsilon))
    send(myPublisher,myMsg) % => ROS
    % muss wiederholt werden, sonst bleibt Turtle stehen
    poseX = mySub.LatestMessage.X;
    poseY = mySub.LatestMessage.Y;
    % Debug Ausgabe
     str = sprintf('goalX: %f goalY: %f poseX: %f poseY: %f', goalX, goalY, poseX, poseY);
    disp(str)
end

% ROS-Msg zum Anhalten (speed = 0)
speed = 0;
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS

% ----- 2.Stufe zur Erhöhung der Zielgenauigkeit
startX = mySub.LatestMessage.X;
startY = mySub.LatestMessage.Y;
startTheta = mySub.LatestMessage.Theta;
%
distX = goalX - startX;
distY = goalY - startY;
% Richtung bestimmen
sollTheta = atan2(distY, distX)
sollWeg = sqrt(distX^2 + distY^2)
% Begrenzung auf den Bereich 0..2pi
if sollTheta > 2* pi()
    sollTheta = sollTheta - 2* pi()
end
if sollTheta < 0
    sollTheta = sollTheta + 2* pi()
end

%Turtle_Drehung % Prozedur 
% ------------ Drehung -------------------
var='Z';
dir='Angular';
speed = 0.5;
% ROS-Msg zum losfahren
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS
poseTheta = mySub.LatestMessage.Theta;

% --- epsilon Umgenung erreicht? -----
while ~((sollTheta <= poseTheta + epsilon) && (sollTheta >= poseTheta - epsilon))
    send(myPublisher,myMsg) % => ROS
    % Debug Ausgabe
    str = sprintf('sollTheta: %f poseTheta: %f poseX: %f poseY: %f', sollTheta, poseTheta);
    disp(str)
    poseTheta = mySub.LatestMessage.Theta;
    % pause(0.1);
end

% ROS-Msg zum Anhalten (speed = 0)
speed = 0;
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS

% ------------ Y-Fahrt -------------------
var='X';
dir='Linear';
speed = 0.5;
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS
poseY = mySub.LatestMessage.Y;
% --- epsilon Umgenung erreicht? -----
while ~((goalY <= poseY + epsilon) && (goalY >= poseY - epsilon))
    send(myPublisher,myMsg) % => ROS
    % muss wiederholt werden, sonst bleibt Turtle stehen
    poseX = mySub.LatestMessage.X;
    poseY = mySub.LatestMessage.Y;
    % Debug Ausgabe
     str = sprintf('goalX: %f goalY: %f poseX: %f poseY: %f', goalX, goalY, poseX, poseY);
    disp(str)
end

% ROS-Msg zum Anhalten (speed = 0)
speed = 0;
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS

% Debug Ausgabe
    str = sprintf('goalX: %f goalY: %f poseX: %f poseY: %f', goalX, goalY, poseX, poseY);
    disp(str)


rosshutdown;







