% goto_beer.m
%  ---------------------------
% EMR am 13.5.2020
%-----------------------------
% Gazebo-youBot faehrt zum Bier
% ########## UBUNTU-Problem ######%  um bei plots Fehler 
% "Caught unexpected fl::except::IInternalException" zu vermeiden
% $ matlab -softwareopengl
%#################################################
%------------------------------------------------------------------------

ROS_Node_init_localhost;

%% --- Subscriber und Publisher beim Master anmelden
sub1 = rossubscriber('base_scan','sensor_msgs/LaserScan');
pub1 = rospublisher ('cmd_vel', 'geometry_msgs/Twist');
msgsBase = rosmessage(pub1);

%% --- Plot vorbereiten ------
close all;
figure;

%% 1mal Scan-Daten holen
scandata = receive(sub1,10); % Abstandswerte holen => Zeilenvektor 
numbOfScans = size(scandata.Ranges,1); % Spaltenzahl des Zeilenvektors 
minAngle = scandata.AngleMin;  % Winkelbereich holen
maxAngle = scandata.AngleMax;
% Zeilenvektor fuer alle Winkel mit gleicher Spaltenzahl erstellen
angles = (minAngle: (maxAngle-minAngle)/(numbOfScans-1):maxAngle);

%% --- Loop() -----
go = true; % Loop-Flag
while go    
    scandata = receive(sub1,10); 
    polarplot(angles,scandata.Ranges,'.');
    % Begrenzung der Angezeigten Reichweite = Radius r    
    rlim([0 scandata.RangeMax]);
    % Begrenzung der Anzeige auf Winkelbereich [min max ]    
    thetalim([scandata.AngleMin*180/pi scandata.AngleMax*180/pi]);
    
    %disp(scandata.Ranges(numbOfScans/2));    
    minIndex = 1; %Index 0 nicht existen!!!    
    minRange = scandata.Ranges(minIndex);
    
    % Suche Kleinsten Abstandswert => Winkel to go
    for i=1:1:numbOfScans
        if scandata.Ranges(i)< minRange            
            minIndex = i;            
            minRange = scandata.Ranges(minIndex);
        end
    end
    % Index und Abstand des naechsten Objektes
    disp(minIndex)    
    disp(minRange)
    
    % Bis auf 10cm hernafahren
    if minRange>0.1 %10cm     
        disp('GO');
        % msgsBase.Linear.X= minRange; % Go forward    
        if(minRange>1)
            msgsBase.Linear.X = 0.5
        else
            msgsBase.Linear.X = 0.2
        end
        
        % Steuerwinkel korrigieren
        if minIndex > numbOfScans/2 +4         
            msgsBase.Linear.Y=0.3; %Go left            
            disp('LEFT');
        end
        if minIndex < numbOfScans/2 -4  
            msgsBase.Linear.Y=-0.3;%Go right             
            disp('RIGHT');
        end
    else %STOP          
        disp('STOP');        
        msgsBase.Linear.X=0.0;        
        msgsBase.Linear.Y=0.0;        
        go = false;
    end
    send(pub1,msgsBase);    
    pause(0.2);
end
pause(10);
close all;
