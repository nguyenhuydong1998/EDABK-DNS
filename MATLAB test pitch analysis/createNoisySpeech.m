function createNoisySpeech(fileSpeech, fileNoise, SNR)
cleanSpeech = wav2pcm(fileSpeech, 1);
noise = wav2pcm(fileNoise,1);
if length(cleanSpeech) > length(noise)
    cleanSpeech = cleanSpeech(1:length(noise));
else
    noise = noise(1:length(cleanSpeech));
end
% Mixing signal
Es = sum(cleanSpeech(:).^2);
En = sum(noise(:).^2);
alpha = sqrt(Es/(10^(SNR/20)*En));      %gain noise
noisySpeech = cleanSpeech + alpha*noise;
str_noisySpeech = [fileNoise(1:end-4) '-' SNR 'dB.pcm'];
writePCM(str_noisySpeech, noisySpeech);
end

