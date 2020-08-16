%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function computes the Haralic features

% Input:
%         img: the color image
%
%         bw: the foreground region
%         c:  the image channel


% Output:
%   stats: the features

% (c) Edited by Hongming Xu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  Feb, 2016
% If you have any problem feel free to contact me.
% Please address questions or comments to: mxu@ualberta.ca

% Terms of use: You are free to copy,
% distribute, display, and use this work, under the following
% conditions. (1) You must give the original authors credit. (2) You may
% not use or redistribute this work for commercial purposes. (3) You may
% not alter, transform, or build upon this work. (4) For any reuse or
% distribution, you must make clear to others the license terms of this
% work. (5) Any of these conditions can be waived if you get permission
% from the authors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stats=md_haralickFeats(imgTiles,bwTiles)
nn=length(imgTiles);
GLCM2=zeros(8,8,4);
for i=1:nn
    I=imgTiles{i};
    bw=bwTiles{i};
    I=double(I);
    I(~bw)=NaN;
    warning('off', 'Images:graycomatrix:scaledImageContainsNan');              %% trun off the warning
    GLCM = graycomatrix(I,'GrayLimits',[0 255], 'Offset',[0 1;-1 1;-1 0;-1 -1]);
    GLCM2=GLCM+GLCM2;
    warning('on', 'Images:graycomatrix:scaledImageContainsNan');              %% trun on the warning
end
stats = GLCM_Haralick(GLCM2,0);
end
