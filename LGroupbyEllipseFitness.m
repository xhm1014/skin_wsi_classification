% check if the components in the mask is well-fit in the fit-ellipse, if
% not, grouping the fit one and not fit one by TUnSolidfit
% similar function can refer to the
% LremoveUnSolidComponentsBaseonEllipseFit.m
function [maskObjs_refined,maskFake]=LGroupbyEllipseFitness(...
    maskObjs,flagtest,TUnSolidFit)
if nargin<2
    flagtest=0;
end

if ~exist('TUnSolidFit','var')
    TUnSolidFit=0.25;
end

sizeIM=size(maskObjs);
tempCC=bwconncomp(maskObjs,4);
%E=cell(1,tempCC.NumObjects);

maskFake=zeros(size(maskObjs));
maskObjs_refined=maskObjs;

TtooBigRegion=1000;

for i=1:tempCC.NumObjects
    curList=tempCC.PixelIdxList{i};
    % don't consider too big region
    if length(tempCC.PixelIdxList{i})<TtooBigRegion
        
        [x,y]=ind2sub(size(maskObjs),curList);
        % get in circle and out circles
        STD=1.5;
        [e]=LFitEllipseV2([x,y], STD);
        
        maskIC_fit=poly2mask(e(2,:),e(1,:),sizeIM(1),sizeIM(2));
        curListIC_fit=find(maskIC_fit==1);
        NumberofDiffbwFitandOri=numel(setxor(curList,curListIC_fit));
        
        curUnSolidFit=NumberofDiffbwFitandOri/numel(curList);
        
        if flagtest
            testMask=maskObjs; testMask(:)=false;
            testMask(curList)=true;
            LshowEllipse(testMask,testMask,104);
%            curUnSolidFit;
        end
        
        % do not consider this guy if it is not well-fit in the fit-ellipse
        if (curUnSolidFit)>TUnSolidFit
            maskObjs_refined(curList)=0;
            maskFake(curList)=1;
            if flagtest
                testMask=maskObjs; testMask(:)=false;
                testMask(curList)=true;
                LshowEllipse(testMask,testMask,104);
            end
        end
    else
        maskObjs_refined(curList)=0;
        maskFake(curList)=1;
    end
end

