%% to statistical features of texture
% wirtten by Hongming Xu
function tex=md_mstatxture(g,b)
% g: a single color channel image
% b: binary image
% tex: 6xn maxtrix each column corresponds to the six texture featrues

blabel=bwlabel(b);
tex=zeros(6,max(max(blabel)));
for i=1:max(max(blabel))
    tm=g(blabel==i);
    tex(:,i)=statxture(tm);
end
%tex=mean(tex,2);
end