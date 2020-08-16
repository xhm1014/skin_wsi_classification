%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function cal the couting of Object of interest in three sub layer of
% epidermis

% Input:
%         AllCentroidInIMTiles: the first element is the y-cooridinate,
%                               second element is the x-cooridinate,
%         method: - global cal information globally
%                 - local  cal information locally, local method should be
%                   more accurate.

% Output:
%   -% O,M,I =outtest , middle, and innest

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


function [O,M,I]=LgetCountingInfo4EpiSubLayer(AllCentroidInIMTiles,AllPtsonBnd_Keratin,MorphoInfo,ResAtcurAnaMag,method)

%% cal the distance with respect to the keratin layer
AllDistance2Keratin=LAnalysisNucleiStasticInEpi(AllCentroidInIMTiles,AllPtsonBnd_Keratin);
%% global method
if strcmp(method,'global')
    AllDist=[];
    for i=1:length(AllDistance2Keratin)
        curDist=AllDistance2Keratin{i};
        if ~isempty(curDist)
            AllDist=cat(2,AllDist, curDist);
        end
    end
    
    AllDist=AllDist*ResAtcurAnaMag;
    OriNO_DetectedNuclei=length(AllDist);
    
    Limit_up=MorphoInfo.depth_mean+MorphoInfo.depth_std;
    % put the high distance to a uni value
    temp=AllDist;temp(AllDist>Limit_up)=[]; maxval=max(temp);
    AllDist(AllDist>Limit_up)=maxval;
    
    % remove the objects in keratin layer
    AllDist(AllDist<MorphoInfo.depth_mean*.2)=[];
    
    % AllDist_hist=hist(AllDist,20);
    % figure(1);hist(AllDist,20);
    
    %%% divide into three groups: innest, middle, and outtest
    AllDist_max=max(AllDist);
    AllDist_min=min(AllDist);
    % AllDist_DLevel=linspace(AllDist_min,AllDist_max,4);
    AllDist_DLevel=[0,MorphoInfo.depth_mean*.3, MorphoInfo.depth_mean*.8 ,AllDist_max];
    
    %%% count the nuclei in three groups
    O=sum(AllDist<=AllDist_DLevel(2));
    M=sum(AllDist_DLevel(2)<AllDist& AllDist<=AllDist_DLevel(3));
    I=sum(AllDist_DLevel(3)<AllDist& AllDist<=AllDist_DLevel(4));
end
%% local method
if strcmp(method,'local') 
    idx=1;
    for i=1:length(AllDistance2Keratin)
        curDist=AllDistance2Keratin{i};
        if ~isempty(curDist)
            AllDist=curDist;
            AllDist=AllDist*ResAtcurAnaMag;
            curMor=MorphoInfo.depths{i};
            curMor(curMor==0)=[];
            curMor_depth_mean=mean(curMor);
            curMor_depth_std=std(curMor);
            
            Limit_up=curMor_depth_mean+curMor_depth_std;
            % put the high distance to a uni value
            temp=AllDist;temp(AllDist>Limit_up)=[]; 
            if ~isempty(temp)
                maxval=max(temp);
            else
                maxval=AllDist(1);
            end
            
            AllDist(AllDist>Limit_up)=maxval;
            
            % remove the objects in keratin layer
            AllDist(AllDist<curMor_depth_mean*.2)=[];
            
            % AllDist_hist=hist(AllDist,20);
            % figure(1);hist(AllDist,20);
            
            %%% divide into three groups: innest, middle, and outtest
            AllDist_max=max(AllDist);
            
            % AllDist_DLevel=linspace(AllDist_min,AllDist_max,4);
            AllDist_DLevel=[0,curMor_depth_mean*.3, curMor_depth_mean*.8 ,AllDist_max];
            if numel(AllDist_DLevel)==3;
                O(idx)=sum(AllDist<=AllDist_DLevel(2));
                M(idx)=sum(AllDist_DLevel(2)<AllDist& AllDist<=AllDist_DLevel(3));
                I(idx)=0;
                idx=idx+1;
            else
                %%% count the nuclei in three groups
                O(idx)=sum(AllDist<=AllDist_DLevel(2));
                M(idx)=sum(AllDist_DLevel(2)<AllDist& AllDist<=AllDist_DLevel(3));
                I(idx)=sum(AllDist_DLevel(3)<AllDist& AllDist<=AllDist_DLevel(4));
                idx=idx+1;
            end
        end
    end    
    O=sum(O);
    M=sum(M);
    I=sum(I);    
end