function MeanColorInEpi=LgetMeanColorInEpiArea(IM,maskConfLHR)
%GC=IM(:,:,2);
GC=IM;
Twhitecolor=210;
mask=GC<Twhitecolor&maskConfLHR;
MeanColorInEpi=mean(GC(mask));