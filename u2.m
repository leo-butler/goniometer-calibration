function u = u2(rnd=1,sigma=0.0)
  if (rnd == 1)
    x = randn(2,1)+i*randn(2,1);
    x = x/norm(x,2);
    y = exp(2*pi*i*rand())*conj([x(2);-x(1)]);
    u = [x,y];
  elseif (rnd == 2)
    x = randn(2,1)+i*randn(2,1);
    x = x/norm(x,2);
    y = randn(2,1)+i*randn(2,1);
    y = y - (ctranspose(x)*y)*x;
    y = y/norm(y,2);
    u = [x,y];
  elseif (columns(rnd) == 2 && rows(rnd) == 2)
    u = rnd + sigma*(randn(2,2)+i*randn(2,2));
    u(:,1) = u(:,1)/norm(u(:,1),2);
    u(:,2) = u(:,2) - (ctranspose(u(:,1))*u(:,2))*u(:,1);
    u(:,2) = u(:,2)/norm(u(:,2),2)
  endif
endfunction