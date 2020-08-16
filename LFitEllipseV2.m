%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is for fitting the ellipse for the given data


% X: m-by-2 matrix defined the location of the points
% STD: standard deriation control the scale of the ellipse,[1.5]
% VV:  major and minor axis vector at VV(:,1) and VV(:,2), respectively

% example:
 %   see FitDatawithEllipse.m

% (c) Edited by Cheng Lu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  19th Jan, 2011
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [EllipsePtsSet,VV,Mu]=LFitEllipseV2(X,STD)

%# substract mean
    Mu = mean( X );
    X0 = bsxfun(@minus, X, Mu);

    %# eigen decomposition [sorted by eigen values
    % If you want the ellipse to represent a specific level of standard
    %deviation, the correct way of doing is by scaling the covariance matrix
    if nargin<2
        STD = 1.5;
    end
    %# 2 standard deviations
    conf = 2*normcdf(STD)-1;
    %# covers around 95% of population
    scale = chi2inv(conf,2);
    %# inverse chi-squared with dof=#dimensions
    Cov = cov(X0) * scale;
    [V,D] = eig(Cov);
    [D,order] = sort(diag(D), 'descend');
    D=diag(D);
    V=V(:,order);

    t=linspace(0,2*pi,200);
    e = [cos(t) ; sin(t)];        %# unit circle
    VV = V*sqrt(D);               %# scale eigenvectors
    EllipsePtsSet = bsxfun(@plus, VV*e, Mu'); %#' project circle back to orig space
%     VVe=VV*e;
end