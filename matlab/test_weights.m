function[PESQ_new_weights, PESQ_origin] = testPitchFiltering(dirSpeech, dirNoise, fileNoisy, fileSpeech)
dirRNNoiseNewWeights = 'C:\Users\DELL\Desktop\EDABK-DNS\examples\rnnoise_demo_10m_50.exe';
dirRNNoiseOrigin = 'C:\Users\DELL\Desktop\EDABK-DNS\examples\rnnoise_demo_origin.exe';

%% Pre-processingdirSpeech noisySpeech
cleanSpeech = wav2pcm([dirSpeech fileSpeech], 1);
noisySpeech = wav2pcm([dirNoise fileNoisy], 1);

% Writing file PCM
str_cleanSpeech = [fileSpeech(1:end-3) 'pcm']
str_noisySpeech = [fileNoisy(1:end-3) 'pcm'];

writePCM(str_cleanSpeech, cleanSpeech);
writePCM(str_noisySpeech, noisySpeech);

%% Processing
% Original RNNoise 
str_origDenoise = [str_noisySpeech(1:end-4) '-origin.pcm']
str_commandOrigin = [dirRNNoiseOrigin...
                    ' ' str_noisySpeech...
                    ' ' str_origDenoise]
system(str_commandOrigin);
% new weights
str_newDenoise = [str_noisySpeech(1:end-4) '-new-weights.pcm']
str_commandNewWeights = [dirRNNoiseNewWeights...
                    ' ' str_noisySpeech...
                    ' ' str_newDenoise]
system(str_commandNewWeights);

%% PESQ evaluation
wav_cleanSpeech = pcm2wav(str_cleanSpeech, 48e3, 16e3);
wav_newDenoise = pcm2wav(str_newDenoise, 48e3, 16e3);
wav_origDenoise = pcm2wav(str_origDenoise, 48e3, 16e3);

cd C:\Users\DELL\Desktop\EDABK-DNS\matlab\pitchFilteringEvaluation\PESQ
PESQ_new_weights = PESQ(['..\' wav_cleanSpeech], ['..\' wav_newDenoise])
PESQ_origin = PESQ(['..\' wav_cleanSpeech], ['..\' wav_origDenoise])
cd ..
%% Deleting file
!del *.pcm
!del *.wav