% Step1_youBot_Gazebo_make_Array_of_LaserScans.m
% -----------------------------------------
% laserscannt die Umgebung beim manuellen fahren
% und ermoeglicht die Speicherung in einer *.mat Datei
% fuer die weitere Verwendung mit dem
% ScanMatching-Algorithmus => Step 2
%-----------------------------------------
% Gazebo mit youbot starten
% Achtung!!
% scanMatching funktioniert nur, wenn Landmarken
% zu finden sind => robocup_at_work_2012
% mit zusaetzlichen Dosen, Waenden etc versehen
% Am besten eine Wand drumherum wie im Labor
% oder Labor-Arena-World nutzen
% ...oder youBot in Willow-Garage stellen
%--------------------------------------------
clear; %workspace
%% ROS Init
%ROS-MAster - nur einmal
try
    rosnode list
catch exp   % Error from rosnode list
    %  realer youBot
    rosinit('http://192.168.0.30:11311','NodeName','/RoboLabHome2')  
end

subScan = rossubscriber('base_scan','sensor_msgs/LaserScan');
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');

%% ----- map mit Odom erstellen --------------
%10m x 10m mit 50 Werten pro m => 2cm Raster
map = robotics.OccupancyGrid(10,10,50);
%Startposition des youBot auf Map % Offset-Map - Pose youBot
map.GridLocationInWorld = [-5,-5];

%% ----- Laserscan Daten vorbereiten ----
promptStr = 'maximale Anzahl der Scans fuer die Karte eimgeben (Vorher Abbruch durch STRG+C möglich) >  .. '
NumbOfScans = input(promptStr);
% size changing in der while loop verhindern
% not working LaserScans = ones(NumbOfScans, 'sensor_msgs/LaserScan');

% make empty ray Object
scandata = receive(subScan,10);
angleMin = scandata.AngleMin;
angleMax = scandata.AngleMax;
angles = linspace(angleMin, angleMax, 489); %150
rangeMax = cast(scandata.RangeMax , 'double');

i=0;
%%
while i< NumbOfScans
    %% pose holen und speichern
    posedata_quat = receive(subOdom,10);
    % pose in Euler umrechnen (mit Versatz)
    pose = youBot_Odom2Laser_Pose_Quat_2_Eul(posedata_quat);
    
    % scan aus ROS holen und speichern
    scandata = receive(subScan,10);
    LaserScans{i+1}=scandata; %erster Index 1
    
    %% Map zeichnen - nur zur Kontrolle
    ranges = cast(scandata.Ranges, 'double'); % single -> double
    mylidarscan = lidarScan(ranges, angles);
    insertRay(map, pose, mylidarscan, rangeMax);
    show(map)
    
    i=i+1
end

%% Save Scans - funktioniert nicht
% promptStr = 'gewuenschten Namen des Scan-Arrays eingeben >  .. '
% arrayNameStr = input(promptStr, 's') +'.mat';
% save(arrayNameStr, LaserScans)

disp('RMB auf Workkspace/LaserScans, save as(''mySavedScans.mat''); => Datei')








