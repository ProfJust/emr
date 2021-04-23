%youBot_Gaezbo_insertRay.m
%--------------------------------------------------
% EMR - 13.5.2020 
% mappt die Gazebo-Welt
%---------------------------------------------------

ROS_Node_init_localhost;
%-----------------------------------------------------------------------
subScan = rossubscriber('base_scan','sensor_msgs/LaserScan');
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');

%% ----- map erstellen --------------
%10m x 10m mit 50 Werten pro m => 2cm Raster
    %map = robotics.OccupancyGrid(20,20,50);
    map = occupancyMap(20,20,50);
%Startposition des youBot  % Offset-Map - Pose youBot
    map.GridLocationInWorld = [-6,-6];
%% ----- Laserscan Daten vorbereiten ----
% make empty ray Object
%AngleMin = -1.57; %siehe scandata
%AngleMax = 1.57;
%ranges = 3*ones(150, 1);
%angles = linspace(AngleMin,AngleMax, 150);
%maxrange = 5.6;


scandata = receive(sub1,10); % Abstandswerte holen => Zeilenvektor 
numbOfScans = size(scandata.Ranges,1); % Spaltenzahl des Zeilenvektors 
minAngle = scandata.AngleMin;  % Winkelbereich holen
maxAngle = scandata.AngleMax;
maxrange = 5.6;
% Zeilenvektor fuer alle Winkel mit gleicher Spaltenzahl erstellen
angles = (minAngle: (maxAngle-minAngle)/(numbOfScans-1):maxAngle);
ranges = 3*ones(numbOfScans, 1);

while 1
   % pose holen und speichern
    posedata = receive(subOdom,10);
    
   % Winkel berechnet sich aus den Quarternionen 
    % pose als Quaternion speichern
    myQuat = [ posedata.Pose.Pose.Orientation.X posedata.Pose.Pose.Orientation.Y posedata.Pose.Pose.Orientation.Z posedata.Pose.Pose.Orientation.W];
    eulZYX = quat2eul(myQuat);
    theta = eulZYX(3);  
    
    %xY-Daten des youBot sind ist nicht die exakte Funktion des
    %Hokuyo, Achse des Scanners ca 30 cm in X-Richtung
    % L�nge Base 58cm, Tr�gerblech - Mitte LAser ca. 4 cm
    versatz = 0.58/2 +0.04;
  
    poseX = posedata.Pose.Pose.Position.X + cos(theta)*versatz; 
    poseY = posedata.Pose.Pose.Position.Y + sin(theta)*versatz; 
    
    pose = [poseX, poseY, theta] %X, Y, THETA
    
    %scan holen
    scandata = receive(subScan,10);
    ranges = scandata.Ranges;
        
    %In Map eintragen
    insertRay(map,pose,ranges,angles,maxrange,[0.4 0.9]);
    show(map)    
end








