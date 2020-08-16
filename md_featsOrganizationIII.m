%---annotation---%
% The main function for organizing features from skin images
% University of Alberta
% Hongming Xu
%---end---%

function md_featsOrganizationIII %% test strategy II melanoma subtypes classification
clear all; clc;
cd C:\Users\Jorge\Dropbox\Public\Classification_Project\features

%% Melanoma
load('melanoma.mat');   %%163
ObjectsFeaturesIII=[];

%% lentigious melanoma
for i=1:9
    Features=[];
    for j=1:size(AllFeatures,1)
       temp0=AllFeatures{j,i}; 
       temp1=struct2cell(temp0);
       temp2=cell2mat(temp1);
       temp2=reshape(temp2,[1 numel(temp2)]);
       Features=[Features,temp2];
    end
    ObjectsFeaturesIII(i,:)=Features;
end
FIdx=size(ObjectsFeaturesIII,1);
CasePoolIdx{1}=[1:FIdx];
lastIdx=FIdx+1;

%% nodular melanoma
for i=lastIdx:14
    Features=[];
    for j=1:size(AllFeatures,1)
        temp0=AllFeatures{j,i}; 
        temp1=struct2cell(temp0);
        temp2=cell2mat(temp1);
        temp2=reshape(temp2,[1 numel(temp2)]);
        Features=[Features,temp2];
    end
    ObjectsFeaturesIII(i,:)=Features;
end
FIdx=size(ObjectsFeaturesIII,1);
CasePoolIdx{2}=[lastIdx:FIdx];
lastIdx=FIdx+1;

%% superficial spreading melanoma
for i=lastIdx:size(AllFeatures,2)
    Features=[];
    for j=1:size(AllFeatures,1)
        temp0=AllFeatures{j,i}; 
        temp1=struct2cell(temp0);
        temp2=cell2mat(temp1);
        temp2=reshape(temp2,[1 numel(temp2)]);
        Features=[Features,temp2];
    end
    ObjectsFeaturesIII(i,:)=Features;
end
FIdx=size(ObjectsFeaturesIII,1);
CasePoolIdx{3}=[lastIdx:FIdx];
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
    ObjectsFeaturesIII(FIdx+i,:)=Features;
end
FIdx=size(ObjectsFeaturesIII,1);
CasePoolIdx{4}=[lastIdx:FIdx];
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
    ObjectsFeaturesIII(FIdx+i,:)=Features;
end
FIdx=size(ObjectsFeaturesIII,1);
CasePoolIdx{5}=[lastIdx:FIdx];

ObjectsFeaturesIII(:,19:28)=[];   %% to remov melanocytes morphological features
ObjectsFeaturesIII(:,1:8)=[];     %% remove nuclei DV features
save('ObjectsFeaturesIII.mat','ObjectsFeaturesIII','CasePoolIdx');
end