%% sw04_slam_example_online_path_PRM.m
% OJ 22.6.2020
% youBot-Path per PRM fahren lassen, dabei slammen
% sehen wie währendessen die Karte aufgezeichnet wird
% Wegpunkt nur auf bereits als frei gescannten Punkt setzbar
% ----------------------------------------
% close all; %figures
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
%% h[v_x, v_y, omega] = step_PurePursuit_youbot(controller, robotCurrentPose);
    goalRadius = 0.5;
    % Inflate by the radius given in number of Grid cells.
    youBotRadiusGrid = 8;
    goalIsSet = false;
    controller = robotics.PurePursuit;
    controller.DesiredLinearVelocity = 0.3;
    controller.MaxAngularVelocity = 0.3;  
    controller.LookaheadDistance = 0.8;   
%% Create lidarSLAM-Objekt
    maxLidarRange = 5.6;
    mapResolution = 20;
    slamAlg = lidarSLAM(mapResolution, maxLidarRange);
    slamAlg.LoopClosureThreshold = 210;
    slamAlg.LoopClosureSearchRadius = 5.6;
%% figures
    close all; %figures
    firstLoopClosure = false;
    title('Occupancy Grid Map Built Using Lidar SLAM');
    

%% -----------------------
i=1;
while (true)
    %% LaserScan empfangen
    scandata = receive(subScan,10);
    scans{i} = lidarScan(scandata);    
    [isScanAccepted,loopClosureInfo,optimizationInfo] = addScan(slamAlg,scans{i});
    if isScanAccepted
        %figure(1); show(slamAlg);
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
    map.OccupiedThreshold = 0.8;
    figure(2); show(map);
    hold on
    show(slamAlg.PoseGraph, 'IDs', 'off');
    hold off
    %% move Robot
    if goalIsSet==false
         close all; %figures
        mapInflated = map;
        inflate(mapInflated,youBotRadiusGrid,'grid');
        figure(3); show(mapInflated);
        %--- PRM ---
         mapInflated.OccupiedThreshold = 0.8; % Schwellwert für Besetzt (0..1 je höher desto dunkler)
         prm = robotics.PRM(mapInflated);
         prm.NumNodes = 200;
         prm.ConnectionDistance = 3;
         startLocation = [optimizedPoses(i,1),optimizedPoses(i,1)];   %latest
         startValid = false;
         while  startValid == false
             % Grauwert der StartLocation holen
             iOccvalStart = getOccupancy(mapInflated, startLocation);
             if iOccvalStart >= map.FreeThreshold
                disp(' Startpunkt eingeben');
                figure(3);
                startLocation = ginput(1) % get 1 Point 
             else
                 startValid = true;
             end
         end
         % setOccupancy(mapInflated,startLocation,0.0) %setze Start auf unbesetzt
         goalValid = false;
         while goalValid == false
            disp(' Zielpunkt eingeben');
            goalLocation =  ginput(1) % 1 Pkt eingeben
            % Wenn Position kein Hindernis Grauwert>Besetzt
            iOccval = getOccupancy(mapInflated,goalLocation);
            if iOccval <= map.OccupiedThreshold  
                 goalValid = true;
            end
         end
%       controller.Waypoints = [0.0, 0.0; 1.0 ,0.0; 2.0 ,0.0];   
%       controller.Waypoints = [startLocation; goalLocation];  
%ADD: check if golaLocation is empty => new Input
        path = findpath(prm, startLocation, goalLocation);
        show( prm, 'Map', 'on', 'Roadmap', 'on');
        controller.Waypoints = path
        goalIsSet = true;
    end
    
    if i>2
        robotCurrentPose =  optimizedPoses(i,:); %latest    
        dist2goal = norm([robotCurrentPose(1),robotCurrentPose(2)]  - goalLocation)
        if dist2goal > goalRadius
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
            goalIsSet=false;
            continue;
        end
    end
    i=i+1;
end