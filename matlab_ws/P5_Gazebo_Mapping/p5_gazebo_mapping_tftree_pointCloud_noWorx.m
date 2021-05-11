% p6_gazebo_mapping.m
%-----------------------------------------
% mappt die Gazebo-Welt
% OJ fuer EMR am 20.5.2020
%-----------------------------------------------------------------------
ROS_Node_init_localhost;


% #####>
% tftree-Transformation funktioniert nur mit sensor_msgs/PointCloud2
% => 'sensor_msgs/LaserScan' to 'sensor_msgs/PointCloud2'needed
% https://github.com/carlosmccosta/laserscan_to_pointcloud
% cd ~/catkin_ws/src/laserscan_to_pointcloud/launch
% roslaunch laserscan_to_pointcloud_assembler.launch 

%%-----------------------------------------------------------------------
% gaezbo Topic /scan => /base_scan
subScan = rossubscriber('base_scan_pointcloud','sensor_msgs/PointCloud2');
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');
scandata = receive(subScan,10); %first scan

%%----- map erstellen --------------
% 12m x 12m mit 60 Werten pro m => 2cm Raster
map = occupancyMap(12,12,60); % requires Navigation Toolbox.

%Startposition des youBot  % Offset-Map - Pose youBot
map.GridLocationInWorld = [-6,-6];

%% Query the Transformation Tree (tf tree) in ROS.
    tftree = rostf;
    waitForTransform(tftree,'/base_link','/base_laser_front_link');
    
while 1
   % pose holen 
    posedata = receive(subOdom,10);     
    
    % Laserscan holen 'sensor_msgs/LaserScan'
    scandata = receive(subScan,10);
        
    % Daten des Lasers (frame /base_laser_front_link) 
    % auf Pose (frame /base_link) transformieren
    % tfentity = transform(tftree,targetframe,entity)
    tfposedata = transform(tftree, 'base_link', scandata);
    
    % In Map eintragen => alles muss double sein
    ranges = double(tfposedata.Ranges);   
    % Version bis Robotic System Toolbox 2.2 
    % insertRay(map, pose, ranges, angles, maxrange, [0.4 0.9]);
    insertRay(map, pose, ranges, angles, maxrange);
    
    show(map)    
end

%%%% Version 2 - noWorx  

% Daten des Lasers (frame /base_laser_front_link) 
    % auf Pose (frame /base_link) transformieren
    % tfentity = transform(tftree,targetframe,entity)
    %tfposedata = transform(tftree, 'base_link', scanMsg);
    % ===> ERROR
    %%%%%% Input message type must be one of these message types:
    %geometry_msgs/QuaternionStamped, geometry_msgs/Vector3Stamped,
    %geometry_msgs/PointStamped, geometry_msgs/PoseStamped, sensor_msgs/PointCloud2.
    
    % Leider ist die Msg aber vom Typ LaserScan







