%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function cal the features based on the centroids of ROIs, and the
% morphological features of the nuclei

% Input:
%         AllCentroidInIMTiles: the first element is the y-cooridinate,
%                               second element is the x-cooridinate,

% Output:
%   - F


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


function F=md_graphFeats(AllCentroidInIMTiles4Nuclei,dTiles)
%% graph based features:
idx=1;

for i=1:length(AllCentroidInIMTiles4Nuclei)
        curCentroid=AllCentroidInIMTiles4Nuclei{i};
        dMask=dTiles{i};
        if size(curCentroid,1)>5
            F_DTri(idx)=LFeatures_DelaunayTriangle(curCentroid(:,1),curCentroid(:,2),dMask);
            F_VDia(idx)=LFeatures_VoronoiDiagram(curCentroid(:,1),curCentroid(:,2),dMask);            
            
            idx=idx+1;
        end
end

F.DTri_meanArea=mean([F_DTri.Area]);
F.DTri_meanPerimeter=mean([F_DTri.Perimeter]);
F.DTri_stdArea=std([F_DTri.Area]);
F.DTri_stdPerimeter=std([F_DTri.Perimeter]);

F.VDia_meanArea=mean([F_VDia.Area]);
F.VDia_meanPerimeter=mean([F_VDia.Perimeter]);
F.VDia_stdArea=std([F_VDia.Area]);
F.VDia_stdPerimeter=std([F_VDia.Perimeter]);

