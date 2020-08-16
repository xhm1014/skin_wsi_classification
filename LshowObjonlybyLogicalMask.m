% GivenMask : given a logical mask which is the same size of IM
% IM: original image

function ShownIM=LshowObjonlybyLogicalMask(GivenMask,IM,contrast,figNo)
CC= bwconncomp(GivenMask);
IndxList=[];

for i =1:CC.NumObjects  
          IndxList=[IndxList;CC.PixelIdxList{i}];
end
 if nargin<4
     ShownIM=LshowOnlyObj( IM,IndxList,contrast);
 else
     ShownIM=LshowOnlyObj( IM,IndxList,contrast,figNo);
end
 
