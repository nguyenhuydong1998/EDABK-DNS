% [PESQ_ideaPF, PESQ_origin] = testPitchFiltering(SNR, dirSpeech, dirNoise, fileNoise, fileSpeech)
function[PESQ_ideaPF, PESQ_origin] = testPitchFiltering(SNR, dirSpeech, dirNoise, fileNoise, fileSpeech)
%% Input
if nargin == 0
dirSpeech = 'data\clean\';
dirNoise = 'data\noise\';
fileSpeech = 'speech1.wav';
fileNoise = 'street-noise.wav';
SNR = 20    %dB        
end
dirRNNoiseIdeaPF = 'D:\EDABK-DNS\examples\rnnoise_demo.exe';
dirRNNoiseOrigin = 'D:\EDABK-DNS\examples\rnnoise_demo_origin.exe';

%% Pre-processing
cleanSpeech = wav2pcm([dirSpeech fileSpeech], 1);
noise = wav2pcm([dirNoise fileNoise], 1);
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
str_noisySpeech = ['noisy-' num2str(SNR) 'dB.pcm'];
writePCM(str_cleanSpeech, cleanSpeech);
writePCM(str_noise, noise);
writePCM(str_noisySpeech, noisySpeech);

%% Processing
% Original RNNoise 
str_origDenoise = [str_noisySpeech(1:end-4) '-origin.pcm'];
str_commandOrigin = [dirRNNoiseOrigin...
                    ' ' str_noisySpeech...
                    ' ' str_origDenoise]
system(str_commandOrigin);
% Idea Pitch Filtering RNNoise
str_ideaDenoise = [str_noisySpeech(1:end-4) '-ideaPF.pcm'];
str_commandIdeaPF = [dirRNNoiseIdeaPF...
                    ' ' str_cleanSpeech...
                    ' ' str_noise...
                    ' ' num2str(alpha)...
                    ' ' str_ideaDenoise]
system(str_commandIdeaPF);
%% PESQ evaluation
wav_cleanSpeech = pcm2wav(str_cleanSpeech, 48e3, 16e3);
wav_ideaDenoise = pcm2wav(str_ideaDenoise, 48e3, 16e3);
wav_origDenoise = pcm2wav(str_origDenoise, 48e3, 16e3);

cd PESQ
PESQ_ideaPF = PESQ(['..\' wav_cleanSpeech], ['..\' wav_ideaDenoise])
PESQ_origin = PESQ(['..\' wav_cleanSpeech], ['..\' wav_origDenoise])
cd ..
%% Deleting file
!del *.pcm
!del *.wav

    