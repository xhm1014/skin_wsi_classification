%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is for detect the melanocyte with given nuclei mask
% implement two main methods: RLS and LDED
% Input:
%   -im_ConfLHR  epidermis image
%   -maskConfLHR epidermis mask
%   -maskAllCells_ATLRRS  the presegmented candidate regions
%   -TAreaRatio: Threshold for the area ratio
%   -TsmalNucleiArea: Threshold for the small area
%   -debug: show intermedia result or not

% Output:
%   -bwM     the binary mask for detected melanocytes
%
% (c) Edited by Cheng Lu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  12th Aug, 2011
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

function bwM=LDetectMelanocytes_RLS(ROI_GC,maskConfLHR,ROI_bw,TAreaRatio,TsmalNucleiArea,debug)


if ~exist('debug','var')
    debug=0;
end

if ~exist('TAreaRatio','var')
    TAreaRatio=.6;
end

if ~exist('TsmalNucleiArea','var')
    TsmalNucleiArea=80;
end


%% Initial Radial line scanning for the supporting point

%GC=im_ConfLHR(:,:,2);
%ROI_bw=maskAllCells_ATLRRS;
%ROI_GC=im_ConfLHR(:,:,2);

cc=bwconncomp(ROI_bw);
stats=regionprops(cc,'Centroid','Area');
MeanIntenInEpi=LgetMeanColorInEpiArea(ROI_GC,maskConfLHR);
%AllSP=[];
%AllIrre=[];
flagRegularization=1;
AllSP=cell(1,cc.NumObjects);
AllIrre=zeros(1,cc.NumObjects);
% tic
% for i=1:cc.NumObjects
%     AllSP{i}=LfindOutterSPV3(stats(i).Centroid,stats(i).Area,...
%         ROI_GC,ROI_bw,maskAllCells_ATLRRS,'GaussianBlur',MeanIntenInEpi,flagRegularization,0);
%     AllIrre(i)=LcalIrregularity(stats(i).Centroid,AllSP{i},size(ROI_bw));
%     
% end
% toc

[GC_x,GC_y]=md_gradientMap(ROI_GC,ROI_bw,'GaussianBlur',0);
parfor i=1:cc.NumObjects
    AllSP{i}=LfindOutterSPV3(stats(i).Centroid,stats(i).Area,...
        ROI_GC,ROI_bw,GC_x,GC_y,MeanIntenInEpi,flagRegularization,0);
    AllIrre(i)=LcalIrregularity(stats(i).Centroid,AllSP{i},size(ROI_bw));
    
end

%[AllSP_Area,~,~]=LCalInfo4Melanocytes(ROI_GC,ROI_bw,AllSP,0);

cc=bwconncomp(ROI_bw);
imsize=size(ROI_bw);
AllSP_Area=zeros(1,length(cc.NumObjects));
for i=1:cc.NumObjects
    [curSP_r,curSP_c]=ind2sub(imsize,AllSP{i});
    %%% the current object turn it to binary mask
    curbw4SP=poly2mask(curSP_c,curSP_r,imsize(1),imsize(2));
    % find the support regions' ind
    curbw4SPInd=find(curbw4SP==1);
    curbwInd=cc.PixelIdxList{i};
    curbwIndDiff=setdiff(curbw4SPInd,curbwInd);
    AllSP_Area(i)=length(curbwIndDiff);
end

% AllRatio_Irre_SRArea=AllIrre(i)*100/AllSP_Area(i);% original Irre/SRArea ratio is good

