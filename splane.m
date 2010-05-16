function t=obj(alpha)
 global x N;
 c=alpha(4);
 n=alpha(1:3);
 n=n/norm(n);
 t=(x*n-c)' * (x*n-c)/N;
endfunction

# alpha=[n;c]
function t=norm_constraint(alpha)
 t=norm(alpha(1:3))-1;
endfunction

## an example
load randstate.m
rand("state",randstate);

global x N;
epsilon=1e-2;
N=10;
n=[1;2;-4];
n=n/norm(n);
v1=[2;-1;0];
v2=[0;2;1];
p=[0;0;0];
c=p'*n;
y=ones(N,1);
for i=1:N
 x(i,1:3)=p+rand(1)*v1+rand(1)*v2+epsilon*rand(1)*n;
endfor;
w=ols(y,x)                                #least squares
v=sqp([1;2;0;3],@obj,@norm_constraint,[]) #non-linear constrained least-squares
actual=[n;c]
error_ols=norm(w/norm(w)-n)
error_cls=norm(v(1:3)-n)
ratio=error_cls/error_ols