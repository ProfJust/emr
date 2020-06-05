%%  SCAN MATCHING USING NDT ALGORITHM
%   Step2_scanMatch_example_4_youBot_Gazebo.m
% --------------------------------------------------------
% Das Matlab-Beispiel edit ScanMatchingExample
% fuer den youBot und Gazebo angepasst
% https://de.mathworks.com/help/robotics/examples/estimate-robot-pose-with-scan-matching.html?s_tid=srchtitle
% Documentation:                  https://goo.gl/YmGpZe
% Edited bby OJ 5.06.2020
%
%--------------------------------------------
%% Load Laser Scan Data from File
scan=load('mySavedLaserScans.mat');
numScans = numel(scan.LaserScans)

%% Build Occupancy Grid Map Using Iterative Scan Matching
% Create an occupancy grid object for a 15 meter by 15 meter area.
% Set the map's origin to be [-7.5 -7.5].
map = robotics.OccupancyGrid(10, 10, 20);
map.GridLocationInWorld = [-5 -5]

%%
% Pre-allocate an array to capture the absolute movement of the robot.
% Initialize the first pose as |[0 0 0]|. All other poses are relative to
% the first measured scan.
initialPose = [0 0 0];
absolutePose = initialPose;
poseList = zeros(numScans,3);
poseList(1,:) = initialPose;
transform = initialPose;
refScanAngles = readScanAngles(scan.LaserScans{1});
currScanAngles = readScanAngles(scan.LaserScans{2});
% maxrange of laser
maxrange= scan.LaserScans{1, 1}.RangeMax; %5.6;


%%
% Create a loop for processing the scans and mapping the area. The laser scans are processed
% in pairs. Define the first scan as reference scan and the second scan as current scan.
% The two scans are then passed to the scan matching algorithm and the
% relative pose between the two scans is computed. The
% |exampleHelperComposeTransform| function is used to calculate of the cumulative
% absolute robot pose. The scan data along with the absolute robot pose
% can then be passed into the |<docid:robotics_ref.bvaw7o8-1 insertRay>| function
% of the occupancy grid.

% Loop through all the scans and calculate the relative poses between them
disp('Starte Mapping Nr.');
for idx = 2: numScans
    disp(idx);
    % Process the data in pairs.
    referenceScan = lidarScan(scan.LaserScans{idx-1});
    currentScan = lidarScan(scan.LaserScans{idx});
    
    % Run scan matching. Note that the scan angles stay the same and do
    % not have to be recomputed. To increase accuracy, set the maximum
    % number of iterations to 500. Use the transform from the last
    % iteration as the initial estimate.
    [transform, stats] = matchScans(currentScan, referenceScan, ...
        'MaxIterations', 500, 'InitialPose', transform);
    
    % The |Score| in the statistics structure is a good indication of the
    % quality of the scan match.
    currScanRanges = currentScan.Ranges;
    if stats.Score / numel(currScanRanges) < 0.8
        disp(['Low scan match score for index ' num2str(idx) '. Score = ' num2str(stats.Score) '.']);
        break; %Ende der SChleife bei Low Score
    end
    
    % Maintain the list of robot poses.
    absolutePose = exampleHelperComposeTransform(poseList(idx-1,:), transform);
    %absolutePose = absolutePose + transform;
    poseList(idx,:) = absolutePose;
    
    % Integrate the current laser scan into the probabilistic occupancy grid.
    insertRay(map, absolutePose, currScanRanges, currScanAngles, cast(maxrange,'double'));
end

%% Visualize Map
% Visualize the occupancy grid map populated with the laser scans.
figure
show(map);
title('Occupancy grid map built using scan matching results');

%%
% Plot the absolute robot poses that were calculated by the scan matching
% algorithm. This shows the path that the robot took through the map of the
% environment.
hold on
plot(poseList(:,1), poseList(:,2), 'bo', 'DisplayName', 'Estimated robot position');
legend('show', 'Location', 'NorthWest')

disp(' Wenn die Karte gelungen ist, können Sie die map aus dem Workspace unter einem gewählten Namen sichern');
