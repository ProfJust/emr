% ros_init_m
% Die IP des ROS-Masters bekannt machen und mit ROS verbinden
%youbot: 
% youBot-Labor rosinit('http://192.168.0.104:11311','NodeName','/PC03')
%Buero@home: 
%rosinit('http://192.168.2.150:11311','NodeName','/RoboLabHome')
rosinit('http://192.168.2.150:11311','NodeName','/Acer')
%Buero@whs: 
%rosinit('http://192.168.129.21:11311','NodeName','/PC03')


% wenn kein Empfang auf dem MAtlab-Rechner / subscriber funkt nicht,
% dann...
% vgl.: https://de.mathworks.com/matlabcentral/answers/119559-why-is-the-ros-subscriber-callback-in-matlab-not-triggered-when-messages-are-published-from-an-exter
% At the end of the file �.bashrc�, add the two export statements.
% In der .bashrc muss die ROS_IP des Rechners auf dem der roscore laeuft (also z.B. der youbot-PC) angegeben sein
% export ROS_IP=192.168.2.101
% export ROS_MASTER_URI=http://192.168.2.101:11311


%rosshutdown