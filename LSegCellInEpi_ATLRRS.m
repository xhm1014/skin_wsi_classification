% this function implement the
% the proposed local thresh algorithm, better than the TBE paper one

%%% need to fix
% 1.if there is a darker region with a less-dark region, the less-dark region
% will be eliminated, check 168c=2.mat.   12/May/2011

%%% this function is used just for compare the initial result of
%%% cell segmentation, there is no cell splitting procedure.
%%%  the whole program plz see LAdaptiveThresh2SegRC4Comarision.m

function  [maskAllCells_ATLRRS]=LSegCellInEpi_ATLRRS(maskConfLHR,RC,RC_ori)
%tempCC=bwconncomp(maskConfLHR);

% for i =1 :tempCC.NumObjects
%     List_LHR=tempCC.PixelIdxList(i);
% end

% RC_LHR=RC(List_LHR{1});
% TWhiteColor=210;

% %% thresholding for comparision
% T4RC=graythresh(RC_LHR(RC_LHR<TWhiteColor));
% maskRC_Thresh = ~im2bw(RC,T4RC)& maskConfLHR;
% % show(maskRC_Thresh,1);
% % LshowObjonlybyLogicalMask(maskRC_Thresh,RC,6,2);
% maskAllCells_Ostu=maskRC_Thresh;
% % %%%%%%%%% remove bridge
% maskRC_Thresh_removebrigde=imopen(maskRC_Thresh,strel('disk',1));
% % LshowObjonlybyLogicalMask(maskRC_Thresh_removebrigde,RC,6,102);

%% adaptive thresholding for comparision
%% !!!!! I.F. !!!!!
meanValueofEpi=mean(RC(maskConfLHR));
RC(~maskConfLHR)=meanValueofEpi+30;
% show(RC);
ws=40; %window size
maskRC_adThresh=adaptivethreshold(RC,ws,0.02,0);
% LshowObjonlybyLogicalMask(~maskRC_adThresh,RC,6,2);
maskRC_Thresh=~maskRC_adThresh;
% maskAllCells_AD=maskRC_Thresh;
% maskAllCells_AD=imopen(maskAllCells_AD,strel('disk',2));

%% first remove the super big area which deemed as keratin area
cc = bwconncomp(maskRC_Thresh,4);
stats = regionprops(cc, 'Area');
idx = find([stats.Area] < 6500);
maskRC_Thresh= ismember(labelmatrix(cc), idx);

%% adjust the threshold for big area
% if the thresholding is good then the image will have many small pieces
% other wise, adjust the thresh value.
% first check if there is any large regions
tempCC=bwconncomp(maskRC_Thresh,4);
Area=zeros(1,tempCC.NumObjects);
for i=1:tempCC.NumObjects
    Area(i)=length(tempCC.PixelIdxList{i});
end

%% !!!!! I.F. !!!!!
TNormal=20*20;
TLargeArea=TNormal*1.5;
%% if find some areas very large then adjust the thresh value in that region.
while sum(Area>TLargeArea)>0
    LAreaIndx=find(Area>TLargeArea==1);
    for i=1:length(LAreaIndx)
        curLAreaList=tempCC.PixelIdxList{LAreaIndx(i)};
        curColors=RC(curLAreaList);
        
        T4curLArea=graythresh(curColors);
        curRefineLAreaList= curColors<(T4curLArea*255);
        
        maskRC_Thresh(curLAreaList(~curRefineLAreaList))=0;
%         LshowObjonlybyLogicalMask(maskRC_Thresh,RC,6,2);
    end
    
    % check again in iterative manner, until not area bigger than TLargeArea
    tempCC=bwconncomp(maskRC_Thresh,4);
    Area=zeros(1,tempCC.NumObjects);
    for i=1:tempCC.NumObjects
        Area(i)=length(tempCC.PixelIdxList{i});
    end
    
end
% LshowObjonlybyLogicalMask(maskRC_Thresh,RC,6,2);

%% remove noise, smooth the bolb object
maskRC_Thresh_fill=imfill(maskRC_Thresh,'holes');
% show( maskRC_Thresh_fill);
% LshowObjonlybyLogicalMask(maskRC_Thresh_fill,RC,6,2);

SE= strel('disk',2);
maskRC_Thresh_fill_o=imopen(maskRC_Thresh_fill,SE);
% show( maskRC_Thresh_fill_o);
% LshowObjonlybyLogicalMask(maskRC_Thresh_fill_o,RC,6,2);
%% remove small noisy objs
%% !!!!! I.F. !!!!!
%Tsmall=6*6;
Tsmall=8*8;
maskRC_Thresh_fill_oo=bwareaopen(maskRC_Thresh_fill_o,Tsmall,4);

