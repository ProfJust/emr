% Path Following for a Differential Drive Robot
% Matlab Example
% file:///D:/Program%20Files/MATLAB/R2016b/help/robotics/examples/path-following-for-a-differential-drive-robot.html
%-----------------------------------------------------------------
%delete(robot)
%Define a set of waypoints for the desired path for the robot
path = [2.00    1.00;
    1.25    1.75;
    5.25    8.25;
    7.25    8.75;
    11.75   10.75;
    12.00   10.00];

% Set the current location and the goal location of the robot as defined by the path
robotCurrentLocation = path(1,:);
robotGoal = path(end,:);
%Assume an initial robot orientation 
%(the robot orientation is the angle between the robot heading and the positive X-axis, measured counterclockwise).
initialOrientation = 0;

%Define the current pose for the robot [x y theta]
robotCurrentPose = [robotCurrentLocation initialOrientation];

%Initialize the robot simulator
robotRadius = 0.4;

robot = ExampleHelperRobotSimulator('emptyMap',2);
robot.enableLaser(false);
robot.setRobotSize(robotRadius);
robot.showTrajectory(true);
robot.setRobotPose(robotCurrentPose);

%Visualize the desired path
plot(path(:,1), path(:,2),'k--d')
xlim([0 13])
ylim([0 13])

%Define the path following controller
%Nutze den PurePursuit-Algorithmus
controller = robotics.PurePursuit
controller.Waypoints = path;
controller.DesiredLinearVelocity = 0.3;
controller.MaxAngularVelocity = 2;
controller.LookaheadDistance = 0.5;

%Using the path following controller, drive the robot over the desired waypoints
goalRadius = 0.1;
distanceToGoal = norm(robotCurrentLocation - robotGoal);

controlRate = robotics.Rate(10);
while( distanceToGoal > goalRadius )

        % Berechne gew�nschte Bewegung [v, omega] aus der Pose
    % Compute the controller outputs, i.e., the inputs to the robot
    [v, omega] = controller(robot.getRobotPose);

    % Simulate the robot using the controller outputs.
    drive(robot, v, omega);

    % Extract current location information ([X,Y]) from the current pose of the robot
    robotCurrentPose = robot.getRobotPose;
    
    % Re-compute the distance to the goal
    distanceToGoal = norm(robotCurrentPose(1:2) - robotGoal);

    waitfor(controlRate);

end


delete(robot)







