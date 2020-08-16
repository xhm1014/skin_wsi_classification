%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis the morphological feature (depth, shape, symmetric...) of the epidermis area

% Input:
%   -AllTileMask:   all the maske for all image tiles in cell variable
%   -AnalysisDirection: {LR|RL|UB|BU} indicate the analysis direction, assume that the
%   direction if from the outtest layer, i.e., keratin layer to the basal
%   layer.
%   -ResAtcurAnaMag: resolution at current analysis magnification
% Output:
%   -MorphoInfo: a stucture that record all the features
%                  MorphoInfo.depths    all depths for all sampling pts 
%                  MorphoInfo.depth_var 
%                  MorphoInfo.depth_std 
%  -AllPtsonBnd_Basal,AllPtsonBnd_Keratin: all boundary point on the basal
%                                          layer and keratin layer
% the length unit is in millimeters

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
function [MorphoInfo,AllPtsonBnd_Basal,AllPtsonBnd_Keratin]=LgetEpidermisMorphoInfo(AllTileMask,AnalysisDirection,ResAtcurAnaMag)
% AnalysisDirection='BU';
ActualEpiBlkNO=0;% some blk may not have content
SamRes=4; % sampling resolution for analysis the epi
TremoveSamPts=3; % the half number of pts need to be excluded when doing the measring 

% the unit is in millimeters
MorphoInfo=struct('depth_mean', 0, 'depth_var', 0, 'depth_std', 0,...
    'depths',cell(1,1) );

for i=1:length(AllTileMask)
    curMask=AllTileMask{i};
    curMaskDepth=[];
    if ~isempty(curMask)
        % bring other analysis direction to the BU analysis space
        if strcmp(AnalysisDirection,'LR')
        end
        if strcmp(AnalysisDirection,'RL')
        end
        if strcmp(AnalysisDirection,'LR')
        end
        
        if strcmp(AnalysisDirection,'BU')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % decide the interest boundary and the starting/end pts
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            cc=bwconncomp(curMask);
            STATS=regionprops(cc,'Extrema');
            Extrema=STATS.Extrema;
            % y_min=min(Extrema(1,:));
            % y_max=max(Extrema(1,:));
            % x_min=min(Extrema(2,:));
            % x_max=max(Extrema(2,:));
            %[top-left top-right right-top right-bottom bottom-right bottom-left left-bottom left-top].
            StartPts=Extrema(7,:); StartPts=fliplr(StartPts);
            EndPts=Extrema(4,:);EndPts=fliplr(EndPts);
            % get the boundary point of the mask
            BndPts=bwboundaries(curMask,8,'noholes');
            BndPts=BndPts{1};
            % get the closest pts to the StratPts
            [~,minInd]=min(sqrt((StartPts(1)-BndPts(:,1)).^2+(StartPts(2)-BndPts(:,2)).^2));
            StartPts=BndPts(minInd,:);
            % get sort boundary point
            BndPts_sort = bwtraceboundary(curMask, StartPts,'SE');
            % get the closest pts to the EndPts
            [~,minInd]=min(sqrt((EndPts(1)-BndPts_sort(:,1)).^2+(EndPts(2)-BndPts_sort(:,2)).^2));
 %           EndPts=BndPts_sort(minInd,:);
            EndPtsInd=minInd;
            [~,minInd]=min(sqrt((StartPts(1)-BndPts_sort(:,1)).^2+(StartPts(2)-BndPts_sort(:,2)).^2));
            StartPtsInd=minInd;
            
%             show(curMask,1);hold on;
%             plot(StartPts(2),StartPts(1),'bs','MarkerSize',20);
%             plot(EndPts(2),EndPts(1),'bs','MarkerSize',20);
%             hold off;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % get the sampling pts on the interest boundary for measure the depth
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % have two pontential sampling boundary list
            SamPtsonBnd_1=BndPts_sort(StartPtsInd+1:SamRes:EndPtsInd-1,:);
            SamPtsonBnd_2=BndPts_sort(EndPtsInd+1:SamRes:end-1,:);
            
            % have two pontential boundary pts on other side
            PtsonBnd_1=BndPts_sort(StartPtsInd+1:1:EndPtsInd-1,:);
            PtsonBnd_2=BndPts_sort(EndPtsInd+1:1:end-1,:);
            
