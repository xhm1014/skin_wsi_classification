%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to detect all the nuclei for given image
% tiles in cell variable

% Input:
%   -AllIMTiles    all the image tiles in cell  variable
%   -AllTileMask   all the mask for epidermis
% Output:
%   -AllBWInIMTiles4Nuclei: all the masks for the image tiles that indicate
%   the nuclei
%   -AllCentroidInIMTiles4Nuclei: all the nuclei centroid locations for all image tiles
%                                 in the format of [Centroid_y' Centroid_x'] 
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
function [AllBWInIMTiles4Nuclei,AllCentroidInIMTiles4Nuclei]...
    =LSegNuclei4AllIMTiles(AllIMTiles, AllTileMask)
for i=1:length(AllIMTiles)
    curIMTile=AllIMTiles{i};
    curMask=AllTileMask{i};
    if ~isempty(curMask)
        RC=curIMTile(:,:,1);
        RC_homo=LmakeHomoonRC(RC,curMask);
        AllBWInIMTiles4Nuclei{i}=LSegCellInEpi_ATLRRS(curMask,RC_homo,RC);
        %%% get the locations only
        cc=bwconncomp(AllBWInIMTiles4Nuclei{i},4);
        stats=regionprops(cc,'Centroid');
        temp=[stats.Centroid];
        Centroid_x=temp(1:2:end);Centroid_y=temp(2:2:end);
        AllCentroidInIMTiles4Nuclei{i}=[Centroid_y' Centroid_x'];
    else
        AllBWInIMTiles4Nuclei{i}=[];
        AllCentroidInIMTiles4Nuclei{i}=[];
    end
end
end