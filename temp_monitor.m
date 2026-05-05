%Yao LIANG ssyyl82@nottingham.edu.cn
%This function is designed using arduino UNO and MCP9700AE thermistor
%The function log voltage data from the thermistor and convert it to
%temperature. The temperatures are updated to a live graph. 
%Then the lights are controled based on the following logic. When
%temperature is at 18-24 C, greenLED will constantly be on. When it's below
%18 C, yellowLED will blink at an interval of 0.5s. When higher than 24,
%redLED will blink at an interval of 0.25s. The time for the calculation
%and the update of the graph was considered for the blinking process.
function temp_monitor(a)

%define pins to make coding easier
redLED = "D8";
greenLED = "D10";
yellowLED = "D12";

%make sure all lights are closed when start and interupted
writeDigitalPin(a,redLED,0);
writeDigitalPin(a,greenLED,0);
writeDigitalPin(a,yellowLED,0);
cleanup = onCleanup(@() turnOffLEDs(a,redLED,greenLED,yellowLED));

%init arrays
time = [];
temperature = [];

%start timer
start_time = tic;

%create the plot
figure;
live_plot = plot(NaN,NaN);
xlabel('Time / min');
ylabel('Temperature / °C');
title('Live Temperature');

%the monitoring loop
while true
    loopStart = tic;

    %read voltage several times and average it
    voltageSamples = zeros(5,1);
    for k = 1:5
        voltageSamples(k) = readVoltage(a, "A5");
    end
    voltage = mean(voltageSamples);

    %convert voltage to temperature
    temp = (voltage - 0.5) * 100;

    %store time and temperature
    currentTime = toc(start_time);

    time = [time; currentTime];
    temperature = [temperature; temp];

    %update the plot
    ylim([0,40]);
    %here, the data are shown like 0-1min,0-2min,0-3min... +0.001 is to
    %make sure the result will be 1 when the script just start.
    xlim([0, (ceil((currentTime+0.001) / 60))]);

    set(live_plot, 'XData', time/60, 'YData', temperature);
    drawnow;

    %LED control logic

    if temp >= 18 && temp <= 24

        %comfort range green LED constant on
        writeDigitalPin(a,redLED,0);
        writeDigitalPin(a,yellowLED,0);
        writeDigitalPin(a,greenLED,1);

        pauseTime = 1 - toc(loopStart);
        if pauseTime > 0
            pause(pauseTime);
        end

    elseif temp < 18
        %below comfort range yellow LED blinks every 0.5 s
        writeDigitalPin(a,redLED,0);
        writeDigitalPin(a,greenLED,0);
        writeDigitalPin(a,yellowLED,1);

        pause(0.5);
        writeDigitalPin(a,yellowLED,0);
        %save time for data logging
        pauseTime = 0.5 - toc(loopStart);
        if pauseTime > 0
            pause(pauseTime);
        end

    else
        %above comfort range: red LED blinks every 0.25 s
        writeDigitalPin(a,greenLED, 0);
        writeDigitalPin(a,yellowLED, 0);

        writeDigitalPin(a,redLED,1);
        pause(0.25);
        writeDigitalPin(a,redLED,0);
        pause(0.25);
        writeDigitalPin(a,redLED,1);
        pause(0.25);
        writeDigitalPin(a,redLED,0);

        %save time for data logging
        pauseTime = 0.25 - toc(loopStart);
        if pauseTime > 0
            pause(pauseTime);
        end
    end

end

end

function turnOffLEDs(a,redLED,greenLED,yellowLED)
    writeDigitalPin(a,redLED,0);
    writeDigitalPin(a,greenLED,0);
    writeDigitalPin(a,yellowLED,0);
end
