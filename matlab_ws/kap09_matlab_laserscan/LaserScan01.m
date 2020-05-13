% LaserScan01.m
%-----------------------------------
% EMR - 13.5.2020 
%-------------------------------------------
% Empfang der Daten vom Laser => plot
%------------------------------------------

ROS_Node_init_localhost;
sub1 = rossubscriber('base_scan','sensor_msgs/LaserScan');

figure;

while 1
    scandata = receive(sub1,10); % Abstandswerte holen => Zeilenvektor 
    numbOfScans = size(scandata.Ranges,1); % Spaltenzahl des Zeilenvektors
    plot(scandata,'MaximumRange',3);
    % Ausgabe Abstand voraus
    disp('Abstand genau voraus in m')
    disp(scandata.Ranges(numbOfScans/2))
    pause(1);
end