clc;
clear;
close all;


%img=imread("moon.jpg");
img=imread("aerial.tiff");
gray_img=double(im2gray(img));
%gray_img=double(rgb2gray(img));
% for i=1:height(gray_img)
%     for j=1:width(gray_img)
%         gray_img(i,j)=gray_img(i,j).*(-1)^(i+j); 
%     end
% end

tr_img=fft2(gray_img);
tr_img=fftshift(tr_img); %metafora sixnotikou simeiou sto (0,0)
%task1: apeikonisi platous fasmatos se grammiki kai logarithmiki klimaka
lin_mag=abs(tr_img);
lin_mag=mat2gray(lin_mag); %scaling sto [0 1]
figure(1);
set(gcf, 'Position', [100 600 700 400]);
subplot(1,2,1);
imshow(lin_mag);
title("Magnitude (Linear)");

log_mag=abs(log(tr_img+1));
log_mag=mat2gray(log_mag);
subplot(1,2,2);
imshow(log_mag);
title("Magnitute (Log)");

%task2: dhmiourgia 2d lpf kai filtrarisma
[f1,f2]=freqspace(256,'meshgrid'); %xrhsimopoioume meshgrid gia na dhmiourghsoume to filtro
z=zeros(256,256); %gia na kathorisoume to cutoff freq
for i=1:256
    for j=1:256
        z(i,j)=sqrt(f1(i,j).^2+f2(i,j).^2); %ipologizoume to metro tou 2D dianismatos f tis sixnotitas
    end
end
h=zeros(256,256); %to filtro
for u=1:256
    for v=1:256
        if z(u,v)<=0.2 %normalised cutoff frequency 0.2
            h(u,v)=1;
        else
            h(u,v)=0;
        end
    end
end

figure(2);
set(gcf, 'Position', [100 100 1100 400]);
subplot(131);
surf(f1,f2,h);
shading interp;
title("lowpass filter, normalised cutoff freq 0.2");
filtered_img_low=tr_img.*h; %sineliksi ston xrono => pollaplasiasmos stin sixnotita
log_mag=abs(log(filtered_img_low+1));
log_mag=mat2gray(log_mag);
subplot(132)
imshow(log_mag);
title("spectrum of filtered image");

ir_low=ifft2(ifftshift(h)); %metaferw to sixnotiko simeio pisw sto (0,0) protou efarmosw ifft
subplot(133);
surf(ir_low);
shading interp;
title("Impulse response of lowpass filter (time domain)");

%highpass filter
hp=ones(256,256)-h; %dhmiourgia ipsiperatou filtrou stin sixnotita me xrisi tou prohgoumenou filtrou
figure(3);
set(gcf, 'Position',[700 600 1200 400]);
subplot(131);
surf(f1,f2,hp);
shading interp;
title('Highpass filter, cutoff freq=0.2')
filtered_img_high=tr_img.*hp; %efarmogi filtrou
log_mag=abs(log(filtered_img_high+1));
log_mag=mat2gray(log_mag);
subplot(132);
imshow(log_mag,[]);
title('spectrum of filtered image');
ir_high=ifft2(ifftshift(hp));
%ir_high=ifftshift(ir_high);
subplot(133);
surf(ir_high);
title('Impulse response of highpass filter (time domain)');
shading interp;

filtered_img_low=ifftshift(filtered_img_low);
final_img_low=abs(ifft2(filtered_img_low));
filtered_img_high=ifftshift(filtered_img_high);
final_img_high=abs(ifft2(filtered_img_high));

figure(4);
set(gcf, 'Position', [1200 100 600 400]);
subplot(133);
imshow(final_img_high,[]);
title('high-filtered image');
subplot(132);
imshow(final_img_low,[]);
title("low-filtered image");
subplot(131);
imshow(img,[]);
title("starting image");

for i=1:4
    saveas(figure(i),num2str(i)+".png")
end
