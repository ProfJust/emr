% STOPP_youBot.m
%--------------------------------------------------------------
% OJ fuer EMR am 18.5.2021 , tested OK
%-----------------------------------------------------------------------

try
    rosnode list
catch exp   % Error from rosnode list
    rosinit
end
pubVel  = rospublisher  ('cmd_vel', 'geometry_msgs/Twist');
msgsBaseVel = rosmessage(pubVel);


%% Robot Anhalten
msgsBaseVel.Linear.X=0;
msgsBaseVel.Angular.Z=0;
send(pubVel,msgsBaseVel);


disp('##### Robot stopped ####');




