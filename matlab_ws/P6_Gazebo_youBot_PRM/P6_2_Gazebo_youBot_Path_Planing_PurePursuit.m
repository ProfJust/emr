% P6_2_Gazebo_youBot_Path_Planing_PurePursuit.m
% mit eigenem PurePursuit für den youBot
%--------------------------------------------------------------
%roslaunch emr_youbot robocup_at_work_2012_offset.launch
%--------------------------------------------------------------
% OJ fuer EMR am 1.6.2020, testted OK
%-----------------------------------------------------------------------

%% Init
    clear; %workspace
    close all;
% Pure Pursuit 
    goalRadius = 0.2; 
% Inflate by the radius given in number of Grid cells.
    youBotRadiusGrid = 15;
% ROS
    ROS_Node_init_localhost;
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
    initialOrientation = 0;
%    endLocation = [3.0 0.1];

%     %Wieder zurueck in die Box
      endLocation = [0.6 0.3];

%--- PRM ---
    prm = robotics.PRM(mapInflated.map);
    prm.NumNodes = 500;
    prm.ConnectionDistance = 20;
    disp('Suche PRM Pfad ...  (das kann etwas dauern)');
    path = findpath(prm, startLocation, endLocation);
    
while isempty(path)      
    disp('kein Pfad gefunden...');
    %Falls kein Pfad gefunden wurde nochmal mit 100 Pkt mehr
    prm.NumNodes = prm.NumNodes+100;
    prm.ConnectionDistance = prm.ConnectionDistance+5;
    prm = robotics.PRM(mapInflated.map);
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
    % pose holen und speichern
        posedata = receive(subOdom,10);
        X = posedata.Pose.Pose.Position.X;
        Y = posedata.Pose.Pose.Position.Y;
    % Winkel berechnet sich aus den Quarternionen
    % pose als Quaternion speichern
        myQuat = [ posedata.Pose.Pose.Orientation.X posedata.Pose.Pose.Orientation.Y posedata.Pose.Pose.Orientation.Z posedata.Pose.Pose.Orientation.W];
        eulZYX = quat2eul(myQuat);
        theta = eulZYX(3);
         
    % Compute the controller outputs, i.e., the inputs to the robot
        robotCurrentPose = [X, Y, theta]
     %#################  verbesserter PurePursuit ####################
        % alt [v, omega] = controller(robotCurrentPose);
        [v_x, v_y, omega] = step_PurePursuit_youbot(controller, robotCurrentPose);
       
    
    % drive-youBot 
       msgsBaseVel.Linear.X  = v_x;
       msgsBaseVel.Linear.Y  = v_y; % beim youBot auch y-Bewegung moeglich
       msgsBaseVel.Angular.Z = omega;
       send(pubVel ,msgsBaseVel)
    
    % Re-compute the distance to the goal
        distanceToGoal = norm(robotCurrentPose(1:2) - robotGoal)
        %waitfor(controlRate);
end
disp('##### Ziel erreicht ####');

%% Robot Anhalten
    msgsBaseVel.Linear.X=0;
    msgsBaseVel.Linear.Y=0;
    msgsBaseVel.Angular.Z=0;
    send(pubVel,msgsBaseVel);


