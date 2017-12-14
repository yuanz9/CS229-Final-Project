clear,clc,close all
global X_ini
global y
global IDX
global n
global train_index
global dev_index
global dev_n
global train_n
global test_index
global test_n
rng(1)
data = load('data84.csv');
n = size(data, 1);

[train_index,dev_index,test_index] = dividerand(n,0.7,0.15,0.15);
train_n=numel(train_index);
dev_n=numel(dev_index);
test_n=numel(test_index);


X_ini = data(:, 2:end)';
y = data(:, 1)';
[IDX, ~] = rankfeatures(X_ini, y,'Criterion', 'entropy');
%%
% [z,fval,exitFlag,output] =simulannealbnd(@logall,[3 3],[1 1],[100 84]);
% 
% neuron=z(1)
% amount=round(z(2))

ObjectiveFunction = @annpot;

nvars = 2;    % Number of variables

LB = [1 1];   % Lower bound
UB = [100 84];  % Upper bound

opts = optimoptions('ga','PlotFcn',@gaplotscorediversity,'MaxTime',7200);

[z,fval,exitflag] = ga(ObjectiveFunction,nvars,[],[],[],[],...
    LB,UB,[],[1 2],opts);
neuron=z(1)
amount=z(2)

[AUC,train_accuracy,train_dev_accuracy,dev_miss]=annpot(z);

train_accuracy
train_dev_accuracy
dev_accuracy=1-dev_miss
AUC=-AUC



% test_y(test_y==-1)=0;
% test_predict(test_predict==-1)=0;
% CP = classperf(test_y,test_predict,'Positive', 1, 'Negative', 0);
% true_positive=CP.Sensitivity
% true_negative=CP.Specificity
% 
% plotconfusion(test_y,test_predict)
% xlabel('Actual')
% ylabel('Predicted')
% xticklabels({'Lane Keeping','Lane Merging'})
% yticklabels({'Lane Keeping','Lane Merging'})
% ytickangle(90)