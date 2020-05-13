% Turtle_Y_Fahrt.m
% ------------ Y-Fahrt -------------------
var='X';
dir='Linear';
speed = 0.5;
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS
poseY = mySub.LatestMessage.Y;
% --- epsilon Umgenung erreicht? -----
while ~((goalY <= poseY + epsilon) && (goalY >= poseY - epsilon))
    poseX = mySub.LatestMessage.X;
    poseY = mySub.LatestMessage.Y;
    % Debug Ausgabe
    str = sprintf('goalY: %f poseY: %f toGo %f', goalY, poseY, abs(poseY-goalY));
    disp(str)
    pause(STEPP_PAUSE);
    distY = goalY - poseY;
     if(abs(distY) > 0.5) 
         speed = 1.0;
     else
         speed = 0.2;
     end
     myMsg.(dir).(var)=speed;
     send(myPublisher,myMsg) % => ROS
    % muss wiederholt werden, sonst bleibt Turtle stehen
end

% ROS-Msg zum Anhalten (speed = 0)
speed = 0;
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS
