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


function F=LgetFeaturesInfo4EpisubLayer(AllCentroidInIMTiles4Nuclei,AllBWInIMTiles4Nuclei,eTiles,isGraph)

if isGraph
    %% graph based features:
    idx=1;
    
    for i=1:length(AllCentroidInIMTiles4Nuclei)
        curCentroid=AllCentroidInIMTiles4Nuclei{i};
        eMask=eTiles{i};
        if size(curCentroid,1)>5
            F_DTri(idx)=LFeatures_DelaunayTriangle(curCentroid(:,2),curCentroid(:,1),eMask);
            F_VDia(idx)=LFeatures_VoronoiDiagram(curCentroid(:,2),curCentroid(:,1),eMask);
            
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
end
%% morphological features

stats=[];

for i=1:length(AllBWInIMTiles4Nuclei)
    curBW=AllBWInIMTiles4Nuclei{i};
    if sum(curBW(:))>0
        
        cc = bwconncomp(curBW);
        statstemp = regionprops(cc, 'Area','Perimeter','Eccentricity','EquivDiameter',...
            'MajorAxisLength','MinorAxisLength');
        stats=[stats; statstemp];
    end
end
F.Nuclei_meanArea=mean([stats.Area]);
F.Nuclei_stdArea=std([stats.Area]);
F.Nuclei_meanPerimeter=mean([stats.Perimeter]);
F.Nuclei_stdPerimeter=std([stats.Perimeter]);
F.Nuclei_meanEccentricity=mean([stats.Eccentricity]);
F.Nuclei_stdEccentricity=std([stats.Eccentricity]);
F.Nuclei_meanEquivDiameter=mean([stats.EquivDiameter]);
F.Nuclei_stdEquivDiameter=std([stats.EquivDiameter]);
F.Nuclei_meanAxisRatio=mean([stats.MajorAxisLength]./[stats.MinorAxisLength]);
F.Nuclei_stdAxisRatio=std([stats.MajorAxisLength]./[stats.MinorAxisLength]);



