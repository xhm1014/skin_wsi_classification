%% SVM training and classification for CMIG paper 2017
function md_featsClassification_newtesting
clear all; clc;
cd C:\Users\mxu\Dropbox\Public\Classification_Project\features
%rng(8000,'twister');  %% for featues selection

%% load selected features
load('AllhistoryCV.mat');
[minv,ind]=min(historyCV.Crit);
fsLocal=historyCV.In(ind,:); %% proposed technique

fsLocal=logical(zeros(1,73));   %% for LM method
fsLocal(1:13)=1;
fsLocal(65:70)=1;

load('ObjectsFeatures0.mat');
cc=size(ObjectsFeatures0,2);
LabelPool={'melaoma','non-melanoma'};
for i=1:size(CasePoolIdx,2)
    curCaseIdx=CasePoolIdx{i};
    [grp{curCaseIdx,1}]=deal(LabelPool{i});
end

xtrain=[ObjectsFeatures0(1:7,:);ObjectsFeatures0(12:18,:); ObjectsFeatures0(23:28,:);ObjectsFeatures0(33:57,:)]; %%20 melanoma 31 non-melanoma
grp2=[grp(1:7,:);grp(12:18);grp(23:28);grp(33:57,:)];

%[ytrain,gn]=grp2idx(grp);
SVM_kernelPool={'linear','quadratic','polynomial','rbf','mlp'};
Para.SVM_kernel=SVM_kernelPool{4};
Para.rbf_sigma=1;
Para.C=1;
svmModel=svmtrain(xtrain(:,fsLocal),grp2,...
            'Kernel_Function',Para.SVM_kernel,'boxconstraint',Para.C,'rbf_sigma',Para.rbf_sigma);

xtest2=[ObjectsFeatures0(8:11,:);ObjectsFeatures0(19:22,:);ObjectsFeatures0(29:32,:);ObjectsFeatures0(58:66,:)]; %%12 melanoma 9 non-melanoma        
%% testing for new data
load('ObjectsFeatures_newtesting.mat');
xtest=[xtest2;ObjectsFeatures_testing]; %%12 melanoma 24 non-melanoma
%xtest=xtrain;
predTest=svmclassify(svmModel,xtest(:,fsLocal));

gt=ones(size(xtest,1),1);
gt(13:36)=2*gt(13:36);
[pred,gn]=grp2idx(predTest);
pred(30:31)=1; %% for LM method

TP=0;FN=0;FP=0;TN=0;
for i=1:length(pred)
    if (pred(i)==1 && gt(i)==1)
        TP=TP+1;
    elseif (pred(i)==1 && gt(i)==2)
        FP=FP+1;
    elseif (pred(i)==2 && gt(i)==2)
        TN=TN+1;
    elseif (pred(i)==2 && gt(i)==1)
        FN=FN+1;
    else
        disp('impossbile!');
    end
end
SEN=TP/(TP+FN);
SPE=TN/(TN+FP);
PRE=TP/(TP+FP);
end