%%  SCAN MATCHING USING NDT ALGORITHM
%  MatlabExample_estimate_youBot_Pose.m
% --------------------------------------------------------
% Das Matlab-Beispiel edit ScanMatchingExample 
% für den youBot und Gazebo angepasst
% https://de.mathworks.com/help/robotics/examples/estimate-robot-pose-with-scan-matching.html?s_tid=srchtitle
% Documentation:                  https://goo.gl/YmGpZe
%Edited bby OJ 15.06.2018

%%  CREATE MAP
clear; %workspace

%#### Grid muss dasselbe sein wie beim Scannen !! ###
% %12m x 12m mit 100 Werten pro m => 1cm Raster
map = robotics.OccupancyGrid(10,10,50);
% %Startposition des youBot % Offset-Map - Pose youBot
map.GridLocationInWorld = [-6,-6];


%%  PREPARATIONS | GET SCANS

% Load scans saved in LaserScans.mat (<--- youBot_Mapping)
scan=load('OJLaserScans.mat');
% Get numer of scans
%numScans = numel(scan.laserMsg);
numScans = 730;% scan.i; %numel() Number of array elements
initialPose = [0 0 0];
absolutePose = initialPose;
% Pre-allocate an array to capture the absolute movement of the robot.
% Initialize the first pose as [0 0 0].
% All other poses are relative to the first measured scan.
poseList = zeros(numScans,3);
poseList(1,:) = initialPose;
transform = initialPose;
% maxrange of laser
maxrange=3;
str_progress = 'Done matching %d of %d scans.\n';


%%  SCAN MATCHING LOOP
% Run scan matching. Note that the scan angles stay the same and do
% not have to be recomputed.
refScanAngles = readScanAngles(scan.LaserScans{1});
currScanAngles = readScanAngles(scan.LaserScans{2});

% Loop through all the scans and calculate the relative poses between them
scoreFlag=true;
for idx = 2:numScans
    
    % disp progress
    clc;
    fprintf(str_progress,idx,numScans);
    
    % Process the data in pairs.
    if scoreFlag == true %neue Referenz nur wenn Scor OK
        referenceScan = scan.LaserScans{idx-1};
        refScanRanges = referenceScan.Ranges;
    end
    currentScan = scan.LaserScans{idx};
    currScanRanges = currentScan.Ranges;       
    
    % To increase accuracy, set the maximum
    % number of iterations to 500. Use the transform from the last
    % iteration as the initial estimate.    
    [transform, stats] = matchScans(currScanRanges, currScanAngles, refScanRanges, refScanAngles, ...
        'SolverAlgorithm', 'fminunc', 'MaxIterations', 500, 'InitialPose', transform);
    
    % The |Score| in the statistics structure is a good indication of the
    % quality of the scan match.
    if stats.Score / numel(currScanRanges) < 1.0
        disp(['Low scan match score for index ' num2str(idx) '. Score = ' num2str(stats.Score) '.']);
        scoreFlag = false;
    else
        scoreFlag = true;
        % Maintain the list of robot poses.
        %absolutePose = exampleHelperComposeTransform(poseList(idx-1,:), transform);
        absolutePose = absolutePose + transform;
        poseList(idx,:) = absolutePose;
        
        % Integrate the current laser scan into the probabilistic occupancy grid.
        insertRay(map, absolutePose, currScanRanges, currScanAngles, maxrange);
    end
end


%%  PLOT RESULTS
close all;
figure('units','normalized','outerposition',[0 0 1 1]); %for fullscreen figure
subplot(1,2,1);
% Plot map after scan matching (NDT algorithm)
show(map);
title('Occupancy grid map built using scan matching results');
subplot(1,2,2);
% Plot estimated robot path along with optimized map
show(map);
title('Occupancy grid map built using scan matching results');
hold on
plot(poseList(:,1), poseList(:,2), 'bo', 'DisplayName', 'Estimated robot position');
legend('show', 'Location', 'NorthWest')

