% Turtle_Drehung.m
%------------------------------------------
% Richtung bestimmen
distX = goalX - poseX;
distY = goalY - poseY;
sollTheta = atan2(distY, distX); %-pi ..pi
% ------------ Drehung -------------------
var='Z';
dir='Angular';
if (sollTheta - poseTheta) < pi()  % wie herum ist Drehung kürzer
    speed = -0.5; %rechts herum
else
    speed = 0.5; %links herum
end
 % Auf Wertebereich 0..2pi bringen
if sollTheta < 0
     sollTheta = sollTheta + 2* pi();
end
if sollTheta > 2*pi()
     sollTheta = sollTheta - 2* pi();
end

% ROS-Msg zum losfahren
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS
poseTheta = mySub.LatestMessage.Theta; %linksherum 0..2pi, rechts 0.. -2pi
% Auf Wertebereich 0..2pi bringen
    if poseTheta < 0
      poseTheta = poseTheta + 2* pi();
    end
    if poseTheta > 2* pi()
      poseTheta = poseTheta - 2* pi();
    end

% --- epsilon Umgenung erreicht? -----
while ~((sollTheta <= poseTheta + epsilon) && (sollTheta >= poseTheta - epsilon))
    send(myPublisher,myMsg) % => ROS
    % Debug Ausgabe
    str = sprintf('sollTheta: %f poseTheta: %f toTurn %f', sollTheta, poseTheta, abs(sollTheta - poseTheta));
    disp(str)
    poseTheta = mySub.LatestMessage.Theta;
    % Auf Wertebereich 0..2pi bringen
    if poseTheta < 0
      poseTheta = poseTheta + 2* pi();
    end
    if poseTheta > 2* pi()
      poseTheta = poseTheta - 2* pi();
    end
    pause(STEPP_PAUSE);
end

% ROS-Msg zum Anhalten (speed = 0)
speed = 0;
myMsg.(dir).(var)=speed;
send(myPublisher,myMsg); % => ROS
distX = goalX - poseX;
distY = goalY - poseY;
