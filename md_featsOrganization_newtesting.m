%---annotation---%
% The main function for organizing features from skin images
% University of Alberta
% Hongming Xu
%---end---%

function md_featsOrganization_newtesting
clear all; clc;
cd C:\Users\mxu\Dropbox\Public\Classification_Project\features

%% non-Melanoma
load('non-melanoma.mat');   %%163
ObjectsFeatures_testing=[];

for i=1:size(AllFeatures,2)
    Features=[];
    for j=1:size(AllFeatures,1)
        temp0=AllFeatures{j,i};
        temp1=struct2cell(temp0);
        temp2=cell2mat(temp1);
        temp2=reshape(temp2,[1 numel(temp2)]);
        Features=[Features,temp2];
    end
    ObjectsFeatures_testing(i,:)=Features;
end
FIdx=size(ObjectsFeatures_testing,1);
CasePoolIdx{1}=[1:FIdx];
lastIdx=FIdx+1;

% %% Nevus
% load('nevus.mat');%%65
% for i=1:size(AllFeatures,2)
%     Features=[];
%     for j=1:size(AllFeatures,1)
%         temp0=AllFeatures{j,i};
%         temp1=struct2cell(temp0);
%         temp2=cell2mat(temp1);
%         temp2=reshape(temp2,[1 numel(temp2)]);
%         Features=[Features,temp2];
%     end
%     ObjectsFeatures0(FIdx+i,:)=Features;
% end
% FIdx=size(ObjectsFeatures0,1);
% %CasePoolIdx{2}=[lastIdx:FIdx];
% pool1=[lastIdx:FIdx];
% lastIdx=FIdx+1;

% %% Normal
% load('normal.mat');  %%146
% for i=1:size(AllFeatures,2)
%     Features=[];
%     for j=1:size(AllFeatures,1)
%         temp0=AllFeatures{j,i};
%         temp1=struct2cell(temp0);
%         temp2=cell2mat(temp1);
%         temp2=reshape(temp2,[1 numel(temp2)]);
%         Features=[Features,temp2];
%     end
%     ObjectsFeatures0(FIdx+i,:)=Features;
% end
% FIdx=size(ObjectsFeatures0,1);
% %CasePoolIdx{3}=[lastIdx:FIdx];
% pool2=[lastIdx:FIdx];
%CasePoolIdx{2}=[pool1,pool2];

ObjectsFeatures_testing(:,19:28)=[];   %% to remov melanocytes morphological features
ObjectsFeatures_testing(:,1:8)=[];     %% remove nuclei DV features

save('ObjectsFeatures_newtesting.mat','ObjectsFeatures_testing','CasePoolIdx');
end