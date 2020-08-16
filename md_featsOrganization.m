%---annotation---%
% The main function for organizing features from skin images
% University of Alberta
% Hongming Xu
%---end---%

function md_featsOrganization
clear all; clc;
cd C:\Users\mxu\Dropbox\Public\Classification_Project\features
tic
%% Melanoma
load('melanoma.mat');   %%163
ObjectsFeatures=[];
FeatureNames=[];
for i=1:size(AllFeatures,2)
    Features=[];
    for j=1:size(AllFeatures,1)
        temp0=AllFeatures{j,i}; 
        
        if j==5
            names=cell(24,1);
            names{1}='contr0';names{2}='contr45';names{3}='contr90';names{4}='contr135';
            names{5}='corrp0';names{6}='corrp45';names{7}='corrp90';names{8}='corrp135';
            names{9}='dissi0';names{10}='dissi45';names{11}='dissi90';names{12}='dissi135';
            names{13}='energ0';names{14}='energ45';names{15}='energ90';names{16}='energ135';
            names{17}='entro0';names{18}='entro45';names{19}='entro90';names{20}='entro135';
            names{21}='homom0';names{22}='homo45';names{23}='homo90';names{24}='homo135';
        else
            names=fieldnames(temp0);
        end
        FeatureNames=[FeatureNames;names];
        % scaling to unit length
        %     for j=1:size(A,1)
        %         temp2=A(j,:)/norm(A(j,:));
        %     end
        % simpplest rescaling
%        An=rescaling(temp);

       temp1=struct2cell(temp0);
       temp2=cell2mat(temp1);
       temp2=reshape(temp2,[1 numel(temp2)]);
       Features=[Features,temp2];
    end
    ObjectsFeatures(i,:)=Features;
end
FIdx=size(ObjectsFeatures,1);
CasePoolIdx{1}=[1:FIdx];
lastIdx=FIdx+1;

%% Nevus
load('nevus.mat');%%65
for i=1:size(AllFeatures,2)
    Features=[];
    for j=1:size(AllFeatures,1)
        temp0=AllFeatures{j,i}; 
        
        % scaling to unit length
        %     for j=1:size(A,1)
        %         temp2=A(j,:)/norm(A(j,:));
        %     end
        % simpplest rescaling
%        An=rescaling(temp);

        temp1=struct2cell(temp0);
        temp2=cell2mat(temp1);
        temp2=reshape(temp2,[1 numel(temp2)]);
        Features=[Features,temp2];
    end
    ObjectsFeatures(FIdx+i,:)=Features;
end
FIdx=size(ObjectsFeatures,1);
CasePoolIdx{2}=[lastIdx:FIdx];
lastIdx=FIdx+1;

%% Normal
load('normal.mat');  %%146
for i=1:size(AllFeatures,2)
    Features=[];
    for j=1:size(AllFeatures,1)
        temp0=AllFeatures{j,i}; 
        
        % scaling to unit length
        %     for j=1:size(A,1)
        %         temp2=A(j,:)/norm(A(j,:));
        %     end
        % simpplest rescaling
%        An=rescaling(temp);
        temp1=struct2cell(temp0);
        temp2=cell2mat(temp1);
        temp2=reshape(temp2,[1 numel(temp2)]);
        Features=[Features,temp2];
    end
    ObjectsFeatures(FIdx+i,:)=Features;
end
FIdx=size(ObjectsFeatures,1);
CasePoolIdx{3}=[lastIdx:FIdx];

ObjectsFeatures(:,19:28)=[];   %% to remov melanocytes morphological features
ObjectsFeatures(:,1:8)=[];     %% remove nuclei DV features
toc
save('ObjectsFeatures.mat','ObjectsFeatures','CasePoolIdx');
end