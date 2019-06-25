%%  AUTONOMOUS NAVIGATION OF YOUBOT by AMCL
% Step3_youBot_Navigation_byAMCL.m


%   The following programm navigates the youBot to a X-Y-position
%   provided by the user. It is using a modified PurePursuit path tracking
%   algorithm and Probabilistic Roadmaps (PRM). In order to avoid obstacle
%   contact, the map is inflated before operation. Furthermore, the
%   position of the robot is constantly estimated through the Monte Carlo
%   Localisation algorithm. The map is plotted along with the position of
%   the youBot and its path to the provided goal location.
%   The procedure can be repeated until termination by user.
%
% Authors of this script:  Marcel Bohnenkamp,  Marcel Herzig, Tobias Wewers
%
% Documentation:    <Map preparation>           https://goo.gl/Zdsmuh
%                   <Map preparation>           https://goo.gl/PbDbC7
%                   <Monte Carlo Localization>  https://goo.gl/uRTDrm
%                   <Monte Carlo Localization>  https://goo.gl/5EA8Sf
%                   <Path building>             https://goo.gl/dufP4a
%                   <Path building>             https://goo.gl/ERKiZ9
%                   <Controller>                https://goo.gl/8tXWVU
%                   <Controller>                https://goo.gl/sMLcjE
%
%
%------------------------------------------
%Version vom 24.06.2019 edited by OJ
%------------------------------------------
%% ROS INITIALIZATION - Subscriber | Publisher
%rosshutdown;
close all; %figures
clear; %workspace
%OJ HomeOffice
%Lokal
if robotics.ros.internal.Global.isNodeActive == false
    rosinit('http://127.0.0.1:11311','NodeName','/RoboLabHome')
end
%robotik.bocholt@w-hs.de
%rosinit('http://192.168.0.99:11311','NodeName','/MatLabHome')
%-- ROS Subscriber --
tic;
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');
%subScan = rossubscriber('scan','sensor_msgs/LaserScan');
subScan = rossubscriber('base_scan','sensor_msgs/LaserScan');
% Publisher
pubVel = rospublisher ('cmd_vel', 'geometry_msgs/Twist');
msgsBaseVel = rosmessage(pubVel);

%% MONTE CARLO LOCALIZATION (MCL) - Algorithm
%MCL - https://de.mathworks.com/help/robotics/examples/localize-turtlebot-using-monte-carlo-localization.html
%usedMapName = 'WillowGarageOccupancyGrid2.mat'
usedMapName ='WillowGarageOccupancyGrid_GIMP.mat'
mapOccGrid = load(usedMapName);
%show(mapOccGrid.map);
% Check whether mapInflated is already available
if exist('mapInflated','var')
    disp('## Map is up to date ##');
else
    disp('## Map Inflation ##');
    tic;
    %Define youBotSize
    youbotRadiusGrid = 3; % 33;
    %MAP File laden
    mapInflated = load(usedMapName);
    %Inflate to avoid obstacles
    inflate(mapInflated.map,youbotRadiusGrid,'grid');
    %Randomly generate NODES
    prm = robotics.PRM(mapInflated.map);
    prm.NumNodes = 214; % number of nodes
    prm.ConnectionDistance = 1; % in meters
    %disp('## Finished Map Inflation ##');
    toc;
end

% -- Setup Motion Model --
% motion can be estimated using odometry data
odometryModel = robotics.OdometryMotionModel;
%The Noise property defines the uncertainty in robot's rotational and linear motion.
odometryModel.Noise = [0.2 0.2 0.2 0.2];

%-- Setup Sensor Model --
rangeFinderModel = robotics.LikelihoodFieldSensorModel;
%Versatz des Laserscanners zur Drehachse
rangeFinderModel.SensorPose = [0.338 0 0];
%The property SensorLimits defines the minimum and maximum range of sensor readings.
rangeFinderModel.SensorLimits = [0.45 5.6];  %OJ 8];
scanMsg = receive(subScan);
rangeFinderModel.NumBeams = numel(scanMsg.Ranges); %Gazebo 150 , real 726
originalMap = load(usedMapName);
rangeFinderModel.Map = originalMap.map;

%-- Initialize AMCL Object --
amcl = robotics.MonteCarloLocalization;
amcl.MotionModel = odometryModel;
amcl.SensorModel = rangeFinderModel;
% Mindestverfahrweg fuer Update
amcl.UpdateThresholds = [0.1,0.1,0.1];
amcl.ResamplingInterval = 1;
amcl.ParticleLimits = [500 50000];
amcl.GlobalLocalization = true;
%true; %set false if Initial youBotPosition is well estimated

%% GET INITIAL POSE FROM ODOMETRY FOR AMCL
% pose holen und speichern
posedata_quat = receive(subOdom,10);
% pose in Euler umrechnen (mit Versatz)
InitialPose = youBot_Pose_Quat_2_Eul(posedata_quat);
amcl.InitialPose = InitialPose;
amcl.InitialCovariance = eye(3)*0.5;
visualizationHelper = ExampleHelperAMCLVisualization(mapInflated.map);

%% -- Rotate youBot to estimate Position --
numUpdate = 90;
cntUpdate=0;
disp('Move youBot with rqt or teleop to help estimating position')
scanCnt=0;
%--------------------------
while cntUpdate < numUpdate
    scanCnt=scanCnt+1;
    % Receive laser scan and odometry message.
    scanMsg = receive(subScan);
    % Create lidarScan object to pass to the AMCL object.
    scan = lidarScan(scanMsg); 
    % pose holen und speichern
    posedata_quat = receive(subOdom,10);
     % pose in Euler umrechnen (mit Versatz)
    pose = youBot_Pose_Quat_2_Eul(posedata_quat);
     
    % Update estimated robot's pose and covariance using new odometry and
    % sensor readings
    % Mindestverfahrweg fuer Update amcl.UpdateThresholds
    [isUpdated,estimatedPose, estimatedCovariance] = ...
        amcl(pose, scan.Ranges, scan.Angles);
    % Drive robot to next pose. (youBot still turning)
    % Plot the robot's estimated pose, particles ..
    % and laser scans on the map.
    if isUpdated 
        cntUpdate = cntUpdate + 1;
        disp('cntUpdate: '); disp(cntUpdate);
        plotStep(visualizationHelper, amcl, estimatedPose, scan, cntUpdate)
        if cntUpdate==1
            % Create grid
            grid minor
            set(gca,'Xcolor',[1 0 0]); % RGB
            set(gca,'Ycolor',[1 0 0]);
            set(gca,'LineWidth', 2); % Line Width
        end
    end   
    disp('estimatedCovariance: ');
    disp(estimatedCovariance(3, 3))
    if estimatedCovariance(3, 3)<= 0.065 % probably equals good estimation, but wasn't tested thoroughly
        disp('#### !!!! Pose found ####');
        break;
    end    
end
beep %Produce operating system beep sound
disp('## Done Estimating - stop youBot ##')
disp('reale Pose (Odometry)');
disp(pose);
disp('Estimated Pose (AMCL)');
disp(estimatedPose);


% Stop Robot
msgsBaseVel.Linear.X = 0;
msgsBaseVel.Linear.Y = 0;
msgsBaseVel.Angular.Z = 0;
send(pubVel,msgsBaseVel);





