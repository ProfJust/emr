%P7_03_Gazebo_youBot_PRM_PurePursuitSpezial_SS18.m
%file:///D:/Program%20Files/MATLAB/R2016b/help/robotics/examples/path-following-for-a-differential-drive-robot.html
%---------------------------------------------------------------
% starten des zugehoerigen Python-Skriptes fuer Gazebo:
% roslaunch youbot_gazebo_robot youbot.launch
% .d.h. youBot ohne Offset in Gazebo - Willow Garage
%--------------------------------------------------------------
% 24.06.2019
%---------------------------------------------------------------
rosshutdown;
%OJ HomeOffice
rosinit('http://192.168.1.142:11311','NodeName','/RoboLabHome')
%WHS
%rosinit('http://192.168.0.99:11311','NodeName','/MatLabHome')
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');
pubVel  = rospublisher  ('cmd_vel', 'geometry_msgs/Twist');
msgsBaseVel = rosmessage(pubVel);

%---- Karte laden ----
mapInflated = load('WillowGarageOccupancyGrid_GIMP.mat');
% Aufblasen (inflate) der Map
youBotRadiusGrid = 11; %Aufblasen auf youBot-Breite default 15
% inflates each occupied position by the radius given in number of cells.
inflate(mapInflated.map,youBotRadiusGrid,'grid');
show(mapInflated.map);
hold on;
%Find a path between the start and end location.
 posedata_quat = receive(subOdom,10);
% pose in Euler umrechnen (mit Versatz)
 estimatedPose = youBot_Pose_Quat_2_Eul(posedata_quat);
if not(exist('estimatedPose'))
    estimatedPose = [0 0 0];
end
startLocation = [estimatedPose(1) estimatedPose(2)]
initialOrientation = estimatedPose(3);

%-- endLocation is choosen by user
  disp('Ziel mit Maus auf Karte waehlen');
  endLocation = ginput(1)

%--- PRM ---
prm = robotics.PRM(mapInflated.map);
prm.NumNodes = 500;
prm.ConnectionDistance = 30;
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
goalRadius = 0.6;
disp('Fahre PRM-Pfad ...');
%-------------------------------------------------------------------
while( distanceToGoal > goalRadius )
    % pose holen und speichern
     posedata_quat = receive(subOdom,10);
     % pose in Euler umrechnen (mit Versatz)
     robotCurrentPose = youBot_Pose_Quat_2_Eul(posedata_quat);
    % Compute the controller outputs, i.e., the inputs to the robot
    %[v, omega] = controller(robot.getRobotPose);
    %#################  verbesserter PurePursuit ####################
    [v_x, v_y, omega] = step_PurePursuit_youbot(controller, robotCurrentPose);
    
    % Simulate the robot using the controller outputs
    % drive(robot, v, omega);
    msgsBaseVel.Linear.X  = v_x;
    msgsBaseVel.Linear.Y  = v_y;
    msgsBaseVel.Angular.Z = omega;
    send(pubVel ,msgsBaseVel)    
    % Re-compute the distance to the goal
    distanceToGoal = norm(robotCurrentPose(1:2) - robotGoal)
end

disp('##### Ziel erreicht ####');
disp(robotCurrentPose);
estimatedPose = robotCurrentPose;
%Robot Anhalten
msgsBaseVel.Linear.X=0;
msgsBaseVel.Linear.Y=0;
msgsBaseVel.Angular.Z=0;
send(pubVel,msgsBaseVel);