% if debug
%     % % plot out
%     % figure(32);imshow(ROI_GC,'InitialMagnification','fit');hold on;
%     LshowMaskCountouronIM(ROI_bw,ROI_GC,32);hold on;
%     for i=1:length(AllSP)
%         [curSubSP_r,curSubSP_c]=ind2sub(size(ROI_bw),AllSP{i});
%         curSubSP_r=[curSubSP_r curSubSP_r(1)];
%         curSubSP_c=[curSubSP_c curSubSP_c(1)];
%         plot(curSubSP_c,curSubSP_r,'y','Linewidth',2);
%         
%         %     text(stats(i).Centroid(1),stats(i).Centroid(2),num2str(AllIrre(i)*100/AllSP_Area(i),'%.2f'),'color','y');
%         
%     end
%     hold off;
% end
%% smooth it  using morphological operations
% AllSP_s=LGetSmoothBnd(ROI_GC,ROI_bw,AllSP,0);
% for i=1:cc.NumObjects
%        AllIrre(i)=LcalIrregularity(stats(i).Centroid,AllSP_s{i},size(ROI_bw));
% end
% %%% plot out
% figure(33);imshow(ROI_GC,'InitialMagnification','fit');hold on;
% for i=1:length(AllSP_s)
%     [curSubSP_r,curSubSP_c]=ind2sub(size(ROI_bw),AllSP_s{i});
%     curSubSP_r=[curSubSP_r curSubSP_r(1)];
%     curSubSP_c=[curSubSP_c curSubSP_c(1)];
%
%     plot(curSubSP_c,curSubSP_r,'y');
%          text(stats(i).Centroid(1),stats(i).Centroid(2),num2str(AllIrre(i)*100/stats(i).Area,'%.2f'),'color','y');
%
% end
% hold off;
%% resolve the overlap
% AllNucleiArea=[stats.Area];

AllSP_NoOverlap=LResolveOverlap4RSP(ROI_bw,AllSP,AllIrre*100./AllSP_Area,0);

if debug
    %%% plot out
    % figure(34);imshow(ROI_GC,'InitialMagnification','fit');hold on;
    LshowMaskCountouronIM(ROI_bw,ROI_GC,34);hold on;
    title('Overlap Resovled');
    for i=1:length(AllSP_NoOverlap)
        [curSubSP_r,curSubSP_c]=ind2sub(size(ROI_bw),AllSP_NoOverlap{i});
        curSubSP_r=[curSubSP_r curSubSP_r(1)];
        curSubSP_c=[curSubSP_c curSubSP_c(1)];
        
        plot(curSubSP_c,curSubSP_r,'y','Linewidth',2);
        %     text(stats(i).Centroid(1),stats(i).Centroid(2),num2str(AllIrre(i)*100/AllSP_Area(i),'%.2f'),'color','y');
        
    end
    hold off;
end
%% Analysis the info in the SP
[~,~,~,...
    AllAreaRatio,AllNucleiArea]=LCalInfo4Melanocytes(ROI_GC,ROI_bw,AllSP_NoOverlap,0);

%%% the thrshold should be determined carefully

if debug
    %%% plot out
    LshowMaskCountouronIM(ROI_bw,ROI_GC,37);hold on;
    for i=1:length(AllSP_NoOverlap)
        if 1%AllAreaRatio(i) > TAreaRatio
            %AllSP_Area(i)>TDiffarea%&&AllSP_MeanIntensity(i)>TMeanInten...
            % &&AllSP_Constrast(i)>TContrast&&(AllIrre(i)*100/stats(i).Area)<TIrre
            [curSubSP_r,curSubSP_c]=ind2sub(size(ROI_bw),AllSP_NoOverlap{i});
            curSubSP_r=[curSubSP_r curSubSP_r(1)];
            curSubSP_c=[curSubSP_c curSubSP_c(1)];
            plot(curSubSP_c,curSubSP_r,'y');
            text(stats(i).Centroid(1),stats(i).Centroid(2),num2str( AllAreaRatio(i),'%.2f'),'color','y');
        end
        
    end
    hold off;
end
%% Filtering out the true malenocytes

cc=bwconncomp(ROI_bw);
idx = find(AllAreaRatio>TAreaRatio& AllNucleiArea>TsmalNucleiArea);% & AllSP_Contrast>TContrast);
bwM = ismember(labelmatrix(cc), idx);

% if debug
%     LshowMaskCountouronIM(bwM,im_ConfLHR,38);
% end