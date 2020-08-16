%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to cal the sub block info. for decompsition of the 
% epidermis mask for further analyis
% Input:
%   -bw    the epidermis mask
%   -Polarity  % predefined layout of the epidermis
%   -BZ_x,BZ_y % predefined tile/block size
%   -TtooSmallMaskRegion   % for checking the epidermis portion 

% Output:
%   -SubBlkInfo     the decompsition info. which indicates which blk make
%   up the image tile.
%   -rowInfo_LR,colInfo_LR %rowInf and colInfo store the division point at
%   row and col. (LR=low resolution)
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
function [SubBlkInfo,rowInfo_LR,colInfo_LR]=LDetermineSubBlkInfo4Epi(bw,Polarity,BZ_x,BZ_y,TtooSmallMaskRegion)

sizeIM=size(bw);
%rowInf and colInfo store the division point at row and col
[Grid_X,Grid_Y,rowInfo_LR,colInfo_LR]=LmakeGrid([BZ_y,BZ_x],sizeIM(1:2));
% LshowGridwImage(Grid_X,Grid_Y,rowInfo_LR,colInfo_LR,bw);
%% 3b. collect tiles info.

BNum_x=length(rowInfo_LR)-1;
BNum_y=length(colInfo_LR)-1;
% mask4TileGrid will indicate which tile has image (set to 1)
mask4TileGrid=zeros(BNum_x,BNum_y);
mask4TileGrid=mask4TileGrid~=0;% turn to logical matrix
% clear curBlkIM;

for i=1:BNum_x
    for j=1: BNum_y
        %         curBlkIM(:,:,1)=IM(rowInfo(i):rowInfo(i+1),colInfo(j):colInfo(j+1),1);
        %         show(curBlkIM,221);
        %         show(IM(rowInfo(i):rowInfo(i+1),colInfo(i):colInfo(i+1),1));
        
        if  sum(sum(bw(rowInfo_LR(i):rowInfo_LR(i+1),colInfo_LR(j):colInfo_LR(j+1),1)))>TtooSmallMaskRegion
            %           curBlkIM(:,:,1)=IM(rowInfo(i):rowInfo(i+1),colInfo(i):colInfo(i+1),1);
            %             curBlkIM(:,:,2)=IM(rowInfo(i):rowInfo(i+1),colInfo(j):colInfo(j+1),2);
            %             curBlkIM(:,:,3)=IM(rowInfo(i):rowInfo(i+1),colInfo(j):colInfo(j+1),3);
            mask4TileGrid(i,j)=1;
        end
    end
end
%% check the polarity by function if not specify
if ~exist('Polarity','var')
    Polarity=LcheckPolarityusingTileMap(mask4TileGrid);
end

%% 4. processing the Analysis tile-by-tile
% row-wise processing
if strcmp(Polarity,'row-wise')% then form the col-wise image
    ToBeAnalysisbyCol=cell(1,BNum_y);
    for i=1:BNum_y
        ToBeAnalysisbyCol{i}=find(mask4TileGrid(:,i)==1);
        % check continouity
        temp=ToBeAnalysisbyCol{i};
        if sum(diff(temp)~=(length(temp)-1))%have problem
            Proind=diff(temp)~=1;
            temp(Proind)=[];
            ToBeAnalysisbyCol{i}=temp;
        end
    end
    SubBlkInfo=ToBeAnalysisbyCol;
else % then form the row-wise image
    %     display('Cheng~~ Come and Check');pause();
    
    ToBeAnalysisbyRow=cell(1,BNum_x);
    for i=1:BNum_x
        ToBeAnalysisbyRow{i}=find(mask4TileGrid(i,:)==1);
        % check continouity
        temp=ToBeAnalysisbyRow{i};
        if sum(diff(temp)~=(length(temp)-1))%have problem
            Proind=diff(temp)~=1;
            temp(Proind)=[];
            ToBeAnalysisbyRow{i}=temp;
        end
    end
    SubBlkInfo=ToBeAnalysisbyRow;
end