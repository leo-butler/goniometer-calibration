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
function [y,a,b] = projection_onto_line (x,L,normalise=1)
  ## usage:  y = projection_onto_line (x,L,normalise=1)
  ##
  ## x = point = 1x3 vector
  ## L = line  = 2x3 vector = [p;v]
  ##     where p = point closest to 0 on L,
  ##           v = unit direction vector
  ## y = projection of x onto L
  ## a = x-p, b = y-p
  if size(L)==[6,1]
    p=L(1:3)';
    v=L(4:6)';
  elseif size(L)==[1,6]
    p=L(1:3);
    v=L(4:6);
  elseif size(L)==[2,3]
    p=L(1,:);
    v=L(2,:);
  endif
				#normalise v and p if needed
  if normalise
    v/=norm(v);
    p=p-(v*p')*v;
  endif
  a=x-p;
  b=(v*a')*v;
  y=p+b;
endfunction
%!test
%! eps=1e-8;
%! x=[1,2,4];
%! L=[1,1,-1;1/sqrt(2),0,1/sqrt(2)];
%! [y,a,b]=projection_onto_line(x,L);
%! p=L(1,:);
%! a_exp=x-p;
%! b_exp=L(2,:)*5/sqrt(2);
%! y_exp=p+b_exp;
%! assert(y_exp,y,eps);
%! assert(a_exp,a,eps);
%! assert(b_exp,b,eps);

#  end of projection_onto_line.m 
