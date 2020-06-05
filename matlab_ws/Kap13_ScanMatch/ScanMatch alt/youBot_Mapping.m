%ROS-MAster - nur einmal
%rosinit('http://192.168.43.238:11311','NodeName','/RoboLabHome3')
%-----------------------------------------------------------------------
subScan = rossubscriber('scan','sensor_msgs/LaserScan');
subOdom = rossubscriber ('odom', 'nav_msgs/Odometry');
LaserScans={zeros};

%----- map erstellen --------------
%12m x 12m mit 100 Werten pro m => 1cm Raster
map = robotics.OccupancyGrid(12,12,100);
%Startposition des youBot % Offset-Map - Pose youBot
map.GridLocationInWorld = [-6,-6];

%----- Laserscan Daten vorbereiten ----
% make empty ray Object
AngleMin = -1.57; %siehe scandata
AngleMax = 1.57;
ranges = 3*ones(512, 1);
angles = linspace(AngleMin,AngleMax, 512);
maxrange = 3;
i=1;

while 1
% pose holen und speichern
posedata = receive(subOdom,25);
% Winkel berechnet sich aus den Quarternionen
% pose als Quaternion speichern
myQuat = [ posedata.Pose.Pose.Orientation.X posedata.Pose.Pose.Orientation.Y posedata.Pose.Pose.Orientation.Z posedata.Pose.Pose.Orientation.W];
eulZYX = quat2eul(myQuat);
theta = eulZYX(3);
%xY-Daten des youBot sind ist nicht die exakte Funktion des
%Hokuyo, Achse des Scanners ca 33 cm in X-Richtung
% Länge Base 58cm, Trägerblech - Mitte Laser ca. 4 cm
versatz = 0.338;
poseX = posedata.Pose.Pose.Position.X + cos(theta)*versatz;
poseY = posedata.Pose.Pose.Position.Y + sin(theta)*versatz;
pose = [poseX, poseY, theta]; %X, Y, THETA
%scan holen
scandata = receive(subScan,25);
LaserScans{i}=scandata;

ranges = scandata.Ranges;
%In Map eintragen
%insertRay(map,pose,ranges,angles,maxrange,[0.4 0.8]);
insertRay(map,pose,ranges,angles,maxrange);
show(map)
i=i+1;
end

%save('LaserScans');