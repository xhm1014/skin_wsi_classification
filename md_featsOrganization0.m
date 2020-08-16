%---annotation---%
% The main function for organizing features from skin images
% University of Alberta
% Hongming Xu
%---end---%

function md_featsOrganization0
clear all; clc;
cd C:\Users\Jorge\Dropbox\Public\Classification_Project\features

%% Melanoma
load('melanoma.mat');   %%163
ObjectsFeatures0=[];

for i=1:size(AllFeatures,2)
    Features=[];
    for j=1:size(AllFeatures,1)
        temp0=AllFeatures{j,i};
        temp1=struct2cell(temp0);
        temp2=cell2mat(temp1);
        temp2=reshape(temp2,[1 numel(temp2)]);
        Features=[Features,temp2];
    end
    ObjectsFeatures0(i,:)=Features;
end
FIdx=size(ObjectsFeatures0,1);
CasePoolIdx{1}=[1:FIdx];
lastIdx=FIdx+1;

%% Nevus
load('nevus.mat');%%65
for i=1:size(AllFeatures,2)
    Features=[];
    for j=1:size(AllFeatures,1)
        temp0=AllFeatures{j,i};
        temp1=struct2cell(temp0);
        temp2=cell2mat(temp1);
        temp2=reshape(temp2,[1 numel(temp2)]);
        Features=[Features,temp2];
    end
    ObjectsFeatures0(FIdx+i,:)=Features;
end
FIdx=size(ObjectsFeatures0,1);
%CasePoolIdx{2}=[lastIdx:FIdx];
pool1=[lastIdx:FIdx];
lastIdx=FIdx+1;

%% Normal
load('normal.mat');  %%146
for i=1:size(AllFeatures,2)
    Features=[];
    for j=1:size(AllFeatures,1)
        temp0=AllFeatures{j,i};
        temp1=struct2cell(temp0);
        temp2=cell2mat(temp1);
        temp2=reshape(temp2,[1 numel(temp2)]);
        Features=[Features,temp2];
    end
    ObjectsFeatures0(FIdx+i,:)=Features;
end
FIdx=size(ObjectsFeatures0,1);
%CasePoolIdx{3}=[lastIdx:FIdx];
pool2=[lastIdx:FIdx];
CasePoolIdx{2}=[pool1,pool2];

ObjectsFeatures0(:,19:28)=[];   %% to remov melanocytes morphological features
ObjectsFeatures0(:,1:8)=[];     %% remove nuclei DV features

save('ObjectsFeatures0.mat','ObjectsFeatures0','CasePoolIdx');
end