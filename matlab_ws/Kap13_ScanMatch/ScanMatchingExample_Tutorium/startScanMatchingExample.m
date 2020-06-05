%https://de.mathworks.com/help/robotics/examples/estimate-robot-pose-with-scan-matching.htmling
load scanMatchingData.mat

referenceScan = lidarScan(laserMsg{180});
currentScan = lidarScan(laserMsg{202});

currScanCart = currentScan.Cartesian;
refScanCart = referenceScan.Cartesian;
figure
plot(refScanCart(:,1), refScanCart(:,2), 'k.');
hold on
plot(currScanCart(:,1), currScanCart(:,2), 'r.');
legend('Reference laser scan', 'Current laser scan', 'Location', 'NorthWest');

transform = matchScans(currentScan, referenceScan)
transScan = transformScan(currentScan, transform);

figure
plot(refScanCart(:,1), refScanCart(:,2), 'k.');
hold on
transScanCart = transScan.Cartesian;
plot(transScanCart(:,1), transScanCart(:,2), 'r.');
legend('Reference laser scan', 'Transformed current laser scan', 'Location', 'NorthWest');

map = robotics.OccupancyGrid(15, 15, 20);
map.GridLocationInWorld = [-7.5 -7.5]

numScans = numel(laserMsg);
initialPose = [0 0 0];
poseList = zeros(numScans,3);
poseList(1,:) = initialPose;
transform = initialPose;

% Loop through all the scans and calculate the relative poses between them
for idx = 2:numScans
    % Process the data in pairs.
    referenceScan = lidarScan(laserMsg{idx-1});
    currentScanMsg = laserMsg{idx};
    currentScan = lidarScan(currentScanMsg);
    
    % Run scan matching. Note that the scan angles stay the same and do 
    % not have to be recomputed. To increase accuracy, set the maximum 
    % number of iterations to 500. Use the transform from the last
    % iteration as the initial estimate.
    [transform, stats] = matchScans(currentScan, referenceScan, ...
        'MaxIterations', 500, 'InitialPose', transform);
    
    % The |Score| in the statistics structure is a good indication of the
    % quality of the scan match. 
    if stats.Score / currentScan.Count < 1.0
        disp(['Low scan match score for index ' num2str(idx) '. Score = ' num2str(stats.Score) '.']);
    end
    
    % Maintain the list of robot poses. 
    absolutePose = exampleHelperComposeTransform(poseList(idx-1,:), transform);
    poseList(idx,:) = absolutePose;
       
    % Integrate the current laser scan into the probabilistic occupancy
    % grid.
    insertRay(map, absolutePose, currentScan, double(currentScanMsg.RangeMax));

end

figure
show(map);
title('Occupancy grid map built using scan matching results');

hold on
plot(poseList(:,1), poseList(:,2), 'bo', 'DisplayName', 'Estimated robot position');
legend('show', 'Location', 'NorthWest')