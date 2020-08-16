%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a function used to segment the rough epidermis area,
% Sep 13th, 2012. this is an enhanced version, still in progress
% V2: add pdf shape analysis

% Input:
%   -IM    RGB image
%   -bwRoughEpi rough epidermis mask
%   -Channel  indicates which channel will be used
% Output:
%   -maskEpidermis    a logical matrix indicate the position of the
%                   epidermis
% Key Threshold:
%   -TAxisRatio % we define the enlonged one as the AxisRatio > TAxisRatio
%   -TAreaofROI the threshold for the size of area that we think is noise

% (c) Edited by Cheng Lu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  20th Feb, 2010
% If you have any problem feel free to contact me.
% Please address questions or comments to: hacylu@yahoo.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [maskEpidermis,PDF]=LSegRoughEpidermis_enhancedV2(IM,bwRoughEpi,Channel,Para,shown)

sizeIM=size(IM);
% predefined area threshold
TAreaofROI=ceil(sizeIM(1)*sizeIM(2)/500);
% show(IM);
%  in R,G,B channels, R is the better one, so
%%  Thresholding in predefined channel
if ~exist('Channel','var')||strcmp(Channel,'R')
    Rchannel=IM(:,:,1);
else
    
    if strcmp(Channel,'G')
        Rchannel=IM(:,:,2);
    end
    
    if strcmp(Channel,'B')
        Rchannel=IM(:,:,3);
    end
    
    if strcmp(Channel,'Gray')
        Rchannel=rgb2gray(IM);
    end
    
    if strcmp(Channel,'H')
        HSV=rgb2hsv(IM);
        Rchannel=HSV(:,:,1);
    end
    
    if strcmp(Channel,'S')
        HSV=rgb2hsv(IM);
        Rchannel=HSV(:,:,2);
    end
    
    if strcmp(Channel,'V')
        HSV=rgb2hsv(IM);
        Rchannel=HSV(:,:,3);
    end
end


% show(Rchannel);
%% segment out the background first
TBKWhite=0.95;
RCnoBK=im2bw(Rchannel,TBKWhite);
RCnoBK=~RCnoBK;
%% !!! introduce a density estimation step to exclude the false positive
% use the rough epidermis mask for template desining

meanValinRoughEpi=mean(Rchannel(bwRoughEpi));

Template_radius=Para.T_radius;
% make the template as a disk like element
template = genTemplate_Bolb(Template_radius, Para.T_size, meanValinRoughEpi);
% show(template);

[R_SSD]=template_matching_SSD(template,Rchannel);
if shown
    show(R_SSD,22);
    %     show(R_NCC,22);
end

%% good threshold method is needed
SSD_Temp=R_SSD(RCnoBK);
% SSD_Temp=double(Rchannel(RCnoBK));
%%% find the local minimun on the right part of the pdf as the threshold

[n,xout]=hist(SSD_Temp,50);
n=LNorHist(n);
PDF.n=n;
PDF.xout=xout;

%% analysis the PDF shape

[flageNormal,curInterval]=LanalysisPDF4EpiSeg(PDF,0);

