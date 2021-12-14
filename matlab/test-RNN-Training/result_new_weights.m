dirNoisy = 'C:\Users\DELL\Desktop\EDABK-DNS\matlab\pitchFilteringEvaluation\data\noisy_testset_wav\';
dirClean = 'C:\Users\DELL\Desktop\EDABK-DNS\matlab\pitchFilteringEvaluation\data\clean_testset_wav\';
noisy = dir(fullfile('C:\Users\DELL\Desktop\EDABK-DNS\matlab\pitchFilteringEvaluation\data\noisy_testset_wav\*.wav'));
clean = dir(fullfile('C:\Users\DELL\Desktop\EDABK-DNS\matlab\pitchFilteringEvaluation\data\clean_testset_wav\*.wav'));

result_new = zeros(length(clean),1);
result_origin = result_new;

for i = 1:length(clean)
       [result_new(i,1),...
        result_origin(i,1)] = ...
            test_weights(...
                            dirClean,...
                            dirNoisy,...
                            noisy(i).name,...
                            clean(i).name);
       
end