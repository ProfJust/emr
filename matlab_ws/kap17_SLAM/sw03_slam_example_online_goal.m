%% sw03_slam_example_online_goal.m
% Das Beispiel aus (s.u.) für den youBot angepasst
% https://de.mathworks.com/help/nav/ug/...
% implement-online-simultaneous-localization-and-mapping-with-lidar-scans.html
% OJ 22.6.2020
% youBot per rqt fahren lassen
% sehen wie währendessen die Karte aufgezeichnet wird
% ----------------------------------------
%% ROS Init
    % gazebo roslaunch emr_worlds youbot_arena.launch
    ROS_Node_init_localhost;

    %  realer youBot03
    % try
    %    rosnode list
    % catch exp   % Error from rosnode list
    %    rosinit('http://192.168.0.30:11311','NodeName','/RoboLabHome2')
    % end
    subScan = rossubscriber('base_scan','sensor_msgs/LaserScan');
    pubVel  = rospublisher  ('cmd_vel', 'geometry_msgs/Twist');
    msgsBaseVel = rosmessage(pubVel);
%% Pfad folgen mit PurePursuit-Controller
    goalRadius = 0.5;
    % Inflate by the radius given in number of Grid cells.
    youBotRadiusGrid = 3.0;
    goalIsSet = false;
    controller = robotics.PurePursuit;
    controller.DesiredLinearVelocity = 0.3;
    controller.MaxAngularVelocity = 0.3;  
    controller.LookaheadDistance = 2.5;   
%% Create lidarSLAM-Objekt
    maxLidarRange = 5.6;
    mapResolution = 20;
    slamAlg = lidarSLAM(mapResolution, maxLidarRange);
    slamAlg.LoopClosureThreshold = 210;
    slamAlg.LoopClosureSearchRadius = 5.6;
%% figures
    close all; %figures
    firstLoopClosure = false;
    figure; title('Occupancy Grid Map Built Using Lidar SLAM');
    i=1;

%% -----------------------
while (true)
    %% LaserScan empfangen
    scandata = receive(subScan,10);
    scans{i} = lidarScan(scandata);    
    [isScanAccepted,loopClosureInfo,optimizationInfo] = addScan(slamAlg,scans{i});
    if isScanAccepted
        show(slamAlg);
        if optimizationInfo.IsPerformed && ~firstLoopClosure
            firstLoopClosure = true;
            show(slamAlg,'Poses','off');
            hold on;
            show(slamAlg.PoseGraph);
            % hold off;
            title('First loop closure');
            snapnow
        end
    end
    %% Build Occupancy Grid Map
    [scans, optimizedPoses]  = scansAndPoses(slamAlg);
    map = buildMap(scans, optimizedPoses, mapResolution, maxLidarRange);
    show(map);
    hold on
    show(slamAlg.PoseGraph, 'IDs', 'off');
    hold off
    %% move Robot
    if goalIsSet==false
%         mapInflated = map
%         inflate(mapInflated,youBotRadiusGrid,'grid');
%         show(mapInflated);
%         %--- PRM ---
% %         prm = robotics.PRM(mapInflated);
% %         prm.NumNodes = 100;
% %         prm.ConnectionDistance =1;
         startLocation = [optimizedPoses(i,1),optimizedPoses(i,1)]   %latest
         disp(' Zielpunkt eingeben');
         goalLocation =  ginput(1)
%        path = findpath(prm, startLocation, goalLocation);
%       controller.Waypoints = [0.0, 0.0; 1.0 ,0.0; 2.0 ,0.0];   %path;
        controller.Waypoints = [startLocation; goalLocation];  
        goalIsSet = true;
    end
    
    if i>2
        robotCurrentPose =  optimizedPoses(i,:); %latest    
        
        if norm([robotCurrentPose(1),robotCurrentPose(2)]  - goalLocation) > goalRadius
            % Compute the controller outputs, i.e., the inputs to the robot
            [v_x, v_y, omega] = step_PurePursuit_youbot(controller, robotCurrentPose);
            % drive-youBot
            msgsBaseVel.Linear.X  = v_x;
            msgsBaseVel.Linear.Y  = v_y; % beim youBot auch y-Bewegung moeglich
            msgsBaseVel.Angular.Z = omega;
            send(pubVel ,msgsBaseVel)   
        else
           % stop youBot
            msgsBaseVel.Linear.X  = 0;
            msgsBaseVel.Linear.Y  = 0; % beim youBot auch y-Bewegung moeglich
            msgsBaseVel.Angular.Z = 0;
            send(pubVel ,msgsBaseVel)   
            disp(' Zielpunkt erreicht');
            goalIsSet=false
            continue;
        end
    end
    i=i+1;
end