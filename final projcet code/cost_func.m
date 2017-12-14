function J=cost_func(theta,train_n,train_x,train_y,lambda)
J=0;
for i=1:1:train_n
    J=J+log(1+exp( -train_y(:,i)*theta'*train_x(:,i)));
end
J=(J/train_n)+(lambda/2)*norm(theta)^2;
end