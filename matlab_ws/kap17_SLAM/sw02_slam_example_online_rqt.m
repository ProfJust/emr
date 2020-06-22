%% sw02_slam_example_online.m
% Das Beispiel aus (s.u.) für den youBot angepasst
% https://de.mathworks.com/help/nav/ug/...
% implement-online-simultaneous-localization-and-mapping-with-lidar-scans.html
% OJ 22.6.2020
% youBot per rqt fahren lassen
% sehen wie währendessen die Karte aufgezeichnet wird
% ----------------------------------------
%% ROS Init
% gazebo roslaunch emr_worlds youbot_arena.launch 
ROS_Node_init_localhost; 

%  realer youBot03
% try
%    rosnode list
% catch exp   % Error from rosnode list
%    rosinit('http://192.168.0.30:11311','NodeName','/RoboLabHome2')  
% end
subScan = rossubscriber('base_scan','sensor_msgs/LaserScan');

%% Create lidarSLAM-Objekt
maxLidarRange = 5.6;
mapResolution = 20;
slamAlg = lidarSLAM(mapResolution, maxLidarRange);
slamAlg.LoopClosureThreshold = 210;  
slamAlg.LoopClosureSearchRadius = 5.6;
%% ------------
close all; %figures
firstLoopClosure = false;
figure; title('Occupancy Grid Map Built Using Lidar SLAM');
i=1;
while (true)
    %% LaserScan empfangen
    scandata = receive(subScan,10);
    scans{i} = lidarScan(scandata); 
       
    [isScanAccepted,loopClosureInfo,optimizationInfo] = addScan(slamAlg,scans{i});
    if isScanAccepted
        % Visualize how scans plot and poses are updated as robot navigates
        % through virtual scene
        show(slamAlg);
        
        % Visualize the first detected loop closure
        % firstLoopClosure flag is used to capture the first loop closure event
        if optimizationInfo.IsPerformed && ~firstLoopClosure
            firstLoopClosure = true;
            show(slamAlg,'Poses','off');
            hold on;
            show(slamAlg.PoseGraph);
            hold off;
            title('First loop closure');
            snapnow
        end
    end
    %% Build Occupancy Grid Map
    [scans, optimizedPoses]  = scansAndPoses(slamAlg);
    map = buildMap(scans, optimizedPoses, mapResolution, maxLidarRange);
    show(map);
    hold on
    show(slamAlg.PoseGraph, 'IDs', 'off');
    hold off  
end