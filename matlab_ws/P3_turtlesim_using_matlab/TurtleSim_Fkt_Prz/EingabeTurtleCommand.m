%-----------------------------
%  EingabeTurtleCommand.m
%-----------------------------
function  [speed, way, dir, movement] = EingabeTurtleCommand()

%% ---- Eingabe Richtung ----
txtAchse = 'In welche Richtung soll der Roboter fahren? <x/y/z> -- q = quit: ';
axisChar = input(txtAchse,'s');

switch axisChar
    case 'x'
        dir='X';
        movement='Linear';
    case 'y'
        dir='Y';
        movement='Linear';
    case 'z'
        dir='Z';
        movement='Angular';
    otherwise
        dir='Q';
        movement='Linear';
        speed=0;
        way=0;
        return;
end

%% --- Eingabe Geschwindigkeit ---------
if dir=='Z'
    txt1 = 'Bitte geben Sie die gewuenschte Dreh-Geschwindigkeit (RAD/sec) ein: ';
else
    txt1 = 'Bitte geben Sie die gewuenschte Geschwindigkeit (m/sec) ein: ';
end

speed = abs(str2double(input(txt1,'s'))); %nur positive Werte

%% --- Ueberpruefen der Eingabe ----
if dir=='X' || dir=='Y'
    if speed > 1
        speed = 1.0;
        disp('Geschwindigkeit wird begrenzt auf maximal 1m/sec');
    end
end

if dir=='Z'
    if speed >0.3
        speed = 0.3;
        disp('Drehgeschwindigkeit begrenzt auf maximal 0.3 RAD/sec');
    end
end

%% --- Eingabe Strecke
if dir=='X' || dir=='Y'
    txt2 = 'Bitte geben Sie die Strecke (in Meter) ein: ';
    way = input(txt2);
    if way > 5
        way = 5;
        disp('Strecke begrenzt auf maximal 5m');
    end
end

if dir=='Z'
    txt3 = 'Bitte geben Sie den Winkel (in Grad) ein: ';
    way = input(txt3);
end




