clc;
clear;
close all;

load("tiger.mat");

img=double(tiger);

noisy_img_gaussian=imnoise(img,'gaussian',0,0.0064);

%task 1: ipologismos SNR gia na vroume to mean value manually
sn=snr(img,noisy_img_gaussian-img);

%ipologizoume oti gia na exoume mean SNR iso me 15dB (15.04), efarmozoume gaussian
%thorivo me tipiki apoklisi σ=0.0064

%sxediazoume moving average filter
avg=fspecial('average',2);

%apply to image
filtered_avg=imfilter(noisy_img_gaussian,avg,'conv');
filtered_median=medfilt2(noisy_img_gaussian);
[peak,snratiofiltered_avg]=psnr(filtered_avg,img);
[peak,snratiofiltered_median]=psnr(filtered_median,img);
%parathrw oti meta thn efarmogh tou filtrou o logos SNR den veltiwnetai
%parolo pou o thorivos ipsilis sixnotitas ehei apovlithei
%parathrw oti h auksisi twn diastasewn tou moving average filter
%xeirotereuei tin poiothta ths eikonas
%parathrhsh: to moving average filter ine pio katallhlo apo to moving
%median giati to moving median prokalei tholwsi kai einai pio katallhlo gia
%kroustiko thorivo
figure('Position',[200 100 800 600]);
subplot(221);
imshow(img);
title("original image");
subplot(222);
imshow(noisy_img_gaussian);
title("image with gaussian white noise std=0.064");
subplot(223);
imshow(filtered_avg);
title("moving average filtered image");
subplot(224);
imshow(filtered_median);
title("median filtered image");

%task2: kroustikos thorivos
noisy_img_imp=imnoise(img,'salt & pepper', 0.2);
filtered_avg=imfilter(noisy_img_imp,avg,'conv');
filtered_median=medfilt2(noisy_img_imp);

figure('Position',[200 100 800 600]);
subplot(221);
imshow(img);
title("original image");
subplot(222);
imshow(noisy_img_imp,[]);
title("salt and pepper noise 20%");
subplot(223);
imshow(filtered_avg,[]);
title("moving average filter");
subplot(224);
imshow(filtered_median,[]);
title("moving median filter");
%parathrw oti to moving average filter ine teleiws akatallhlo gia na
%afairesei ton kroustiko thorivo se antithesi me to moving median filter

%task3: sindiasmos thorivwn
noisy_img=imnoise(img,'gaussian',0,0.064);
noisy_img=imnoise(noisy_img,'salt & pepper',0.2);

avg_median_filtered=imfilter(medfilt2(noisy_img),avg,'conv'); %prwta median meta average
median_avg_filtered=medfilt2(imfilter(noisy_img,avg,'conv'));

figure("Position",[200,100,800,600]);
subplot(221);
imshow(img);
title("original image");
subplot(222);
imshow(noisy_img,[]);
title("gaussian+salt n pepper");
subplot(223);
imshow(avg_median_filtered,[]);
title("average first median second");
subplot(224);
imshow(filtered_median,[]);
title("median first average second");

%opws itan anamenomeno apo tin efarmogi tou average filter se
%eikona me kroustiko thorivo (to apotelesma einai ousiastika apwleia
%plhroforias), to apotelesma efarmogis prwta tou average filter einai
%arketa xeirotero