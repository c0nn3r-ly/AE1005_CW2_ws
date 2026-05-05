% Insert name here Yao LIANG
% Insert email address here ssyyl82@nottingham.edu.cn


%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [5 MARKS]

% Insert answers here
clc;clear all;close all;

a = arduino("/dev/cu.usbserial-1310","Uno");

%let led blink 5 times
for i = 1:5
    writeDigitalPin(a,"D2",1);
    pause(0.5);
    writeDigitalPin(a,"D2",0);
    pause(0.5);
end

%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

% Insert answers here

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

% Insert answers here


%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [30 MARKS]

% Insert answers here


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% Insert answers here