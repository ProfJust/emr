% LaserScan02.m
% 
%----------------------------------------------------
% EMR - 13.5.2020 
%-------------------------------------------
% Empfang der Daten vom Laser => Polarplot
%------------------------------------------

ROS_Node_init_localhost;

%% 1mal empfangen
sub1 = rossubscriber('base_scan','sensor_msgs/LaserScan');
scandata = receive(sub1,10);
numbOfScans = size(scandata.Ranges,1); %Wiviele Messpunkte hat der Scanner
minAngle = scandata.AngleMin;
maxAngle = scandata.AngleMax;
ranges = zeros(numbOfScans);
angles = (minAngle: (maxAngle-minAngle)/(numbOfScans-1): maxAngle);

%%----------- 
while 1
    scandata = receive(sub1,10);
    ranges = scandata.Ranges;
%---- Polarplot ----    
     %polarplot(angle,fliplr(range),'.'); %Seitentausch nicht nötig
    polarplot(angles,ranges,'.');
     % Begrenzung der Angezeigten Reichweite = Radius r
    rlim([0 5.6]);
    % Begrenzung der Anzeige auf Winkelbereich [min max ]
    %thetalim([minAngle*180/pi+offsetAngle maxAngle*180/pi+offsetAngle]);
     thetalim([minAngle*180/pi maxAngle*180/pi]);

    % Ausgabe Abstand voraus
    disp('Abstand genau voraus in m')
    disp(scandata.Ranges(numbOfScans/2)); %Abstand gerade voraus
end
