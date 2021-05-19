% P6_2_Gazebo_youBot_Path_Planing_PurePursuit.m
% mit eigenem PurePursuit für den youBot
%--------------------------------------------------------------
% roslaunch emr_youbot youbot_emr_simulation_robocup2012.launch
%
% NICHT mit Offset starten, die Odometrie Pose stimmt sonst nicht mit der
% Map-Pose überein, youBot mit rqt drehen, rviz beenden
%--------------------------------------------------------------
% OJ fuer EMR am 18.6.2021, testted not OK
%-----------------------------------------------------------------------

%% Init
clear; %workspace
close all;
% Pure Pursuit
goalRadius = 0.2;
% Inflate by the radius given in number of Grid cells.
youBotRadiusGrid = 15;
% ROS
try
    rosnode list
catch exp   % Error from rosnode list
    rosinit
end
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');
pubVel  = rospublisher  ('cmd_vel', 'geometry_msgs/Twist');
msgsBaseVel = rosmessage(pubVel);

%% ---- Karte laden ----
disp('  KarteGazeboWorld.map laden und aufblasen ')
mapInflated = load('KarteGazeboWorld.mat');
% Aufblasen (inflate) der Map
% inflates each occupied position by the radius given in number of cells.
inflate(mapInflated.map,youBotRadiusGrid,'grid');
show(mapInflated.map)
hold on;

%% Find a path between the start and end location.
% ROS- Pose holen und als startLocation nutzen
posedata = receive(subOdom,10);
X = posedata.Pose.Pose.Position.X;
Y = posedata.Pose.Pose.Position.Y;
startLocation = [X Y];
yaw = yawFromPose(posedata);
initialOrientation = yaw;
fprintf('Start-Pose des youBots: %f %f %f\n',X, Y, yaw);
endLocation = [0.0 -4.0]
%     %Wieder zurueck in die Box
%      endLocation = [0.6 0.3];

%% --- PRM ---
% Create probabilistic roadmap path planner
prm = robotics.PRM(mapInflated.map);
prm.NumNodes = 100;
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
robotCurrentPose = [robotCurrentLocation initialOrientation];
distanceToGoal = norm(robotCurrentLocation - robotGoal);

%% -------------------------------------------------------------------
while(distanceToGoal > goalRadius )
    %% pose holen und speichern
    posedata = receive(subOdom,10);
    X = posedata.Pose.Pose.Position.X;
    Y = posedata.Pose.Pose.Position.Y;
    % Winkel berechnet sich aus den Quarternionen
    yaw = yawFromPose(posedata);
    % Compute the controller outputs, i.e., the inputs to the robot
    robotCurrentPose = [X, Y, yaw]
    %% #################  verbesserter PurePursuit ####################
    % alt [v, omega] = controller(robotCurrentPose);
    [v_x, v_y, omega] = step_PurePursuit_youbot(controller, robotCurrentPose);
    
    
    %% drive-youBot
    msgsBaseVel.Linear.X  = v_x;
    msgsBaseVel.Linear.Y  = v_y; % beim youBot auch y-Bewegung moeglich
    msgsBaseVel.Angular.Z = omega;
    send(pubVel ,msgsBaseVel)
    
    %% Re-compute the distance to the goal
    %%distanceToPoint = norm(robotCurrentPose(1:2) - path???)
    distanceToGoal = norm(robotCurrentPose(1:2) - robotGoal)
    %waitfor(controlRate);
end
disp('##### Ziel erreicht ####');

%% Robot Anhalten
msgsBaseVel.Linear.X=0;
msgsBaseVel.Linear.Y=0;
msgsBaseVel.Angular.Z=0;
send(pubVel,msgsBaseVel);


