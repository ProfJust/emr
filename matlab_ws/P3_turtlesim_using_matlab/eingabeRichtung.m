%-----------------------------
% eingabeRichtung.m
%-----------------------------
txtFahren = ' Roboter soll fahren? <j/n> : ';
goChar = input(txtFahren,'s'); % Benutzereingabe

switch goChar
    case 'n' 
        go = false;
        
    case 'j' 
        txtAchse = 'In welche Achse Verfahren? <x/y/z> : ';
        axisChar = input(txtAchse,'s');
        %   myMsg.(dir).(var)=Speed; erstellen
        switch axisChar
            case 'x' 
                var='X';
                dir='Linear';
            case 'y'
                var='Y';
                dir='Linear';
            case 'z'
                var='Z';
                dir='Angular';
        end
end
