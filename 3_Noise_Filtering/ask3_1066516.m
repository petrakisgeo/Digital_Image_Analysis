clc;
clear;
close all;

img=imread("flower.png");
img=im2double(im2gray(img));
noisy_img_gaussian=imnoise(img,'gaussian',0,0.008);

%task 1: ipologismos SNR gia na vroume to mean value manually
sn=snr(img,noisy_img_gaussian-img) 

%ipologizoume oti gia na exoume mean SNR iso me 15dB, efarmozoume gaussian
%thorivo me tipiki apoklisi σ=0.008

%sxediazoume moving average filter
dim=3;
avg=fspecial('average',dim); %arxika 3x3

%apply to image
filtered_avg=imfilter(noisy_img_gaussian,avg);
filtered_median=medfilt2(noisy_img_gaussian, [dim dim]); %apply median filter

%gia elegxo twn snr meta ta filtra
[peak,snratiofiltered_avg]=psnr(filtered_avg,img);
[peak,snratiofiltered_median]=psnr(filtered_median,img);
%parathrw oti h auksisi twn diastasewn twn filtrwn
%xeirotereuei tin poiothta ths eikonas mexri opou to 11x11 filtra prokaloun
%meiwsi tou snr sxetika me tin thorivwdis eikona
%apo optiki parathrhsh to filtro moving average fainetai na diathrei
%perissoteres plhrofories kai na tholwnei ligotero tin eikona parolo pou h
%filtrarismeni eikona me to median filtro ehei megalitero SNR

figure(1);
set(gcf,'Position',[100 500 800 450]);
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
noisy_img_imp=imnoise(img,'salt & pepper', 0.25);
filtered_avg=imfilter(noisy_img_imp,avg,'conv');
filtered_median=medfilt2(noisy_img_imp);

figure(2);
set(gcf,'Position',[900 500 800 450]);
subplot(221);
imshow(img);
title("original image");
subplot(222);
imshow(noisy_img_imp,[]);
title("salt and pepper noise 25%");
subplot(223);
imshow(filtered_avg,[]);
title("moving average filter");
subplot(224);
imshow(filtered_median,[]);
title("moving median filter");

for i=1:2
    saveas(figure(i),"fig"+num2str(i)+".png");
end
