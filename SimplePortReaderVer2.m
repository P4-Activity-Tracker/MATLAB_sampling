comport = 'COM2'; % porten til jeres arduino

serial_port = serial(comport, 'TimeOut', 10, 'BaudRate', 115200, 'InputBufferSize', 4096);

num_of_channels = 1;    % Antallet af kanaler
data_length = 10000;     % Antal samples per kanal i plottet
data = NaN*ones(data_length,num_of_channels);   % Initialisering af data
byte_per_channel = 2;   % Antal bytes per kanal (int16 = 2 bytes)
samples_per_channel = 40; % Antal samples per l?sning fra porten

try 
    fopen(serial_port)          % Dette fors?ger at ?bne porten
    port_open = 1;
    pause(1)
catch err
    disp(err.message)           % Skriv en fejlmeddelelse, hvis det ikke lykkedes
    disp(sprintf('\n Tjek jeres device manager for at finde jeres egen com-port\n'))
    port_open = 0;
end

if port_open                        % K?r kun nedenst?nde, hvis porten kunne ?bnes
    H = figure(1);                  % Skab en figur
    set(H,'windowstyle','modal')    % Dette tvinger figuren til at v?re i front
    key = '';                       % Variable til at stoppe while-l?kken
    disp('Data visualisering startet')  % Skriv start-besked i command-vinduet
    while (~(strcmp(key,'q') | strcmp(key,'s')))         % while-l?kken stoppes ved at trykke p? "q"-tasten
        %get(serial_port,'BytesAvailable')
        data_stream = fread(serial_port,samples_per_channel*num_of_channels,'int16');   % L?s en byte_stream fra porten
        for i = 1:num_of_channels   % Pak byte_stream data ud til en matrice
            data(:,i) = [data(samples_per_channel+1:end,i) ; data_stream(i:num_of_channels:end)];
        end
        plot(data)                              % Plot data
        v = axis;
        axis([0 data_length v(3) v(4)])
        drawnow                                 % Tving grafen til at opdatere
        key = lower(get(H,'CurrentCharacter')); % L?s om der er trykket p? en tast
    end
    fclose(serial_port)                 % Dette lukker porten
    close(H)                            % Luk figuren
    disp('Data visualisering stoppet')  % Skriv slut-besked i command-vinduet
end

if strcmp(key,'s')
    disp('Saving data ...')
    save ppg.mat data
    disp('Program stopped')
else
    disp('Program stopped')
end
