% normalize the histogram , then sum(Hist)=1;
function hist=LNorHist(hist)
if sum(hist)~=1
    hist=hist/sum(hist);
end
end