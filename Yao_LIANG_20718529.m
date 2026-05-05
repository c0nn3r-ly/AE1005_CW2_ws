% Insert name here Yao LIANG
% Insert email address here ssyyl82@nottingham.edu.cn

clc;clear all;close all;

%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [5 MARKS]

% Insert answers here

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

%acquisition time in s
duration = 600;

%create arrays, number of samples should be duration+1
time = zeros(duration+1,1);
voltage = zeros(duration+1,1);
temperature = zeros(duration+1,1);

%read voltage and convert to temperature and then store them
count = 20;

for i = 1:duration+1
    %start timer
    loop_start = tic;
    time(i) = i - 1;

    %read voltage 20 times as fast as possible
    voltage_samples = zeros(count,1);

    for k = 1:count
        voltage_samples(k) = readVoltage(a,"A5");
    end

    %use the average voltage as the recorded value for this second
    voltage(i) = mean(voltage_samples);

    %convert voltage to temperature
    temperature(i) = (voltage(i) - 0.5) * 100;

    %make each loop take approximately 1 second
    time_taken = toc(loop_start);
    pause_time = 1 - time_taken;

    if pause_time > 0
        pause(pause_time);
    end

end

%calculate the required statistics
Temp_min = min(temperature);
Temp_max = max(temperature);
Temp_avg = mean(temperature);

time_in_minutes = time/60;

%plot the figure
figure;
plot(time_in_minutes,temperature);
xlabel('Time / min');
ylabel('Temperature / °C');
title('Temperature against Time');

%save the figure
saveas(gcf, 'temperature_time_plot.jpg');

%print information to screen
%log date
Date = datestr(now,'dd/mm/yyyy');

%store header
Date_text = sprintf('Data logging initiated - %s\n',Date);
location_text = sprintf('Location - Ningbo\n\n');
header = [Date_text,location_text];
fprintf('%s',header);

%print temperature every minute
body = '';
for minute = 0:10
    j = minute * 60 +1;
    minute_text = sprintf('Minute\t\t%d\n',minute);
    temperature_text = sprintf('Temperature\t%.2f C\n\n',temperature(j));
    body = [body,minute_text,temperature_text];
end
%print body
fprintf('%s',body);

%print statistics
max_text = sprintf('Max temp\t%.2f C\n',Temp_max);
min_text = sprintf('Min temp\t%.2f C\n',Temp_min);
avg_text = sprintf('Average temp\t%.2f C\n\n',Temp_avg);

statistics = [max_text,min_text,avg_text,'Data logging terminated'];
fprintf('%s',statistics);

%save info in txt
%open the file
fileID = fopen('capsule_temperature.txt','w');

%write all info
all_info = [header,body,statistics];
fprintf(fileID,'%s',all_info);

%finish
fclose(fileID);

%open the generated txt file to check the contents
open('capsule_temperature.txt');

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

% Insert answers here
temp_monitor(a);
%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [30 MARKS]

% Insert answers here
temp_prediction(a);

%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% Insert answers here