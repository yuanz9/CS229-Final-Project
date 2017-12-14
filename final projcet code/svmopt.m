function dev_miss=svmopt(z)
%% minimizing J(theta);

global dev_n
global train_index

global dev_index
global X_ini
global y
global IDX
ks=z(1);
bc=z(2);
amount=z(3);

data_used=IDX(1:amount);

X=X_ini(:,data_used);

train_x=X(train_index,:);
train_y=y(train_index);


dev_x=X(dev_index,:);
dev_y=y(dev_index);


SVMModel = fitcsvm(train_x,train_y,'KernelScale',ks,'BoxConstraint',bc,'Standardize',true);%,'Standardize',true

% [dev_predict,~] = predict(SVMModel,dev_x);

SVMModel3 = fitPosterior(SVMModel);
[~,score_svm] = predict(SVMModel3,dev_x);


%%
 [~,~,~,AUC] = perfcurve(dev_y,score_svm(:,2),1);
dev_miss=-AUC
% dev_miss=(sum(dev_predict~=dev_y)/dev_n);
% 
% dev_y(dev_y==-1)=0;
% dev_predict(dev_predict==-1)=0;
% 
% 
% CP = classperf(dev_y,dev_predict,'Positive', 1, 'Negative', 0);
% true_positive=CP.Sensitivity;
% dev_miss=1-true_positive
% true_negative=CP.Specificity;
% 
% dev_miss=0.8*(1-true_positive)+0.2*(1-true_negative);


end