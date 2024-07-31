% read the  iq wave file
% [filename, pathname, filterindex] = uigetfile('*.*','Pick a FSK IQ wave file','c:\FSK4Level\');
clear;
close all;

fs = 48e3;

debugflag = 0;  % set to one for debug plots

[filename, pathname, filterindex] = uigetfile('*.*','Pick a Image IQ wave file','c:\AM_Image');

pathname = [pathname filename];
[message,fswave] = audioread(pathname);
[audiosamples,nch] = size(message);
if nch == 2
    message = message(:,1) + 1i*message(:,2);
    message = message.';
%     message = message / max(message);
else
    message = message';
%     message = message / max(message);
end



if fswave ~= fs

    x = gcd(fswave,fs);
    a = fs/x;
    b = fswave/x;
    message = resample(message,a,b);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% enter in expected image dim details
%image pixels height and width
h = 800;
w = 800;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%create sync chirp file


rg = 1/fs;
pw = 64*rg;   %
bw = 0.8*fs;  % bandwidth of chirp ,
t = [rg:rg:pw];
t = t - pw/2;
slope = bw / (pw);
sync = exp(1i*pi*slope*t.^2);
sN = length(sync);



pw = 1024*rg;   % preamble time ,  500 range gates
bw = 0.5*fs;  % bandwidth of chirp ,
t = [rg:rg:pw];
t = t - pw/2;
slope = bw / (pw);
preamble = exp(-1i*pi*slope*t.^2);


h1 = conj(sync(end:-1:1));
h1N = length(h1);
h2 = conj(preamble(end:-1:1));
h2N = length(h2);


%find preamble
h2detect = filter(h2,1,message);
if debugflag
    figure(56)
    plot(abs(h2detect));
    title('Preamble detect signal')
end

[Imax, index] = max(abs(h2detect));
index = index + 1;
data = message(index:end);
Ndata = length(data);

pic = zeros(h,w);
pictime = zeros(h,w);

x1 = 1;
x2 = w + sN;

for k = 1:h

    if x1 >= Ndata || x2 >= Ndata
        break
    end

    iqk = data(x1:x2);
    if debugflag
        figure(333)
        plot(real(iqk))
    end


    syncdet = filter(h1,1,iqk);
    [imax,index] = max(abs(syncdet));

    a = index + 1;

    iqpic = iqk(a:end);

    if debugflag
        figure(54)
        plot(abs(iqpic))
        title('Picture ABS line by line')
        pause(0.1);
    end


    % handle cases when not w pixels wide
    if length(iqpic) >= w
        iqpic = iqpic(1:w);
    else
        iqpic = [iqpic zeros(1, (w - length(iqpic))) ];
    end
%     iqpic = iqpic - mean(iqpic);   % remove dc from pic, may need
    pictime(k,:) = 20*log10(abs(iqpic(1:w)));
    iqpic = abs(iqpic);
    pic(k,:) = iqpic(1:w);
    x1 = x1 + index + w;
    x2 = x1 + w + sN;


end


figure(22)
colormap('winter')

imagesc(pictime);


figure(23)
colormap('bone')

imagesc(pic)




figure(24)
colormap('gray')

imagesc(pic)










