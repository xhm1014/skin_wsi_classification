function IMTilesN=md_normalizeStaining(temp)
%IMTilesN=cell(1,length(IMTiles));
%for i=1:length(IMTiles)
%    temp=IMTiles{i};
    R=temp(:,:,1);G=temp(:,:,2);B=temp(:,:,3);
    J=R==0&G==0&B==0;
    R(J)=255;G(J)=255;B(J)=255;
    temp=reshape([R,G,B],size(temp));
%    [IMTilesN{i},~,~]=normalizeStaining(temp);
    IMTilesN=normalizeStaining(temp);
%end
end