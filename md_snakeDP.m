function [bwff,mcost]=md_snakeDP(I,cx,cy,rmax)
%% modified by Hongming Xu
%%---paramters---%%
% indicator: 1, circular neighborhood; 2 ellliptical neighborhood
%%-- end ---%%


% Dynamic Programming Snake with GICOV Criterion
% N. Ray, S. Acton, H. Zhang, “Seeing through clutter: Snake computation
% with dynamic programming for particle segmentation,?ICPR 2012.
% Program writen by Nilanjan Ray
% Last modified on July 2012


%%%%%%%%%%%%%%%%%%%%%%%%% Parameter Setting %%%%%%%%%%%%%%%%%%%%%
% How many radial lines?
%N =70;
N=90; %for generating figures

% snake smoothness parameter
delta=1;

% Object brighter than surrounding? if yes set 1, else set 0
IsBrighter=0;

%bw=imdilate(bw,strel('disk',2));

bwtemp=zeros(size(I,1),size(I,2),length(rmax));
costM=zeros(length(rmax),3);
for i=1:length(rmax)
    rr=rmax(i);
    
    % search radius range
    search_rad = (3:0.5:rr)';
%    search_rad = (2:1:rr)';
%    search_rad = (6:1:rr)'; % for generating figures
    %%construct radial lines
    theta = linspace(0,2*pi,N+1);
    theta = theta(1:N);
    
    [R,T] = meshgrid(search_rad,theta);
    ix = R.*cos(T) + cx;
    iy = R.*sin(T) + cy;
    
    
    
 %   figure,imshow(I,[]);
 %    hold on, plot(cx,cy,'y+','MarkerSize',13,'LineWidth',2),hold off;
 %    hold on,plot(ix,iy,'r.');
    
   
    [sIx,sIy] = gradient(I);
    iIx = interp2(sIx,ix,iy,'*linear',0);
    iIy = interp2(sIy,ix,iy,'*linear',0);
    
    ac=md_angleCost(iIx,iIy,theta);
    
%     %% added by Hongming Xu
%     bwxy=interp2(bw,ix,iy,'nearst',0);
%     iIx(~bwxy)=0;
%     iIy(~bwxy)=0;
    
%     % directional gradient on radial lines
    if IsBrighter,
        g1 = -sqrt(iIx.*iIx+iIy.*iIy).*sign(iIx.*cos(T)+iIy.*sin(T));
    else
        g1 = sqrt(iIx.*iIx+iIy.*iIy).*sign(iIx.*cos(T)+iIy.*sin(T)); % directional gradient
    end
  
    gm=max(g1,[],2);
    gm(abs(gm)<0.001)=0.001;
    gmat=repmat(gm,[1,size(g1,2)]);
    g1=g1./gmat;
%    g1=g1./(max(max(abs(g1))));
    g=ac+2*g1;
%    g(g<mean(g(:)))=0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DP snake with max directional grad%%%%
    
    % call DP snake with maximum directional gradient criterion
    [ind,minv]=gicov_dyn_snake(max(g(:)),g,delta);
    X = ix(ind);
    Y = iy(ind);
    
    bwtemp(:,:,i)=poly2mask(X,Y,size(I,1),size(I,2));
    bwtemp(:,:,i)=bwareaopen(bwtemp(:,:,i),round(sum(sum(bwtemp(:,:,i)))/2)); %% to remove isolated pixels
%    figure,imshow(bwtemp(:,:,i));
%    figure,imshow(I,[]);
    efr=md_ellipseFittingResidual(bwtemp(:,:,i));
    
    pp=I(bwtemp(:,:,i)==1);
    costM(i,1)=minv; 
    costM(i,2)=var(pp)*(numel(pp)-1);
%    stats=regionprops(bwtemp(:,:,i),'Solidity');
%    costM(i,3)=1-stats.Solidity;
   costM(i,3)=efr;
%    hold on; plot([X; X(1)],[Y; Y(1)],'r');hold off; drawnow;%flush event queue and update the figure window
end
% maxM=max(costM);
% maxN=repmat(maxM,[size(costM,1),1]);
%costMN=costM./maxN;
maxM=sqrt(sum(abs(costM).^2,1));
maxN=repmat(maxM,[size(costM,1),1]);
costMN=costM./maxN;
fa=repmat([2 1 1],[size(costM,1),1]);
costMN=costMN.*fa;
costS=sum(costMN,2);
[mcost,ind3]=min(costS);   %% minimum energy
bwff=bwtemp(:,:,ind3);

function [ind,minv]=gicov_dyn_snake(gm,g,delta)
% dynamic programing for computing gicov (closed contour) snake
% most stable version - works in O(NM^2) time

[N,M] = size(g);

OldValues =  1e10*ones(M,M);
Indices = zeros(N-2,M,M);

% forward pass to build the value functions and indices
for i=1:M,
    for j=max(1,i-delta):min(M,i+delta),
        OldValues(i,j)=0;
    end
end
for n=1:N-2,
    Values = 1e10*ones(M,M);
    for i=1:M,
        for k=1:M,
            minv=1e10;minind=0;
            for j=max(1,k-delta):min(M,k+delta),
                thisv = OldValues(i,j) + abs(gm-g(n+1,j));  %% comment by
%                Hongming
%                 thisv = OldValues(i,j)-g(n+1,j);
                if minv>thisv,
                    minv=thisv;
                    minind=j;
                end
            end
            Values(i,k) = minv;
            Indices(n,i,k) = minind;
        end
    end
    clear OldValues;
    OldValues = Values;
    clear Values;
end

% backtrack
ind = zeros(N,1);
minv=1e10;
for i=1:M,
    for j=max(1,i-delta):min(M,i+delta),
        thisv = OldValues(i,j) + abs(gm-g(1,i)) + abs(gm-g(N,j)); %%
%        comment by Hongming
%        thisv = OldValues(i,j)-g(1,i)-g(N,j);
        if minv>thisv,
            minv=thisv;
            ind(1) = i;
            ind(N) = j;
        end
    end
end
for n=N-1:-1:2,
    ind(n) = Indices(n-1,ind(1),ind(n+1));
end
ind(:) = N*(ind-1) + (1:N)';
