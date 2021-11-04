dirNoise = 'data\noise\';
dirClean = 'data\clean\';
noise = dir(fullfile('data\noise\*.wav'));
clean = dir(fullfile('data\clean\*.wav'));

SNR = [5 10 15 20];
result_ideaPF = zeros(length(SNR), length(noise)*length(clean));
result_origin = result_ideaPF;
for i_snr = 1:length(SNR)
    i = 1;
    for i_clean = 1:length(clean)
       for i_noise = 1:length(noise)
            [result_ideaPF(i_snr, i),...
             result_origin(i_snr, i)] = ...
             testPitchFiltering(...
                            SNR(i_snr),...
                            dirClean,...
                            dirNoise,...
                            noise(i_noise).name,...
                            clean(i_clean).name);
             i = i+1;
       end
    end
end
