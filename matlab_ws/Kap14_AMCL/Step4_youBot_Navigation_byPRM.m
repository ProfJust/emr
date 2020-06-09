% Step4_youBot_Navigation_byPRM.m
%---------------------------------------------------------------
% starten des zugehoerigen Launch-Skriptes fuer Gazebo:
% roslaunch emr_worlds youbot_arena.launch 
% .d.h. youBot in der Arena des Robotik-Labors
%--------------------------------------------------------------
% 9.06.2020
%---------------------------------------------------------------
%% -- ROS Init --
ROS_Node_init_localhost;
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');
pubVel  = rospublisher  ('cmd_vel', 'geometry_msgs/Twist');
msgsBaseVel = rosmessage(pubVel);

%% ---- Karte laden ----
goalRadius = 0.5;
mapInflated = load('myArenaMap.mat');
% Aufblasen (inflate) der Map
youBotRadiusGrid = 9; %Aufblasen auf youBot-Breite default 15
disp('Inflate Map ...');
inflate(mapInflated.map,youBotRadiusGrid,'grid');
show(mapInflated.map);
hold on;
% Find a path between the start and end location.
 posedata_quat = receive(subOdom,10);
% pose in Euler umrechnen (mit Versatz)
% estimated Pose aus Step3 liegt im Workspace
estimatedPose = youBot_Pose_Quat_2_Eul(posedata_quat); %ohne Versatz rechnen !!
if not(exist('estimatedPose'))
    estimatedPose = [0 0 0];
end
startLocation = [estimatedPose(1) estimatedPose(2)] % X,Y
initialOrientation = estimatedPose(3); % Z

%% -- endLocation is choosen by user
  disp('Ziel mit Maus auf Karte waehlen');
  endLocation = ginput(1)

%% --- PRM ---
prm = robotics.PRM(mapInflated.map);
prm.NumNodes = 500;
prm.ConnectionDistance = 10;
disp('Suche PRM-Pfad ...');
path = findpath(prm, startLocation, endLocation)

if isempty(path)      
    disp('kein Pfad gefunden...');
    %Falls kein Pfad gefunden wurde nochmal
       prm.NumNodes = prm.NumNodes+100;
       prm.ConnectionDistance = prm.ConnectionDistance+5;
       prm = robotics.PRM(mapInflated.map);
end
show( prm, 'Map', 'on', 'Roadmap', 'on');
%Pfad folgen mit PurePursuit-Controller
controller = robotics.PurePursuit;
controller.DesiredLinearVelocity = 0.5;
controller.MaxAngularVelocity = 0.4;
controller.LookaheadDistance = 0.5;
controller.Waypoints = path;

robotCurrentLocation = path(1,:);
robotGoal = path(end,:);
robotCurrentPose = [robotCurrentLocation initialOrientation];
distanceToGoal = norm(robotCurrentLocation - robotGoal);

disp('Fahre PRM-Pfad ...');

%% -------------------------------------------------------------------
while( distanceToGoal > goalRadius )
    % pose holen und speichern
     posedata_quat = receive(subOdom,10);
     % pose in Euler umrechnen (mit Versatz)
     robotCurrentPose = youBot_Pose_Quat_2_Eul(posedata_quat);
    % Compute the controller outputs, i.e., the inputs to the robot
     [v_x, v_y, omega] = step_PurePursuit_youbot(controller, robotCurrentPose);
    
    % Drive the robot using the controller outputs
    msgsBaseVel.Linear.X  = v_x;
    msgsBaseVel.Linear.Y  = v_y;
    msgsBaseVel.Angular.Z = omega;
    send(pubVel ,msgsBaseVel)    
    % Re-compute the distance to the goal
    distanceToGoal = norm(robotCurrentPose(1:2) - robotGoal)
end

%% --- Finally --
disp('##### Ziel erreicht ####');
disp(robotCurrentPose);
estimatedPose = robotCurrentPose;
beep
%Robot Anhalten
msgsBaseVel.Linear.X=0;
msgsBaseVel.Linear.Y=0;
msgsBaseVel.Angular.Z=0;
send(pubVel,msgsBaseVel);