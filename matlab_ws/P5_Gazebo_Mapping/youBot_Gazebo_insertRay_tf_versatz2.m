% youBot_Gaezbo_insertRay_tf_versatz.m
%-----------------------------------------
% mappt die Gazebo-Welt
% youBot mit z.B. rqt bewegen
% laserscans werden in die Grid gezeichnet
%-----------------------------------------
% Versatz des Lasers mit tf im launch File angepasst
% Version vom 20.5.2020
%-----------------------------------------------------------------------
ROS_Node_init_localhost;

%%-----------------------------------------------------------------------
% gaezbo Topic /scan => /base_scan
subScan = rossubscriber('base_scan','sensor_msgs/LaserScan');
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');
scandata = receive(subScan,10); %first scan
tftree = rostf; % get tfTree

%%----- Laserscan Daten vorbereiten ----
numbOfScans = size(scandata.Ranges,1); % Spaltenzahl des Zeilenvektors 
maxrange = double(scandata.RangeMax);  % must be double-Format
% make empty ray Object insize of scandata, must be double-Format
ranges = typecast(3*ones(numbOfScans, 1),'double');
% determine the angles corrersponding to ranges, must be double-Format
angles = double(scandata.AngleMin: (scandata.AngleMax-scandata.AngleMin)/(numbOfScans-1) :scandata.AngleMax );
%%----- map erstellen --------------
% 12m x 12m mit 60 Werten pro m => 2cm Raster
map = robotics.OccupancyGrid(12,12,60);
%Startposition des youBot  % Offset-Map - Pose youBot
map.GridLocationInWorld = [-6,-6];

%%
while 1
   % pose holen und speichern
    posedata = receive(subOdom,10);
    
   % Winkel berechnet sich aus den Quarternionen 
    % pose als Quaternion speichern
    % Vektor mit 4 Spalten und einer Zeile => "..."
    poseOriQuat = [posedata.Pose.Pose.Orientation.X...
                   posedata.Pose.Pose.Orientation.Y...
                   posedata.Pose.Pose.Orientation.Z...
                   posedata.Pose.Pose.Orientation.W];
    eulZYX = quat2eul(poseOriQuat);
    theta = eulZYX(3);  
    
    % https://de.mathworks.com/help/robotics/examples/access-the-tf-transformation-tree-in-ros.html?searchHighlight=tf%20tree&s_tid=doc_srchtitle
     BaseToFront = getTransform(tftree, 'base_link', 'base_laser_front_link');
     
     %https://cps-vo.org/node/33530
     
    % Aktueller Base - Punkt 
     pt = rosmessage('geometry_msgs/PointStamped');
     pt.Header.FrameId = 'base_link';
     pt.Point.X = posedata.Pose.Pose.Position.X;
     pt.Point.Y = posedata.Pose.Pose.Position.Y;
     pt.Point.Z = posedata.Pose.Pose.Position.Z;
     disp('pt = base_link_pose'); disp(pt.Point)
     
     % base_link in base_laser_front_link wandeln 
     % Funktioniert nicht => immer nur 30cm in X-Richtung
     tfposedata = transform(tftree, 'base_laser_front_link', pt);
     disp('tfposedata'); disp(tfposedata.Point);
     poseTf = [tfposedata.Point.X,tfposedata.Point.Y, theta]; %X, Y, THETA
    
    %% xy-Daten des youBots sind ist nicht die exakte Position des Lasers
    % Hokuyo, Achse des Scanners ca 30 cm in X-Richtung
    % Laenge Base 58cm, Traegerblech - Mitte LAser ca. 4 cm
    versatz = 0.338; % 0.58/2 +0.05;
        
    poseX = posedata.Pose.Pose.Position.X + cos(theta)*versatz; 
    poseY = posedata.Pose.Pose.Position.Y + sin(theta)*versatz; 
    poseVersatz = [poseX, poseY, theta]; %X, Y, THETA
    
    poseLaser = poseTf;
    
    %scan holen
    scandata = receive(subScan,10);
    ranges = double(scandata.Ranges);
        
    %In Map eintragen, (alles muss double sein)
    insertRay(map, poseLaser, ranges, angles, maxrange, [0.4 0.9]);
    show(map)    
end



