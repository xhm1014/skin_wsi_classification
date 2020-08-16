%% cal the Voronoi Diagram statistics/features
%%% x,y are all column vectors
function Features=LFeatures_VoronoiDiagram(x,y,dMask)

%% Calculate and plot triangulation
[v,c]=voronoin([x,y]);
idx=1;
p=[];
A=[];

% [vx,vy]=voronoi(x,y);    %% for drawing features
% hold on,plot(x,y,'r.','MarkerSize',10)
% hold on,plot(vx,vy,'y-','LineWidth',1.5)
%figure,imshow(dMask);
for i = 1:length(c)
    if all(c{i}~=1)   % cal for all the bounded cells only
        %       curV=[];
        curVshift=[];
        % First, get co-ordinates
        curV=v(c{i},:);
        tempr=curV(:,2);
        tempc=curV(:,1);
        if all(tempr>0.5&tempr<size(dMask,1)-0.5&tempc>0.5&tempc<size(dMask,2)-0.5)
            pathXY=curV;
            pathXY(size(curV,1)+1,:)=curV(1,:);
            stepLengths=sqrt(sum(diff(pathXY,[],1).^2,2));
            stepLengths=[0;stepLengths];
            cumulativeLen=cumsum(stepLengths);
            finalStepLocs=linspace(0,cumulativeLen(end),round(max(stepLengths)));
            finalPathXY=interp1(cumulativeLen,pathXY,finalStepLocs);
            interV=unique(round(finalPathXY),'rows');
            ind=sub2ind(size(dMask),round(interV(:,2)),round(interV(:,1)));
            bw=false(size(dMask));
            bw(ind)=1;
            %        bw=roipoly(dMask,curV(:,1),curV(:,2));
            if sum(sum(bw&(~dMask)))<20
%                 curV2=curV;curV2(end+1,:)=curV(1,:);   %% for drawing
%                 features
%                 for kkk=1:length(curV2)-1
%                     hold on,line([curV2(kkk,1),curV2(kkk+1,1)],[curV2(kkk,2),curV2(kkk+1,2)],'Color','b','LineWidth',1.5);
%                 end
                
                % Then, get lengths of polygon sides
                curVshift(1:size(curV,1)-1,:)=curV(2:end,:);
                curVshift(size(curV,1),:)=curV(1,:);
                
                sideLengths=sqrt( sum( (curVshift-curV).^2,2 ) );
                
                % Now get meta-statistics
                p(idx) = sum(sideLengths);                   % Perimeter
                %         curV=flipud(curV);
                %         curVshift=flipud(curVshift);
                A(idx) = abs(.5*sum(curVshift(:,1).*curV(:,2)-curVshift(:,2).*curV(:,1))); % Area
                idx=idx+1;
            end
        end
    end
end
Features.Perimeter=p;
Features.Area=A;