%%----------nuclei segmentation--------%%
% Ncs: Nuclei seeds
% cNIs: isolated nuclei seeds
% dNuSeg: images with isolated nuclei segmentations
%%----------output----------------------%%
% Rd0: regional features
% St0: statistical features
% nucleiCens: nulei centroids


function [Rd0,St0,nucleiCens,dNuSeg]=md_nucleiSegmentation(drIMTiles,Ncs,cNIs,dNuSeg)

Rd0=[];
St0=[];
nucleiCens=cell(1,length(Ncs));
ss2=7:1:11; %% radial ranges
tt=40;  %% croped image size
for k=1:length(Ncs)
    overlay1=dNuSeg{k};
    
    drTile=drIMTiles{k};
    nctemp=cNIs{k};
    cstemp=Ncs{k};
    ind1=find(cstemp(:,1)<3 | (size(drTile,1)-cstemp(:,1))<3);
    if ~isempty(ind1)
        cstemp(ind1,:)=[];
    end
    ind1=find(cstemp(:,2)<3 | (size(drTile,2)-cstemp(:,2))<3);
    if ~isempty(ind1)
        cstemp(ind1,:)=[];
    end
    rs5=cstemp(:,1);cs5=cstemp(:,2);
    
    
    sig=2;
    R1 = imfilter(double(drTile),fspecial('Gaussian',[2*round(2*sig)+1 2*round(2*sig)+1],sig),'same','conv','replicate');
    
    for nn=1:length(rs5)
        
        cx=cs5(nn);cy=rs5(nn);
        %% speed up
        if cy-tt<1
            rs=1;cy2=cy;
        else
            rs=cy-tt;cy2=tt+1;
        end
        if cy+tt>size(drTile,1)
            re=size(drTile,1);
        else
            re=cy+tt;
        end
        
        if cx-tt<1
            cs=1;cx2=cx;
        else
            cs=cx-tt;cx2=tt+1;
        end
        if cx+tt>size(drTile,2)
            ce=size(drTile,2);
        else
            ce=cx+tt;
        end
        
        Rtemp=R1(rs:re,cs:ce);
        [bw,~]=md_snakeDP(double(Rtemp),cx2,cy2,ss2);
        bw2=false(size(drTile));
        bw2(rs:re,cs:ce)=bw;
        bw2=imclose(logical(bw2),strel('disk',1));
        blm=bwperim(bw2);
        overlay1=imoverlay(overlay1,blm,[1 0 0]);
        
        if sum(bw2(:))>0
            %%(i) regional descriptors
            Rd=regionprops(bw2,'Area','Eccentricity','MajorAxisLength','MinorAxisLength','Perimeter','EquivDiameter');
%             per=Rd.Perimeter;
%             area=Rd.Area;
%             pr=per/(sqrt(area));              % perimeter ratio to measure boundary irregularities
%             Rd.Pratio=pr;
            Rdt.Area=Rd.Area;
            Rdt.Eccentricity=Rd.Eccentricity;
            Rdt.Perimeter=Rd.Perimeter;
            Rdt.EquivDiameter=Rd.EquivDiameter;
            Rdt.AxisRatio=Rd.MajorAxisLength/Rd.MinorAxisLength;
            Rd0=[Rd0;Rdt];
            
            %%(ii) statistical texture features
            %             % average intensity, average contrast,smoothness, third moment, uniformity,
            %             % and entropy
            tm=drTile(bw2);     %% original red channel
            St=statxture(tm);
            St0=[St0,St'];
            
            %% (iii) graph features
            curCC=regionprops(bw2,'centroid');
            nctemp=[nctemp;curCC.Centroid];
        end
    end
    nucleiCens{k}=nctemp;
    dNuSeg{k}=overlay1;
end
