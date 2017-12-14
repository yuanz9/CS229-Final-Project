clear,clc,close all

global dev_n
global train_index
global left_index
global dev_index
global X_ini
global y
global IDX
rng(1)
data = load('data84.csv');
n = size(data, 1);
[train_index,dev_index,test_index] = dividerand(n,0.7,0.15,0.15);
train_n=numel(train_index);
dev_n=numel(dev_index);
test_n=numel(test_index);

X_ini = data(:, 2:end);
y = data(:, 1);
[IDX, ~] = rankfeatures(X_ini', y','Criterion', 'entropy');

%%

ObjectiveFunction = @svmopt;

nvars = 3;    % Number of variables

LB = [0 0 1];   % Lower bound
UB = [1000 1000 84];  % Upper bound

opts = optimoptions('ga','PlotFcn',@gaplotscorediversity,'MaxTime',7200);

[z,fval,exitflag] = ga(ObjectiveFunction,nvars,[],[],[],[],...
    LB,UB,[],[3],opts);

ks=z(1)
bc=z(2)
amount=z(3)
% ks=101.3984
% bc=999.5889
% amount=8

data_used=IDX(1:amount);

X=X_ini(:,data_used);



%%
 
train_x=X(train_index,:);
train_y=y(train_index);



dev_x=X(dev_index,:);
dev_y=y(dev_index);

test_x=X(test_index,:);
test_y=y(test_index);


model1 = fitcsvm(train_x,train_y,'KernelScale',ks,'BoxConstraint',bc,'Standardize',true);%,'Standardize',true
[train_predict,~] = predict(model1,train_x);
train_accuracy=1-sum(train_y~=train_predict)/numel(train_y)

[dev_predict,~] = predict(model1,dev_x);
dev_accuracy=1-sum(dev_y~=dev_predict)/numel(dev_y)

%% evaluate in test set
% SVMModel = fitcsvm([train_x;dev_x],[train_y;dev_y],'KernelScale',ks,'BoxConstraint',bc);%,'Standardize',true
SVMModel = fitcsvm([train_x;dev_x],[train_y;dev_y],'KernelScale',ks,'BoxConstraint',bc,'Standardize',true);%,'Standardize',true
[test_predict,~] = predict(SVMModel,test_x);

% SVMModel3 = fitPosterior(SVMModel);
% [label,score_svm] = predict(SVMModel3,test_x);
% 
% [test_y,label,score_svm(:,2)]


test_accuracy=1-sum(test_y~=test_predict)/numel(test_y)

test_y(test_y==-1)=0;
test_predict(test_predict==-1)=0;
CP = classperf(test_y,test_predict,'Positive', 1, 'Negative', 0);
true_positive=CP.Sensitivity
true_negative=CP.Specificity
plotconfusion(test_y',test_predict')
xlabel('Actual')
ylabel('Predicted')
xticklabels({'Lane Keeping','Lane Merging'})
yticklabels({'Lane Keeping','Lane Merging'})
ytickangle(90)


beep


