function md_featsClassificationII
clear all; clc;
cd C:\Users\Jorge\Dropbox\Public\Classification_Project\features
%rng(8000,'twister');  %% for featues selection

load('ObjectsFeaturesII.mat');
cc=size(ObjectsFeaturesII,2);
LabelPool={'lentiginous','nodular','superficial'};
for i=1:size(CasePoolIdx,2)
    curCaseIdx=CasePoolIdx{i};
    [grp{curCaseIdx,1}]=deal(LabelPool{i});
end

CA0=[];CA1=[];CA2=[];CA3=[];
for i=1:100

% %# sequential feature selection
  tenfoldCVP=cvpartition(grp,'kfold',10);
  
% [fsCVfor50,historyCV] = sequentialfs(@MultiSVMClassfII,ObjectsFeaturesII,grp,...
%     'cv',tenfoldCVP,'Nf',cc);
% plot(historyCV.Crit,'o');
% xlabel('Number of Features');
% ylabel('CV MCE');
% title('Forward Sequential Feature Selection with cross-validation');

load('AllhistoryCVII.mat');
[minv,ind]=min(historyCV.Crit);
fsLocal=historyCV.In(ind,:);

% load('fs.mat');
% fsLocal=fs;
testMCE=crossval(@MultiSVMClassif2II,ObjectsFeaturesII(:,fsLocal),grp,'Partition',tenfoldCVP);   
acc0=1-mean(testMCE);  %% based on selected features
CA0=[CA0,acc0];

% testMCE=crossval(@MultiSVMClassif2II,ObjectsFeaturesII,grp,'Partition',tenfoldCVP);   
% acc1=1-mean(testMCE);  %% use all features
% CA1=[CA1,acc1];
% 
% testMCE=crossval(@MultiSVMClassif2II,ObjectsFeaturesII(:,1:13),grp,'Partition',tenfoldCVP);   
% acc2=1-mean(testMCE);  %% use epidermis features
% CA2=[CA2,acc2];
% 
% testMCE=crossval(@MultiSVMClassif2II,ObjectsFeaturesII(:,14:73),grp,'Partition',tenfoldCVP);   
% acc3=1-mean(testMCE);  %% use dermis features
% CA3=[CA3,acc3];
end
sfc=mean(CA0);
afc=mean(CA1);
efc=mean(CA2);
dfc=mean(CA3);

