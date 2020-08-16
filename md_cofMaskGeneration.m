%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% input
% cMask--(low resolution) binary mask
% IM--color image
% dRoi--depth of interest
%eMask--epidermis mask
%dMask--dermis mask
%% Output
% maskfRoi-- mask of interest
% IMfRoi-- image of interest

% (c) Edited by Hongming Xu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  24th Feb, 2015
% If you have any problem feel free to contact me.
% Please address questions or comments to: mxu@ualberta.ca
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [maskfRoi,IMfRoi,efMask,dfMask]=md_cofMaskGeneration(cMask,IM,dRoi,eMask,dMask)

sizeI=size(IM);
temp=imresize(cMask,[sizeI(1) sizeI(2)]);
eMask=imresize(eMask,[sizeI(1) sizeI(2)]);
dMask=imresize(dMask,[sizeI(1) sizeI(2)]);
%% compute masks within bounding boxes
stats=regionprops(temp,'BoundingBox');
%pd=20;   %% empirically selected for boundaries
tmaskfRoi=cell(1,length(stats));
tIMfRoi=cell(1,length(stats));
tefMask=cell(1,length(stats));
tdfMask=cell(1,length(stats));
[nr,nc]=size(temp);
for i=1:length(stats)
    x=floor(stats(i).BoundingBox(1));
    y=floor(stats(i).BoundingBox(2));
    w=floor(stats(i).BoundingBox(3));
    h=floor(stats(i).BoundingBox(4));
    if x<1   %% make sure the bounding box is within the image
        xs=1;
    else
        xs=x;
    end
    if y<1
        ys=1;
    else
        ys=y;
    end
    if y+h>nr
        ye=nr;
    else
        ye=y+h;
    end
    if x+w>nc
        xe=nc;
    else
        xe=x+w;
    end
    tmaskfRoi{i}=temp(ys:ye,xs:xe);
    tIMfRoi{i}=IM(ys:ye,xs:xe,:);
    tefMask{i}=eMask(ys:ye,xs:xe,:);
    tdfMask{i}=dMask(ys:ye,xs:xe,:);
end

%% second pass for avoiding slanted regions
k=1;
for i=1:length(tmaskfRoi)
    temp=tmaskfRoi{i};
    tempIM=tIMfRoi{i};
    tempEM=tefMask{i};
    tempDM=tdfMask{i};
    [r,c]=size(temp);
    thr=min([r,c])/dRoi;
    if thr<3   %% 3 is an empirically threshold
        maskfRoi{k}=temp;
        IMfRoi{k}=tempIM;
        efMask{k}=tempEM;
        dfMask{k}=tempDM;
        k=k+1;
    else
        if c>r
            temp(:,round(c/2))=0;
        else
            temp(round(r/2),:)=0;
        end
        stats=regionprops(temp,'BoundingBox');
        [nr,nc]=size(temp);
        for j=1:length(stats)
            x=floor(stats(j).BoundingBox(1));
            y=floor(stats(j).BoundingBox(2));
            w=floor(stats(j).BoundingBox(3));
            h=floor(stats(j).BoundingBox(4));
            if x<1   %% make sure the bounding box is within the image
                xs=1;
            else
                xs=x;
            end
            if y<1
                ys=1;
            else
                ys=y;
            end
            if y+h>nr
                ye=nr;
            else
                ye=y+h;
            end
            if x+w>nc
                xe=nc;
            else
                xe=x+w;
            end
            maskfRoi{k}=temp(ys:ye,xs:xe);
            IMfRoi{k}=tempIM(ys:ye,xs:xe,:);
            efMask{k}=tempEM(ys:ye,xs:xe,:);
            dfMask{k}=tempDM(ys:ye,xs:xe,:);
            k=k+1;
        end
    end
end
end
