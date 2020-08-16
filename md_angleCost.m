function [ac]=md_angleCost(iIx,iIy,theta)
angle=atan2(iIy,iIx);
ind=find(angle<0);
angle(ind)=2*pi+angle(ind);  %% change from [-pi pi] to [0 2*pi]
theta2=repmat(theta',[1,size(angle,2)]);
ac=cos(abs(angle-theta2));
%ac(ac<0)=-10;
end