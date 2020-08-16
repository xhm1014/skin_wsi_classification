%% cal the Delaunay triangle statistics/features
%%% x,y are all column vectors
function Features=LFeatures_DelaunayTriangle(x,y,dMask)

%% Calculate and plot triangulation
TRI = delaunay(x,y);
nt = numel(TRI)/3;
% triplot(TRI,x,y);
p=[];A=[];
%TRI2=[];
%% Get triangle areas and perimeters
for i = 1:nt
    % First, get co-ordinates
    c1 = [x(TRI(i,1)) y(TRI(i,1))];
    c2 = [x(TRI(i,2)) y(TRI(i,2))];
    c3 = [x(TRI(i,3)) y(TRI(i,3))];
    
    tempr=[c1(2);c2(2);c3(2)];
    tempc=[c1(1);c2(1);c3(1)];
    if all(tempr>0.5&tempr<size(dMask,1)-0.5&tempc>0.5&tempc<size(dMask,2)-0.5)
        pathXY=[tempc,tempr];
        pathXY(length(tempr)+1,:)=[tempc(1),tempr(1)];
        stepLengths=sqrt(sum(diff(pathXY,[],1).^2,2));
        stepLengths=[0;stepLengths];
        cumulativeLen=cumsum(stepLengths);
        finalStepLocs=linspace(0,cumulativeLen(end),round(max(stepLengths)));
        finalPathXY=interp1(cumulativeLen,pathXY,finalStepLocs);
        interV=unique(round(finalPathXY),'rows');
        ind=sub2ind(size(dMask),round(interV(:,2)),round(interV(:,1)));
        bw=false(size(dMask));
        bw(ind)=1;
        
        %    bw=roipoly(dMask,[c1(1),c2(1),c3(1)],[c1(2),c2(2),c3(2)]);
        if sum(sum(bw&(~dMask)))<20
            % Then, get lengths of triangle sides
            v1 = sqrt( sum( (c1-c2).^2 ) );
            v2 = sqrt( sum( (c2-c3).^2 ) );
            v3 = sqrt( sum( (c3-c1).^2 ) );
            %     % Now get meta-statistics
            pt = v1 + v2 + v3;                   % Perimeter
            s = pt/2;                            % Semi-perimeter
            At = sqrt( s*(s-v1)*(s-v2)*(s-v3) ); % Area (Heron's formula)
            p=[p,pt];
            A=[A,At];
 %                   TRI2=[TRI2;TRI(i,:)];
        end
    end
    
    %     % Now get meta-statistics
    %     p(i) = v1 + v2 + v3;                   % Perimeter
    %     s = p(i)/2;                            % Semi-perimeter
    %     A(i) = sqrt( s*(s-v1)*(s-v2)*(s-v3) ); % Area (Heron's formula)
    
end

Features.Perimeter=p;
Features.Area=A;