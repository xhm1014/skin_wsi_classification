%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a function used to find  the coarse epidermis area,
% for the enhanced method. Entact epidermis is not required, but highly
% highly true positive rate is required.

% Input:
%   -IM    RGB image
%   -Channel  indicates which channel will be used
% Output:
%   -maskEpidermis    a logical matrix indicate the position of the
%                   epidermis
% Key Threshold:
%   -TAxisRatio we define the enlonged one as the AxisRatio > TAxisRatio
%   -TAreaofROI the threshold to remove noisy regions

% (c) Edited by Hongming Xu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  11th May, 2016
% If you have any problem feel free to contact me.
% Please address questions or comments to: mxu@ualberta.ca
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maskEpidermis=md_segCoarseEpidermis(IM,Channel)

sizeIM=size(IM);
TAreaofROI=ceil(sizeIM(1)*sizeIM(2)/1000);              %% area threshold to remove noisy regions

%%  Thresholding in predefined channel
if ~exist('Channel','var')||strcmp(Channel,'R')
    Rchannel=IM(:,:,1);
else
    
    if strcmp(Channel,'G')
        Rchannel=IM(:,:,2);
    end
    
    if strcmp(Channel,'B')
        Rchannel=IM(:,:,3);
    end
    
    if strcmp(Channel,'Gray')
        Rchannel=rgb2gray(IM);
    end
    
    if strcmp(Channel,'H')
        HSV=rgb2hsv(IM);
        Rchannel=HSV(:,:,1);
    end
    
    if strcmp(Channel,'S')
        HSV=rgb2hsv(IM);
        Rchannel=HSV(:,:,2);
    end
    
    if strcmp(Channel,'V')
        HSV=rgb2hsv(IM);
        Rchannel=HSV(:,:,3);
    end
end

%% segment out the background first
TBKWhite=0.95;                                %% threshold to remove white background pixels
RCnoBK=im2bw(Rchannel,TBKWhite);
RCnoBK=~RCnoBK;

%% thresholding in the foreground
Rchannel=imclose(Rchannel,strel('disk',5));   %% structuring element
IM_Temp=Rchannel(RCnoBK);
% hist(double(IM_Temp),255);
T4IM=graythresh(IM_Temp);
IMlogical= im2bw(Rchannel,T4IM);
RC_Thresh1=~IMlogical;
% good for M1,M4,M115
% RC_Thresh1=LRecursiveThresholding(Rchannel,2);

RC_Thresh1_open=bwareaopen(RC_Thresh1, TAreaofROI,4);



%% analysis the remaining objs, find the longest one
CC=bwconncomp(RC_Thresh1_open,4);
TAxisRatio=3;                      % the threshold to select long and narrow shape foreground region
idx4Candidate=1;
CandidateSet=[];
if CC.NumObjects>1
    STATStemp=regionprops(CC,'MajorAxisLength','MinorAxisLength','Perimeter');
    AxisRatiotemp=[STATStemp.MajorAxisLength]./[STATStemp.MinorAxisLength];
    Perimetertemp=[STATStemp.Perimeter];
    Max_Premeter=max(Perimetertemp);
    for i=1:CC.NumObjects
        if AxisRatiotemp(i)>TAxisRatio && Perimetertemp(i)>0.4*Max_Premeter
            CandidateSet(idx4Candidate)=i;
            idx4Candidate=idx4Candidate+1;
        end
    end
    
    if isempty(CandidateSet)
        if max(AxisRatiotemp)>10  % the threshold to selection on long and narrow region
            [~,CandidateSet]=max(AxisRatiotemp);
        else
            AxisRatiotempN=LNorHist(AxisRatiotemp);
            PerimetertempN=LNorHist(Perimetertemp);
            TempPlus=AxisRatiotempN+PerimetertempN;
            [~,CandidateSet]=max(TempPlus);
        end
        
        List_RegionwithMaxAxisRatio=CC.PixelIdxList{CandidateSet};
    else
        List_RegionwithMaxAxisRatio=[];
        for i=1:length(CandidateSet)
            List_RegionwithMaxAxisRatio=[List_RegionwithMaxAxisRatio;CC.PixelIdxList{CandidateSet(i)}];
        end
    end
end

if CC.NumObjects==1
    List_RegionwithMaxAxisRatio=CC.PixelIdxList{1};
end

if CC.NumObjects==0
    error('There is no Epidermis?????');
end

clear STATStemp MaxAxisRatio CandidateSet;
maskEpidermis=RC_Thresh1_open;
maskEpidermis(:)=0;
maskEpidermis(List_RegionwithMaxAxisRatio)=1;

end