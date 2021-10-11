function score = PESQ(fileREF, fileDEG)

command = ['PESQ +16000 ' fileREF ' ' fileDEG];
[status, cmdout] = system(command);

score = str2num(cmdout(end-5:end));