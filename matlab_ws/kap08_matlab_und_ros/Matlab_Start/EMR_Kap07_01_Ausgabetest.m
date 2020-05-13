% EMR_Kap07_01_Ausgabetest.m
% Matlab auf Ubuntu im Terminal starten mit $ matlab -softwareopengl 
% Demo fuer ein Skript mit einem 3D-Oberflaechenplot

[X,Y,Z] = peaks(30);  % DemoFunktion, ergibt 30x30 Matrix
surfc(X,Y,Z)          % 3D Oberflaechenplot surface
colormap hsv          % waehlt Farbpalette
axis([-3 3 -3 3 -10 5]) % Skalierung der 3 Achsen
