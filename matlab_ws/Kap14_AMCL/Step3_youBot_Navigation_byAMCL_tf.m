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
% ------------------------------------------
% Version vom 9.06.2020 edited for youBot by OJ
% robotik.bocholt@w-hs.de
% ------------------------------------------
close all; %figures
clear; %workspace

%% ROS Init
ROS_Node_init_localhost;
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');
subScan = rossubscriber('base_scan','sensor_msgs/LaserScan');
pubVel = rospublisher ('cmd_vel', 'geometry_msgs/Twist');
msgsBaseVel = rosmessage(pubVel);

%% Konfiguration 
usedMapName ='myArenaMap.mat' % Die Karte der aktuellen Welt
mapOccGrid  = load(usedMapName);
mapInflated = load(usedMapName);
originalMap = load(usedMapName);
youbotRadiusGrid = 6; % 33; %Define youBotSize
numUpdate = 90; % Max. Anzahl der AMCL Update Zyklen

% -- Erster LaserScan => Konfiguration 
    scanMsg = receive(subScan);    
% -- Setup Motion Model --
    % motion can be estimated using odometry data
    odometryModel = robotics.OdometryMotionModel;
    %The Noise property defines the uncertainty in robot's rotational and linear motion.
    odometryModel.Noise = [0.2 0.2 0.2 0.2];
% -- Setup Sensor Model  rangeFinderModel --
    rangeFinderModel = robotics.LikelihoodFieldSensorModel;
    rangeFinderModel.Map = originalMap.map;
    %The property SensorLimits defines the minimum and maximum range of sensor readings.
    rangeFinderModel.SensorLimits = [0.45 double(scanMsg.RangeMax)];  % 5.6 im gazebo youBot
    rangeFinderModel.NumBeams = numel(scanMsg.Ranges); %Gazebo 150 , real 726
    % Versatz des Laserscanners zur Drehachse berücksichtigen
    %% alt rangeFinderModel.SensorPose = [0.338 0 0];
    
    % Query the Transformation Tree (tf tree) in ROS.
    tftree = rostf
    waitForTransform(tftree,'/base_link','/base_laser_front_link');
    sensorTransform = getTransform(tftree,'/base_link', '/base_laser_front_link');

    % Get the euler rotation angles.
    laserQuat = [sensorTransform.Transform.Rotation.W sensorTransform.Transform.Rotation.X ...
                 sensorTransform.Transform.Rotation.Y sensorTransform.Transform.Rotation.Z];
    laserRotation = quat2eul(laserQuat, 'ZYX');

    % Setup the |SensorPose|, which includes the translation along base_link's
    % +X, +Y direction in meters and rotation angle along base_link's +Z axis
    % in radians.
    rangeFinderModel.SensorPose = ...
        [sensorTransform.Transform.Translation.X sensorTransform.Transform.Translation.Y laserRotation(1)];

%-- Initialize AMCL Object --
    amcl = robotics.MonteCarloLocalization;
    amcl.MotionModel = odometryModel;
    amcl.SensorModel = rangeFinderModel;
    % Mindestverfahrweg fuer Update
    amcl.UpdateThresholds = [0.1,0.1,0.1];
    amcl.ResamplingInterval = 1;
    amcl.ParticleLimits = [500 50000];
    amcl.GlobalLocalization = false; % true;
    %true; %set false if Initial youBotPosition is well estimated


%% MONTE CARLO LOCALIZATION (MCL) - Algorithm
%MCL - https://de.mathworks.com/help/robotics/examples/localize-turtlebot-using-monte-carlo-localization.html
% Check whether mapInflated is already available
if exist('mapInflated','var')
    disp('## Map is up to date ##');
else
    disp('## Map Inflation ##');
    inflate(mapInflated,youbotRadiusGrid,'grid');
    % Randomly generate NODES
    prm = robotics.PRM(mapInflated);
    prm.NumNodes = 214; % number of nodes
    prm.ConnectionDistance = 1; % in meters
end

%% GET INITIAL POSE FROM ODOMETRY FOR AMCL
posedata_quat = receive(subOdom,10);
% pose in Euler umrechnen (mit Versatz)
InitialPose = youBot_Pose_Quat_2_Eul(posedata_quat);
amcl.InitialPose = InitialPose;
amcl.InitialCovariance = eye(3)*0.5;
visualizationHelper = ExampleHelperAMCLVisualization(mapInflated.map);

%% --------------------------
cntUpdate=0;
scanCnt=0;
while cntUpdate < numUpdate
    scanCnt=scanCnt+1;
    % Receive laser scan and odometry message.
    scanMsg = receive(subScan);
    % Create lidarScan object to pass to the AMCL object.
    scan = lidarScan(scanMsg); 
    % OdomPose als erste Schätzung holen und speichern
    posedata_quat = receive(subOdom,10);
     % pose in Euler umrechnen (mit Versatz)
    pose = youBot_Pose_Quat_2_Eul(posedata_quat);
     
    % Update estimated robot's pose and covariance using new odometry and
    % sensor readings
    [isUpdated,estimatedPose, estimatedCovariance] = ...
        amcl(pose, scan.Ranges, scan.Angles);
    % Drive robot to next pose. (youBot still moving)
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
    else
        disp('Move youBot with rqt or teleop to help estimating position')
    end    
end

%% Finally Stop Robot
msgsBaseVel.Linear.X = 0;
msgsBaseVel.Linear.Y = 0;
msgsBaseVel.Angular.Z = 0;
send(pubVel,msgsBaseVel);

beep() %Produce operating system beep sound
disp('## Done Estimating - stop youBot ##')
disp('reale Pose (Odometry)');
disp(pose);
disp('Estimated Pose (AMCL)');
disp(estimatedPose);




