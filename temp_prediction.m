%Yao LIANG ssyyl82@nottingham.edu.cn
%The temp_prediction function monitors the temperature change rate and can
%predict temperature in 5 minutes. This function is designed using arduino
%UNO and MCP9700AE thermistor. It log 20 voltage readings each one-second
%cycle, converts the result to temperature, and store the real-time data for each second.
%It calculate 30 changing rate with the 60 newest data(can be changed). Then the rates are
%averaged and used to predict the temperature. GreenLED will be on when
%rate is around -4 C/min to 4. When rate is smaller than -4 C/min, YellowLED
%will be on. When rate is bigger than 4 C/min, RedLED will be on.
function temp_prediction(a)
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

%number of voltage readings in each loop
count = 20;

%number of data used to calculate rate
window_size = 60;

%start timer
start_time = tic;

%the prediction loop

while true
    loop_start = tic;

    %read voltage 20 times and average it
    voltageSamples = zeros(count,1);
    for k = 1:count
        voltageSamples(k) = readVoltage(a,"A5");
    end
    voltage = mean(voltageSamples);
    %convert voltage to temperature
    temp = (voltage - 0.5) * 100;
    
    %store time and temperature
    currentTime = toc(start_time);
    time = [time; currentTime];
    temperature = [temperature; temp];

    %calculate rate when enough data has been stored
    if length(temperature) >= window_size
        %select the newest window_size data
        newest_time = time(end-window_size+1:end);

        newest_temperature = temperature(end-window_size+1:end);

        %calculate window_size/s rates using window_size data
        rates = zeros(window_size/2,1);
        for n = 1:window_size/2
            rates(n) = (newest_temperature(n+window_size/s) - newest_temperature(n)) / (newest_time(n+window_size/2) - newest_time(n));
        end

        %calculate the average rate and convert it from C/s to C/min
        rate_avg = mean(rates);
        rate_min = rate_avg * 60;

        %predict temperature after 5 minutes
        predictedTemp = temp + rate_min * 5;

        %print information
        fprintf('Current temperature: %.2f C\tRate: %.2f C/min\tPredicted temperature in 5 min: %.2f C\n',temp, rate_min, predictedTemp);

        %LED control logic
        if rate_min >= -4 && rate_min <= 4

            %stable temperature green LED constant on
            writeDigitalPin(a,redLED,0);
            writeDigitalPin(a,yellowLED,0);
            writeDigitalPin(a,greenLED,1);

        elseif rate_min > 4

            %temperature increase too fast red LED constant on
            writeDigitalPin(a,greenLED,0);
            writeDigitalPin(a,yellowLED,0);
            writeDigitalPin(a,redLED,1);

        else

            %temperature decrease too fast yellow LED constant on
            writeDigitalPin(a,greenLED,0);
            writeDigitalPin(a,redLED,0);
            writeDigitalPin(a,yellowLED,1);

        end

    else

        %not enough data yet
        fprintf('Collecting data\n',temp);

    end

    %make each loop take approximately 1 second
    pauseTime = 1 - toc(loop_start);
    if pauseTime > 0
        pause(pauseTime);
    end

end

end

function turnOffLEDs(a,redLED,greenLED,yellowLED)
    writeDigitalPin(a,redLED,0);
    writeDigitalPin(a,greenLED,0);
    writeDigitalPin(a,yellowLED,0);
end