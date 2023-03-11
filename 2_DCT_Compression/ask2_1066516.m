clc;
clear;
close all;

file=load("barbara.mat");
img=file.barbara;

img=double(rgb2gray(img));
dct_m=dctmtx(32); %dhmiourgia pinaka metasxhmatismou DCT megethous 32x32
dct_fun=@(block_struct) dct_m * block_struct.data * dct_m';
dct_im=blockproc(img,[32 32],dct_fun); %efarmogi DCT ana block 
%methodos zwnhs: dhmiourgw thn zwnh kai meta kanw padding gia na ftiaksw
%tin maska
msevalues_zone=[];
msevalues_threshold=[];
r_zone=[];
for r=4:21
    zone=ones(r,r);
    r_zone=[r_zone r^2/32^2]; %pososto sintelestwn pou kratame gia plotting
    mask=padarray(zone,[32-r 32-r],'post');
    %discard bits according to mask
    compressed_img=blockproc(dct_im,[32 32], @(block_struct) mask.* block_struct.data);
    inversedct= @(block_struct) dct_m'*block_struct.data*dct_m;
    reconstructed_img=blockproc(compressed_img,[32 32],inversedct);
    msevalues_zone=[msevalues_zone immse(reconstructed_img, img)];
end
%endeiktika kanoume imshow to r=50%
figure;
subplot(221);
imshow(reconstructed_img,[]);
title("zone mask, r=0.5");

r_threshold=[]; %pososta
for threshold=0.23:-0.001:0
    threshold_dct_m=dct_m; %gia na dhmiourghsw ton neo dct_m me xrhsh tou threshold
    for x=1:32
        for y=1:32
            if(dct_m(x,y)<threshold) threshold_dct_m(x,y)=0;
            end
        end
    end
    discarded_pixels=sum(threshold_dct_m(:)==0);
    r_threshold=[r_threshold (32*32-discarded_pixels)/(32*32)];
    inversedct= @(block_struct) threshold_dct_m'*block_struct.data*threshold_dct_m;
    reconstructed_img=blockproc(compressed_img,[32 32],inversedct);
    msevalues_threshold=[msevalues_threshold immse(reconstructed_img, img)];
end

subplot(222);
imshow(reconstructed_img,[]);
ttl=sprintf("threshold mask, r=%1.3f",r_threshold(length(r_threshold)));
title(ttl);

subplot(223);
plot(r_zone,msevalues_zone);
axis([0.0 0.6 min(msevalues_zone)-200 max(msevalues_zone)+200]);
grid on;
title("Mean Squared Error, zone method");

subplot(224);
plot(r_threshold,msevalues_threshold);
axis([0.0 0.6 min(msevalues_threshold)-1000 max(msevalues_threshold)+1000]);
grid on;
title("Mean Squared Error, threshold method");

figure;
subplot(211);
plot(r_zone,msevalues_zone);
axis([0.0 0.6 min(msevalues_zone)-200 max(msevalues_zone)+200]);
grid on;
title("Mean Squared Error, zone method");
subplot(212);
plot(r_threshold(55:length(r_threshold)),msevalues_threshold(55:length(msevalues_threshold)));
axis([0.2 0.6 0 1500]);
grid on;
title("threshold method, zoomed in");

%apo to teleutaio diagramma katalavainoume oti h methodos katwfliou gia tin
%epilogi tis maskas xreiazetai perissotera pixels gia na ftasei se epidosi
%tin maska zwnhs