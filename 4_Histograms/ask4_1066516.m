clc;
clear;
close all;

img1=imread("dark_road_1.jpg");
img2=imread("dark_road_2.jpg");
img3=imread("dark_road_3.jpg");
images={img1 img2 img3};

%task 1: ipologismos kai emfanisi histograms
figure(1)
set(gcf,"Position",[500 100 1200 900]);
hists={};
for i=1:1:3
    images{i}=im2gray(images{i});
    hists{i}=imhist(images{i}); %gia na ta apothikeusw
    subplot(4,3,i);
    imshow(images{i},[])
    subplot(4,3,3+i);
    imhist(images{i})
end

eqimages={};
for i = 1:1:3
    curr_img=images{i};
    cdf=cumsum(hists{i})/sum(hists{i}); %h athroistiki sinartisi
    L=256; %diaforetikes times
    T=uint8((L-1)*cdf); %transform function se uint8 opws oi eikones
    %xrisimopoioume tin T gia na kanoume map ta pixels se alla intensities
    %analoga me to intensity tous
    for j=1:1:size(curr_img,1)
        for k=1:1:size(curr_img,2)
            curr_img(j,k)=T(curr_img(j,k)+1); %+1 giati to array ksekina apo 1
        end
    end
    eqimages{i}=curr_img;
    subplot(4,3,i+6);
    imshow(eqimages{i},[]);
    subplot(4,3,i+9);
    imhist(eqimages{i});
end

%gia sintomia kwdika sto local histogram equalization entopisa tin sinartisi
%histeq ths matlab thn opoia xrisimopoiw mazi me thn sinartisi blockproc gia na thn
%efarmosw ana block opws kai sto metasxhmatismo DCT. Anti gia thn histeq
%function tha mporouse na dhmiourgithei mia nea sinartisi pou tha ekane ana
%block oti ginetai sto teleutaio for loop diladi tha ipologize kai tha
%efarmoze ton metasxhmatismo T me eisodo ena block eikonas. H sinartisi
%auti tha mporouse na xrisimopoihthei anti gia thn histeq me thn blockproc

%ston aksona y diathrw tin sinoliki eikona kaliteri alla ston aksona x
%emfanizw perissoteres leptomereies sta katw merh tis eikonas
figure(2)
set(gcf,'Position',[300 100 1200 900]);
window_size=[4 400];
%xrisimopoiw parathiro pou ehei megalitero ipsos kai mikro platos 
%(san na deigmatolhptw sixnotera ston orizontio aksona)
%giati anamenw oi "leptomereies" kai to contrast tis eikonas na vrisketai
%kata tin dieuthinsi tou x. Epishs oles oi eikones ehoun ton skouro ourano
%sto panw meros tous. Ta pixel auta theloume na ta apomonwsoume apo tis leptomereies tou dromou
%kai twn kthriwn gia na ehoume kalitero dinato equalisation se ena window.
block_fun=@(block_struct) histeq(block_struct.data);
local_eq_images={};
for i=1:1:3
    curr_img=images{i};
    %xrisimopoiw simmetriko padding gia na metavallw oso ligotero ginetai
    %to histogram kathe block
    local_eq_images{i}=blockproc(curr_img,window_size,block_fun,'PadPartialBlocks',true,'PadMethod','symmetric');
    %kanw crop tis eikones pisw sto arxiko tous megethos gia na min
    %emfanizetai to padding
    local_eq_images{i}=local_eq_images{i}(1:size(curr_img,1),1:size(curr_img,2));
    
    subplot(2,3,i);
    imshow(images{i},[]);
    subplot(2,3,i+3);
    imshow(local_eq_images{i},[]);
end

for i=1:2
    saveas(figure(i),"fig"+num2str(i)+".png");
end
