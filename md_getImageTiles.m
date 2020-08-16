%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% input
% roiMask--binary mask for generating image tiles
% IM--color image for generating image tiles
% cc-- column numbers of image tiles
%% Output
% IMTiles--generated image tiles

% (c) Edited by Hongming Xu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  24th Feb, 2015
% If you have any problem feel free to contact me.
% Please address questions or comments to: mxu@ualberta.ca
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [IMTiles,efmTiles,dfmTiles]=md_getImageTiles(roiMask,IM,cc,efmRot,dfmRot)

IMTiles=[];
efmTiles=[];
dfmTiles=[];
for i=1:length(roiMask)
    [~,nn]=size(roiMask{i});
    n=[1:cc:nn,nn];
    if (n(length(n))-n(length(n)-1))<0.8*cc %% to remove narrow tiles
        n=n(1:length(n)-1);
    end
    tempMask=roiMask{i};
    tempIM=IM{i};
    tempEM=efmRot{i};
    tempDM=dfmRot{i};
    %    tIMTiles=cell(1,length(n)-1);
    for j=1:length(n)-1
        temp=tempMask(:,n(j):n(j+1));
        tIM=tempIM(:,n(j):n(j+1),:);
        tEM=tempEM(:,n(j):n(j+1));
        tDM=tempDM(:,n(j):n(j+1));
        [nr,nc]=size(temp);
        temp=bwareaopen(temp,round(sum(temp(:))/3));
        stats=regionprops(temp,'BoundingBox');
        if ~isempty(stats)
            xs=floor(stats.BoundingBox(1));
            ys=floor(stats.BoundingBox(2));
            w=floor(stats.BoundingBox(3));
            h=floor(stats.BoundingBox(4));
            if xs<1   %% make sure the bounding box is within the image
                xs=1;
            end
            if ys<1
                ys=1;
            end
            if ys+h>nr
                ye=nr;
            else
                ye=ys+h;
            end
            if xs+w>nc
                xe=nc;
            else
                xe=xs+w;
            end
            tIMTiles{j}=tIM(ys:ye,xs:xe,:);
            ttmask=tEM(ys:ye,xs:xe,:);
            ttmask=bwareaopen(ttmask,round(sum(ttmask(:)/3)));
            tefmTiles{j}=ttmask;
            
            ttmask=tDM(ys:ye,xs:xe,:);
            ttmask=bwareaopen(ttmask,round(sum(ttmask(:)/3)));
            tdfmTiles{j}=ttmask;
        end
    end
    IMTiles=[IMTiles,tIMTiles];
    efmTiles=[efmTiles,tefmTiles];
    dfmTiles=[dfmTiles,tdfmTiles];
end
end
