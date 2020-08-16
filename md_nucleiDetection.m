%%----------------------%%
% Input
%    R: image channel (R,G,B, or Gray channel)
%    C_mask3: the foreground with nuclei regions as foreground
%    Para: Parameters setttings
% Output:
%    bs4: the binary image with nuclei centers as foreground
% Written by Hongming Xu
% ECE U of A
% feel free to use it
%%---------------------%%


function [cs]=md_nucleiDetection(R,C_mask3,Para)


R_hat=double(255-R);     %% assume the dark blobs
%R_hat=imfill(R_hat,'holes');
thetaStep=Para.thetaStep;          % thetaStep
largeSigma=Para.largeSigma;
smallSigma=Para.smallSigma;
sigmaStep=Para.sigmaStep;              % Sigma step
kerSize=Para.kerSize;         % Kernel size
bandwidth=Para.bandwidth;     % Mean-shift bandwidth

%% modified version with mean-shift clustering algorithm
[aggregated_response] = md_aggregate_gLoG_Filters(R_hat, largeSigma, smallSigma, sigmaStep,thetaStep, kerSize); %% summation with same direction

%bcur=zeros(size(R)); %% for generating figures
X=[;];
%Y=[];
for i=1:size(aggregated_response,3)
    aggregated_response1=aggregated_response(:,:,i);
    bt=imregionalmax(aggregated_response1);
%    bcur=bcur|bt;   %% for generating figures
    
    bt(~C_mask3)=0;
    [r,c]=find(bt);
    X=[X,[r';c']];
%    ind=sub2ind(size(R),r,c);
%    Y=[Y,aggregated_response1(ind)'];
    
%    hold on, plot(c,r,'r+','MarkerSize',8,'LineWidth',2); %% for debugging  
end

% [r,c]=find(bcur);
% X=[r';c'];

[~,~,clustMembsCell] = MeanShiftCluster(X,bandwidth);
clustMembsCell=clustMembsCell(~cellfun('isempty',clustMembsCell)); %% to remove empty cell arrays
% for i=1:length(clustMembsCell)
%     ind=clustMembsCell{i,1};
%     pp=X(:,ind);
%     hold on,plot(pp(2,:),pp(1,:),'y.');
% end

%hold on, plot(clustCent(2,:),clustCent(1,:),'gs');

cs=[];
for i=1:length(clustMembsCell)
    temp=clustMembsCell{i};
    pp=mean(X(:,temp),2);
    cs=[cs,round(pp)];
%     if sum(isnan(round(pp)))>0
%         check=0;
%     end
    %    hold on,plot(cs(2,:),cs(1,:),'g+'); 
end
cs=cs'; 
% % bcur=logical(zeros(size(R)));
% % ind=sub2ind(size(R),cs(1,:),cs(2,:));
% % bcur(ind)=1;

end