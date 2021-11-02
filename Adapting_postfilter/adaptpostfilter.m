function y_estm = adaptpostfilter(input)
% input : speech file
% output : filtered samples

[inp_aud,fs] =audioread(input); 
% [inp_aud,fs] =audioread('test_12.wav'); 
t=length(inp_aud)/fs; %%% signal duration
fprintf('Signal duration= %f secs\n',t);
fprintf('Sampling frequency= %d Hz\n',fs);

p=10;  % LPC predictor order

fr=0.03;    %frame size=30ms
fprintf('Frame size= %d ms\n',fr*1000);
frm_len=fs*fr; %no of samples in a frame
n=frm_len-1;
%% Define parameters
alpha = 0.8;
beta = 0.5;
muy = 0.5;
Cz = 0.4;
Cp= 0.1;
Uth = 0.6;
%% Find pitch
 for frm=1:frm_len:(length(inp_aud)-frm_len)
    y=inp_aud(frm:frm+n);
    autocor=xcorr(y);
    [pk,ind]=findpeaks(autocor);
    pitch_freq(frm:(frm+n)) = mean(fs./diff(ind));
    if isnan(pitch_freq(frm)) 
        pitch_freq(frm:(frm+n)) = 100 ;
    end;
    pitch_per(frm:(frm+n)) = 1/mean(fs./diff(ind));
 end
 %% Pitch indicator
 pitch_lag = round(fs./pitch_freq);
 frm_num = round(length(inp_aud)/frm_len)-1;
 x(1) = 0; % pitch indicator for each frame, initial value for first frame = 0
%  x1 = [0 ];
%  x2 = [0 ];
%  x3 = [0 ];
 for frm = 1:frm_len:(length(inp_aud)-2*frm_len)
    speech = inp_aud(frm:(frm+2*n+1)); %two frame 
    M = pitch_lag(frm+frm_len);
    x(frm+frm_len:(frm+n+frm_len)) = 1- Phi(speech,0,M)/Phi(speech,M,M); % coeff for pitch indicator
%     x1 = [x1 Phi(speech,0,M)/Phi(speech,M,M)];
%     x2 = [x2 Phi(speech,0,M+1)/Phi(speech,M+1,M+1)];
%     x3 = [x3 Phi(speech,0,M-1)/Phi(speech,M-1,M-1)];
%     xs = x1+x2+x3;
 end

%% Coefficients and gain (levinson-durbin method)
for frm=1:frm_len:(length(inp_aud)-frm_len)
    y=inp_aud(frm:frm+n);    
    coef_init=zeros(p+1);
    autocor=xcorr(y);
    R=autocor(((length(autocor)+1)./2):length(autocor));
    
    ep(1)=R(1);          
    for j=2:p+1
        tot=0;               
        for i=2:(j-1)
            tot=tot+coef_init(i,(j-1)).*R(j-i+1);
        end
        T(j)=(R(j)+tot)./ep(j-1);
        ep(j)=ep(j-1).*(1-(T(j)).^2);

        coef_init(j,j)= -T(j);
        coef_init(1,j)=1;
        for i=2:(j-1)
            coef_init(i,j)=coef_init(i,(j-1))-T(j).*coef_init((j-i+1),(j-1));
        end
    end

    q=coef_init((1:j),j)';       
    num_co=length(q);

    %% Adaptive postfilter
    %short-term filter
    st_num1(1) = 1;
    st_denom(1) = 1;
    for i = 2:1:p+1
        st_num1(i) = - alpha^i*q(i);
        st_denom(i) = - beta^i*q(i);
    end
    st_num = conv(st_num1, [1 -muy]);
    % long-term filter
    gamma = Cz*f(x(frm), Uth);
    lamda = Cp*f(x(frm), Uth);
    lt_num(frm) = 1;
    lt_denom(frm) = 1;
    pt = pitch_lag(frm) ;
    lt_num(frm +1 :(frm + pt -1)) = 0;
    lt_denom(frm +1 :(frm + pt -1)) = 0;
    lt_num(frm + pt) = gamma;
    lt_denom(frm + pt) = -lamda;
    Gl = (1-lamda*x(frm))/(1+lamda*x(frm));
    lt_num = lt_num*Gl;
    %combine filter
    y1 = filter(lt_num(frm:(frm + pt)),lt_denom(frm : (frm + pt)),y);
    y2 = filter(st_num,st_denom,y1);
    % gain estimation
    g1(1) = 0; 
    g2(1) = 0;
    g(1) = 1;
    for i = 2:1:frm_len
        g1(i) = 0.99*g1(i-1) + (1-0.99)*abs(y(i));
        g2(i) = 0.99*g2(i-1) + (1-0.99)*abs(y2(i));
        g(i) = g1(i)/g2(i);
    end
    y_estm(frm:(frm+n)) = y2 .* g;
end
end