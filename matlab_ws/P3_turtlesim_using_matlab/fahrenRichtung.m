%-----------------------------
% fahreRichtung.m
%-----------------------------
txt1 = 'Bitte geben Sie die Geschwindigkeit (in m/sec bzw. RAD/sec) ein: ';
speed = abs(str2double(input(txt1,'s'))); %nur positive Werte

if axisChar=='x' || axisChar=='y'
    if speed > 1
        speed = 1.0;
        disp('Geschwindigkeit begrenzt auf maximal 1m/sec');
    end
    txt2 = 'Bitte geben Sie die Strecke (in Meter) ein: ';
    meter = input(txt2);
    if meter > 5
        meter = 5;
        disp('Strecke begrenzt auf maximal 5m');
    end
end

if axisChar=='z'
    txt3 = 'Bitte geben Sie den Winkel (in Grad) ein: ';
    meter = input(txt3);
    if speed >0.3
        speed = 0.3;
        disp('Drehgeschwindigkeit begrenzt auf maximal 0.3 RAD/sec');
    end
end
