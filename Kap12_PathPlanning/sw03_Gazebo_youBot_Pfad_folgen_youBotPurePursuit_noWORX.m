%sw03_P7_01_Gazebo_youBot_Pfad_folgen_PurePursuit.m
%Path Following fuer den youBot mit dem eigenen PurePursuit
%Version 11.6.2019
%-----------------------------------------------------------------
%roslaunch youbot_gazebo_robot empty_world.launch
rosshutdown
rosinit('http://127.0.0.1:11311','NodeName','/MatLabHome')

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
zielAkt = 2; % aktuelles  Ziel, 1 ist Startpunkt
% Set the current location and the goal location of the robot as defined by the path
robotCurrentLocation = path(1,:);
robotGoal = path(zielAkt,:);
%Assume an initial robot orientation
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

%Pfad folgen mit PurePursuit-Controller
controller = robotics.PurePursuit;
controller.DesiredLinearVelocity = 0.3;
controller.MaxAngularVelocity = 0.3;
controller.LookaheadDistance = 0.5;
controller.Waypoints = path;

distanceToGoal = norm(robotCurrentLocation - robotGoal);
goalRadius = 0.2;

while( zielAkt <= zielAnz )
    % pose holen und speichern
    posedata = receive(subOdom,10);
    X = posedata.Pose.Pose.Position.X;
    Y = posedata.Pose.Pose.Position.Y;
    % Winkel berechnet sich aus den Quarternionen
    myQuat = [ posedata.Pose.Pose.Orientation.X posedata.Pose.Pose.Orientation.Y posedata.Pose.Pose.Orientation.Z posedata.Pose.Pose.Orientation.W];
    eulZYX = quat2eul(myQuat);
    theta = eulZYX(3);
    
    robotCurrentPose = [X, Y, theta]
    plot(X,Y, 'b--.');
    
    % Berechne gewuenschte Bewegung [v, omega] aus der Pose
    [v_x, v_y, omega] = step_PurePursuit_youbot(controller, robotCurrentPose);
    fprintf('%f %f %f \n',v_x, v_y, omega); 
    
    % Simulate the robot using the controller outputs.
    msgsBaseVel.Linear.X  = v_x;
    msgsBaseVel.Linear.Y  = v_y;
    msgsBaseVel.Angular.Z = omega;
    send(pubVel ,msgsBaseVel);
    
       
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
        %Robot 2 sec Anhalten
        msgsBaseVel.Linear.X=0;
        msgsBaseVel.Angular.Z=0;
        send(pubVel,msgsBaseVel);
        pause(2);
        if (zielAkt < zielAnz)
            zielAkt = zielAkt+1
            robotGoal = path(zielAkt,:)            
        end
    end 
       
   % waitfor(controlRate);
    
end %while







