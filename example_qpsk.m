clear all;
close all;
clc;

tic

EbN0 = 0:11; %比特信噪比
infoLen = 1e5; %信息长度
frameNum = 10; %仿真帧数
moduRatio = 2;  %调制阶数
symbolLen = infoLen/moduRatio; %符号长度
maxErrBit = 100;  %误比特数上限，控制仿真循环次数

errBitRatioAll = zeros(1,length(EbN0));
for i=1:length(EbN0)
    EbN0_num = 10^(EbN0(i)/10);  %比特信噪比数值
    snr_num = EbN0_num*moduRatio; %符号信噪比数值
    N0 = 1/snr_num; %噪声功率，默认信号功率为1
    segma = sqrt(N0/2); %噪声幅度
    
    errBit = 0; %误比特数
    for j=1:frameNum
        %% 信源
        info = randi(2,1,infoLen) - 1;
        %% 调制
        symbolI = (-2*info(1:2:end) + 1)/sqrt(2);
        symbolQ = (-2*info(2:2:end) + 1)/sqrt(2);  %QPSK,normalized
        %% 信道，AWGN
        symbolRecI = symbolI + segma*randn(1,symbolLen); %添加噪声
        symbolRecQ = symbolQ + segma*randn(1,symbolLen);
        %% 判决
        infoDecI = zeros(1,symbolLen);
        infoDecQ = zeros(1,symbolLen);
        infoDecI(symbolRecI >= 0) = 0;
        infoDecI(symbolRecI < 0) = 1;
        infoDecQ(symbolRecQ >= 0) = 0;
        infoDecQ(symbolRecQ < 0) = 1;
        infoDec = zeros(1,infoLen);
        infoDec(1:2:end) = infoDecI;
        infoDec(2:2:end) = infoDecQ;
        %% 统计
        diff = abs(info - infoDec); %收发信息作差
        diffNum = sum(diff); %比较误比特数
        if(diffNum > 0)
            errBit = errBit + diffNum; %累加误比特数
        end
        
        if(errBit > maxErrBit)  %超过最大误比特数时跳出循环
            break;
        end
    end
    errBitRatioAll(i) = errBit/(j*infoLen);  %计算该信噪比下的误比特率
end

toc %计算仿真时间

%% 作图
figure;
semilogy(EbN0,errBitRatioAll,'r'); %纵轴为对数坐标
grid on;