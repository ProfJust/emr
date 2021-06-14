
%http://www.cbcity.de/das-kalman-filter-einfach-erklaert-teil-1

function [new_mean, new_var]=Kalman_predict(mean1,var1,mean2,var2)
%% [new_mean, new_var]=predict(mean1,var1,mean2,var2)
% Berechnet neuen Mittelwert und neue Varianz nach Bewegung mit Mittelwert
% und Varianz von Ausgangsposition und Unsicherheit der Bewegung sowie
% vorhergesagter Bewegungsentfernung
% new_mean = mean1 + mean2;
% new_var = var1 + var2;

new_mean=mean1+mean2;
new_var =var1+var2;
 
end
 
