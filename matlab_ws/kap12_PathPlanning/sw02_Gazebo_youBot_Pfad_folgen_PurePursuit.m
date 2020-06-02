% sw02_Gazebo_youBot_Pfad_folgen_PurePursuit.m 
% Path Following for a Differential Drive Robot
%-----------------------------------------------------------------

% clear worksapce;
%%roslaunch youbot_gazebo_robot empty_world.launch
ROS_Node_init_localhost


subOdom = rossubscriber ('/odom', 'nav_msgs/Odometry');
pubVel  = rospublisher ('/cmd_vel', 'geometry_msgs/Twist');
msgsBaseVel = rosmessage(pubVel);

%% PAth Setup
% Define a set of waypoints for the desired path for the robot
path = [0.00    0.00;
    5.0    0.0;
    5.0    5.0;
    0.0    5.0;
    0.0   0.0;
    -2.0   0.00];

zielAnz = 6; %Anzahl der Ziele in path
zielAkt=2; % Index aktuelles  Ziel
robotGoal = path(zielAkt,:);
goalRadius = 0.5;
%Visualize the desired path
close all;
figure;
plot(path(:,1), path(:,2),'k--d')
hold on;
xlim([-10 10])
ylim([-10 10])

%% Robot Setup
% Set the current location and the goal location of the robot as defined by the path
robotCurrentLocation = path(1,:);
% Assume an initial robot orientation
%(the robot orientation is the angle between the robot heading and the positive X-axis, measured counterclockwise).
initialOrientation = 0;
%Define the current pose for the robot [x y theta]
robotCurrentPose = [robotCurrentLocation initialOrientation];
%Initialize the robot simulator
robotRadius = 0.4;


%% Setup the path following controller
% Nutze den PurePursuit-Algorithmus - Konfiguration der Paramater
controller = robotics.PurePursuit;
controller.Waypoints = path;
controller.DesiredLinearVelocity = 0.4;
controller.MaxAngularVelocity = 0.5;
controller.LookaheadDistance = 0.48;
%Using the path following controller, drive the robot over the desired waypoints
controlRate = robotics.Rate(10);

%%
while( zielAkt <= zielAnz )
    %% pose ([X,Y,theta]) holen und speichern
        posedata = receive(subOdom,10); % Timeou 10 sek
        % Bemerkung: Es kommt vor, das Gazebo den /odom Topic nicht
        % publisht, warum ? 
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
    
    % Berechne gewuenschte Bewegung [v, omega] aus der Pose
    % Compute the controller outputs, i.e., the inputs to the robot
       [v, omega, lookaheadPoint] = controller(robotCurrentPose)
    
   
    %% drive(robot, v, omega);
    msgsBaseVel.Linear.X  = v;
    msgsBaseVel.Angular.Z = omega;
    send(pubVel ,msgsBaseVel);
    
    %% Re-compute the distance to the goal
    disp(['Naechster Wegpunkt ',num2str( zielAkt),'  X:', num2str(robotGoal(1)), ' Y:', num2str(robotGoal(2))] );
    
    distanceToGoal = sqrt( (robotCurrentPose(1) - robotGoal(1))^2 + (robotCurrentPose(2) - robotGoal(2))^2)
    % distanceToGoal = norm(robotCurrentLocation - robotGoal)
    
    if(distanceToGoal <= goalRadius)      
        %Robot am Zwischenziel Anhalten
        msgsBaseVel.Linear.X=0;
        msgsBaseVel.Angular.Z=0;
        send(pubVel,msgsBaseVel);
        pause(2);
        if (zielAkt < zielAnz)
            disp('######## Zwischenziel-Nr.:  ');
            disp(zielAkt);
            disp(' erreicht ##########');
            % neues Ziel setzen
            zielAkt = zielAkt+1
            robotGoal = path(zielAkt,:)            
        end
    end 
       
    waitfor(controlRate);
    
end %while

disp('######### Endziel erreicht ############');






