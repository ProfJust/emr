% TurtleSim_02_plot_path.m
% --------------------------------------------------
% Subsribes the turtle-pose and plots it for 50sec
% To move turtle use rqt - robot steering tool
%----------------------------------------------------
% EMR - 13.5.2020
%----------------------------------------------------

ROS_Node_init_localhost;

%%
% Subscriber anmelden
mySub = rossubscriber ('/turtle1/pose');

% Plot konfigurieren
figure;    % eine figur/ einen Plot oeffnen
hold on;   % jeder Punkt kommt in denselben Plot
grid on;   % Gitternetz anzeigen
axis([0 12 0 12]); % Groesse des Plots / Achsen konfigurieren

%--- Schleife fuer 500 * 0.1sec zum Empfangen und Plotten --
for i=1:500
    %---- Werte empfangen ----
    poseX = mySub.LatestMessage.X;
    poseY = mySub.LatestMessage.Y;
    tempVect = [poseX ; poseY];
    if i==1
        poseVect = tempVect;
    else
        % Fuege neue Daten zur Matrix hinzu
        poseVect = [poseVect, tempVect]; 
    end
    
    %-----  empfangene Werte im Command Window anzeigen ---
    % String basteln
    poseStr =['aktuelle Turtle Pose',' X: ',num2str(poseX),' Y: ',num2str(poseY)];
    % ...und ausgeben
    disp(poseStr);
    
    %----- Werte im Plot anzeigen ----
    plot(poseX,poseY,'b--o');
    
    pause(0.1);
end

disp('Maximale Speicherdauer erreicht, beende Aufzeichnung')


