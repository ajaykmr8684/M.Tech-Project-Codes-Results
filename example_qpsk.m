clear all;
close all;
clc;

tic

EbN0 = 0:11; %���������
infoLen = 1e5; %��Ϣ����
frameNum = 10; %����֡��
moduRatio = 2;  %���ƽ���
symbolLen = infoLen/moduRatio; %���ų���
maxErrBit = 100;  %����������ޣ����Ʒ���ѭ������

errBitRatioAll = zeros(1,length(EbN0));
for i=1:length(EbN0)
    EbN0_num = 10^(EbN0(i)/10);  %�����������ֵ
    snr_num = EbN0_num*moduRatio; %�����������ֵ
    N0 = 1/snr_num; %�������ʣ�Ĭ���źŹ���Ϊ1
    segma = sqrt(N0/2); %��������
    
    errBit = 0; %�������
    for j=1:frameNum
        %% ��Դ
        info = randi(2,1,infoLen) - 1;
        %% ����
        symbolI = (-2*info(1:2:end) + 1)/sqrt(2);
        symbolQ = (-2*info(2:2:end) + 1)/sqrt(2);  %QPSK,normalized
        %% �ŵ���AWGN
        symbolRecI = symbolI + segma*randn(1,symbolLen); %�������
        symbolRecQ = symbolQ + segma*randn(1,symbolLen);
        %% �о�
        infoDecI = zeros(1,symbolLen);
        infoDecQ = zeros(1,symbolLen);
        infoDecI(symbolRecI >= 0) = 0;
        infoDecI(symbolRecI < 0) = 1;
        infoDecQ(symbolRecQ >= 0) = 0;
        infoDecQ(symbolRecQ < 0) = 1;
        infoDec = zeros(1,infoLen);
        infoDec(1:2:end) = infoDecI;
        infoDec(2:2:end) = infoDecQ;
        %% ͳ��
        diff = abs(info - infoDec); %�շ���Ϣ����
        diffNum = sum(diff); %�Ƚ��������
        if(diffNum > 0)
            errBit = errBit + diffNum; %�ۼ��������
        end
        
        if(errBit > maxErrBit)  %��������������ʱ����ѭ��
            break;
        end
    end
    errBitRatioAll(i) = errBit/(j*infoLen);  %�����������µ��������
end

toc %�������ʱ��

%% ��ͼ
figure;
semilogy(EbN0,errBitRatioAll,'r'); %����Ϊ��������
grid on;