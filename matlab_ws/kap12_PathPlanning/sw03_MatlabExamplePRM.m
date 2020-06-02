%MatlabExamplePRM.m
%file:///D:/Program%20Files/MATLAB/R2016b/help/robotics/examples/path-following-for-a-differential-drive-robot.html

% Start Robot Simulator with simple map
delete(robot) % cancel old robot if necessary
robot = ExampleHelperRobotSimulator('simpleMap',2);
robot.enableLaser(false);
robotRadius = 0.1;
robot.setRobotSize(robotRadius);
robot.showTrajectory(true);

%You can compute the path using the PRM path planning algorithm.
mapInflated = copy(robot.Map);
show(mapInflated)
inflate(mapInflated,robotRadius);
show(mapInflated)

% PRM - konfigurieren
prm = robotics.PRM(mapInflated); %Karte setzen
prm.NumNodes = 20;              %Anzahl der Knotenpunkte
prm.ConnectionDistance = 10;     %Maximale Verbindungsdistanz

%Find a path between the start and end location.
startLocation = [2.0 1.0];
endLocation = [12.0 1.5];
path = findpath(prm, startLocation, endLocation)

initialOrientation = 0;
robotCurrentLocation = path(1,:);
robotCurrentPose = [robotCurrentLocation initialOrientation];
robot.setRobotPose(robotCurrentPose);



show(prm, 'Map', 'on', 'Roadmap', 'on');
%show(prm, 'Map', 'off', 'Roadmap', 'off');


%release(controller);
controller.Waypoints = path;
robotGoal = path(end,:);
distanceToGoal = norm(robotCurrentLocation - robotGoal);
goalRadius = 0.1;

%reset(controlRate);
while( distanceToGoal > goalRadius )
    
     % Extract current location information from the current pose
    robotCurrentPose = robot.getRobotPose;

    % Compute the controller outputs, i.e., the inputs to the robot
    [v, omega] = controller(robotCurrentPose);

    % Simulate the robot using the controller outputs
    drive(robot, v, omega);

   

    % Re-compute the distance to the goal
    distanceToGoal = norm(robotCurrentPose(1:2) - robotGoal);

    waitfor(controlRate);
end
%Stop the robot.
drive(robot, 0, 0);



