%sw06_Gazebo_youBot_Pfad_mit_PRM_und_youBotPurePursuit.m
%---------------------------------------------------------------
rosshutdown;
clear; %workspace
%rosinit('http://192.168.2.108:11311','NodeName','/RoboLabHome')
rosinit('http://127.0.0.1:11311','NodeName','/MatLabHome')
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');
pubVel  = rospublisher  ('cmd_vel', 'geometry_msgs/Twist');
msgsBaseVel = rosmessage(pubVel);

%---- Karte laden ----
mapInflated = load('KarteGazeboWorld.mat');
% Aufblasen (inflate) der Map
youBotRadiusGrid = 15; %Aufblasen auf youBot-Breite default 15
% inflates each occupied position by the radius given in number of cells.
inflate(mapInflated.map,youBotRadiusGrid,'grid');
show(mapInflated.map);
hold on;
%Find a path between the start and end location.
startLocation = [0.0 0.0];
initialOrientation =0;
endLocation = [3.0 -1.0];

%--- PRM ---
prm = robotics.PRM(mapInflated.map);
prm.NumNodes = 500;
prm.ConnectionDistance = 20;
disp('Suche Pfad mit PRM... das kann etwas dauern');
path = findpath(prm, startLocation, endLocation);

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
controller.DesiredLinearVelocity = 0.3;
controller.MaxAngularVelocity = 0.3;
controller.LookaheadDistance = 0.5;
controller.Waypoints = path;

robotCurrentLocation = path(1,:);
robotGoal = path(end,:);
robotCurrentPose = [robotCurrentLocation initialOrientation];
distanceToGoal = norm(robotCurrentLocation - robotGoal);
goalRadius = 0.2;

%-------------------------------------------------------------------
while( distanceToGoal > goalRadius )
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
    %#################  verbesserter PurePursuit ####################
    [v_x, v_y, omega] = step_PurePursuit_youbot(controller, robotCurrentPose);
    fprintf('%f %f %f \n',v_x, v_y, omega); 
        
    % Simulate the robot using the controller outputs
    % drive(robot, v, omega);
    msgsBaseVel.Linear.X  = v_x;
    msgsBaseVel.Linear.Y  = v_y;
    msgsBaseVel.Angular.Z = omega;
    send(pubVel ,msgsBaseVel)
    
    % Extract current location information from the current pose
    %robotCurrentPose = robot.getRobotPose;
    robotCurrentPose = [X, Y, theta]
    
    % Re-compute the distance to the goal
    distanceToGoal = norm(robotCurrentPose(1:2) - robotGoal);
    %waitfor(controlRate);
end
disp('##### Ziel erreicht ####');
%Robot Anhalten
msgsBaseVel.Linear.X=0;
msgsBaseVel.Linear.Y=0;
msgsBaseVel.Angular.Z=0;
send(pubVel,msgsBaseVel);



