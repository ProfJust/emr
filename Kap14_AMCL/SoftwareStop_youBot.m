%% ROS INITIALIZATION - Subscriber | Publisher
% Publisher
tic;
pubVel = rospublisher ('cmd_vel', 'geometry_msgs/Twist');
msgsBaseVel = rosmessage(pubVel);
toc;

% Execution
msgsBaseVel.Linear.X = 0;
msgsBaseVel.Linear.Y = 0;
msgsBaseVel.Angular.Z = 0;
send(pubVel,msgsBaseVel);
disp('NOTAUS!');