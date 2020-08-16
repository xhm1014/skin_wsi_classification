
%% return fitting residuals
function [efr]=md_ellipseFittingResidual(bw)
cc = bwconncomp(bw);
stats = regionprops(cc,'Centroid','Orientation','MajorAxisLength','MinorAxisLength');
phi=linspace(0,2*pi,50);
cosphi = cos(phi);
sinphi = sin(phi);

xbar = stats.Centroid(1);
ybar = stats.Centroid(2);

%    hold on,plot(xbar,ybar,'g*');

a = stats.MajorAxisLength/2;
b = stats.MinorAxisLength/2;

theta = pi*stats.Orientation/180; %% Orientation ranging from -90 to 90 degrees
R = [ cos(theta)   sin(theta);  %% counterclockwise roatation if theta is positive
    -sin(theta)   cos(theta)];  %% clockwise rotation if theta is negative

xy = [a*cosphi; b*sinphi];
xy = R*xy;

x = xy(1,:) + xbar;
y = xy(2,:) + ybar;

%hold on, plot(x,y,'r','LineWidth',2);

bwe=poly2mask(x,y,size(bw,1),size(bw,2));
efr=1-sum(sum(bwe&bw))/sum(bwe(:));

% %E=[x;y;ones(1,length(x))];
% %
% E=[x;y];
% 
% BW2=bwperim(bw);
% [r,c]=find(BW2);
% %N=[c';r';ones(1,length(c))];
% N=[c';r'];
% %[m,n]=size(bw);

% %% Affine transformation
% x0 = [xbar;ybar];
% S = diag([1,b/a]);
% C = R*S*R';
% %d = (eye(2) - C)*x0;
% 
% % temp = [C d;0 0 1]';
% % %temp2 = inv(temp);
% % S2 = [10/a 0 0;0 10/a 0;0 0 1];
% %C1 = [xbar;ybar;1];
% % %C1 = S2/temp*C1;
% % C1 = temp\C1;
% % % Im2 = S2/temp*E;
% % % Im0 = S2/temp*N;
% % Im2 = temp\E;
% % Im0 = temp\N;    
% S2=[10/a 0;0 10/a];
% Im2=S2/C*E+repmat((x0-S2/C*x0),1,size(E,2));
% Im0=S2/C*N+repmat((x0-S2/C*x0),1,size(N,2));
% 
% % Im2(1,:) = Im2(1,:)+(round(n/2)-C1(1,1));
% % Im2(2,:) = Im2(2,:)+(round(m/2)-C1(2,1));
% % Im0(1,:) = Im0(1,:)+(round(n/2)-C1(1,1));
% % Im0(2,:) = Im0(2,:)+(round(m/2)-C1(2,1));
% 
% % Xi = [Im0(1,:)' Im0(2,:)'];  %% first column: column values
% % Yi = [Im2(1,:)' Im2(2,:)'];
% 
% % DIS = sqrt(sum(abs(repmat(permute(Xi,[1 3 2]),[1 size(Yi,1) 1])...
% %         -repmat(permute(Yi,[3 1 2]),[size(Xi,1) 1 1])).^2,3));
% % efr=sum(min(DIS,[],2))/size(Xi,1);
% % hold on,plot(Yi(:,1),Yi(:,2),'g.')
% % hold on,plot(Xi(:,1),Xi(:,2),'y.')
% bwn=poly2mask(Im0(1,:),Im0(2,:),size(bw,1),size(bw,2));
% bwe=poly2mask(Im2(1,:),Im2(2,:),size(bw,1),size(bw,2));
% efr=1-sum(sum(bwe&bwn))/sum(bwe(:));