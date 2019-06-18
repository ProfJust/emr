% STep1_youBot_Gazebo_make_Array_of_LaserScans.m
%-----------------------------------------
% laserscannt die Umgebung beim manuellen fahren
% und ermoeglicht die Speicherung einer *.mat Datei
% fuer die weitere Verwendung mit dem 
% ScanMatching-Algorithmus
%-----------------------------------------
% Gazebo mit youbot starten
% Achtung!! 
% scanMatching funktioniert nur, wenn Landmarken
% zu finden sind => robocup_at_work_2012 
% mit zusaetzlichen Dosen, Waenden etc versehen
% Am besten eine Wand drumherum wie im Labor
%
% ...oder youBot in Willow-Garage stellen
%--------------------------------------------

%ROS-MAster - nur einmal
rosshutdown
clear; %workspace
%rosinit('http://192.168.2.108:11311','NodeName','/RoboLabHome')
rosinit('http://127.0.0.1:11311','NodeName','/RoboLabHome')
%-----------------------------------------------------------------------
% gaezbo Topic /scan => /base_scan
subScan = rossubscriber('base_scan','sensor_msgs/LaserScan');
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');

%----- map erstellen --------------
%10m x 10m mit 50 Werten pro m => 2cm Raster
map = robotics.OccupancyGrid(10,10,50);
%Startposition des youBot  % Offset-Map - Pose youBot
map.GridLocationInWorld = [-6,-6];

%----- Laserscan Daten vorbereiten ----
promptStr = 'gewuenschten Anzahl der Scans  fuer die Karte eimgeben >  .. '
NumbOfScans = input(promptStr);
firstLoop = true;
i=0;

while i< NumbOfScans
   % pose holen und speichern
    posedata_quat = receive(subOdom,10);
    
    % pose in Euler umrechnen (mit Versatz)
    pose = youBot_Pose_Quat_2_Eul(posedata_quat);
    
    
    %scan aus ROS holen
    scandata = receive(subScan,10);
    LaserScans{i+1}=scandata; %erster Index 1
    if firstLoop
        %----- Laserscan Daten vorbereiten ----
        % make empty ray Object
         angleMin = scandata.AngleMin;
         angleMax = scandata.AngleMax;
         angles = linspace(angleMin, angleMax, 150);   
         rangeMax = cast(scandata.RangeMax , 'double');           
    end    
     ranges = cast(scandata.Ranges, 'double'); % single -> double
    mylidarscan = lidarScan(ranges, angles);      
   
    insertRay(map, pose, mylidarscan, rangeMax);
    show(map)   
    i=i+1
end

% Save Scans
promptStr = 'gewuenschten Namen des Scan-Arrays eingeben >  .. '
arrayNameStr = input(promptStr, 's') +'.mat';
save(arrayNameStr, 'LaserScans')

% alt: STRG+C danach RMB auf Workkspace / LaserScans save as('OJLaserScans.mat'); => Datei
    







