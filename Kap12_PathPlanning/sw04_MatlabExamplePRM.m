%MatlabExamplePRM.m
%file:///D:/Program%20Files/MATLAB/R2016b/help/robotics/examples/path-following-for-a-differential-drive-robot.html
%
%!!!! vorher einmal sw01
% MatlabExample_PathFollowingforaDifferentialDriveRobot.m
% laufen lassen


% Start Robot Simulator with simple map
%delete(robot) %cancel old robot
robot = ExampleHelperRobotSimulator('simpleMap',2);
robot.enableLaser(false);
robotRadius =0.5;
robot.setRobotSize(robotRadius);
robot.showTrajectory(true);

%You can compute the path using the PRM path planning algorithm.
mapInflated = copy(robot.Map);
show(mapInflated)
inflate(mapInflated,robotRadius);
show(mapInflated)

% PRM - konfigurieren
prm = robotics.PRM(mapInflated); %Karte setzen
prm.NumNodes = 200;              %Anzahl der Knotenpunkte
prm.ConnectionDistance = 10;     %Maximale Verbindungsdistanz

%Find a path between the start and end location.
startLocation = [2.0 1.0];
endLocation = [12.0 1.5];
path = findpath(prm, startLocation, endLocation)

show(prm, 'Map', 'on', 'Roadmap', 'on');
%show(prm, 'Map', 'off', 'Roadmap', 'off');


release(controller);
controller.Waypoints = path;
robotCurrentLocation = path(1,:);
robotGoal = path(end,:);
initialOrientation = 0;
robotCurrentPose = [robotCurrentLocation initialOrientation];
robot.setRobotPose(robotCurrentPose);
distanceToGoal = norm(robotCurrentLocation - robotGoal);
goalRadius = 0.1;

%reset(controlRate);
while( distanceToGoal > goalRadius )

    % Compute the controller outputs, i.e., the inputs to the robot
    [v, omega] = controller(robot.getRobotPose);
   
    % Simulate the robot using the controller outputs
    drive(robot, v, omega);

    % Extract current location information from the current pose
    robotCurrentPose = robot.getRobotPose;

    % Re-compute the distance to the goal
    distanceToGoal = norm(robotCurrentPose(1:2) - robotGoal);

    waitfor(controlRate);
end
%Stop the robot.
drive(robot, 0, 0);



