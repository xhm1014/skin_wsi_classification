function md_featsClassificationV2
clear all; clc;
cd C:\Users\Jorge\Dropbox\Public\Classification_Project\features
%rng(8000,'twister');  %% for featues selection

load('ObjectsFeatures.mat');
%ObjectsFeatures=ObjectsFeatures(:,1:62);
cc=size(ObjectsFeatures,2);
LabelPool={'melaoma','nevus','normal'};
for i=1:size(CasePoolIdx,2)
    curCaseIdx=CasePoolIdx{i};
    [grp{curCaseIdx,1}]=deal(LabelPool{i});
end

% 
% temp=[];
% 
% holdoutCVP=cvpartition(grp,'holdout',0.3);
% dataTrain=ObjectsFeatures(holdoutCVP.training,:);
% grpTrain=grp(holdoutCVP.training);
% 
% dataTest=ObjectsFeatures(~holdoutCVP.training,:)
% grpTest=grp(~holdoutCVP.training);

CA0=[];CA1=[];CA2=[];CA3=[];
for i=1:100

% %# sequential feature selection
  tenfoldCVP=cvpartition(grp,'kfold',10);
  
% [fsCVfor50,historyCV] = sequentialfs(@MultiSVMClassf,ObjectsFeatures,grp,...
%     'cv',tenfoldCVP,'Nf',cc);
% plot(historyCV.Crit,'o');
% xlabel('Number of Features');
% ylabel('CV MCE');
% title('Forward Sequential Feature Selection with cross-validation');

% load('AllhistoryCV.mat');
% [minv,ind]=min(historyCV.Crit);
% fsLocal=historyCV.In(ind,:);
% 
% % load('fs.mat');
% % fsLocal=fs;
% testMCE=crossval(@MultiSVMClassif2,ObjectsFeatures(:,fsLocal),grp,'Partition',tenfoldCVP);   
% acc0=1-mean(testMCE);  %% based on selected features
% CA0=[CA0,acc0];

testMCE=crossval(@MultiSVMClassif2,ObjectsFeatures,grp,'Partition',tenfoldCVP);   
acc1=1-mean(testMCE);  %% use all features
CA1=[CA1,acc1];
% 
% testMCE=crossval(@MultiSVMClassif2,ObjectsFeatures(:,1:13),grp,'Partition',tenfoldCVP);   
% acc2=1-mean(testMCE);  %% use epidermis features
% CA2=[CA2,acc2];
% 
% testMCE=crossval(@MultiSVMClassif2,ObjectsFeatures(:,14:73),grp,'Partition',tenfoldCVP);   
% acc3=1-mean(testMCE);  %% use dermis features
% CA3=[CA3,acc3];
end
sfc=mean(CA0);
afc=mean(CA1);
efc=mean(CA2);
dfc=mean(CA3);
%fsLocal=sequentialfs(@MultiSVMClassf,dataTrain,grpTrain,'cv',tenfoldCVP);
%load('fsLocal.mat');
% % %# to evalue the performance on testing dataset
% testMCELocal=crossval(@MultiSVMClas sf,ObjectsFeatures(:,fsLocal),grp,'partition',...
%       holdoutCVP)/holdoutCVP.TestSize;   %% using selected features
% acct1=1-testMCELocal;
% 
% for i=1:75
% load('historyCV.mat');
% fsLocal=historyCV.In(i,:);
% testMCELocal=crossval(@MultiSVMClassf,dataTrain(:,fsLocal),grpTrain,'Partition',tenfoldCVP);   %% using selected features
% temp=[temp,mean(testMCELocal)];
 
% svmModel=MultiSVMModels(dataTrain(:,fsLocal),grpTrain);
% acc2=MultiSVMClassification(svmModel,dataTest(:,fsLocal),grpTest);
% % 
% acc3=MultiSVMClassification(svmModel,dataTrain(:,fsLocal),grpTrain);
% 
% testMCELocal=crossval(@MultiSVMClassf,ObjectsFeatures(:,1:62),grp);
% acc0=1-testMCELocal;
% 
% svmModel2=MultiSVMModels(dataTrain,grpTrain);
% acc4=MultiSVMClassification(svmModel2,dataTest,grpTest);
% 
% acc5=MultiSVMClassification(svmModel2,dataTrain,grpTrain);
%end

% mean(act2)
%tenfoldCVP=cvpartition(grp,'kfold',10);
% [fsCVfor50,historyCV] = sequentialfs(@MultiSVMClassf,dataTrain,grpTrain,...
%     'cv',tenfoldCVP,'Nf',cc);
% plot(historyCV.Crit,'o');
% xlabel('Number of Features');
% ylabel('CV MCE');
% title('Forward Sequential Feature Selection with cross-validation');