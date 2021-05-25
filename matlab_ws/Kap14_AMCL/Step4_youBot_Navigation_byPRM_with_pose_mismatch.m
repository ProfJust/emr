% Step4_youBot_Navigation_byPRM.m
%---------------------------------------------------------------
% starten des zugehoerigen Launch-Skriptes fuer Gazebo:
% roslaunch emr_worlds youbot_arena.launch 
% 
%--------------------------------------------------------------
% 25.05.2021 jetzt wird auch der Unterschied zwischen AMCL-Pose
% und Odom-Pose gespeichert und mitberücksichtig (poseMismatch)
% => immer erst Step3, dann Step4
% ...oder
% Nach dem Gazebo Start mit youBot an Null-Position
% Variable in den Workspace eintragen, oder Step3 nutzen
% estimatedBasePose = [0.01   -0.012   -0.0073]
%---------------------------------------------------------------
%% -- ROS Init --
close all;
% Pure Pursuit
goalRadius = 0.3; % Ziel-Toleranz in Meter
% Inflate by the radius given in number of Grid cells.
youBotRadiusGrid = 9; %Aufblasen auf youBot-Breite default 15
% Matlab mit ROS - Master verbinden (wenn noch nicht geschehen)
try
    rosnode list
catch exp   % Error from rosnode list
    rosinit
end
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');
pubVel  = rospublisher  ('cmd_vel', 'geometry_msgs/Twist');
msgsBaseVel = rosmessage(pubVel);

%% ---- Karte laden ----
mapInflated = load('myArenaMap.mat');
% Aufblasen (inflate) der Map
disp('Inflate Map ...');
inflate(mapInflated.map,youBotRadiusGrid,'grid');
show(mapInflated.map);
grid minor;
grid on;
hold on;

%% --- aktuelle Odom_Pose holen vom ROS
posedata = receive(subOdom,10);
X = posedata.Pose.Pose.Position.X;
Y = posedata.Pose.Pose.Position.Y;
% Winkel berechnet sich aus den Quarternionen
yaw = yawFromPose(posedata);
% Compute the controller outputs, i.e., the inputs to the robot
robotCurrentOdomPose = [X, Y, yaw]

%% --- get AMCL-Pose Step3 from Workspace
disp('Nutze die AMCL-Pose aus Step 3 als Start-Pose');
% estimated Pose aus Step3 sollte im Workspace liegen
if not(exist('estimatedBasePose'))
    disp('Error: AMCL-Pose aus Step 3 liegt nicht im Workspace');
    return; % End this script
end
startLocation = [estimatedBasePose(1) estimatedBasePose(2)] % X,Y
initialOrientation = estimatedBasePose(3); % yaw

%% -- Differenz zwischen der Odometrie und AMCL merken
poseMismatch = [
    estimatedBasePose(1)-X...
    estimatedBasePose(2)-Y...
    wrapToPi(estimatedBasePose(3)-yaw)]  % 3x1
% clear estimatedBasePose; % delete from Workspace => Nur einmal korrekt

%% -- endLocation is choosen by user ginput()
  disp('Ziel mit Maus auf Karte waehlen');
  endLocation = ginput(1)

%% --- PRM - Weg finden ---
% Create probabilistic roadmap path planner
prm = robotics.PRM(mapInflated.map);
prm.NumNodes = 200;
prm.ConnectionDistance = 1;  % m?  was 20
disp('Suche PRM Pfad ...  (das kann etwas dauern)');

searching4path = true;
while searching4path
    path = findpath(prm, startLocation, endLocation);
    if isempty(path)
        disp('kein Pfad gefunden...');
        %Falls kein Pfad gefunden wurde nochmal mit 50 Pkt mehr
        prm.NumNodes = prm.NumNodes+50;
        prm.ConnectionDistance = prm.ConnectionDistance+0.2;
    else
        searching4path = false;
    end
end

% Roadmap zeigen
show( prm, 'Map', 'on', 'Roadmap', 'on');

%% Pfad folgen mit PurePursuit-Controller
controller = robotics.PurePursuit;
controller.DesiredLinearVelocity = 0.3;
controller.MaxAngularVelocity = 0.3;  % slower
controller.LookaheadDistance = 0.5;   % shorter
controller.Waypoints = path;

robotCurrentLocation = path(1,:);
robotGoal = path(end,:);
correctedBasePose = [robotCurrentLocation initialOrientation];
distanceToGoal = norm(robotCurrentLocation - robotGoal);
disp('Fahre PRM-Pfad ...');

%% ---------- Main- Loop -------------------------------------------------
while(distanceToGoal > goalRadius )
    %% pose holen und speichern
    posedata = receive(subOdom,10);
    X = posedata.Pose.Pose.Position.X;
    Y = posedata.Pose.Pose.Position.Y;
    % Winkel berechnet sich aus den Quarternionen
    yaw = yawFromPose(posedata);
    % Compute the controller outputs, i.e., the inputs to the robot
    robotCurrentOdomPose = [X Y yaw]  % 1x3
    correctedBasePose = robotCurrentOdomPose + poseMismatch  
    %% #################  verbesserter PurePursuit ####################
    % alt [v, omega] = controller(robotCurrentPose);
    [v_x, v_y, omega] = step_PurePursuit_youbot(controller, correctedBasePose);
    
    
    %% drive-youBot
    msgsBaseVel.Linear.X  = v_x;
    msgsBaseVel.Linear.Y  = v_y; % beim youBot auch y-Bewegung moeglich
    msgsBaseVel.Angular.Z = omega;
    send(pubVel ,msgsBaseVel)
    
    %% Re-compute the distance to the goal
    %%distanceToPoint = norm(robotCurrentPose(1:2) - path???)
    distanceToGoal = norm(correctedBasePose(1:2) - robotGoal)
    %waitfor(controlRate);
end

%% --- Finally --
disp('##### Ziel erreicht ####');
disp(correctedBasePose);
% Robot Anhalten
msgsBaseVel.Linear.X=0;
msgsBaseVel.Linear.Y=0;
msgsBaseVel.Angular.Z=0;
send(pubVel,msgsBaseVel);
