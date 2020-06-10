function poseEuler = youBot_Pose_Quat_2_Eul(posedata_quat)

%% youBot_Pose_Quat_2_Eul
% Berechnet aus der Quaternion [x,y,z,w]
% die Pose in [x,y,theta]
% Versatz nur bei Odom 2 Laserscan notwenidg
% Version vom 9.6.2020 by OJ
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
    
    %% Kein Versatz !!!
    poseX = posedata_quat.Pose.Pose.Position.X    %+ cos(theta)*versatz; 
    poseY = posedata_quat.Pose.Pose.Position.Y    %+ sin(theta)*versatz; 
    
    poseEuler = [poseX, poseY, theta];
    
end



