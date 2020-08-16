%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to detect all the melanocytes for given image
% tiles in cell variable

% Input:
%   -AllIMTiles:    all the image tiles in cell  variable
%   -AllBWInIMTiles4Nuclei: all the masks for the image tiles that indicate
%                           the nuclei
%   -AllTileMask   all the mask for epidermis
%   -MelaDetectPar   a structure that indicates the parameter for
%                   melanocytes detection.
% Output:
%   -AllBWInIMTiles4Melanocyte: all the masks for the image tiles that indicate
%   the Melanocyte
%   -AllCentroidInIMTiles4Melanocyte: all the Melanocyte centroid locations for all image tiles
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
function [AllBWInIMTiles4Melanocyte,AllCentroidInIMTiles4Melanocyte]...
    =LSegMelanocytes4AllIMTiles(AllIMTiles,AllTileMask,AllBWInIMTiles4Nuclei,MelaDetectPar)

for i=1:length(AllIMTiles)
    curIMTile=AllIMTiles{i};
    curMask=AllTileMask{i};
    curNucleiMask=AllBWInIMTiles4Nuclei{i};
    if ~isempty(curMask)&&~(sum(curNucleiMask(:))==0)
        disp(sprintf('The %dth/%d tile...\n',i,length(AllIMTiles)));
%        RC=curIMTile(:,:,2); 
        if strcmp(MelaDetectPar.Method,'LDED')
            AllBWInIMTiles4Melanocyte{i}=LdetectMelanocytes(curIMTile,curNucleiMask,...
                curMask,MelaDetectPar.T_I,MelaDetectPar.T_E,MelaDetectPar.TmuDiff,'PDF');
        else
            AllBWInIMTiles4Melanocyte{i}=LDetectMelanocytes_RLS(curIMTile,curMask,curNucleiMask,MelaDetectPar.TAreaRatio,...
                MelaDetectPar.TsmalNucleiArea);
        end
        %%% get the locations only
        cc=bwconncomp(AllBWInIMTiles4Melanocyte{i});
        stats=regionprops(cc,'Centroid');
        temp=[stats.Centroid];
        Centroid_x=temp(1:2:end);Centroid_y=temp(2:2:end);
        AllCentroidInIMTiles4Melanocyte{i}=[Centroid_y' Centroid_x'];
    else
        AllCentroidInIMTiles4Melanocyte{i}=[];
    end
end

end