function g=gradient(theta,train_n,train_x,train_y,lambda)
g=zeros(length(theta),1);

for k=1:1:length(theta)
for i=1:1:train_n
    const1=1+exp(train_y(:,i)*theta'*train_x(:,i));
    g(k)=g(k)+(1/const1)*(-train_y(:,i)*train_x(k,i))  ;
end
g(k)=(g(k)/train_n)+lambda*theta(k);
end

end