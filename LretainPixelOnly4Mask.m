% keep the ROI(mask indicated) you want in an imag IM, other pixels will be zeros
% we hightlight the ROI
%   -IM: the whole image
%   -bwmask: binary mask which indicates the ROI
%  Output
%   - IM:  the image whic keep the ROI indicated by mask , other pixels will be zeros
function IM=LretainPixelOnly4Mask(IM,bwmask)
sizeIM=size(IM);
sizebwmask=size(bwmask);

% if sizeIM(1)~=sizebwmask(1) && sizeIM(2)~=sizebwmask(2)
%     disp('Cheng warning: image and mask must be the same size!');
%     bwmask= imresize(bwmask, [sizeIM(1) sizeIM(2)]);
% end

if sizeIM(1)>sizebwmask(1) && sizeIM(2)>sizebwmask(2)
    disp('Cheng warning: image size is > mask size, I change to the same size!');
    bwmask(sizebwmask(1)+1:sizeIM(1),sizebwmask(2)+1:sizeIM(2))=0;
end

% bwmask3=zeros(sizeIM);
% bwmask3=logical(bwmask3);
if length(sizeIM)==3
    bwmask3=cat(3,bwmask,bwmask,bwmask);
    % for i=1:3
    %     bwmask3(:,:,i)=bwmask;
    % end
    IM(~bwmask3)=0;
end

if length(sizeIM)==2
    IM(~bwmask)=0;
end

%
% IM_R=IM(:,:,1);
% IM_G=IM(:,:,2);
% IM_B=IM(:,:,3);
%
% IM_R(~bwmask)=0;
% IM_G(~bwmask)=0;
% IM_B(~bwmask)=0;
%
% IMwithOnlyROI(:,:,1)=IM_R;
% IMwithOnlyROI(:,:,2)=IM_G;
% IMwithOnlyROI(:,:,3)=IM_B;
% IMwithOnlyROI=IM;
end
