%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a function used to find the region of interest (including epidermis and dermis).

% Input:
%   -epidermis_mask    epidermis binary mask
%   -thickenss         user-predefined interest thickness
%   -AnalysisDirection assume bottom-up direction
% Output:
%   -roi_mask    a binary interest mask

% (c) Edited by Hongming Xu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  24th Feb, 2015
% If you have any problem feel free to contact me.
% Please address questions or comments to: mxu@ualberta.ca
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [roi_mask]=md_roiMaskGeneration(epidermis_mask,thickness,AnalysisDirection)

SamRes=3; % sampling resolution
TremoveSamPts=3; % romove a few points for use
roi_mask=epidermis_mask;
cc1=bwconncomp(epidermis_mask);
for i=1:cc1.NumObjects
    curMask=zeros(cc1.ImageSize);
    curMask(cc1.PixelIdxList{i})=1;
    
    if strcmp(AnalysisDirection,'BU')
        cc=bwconncomp(curMask);
        STATS=regionprops(cc,'Extrema');
        
        %sequence:[top-left top-right right-top right-bottom bottom-right
        %bottom-left left-bottom left-top] step (1)
        StartPts=STATS.Extrema(7,:); % left bottom
        StartPts=fliplr(StartPts);
        EndPts=STATS.Extrema(4,:);   % right bottom
        EndPts=fliplr(EndPts);
        
        
        %         show(curMask);  %% to see intermediate results
        %         hold on,plot(StartPts(1,2),StartPts(1,1),'r*','MarkerSize',20);
        %         plot(EndPts(1,2),EndPts(1,1),'g*','MarkerSize',20);
        %         hold off;
        
        BndPts=bwboundaries(curMask,8,'noholes');
        BndPts=BndPts{1}; %% get boundary points
        [~,minInd]=min(sqrt((StartPts(1)-BndPts(:,1)).^2+(StartPts(2)-BndPts(:,2)).^2));
        StartPts=BndPts(minInd,:);
        
        % get sorted boundary points
        BndPts_sort=bwtraceboundary(curMask,StartPts,'SE');
        [~,minInd]=min(sqrt((EndPts(1)-BndPts_sort(:,1)).^2+(EndPts(2)-BndPts_sort(:,2)).^2));
        EndPts=BndPts_sort(minInd,:);
        EndPtsInd=minInd;
        [~,minInd]=min(sqrt((StartPts(1)-BndPts_sort(:,1)).^2+(StartPts(2)-BndPts_sort(:,2)).^2));
        StartPtsInd=minInd;
        
        %         show(curMask);  %% to see intermediate results
        %         hold on,plot(StartPts(1,2),StartPts(1,1),'r*','MarkerSize',20);
        %         plot(EndPts(1,2),EndPts(1,1),'g*','MarkerSize',20);
        %         hold off;
        
        % two potential sampling boundary points
        SamPtsonBnd_1=BndPts_sort(StartPtsInd+1:SamRes:EndPtsInd-1,:);
        SamPtsonBnd_2=BndPts_sort(EndPtsInd+1:SamRes:end-1,:);
        
        % have two pontential boundary pts on other side
        %        PtsonBnd_1=BndPts_sort(StartPtsInd+1:1:EndPtsInd-1,:);
        %        PtsonBnd_2=BndPts_sort(EndPtsInd+1:1:end-1,:);
        %             show(curMask);hold on; %% to see intermediate results
        %             plot(SamPtsonBnd_1(:,2),SamPtsonBnd_1(:,1),'bs','MarkerSize',10);
        %             plot(SamPtsonBnd_2(:,2),SamPtsonBnd_2(:,1),'bp','MarkerSize',10);
        %             hold off;
        % decide keratin side of boundaries according to the AnalysisDirection
        if mean(SamPtsonBnd_1(:,1))>mean(SamPtsonBnd_2(:,1)) %% the first dimension is row
            SamPtsonBnd=SamPtsonBnd_1;
            %             PtsonBnd_Keratin=PtsonBnd_1;
            %             PtsonBnd_Basal=PtsonBnd_2;
        else
            SamPtsonBnd=SamPtsonBnd_2;
            %             PtsonBnd_Keratin=PtsonBnd_2;
            %             PtsonBnd_Basal=PtsonBnd_1;
        end
        % make points order from left to right
        if SamPtsonBnd(1,2)>SamPtsonBnd(end,2)
            SamPtsonBnd=flipud(SamPtsonBnd);
        end
        %         if PtsonBnd_Basal(1,2)>PtsonBnd_Basal(end,2)
        %             PtsonBnd_Basal=flipud(PtsonBnd_Basal);
        %         end
        %         if PtsonBnd_Keratin(1,2)>PtsonBnd_Keratin(end,2)
        %             PtsonBnd_Keratin=flipud(PtsonBnd_Keratin);
        %         end
        
        LinePts=[];
        SamPtsonBnd_filter=XFilter(SamPtsonBnd,201); %% smooth boundaries
        for j=TremoveSamPts:size(SamPtsonBnd,1)-TremoveSamPts
            % find the support base
            fitPar=polyfit(SamPtsonBnd_filter(j-TremoveSamPts+1:j+TremoveSamPts-1,2),...
                SamPtsonBnd_filter(j-TremoveSamPts+1:j+TremoveSamPts-1,1),1);
            % cal the perpendicular line of fit line
            P_fitPar(1)=tan(atan(fitPar(1))+pi/2);
            P_fitPar(2)=SamPtsonBnd(j,1)-P_fitPar(1)*SamPtsonBnd(j,2);
            
            x1=1:size(curMask,2);
            y1=polyval(P_fitPar,x1);
            
            ind2=find(y1<SamPtsonBnd(j,1));  %% assume 'BU'
            x=x1(ind2);y=y1(ind2);
            
            dis=sqrt((SamPtsonBnd(j,2)-x).^2+(SamPtsonBnd(j,1)-y).^2);
            ind=find(dis<thickness);  %% distance contraint  get a set of
            %points
            tempx=x(ind);tempy=y(ind);
            ind2=find(tempy>=1);
            LinePts1=[tempy(ind2)',tempx(ind2)'];
            LinePts=[LinePts;LinePts1];
            
            if j==TremoveSamPts   %% to process the left side
                [miny,ind]=min(tempy(ind2));
                temp=tempx(ind2);
                minx=temp(ind);
                tempy1=round(miny):1:SamPtsonBnd(j,1);   %% the vertical points
                tempx1=ones(length(tempy1),1)*StartPts(1,2);
                LinePts=[LinePts;[tempy1',tempx1]];
                
                tempx2=StartPts(1,2):1:minx;             %% the horizontal points
                tempy2=ones(length(tempx2),1)*miny;
                LinePts=[LinePts;[tempy2,tempx2']];
            end
            if j==size(SamPtsonBnd,1)-TremoveSamPts  %% to process the right side
                [miny,ind]=min(tempy(ind2));
                temp=tempx(ind2);
                minx=temp(ind);
                tempy1=round(miny):1:SamPtsonBnd(j,1);   %% the vertical points
                tempx1=ones(length(tempy1),1)*EndPts(1,2);
                LinePts=[LinePts;[tempy1',tempx1]];
                
                tempx2=minx:1:EndPts(1,2);             %% the horizontal points
                tempy2=ones(length(tempx2),1)*miny;
                LinePts=[LinePts;[tempy2,tempx2']];
            end
        end
        %          show(curMask);
        %          hold on,plot(SamPtsonBnd_filter(:,2),SamPtsonBnd_filter(:,1),'r.');
        %          hold on,plot(LinePts(:,2),LinePts(:,1),'g.');
        %          hold off;
        
        %%         strategy (i) based on linefitting
        %          p_fit=polyfit(LinePts(:,2),LinePts(:,1),2);
        %          x2=1:size(curMask,2);
        %          y2=polyval(p_fit,x2);
        %          y=1:size(curMask,1);
        %          r=[];c=[];
        %          for j=1:length(x2)
        %              ind=find(y>y2(j));
        %              r=[r;y(ind)'];
        %              c=[c;x2(j)*ones(length(ind),1)];
        %          end
        %          ind2=sub2ind(size(roi_mask),r,c);
        %          roi_mask(ind2)=1;
        
        %         %%         strategy (ii) based on convex hull
        %         Pstart(1,1)=LinePts(1,1);Pstart(1,2)=StartPts(1,2);
        %         Pend(1,1)=LinePts(end,1);Pend(1,2)=EndPts(1,2);
        %
        %         fLinePts=[Pstart;LinePts;Pend];
        %         ind=sub2ind(size(roi_mask),round(fLinePts(:,1)),round(fLinePts(:,2)));
        %         curMask(ind)=1;
        %         roi_mask=bwconvhull(curMask);
        
        %% strategy (ii) based on closeing
        ind=sub2ind(size(roi_mask),round(LinePts(:,1)),round(LinePts(:,2)));
        curMask(ind)=1;
        curMask=imclose(curMask,strel('disk',30));   %% structuring element is empirically selected
        curMask=imfill(curMask,'holes');
        curMask=bwareaopen(curMask,100);
        
    end
    roi_mask=roi_mask|curMask;
end

end