%% cal the distance with respect to the keratin layer
function AllDistance2Keratin=LAnalysisNucleiStasticInEpi(AllCentroidInIMTiles4Nuclei,AllPtsonBnd_Keratin)
for i=1:size(AllCentroidInIMTiles4Nuclei,2)
    curCentroids=AllCentroidInIMTiles4Nuclei{i};
    curPtsonKeratin=AllPtsonBnd_Keratin{i};
    if ~isempty(curCentroids)        
%         for j=1:size(curCentroids,1)
%             curC=curCentroids(j,:);
%             tempdiff=repmat(curC,size(curPtsonKeratin,1),1)-curPtsonKeratin;
%             temp=sqrt(sum(tempdiff.^2,2));
%             minVal=min(temp);
%             curNucleiDist2Keratin(j)=minVal;
%         end
        %% added by Hongming Xu
        D=pdist2(curCentroids,curPtsonKeratin);
        curNucleiDist2Keratin=min(D,[],2)';
        AllDistance2Keratin{i}=curNucleiDist2Keratin;
%        curNucleiDist2Keratin=[];
    else
        AllDistance2Keratin{i}=[];
%        curNucleiDist2Keratin=[];
    end    
end
