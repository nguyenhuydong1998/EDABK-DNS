close all;
clc;
load('result.mat')
SNR = [5, 10, 15, 20];

ideaPF = mean(result_ideaPF, 2); 
origin = mean(result_origin, 2);

figure()
hold on;

plot(SNR, ideaPF, '-*b', 'LineWidth', 2.5)
plot(SNR, origin, '-*r', 'LineWidth', 2.5)
title('PESQ of RNNoise with origin vs idea pitch filtering', 'FontSize', 15)
xlabel('SNR (dB)');
grid();
ylabel('PESQ');
ylim([0 4.5]);
legend('ideaPF', 'origin');
disp(['Delta = ' num2str(mean(ideaPF-origin))]);