% this function cal. the distance from given point, pt, to a line, where the
% line is modeled by parameters, LinePars
% LinePars is consist of first order parameter and zero order parameter by
% polyfit
% Pt is in the format of (x,y), can be a n-by-2 matrix
function distance=LPts2LineDistance(Pt,LinePars)
%  parameterize the line by Ax+By+C=0
% assign reverse sign to fix the reverse problem
A=-LinePars(1);
B=1;
C=-LinePars(2);
distance=(A.*Pt(:,1)+B.*Pt(:,2)+C)/sqrt(A^2+B^2);
end