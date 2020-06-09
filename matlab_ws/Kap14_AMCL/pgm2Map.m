%EditOccupancyGrid.m
%-----------------------------------------
%Figure mit save as als PGM speichern
% mit GIMP bearbeiten 

% oder
%mat = occupancyMatrix(map);
%imwrite(mat, 'ImageName.jpg');

%-------------------------------------------
%danach: reload   pgm => occupnacy grid 
image = imread('WillowGrarage2.pgm')

%aus dem image eine map mit passender Auflösung
%(hier 50) erstellen 
 map = robotics.OccupancyGrid(image <100, 50);
%map Nullpunkt setzen 
 map.GridLocationInWorld = [-7.5,-7.5];

show(map);
save('WillowGarageOccupancyGrid_GIMP.mat',  'map')

