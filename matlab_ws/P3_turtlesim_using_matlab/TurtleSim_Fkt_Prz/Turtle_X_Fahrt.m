% Turtle_X_Fahrt.m
% ------------ X-Fahrt -------------------
var='X';
dir='Linear';
speed = 0.3;
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS
poseX = mySub.LatestMessage.X;
% --- epsilon Umgenung erreicht? -----
while ~((goalX <= poseX + epsilon) && (goalX >= poseX - epsilon))
    
    poseX = mySub.LatestMessage.X;
    poseY = mySub.LatestMessage.Y;
    % Debug Ausgabe
     str = sprintf('goalX: %f poseX: %f toGo %f', goalX, poseX, abs(poseX-goalX));
    disp(str)
     pause(STEPP_PAUSE);
     distX = goalX - poseX;
     if(abs(distX) > 0.5) 
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

