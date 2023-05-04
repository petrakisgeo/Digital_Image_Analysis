clc;
clear;
close all;

file=load("barbara.mat");
img=file.barbara;
img=imread("lenna.jpg");
img=imresize(img,[256 256]); %mikro transform stin eikona gia na ehoume akrives fit twn 32x32 block anti gia padding
img=double(rgb2gray(img));
%xrisimopoiw thn blockproc sinartisi gia na efarmosw ton DCT matrix ana
%block 32x32 ths eikonas
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
    r_zone=[r_zone r^2/32^2]; %pososto sintelestwn pou kratame se kathe iteration. ta plots tha ginoun se auton ton aksona
    mask=padarray(zone,[32-r 32-r],'post');
    %discard bits according to mask. Se kathe 32x32 block kratame ta bits
    %pou orizei h maska
    compressed_img=blockproc(dct_im,[32 32], @(block_struct) mask.* block_struct.data);
    inversedct= @(block_struct) dct_m'*block_struct.data*dct_m;
    reconstructed_img=blockproc(compressed_img,[32 32],inversedct);
    msevalues_zone=[msevalues_zone immse(reconstructed_img, img)];
end
%endeiktika kanoume imshow to r=50%
figure(1);
set(gcf,'Position',[100 300 800 500]);
subplot(221);
imshow(reconstructed_img,[]);
title("zone mask, r=0.43");

r_threshold=[]; %pososta
for threshold=0:0.1:80
    compressed_img=dct_im;
    compressed_img(abs(compressed_img)<threshold)=0;
    remaining_coeffs=nnz(compressed_img);
    r_threshold=[r_threshold remaining_coeffs/(256*256)];
    inversedct= @(block_struct) dct_m'*block_struct.data*dct_m;
    reconstructed_img=blockproc(compressed_img,[32 32],inversedct);
    msevalues_threshold=[msevalues_threshold immse(reconstructed_img, img)];
end

subplot(222);
imshow(reconstructed_img,[]);
ttl=sprintf("threshold mask, r=%1.3f",r_threshold(end));
title(ttl);

subplot(223);
plot(r_zone,msevalues_zone);
axis([0.0 0.6 min(msevalues_zone)-200 max(msevalues_zone)+200]);
grid on;
title("Mean Squared Error, zone method");

subplot(224);
plot(r_threshold,msevalues_threshold);
axis([0.0 0.6 -100 max(msevalues_threshold)+1000]);
grid on;
title("Mean Squared Error, threshold method");

figure(2);
set(gcf,'Position',[1000 300 600 700]);
subplot(311);
plot(r_zone,msevalues_zone);
axis([0.0 0.2 min(msevalues_zone)-100 max(msevalues_zone)+100]);
grid on;
title("Mean Squared Error, zone method");
subplot(312);
plot(r_threshold,msevalues_threshold);
axis([0.0 0.2 0 max(msevalues_threshold)+100]);
grid on;
title("threshold method, zoomed in");
subplot(313);
plot(r_zone,msevalues_zone);
grid on;
hold on;
plot(r_threshold(length(r_threshold):-1:1),msevalues_threshold(length(msevalues_threshold):-1:1));
axis([0.0 0.2 0 max(msevalues_zone)+100]);
title("Zone: blue, Threshold: red");
%apo to teleutaio diagramma katalavainoume oti h methodos katwfliou gia tin
%epilogi tis maskas xreiazetai perissotera pixels gia na ftasei se epidosi
%tin maska zwnhs

for i=1:2
    saveas(figure(i),"fig"+num2str(i)+".png");
end