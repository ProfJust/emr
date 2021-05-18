% P6_1_Gazebo_youBot_Path_Planing_DRM.m
% mit DRM-PurePursuit
%--------------------------------------------------------------
% Damit der youBot gut herausfindet:
%
% roslaunch emr_youbot robocup_at_work2012_offset.launch
%
% Achtung: Odometer des youBots kann nur per neulaunch resetet werden
%--------------------------------------------------------------
% OJ fuer EMR am 18.5.2021 , tested OK
%-----------------------------------------------------------------------

%% Init
    clear; %workspace
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
    
    % pose holen und speichern
        posedata = receive(subOdom,10);
        X = posedata.Pose.Pose.Position.X;
        Y = posedata.Pose.Pose.Position.Y;
        fprintf('Start-Pose des youBots: %f %f \n',X,Y);

%% ---- Karte laden ----
    mapInflated = load('KarteGazeboWorld.mat');
% Aufblasen (inflate) der Map
% inflates each occupied position by the radius given in number of cells.
    inflate(mapInflated.map,youBotRadiusGrid,'grid');
    show(mapInflated.map);
    hold on;

%% Find a path between the start and end location.
    startLocation = [X Y];
    initialOrientation = 0;
    endLocation = [3.0 -1.0];

%--- PRM ---
    prm = robotics.PRM(mapInflated.map);
    prm.NumNodes = 500;
    prm.ConnectionDistance = 20;
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
show( prm, 'Map', 'on', 'Roadmap', 'on');

%% Pfad folgen mit PurePursuit-Controller
    controller = robotics.PurePursuit;
    controller.DesiredLinearVelocity = 0.3;
    controller.MaxAngularVelocity = 0.5;  % was 0.8
    controller.LookaheadDistance = 1.0;
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
        myQuat = [ 
            posedata.Pose.Pose.Orientation.X...
            posedata.Pose.Pose.Orientation.Y...
            posedata.Pose.Pose.Orientation.Z...
            posedata.Pose.Pose.Orientation.W];
        eulZYX = quat2eul(myQuat);
        theta = eulZYX(3);
         
    % Compute the controller outputs, i.e., the inputs to the robot
        robotCurrentPose = [X, Y, theta]
        [v, omega] = controller(robotCurrentPose);
    
    % drive(robot, v, omega);
        msgsBaseVel.Linear.X  = v;
        msgsBaseVel.Angular.Z = omega;
        send(pubVel ,msgsBaseVel)
    
    % Re-compute the distance to the goal
        distanceToGoal = norm(robotCurrentPose(1:2) - robotGoal)
        %waitfor(controlRate);
end
disp('##### Ziel erreicht ####');

%% Robot Anhalten
    msgsBaseVel.Linear.X=0;
    msgsBaseVel.Angular.Z=0;
    send(pubVel,msgsBaseVel);

% Achtung: Odometer des youBots kann nur per neulaunch resetet werden
% oder per
% $rosservice call /gazebo/set_model_state '{model_state: { model_name: youbot, pose: { position: { x: 0.0, y: 0.0 ,z: 0.1 }, orientation: {x: 0.0, y: 0.0, z: 0.0, w: 0.0 } }, twist: { linear: {x: 0.0 , y: 0 ,z: 0 } , angular: { x: 0.0 , y: 0 , z: 0.0 } } , reference_frame: world } }'
% success: True
% status_message: "SetModelState: set model state done"
% check: rostopic echo -n 1 /gazebo/model_states

