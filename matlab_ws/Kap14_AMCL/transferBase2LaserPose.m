function poseBase = transferBase2LaserPose(poseLaser)
% transferLaser2BasePose
% Berechnet die Odom-Pose/Base_link aus der LaserScan Pose um
% Version vom 25.5.2021 by OJ
% Pose im Format [x, y, yaw]
%------------------------------------------------------
versatz = 0.3; %sensorTransform.Transform.Translation.X
theta =  poseLaser(3);

poseBase = [
    poseLaser(1) + cos(theta)*versatz... 
    poseLaser(2) + sin(theta)*versatz... 
    poseLaser(3)];


end



