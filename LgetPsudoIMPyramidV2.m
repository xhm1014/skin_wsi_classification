%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used for generate the psudo Im. Pyramid,
% i.e. only have the original and corsest level specified by user
%, by build-in matlab func.

%  input:
%   -oriIM: original image;
%   -Totallevels: as it named 
%   -SpecifiedLevels: one number specify the level you want 
%  output:
%   -IMPyramid: IM. Pyramid
%   -IMsizes: image sizes in each level

% e.g.:
%   I=imread('pout.tif');
%   [IMPyramid,IMsizes]=LgetPsudoIMPyramidV2(I,5,3)

% (c) Edited by Cheng Lu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  9th Jan, 2011
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [IMPyramid,IMsizes]=LgetPsudoIMPyramidV2(oriIM,Totallevels,SpecifiedLevels)
sizeI=size(oriIM);
OriIMsizes=sizeI(1:2);

% should have the coarsest level and original image
numrows=round(OriIMsizes(1)/(2^(Totallevels-1)));
numcols=round(OriIMsizes(2)/(2^(Totallevels-1)));

LRIM = imresize(oriIM, [numrows numcols]);
IMPyramid(Totallevels).im=LRIM;
IMsizes(Totallevels,:)=[numrows numcols];
IMPyramid(1).im = oriIM;
IMsizes(1,:)=OriIMsizes;
%% build other image for Psudopyramids

for i = 2:Totallevels-1
    if i~=SpecifiedLevels
        IMPyramid(i).im = [];
        IMsizes(i,:)=[0 0];
    else
        numrows=round(OriIMsizes(1)/(2^(i-1)));
        numcols=round(OriIMsizes(2)/(2^(i-1)));
        IMPyramid(i).im= imresize(oriIM, [numrows numcols]);
        IMsizes(i,:)=[numrows numcols];
    end
end

end