if flageNormal
    localMinIdx=localMaximum(-n);
    localMinIdx=setdiff(localMinIdx,[1,50]);
    
    localMaxIdx=localMaximum(n);
    if shown
        %     [n,xout]=hist(SSD_Temp,50);
        figure(29);
        plot(xout,n);hold on;
        plot(xout(localMaxIdx),n(localMaxIdx),'p');
        plot(xout(localMinIdx),n(localMinIdx),'s');
        hold off;
        %     pause(.2)
        %     saveas(figure(23),sprintf('AllIMwithEpi/IMwithEpi_%dthSet_%dthIM_pdf.jpg',Para.i,Para.j),'jpg');
    end
    
    if length(localMinIdx)>1
        
        for kk=1:length(localMinIdx)
            temp=localMinIdx(kk)-localMaxIdx<0;
            temp2=find(temp==1);
            if ~isempty(temp2)
                curLocalMaxbetweenLocalMin=[localMaxIdx(temp2(1)-1), localMaxIdx(temp2(1))];
                temp3=[n(curLocalMaxbetweenLocalMin(1))-n(localMinIdx(kk)); n(curLocalMaxbetweenLocalMin(2))-n(localMinIdx(kk))];
                if sum(temp3<0.001)>0
                    localMinIdx2beRemove(kk)=1;
                else
                    localMinIdx2beRemove(kk)=0;
                end
            else
                localMinIdx2beRemove(kk)=1;
            end
        end
        localMinIdx(logical(localMinIdx2beRemove))=[];
        % pick the right one
        localMinIdx=max(localMinIdx);
        T4R_SSD=xout(localMinIdx);
    end
    
    if length(localMinIdx)==1
        T4R_SSD=xout(localMinIdx)-0.06;
    end
    
    if isempty(localMinIdx)
        %     T4R_SSD=.65;
        T4R_SSD=graythresh(SSD_Temp)+.12;
    end
    
    % T4R_SSD=graythresh(SSD_Temp);% T4IM*255
    
    if shown
        %     [n,xout]=hist(SSD_Temp,50);
        figure(23);
        plot(xout,n);hold on;
        line([T4R_SSD,T4R_SSD],[0,max(n)],'Color','r','LineWidth',2);
        %     plot(T4R_SSD,1,T4R_SSD,max(n),'-r');
        hold off;
        %     pause(.2)
        %     saveas(figure(23),sprintf('AllIMwithEpi/IMwithEpi_%dthSet_%dthIM_pdf.jpg',Para.i,Para.j),'jpg');
    end
    
    if Para.savepdf
        %     [n,xout]=hist(SSD_Temp,50);
        figure(23);
        plot(xout,n);hold on;
        line([T4R_SSD,T4R_SSD],[0,max(n)],'Color','r','LineWidth',2);
        
        line([curInterval(1),curInterval(1)],[0,max(n)],'Color','b','LineWidth',1);
        line([curInterval(2),curInterval(2)],[0,max(n)],'Color','b','LineWidth',1);
        
        %     plot(T4R_SSD,1,T4R_SSD,max(n),'-r');
        hold off;
        pause(.2)
        saveas(figure(23),sprintf('AllIMwithEpi/IMwithEpi_%dthSet_%dthIM_pdf.jpg',Para.i,Para.j),'jpg');
    end
    
    % T4R_SSD=0.75;
    bwHighSSD=R_SSD>T4R_SSD;
    
    if shown
        show(bwHighSSD,24);
        %     LshowMaskCountouronIM(bwHighSSD,IM,24);
    end    
    
    %% remove conneting noise areas
    SE=strel('disk',round(Template_radius/2));
    bwHighSSD_o=imopen(bwHighSSD,SE);   % bwHighSSD_o=imdilate(bwHighSSD,SE);
    RC_Thresh1_open=bwareaopen(bwHighSSD_o, TAreaofROI,4);
    if shown
        show(RC_Thresh1_open);
    end
    %% analysis the remaining objs, find the enlonged one
    CC=bwconncomp(RC_Thresh1_open);
    TAxisRatio=4; % we define the enlonged one as the AxisRatio >3
    idx4Candidate=1;
    CandidateSet=[];
    if CC.NumObjects>1
        STATStemp=regionprops(CC,'MajorAxisLength','MinorAxisLength','Perimeter');
        AxisRatiotemp=[STATStemp.MajorAxisLength]./[STATStemp.MinorAxisLength];
        Perimetertemp=[STATStemp.Perimeter];
        
        TAvePremeter=mean(Perimetertemp);
        
        %     Max_Premeter=max(Perimetertemp);
        for i=1:CC.NumObjects
            if AxisRatiotemp(i)>TAxisRatio && Perimetertemp(i)>TAvePremeter
                CandidateSet(idx4Candidate)=i;
                idx4Candidate=idx4Candidate+1;
            end
        end
        
        if isempty(CandidateSet)
            [AxisRatiotemp_max,CandidateSet]=max(AxisRatiotemp);
            List_RegionwithMaxAxisRatio=CC.PixelIdxList{CandidateSet};
        else if length(CandidateSet)>1
                [Val,EpiIdxtemp]=max(Perimetertemp(CandidateSet));
                EpiIdx=CandidateSet(EpiIdxtemp);
                List_RegionwithMaxAxisRatio=CC.PixelIdxList{EpiIdx};
            else
                List_RegionwithMaxAxisRatio=CC.PixelIdxList{CandidateSet};
            end
        end
    end
    
    if CC.NumObjects==1
        List_RegionwithMaxAxisRatio=CC.PixelIdxList{1};
    end
    
    if CC.NumObjects==0
        %     bwRoughEpi;
        disp('There is no Epidermis?????');
    end
    
    clear STATStemp MaxAxisRatio CandidateSet;
    
    % LshowOnlyObj(IM,List_RegionwithMaxAxisRatio,9);
    
    %% Fill holes
    if CC.NumObjects~=0
        maskEpidermis=RC_Thresh1_open;
        maskEpidermis(:)=0;
        maskEpidermis(List_RegionwithMaxAxisRatio)=1;
    else
        maskEpidermis=bwRoughEpi;
        maskEpidermis=imopen(maskEpidermis, strel('disk',10));
    end
    % fill holes
    maskEpidermis=imfill(maskEpidermis,'holes');
    %% use enhanced erosion for the result
else    
    if Para.savepdf
        %     [n,xout]=hist(SSD_Temp,50);
        figure(23);
        plot(xout,n);hold on;
        %         line([T4R_SSD,T4R_SSD],[0,max(n)],'Color','r','LineWidth',2);
        
        line([curInterval(1),curInterval(1)],[0,max(n)],'Color','b','LineWidth',1);
        line([curInterval(2),curInterval(2)],[0,max(n)],'Color','b','LineWidth',1);
        
        %     plot(T4R_SSD,1,T4R_SSD,max(n),'-r');
        hold off;
        pause(.2)
        saveas(figure(23),sprintf('AllIMwithEpi/IMwithEpi_%dthSet_%dthIM_pdf.jpg',Para.i,Para.j),'jpg');
    end
    maskEpidermis=LSegRoughEpidermisUsingEnhancedErosion(IM,'R',0);
end
%% check it
if shown
    %     LshowMaskCountouronIM(maskEpidermis,IM,114);
end

end