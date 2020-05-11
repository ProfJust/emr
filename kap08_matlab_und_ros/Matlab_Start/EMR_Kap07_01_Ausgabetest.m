% EMR_Kap07_01_Ausgabetest.m
% Matlab auf Ubuntu im Terminal starten mit $ matlab -softwareopengl 
% Demo f�r ein Skript mit einem 3D-Oberfl�chenplot
[X,Y,Z] = peaks(30);  %DemoFunktion, ergibt 30x30 Matrix
surfc(X,Y,Z)          %3D Oberfl�chenplot surface
colormap hsv          %w�hlt Farbpalette
axis([-3 3 -3 3 -10 5]) %Skalierung der 3 Achsen
