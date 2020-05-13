function y = gauss1(x)
% Berechnet die Wahrscheinlichkeitsdichte eines Wertes x
% auf Gauss'schen Glockenkurve, mit fixem Mittelwert m=3
% und Standardabweichung Sigma = 5
 
s = 5; % Sigma
m = 3; % Mittelwert
y = 1/(s*sqrt(2*pi))*exp(-1/2*((x-m)/s)^2);
 
end
