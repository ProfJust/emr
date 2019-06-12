%InflateMap.m
%---------------------------------------------------------------
% Aufblasen (inflate) der Map 

youBotRadiusGrid = 15; %cm?
mapInflated = load('KarteGazeboWorld.mat');

% inflates each occupied position by the radius given in number of cells.
%inflate(mapInflated.map,robotRadius);
inflate(mapInflated.map,youBotRadiusGrid,'grid');
show(mapInflated.map);
hold on;



