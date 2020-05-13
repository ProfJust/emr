% TurtleSim_02.m
% TurtleSim Pose plotten
%-------------------------------------
% Wichtig: zun�chst ROS-Node anmelden mit
% IP des ROS-Master-Rechners hier eintragen
% !!! Nur einmal am Anfang.
%rosinit('http://192.168.2.150:11311','NodeName','/Acer');
% rosinit('http://RoboMasterHP:11311/','NodeName','/RoboMasterHP')
rosinit;

% Matrix f�r Speicherung der Positionen
poseVect = [5; 5;]
% plotten mit plot(poseVect(1,:), poseVect(2,:))
% Subscriber anmelden
mySub = rossubscriber ('/turtle1/pose');

% Plot konfigurieren
figure;    % eine figur/ einen Plot �ffnen
hold on;   % jeder Punkt kommt in denselben Plot
grid on;   % Gitternetz anzeigen
axis([0 12 0 12]); % Gr��e des Plots / Achsen konfigurieren

%--- Endlosschleife zum Empfangen und Plotten --
for i=1:500
    %---- Werte empfangen ---- 
    poseX = mySub.LatestMessage.X;
    poseY = mySub.LatestMessage.Y;
    tempVect = [poseX ; poseY];
    poseVect = [poseVect, tempVect]; % F�ge neue Daten zur Matrix hinzu
        
    %-----  empfangene Werte im Command Window anzeigen ---
    % Strimg basteln
        poseStr =['aktuelle Turtle Pose',' X: ',num2str(poseX),' Y: ',num2str(poseY)];
    % String ausgeben
        disp(poseStr); 
    %----- Werte im Plot anzeigen ----    
    plot(poseX,poseY,'b--o');
    
    pause(0.1);
end
disp('Maximale Speicherdauer erreicht')
%figure;
plot(poseVect(1,:), poseVect(2,:))

rosshutdown();
