%MatlabExample_Using_the_path_following_controller_along_with_PRM.m
%file:///D:/Program%20Files/MATLAB/R2016b/help/robotics/examples/path-following-for-a-differential-drive-robot.html
%---------------------------------------------------------------
%roslaunch youbot_gazebo_robot youbot_new_pose.launch
rosshutdown;
clear;
%rosinit('http://192.168.2.128:11311','NodeName','/RoboLabHome')
rosinit('http://127.0.0.1:11311','NodeName','/MatLabHome')
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');
pubVel  = rospublisher  ('cmd_vel', 'geometry_msgs/Twist');
msgsBaseVel = rosmessage(pubVel);

%---- Karte laden ----
mapInflated = load('KarteGazeboWorld.mat');
% Aufblasen (inflate) der Map
youBotRadiusGrid = 15; %Aufblasen auf youBot-Breite
% inflates each occupied position by the radius given in number of cells.
inflate(mapInflated.map,youBotRadiusGrid,'grid');
show(mapInflated.map);
hold on;
%Find a path between the start and end location.
startLocation = [1.0 0.0];
initialOrientation = 1;
endLocation = [3.0 -1.0];

%--- PRM ---
prm = robotics.PRM(mapInflated.map);
prm.NumNodes = 500;
prm.ConnectionDistance = 25;
%while isempty(path)      
    %Falls kein Pfad gefunden wurde nochmal
    path = findpath(prm, startLocation, endLocation);
%     if isempty(path)
%         %--- PRM ---
%        % prm = robotics.PRM(mapInflated.map);
%         prm.NumNodes = prm.NumNodes+100;
%         prm.ConnectionDistance = prm.ConnectionDistance+5;
%     end
%end
show( prm, 'Map', 'on', 'Roadmap', 'on');

%Pfad folgen mit PurePursuit-Controller
controller = robotics.PurePursuit;
controller.DesiredLinearVelocity = 0.3;
controller.MaxAngularVelocity = 0.8;
controller.LookaheadDistance = 1.0;
controller.Waypoints = path;

robotCurrentLocation = path(1,:);
robotGoal = path(end,:);
robotCurrentPose = [robotCurrentLocation initialOrientation];
distanceToGoal = norm(robotCurrentLocation - robotGoal);
goalRadius = 0.2;

%reset(controlRate);
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
    [v, omega] = controller(robotCurrentPose)
    
    % Simulate the robot using the controller outputs
    % drive(robot, v, omega);
    msgsBaseVel.Linear.X  = v;
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
msgsBaseVel.Angular.Z=0;
send(pubVel,msgsBaseVel);



