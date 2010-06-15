function s=ssum(f,i,a,b)
  s=0;
  for i=a:b
    s=s+feval(f,i);
  endfor
  s;
endfunction

## end of ssum.m

