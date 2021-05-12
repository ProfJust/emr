% p5_gazebo_mapping_tftree_LOESUNG_SS21_Noworx.m
%-----------------------------------------
% mappt die Gazebo-Welt mit rostf
% OJ fuer EMR am 12.5.2021
%-----------------------------------------------------------------------
ROS_Node_init_localhost;

%% --- get Gazebo Topics ----
subScan = rossubscriber('base_scan','sensor_msgs/LaserScan');
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');

%% ----- map erstellen --------------
% 12m x 12m mit 60 Werten pro m => 2cm Raster
map = occupancyMap(12,12,60); % requires Navigation Toolbox.
%Startposition des youBot  % Offset-Map - Pose youBot
map.GridLocationInWorld = [-6, -6];

%% Versatz des Lasers (frame /base_laser_front_link) auf Pose (frame /odom ermitteln
    tftree = rostf; %  Query the Transformation Tree (tf tree) in ROS.
    % https://de.mathworks.com/help/ros/ug/access-the-tf-transformation-tree-in-ros.html
    waitForTransform(tftree,'/odom','/base_laser_front_link');
    
 while 1
    %% Daten vom ROS empfangen
    % pose holen 
    odomMsg = receive(subOdom,10);     
    % Laserscan holen 'sensor_msgs/LaserScan'
    scanMsg = receive(subScan,10);    
    
    %% Odom Pose (frame /odom)
    % auf die Laserposition umrechnen(frame /base_laser_front_link) 
    % Für transform muss der Datentyp von 'geometry_msgs/Pose'
    % auf geometry_msgs/PoseStamped geändert werden
    % http://docs.ros.org/en/melodic/api/geometry_msgs/html/msg/PoseStamped.html
    odomPoseStamped = rosmessage('geometry_msgs/PoseStamped'); % Instanziierung
    odomPoseStamped.Pose = odomMsg.Pose.Pose;
    odomPoseStamped.Header = odomMsg.Header;
     
    % Transform the ROS message to the 'base_laser_front_link' frame 
    transOdomMsg = transform(tftree,'/base_laser_front_link', odomPoseStamped);
    %% Debug
     disp(odomPoseStamped.Pose.Position);
     disp(transOdomMsg.Pose.Position);
    
    
    %% Theta ermitteln => pose
    myQuat = [ odomMsg.Pose.Pose.Orientation.X + transOdomMsg.Pose.Orientation.X ...
               odomMsg.Pose.Pose.Orientation.Y + transOdomMsg.Pose.Orientation.Y ...
               odomMsg.Pose.Pose.Orientation.Z + transOdomMsg.Pose.Orientation.Z ...
               odomMsg.Pose.Pose.Orientation.W + transOdomMsg.Pose.Orientation.W ];
    eulZYX = quat2eul(myQuat);
    theta = eulZYX(3);  
    poseLaser = [odomPoseStamped.Pose.Position.X + transOdomMsg.Pose.Position.X...
                 odomPoseStamped.Pose.Position.Y + transOdomMsg.Pose.Position.Y...
                 theta]
   
    
    %% transscan benötigt lidarScan-Type  
    % scanMsg ist aber sensor_msgs/LaserScan
    scan = lidarScan(scanMsg);  
    
    %% Scan in Map eintragen
    insertRay(map, poseLaser, scan.Ranges, scan.Angles, double(scanMsg.RangeMax));
    
    show(map)    
 end

 
 
 

    % transformieren
    % getTransform(tftree,targetframe,sourceframe)
   % sensorTransform = getTransform(tftree,'/base_laser_front_link', '/odom');
    % Hier kommt was anderes raus als erwartet, wieso nicht 0.3 in X-Richtung?? 
        
% %     % Calculate theta   using the euler rotation angles.
%     % set Quaternion
%     laserQuat = [sensorTransform.Transform.Rotation.W ...
%                  sensorTransform.Transform.Rotation.X ...
%                  sensorTransform.Transform.Rotation.Y ...
%                  sensorTransform.Transform.Rotation.Z ]; 
%     laserEul = quat2eul(laserQuat);
% 
%     % relPose bzw. tf  benötigt in der Form [x y theta] 
%     ododm2lasertf = [sensorTransform.Transform.Translation.X ...
%                     sensorTransform.Transform.Translation.Y ...
%                     laserEul(1)]
%     %% Theta ermitteln
%     myQuat = [ transOdomMsg.Pose.Pose.Orientation.X ...
%                transOdomMsg.Pose.Pose.Orientation.Y ...
%                transOdomMsg.Pose.Pose.Orientation.Z ...
%                transOdomMsg.Pose.Pose.Orientation.W ];
%     eulZYX = quat2eul(myQuat);
%     theta = eulZYX(3);  
%     
%     %% In Map eintragen => alles muss vom Typ double sein  
%     % Neue Pose ist die /odom-Pose + Versatz
%     pose = [transOdomMsg.Pose.Pose.Position.X ...
%             transOdomMsg.Pose.Pose.Position.Y ...
%             theta];







