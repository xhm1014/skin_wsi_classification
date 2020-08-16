function md_featsClassificationUtilized


load('AllhistoryCV0.mat');
[minv,ind]=min(historyCV.Crit);
fs=historyCV.In(ind,:);

load('AllhistoryCV.mat');
[minv,ind]=min(historyCV.Crit);
fs1=historyCV.In(ind,:);
fs=fs|fs1;

load('AllhistoryCVII.mat');
[minv,ind]=min(historyCV.Crit);
fs2=historyCV.In(ind,:);
fs=fs|fs2;

load('AllhistoryCVIII.mat');
[minv,ind]=min(historyCV.Crit);
fs3=historyCV.In(ind,:);
fs=fs|fs3;


