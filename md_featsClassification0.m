function md_featsClassification0
clear all; clc;
cd C:\Users\mxu\Dropbox\Public\Classification_Project\features
%rng(8000,'twister');  %% for featues selection

load('ObjectsFeatures0.mat');
cc=size(ObjectsFeatures0,2);
LabelPool={'melaoma','non-melanoma'};
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
TPa=[];TPe=[];TPd=[];
FPa=[];FPe=[];FPd=[];
PPVa=[];PPVe=[];PPVd=[];
for i=1:100

% %# sequential feature selection
  tenfoldCVP=cvpartition(grp,'kfold',10);
  
% [fsCVfor50,historyCV] = sequentialfs(@MultiSVMClassif00,ObjectsFeatures0,grp,...
%     'cv',tenfoldCVP,'Nf',cc);
% plot(historyCV.Crit,'o');
% xlabel('Number of Features');
% ylabel('CV MCE');
% title('Forward Sequential Feature Selection with cross-validation');

% load('AllhistoryCV0.mat');
% [minv,ind]=min(historyCV.Crit);
% fsLocal=historyCV.In(ind,:);
% 
% % load('fs.mat');
% % fsLocal=fs;
% testMCE=crossval(@MultiSVMClassif0,ObjectsFeatures0(:,fsLocal),grp,'Partition',tenfoldCVP);   
% acc0=1-mean(testMCE(:,1));  %% based on selected features
% CA0=[CA0;acc0];

testMCE=crossval(@MultiSVMClassif0,ObjectsFeatures0,grp,'Partition',tenfoldCVP);   
acc1=1-mean(testMCE);  %% use all features
CA1=[CA1;acc1];
% 
TPa=[TPa,mean(testMCE(:,2))];
FPa=[FPa,mean(testMCE(:,3))];
PPVa=[PPVa,mean(testMCE(:,4))];
% 
% testMCE=crossval(@MultiSVMClassif0,ObjectsFeatures0(:,1:13),grp,'Partition',tenfoldCVP);   
% acc2=1-mean(testMCE);  %% use epidermis features
% CA2=[CA2;acc2];
% 
% % TPe=[TPe,mean(testMCE(:,2))];
% % FPe=[FPe,mean(testMCE(:,3))];
% % PPVe=[PPVe,mean(testMCE(:,4))];
% 
% testMCE=crossval(@MultiSVMClassif0,ObjectsFeatures0(:,14:73),grp,'Partition',tenfoldCVP);   
% acc3=1-mean(testMCE);  %% use dermis features
% CA3=[CA3;acc3];

% TPd=[TPd,mean(testMCE(:,2))];
% FPd=[FPd,mean(testMCE(:,3))];
% PPVd=[PPVd,mean(testMCE(:,4))];
end
sfc=mean(CA0);
% afc=mean(CA1);
% efc=mean(CA2);
% dfc=mean(CA3);

TPaf=mean(TPa);
FPaf=mean(FPa);
PPVaf=mean(PPVa);
% 
% TPef=mean(TPe);
% FPef=mean(FPe);
% PPVef=mean(PPVe);
% 
% TPdf=mean(TPd);
% FPdf=mean(FPd);
% PPVd=mean(PPVd);
