%% sw01_slam_example_matlab.m
% Das Beispiel aus (s.u.) für den youBot angepasst
% https://de.mathworks.com/help/nav/ug/...
% implement-simultaneous-localization-and-mapping-with-lidar-scans.html
% OJ 22.6.2020
% ----------------------------------------
close all; %figures

%% Auswahldialog für Datei - öffnen
[file,path] = uigetfile('*.mat','Select File with LaserScans');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end

%% load real LaseScans{}
%load('realArenaScans.mat');
load(file)
%% Create lidarSLAM-Objekt
maxLidarRange = 5.6;
mapResolution = 20;
slamAlg = lidarSLAM(mapResolution, maxLidarRange);
slamAlg.LoopClosureThreshold = 210;  
slamAlg.LoopClosureSearchRadius = 5.6;

%% Observe the Map Building Process with Initial 10 Scans
for i=1:10
    % Create lidarScan object 
    scans{i} = lidarScan(LaserScans{i}); 
    [isScanAccepted, loopClosureInfo, optimizationInfo] = addScan(slamAlg, scans{i});
    if isScanAccepted
        fprintf('Added scan %d \n', i);
    end
end

figure;
show(slamAlg);
title({'Map of the Environment','Pose Graph for Initial 10 Scans'});

%% Create LidarScan-matrix
for i=10:numel(LaserScans)
    strOut ="create lidarScan("+  i +") von " + length(scans);
    disp(strOut);
    % Create lidarScan object 
    scans{i} = lidarScan(LaserScans{i}); 
end

%%Observe the Effect of Loop Closures and the Optimization Process
firstTimeLCDetected = false;
figure;

%% The loop closure parameters are set empirically. 
% Using a higher loop closure threshold helps reject false positives in loop closure identification process.
% Keep in mind that a high-score match may still be a bad match. 
% For example, scans collected in an environment that has similar or repeated features
% are more likely to produce false positive. 
% Using a higher loop closure search radius allows the algorithm to search a wider range of the map 
% around the current pose estimate for loop closures.

disp(" This could take minutes");
for i=10:length(scans)
    [isScanAccepted, loopClosureInfo, optimizationInfo] = addScan(slamAlg, scans{i});
    if ~isScanAccepted
        continue;
    end
    % visualize the first detected loop closure, if you want to see the
    % complete map building process, remove the if condition below
    if optimizationInfo.IsPerformed && ~firstTimeLCDetected
        show(slamAlg, 'Poses', 'off');
        hold on;
        show(slamAlg.PoseGraph); 
        hold off;
        firstTimeLCDetected = true;
        drawnow
    end
end
title('First loop closure');

%%Build Occupancy Grid Map
[scans, optimizedPoses]  = scansAndPoses(slamAlg);
map = buildMap(scans, optimizedPoses, mapResolution, maxLidarRange);
figure; 
show(map);
hold on
show(slamAlg.PoseGraph, 'IDs', 'off');
hold off
title('Occupancy Grid Map Built Using Lidar SLAM');
