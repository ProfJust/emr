%P_VII_01_Gazebo_youBot_Pfad_folgen_PurePursuit.m 
%Path Following for a Differential Drive Robot
%-----------------------------------------------------------------
%roslaunch youbot_gazebo_robot empty_world.launch
rosshutdown
%rosinit('http://192.168.2.128:11311','NodeName','/MatLabHome')
rosinit('http://127.0.0.1:11311','NodeName','/MatLabHome')
%sub1    = rossubscriber ('base_scan','sensor_msgs/LaserScan');
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');

pubVel  = rospublisher  ('cmd_vel', 'geometry_msgs/Twist');
msgsBaseVel = rosmessage(pubVel);

%Define a set of waypoints for the desired path for the robot
path = [0.00    0.00;
    5.0    0.0;
    5.0    5.0;
    0.0    5.0;
    0.0   0.0;
    -2.0   0.00];

zielAnz = 6; %Anzahl der Ziele in path
zielAkt=2; % aktuelles  Ziel
% Set the current location and the goal location of the robot as defined by the path
robotCurrentLocation = path(1,:);
robotGoal = path(zielAkt,:);
%Assume an initial robot orientation
%(the robot orientation is the angle between the robot heading and the positive X-axis, measured counterclockwise).
initialOrientation = 0;
%Define the current pose for the robot [x y theta]
robotCurrentPose = [robotCurrentLocation initialOrientation];
%Initialize the robot simulator
robotRadius = 0.4;

%Visualize the desired path
close all;
figure;
plot(path(:,1), path(:,2),'k--d')
hold on;
xlim([-10 10])
ylim([-10 10])

%Define the path following controller
%Nutze den PurePursuit-Algorithmus - Konfiguration der Paramater
controller = robotics.PurePursuit
controller.Waypoints = path;
controller.DesiredLinearVelocity = 0.4;
controller.MaxAngularVelocity = 0.5;
controller.LookaheadDistance = 0.48;

%Using the path following controller, drive the robot over the desired waypoints
goalRadius = 0.5;
controlRate = robotics.Rate(10);

while( zielAkt <= zielAnz )
    % Extract current location information ([X,Y,theta]) from the current pose of the
    % robot
    % pose holen und speichern
    posedata = receive(subOdom,10);
    X = posedata.Pose.Pose.Position.X;
    Y = posedata.Pose.Pose.Position.Y;
    % Winkel berechnet sich aus den Quarternionen
    % pose als Quaternion speichern
    myQuat = [ posedata.Pose.Pose.Orientation.X posedata.Pose.Pose.Orientation.Y posedata.Pose.Pose.Orientation.Z posedata.Pose.Pose.Orientation.W];
    eulZYX = quat2eul(myQuat);
    theta = eulZYX(3);
    robotCurrentPose = [X, Y, theta]
    robotCurrentLocation = [X, Y];
    plot(X,Y, 'b--.');
    % Berechne gew�nschte Bewegung [v, omega] aus der Pose
    % Compute the controller outputs, i.e., the inputs to the robot
       [v, omega, lookaheadPoint] = controller(robotCurrentPose)
    
    % Simulate the robot using the controller outputs.
    %drive(robot, v, omega);
    msgsBaseVel.Linear.X  = v;
    msgsBaseVel.Angular.Z = omega;
    send(pubVel ,msgsBaseVel);
    robotCurrentPose = [X, Y, theta]
    
    % Re-compute the distance to the goal
    disp(['Naechster Wegpunkt ',num2str( zielAkt),'  X:', num2str(robotGoal(1)), ' Y:', num2str(robotGoal(2))] );
    
    distanceToGoal = sqrt( (robotCurrentPose(1) - robotGoal(1))^2 + (robotCurrentPose(2) - robotGoal(2))^2)
    % distanceToGoal = norm(robotCurrentLocation - robotGoal)
    if(distanceToGoal <= goalRadius)
        if (zielAkt >= zielAnz)
            disp('######### Endziel erreicht ############');
            %Robot Anhalten
            msgsBaseVel.Linear.X=0;
            msgsBaseVel.Angular.Z=0;
            send(pubVel,msgsBaseVel);
            pause(30);
            exit();
        else
            disp('######## Zwischenziel-Nr.:  ');
            disp(zielAkt);
            disp(' erreicht ##########');
        end
        %Robot Anhalten
        msgsBaseVel.Linear.X=0;
        msgsBaseVel.Angular.Z=0;
        send(pubVel,msgsBaseVel);
        pause(2);
        if (zielAkt < zielAnz)
            zielAkt = zielAkt+1
            robotGoal = path(zielAkt,:)            
        end
    end 
       
    waitfor(controlRate);
    
end %while







