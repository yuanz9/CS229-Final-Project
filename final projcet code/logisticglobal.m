clear,clc,close all
global train_n
global dev_n
global train_index
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

X_ini = [ones(n, 1), data(:, 2:end)]';
y = data(:, 1)';
[IDX, ~] = rankfeatures(X_ini, y,'Criterion', 'entropy');
%%

ObjectiveFunction = @logall;

nvars = 2;    % Number of variables

LB = [0 1];   % Lower bound
UB = [500 84];  % Upper bound

opts = optimoptions('ga','PlotFcn',@gaplotscorediversity,'MaxTime',7200);

[z,fval,exitflag] = ga(ObjectiveFunction,nvars,[],[],[],[],...
    LB,UB,[],[2],opts);

%


lambda=z(1)
amount=z(2)

% lambda=0.0168;
% amount=81

data_used=IDX(1:amount);

X=X_ini(data_used,:);



%%
 
train_x=X(:,train_index);
train_y=y(train_index);

dev_x=X(:,dev_index);
dev_y=y(dev_index);

test_x=X(:,test_index);
test_y=y(test_index);


max_iter=50;
tol=0.00001;

theta=zeros(size(train_x,1),1);
for i=1:1:max_iter
J(i)=cost_func(theta,train_n,train_x,train_y,lambda);

if i>1 && abs(J(i)-J(i-1))<=tol
    break;
end
G=gradient(theta,train_n,train_x,train_y,lambda);
H=hessian(theta,train_n,train_x,train_y,lambda);
theta=theta-pinv(H)*G;

end
%% training set accuracy
phi_train=1./(1+exp(-theta'*train_x));
train_predict=-ones(1,train_n);
train_predict(find(phi_train>=0.5))=1;
train_accuracy=1-(sum(train_predict~=train_y)/train_n)

phi_dev=1./(1+exp(-theta'*dev_x));
dev_predict=-ones(1,dev_n);
dev_predict(find(phi_dev>=0.5))=1;
dev_accuracy=1-(sum(dev_predict~=dev_y)/(dev_n))

%%
max_iter=50;
tol=0.00001;

theta=zeros(size(train_x,1),1);
for i=1:1:max_iter
J(i)=cost_func(theta,train_n+dev_n,[train_x,dev_x],[train_y,dev_y],lambda);

if i>1 && abs(J(i)-J(i-1))<=tol
    break;
end
G=gradient(theta,train_n+dev_n,[train_x,dev_x],[train_y,dev_y],lambda);
H=hessian(theta,train_n+dev_n,[train_x,dev_x],[train_y,dev_y],lambda);
theta=theta-pinv(H)*G;

end

%% test set accuracy
phi_test=1./(1+exp(-theta'*test_x));
test_predict=-ones(1,test_n);
test_predict(find(phi_test>=0.5))=1;
test_accuracy=1-(sum(test_predict~=test_y)/test_n)


test_y(test_y==-1)=0;
test_predict(test_predict==-1)=0;


CP = classperf(test_y,test_predict,'Positive', 1, 'Negative', 0);
true_positive=CP.Sensitivity
true_negative=CP.Specificity

plotconfusion(test_y,test_predict)
xlabel('Actual')
ylabel('Predicted')
xticklabels({'Lane Keeping','Lane Merging'})
yticklabels({'Lane Keeping','Lane Merging'})
ytickangle(90)
beep

[~,~,~,AUC] = perfcurve(test_y,phi_test,1);