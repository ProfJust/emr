% plotGauss1.m
% Zeichnet die Glockenkurve mit Hilfe der
% Funktion gauss1() von links bis rechts in schritten
y = 0;
 
links = -10;
t = links;
rechts = 13;
schritte = 1000;
 
for i=1:schritte
    x = links + i*(rechts - links) /schritte; %-3....3 in 100 Schritten
    y = [y, gauss1(x)]; %an den bisherigen Zeilenvektor anh�ngen
    t = [t, x];         %an den bisherigen Zeilenvektor anh�ngen
    
    
end
 
plot(t,y,'.');
title('Normalverteilung'); %Kopfzeile setzen
%----- Text und Variableninhalt ausgeben an Stelle x,y
text(0,0.05,['µ = ',num2str(3)]); %�=3 ist in gauss1() festgelegt
text(-1,0.04,['sigma = ',num2str(5)]); % 5 in gauss1() festgelegt


waitforbuttonpress;
close();  %figure
