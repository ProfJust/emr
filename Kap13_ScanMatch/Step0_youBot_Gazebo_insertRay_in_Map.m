% Step1_youBot_Gazebo_insertRay.m
%-----------------------------------------
% mappt die Gazebo-Welt
% getestet mit robocup_at_work_2012
% youBot mit z.B. rqt bewegen
% laserscans werden in die Map gezeichnet
%-----------------------------------------
% Drehen klappt jetzt auch !!
% Version vom 17.6.19
%-----------------------------------------
rosshutdown; %ROS-MAster - nur einmal
%rosinit('http://192.168.1.142:11311','NodeName','/MatlabNode')
rosinit('http://127.0.0.1:11311','NodeName','/MatlabNode')
%-----------------------------------------------------------------------
% gaezbo Topic /scan => /base_scan
subScan = rossubscriber('base_scan','sensor_msgs/LaserScan');
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');

%----- map erstellen --------------
%10m x 10m mit 50 Werten pro m => 2cm Raster
map = robotics.OccupancyGrid(12,12,50);
%Startposition des youBot  % Offset-Map - Pose youBot
map.GridLocationInWorld = [-6,-6];

promptStr = 'gewuenschten Anzahl der Scans  fuer die Karte eimgeben >  .. '
NumbOfScans = input(promptStr);
firstLoop = true;
i=0;
while i< NumbOfScans
    
     % pose holen und speichern
    posedata_quat = receive(subOdom,10);
  
   % pose in Euler umrechnen (mit Versatz)
    pose = youBot_Pose_Quat_2_Eul(posedata_quat);
    
    % scan vom ROS holen
    scandata = receive(subScan,10);
    % Array für die Winkel fetslegen (nur einmal noetig)
    if firstLoop
        %----- Laserscan Daten vorbereiten ----
        % make empty ray Object
         angleMin = scandata.AngleMin;
         angleMax = scandata.AngleMax;
         angles = linspace(angleMin, angleMax, 150);   
         rangeMax = cast(scandata.RangeMax , 'double');           
    end
    
    % scandata in Map eintragen
     % to Avoid Error :Incorrect class for expression 'p2': expected 'double' but found 'single'.
     % xacro - File im URDF auf double konfigurieren, Möglich??
    ranges = cast(scandata.Ranges, 'double'); % single -> double
    mylidarscan = lidarScan(ranges, angles);      
   
    insertRay(map, pose, mylidarscan, rangeMax);
    show(map)   
    i=i+1
end

% Save Map
promptStr = 'gewuenschten Namen der Karte eingeben >  .. '
mapNameStr = input(promptStr, 's');
save(mapNameStr, 'map')
% anzeigen mit  >>show(map)  








