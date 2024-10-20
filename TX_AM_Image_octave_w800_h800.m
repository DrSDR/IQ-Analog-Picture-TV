
clear;
clc;
pkg load signal
pkg load image
% iq file will be placed where jpeg file is selected 
[filename, pathname, filterindex] = uigetfile('*.*','Pick a Image file','c:\AM_Image');
p1 = pathname;
pathname = [pathname filename];
data = imread(pathname);
data = rgb2gray(data);
data = double(data);
data = imresize(data,[800,800] );
[hpixels,wpixels] = size(data)
data = data / max(data(:));


fs = 48e3;
iqdata = zeros(hpixels,wpixels);
t = [1:wpixels]/fs;
f0 = 300;







for k = 1:hpixels
    iqk = [1 + 1.9*data(k,:)] .* exp(1i*2*pi*f0*t);
    iqdata(k,:) = iqk;
end


iqdata = iqdata  /  max(abs(iqdata(:)));



clear data





%create sync chirp file


rg = 1/fs;
pw = 64*rg;   %
bw = 0.8*fs;  % bandwidth of chirp ,
t = [rg:rg:pw];
t = t - pw/2;
slope = bw / (pw);
sync = exp(1i*pi*slope*t.^2);
chirpstack = repmat(sync,hpixels,1);
data = [chirpstack iqdata];
data = reshape(data.',1,[]);
data = data / max( abs(data));


pw = 1024*rg;   % preamble time ,  500 range gates
bw = 0.5*fs;  % bandwidth of chirp ,
t = [rg:rg:pw];
t = t - pw/2;
slope = bw / (pw);
preamble = exp(-1i*pi*slope*t.^2);
data = [preamble data];


% [filename, pathname] = uiputfile('*.wav','Save I/Q WAVE File','c:\8LFM\imageIQ.wav');
%  p1 = 'C:\BW_SDR_TV_AM_IQ\'
pathname = [p1 'AMImageIQ.wav'];


delay = 5;
dN = round(delay * fs);
dN = zeros(1,dN);
data = [dN data dN];
hlpf = fir1(64,0.9);
data = filter(hlpf,1,data);
data = data / max(abs(data));
data = [real(data)'  imag(data)'];
audiowrite(pathname,data,fs);





% %  make the .dat file  float32 of IQIQIQIQIQ...
% datafile = [ real(data) ; imag(data) ];
%
% datafile = reshape(datafile, 1, []);
%
% [filename pathname ] = uiputfile( '.dat', 'Save FCM .dat File To:  ');
%
% fid = fopen ([pathname filename], 'w', 'b');
%
% fwrite(fid, datafile, 'float32');
%
% fclose (fid);
%

