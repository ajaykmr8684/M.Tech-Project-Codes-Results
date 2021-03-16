%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All rights reserved by Krishna Pillai, http://www.dsplog.com 
% The file may not be re-distributed without explicit authorization
% from Krishna Pillai.
% Checked for proper operation with Octave Version 3.0.0
% Author	: Krishna Pillai
% Email		: krishna@dsplog.com
% Version	: 1.0
% Date		: 05 June 2008
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Simple Matlab example of binary Frequency Shift Keying using
% coherent demodulation

clear
N = 10^5 % number of bits or symbols
T = 8; % symbol duration
t = [0:1/T:0.99]; % sampling instants
tR = kron(ones(1,N),t); % repeating the sampling instants 

Eb_N0_dB = [0:11]; % multiple Eb/N0 values

for ii = 1:length(Eb_N0_dB)
   % generating the bits
   ip = rand(1,N)>0.5; % generating 0,1 with equal probability
   freqM = ip+1; % converting the bits into frequency, bit0 -> frequency of 1, bit1 -> frequency of 2
   freqR = kron(freqM,ones(1,T)); % repeating
   x = (sqrt(2)/sqrt(T))*cos(2*pi*freqR.*tR); %generating the FSK modulated signal 

   % noise
   n = 1/sqrt(2)*[randn(1,N*T) + j*randn(1,N*T)]; % white gaussian noise, 0dB variance 

   % coherent receiver
   y = x + 10^(-Eb_N0_dB(ii)/20)*n; % additive white gaussian noise
   op1 = conv(y, sqrt(2/T)*cos(2*pi*1*t)); % correlating with frequency 1
   op2 = conv(y, sqrt(2/T)*cos(2*pi*2*t)); % correlating with frequency 2 

   % demodulation
   ipHat = [real(op1(T+1:T:end)) < real(op2(T+1:T:end))]; %
   nErr(ii) = size(find([ip - ipHat]),2); % counting the number of errors 

end
simBer = nErr/N;
theoryBer = 0.5*erfc(sqrt((10.^(Eb_N0_dB/10))/2)); %theoretical BER 

close all
figure
semilogy(Eb_N0_dB,theoryBer,'b-');
hold on
semilogy(Eb_N0_dB,simBer,'mx-');
axis([0 11 10^-4 0.5])
grid on
legend('theory:fsk-coh', 'sim:fsk-coh');
xlabel('Eb/No, dB')
ylabel('Bit Error Rate')
title('Bit error probability curve')





