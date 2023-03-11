clc;
clear;
close all;

%task 1: proepeksergasia
img=imread("moon.jpg");
gray_img=double(rgb2gray(img));
for i=1:height(gray_img)
    for j=1:width(gray_img)
        gray_img(i,j)=gray_img(i,j).*(-1)^(i+j); %metafora sixnotikou simeiou sto (0,0)
    end
end

%task 2: 2d fft me methodo grammwn sthlwn
rowsfft=[];
for i=1:height(gray_img)
    current_row=gray_img(i,:);
    rowsfft=[rowsfft; fft(current_row)];
end
tr_img=[];
for i=1:width(rowsfft)
    currentcolumn=rowsfft(:,i);
    tr_img = [tr_img, fft(currentcolumn)];
end
%task3: apeikonisi platous fasmatos se grammiki kai logarithmiki klimaka
lin_mag=abs(tr_img);
lin_mag=mat2gray(lin_mag);
imshow(lin_mag);
title("Magnitude (Linear)");
figure;
log_mag=abs(log(tr_img+1));
log_mag=mat2gray(log_mag);
imshow(log_mag);
title("Magnitute (Log)");
%task4: dhmiourgia 2d lpf 
[f1,f2]=freqspace(256,'meshgrid'); %xrhsimopoioume meshgrid gia na dhmiourghsoume to filtro
z=zeros(256,256); %gia na kathorisoume to cutoff freq
for i=1:256
    for j=1:256
        z(i,j)=sqrt(f1(i,j).^2+f2(i,j).^2);
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
figure;
surf(f1,f2,h);
title("lowpass filter, normalised cutoff freq 0.2");
filtered_img=tr_img.*h; %sineliksi ston xrono, pollaplasiasmos stin sixnotita
log_mag=abs(log(filtered_img+1));
log_mag=mat2gray(log_mag);
figure;
imshow(log_mag);
title("spectrum of filtered image");
%task 5: idft
filtered_img=ifftshift(filtered_img);
final_img=abs(ifft2(filtered_img));
figure;
imshow(final_img,[]);
title("final image");