%             show(curMask,1);hold on;
%             plot(SamPtsonBnd_1(:,2),SamPtsonBnd_1(:,1),'bs','MarkerSize',10);
%             plot(SamPtsonBnd_2(:,2),SamPtsonBnd_2(:,1),'bp','MarkerSize',10);
%             hold off;
            % decide one according to the AnalysisDirection
            if mean(SamPtsonBnd_1(:,1))>mean(SamPtsonBnd_2(:,1))
                SamPtsonBnd=SamPtsonBnd_1;
                PtsonBnd_Keratin=PtsonBnd_1;
                PtsonBnd_Basal=PtsonBnd_2;
            else
                SamPtsonBnd=SamPtsonBnd_2;
                PtsonBnd_Keratin=PtsonBnd_2;
                PtsonBnd_Basal=PtsonBnd_1;
            end
            % make them left to right order
            if SamPtsonBnd(1,2)>SamPtsonBnd(end,2)
                SamPtsonBnd=flipud(SamPtsonBnd);
            end
            if PtsonBnd_Basal(1,2)>PtsonBnd_Basal(end,2)
                PtsonBnd_Basal=flipud(PtsonBnd_Basal);
            end
            if PtsonBnd_Keratin(1,2)>PtsonBnd_Keratin(end,2)
                PtsonBnd_Keratin=flipud(PtsonBnd_Keratin);
            end
            AllPtsonBnd_Basal{i}=PtsonBnd_Basal;
            AllPtsonBnd_Keratin{i}=PtsonBnd_Keratin;
%             show(curMask,1);hold on;
%             plot(PtsonBnd_Keratin(:,2),PtsonBnd_Keratin(:,1),'rs','MarkerSize',10);
%             plot(PtsonBnd_Basal(:,2),PtsonBnd_Basal(:,1),'bo','MarkerSize',5);
%             hold off;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % begin to measure the depth
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % for each Sampling pts on the bnd
            SamPtsonBnd_filter=XFilter(SamPtsonBnd,181);   %added by Hongming Xu
            for j=TremoveSamPts:size(SamPtsonBnd,1)-TremoveSamPts
                % find the support base
                fitPar=polyfit(SamPtsonBnd_filter(j-TremoveSamPts+1:j+TremoveSamPts-1,2),...
                    SamPtsonBnd_filter(j-TremoveSamPts+1:j+TremoveSamPts-1,1),1);
%                 SamPtsonBnd_filter(j-TremoveSamPts+1:j+TremoveSamPts-1,2)'
%                    
%                 
                % cal the perpendicular line of fit line
                P_fitPar(1)=tan(atan(fitPar(1))+pi/2);
                P_fitPar(2)=SamPtsonBnd(j,1)-P_fitPar(1)*SamPtsonBnd(j,2);
                
%                 plotx=1:size(curMask,2);                
%                 show(curMask,1);hold on;
%                 plot(plotx,polyval(fitPar,plotx),'b');
%                 plot(plotx,polyval(P_fitPar,plotx),'r');
%                 hold off;
                %%% find the point that on the other side of the boundary
                %%% that close to the perpendicular line of the fit line
                Dist=abs(LPts2LineDistance(fliplr(PtsonBnd_Basal),P_fitPar));
                [~,minInd]=min(Dist);
                PtonPline=PtsonBnd_Basal(minInd,:);
                
%                 show(curMask,1);hold on;
%                 plot(SamPtsonBnd(j,2),SamPtsonBnd(j,1),'bs','MarkerSize',10);
%                 plot(PtonPline(2),PtonPline(1),'bo','MarkerSize',10);
%                 hold off;
                
                %%% compute the depth
                curMaskDepth(j)=norm(PtonPline-SamPtsonBnd(j,:));  
                                
            end
%             %%% remove the sampling pts that are on the two end, they may
%             %%% not be accurate and will not heart the final result
%             TremoveSamPts=4;% the half number of pts need to be removed
%             flagDone=1;
%             while flagDone
%                 if length(curMaskDepth)>TremoveSamPts*2;
%                     curMaskDepth(1:TremoveSamPts)=[];
%                     curMaskDepth(end-TremoveSamPts:end)=[];
%                     flagDone=0;
%                 else
%                     TremoveSamPts=TremoveSamPts-1;
%                 end
%             end
        end        
        MorphoInfo.depths{i}=curMaskDepth*ResAtcurAnaMag;        
        ActualEpiBlkNO=ActualEpiBlkNO+1;    
    else
        AllPtsonBnd_Basal{i}=[];
        AllPtsonBnd_Keratin{i}=[];
        MorphoInfo.depths{i}=[];
    end    
end

%% get all depths and form the output
Alldepths=[];
for i=1:length([MorphoInfo.depths])
    if ~isempty( [MorphoInfo.depths{i}])
        Alldepths=cat(2,Alldepths, MorphoInfo.depths{i});
    end
end
%%% analysis all the depths and remove some outliers
Alldepths(Alldepths==0)=[];

Alldepths_s=smooth(Alldepths,'rlowess');

% figure(99);plot(Alldepths);hold on;
% plot(Alldepths_s,'r');
% hold off;

MorphoInfo.depth_mean=mean(Alldepths_s);
MorphoInfo.depth_var=var(Alldepths_s);
MorphoInfo.depth_std=std(Alldepths_s);
end