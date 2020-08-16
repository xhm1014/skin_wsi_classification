%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to get all the image tiles for further 
% processing

% Input:
%   -IM:         the image
%   -mask:   the mask indicates the epidermis 
%   -Polarity:   predefined layout of the epidermis
%   -SubBlkInfo:  the decompsition info. which indicates which blk make
%                  up the image tile.
%   -rowInfo_Analysislevel,colInfo_Analysislevel: the row/col Info for Analysislevel
%                                                   rowInf and colInfo store the division point at
%                                                   row and col. 
% Output:
%   -AllIMTiles     all the image tiles in cell  variable 

% (c) Edited by Cheng Lu, 
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  Sep, 2011
% If you have any problem feel free to contact me.
% Please address questions or comments to: hacylu@yahoo.com

% Terms of use: You are free to copy,
% distribute, display, and use this work, under the following
% conditions. (1) You must give the original authors credit. (2) You may
% not use or redistribute this work for commercial purposes. (3) You may
% not alter, transform, or build upon this work. (4) For any reuse or
% distribution, you must make clear to others the license terms of this
% work. (5) Any of these conditions can be waived if you get permission
% from the authors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [AllIMTiles,AllTileMask]=LgetAllIMTiles8SubInfo_p1(IM,mask,SubBlkInfo,Polarity,rowInfo_Analysislevel,colInfo_Analysislevel)
% flagwriteFile=0;% save variables on disk or not
sizeIM=size(IM);
sizebwmask=size(mask);
if strcmp(Polarity,'row-wise')% then form the col-wise image
    %%   for c=1:length(ToBeAnalysisbyCol)
    ToBeAnalysisbyCol=SubBlkInfo;
    for c=1:1:length(ToBeAnalysisbyCol)
%         IM=IMPyramid(Analysislevel).im;        
        % c=4;
        ToBeAnalysisSeqs=ToBeAnalysisbyCol{c};
        if ~isempty(ToBeAnalysisSeqs)
            im_CurColTile=[];
            mask_CurColTile=[];
            for t=1:length(ToBeAnalysisSeqs)
                i=ToBeAnalysisSeqs(t);
                j=c;
                im_CurTile=IM(rowInfo_Analysislevel(i):rowInfo_Analysislevel(i+1),colInfo_Analysislevel(j):colInfo_Analysislevel(j+1),:);
                if sizeIM(1)>sizebwmask(1) && sizeIM(2)>sizebwmask(2)
                    disp('Cheng warning: image size is > mask size, I change to the same size!');
                    mask(sizebwmask(1)+1:sizeIM(1),sizebwmask(2)+1:sizeIM(2))=0;
                end
                mask_CurTile=mask(rowInfo_Analysislevel(i):rowInfo_Analysislevel(i+1),colInfo_Analysislevel(j):colInfo_Analysislevel(j+1));
                im_CurColTile=[im_CurColTile; im_CurTile];
                mask_CurColTile=[mask_CurColTile; mask_CurTile];
            end
            % mask only turn to image
            im_maskCurColTile=LretainPixelOnly4Mask(im_CurColTile,mask_CurColTile);
            %        show(im_maskCurColTile,88);
%            AllIMTiles{c}=im_maskCurColTile;  % by Hongming Xu
            AllIMTiles{c}=im_CurColTile;       % by Hongming Xu
            AllTileMask{c}=logical(mask_CurColTile);
%             %% 4.c get the fine epidermis area (LHR)  at fine scale  based on OriIM first to save time for MS
%             RC=im_maskCurColTile(:,:,1);
%             [maskConfLHR]=LgetFineEpiatTileScaleFromOriIM(RC,logical(mask_CurColTile));
%             % LshowObjonlybyLogicalMask(maskConfLHR,im_maskCurColTile,3,103);
%             if sum(maskConfLHR)==0 % if there is no mask
%                 continue;
%             end
%             im_ConfLHR=LretainPixelOnly4Mask(im_maskCurColTile,maskConfLHR);
%             
%             %% save variables for later easy access.
%             if flagwriteFile==1
%                 % filename='1_4_T1.tif';
%                 SaveFolderName='F:/SugarSync/BigBlk4Exame/';
%                 SaveFileName=sprintf('%s%s_%s_c=%d.mat',SaveFolderName,SaveBigFileName,filename,c);
%                 save (SaveFileName,'im_maskCurColTile','mask_CurColTile','RC');
%             end
        end
    end
    %%   end
    %% Polarity=='col-wise')% then form the col-wise image
else
    %%   for c=1:length(ToBeAnalysisbyRow)
    ToBeAnalysisbyRow=SubBlkInfo;
    for c=1:1:length(ToBeAnalysisbyRow)
%         IM=IMPyramid(Analysislevel).im;
        
        % c=4;
        ToBeAnalysisSeqs=ToBeAnalysisbyRow{c};
        if ~isempty(ToBeAnalysisSeqs)
            im_CurColTile=[];
            mask_CurColTile=[];
            for t=1:length(ToBeAnalysisSeqs)
                %                 i=ToBeAnalysisSeqs(t);
                i=c;
                %                 j=c;
                j=ToBeAnalysisSeqs(t);
                im_CurTile=IM(rowInfo_Analysislevel(i):rowInfo_Analysislevel(i+1),colInfo_Analysislevel(j):colInfo_Analysislevel(j+1),:);
                if sizeIM(1)>sizebwmask(1) && sizeIM(2)>sizebwmask(2)
                    disp('Cheng warning: image size is > mask size, I change to the same size!');
                    mask(sizebwmask(1)+1:sizeIM(1),sizebwmask(2)+1:sizeIM(2))=0;
                end
                mask_CurTile=mask(rowInfo_Analysislevel(i):rowInfo_Analysislevel(i+1),colInfo_Analysislevel(j):colInfo_Analysislevel(j+1));
                im_CurColTile=[im_CurColTile im_CurTile];
                mask_CurColTile=[mask_CurColTile mask_CurTile];
            end
            % mask only turn to image
            im_maskCurColTile=LretainPixelOnly4Mask(im_CurColTile,mask_CurColTile);
            %        show(im_maskCurColTile,88);
            AllIMTiles{c}=im_maskCurColTile;
            AllTileMask{c}=logical(mask_CurColTile);
%             %% 4.c get the fine epidermis area (LHR) at fine scale  based on OriIM first to save time for MS
%             RC=im_maskCurColTile(:,:,1);
%             [maskConfLHR]=LgetFineEpiatTileScaleFromOriIM(RC,logical(mask_CurColTile));
%             %             show(mask_CurColTile);
%             % LshowObjonlybyLogicalMask(maskConfLHR,im_maskCurColTile,3,103);
%             
%             im_ConfLHR=LretainPixelOnly4Mask(im_maskCurColTile,maskConfLHR);            
%             %% save variables for later easy access.
%             
%             if flagwriteFile==1
%                 % filename='1_4_T1.tif';
%                 SaveFolderName='F:/SugarSync/BigBlk4Exame/';
%                 SaveFileName=sprintf('%s%s_%s_c=%d.mat',SaveFolderName,SaveBigFileName,filename,c);
%                 save (SaveFileName,'im_maskCurColTile','mask_CurColTile','RC');  
%             end
        end
    end
end
