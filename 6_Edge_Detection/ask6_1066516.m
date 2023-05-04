clc;
clear;
close all;

img=imread("clock.jpg");
img=im2double(rgb2gray(img));
%orizoume ta sobel kernels
sobel_y=[-1 -2 -1; 0 0 0; 1 2 1];
sobel_x=[-1 0 1; -2 0 2; -1 0 1];

grad_x=conv2(sobel_x,img);
grad_y=conv2(sobel_y,img);

mag=sqrt(grad_x.^2+grad_y.^2); %gradient image
angle=atan(grad_y./grad_x); %gradient angle

figure(1)
set(gcf,'Position',[100 400 1200 500]);
subplot(141);
imshow(img);
subplot(142);
imshow(mag);
subplot(143);
imhist(mag);
%thresholding
%apo to istogramma ths gradient image parathrw oti h diamesos vrisketai se
%xamhles times pixel intensity. opote ipothetw oti ena katallhlo threshold
%pithanon na vrisketai sto diasthma [0.0,0.3]
%kai me optiki parathrhsh parathrw oti
%exw polles akmes oi opoies eite diakoptontai eite den anixneuontai
%katholou (pithanotata logw xamilou contrast eikonas) opote epilegw mia
%xamili timi gia ot threshold

thresh=0.1*max(mag,[],'all');
mag(mag>=thresh)=1.0;
mag(mag<thresh)=0.0;
subplot(144);
imshow(mag);

% Hough transform
% orizoume to ρθ-plane
theta=linspace(-pi/2,pi/2,180);
d = sqrt(size(img,1)^2 + size(img,2)^2); %megisti timi tou r einai h diagwnios tou x,y plane
r=linspace(-d,d,2*d);

%ara h ipodiairesi tou xwrou tha einai h ekshs
acc_cells=zeros(length(theta),length(r));

%ipologismos gia kathe eutheia tou r-theta plane posa pixels twn akmwn
%vriskontai panw se autes tis eutheies. oi eutheies me ta perissotera
%epivevaiwmena stoixeia tha einai autes pou tha sxediastoun

for i=1:size(mag,1)
    for j=1:size(mag,2)
        if mag(i,j)>0 %an einai shmeio akmhs
            for t=1:length(theta)
                R=i*cos(theta(t))+j*sin(theta(t)); %ipologizw kathe eutheia pou dierxetai apo auto to simeio
                [~,indexofclosest]=min(abs(R-r)); %stroggilopoiw stin kontinoteri ipodiairesi tou r
                acc_cells(t,indexofclosest)=acc_cells(t,indexofclosest)+1;
                %auksanw to cell kathe eutheias pou periexei auto to simeio
                %akmis
            end
        end
    end
end

num_of_lines=100;
[~,indices]=maxk(acc_cells(:),num_of_lines);
[theta_lines,r_lines]=ind2sub(size(acc_cells),indices);

%times
ts=theta(theta_lines);
rs=r(r_lines);

figure(2);
imshow(img);
hold on;

for i=1:num_of_lines
    x=1:size(img,1);
    y=(rs(i)-x*cos(ts(i)))/sin(ts(i));
    plot(x,y,'r');
end

for i=1:2
    saveas(figure(i),"fig"+num2str(i)+".png");
end
