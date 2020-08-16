%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a function used to find the region of interest (including epidermis and dermis).

% Input:
%   -epidermis_mask    epidermis binary mask
%   -thickenss         user-predefined interest thickness
%   -AnalysisDirection assume bottom-up direction 
% Output:
%   -dermis_mask    a binary interest mask

% (c) Edited by Hongming Xu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  24th Feb, 2015
% If you have any problem feel free to contact me.
% Please address questions or comments to: mxu@ualberta.ca
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dermis_mask]=md_segDermis(roi_mask,Rchannel,epidermis_mask)

cc1=bwconncomp(roi_mask);
dermis_mask=zeros(size(roi_mask));
for i=1:cc1.NumObjects
    curMask=zeros(cc1.ImageSize);
    curMask(cc1.PixelIdxList{i})=1;
    
    Rtemp=Rchannel.*uint8(curMask);
    TWhite=0.95;
    bw1=im2bw(Rtemp,TWhite);
%     bw2=bw1+(~curMask);
%     bw2=~bw2;
    bw2=curMask-(epidermis_mask&curMask);
    dermis_temp=bw2-bw1;
    CC1=bwconncomp(dermis_temp);
    numPixels=cellfun(@numel,CC1.PixelIdxList);
    [biggest,~]=max(numPixels);
    dermis_temp=bwareaopen(dermis_temp,round(biggest*0.1));
%    dermis_mask(CC1.PixelIdxList{idx})=1;  
    dermis_temp=imfill(dermis_temp,'holes');
    dermis_mask=dermis_mask|dermis_temp;
end
end