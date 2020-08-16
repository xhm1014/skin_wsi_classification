function [GC_x,GC_y]=md_gradientMap(im,bw_allNuclei,GradienMapTpye,shown)
%% supress the weak and noisy gradient by gaussian bluring
if strcmp(GradienMapTpye,'GaussianBlur')
    %     disp(' Compute edge map ...');
    f = double(im)/255;
    f0 = gaussianBlur(f,1);
    %     disp(' Comute the traditional external force ...');
    [px,py] = gradient(f0);
    %%% make the border gradient to be zeros
    px([1:2, end-1:end],:)=0;py([1:2, end-1:end],:)=0;
    px(:,[1:2, end-1:end])=0;py(:,[1:2, end-1:end])=0;
    
    %%% supress the weak gradient
    G_mag=sqrt(px.^2+ py.^2);
    % TGMag=mean(G_mag(:));   %max(G_mag(:));%figure(23);hist(G_mag,50);
    %       allMag=G_mag(:);allMag(find(allMag>150/255))=[];
    %       allMag(find(allMag<10/255))=[];
    %% !!!! important thrshold for  supressing the weak gradient
    temp=G_mag(bw_allNuclei==1);  %% added by Hongming Xu
    TGMag=mean(temp);
    
%    TGMag=mean(G_mag(:)); % comment by Hongming Xu 
    ValidGM=G_mag>=TGMag;
    px(~ValidGM)=0;   py(~ValidGM)=0;
    if shown
        % display the results
        figure(2);imshow(im,'InitialMagnification','fit');hold on;
        quiver(px,py,'y');
        hold off;
    end
    
    % changed gradient map
    GC_y=py; GC_x=px;
end

%% supress the weak gradient, need better method here
if strcmp(GradienMapTpye,'Threshold')
    [G_x,G_y]=gradient(double(im));
    G_mag=sqrt(G_x.^2+ G_y.^2);
    % TGMag=mean(G_mag(:));   %max(G_mag(:));%figure(23);hist(G_mag,50);
    allMag=G_mag(:);allMag(allMag>150)=[];
    allMag(allMag<10)=[];
    %% !!!! important thrshold for  supressing the weak gradient
    TGMag=mean(allMag)/3;
    
    %figure(23);hist(allMag,50);
    % TGMag=graythresh(allMag)*255;
    ValidGM=G_mag>=TGMag;
    
    G_x4shown=G_x;G_y4shown=G_y;
    G_x4shown(~ValidGM)=0;G_y4shown(~ValidGM)=0;
    
    if shown
        figure(1);imshow(im,'InitialMagnification','fit');hold on;
        quiver(G_x4shown,G_y4shown,'y');
        hold off;
    end
    
    
    % changed gradient map
    GC_y=G_y4shown; GC_x=G_x4shown;
end
end