function y = gauss2(x, m, s)
% Berechnet den Wert der Gauss'schen Glockenkurve mit variablem 
% Mittelwert m und Standardabweichung sigma = s
 
 y = 1/(s*sqrt(2*pi))*exp(-1/2*((x-m)/s)^2);
 
end
