clc;
clear;
close all;

img=imread("factory.jpg");
img=im2double(rgb2gray(img)); %grayscale kai scaling sto [0 1] me thn im2double

gfilter=fspecial('gaussian', size(img), 2); %dhmiourgia smoothing filter me fspecial
img_filtered=imfilter(img,gfilter,'replicate','same'); %filtrarisma eikonas

noisy=imnoise(img_filtered,'gaussian',0,0.015);
additive_noise=noisy-img_filtered;
snr(img,additive_noise) %gia manual elegxo tou SNR sta 10db
%epeidi to filtro einai kentrarismeno, protou
%ipologisoume ton FFT tou pragmatopoioume fftshift gia na to feroume sto
%(0,0). Meta tha ksanaxreiastei na kanoume fftshift to transfer function
%gia na kanoume visualize (to fftshift einai aneksartito diladi apo tin
H=fft2(gfilter); %transfer function of degradation model

figure(1);
set(gcf,'Position', [100 500 700 450]);
subplot(221);
imshow(img);
subplot(222);
imshow(noisy);
subplot(223);
imshow(fftshift(abs(H)),[]);
title("Impulse response of degradation model (PSF)");
subplot(224);
[f1,f2]=freqspace(size(H),'meshgrid');
surf(f1,f2,fftshift(abs(H)));
shading interp;
title("Frequency Response of Degradation");

%kataskeui filtrou wiener
%ipologismos twn fasmatikwn piknotitwn
n_fact=420*630; %gia diairesh me plithos pixel
N=fft2(additive_noise); %noise fft
G=fft2(noisy); %degraded+noisy image fft
F=fft2(img); %original image fft
Pn=abs(N.*N)./n_fact; %noise PSD
Pg=abs(G.*G)./n_fact; %degraded+noisy image PSD
%Pf=abs(F.*F); %original image PSD
Pf=Pg-Pn; %estimated original image PSD
Ph=abs(H.*H)./n_fact; %degradation function PSD


%W=Sh./(Sh+Pn./Ps);
W=Pf./(Pf+Pn);

F=W.*G;
wiener_img=ifft2(F);

%efarmogi inverse filter
IF=1./H;
IF(isinf(IF))=max(IF(~isinf(IF))); %gia diaireseis me to mhden.
% antikathistw ta inf me ton megalitero arithmo tou pinaka pou den einai inf
F_final=IF.*F;
final_img=ifft2(F_final);

%efarmogi threshold
threshold=2.0;
thresholded_values=threshold*abs(H).*IF;
IF(abs(IF)>threshold)=thresholded_values(abs(IF)>threshold); %efarmogi threshold
F_thresholded=IF.*F;
final_img_thresholded=ifft2(F_thresholded);
%o pollaplasiasmos me to degradation PSF to opoio einai kentrarismeno (diladi den
%ehei tin arxi tou sto (0,0)) prokalei mia metatopisi fasis sti sixnotita h
%opoia metafrazetai ws metatopish kai otan epistrefoume sto time domain.
%Gia auton ton logo parolo pou den xrisimopoihsame fftshift kata ton
%ipologismo kapoiou fasmatos pragmatopoioume twra shift logw ths
%metatopisis fasis, gia na mporoume na optikopoihsoume swsta thn eikona
%mesw ths imshow()
final_img=ifftshift(final_img);
final_img_thresholded=ifftshift(final_img_thresholded);

figure(2);
set(gcf,'Position',[700 100 1000 800],'Name','Noise PSD known');
subplot(221);
imshow(img);
title("Original Image");
subplot(222);
imshow(wiener_img);
title("Wiener No Inverse");
subplot(223);
imshow(final_img);
title("Wiener and Inverse, no threshold");
subplot(224);
imshow(final_img_thresholded);
title("Wiener and Inverse, thresholded");

%Wiener deconvolution.

%dokimasa na ftiaksw to wiener deconvolution filter alla den paragei ta
%epithimita apotelesmata opote xrisimopoihsa thn sinartisi tis matlab
% Wd=Pf.*conj(H)./(Pf.*Ph + Pn);
% Wd(isinf(Wd))=max(Wd(~isinf(Wd)));
% F_deconv=Wd.*F;
% img_deconv=ifft2(F_deconv);
% img_deconv=ifftshift(img_deconv);

img_deconv=deconvwnr(noisy,gfilter,1/10); %auto

figure(3)
set(gcf,'Position',[1000 100 800 500],'Name','Noise PSD known');
imshow(img_deconv,[]);
title("Wiener Deconvolution");


%Stin periptwsi pou den einai gnwsto to PSD, to ipologizoume apo ena
%parathiro ths PSD ths degraded eikonas stis ipsiles sixnotites
%efoson to sixnotiko shmeio vrisketai sto (0,0) theloume na ipologisoume
%thn mesh timh se ena parathiro peripou sto meso tou pinaka (ipsiles
%sixnotites)
mid_x=round(size(Pg,1)/2);
mid_y=round(size(Pg,2)/2);
%se ena parathiro 20x20 ipologizoume tin mesi timi olwn twn stoixeiwn
Pn_unknown_mean=mean(Pg(mid_x-10:mid_x+10,mid_y-10:mid_y+10),'all')
%gia sigrisi me tin mesi timi tou gnwstou noise PSD
Pn_known_mean=mean(Pn,'all')
%efarmogi twn wiener-inverse filtering kai deconvolution
Pn(:)=Pn_unknown_mean;

F=W.*G;
wiener_img=ifft2(F);

%efarmogi inverse filter
IF=1./H;
IF(isinf(IF))=max(IF(~isinf(IF))); %gia diaireseis me to mhden.
% antikathistw ta inf me ton megalitero arithmo tou pinaka pou den einai inf
F_final=IF.*F;
final_img=ifft2(F_final);

%efarmogi threshold
threshold=2.0;
thresholded_values=threshold*abs(H).*IF;
IF(abs(IF)>threshold)=thresholded_values(abs(IF)>threshold); %efarmogi threshold
F_thresholded=IF.*F;
final_img_thresholded=ifft2(F_thresholded);
%o pollaplasiasmos me to degradation PSF to opoio einai kentrarismeno (diladi den
%ehei tin arxi tou sto (0,0)) prokalei mia metatopisi fasis sti sixnotita h
%opoia metafrazetai ws metatopish kai otan epistrefoume sto time domain.
%Gia auton ton logo parolo pou den xrisimopoihsame fftshift kata ton
%ipologismo kapoiou fasmatos pragmatopoioume twra shift logw ths
%metatopisis fasis, gia na mporoume na optikopoihsoume swsta thn eikona
%mesw ths imshow()
final_img=ifftshift(final_img);
final_img_thresholded=ifftshift(final_img_thresholded);

figure(4);
set(gcf,'Position', [100 500 700 450],'Name','Noise PSD estimated from degraded image');
subplot(121);
imshow(final_img);
title("Wiener and Inverse, no threshold");
subplot(122);
imshow(final_img_thresholded);
title("Wiener and Inverse, thresholded, unknown Pn");

for i=1:4
    saveas(figure(i),"fig"+num2str(i)+".png");
end
