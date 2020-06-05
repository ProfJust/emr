%%  SCAN MATCHING USING NDT ALGORITHM
%   youBot_ScanMatch.m
% --------------------------------------------------------
%   "The goal of scan matching is to find the relative pose (or transform
%   between the two robot positions where the scans were taken. 
%   The scans can be aligned based on the shapes of their overlapping features.
%   To estimate this pose, NDT subdivides the laser scan into 2D cells and
%   each cell is assigned a corresponding normal distribution.
%   The distribution represents the probability of measuring a point in that cell. 
%   Once the probability density is calculated, an optimization method finds 
%   the relative pose between the current laser scan and the reference
%   laser scan."
%
% Authors of this script:          Bohnenkamp, Herzig, Wewers
%
% Documentation:                  https://goo.gl/YmGpZe


%%  CREATE MAP

%12m x 12m mit 100 Werten pro m => 1cm Raster
map = robotics.OccupancyGrid(12,12,100);
%Startposition des youBot % Offset-Map - Pose youBot
map.GridLocationInWorld = [-6,-6];


%%  PREPARATIONS | GET SCANS

% Load scans saved in LaserScans.mat (<--- youBot_Mapping)
scan=load('LaserScans.mat');
% Get numer of scans
numScans = numel(scan.laserMsg);
%numScans = numel(scan); %numel() Number of array elements
initialPose = [0 0 0];
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

% Loop through all the scans and calculate the relative poses between them

for idx = 2:numScans
    
    % disp progress
    clc;
    fprintf(str_progress,idx,numScans);
    
    % Process the data in pairs.
    referenceScan = scan.laserMsg{idx-1};
    currentScan = scan.laserMsg{idx};
    
    % Run scan matching. Note that the scan angles stay the same and do
    % not have to be recomputed. 
    
    if idx==2
        refScanAngles = readScanAngles(referenceScan);
        currScanAngles = readScanAngles(currentScan);
    end
    
    currScanRanges = currentScan.Ranges;
    refScanRanges = referenceScan.Ranges;

    % To increase accuracy, set the maximum
    % number of iterations to 500. Use the transform from the last
    % iteration as the initial estimate.
    
    [transform, stats] = matchScans(currScanRanges, currScanAngles, refScanRanges, refScanAngles, ...
        'SolverAlgorithm', 'fminunc', 'MaxIterations', 500, 'InitialPose', transform);

    % The |Score| in the statistics structure is a good indication of the
    % quality of the scan match.
    if stats.Score / numel(currScanRanges) < 1.0
        disp(['Low scan match score for index ' num2str(idx) '. Score = ' num2str(stats.Score) '.']);
    end
    
    % Maintain the list of robot poses.
    absolutePose = exampleHelperComposeTransform(poseList(idx-1,:), transform);
    poseList(idx,:) = absolutePose;

    % Integrate the current laser scan into the probabilistic occupancy grid.
    insertRay(map, absolutePose, currScanRanges, currScanAngles, maxrange);
end


%%  PLOT RESULTS

% Load reference map (built without scan matching)
originalMap=load('ReferenceMap.mat');


figure('units','normalized','outerposition',[0 0 1 1]); %for fullscreen figure
% subplot(line,column,position) allows to plot numerous figures in one windwow
% cf. help subplot
subplot(1,3,1);
% Plot reference map
show(originalMap.map);

subplot(1,3,2);
% Plot map after scan matching (NDT algorithm)
show(map);
title('Occupancy grid map built using scan matching results');

subplot(1,3,3);
% Plot estimated robot path along with optimized map
show(map);
title('Occupancy grid map built using scan matching results');
hold on
plot(poseList(:,1), poseList(:,2), 'bo', 'DisplayName', 'Estimated robot position');
legend('show', 'Location', 'NorthWest')

