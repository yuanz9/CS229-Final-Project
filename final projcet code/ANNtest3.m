clear,clc,close all

data = load('data84.csv');

n = size(data, 1);

X_ini = data(:, 2:end)';
y = data(:, 1)';

[IDX, ~] = rankfeatures(X_ini, y,'Criterion', 'entropy');
%%
neuron=23;
amount=25;


data_used=IDX(1:amount);
% 
X=X_ini(data_used,:);

 
net=feedforwardnet([neuron ],'trainscg');

net.layers{1}.transferFcn = 'tansig';
net.layers{2}.transferFcn = 'logsig';
net.adaptFcn='learngdm';
net.performFcn='crossentropy';
net.divideFcn='divideind';

rng(1)
[trainInd,valInd,testInd] = dividerand(n,0.7,0.15,0.15);
net.divideParam.trainInd=trainInd;
net.divideParam.valInd=valInd;
net.divideParam.testInd=testInd;
net.trainParam.showWindow = false;
[network1,tr]=train(net,X,y);
% tr.valInd
%%

% train_x=X(:,trainInd);
% train_y=y(trainInd);
% train_n=numel(train_y);
% 
% dev_x=X(:,valInd);
% dev_y=y(valInd);
% dev_n=numel(dev_y);
% 
% 
test_x=X(:,testInd);
test_y=y(testInd);
test_n=numel(test_y);
% 
% train_predict=network1(train_x);
% train_predict(train_predict>=0.5)=1;
% train_predict(train_predict<0.5)=-1;
% train_accuracy=1-sum(train_predict~=train_y)/train_n
% 
% 
% dev_predict=network1(dev_x);
% dev_predict(dev_predict>=0.5)=1;
% dev_predict(dev_predict<0.5)=-1;
% dev_accuracy=1-sum(dev_predict~=dev_y)/dev_n



test_predict=network1(test_x);

test_predict(test_predict>=0.5)=1;
test_predict(test_predict<0.5)=-1;



test_accuracy=1-sum(test_predict~=test_y)/test_n

wrong_index=find(test_predict~=test_y)
wrong_sample=X(:,wrong_index)
wrong_label=test_predict(wrong_index)
true_label=test_y(wrong_index)
features=IDX(1:amount)



% test_y(test_y==-1)=0;
% test_predict(test_predict==-1)=0;
% CP = classperf(test_y,test_predict,'Positive', 1, 'Negative', 0);

% [a,b,~,AUC1] = perfcurve(test_y,network1(test_x),1);
% load testy_log
% load testy_svm
% load phi_test_AUC
% load score_svm
% [c,d,~,AUC2] = perfcurve(testy_log,phi_test,1);
% [e,f,~,AUC3] = perfcurve(testy_svm,score_svm(:,2),1);
% 
% plot(c,d)
% hold on
% plot(e,f)
% plot(a,b)
% legend('Logistic Regression','Support Vector Machines','Artificial Neural Network','Location','Best')
% xlabel('False positive rate'); ylabel('True positive rate');
% title('ROC Curves for Logistic Regression, SVM, and ANN Classification')
% hold off


% true_positive=CP.Sensitivity
% true_negative=CP.Specificity
% figure
% plotconfusion(test_y,test_predict)
% xlabel('Actual')
% ylabel('Predicted')
% xticklabels({'Lane Keeping','Lane Merging'})
% yticklabels({'Lane Keeping','Lane Merging'})
% ytickangle(90)
% view(network1)