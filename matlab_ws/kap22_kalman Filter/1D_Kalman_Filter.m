%Klaman01.m
%http://www.cbcity.de/das-kalman-filter-einfach-erklaert-teil-1
 
%% 1D-Kalman Filter
% Aufbau und Erläuterung nach Udacity Kurs CS373 taught by Sebastian Thrun
% Paul Balzer
clear %Clear Workspace
clc %Clear Command Window
clf % clear figure
 
%% Ausgangsbedingungen
% sigma=Standardabweichung, m = Mittelwert
sigma_mess = 4; % Standardabweichung Messung (Sensor)
sigma_move = 2; % Standardabweichung Bewegung (Odometrie)
 
mu = 0; % Startposition
sig = 100000; % Unsicherheit der Startposition zu Beginn
 
x = [-20:.1:30]; %Wertebereich für die Position
% Plotten der Normalverteilung
%https://de.mathworks.com/help/stats/normal-distribution.html
% normpdf(variablen-Bereich, Mittelwert, varianz
    norm = normpdf(x,mu,sig);
    plot(x,norm)
    ylim([0.0 0.15]); 
    hold on;
    
%% Kalman-Berechnung
messung = [5, 6, 7, 9, 10, 11]; % Die gemessenen Orte (Sensor)
bewegung= [1, 1, 2, 1, 1, 1];  % Die zurückgelegte Strecke (Odometrie)
 
for i=1:length(messung)
    [mu,sig]=Kalman_update(mu,sig,messung(i),sigma_mess);
        disp(['Update: ' num2str(mu) ', ' num2str(sig)])
    [mu,sig]=Kalman_predict(mu,sig,bewegung(i),sigma_move);
        disp(['Predict: ' num2str(mu) ', ' num2str(sig)])
    
    % Zeichne Normalverterilung
        norm = normpdf(x,mu,sig);
        plot(x,norm);         
        pause(2);
end
