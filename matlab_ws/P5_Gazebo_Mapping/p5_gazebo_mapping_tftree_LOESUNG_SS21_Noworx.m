% p6_gazebo_mapping.m
%-----------------------------------------
% mappt die Gazebo-Welt
% OJ fuer EMR am 20.5.2020
%-----------------------------------------------------------------------
ROS_Node_init_localhost;

%% --- get Gazebo Topics ----
subScan = rossubscriber('base_scan','sensor_msgs/LaserScan');
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');
scanMsgs = receive(subScan,10); % get first scan-Message

%%----- map erstellen --------------
% 12m x 12m mit 60 Werten pro m => 2cm Raster
map = occupancyMap(12,12,60); % requires Navigation Toolbox.

%Startposition des youBot  % Offset-Map - Pose youBot
map.GridLocationInWorld = [-6, -6];

%% Versatz des Lasers (frame /base_laser_front_link) auf Pose (frame /base_link) ermitteln
    tftree = rostf; %  Query the Transformation Tree (tf tree) in ROS.
    % https://de.mathworks.com/help/ros/ug/access-the-tf-transformation-tree-in-ros.html
    waitForTransform(tftree,'/base_link','/base_laser_front_link');
    sensorTransform = getTransform(tftree,'/base_link', '/base_laser_front_link');  
    % Calculate the euler rotation angles.
    laserQuat = [sensorTransform.Transform.Rotation.W ...
                 sensorTransform.Transform.Rotation.X ...
                 sensorTransform.Transform.Rotation.Y ...
                 sensorTransform.Transform.Rotation.Z ]
        
    laserEul = quat2eul(laserQuat);
     % relPose = [x y theta] relPose = [0.3 0.0 0.0];
    % relPose = [sensorTransform.Transform.Translation.X sensorTransform.Transform.Translation.Y laserEul(1)];

 while 1
   % pose holen 
    posedata = receive(subOdom,10);     
    
    % Laserscan holen 'sensor_msgs/LaserScan'
    scanMsg = receive(subScan,10);    
    
    % Daten des Lasers (frame /base_laser_front_link) 
    % auf Pose (frame /base_link) transformieren
    % relPose = [x y theta] 
    relPose = [sensorTransform.Transform.Translation.X sensorTransform.Transform.Translation.Y posedata.Twist.Twist.Angular.Z];
    
    scan = lidarScan(scanMsg);   % transscan benötigt lidarScan-Type
    transScan = transformScan(scan, relPose);
        
    % In Map eintragen => alles muss vom Typ double sein  
    pose = [posedata.Pose.Pose.Position.X, posedata.Pose.Pose.Position.Y, posedata.Twist.Twist.Angular.Z];
    insertRay(map, pose, transScan.Ranges, scan.Angles, double(scanMsg.RangeMax));
    % transScan.Angled are NAN if robot turns, so use scan.Angles instead
    
    show(map)    
end







