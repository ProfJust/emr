function poseEuler = youBot_Odom2Laser_Pose_Quat_2_Eul(posedata_quat)
%YOUBOT_POSE_QUAT_2 
% Berechnet die Odom-Pose in die LaserScan Pose um
% des youBots also     position [x,y,z]
% und Quaternion  orientation [x,y,z,w]
% Version vom 09.6.2020 by OJ
%------------------------------------------------------

% Winkel berechnet sich aus den Quarternionen 
    % pose als Quaternion speichern
    % Vektor mit 4 Spalten und einer Zeile => "..."
    myQuat = [ posedata_quat.Pose.Pose.Orientation.X...
               posedata_quat.Pose.Pose.Orientation.Y...
               posedata_quat.Pose.Pose.Orientation.Z...
               posedata_quat.Pose.Pose.Orientation.W];
    eulZYX = quat2eul(myQuat);
    theta = eulZYX(3);  
    
     
    %xY-Daten des youBot sind ist nicht die exakte Funktion des
    %Hokuyo, Achse des Scanners ca 30 cm in X-Richtung
    % L�nge Base 58cm, Tr�gerblech - Mitte LAser ca. 4 cm
    versatz = 0.338; % 0.58/2 +0.05;
  
    poseX = posedata_quat.Pose.Pose.Position.X  + cos(theta)*versatz; 
    poseY = posedata_quat.Pose.Pose.Position.Y  + sin(theta)*versatz; 
    
    poseEuler = [poseX, poseY, theta];
    
end



