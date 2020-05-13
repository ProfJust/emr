% Turtle_Drehung_Rechts.m
%------------------------------------------

% ------------ Drehung -------------------
var='Z';
dir='Angular';
speed = -0.5;
% ROS-Msg zum losfahren
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS
poseTheta = mySub.LatestMessage.Theta;

% --- epsilon Umgenung erreicht? -----
while ~((sollTheta <= poseTheta + epsilon) && (sollTheta >= poseTheta - epsilon))
    send(myPublisher,myMsg) % => ROS
    % Debug Ausgabe
    str = sprintf('sollTheta: %f poseTheta: %f poseX: %f poseY: %f', sollTheta, poseTheta);
    disp(str)
    poseTheta = mySub.LatestMessage.Theta;
    % pause(0.1);
end

% ROS-Msg zum Anhalten (speed = 0)
speed = 0;
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS
