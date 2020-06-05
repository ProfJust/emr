%%  SCAN MATCHING USING NDT ALGORITHM
%   MatlabExample_estimate_youBot_Pose_linear.m
% --------------------------------------------------------
% Das Matlab-Beispiel edit ScanMatchingExample 
% f�r den youBot und Gazebo angepasst
% https://de.mathworks.com/help/robotics/examples/estimate-robot-pose-with-scan-matching.html?s_tid=srchtitle
% Documentation:                  https://goo.gl/YmGpZe
% Edited bby OJ 15.06.2018
%
%% Load Laser Scan Data from File
close all;
clear; %workspace
% filePath = fullfile(fileparts(mfilename('fullpath')), 'data', 'OJLaserScans.mat');
% load(filePath);
scan=load('OJLaserScansLinear.mat');

%%
% The laser scan data was collected by a mobile robot in an indoor environment. 
% An approximate floorplan of the area, along with the robot's path
% through the space, is shown in the following image.
%
% <<sm_floorplan_sketch.png>>

%% Plot Two Laser Scans
% Pick two laser scans to scan match from the |laserMsg| ROS messages. They
% should share common features by being close together in the sequence.
% referenceScan = lidarScan(laserMsg{180});
% currentScan = lidarScan(laserMsg{202});
referenceScan = lidarScan(scan.LaserScans{80});
currentScan = lidarScan(scan.LaserScans{100});
% maxrange of laser
maxrange=5.6;


%%
% Display the two scans. Notice there are translational and rotational 
% offsets, but some features still match.
currScanCart = currentScan.Cartesian;
refScanCart = referenceScan.Cartesian;
figure
plot(refScanCart(:,1), refScanCart(:,2), 'k.');
hold on
plot(currScanCart(:,1), currScanCart(:,2), 'r.');
legend('Reference laser scan', 'Current laser scan', 'Location', 'NorthWest');

%% Run Scan Matching Algorithm and Display Transformed Scan
% Pass these two scans to the scan matching function. |<docid:robotics_ref.bvlvwfu-1 matchScans>| 
% calculates the relative pose of the current scan with respect to the
% reference scan.
transform = matchScans(currentScan, referenceScan)

% versatz = 0.338;
%Versatz des Laserscanner vom Drehpunkt ber�cksichtigen !!!!!!!!!!
%  theta= pi-transform(3); %theta in rad
%  transform(1) = transform(1)% *(cos(theta))*versatz; %x
%  transform(2) = transform(2)% *(sin(theta))*versatz; %y
%   
%transform(1) =  transform(1)/3.1415; 
%transform(2) =  transform(2)/(2*pi); 
%transform(3) = transform(3)/pi; 
 %[transform, stats] = matchScans(currScanRanges, currScanAngles, refScanRanges, refScanAngles, ...
  %      'SolverAlgorithm', 'fminunc', 'MaxIterations', 500, 'InitialPose', transform);
%%
% To visually verify that the relative pose was calculated correctly,
% transform the current scan by the calculated pose using |<docid:robotics_ref.bvlvwih-1 transformScan>|. 
% This transformed laser scan can be used to visualize the result.
transScan = transformScan(currentScan, transform);

%% 
% Display the reference scan alongside the transformed current laser scan.
% If the scan matching was successful, the two scans should be
% well-aligned.
figure
plot(refScanCart(:,1), refScanCart(:,2), 'k.');
hold on
transScanCart = transScan.Cartesian;
plot(transScanCart(:,1), transScanCart(:,2), 'r.');
legend('Reference laser scan', 'Transformed current laser scan', 'Location', 'NorthWest');

%% Build Occupancy Grid Map Using Iterative Scan Matching
% If you apply scan matching to a sequence of scans, you can use it to
% recover a rough map of the environment. Use the |<docid:robotics_ref.bvaw60t-1 robotics.OccupancyGrid>|
% class to build a probabilistic occupancy grid map of the environment.

%%
% Create an occupancy grid object for a 15 meter by 15 meter area. 
% Set the map's origin to be [-7.5 -7.5].
map = robotics.OccupancyGrid(15, 15, 20);
map.GridLocationInWorld = [-7.5 -7.5]

%%
% Pre-allocate an array to capture the absolute movement of the robot.
% Initialize the first pose as |[0 0 0]|. All other poses are relative to 
% the first measured scan. 
numScans = 165; % numel(laserMsg);
initialPose = [0 0 0];
absolutePose = initialPose;
poseList = zeros(numScans,3);
poseList(1,:) = initialPose;
transform = initialPose;
refScanAngles = readScanAngles(scan.LaserScans{1});
currScanAngles = readScanAngles(scan.LaserScans{2});

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
for idx = 2:numScans
    % Process the data in pairs.
    referenceScan = lidarScan(scan.LaserScans{idx-1});
   % referenceScan = lidarScan(laserMsg{idx-1});
   
    %currentScanMsg = laserMsg{idx};
    %currentScan = lidarScan(currentScanMsg);
    currentScan = lidarScan(scan.LaserScans{idx});
    
    % Run scan matching. Note that the scan angles stay the same and do 
    % not have to be recomputed. To increase accuracy, set the maximum 
    % number of iterations to 500. Use the transform from the last
    % iteration as the initial estimate.
    [transform, stats] = matchScans(currentScan, referenceScan, ...
        'MaxIterations', 500, 'InitialPose', transform);
%     versatz = 0.338;
%     transform(3) = transform(3)/pi; %theta
%     transform(1) = transform(1) + sin(transform(3))*versatz; %x
%     transform(2) = transform(2) + cos(transform(3))*versatz; %y
     % The |Score| in the statistics structure is a good indication of the
    % quality of the scan match.
     currScanRanges = currentScan.Ranges;     
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

%% See Also
%
% * <docid:robotics_examples.example-MappingWithKnownPosesExample Mapping With Known Poses>

%% References
%%
% [1] P. Biber, W. Strasser, "The normal distributions transform: A
% new approach to laser scan matching," in Proceedings of IEEE/RSJ
% International Conference on Intelligent Robots and Systems
% (IROS), 2003, pp. 2743-2748

displayEndOfDemoMessage(mfilename)
