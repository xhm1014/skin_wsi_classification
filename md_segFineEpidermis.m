%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a function used to segment the epidermis.

% Input:
%   -IM    RGB image
%   -epi_thick epidermis thickness
%   -initial_epidermis_mask  the initially segmented epidermis region
% Output:
%   -maskEpidermis    a logical matrix indicate the position of the
%                   epidermis
% Key Threshold:
%   -TTickness  %% the nomral epidermis thickness
%   -TAxisRatio % we define the enlonged one as the AxisRatio > TAxisRatio
%   -TAreaofROI %% the threshold to remove noisy pixels

% (c) Edited by Hongming Xu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  11th May, 2016
% If you have any problem feel free to contact me.
% Please address questions or comments to: mxu@ualberat.ca
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [epidermisMaskTop,imagethick_final]=md_segFineEpidermis(IM,epi_thick,initial_epidermis_mask,shown)
if ~exist('shown','var')
    shown=0;
end
TTickness=190; %% empirially selected for 25X tiff database
if epi_thick < TTickness
    epidermis_mask=initial_epidermis_mask;
    imagethick_final=epi_thick;
else
    
    sizeI=size(IM);
    OriIMsizes=sizeI(1:2);
    numrows=round(OriIMsizes(1)/6);  % down-sample by a factor of 6 for more accurate fine segmentation
    numcols=round(OriIMsizes(2)/6);
    epidermis_mask=imresize(initial_epidermis_mask,[numrows numcols]);
    IM2=imresize(IM,[numrows numcols]);
    
    %% K-means algorithm
    red=IM2(:,:,1);green=IM2(:,:,2);blue=IM2(:,:,3);
    ind=find(epidermis_mask);
    r=red(ind);g=green(ind);b=blue(ind);
    X=double([r,g,b,b]);
    [IDX,C]=kmeans(X,2,'Replicates',1);   % kmeans clustering algorithm
    
    mask=zeros(size(epidermis_mask));
    if sum(C(1,:))<sum(C(2,:))            %% based on the knowledge epidermis is darker
        mask(ind(IDX==1))=1;
    else
        mask(ind(IDX==2))=1;
    end
    CC0=bwconncomp(mask);
    numPixels=cellfun(@numel,CC0.PixelIdxList);
    TAreaofROI=round(max(numPixels)/3);
    RC_Thresh1_open1=bwareaopen(mask,TAreaofROI,8);
    RC_Thresh1_open1=imresize(RC_Thresh1_open1,size(initial_epidermis_mask));
    RC_Thresh1_open1=imclose(RC_Thresh1_open1,strel('disk',1));   %% connect regions
    if shown
        ind1=find(RC_Thresh1_open1==0);
        red(ind1)=255;green(ind1)=255;blue(ind1)=255;
        img=cat(3,red,green,blue);
        show(img);
    end
    
    epidermis_mask=zeros(size(initial_epidermis_mask));
    CC=bwconncomp(RC_Thresh1_open1);
    TAxisRatio=3;  % we define the enlonged one as the AxisRatio >3
    
    if CC.NumObjects>1
        STATStemp=regionprops(CC,'MajorAxisLength','MinorAxisLength');
        AxisRatiotemp=[STATStemp.MajorAxisLength]./[STATStemp.MinorAxisLength];
        for i=1:CC.NumObjects
            if AxisRatiotemp(i)>TAxisRatio
                epidermis_mask(CC.PixelIdxList{i})=1;
            end
        end
        if sum(epidermis_mask(:))==0
            [~,CandidateSet]=max(AxisRatiotemp);
            epidermis_mask(CC.PixelIdxList{CandidateSet})=1;
        end
    else
        epidermis_mask=RC_Thresh1_open1;
    end
    
    %     imagethick=XThicknessCal(epidermis_mask);
    imagethick_final=0;
    
end
epidermis_mask=imclose(epidermis_mask,strel('disk',1));
epidermis_mask=imdilate(epidermis_mask,strel('disk',4));

%%%%%%%%%%%%%%%%%%%%% do not consider the background part%%%%%%%%%%%%%%%%%%%
LTWhiteColor=230;                               %% threshold for white pixels
RC_PyraimdTop=IM(:,:,1);
maskWhiteBKAll=RC_PyraimdTop>LTWhiteColor;
maskWhiteBK=epidermis_mask & maskWhiteBKAll;
maskWhiteBK=imfill(maskWhiteBK,'holes');  %% holes filling
epidermisMaskTop=xor(epidermis_mask,maskWhiteBK);
epidermisMaskTop=imfill(epidermisMaskTop,'holes');  %% holes filling
TtoosmalRegion=5000;      % remove too small regions, i.e. the noisy regions
epidermisMaskTop=bwareaopen(epidermisMaskTop,TtoosmalRegion);
end