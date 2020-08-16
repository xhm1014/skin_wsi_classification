%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% input
% maskfRoi--binary mask for rotation
% IMfRoi--color image for rotation

%% Output
% maskfRot--binary mask for rotation
% IMfRot--color image after rotation

% (c) Edited by Hongming Xu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  24th Feb, 2015
% If you have any problem feel free to contact me.
% Please address questions or comments to: mxu@ualberta.ca
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [maskfRot,IMfRot,efmRot,dfmRot]=md_rotImage(maskfRoi,IMfRoi,efMask,dfMask)

maskfRot=cell(1,length(maskfRoi));
IMfRot=cell(1,length(maskfRoi));
efmRot=cell(1,length(maskfRoi));
dfmRot=cell(1,length(maskfRoi));
for i=1:length(maskfRoi)
    temp=imresize(maskfRoi{i},0.25);  %% use low resolution for efficiency
    temp=bwareaopen(temp,round(sum(temp(:))/3));
    stats=regionprops(temp,'Orientation');
    maskfRot{i}=imrotate(maskfRoi{i},-stats.Orientation);
    IMfRot{i}=imrotate(IMfRoi{i},-stats.Orientation,'bilinear');
    efmRot{i}=imrotate(efMask{i},-stats.Orientation);
    dfmRot{i}=imrotate(dfMask{i},-stats.Orientation);
end
end