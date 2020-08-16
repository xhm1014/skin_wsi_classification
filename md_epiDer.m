function [eIMTiles,eTiles]=md_epiDer(IMTiles,efmTiles,isnorm)
%eIMTiles=cell(1,length(IMTiles));
%eTiles=cell(1,length(IMTiles));
idx=1;
for k=1:length(IMTiles)
    temp=IMTiles{k};
    [r,c]=find(efmTiles{k});
    rmin=min(r);rmax=max(r);
    cmin=min(c);cmax=max(c);
    if rmax+5>size(efmTiles{k},1)
        rr2=size(efmTiles{k},1);
    else
        rr2=rmax+5;
    end
    if rmin-5<1
        rr1=1;
    else
        rr1=rmin-5;
    end
    if cmax+5>size(efmTiles{k},2)
        cc2=size(efmTiles{k},2);
    else
        cc2=cmax+5;
    end
    if cmin-5<1
        cc1=1;
    else
        cc1=cmin-5;
    end
    
    if cc2-cc1>300
        tempe=efmTiles{k};
        epiMask=tempe(rr1:rr2,cc1:cc2);
        temp2=temp(rr1:rr2,cc1:cc2,:);
        if isnorm
            temp2=md_normalizeStaining(temp2);
        end
        bwe=cat(3,epiMask,epiMask,epiMask);
        temp2(~bwe)=0;
        eIMTiles{idx}=temp2;
        eTiles{idx}=epiMask;
        idx=idx+1;
    end
    
end
end