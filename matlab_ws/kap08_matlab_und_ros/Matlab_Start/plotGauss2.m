% plotGauss2.m
% Zeichnet die Glockenkurve mit Hilfe der
% Funktion gauss2() von links bis rechts in schritten
 
%%%%%%%%%%%%%%%%%%%%% Eingabe Dialog %%%%%%%%%%%%%%
prompt = {'Eingabe Sigma:','Eingabe µ:'};
dlg_title = 'Zeichnen einer Normalverteilung';
num_lines = 1;
def = {'5','3'}; %default Werte setzen
% ---- Antwort als String-Array einlesen ------
answer = inputdlg(prompt,dlg_title,num_lines,def)
sigmaStr = answer(1);         %Element 1 auslesen
sigma = str2double(sigmaStr); %von String in Zahlenwert wandeln
mueStr = answer(2);           %Element 2 auslesen
mue = str2double(mueStr);     %von String in Zahlenwert wandeln
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
y = 0;
links = -10;
t = links;
rechts = 13;
schritte = 1000;
 
for i=1:schritte
    x = links + i*(rechts - links) /schritte; %-3....3 in 100 Schritten
    y = [y, gauss2(x,mue,sigma)]; %an den bisherigen Zeilenvektor anhängen
    t = [t, x];         %an den bisherigen Zeilenvektor anhängen
end
 
plot(t,y,'.');
title('Normalverteilung'); %Kopfzeile setzen
%Text und Variableninhalt ausgeben an Stelle x,y
text(0,0.05,['µ = ',num2str(mue)]); %µ=3 ist in gauss1() festgelegt
text(-1,0.04,['sigma = ',num2str(sigma)]); % 5 in gauss1() festgelegt
waitforbuttonpress;
