% stop_goto_beer.m
%  ---------------------------
% EMR am 13.5.2020
%-----------------------------
% Gazebo-youBot faehrt zum Bier
% ########## UBUNTU-Problem ######%  um bei plots Fehler
% "Caught unexpected fl::except::IInternalException" zu vermeiden
% $ matlab -softwareopengl
%#################################################
%------------------------------------------------------------------------

ROS_Node_init_localhost;

%% --- Subscriber und Publisher beim Master anmelden
pub1 = rospublisher ('cmd_vel', 'geometry_msgs/Twist');
msgsBase = rosmessage(pub1);

%%STOP
disp('STOP');
msgsBase.Linear.X=0.0;
msgsBase.Linear.Y=0.0;
send(pub1,msgsBase);

