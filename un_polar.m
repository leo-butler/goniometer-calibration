function [o,p] = un_polar(x)
  p = sqrtm(transpose(x)*x);
  o = x*inverse(p);
  o = real(o);
endfunction