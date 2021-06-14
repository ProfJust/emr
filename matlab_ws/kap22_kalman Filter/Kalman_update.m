
%http://www.cbcity.de/das-kalman-filter-einfach-erklaert-teil-1

function [new_mean, new_var]= Kalman_update(mean1,var1,mean2,var2)
%% [new_mean, new_var]=update(mean1,var1,mean2,var2)
% Berechnet geschätzte Position nach Messung der Position
 
new_mean=(var2*mean1 + var1*mean2) / (var1+var2);
new_var = 1/(1/var1 +1/var2);
end

 
