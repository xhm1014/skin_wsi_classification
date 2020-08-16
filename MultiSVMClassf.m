function err=MultiSVMClassf(xtrain,ytrain,xtest,ytest)

SVM_kernelPool={'linear','quadratic','polynomial','rbf','mlp'};
Para.SVM_kernel=SVM_kernelPool{1};
Para.rbf_sigma=1;
Para.C=0.1;
Para.FnMode='New';
Para.shown=0;

[g,gn]=grp2idx(ytrain);
pairwise=nchoosek(1:length(gn),2);
svmModel=cell(size(pairwise,1),1);
predTest=zeros(size(xtest,1),numel(svmModel));

for k=1:numel(svmModel)
    %# get only training instances belonging to this pair
    idx=any(bsxfun(@eq,g,pairwise(k,:)),2);
    
    %# train
    if strcmp(Para.SVM_kernel,'rbf')
        svmModel{k}=svmtrain(xtrain(idx,:),g(idx),'showplot',false,...
            'BoxConstraint',2e-1,'Kernel_Function',Para.SVM_kernel,...
            'rbf_sigma',Para.rbf_sigma,'boxonstraint',Para.C);
    else
        svmModel{k}=svmtrain(xtrain(idx,:),g(idx),...
            'Kernel_Function',Para.SVM_kernel,'boxconstraint',Para.C);
    end
    %# test
    predTest(:,k)=svmclassify(svmModel{k},xtest);
end

%# voting for classification
pred=mode(predTest,2);

err=sum(grp2idx(ytest)~=pred);

%err=err/length(ytest);
%# performance evaluation
%   cmat=confusionmat(grp2idx(ytest),pred);
%   acc=sum(diag(cmat))./sum(cmat(:));
%  err=1-acc;
end