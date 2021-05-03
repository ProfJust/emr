% goto_beer.m
%  ---------------------------
% EMR am 3.5.2021
%-----------------------------
% Gazebo-youBot faehrt zum Bier in leerer Welt
% $ roslaunch emr_youbot youbot_emr_simulation_empty_gazebo.launch 
% Ergänze Bierdose http://models.gazebosim.org/Beer vor dem youbot
% Abstand max.  5,6 m
%------------------------------------------------------------------------
ROS_Node_init_localhost;

%% --- Subscriber und Publisher beim Master anmelden
sub1 = rossubscriber('base_scan','sensor_msgs/LaserScan');
pub1 = rospublisher ('cmd_vel', 'geometry_msgs/Twist');
msgsBase = rosmessage(pub1);

%% --- Plot vorbereiten ------
close all;
figure;

%% 1mal Scan-Daten holen
scandata = receive(sub1,10); % Abstandswerte holen
% Zeilenzahl der 1. Spalte ermitteln
numbOfScans = size(scandata.Ranges,1);
% Winkelbereich ermitteln
minAngle = scandata.AngleMin;
maxAngle = scandata.AngleMax;
% Im Laserscan sind nur Anstände, aber keine Winkel =>
% Winkelvektor mit gleicher Spaltenzahl erstellen
angles = (minAngle: (maxAngle-minAngle)/(numbOfScans-1): maxAngle);

%% --- Loop() -----
go = true; % Loop-Flag
while go    
    scandata = receive(sub1,10); 
    polarplot(angles,scandata.Ranges,'.');
    % Begrenzung der Angezeigten Reichweite = Radius r    
    rlim([0 5.6]);
    % Begrenzung der Anzeige auf Winkelbereich [min max ]    
    thetalim([scandata.AngleMin*180/pi scandata.AngleMax*180/pi]);
    disp(scandata.Ranges(numbOfScans/2));  % direkt nach vorn
    
    % Suche Kleinsten Abstandswert => Winkel to go
    
   
end
pause(10);
close all;

