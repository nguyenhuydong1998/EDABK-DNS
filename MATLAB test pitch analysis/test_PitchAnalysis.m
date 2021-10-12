%function [testPitch] = testpitch(fileSpeech, fileNoise, SNR)
%% Input
clear
dirData = 'data\';
fileSpeech = 'clean-speech.wav';
fileNoise = 'street-noise.wav';
SNR = 10 ;   %dB        
dirRNNoisePA = 'E:\EDABK-DNS\examples\rnnoise_demo.exe';
%dirRNNoiseOrigin = 'D:\EDABK-DNS\examples\rnnoise_demo_origin.exe';

%% Pre-processing
cleanSpeech = wav2pcm([dirData fileSpeech], 1);
noise = wav2pcm([dirData fileNoise], 1);
% Truncating file
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

% Writing file PCM
str_cleanSpeech = [fileSpeech(1:end-4) '.pcm'];
str_noise = [fileNoise(1:end-4) '.pcm'];
str_noisySpeech = [fileNoise(1:end-4) '-' num2str(SNR) 'dB.pcm'];
writePCM(str_cleanSpeech, cleanSpeech);
writePCM(str_noise, noise);
writePCM(str_noisySpeech, noisySpeech);

str_denoisedNoisySpeech = ['denoised' str_noisySpeech(1:end-4) '.pcm'];
str_denoisedCleanSpeech = ['denoised' str_cleanSpeech(1:end-4) '.pcm'];
%% Processing
% Pitch Analysis noisy speech
str_pitchNoisy = [str_noisySpeech(1:end-4) '_pitch.txt'];
str_commandPitchNoisy = [dirRNNoisePA...
                    ' ' str_noisySpeech...
                    ' ' str_denoisedNoisySpeech...
                    ' ' str_pitchNoisy];
system(str_commandPitchNoisy);
% Pitch Analysis clean speech
str_pitchClean = [str_cleanSpeech(1:end-4) '_pitch.txt'];
str_commandPitchClean = [dirRNNoisePA...
                    ' ' str_cleanSpeech...
                    ' ' str_denoisedCleanSpeech...
                    ' ' str_pitchClean];
system(str_commandPitchClean);
%% Pitch evaluation
fileCleanPitch = fopen(str_pitchClean,'r');
fileNoisyPitch = fopen(str_pitchNoisy,'r');
[pitchClean, countCleanFrame] = fscanf(fileCleanPitch, '%f');
[pitchNoise, countNoiseFrame] = fscanf(fileNoisyPitch, '%f');
fclose(fileCleanPitch);
fclose(fileNoisyPitch);
fprintf('Variance of clean speech pitch: %f \n',var(pitchClean));
fprintf('Variance of noisy speech %d dB pitch: %f \n ',SNR, var(pitchNoise));
f0 = pitch(cleanSpeech, 48000);
fprintf('%f',MAE(pitchClean,f0));
%% Deleting file
!del *.pcm
!del *.wav
!del *.txt