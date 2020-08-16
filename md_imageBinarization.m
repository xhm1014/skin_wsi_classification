%% this is the second version for thresholding based binarization
% input:
% I:RGB skin image
% Dermis: binary mask with dermis as foreground
% ac: to remove small noisy regions
% output:
% Nmask3: binary mask with nuclei clumps as foreground
% NImask: binary mask with identified isolated nuclei as foreground

function [Nmask3,NImask]=md_imageBinarization(R,dMask,ac)
                                                               %% use red channel
%% HGMR module
R_hat=255-R;
%%Opening by reconstruction
S = [0 0 1 1 1 0 0;...
    0 1 1 1 1 1 0;...
    1 1 1 1 1 1 1;...
    1 1 1 1 1 1 1;...
    1 1 1 1 1 1 1;...
    0 1 1 1 1 1 0;...
    0 0 1 1 1 0 0];
% S = [0 0 1 0 0;...                                                         %% selected according to nuclei size
%      0 1 1 1 0;...
%      1 1 1 1 1 ;...
%      0 1 1 1 0;...
%      0 0 1 0 0];
Re=imerode(R_hat,S);
fRe=imreconstruct(Re,R_hat);
% Closing-by-Reconstruction
fRerc=imcomplement(fRe);
fRerce=imerode(fRerc,S);
fRercbr=imcomplement(imreconstruct(fRerce,fRerc));
R=255-fRercbr;

%% Thresholding
%thr=graythresh(R_blue);
thr=0.6;                                                                  %% manually determined better than Ostu's method
Nmask1=im2bw(R,thr);
Nmask1=Nmask1|(~dMask);
Nmask1=imopen(~Nmask1,strel('disk',2));
Nmask1=bwareaopen(Nmask1,round(ac),8);
Nmask1=imfill(Nmask1,'holes');

% %% local threshold segmentation
% [label2,n2]=bwlabel(Nmask1);
% stats2=regionprops(label2,'BoundingBox');
% Nmask2=Nmask1;
% %imshow(R)
% [r,c]=size(Nmask2);
% for j=1:n2
%     x=floor(stats2(j).BoundingBox(1));
%     y=floor(stats2(j).BoundingBox(2));
%     w=floor(stats2(j).BoundingBox(3));
%     h=floor(stats2(j).BoundingBox(4));
%     if x<1   %% make sure the bounding box is within the image
%         x=1;
%     end
%     if y<1
%         y=1;
%     end
%     if y+h>r
%         y2=r;
%     else
%         y2=y+h;
%     end
%     if x+w>c
%         x2=c;
%     else
%         x2=x+w;
%     end
%     tr=R(y:y2,x:x2);
%     rr=im2bw(tr,graythresh(tr));
%     Nmask2(y:y2,x:x2)=Nmask1(y:y2,x:x2)&(~rr);
% %      hold on,
% %      plot(stats2(j).BoundingBox(1),stats2(j).BoundingBox(2),'r*');
% %      rectangle('Position',[stats2(j).BoundingBox(1),stats2(j).BoundingBox(2),stats2(j).BoundingBox(3),stats2(j).BoundingBox(4)],...
% %         'EdgeColor','g','LineWidth',2);
% end
% Nmask2=imopen(Nmask2,strel('disk',2));
% Nmask2=bwareaopen(Nmask2,round(ac),8);
% Nmask2=imfill(Nmask2,'holes');

%% for debugging
% temp3d=cat(3,Nmask1,Nmask1,Nmask1);
% Iimg=I.*uint8(temp3d);
% show(I)
% B=bwboundaries(Nmask2);
% for j=1:length(B)
%     b1=B{j};
%     hold on,plot(b1(:,2),b1(:,1),'g-','LineWidth',2);
% end

%% find isolated nuclei centers with high fittness of convex shape
label3=bwlabel(Nmask1);
stats3=regionprops(Nmask1,'Solidity','Area');
ind3=find([stats3.Solidity]>0.93&[stats3.Area]<500);              %% 0.95 is empirically set
NImask=ismember(label3,ind3);
%c4=regionprops(NImask,'centroid');
%centroids4=cat(1,c4.Centroid);
% cs4=centroids4(:,1);
% rs4=centroids4(:,2);
Nmask3=Nmask1-NImask;
Wmask=~im2bw(R,0.8);
Nmask3=Nmask3&Wmask; %% remove background pixels
end