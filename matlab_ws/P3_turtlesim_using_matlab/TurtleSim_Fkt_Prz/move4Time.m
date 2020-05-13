%-----------------------------
% move4Time.m
%-----------------------------
%---- warten bis Fahrt zu Ende ----
function  goTime = move4Time(speed, way, axisChar)
    goTime = 0;
    switch axisChar
        case 'X'
            goTime = abs(way / speed);
        case 'Y'
            goTime = abs(way / speed);
        case 'Z'
            goTime = abs((way*pi/180) / speed);
    end
end