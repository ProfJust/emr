%% Multidimensional Kalman-Filter
% Paul Balzer | Motorblog


clear  
clc
clf
  
%% Messungen generieren
% Da wir jetzt keine Messwerte haben,
% generieren wir uns einfach selbst
% ein paar verrauschte Werte.
it=100;     % Anzahl Messwerte
realv=10;   % wahre Geschwindigkeit
 
                   % x'                y'
measurements = [realv+1.*randn(1,it); zeros(1,it)];
  
dt = 1;     % Zeitschritt
 
 xBereich  = [-500:1:1000]; %Wertebereich für die Position
 vBereich  = [0:0.1:20]; %Wertebereich für die Position
  
%% Initialisieren
%    x  y  x' y'
x = [0; 0; 10; 0];      % Initial State (Location and velocity)
P = [10, 0, 0, 0;...
    0, 10, 0, 0;...
    0, 0, 10, 0;...
    0, 0, 0, 10];       % Initial Uncertainty
A = [1, 0, dt, 0;...
    0, 1, 0, dt;...
    0, 0, 1, 0;...
    0, 0, 0, 1];        % Transition Matrix
H = [0, 0, 1, 0;...
    0, 0, 0, 1];        % Measurement function
R = [10, 0;...
    0, 10];             % measurement noise covariance

Q = [1/4*dt^4, 1/4*dt^4, 1/2*dt^3, 1/2*dt^3;...
    1/4*dt^4, 1/4*dt^4, 1/2*dt^3, 1/2*dt^3;...
    1/2*dt^3, 1/2*dt^3, dt^2, dt^2;...
    1/2*dt^3, 1/2*dt^3, dt^2, dt^2]; % Process Noise Covariance

I = eye(4);             % Identity matrix
 
%% Kalman Filter Steps
%
for n=1:length(measurements)
    % Prediction
    x=A*x;                  % Prädizierter Zustand aus Bisherigem und System
    P=A*P*A'+Q;             % Prädizieren der Kovarianz
  
    % Correction
    Z=measurements(:,n);
    y=Z-(H*x);              % Innovation aus Messwertdifferenz
    S=(H*P*H'+R);           % Innovationskovarianz
    K=P*H'*inv(S);          % Filter-Matrix (Kalman-Gain)
  
    x=x+(K*y);              % aktualisieren des Systemzustands
    
    P=(I-(K*H))*P;          % aktualisieren der Kovarianz

% Plotten der Normalverteilung
%https://de.mathworks.com/help/stats/normal-distribution.html
% normpdf(variablen-Bereich-Matrix, Mittelwert (scalar), varianz (scalsar)
    norm = normpdf(xBereich,x(1),P(1,1));
    plot1 = subplot(2,1,1)
    plot(plot1, xBereich,norm)
    title(plot1 ,'Position x [m]');
   ylim(plot1,[0.0 0.03]); 
     hold on;
   
   norm = normpdf(vBereich,x(3),P(3,3));
    plot2 = subplot(2,1,2)
    plot(plot2,vBereich,norm)
    title(plot2 ,'Speed x [m/s]');
   ylim(plot2 ,[0.0 0.3]); 
    hold on;
   
   pause(0.2)
end
