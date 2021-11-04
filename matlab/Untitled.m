% d = uigetdir(pwd, 'Select a folder');
d = 'E:\datasets_fullband\noise_fullband';
files = dir(fullfile(d, '**\*.wav'));

cleanName = 'E:\noise.pcm'
delete cleanName
f = fopen(cleanName, 'a');
for i = 1:length(files)
    i
    fileName = [files(i).folder '\' files(i).name];
    [data, sampleRate] = audioread(fileName);
    
    % Convert 2 channel to 1 channel
    [~, N] = size(data);
    if N ~= 1
        data = mean(data, 2);
    end
    
    % Resample to 48K          
    data48k = resample(data, 48000, sampleRate);
    data48k = int16(data48k*2^15);
    
    % Append data
    fwrite(f, data48k, 'short');
end
fclose('all');

