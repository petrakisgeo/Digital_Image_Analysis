clc;
clear;
close all;


img=imread("lenna.jpg");
img=double(mat2gray(rgb2gray(img))); %image scaling sto diasthma [0 1]

noisy_img=imnoise(img,'gaussian',0,0.03); %standard deviation iso me 0.03
noise=noisy_img-img;
sn=snr(img,noise); %gia SNR=10dB
figure('Position',[100 100 500 600]);
subplot(311);
imshow(noisy_img);
title("noisy image");

%ipologizw tous fft tou thorivou kai tou simatos kai apo auto ta fasmata
%isxios 
%efarmozw ta vimata tou filtrarismatos wiener
noisy_img=padarray(noisy_img,[round(257/2),round(255/2)-1],'both'); %2Nx2N padding
noise=padarray(noise,[round(257/2),round(255/2)-1],'both');
meang=mean(noisy_img(:));
noisy_img=noisy_img-meang; %afairw thn mesh timi tou noisy shmatos
noisyimg_sp=fft2(noisy_img); %ipologizw tous metasxhmatismous fft2d
noise_sp=fft2(noise);

%fasmatikes piknotites isxios
Gg=abs(noisyimg_sp).^2/(256*256);
Gn=abs(noise_sp).^2/(256*256);

Gf=Gg-Gn; 
Hw=Gf./(Gg+Gn); %dhmiourgw tin sinartisi metaforas tou filtrou 2Nx2N
filtered_fft=Hw.*noisyimg_sp; %Hadamard product elementwise pollaplasiasmos
filtered_img=ifft2(filtered_fft); %2D-IFFT

filtered_img=filtered_img+meang; %prosthetw ksana thn mesh timh stin eikona
filtered_img=filtered_img(round(257/2):round(257/2)+257,round(255/2):round(255/2)+255); %afairw to padding
subplot(312);
imshow(filtered_img,[]);
title("after wiener filtering (known spectral densities)");

%xwris gnwsi twn fasmatikwn piknotitwn (?)
filtered_img=wiener2(noisy_img);
subplot(313);
imshow(filtered_img(round(257/2):round(257/2)+257,round(255/2):round(255/2)+255));
title("after wiener filtering (unknown spectral densities)");

%merosb
%gia na ipologisoume tin kroustiki apokrisi tou sistimatos katagrafis
%aplws xrhsimopoioume gia eisodo thn 2D kroustiki sinartisi
d=zeros(257,255);
d(round(257/2),round(255/2))=1;
hpsf=psf(d);
sp_hpsf=fft2(hpsf);
figure("Position",[100 100 400 600]);
subplot(311);
imshow(abs(sp_hpsf),[]);
title("psf 2D impulse response");

subplot(312);
psfnoisy=psf(img);
imshow(psfnoisy);
title("after psf");
sp_psfnoisy=fft2(psfnoisy);
H=1./sp_hpsf; %antistrofo filtro
sp_filtered_img=zeros(257,255);
msevalues=[];
for threshold=0.1:0.001:1
    for x=1:height(H)
        for y=1:width(H)
            if(abs(H(x,y))<threshold)
                sp_filtered_img(x,y)=sp_psfnoisy(x,y)*H(x,y);
            else
                sp_filtered_img(x,y)=sp_psfnoisy(x,y)*H(x,y)*threshold*abs(1./H(x,y));
            end
        end
    end
    filtered_img=ifft2(sp_filtered_img);
    filtered_img=ifftshift(filtered_img);
    msevalues=[msevalues immse(img,filtered_img)];
end

subplot(313);
imshow(filtered_img,[]);
title("after inverse filter (threshold=1)");
figure;
plot(0.1:0.001:1,msevalues);
title('Mean Squared Error=f(threshold)');
