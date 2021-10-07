%% 产生波形
fs = 1024000;
depth = 1024;
width = 16;
n = 0 : (depth-1);

amp0 = 30;
wav0 = amp0;

fc1 = 25000;
amp1 = 10;
wav1 = amp1*sin(2*pi*fc1*n/fs + pi/6);

fc2 = 150000;
amp2 = 20;
wav2 = amp2*sin(2*pi*fc2*n/fs + pi/2);

Wave = wav0 + wav1 + wav2;

%% FFT 并 显示
fft_wav = fft(Wave, depth);
fft_f = (0:(depth-1))*fs/depth/1000;

% subplot(3, 1, 1)
% plot(n, Wave);
% title("波形");
% 原始数据，没转换
% subplot(3, 1, 2);
% plot(fft_f, abs(fft_wav) );
% title("幅度");
% 还不会弄
% subplot(3, 1, 3);
% plot(fft_f, atan(fft_wav) );
% title("相位");

%% 量化
% QWave = (Wave / max(abs(Wave))); % 归一化
% QWave = round(QWave * (2^(width-1)-1));
% test
QWave = 1:depth;

%% 写入文件
fid = fopen("File_input.txt", "wt");

% fprintf(fid, "test\n");
for i = 1:depth
    fprintf(fid, "%x\n", QWave(i));
end

fclose(fid);
