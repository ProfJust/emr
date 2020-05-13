%------------------------------------------------------------------
% TurtleSim_05_Move_to_Goal_P_Glied.m
% Die Turtle mit Konsolen-Befehlen im Matlab CommandWindow steuern
% Bewegt sich zu einem Ziel in Weltkoordinaten
%------------------------------------------------------------------

% Wichtig: zun�chst ROS-Node anmelden mit
% IP des ROS-Master-Rechners hier eintragen
rosshutdown;
rosinit('http://127.0.0.1:11311','NodeName','/Acer')
% B�ro WHS - Windows PC rosinit('http://WHS-B5-0-09:11311/','NodeName','/Acer')

%--- Anmelden des Topics beim ROS-Master -----
myPublisher = rospublisher ('turtle1/cmd_vel', 'geometry_msgs/Twist');
% Subscriber anmelden
mySub = rossubscriber ('/turtle1/pose');
%---  zun�chst leere Message in diesem Topic erzeugen --
myMsg = rosmessage(myPublisher);

%---- Globale Variablen ----
epsilon = 0.1;  % Umgebung der Soll_Position
moveFlag = true; % Turtle in Bewegung?
Kx = 0.4; % Proportionalkonstante vx = Kv * Abstand
Kz = 2.0; % Proportionalkonstante vz = Kz * distTheta
%---- Get Goal from User ----
goalX = str2double(input('Ziel X: ','s')); % Benutzereingabe
goalY = str2double(input('Ziel Y: ','s')); % Benutzereingabe

%--- Move to Goal ----
while (moveFlag)
    %--- aktuelle Pose empfangen ---
    poseX     = mySub.LatestMessage.X;
    poseY     = mySub.LatestMessage.Y;
    poseTheta = mySub.LatestMessage.Theta;
    
    %---- Richtung bestimmen ---
    distX = goalX - poseX; %Strecke zum Ziel X-Anteil
    distY = goalY - poseY; %Strecke zum Ziel Y-Anteil
    distS = sqrt(distX^2 + distY^2); %Strecke zum Ziel
    sollTheta = atan2(distY, distX); %-pi ..pi
    distTheta = sollTheta - poseTheta;
    %---- Fahrbefehl senden ----
    % Geschwindigkeit Proportional abh�ngig vom Abstand zum Ziel
    myMsg.Linear.X  = Kx * distS; %turtleSpeed;
    myMsg.Angular.Z = Kz * distTheta;
    send(myPublisher,myMsg); % => ROS
    % Debug Ausgabe
    fprintf('Strecke zum Ziel: distX %f distY %f distTheta %f \n', distX, distY, sollTheta - poseTheta);
    
    %---- Ziel erreicht??? ---
    if(distS <epsilon)
        moveFlag = false;
    end
end
%---- Fahrbefehl zum Anhalten senden ----
myMsg.Linear.X = 0;
myMsg.Angular.Z = 0;
send(myPublisher,myMsg); % => ROS

%---- Debug Ausgabe -----
fprintf('Ziel erreicht!   goalX: %f goalY: %f poseX: %f poseY: %f \n', goalX, goalY, poseX, poseY);








