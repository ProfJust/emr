function yaw = yawFromPose( odomMsg)
    w = odomMsg.Pose.Pose.Orientation.W;
    z = odomMsg.Pose.Pose.Orientation.Z;
    x = odomMsg.Pose.Pose.Orientation.X;
    y = odomMsg.Pose.Pose.Orientation.Y;
    
    t3 = + 2.0 * (w * z + x * y);
    t4 = +1.0 - 2.0 * (y * y + z * z);
    yaw = atan2(t3, t4);  % Drehung um Z-Achse in rad
end

%% 

%% yaw von Hand rechnen (4debug)
%     w = odomMsg.Pose.Pose.Orientation.W;
%     z = odomMsg.Pose.Pose.Orientation.Z;
%     x = odomMsg.Pose.Pose.Orientation.X;
%     y = odomMsg.Pose.Pose.Orientation.Y;
%     
%     t3 = + 2.0 * (w * z + x * y);
%     t4 = +1.0 - 2.0 * (y * y + z * z);
%     yaw = atan2(t3, t4)  % Drehung um Z-Achse in rad