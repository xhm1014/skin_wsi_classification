% kind of preprocessing, make the image homogenous
% using hibrid morphological reconstruction
% Example plz refer to LTestPrecessing_2011Apri20.m
%% Author Cheng lu
function RC_homo=LmakeHomoonRC(RC,maskConfLHR,strSize)

if ~exist('strSize','var')
    strSize=4;
end
if ~exist('maskConfLHR','var') || isempty(maskConfLHR)
    maskConfLHR=ones(size(RC));
end

% complement of R channel
RCc = imcomplement(RC); 
RCc(~maskConfLHR)=0;
% show(RCc,1);

% opening by reconstruction
se=strel('disk',strSize);
RCce=imerode(RCc,se);
% show(RCce,2);
RCceobr=imreconstruct(RCce,RCc);
% show(RCceobr,3);

% closing by reconstruction
RCceobrc=imcomplement(RCceobr);
RCceobrce=imerode(RCceobrc,se);
RCceobrcbr=imcomplement(imreconstruct(RCceobrce,RCceobrc));
% show(RCceobrcbr,4);

% back to original
RC_homo= imcomplement(RCceobrcbr); 
RC_homo(~maskConfLHR)=0;
% show(RC_homo,5);
% show(RC,6);
end