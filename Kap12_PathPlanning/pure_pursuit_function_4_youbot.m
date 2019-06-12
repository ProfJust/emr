function [v_x,v_y,omega] = step_youbot(pp,cpose, orie, kv_rot, kv_ang)
%%%%------------PurePursuit algorithmus angepasst auf den Kuka-Youbot--------------%%%%
%%%%-------------------Westf�lische hochschule Juni/Juli 2017----------------------%%%%
%%%%---------------------Projektarbeit: Embedded Robotics--------------------------%%%%
%%%%--------------Betreuender Professor: Prof. Dr. Olaf Just-----------------------%%%%
%------Authoren------%:
% Marcel Bohnenkamp
% Marcel Herzig  
% Tobias Wewers

%%%%------------Begriffe--------------%%%%
%WP1: Wegpunkt der n�her am Startpunkt als am Zielpunkt liegt

%%%%------------Optionale Parameter, Default Werte--------------%%%%
if nargin < 3
    %Verst�rkungsfaktor gibt an wie Stark die Rotation geregelt wird
    orie = 0;
end
if nargin < 4
    %Verst�rkungsfaktor gibt an wie Stark die Rotation priorisiert wird
    kv_rot = 5;
end
if nargin < 5
    %Verst�rkungsfaktor gibt an wie Stark die Rotation geregelt wird
    kv_ang = 15;
end

%naheliegendste Position auf Pfad finden
wp = pp.Waypoints;
s = [inf,0,0,0]; %[Strecke von Cpose-Schnittpunkt, WP1, [X,Y]]
for i=1:(length(wp)-1)
    s_temp = calc_vektorschnittpunkt(wp(i,:),wp(i+1,:),cpose(1:2));
    %Senkrechte zu Pfad
    if ~isnan(s_temp)
        if norm(cpose(1:2)-s_temp) < s(1)
            s = [norm(cpose(1:2)-s_temp),i,s_temp];
        end
    end
    %Abstand zu Punkt
    if norm(cpose(1:2)-wp(i,:)) < s(1)
        s = [norm(cpose(1:2)-wp(i,:)),i,wp(i,:)];
    end
end

%Look-Ahead Punkt bestimmen
%Pfad R�ckw�rts durchgehen bis Schnittpunkt(e) gefunden
for i = (length(wp)-1):-1:s(2)
    v_pfad = wp(i+1,:)-wp(i,:);
    if i == length(wp)-1
        %Letzen Pfad-V verl�ngern damit Look-Ahead auch am Schluss m�glich ist
        v_pfad = (pp.LookaheadDistance+norm(v_pfad))*v_pfad/norm(v_pfad);
    end
    [ks1,ks2] = calc_kreisschnittpunkte(wp(i,:),v_pfad,[s(3),s(4)],pp.LookaheadDistance);
    if (norm(ks1) ~= inf) || (norm(ks2) ~= inf)
        %WP1-Nummer auf dem ein Kreisschnittpunkt liegt
        wp_spnr = i;
        break;
    end
end

%Punktauswahl
p = wp(wp_spnr+1,:);
if norm(ks1-p) < norm(ks2-p)
    lah_p = ks1;
else
    lah_p = ks2;
end

%Winkel zwischen cpose und LAh-Vektor + Soll-Orientierung berechnen (alpha)
theta = cpose(3)+orie*pi/180;
v_cpose_lah = [lah_p-cpose(1,1:2),0];
v_temp = [1,0];
R = [cos(-theta) sin(theta); -sin(theta) cos(-theta)];
v_ori = [v_temp*R,0];
alpha = atan2(norm(cross(v_ori,v_cpose_lah)),dot(v_ori,v_cpose_lah))*180/pi;

%Rotatorische Gesch. bestimmen
v_cross = cross(v_ori,v_cpose_lah); %Drehrichtung
if v_cross(3) > 0
    vz = 1;
else
    vz = -1;
end
%Reglung Roation
omega = vz*pp.MaxAngularVelocity*kv_ang*abs(alpha/180);
%Begrenzung 
if abs(omega) > pp.MaxAngularVelocity
    omega = (omega/abs(omega))*pp.MaxAngularVelocity;
end

%Reglung Priorit�t der Rotation
omega2 = vz*pp.MaxAngularVelocity*kv_rot*abs(alpha/180);
%Begrenzung
if abs(omega2) > pp.MaxAngularVelocity
    omega2 = (omega2/abs(omega2))*pp.MaxAngularVelocity;
end

%Translatorische Gesch. bestimmen
theta = cpose(3);
v_vel = v_cpose_lah*pp.DesiredLinearVelocity/norm(v_cpose_lah);
R = [cos(theta) sin(-theta); -sin(-theta) cos(theta)];
v_vel = v_vel(1:2)*R;
%Rotation Priorisieren
v_vel = v_vel*abs(abs(omega2/pp.MaxAngularVelocity)-1);
%Begrenzung
if norm(v_vel) > pp.DesiredLinearVelocity
    v_vel = v_vel*pp.DesiredLinearVelocity/norm(v_vel);
end
v_x = v_vel(1);
v_y = v_vel(2);
end

function [s1,s2] = calc_kreisschnittpunkte(vo,v,vok,r)
%vo: Orstvektor vom Pfad
%v: Pfadvektor
%vok: Naheliegenster Pfadpunkt/Kreismittelpunkt
%r: Radius
%Gleichung: ((vo1+v1*f)-vok1)^2+((vo2+v2*f)-vok2)^2=r^2
t1 = (-2*vok(1)*v(1)-2*vok(2)*v(2)+2*vo(1)*v(1)+2*vo(2)*v(2))^2;
t2 = -4*(v(1)^2+v(2)^2)*(vok(1)^2-2*vok(1)*vo(1)+vok(2)^2-2*vok(2)*vo(2)-r^2+vo(1)^2+vo(2)^2);
t3 = vok(1)*v(1)+vok(2)*v(2)-vo(1)*v(1)-vo(2)*v(2);
%f1/f2 = Streckungsfaktoren vom Pfad Vektor
f1 = ((1/2)*sqrt(t1+t2)+t3)/(v(1)^2+v(2)^2);
f2 = ((-1/2)*sqrt(t1+t2)+t3)/(v(1)^2+v(2)^2);

%Schnittpunkt auf Pfad? (Streckung 0<f<1)
if isreal(f1) && (f1<=1) && (f1>=0)
    s1 = vo+v*f1;
else
    s1 = [inf,inf];
end
if isreal(f2) && (f2<=1) && (f2>=0)
    s2 = vo+v*f2;
else
    s2 = [inf,inf];
end
end

function [s] = calc_vektorschnittpunkt(p1,p2,pos)
v_pfad = p2-p1;
s = NaN;
%Senkrechte Pfad/CPose berechen und n�tige Streckung bis zum Schnittpunkt
%bestimmen
f = (-p1(1)*v_pfad(1)-p1(2)*v_pfad(2)+pos(1)*v_pfad(1)+pos(2)*v_pfad(2))/(v_pfad(1)^2+v_pfad(2)^2);
%Liegt Schnittpunkt Senkrechte/Pfad auf Pfad? (Streckung 0<f<1)
if (f>=0) && (f<1)
    s = p1+v_pfad*f;
end
end
