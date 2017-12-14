function H=hessian(theta,train_n,train_x,train_y,lambda)
H=zeros(length(theta),length(theta));
for i=1:1:train_n
    const1=1+exp(train_y(:,i)*theta'*train_x(:,i));
    const2=1+exp(-train_y(:,i)*theta'*train_x(:,i));
    H=H+((1/const1)*(1/const2)*train_y(:,i)*train_y(:,i)*train_x(:,i)*train_x(:,i)'  );
end
H=(H/train_n)+diag(ones(1,length(theta))*lambda);


end