maskRC_MS_Thresh=maskRC_Thresh_fill_oo & maskConfLHR;
% LshowObjonlybyLogicalMask(maskRC_MS_Thresh,RC,6,2);
% the candidate melanocytes mask is maskRC_MS_Thresh

% maskAllCells_ATLRRS=maskRC_MS_Thresh;
% 
%% %%%%%%%%  get the ellipse-like obj %%%%%%%%%%%%%%%%%%%%%%
% we can also use convex-hull measure to do the filtering
%% !!!!!Important Factor!!!!!
TUnSolidFit=0.15;% corresponds to 1-e_E in paper, higher will include more objs
flagtest=0;
[maskObjs_ConfEllipse1,maskLessConf]=LGroupbyEllipseFitness(...
    maskRC_MS_Thresh,flagtest,TUnSolidFit);

% LshowObjonlybyLogicalMask(maskObjs_ConfEllipse1,RC,6,2);
% LshowObjonlybyLogicalMask(maskLessConf,RC,6,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove the long and large component in maskLessConf, since they are
% likely the keratin layer

% TLongLength=0.1*min(size(maskLessConf));
TLongLength=sqrt(TNormal)*4;
%TLargeArea=TNormal*4;
TLongPerimeter=sqrt(TNormal)*8;
TAxesRatio=3.5;
CCtemp=bwconncomp(maskLessConf,4);
STATE=regionprops(CCtemp,'MajorAxisLength','MinorAxisLength','Perimeter');

idx = find(([STATE.Perimeter] > TLongPerimeter & [STATE.MajorAxisLength]>TLongLength)...
    | [STATE.MajorAxisLength]/[STATE.MinorAxisLength]>TAxesRatio);
maskLessConf_refined=maskLessConf;
maskLessConf_refined(ismember(labelmatrix(CCtemp), idx))=0;

% LshowObjonlybyLogicalMask(maskLessConf_refined,RC,6,3);
% LshowObjonlybyLogicalMask(maskLessConf_refined,RC_ori,6,3);

%% %%%%%%%% get more cofEllipse from maskLessConf_refined on RC
CC=bwconncomp(maskLessConf_refined,4);
mask4S=maskConfLHR;mask4S(:)=0;
% local thresholding for each region
for i=1:CC.NumObjects
    curObjList=CC.PixelIdxList{i};
    mask4S(curObjList)=1;
%     LshowObjonlybyLogicalMask(mask4S,RC,6,108);
%     LshowObjonlybyLogicalMask(mask4S,RC_ori,6,109);
    curColors=RC_ori(curObjList); %figure;hist(double(curColors));
    T4RC=graythresh(curColors)*255;
    ListHighObj=curObjList(curColors>T4RC);
    mask4S(ListHighObj)=0;
end
% LshowObjonlybyLogicalMask(mask4S,RC,6,3);
% make them smooth
mask4S_f=imfill(mask4S,'holes');
% show(mask4S_f,4);
mask4S_fe=bwareaopen(mask4S_f,round(Tsmall/2),4);
% show(mask4S_fe,5);
mask4S_fed=imdilate(mask4S_fe,strel('disk',1));
% show(mask4S_fed,6);

% filter the ellipse like obj again
[maskObjs_ConfEllipse2,maskLessConf]=LGroupbyEllipseFitness(...
    mask4S_fed,flagtest,TUnSolidFit);

% LshowObjonlybyLogicalMask(maskObjs_ConfEllipse2,RC,6,4);
% LshowObjonlybyLogicalMask(maskLessConf,RC,6,5);
maskObjs_ConfEllipseAll=maskObjs_ConfEllipse2|maskObjs_ConfEllipse1;
% LshowObjonlybyLogicalMask(maskObjs_ConfEllipseAll,RC,6,4);
% 
%% combine all fit objs

%% added by Hongming Xu for segmenting less confident nuclei
Para.thetaStep=pi/9;
Para.largeSigma=8;
Para.smallSigma=4;
Para.sigmaStep=-1;
Para.kerSize=Para.largeSigma*4;
Para.bandwidth=5;
[cs]=md_nucleiSeedsDetection_gLoG(RC_ori,maskLessConf,Para);
fm=zeros(size(RC_ori));
ind=sub2ind(size(RC_ori),cs(:,1),cs(:,2));
fm(ind)=1;
[bnf,~] = md_waterShed(maskLessConf,fm);
bnf=imopen(bnf,strel('disk',1));
bnf=bwareaopen(bnf,Tsmall,4);

maskAllCells_ATLRRS=bnf|maskObjs_ConfEllipseAll;
%maskAllCells_ATLRRS=maskLessConf|maskObjs_ConfEllipseAll;
maskAllCells_ATLRRS=imfill(maskAllCells_ATLRRS,'holes');
% show(RC_ori,5);
% LshowObjonlybyLogicalMask(maskAllCells_ATLRRS,RC_ori,2,4);

