## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id:$
##
## Author: Leo Butler (l.butler@cmich.edu)
##
## This file is OCTAVE code (http://www.octave.org/)
##
## It is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at your
## option) any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
## or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
## License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file. If not, see http://www.gnu.org/licenses/.
##

function [l,Lbar,d] = estimate_line_from_lines_closed_form (L)

  ## usage:  l = estimate_line_from_lines_closed_form (L)
  ##
  ## L = 6 x n matrix of oriented lines
  ## l = 6 x 1 least-squares best fit oriented line
  ## a line is a matrix [p;v] where p'*v=0, v'*v=1
  critpoly = @(a,b) [1,2,1-a,2*(b-a),b-a]; #[b-a, 2*b - 2*a, 1 - a, 2, 1];
  realorzero=@(x) real(x.*(abs(imag(x))<1e-9));
  delta = @(a,b) max(realorzero(roots(critpoly(a,b))));
  Lbar = mean(L,2);
  pbar = Lbar(1:3,1);
  vbar = Lbar(4:6,1);
  if norm(pbar,2) < 1e-16
    v=vbar/norm(vbar,2);
    p=pbar;
    d=NaN;
  else
    u = pbar/norm(pbar,2);
    w = vbar/norm(pbar,2)^2;
    a2 = w'*w;
    b2 = (u'*w)^2;
    d = delta(a2,b2);
    v = d^(-1)*(w-(u'*w)/(1+d)*u);
    p = pbar - (pbar'*v)*v;
  endif
  l = [p;v];
endfunction
%!test
%! L=[0,0;0,0;1,1;  1,0;0,1;0,0];
%! s=1/sqrt(2);
%! lexp=[0;0;1;s;s;0];
%! l=estimate_line_from_lines_closed_form(L);
%! assert(l,lexp,1e-12);
%! L=[0,1,0;0,0,1;1,0,0;  1,0,0;0,1,0;0,0,1];
%! s=1/sqrt(3);
%! lexp=[0;0;0;s;s;s];
%! l=estimate_line_from_lines_closed_form(L);
%! assert(l,lexp,1e-12);
%! L=[0,0.1,0;0,0,0.1;0.1,0,0;  1,0,0;0,0,1;0,0,1];
%! l=estimate_line_from_lines_closed_form(L);
%! assert(l,lexp,1e-12);

##  end of estimate_line_from_lines_closed_form.m 
