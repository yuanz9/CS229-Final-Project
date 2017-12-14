function dev_miss=logall(z)
%% minimizing J(theta);
global train_n
global dev_n
global train_index
global dev_index
global X_ini
global y
global IDX
lambda=z(1);
amount=z(2);

data_used=IDX(1:amount);

X=X_ini(data_used,:);


%%
train_x=X(:,train_index);
train_y=y(train_index);

dev_x=X(:,dev_index);
dev_y=y(dev_index);


max_iter=500;
tol=0.0001;

theta=zeros(size(train_x,1),1);
flag=0;
for i=1:1:max_iter
J(i)=cost_func(theta,train_n,train_x,train_y,lambda);

if i>1 && abs(J(i)-J(i-1))<=tol
    flag=1;
    break;
end
G=gradient(theta,train_n,train_x,train_y,lambda);
H=hessian(theta,train_n,train_x,train_y,lambda);
theta=theta-pinv(H)*G;

end

if flag==1
phi_dev=1./(1+exp(-theta'*dev_x));

% [~,~,~,AUC] = perfcurve(dev_y,phi_dev,1);
% dev_miss=-AUC;
% else
%   dev_miss=100;  
%     
% end


dev_predict=-ones(1,dev_n);
dev_predict(find(phi_dev>=0.5))=1;
dev_miss=(sum(dev_predict~=dev_y)/dev_n)

% dev_y(dev_y==-1)=0;
% dev_predict(dev_predict==-1)=0;
% 
% 
% CP = classperf(dev_y,dev_predict,'Positive', 1, 'Negative', 0);
% true_positive=CP.Sensitivity;
% % dev_miss=1-true_positive;
% true_negative=CP.Specificity;
% 
% dev_miss=0.6*(1-true_positive)+0.4*(1-true_negative);

end