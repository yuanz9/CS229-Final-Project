function [dev_miss,train_accuracy,train_dev_accuracy,dev_missC]=annpot(z)

global X_ini
global y
global IDX
global dev_n
global train_n
global train_index
global dev_index
% global test_index
% global test_n

rng(1);
neuron=z(1);
amount=z(2);


data_used=IDX(1:amount);
% 
X=X_ini(data_used,:);

train_x=X(:,train_index);
train_y=y(train_index);

dev_x=X(:,dev_index);
dev_y=y(dev_index);

% test_x=X(:,test_index);
% test_y=y(test_index);
 
net=feedforwardnet([neuron ],'trainscg');
net.layers{1}.transferFcn = 'tansig';
net.layers{2}.transferFcn = 'logsig';
net.adaptFcn='learngdm';
net.performFcn='crossentropy';
net.divideFcn='divideind';

rng(1)
[trainInd,valInd,testInd] = dividerand(train_n,0.7,0.1,0);

net.divideParam.trainInd=trainInd;
net.divideParam.valInd=valInd;
net.divideParam.testInd=testInd;
net.trainParam.showWindow = false;
[network1,tr]=train(net,train_x,train_y);
% tr.valInd
%%
x_train=train_x(:,trainInd);
y_train=train_y(trainInd);
n_train=numel(trainInd);

train_dev_x=train_x(:,valInd);
train_dev_y=train_y(valInd);
train_dev_n=numel(valInd);


train_predict=network1(x_train);
train_predict(train_predict>=0.5)=1;
train_predict(train_predict<0.5)=-1;
train_accuracy=1-sum(train_predict~=y_train)/n_train;

train_dev_predict=network1(train_dev_x);
train_dev_predict(train_dev_predict>=0.5)=1;
train_dev_predict(train_dev_predict<0.5)=-1;
train_dev_accuracy=1-sum(train_dev_predict~=train_dev_y)/train_dev_n;


dev_predict=network1(dev_x);
dev_predict(dev_predict>=0.5)=1;
dev_predict(dev_predict<0.5)=-1;
dev_missC=sum(dev_predict~=dev_y)/dev_n;

[~,~,~,AUC1] = perfcurve(dev_y,network1(dev_x),1);
dev_miss=-AUC1
% test_predict=network1(test_x);
% test_predict(test_predict>=0.5)=1;
% test_predict(test_predict<0.5)=-1;
% test_accuracy=1-sum(test_predict~=test_y)/test_n;



end