function ev_showBound(img,mask,color,shown)
if ~exist('shown','var')
    shown=0;
end
if ~exist('color','var')
    color='g';
end
if shown
    show(img);
end
hold on,
B = bwboundaries(mask,8);
for i=1:length(B)
    curB=B{i};
    plot(curB(:,2),curB(:,1),color,'LineWidth',2);
end
hold off;

end