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

function x = euler_tv (g,v,skew=false,h=1e-6)
  ## usage:  x = euler_tv (g,v)
  if size(g) == [3,3]
    theta=euler_angles(g);
  else
    theta=g;
    g=euler_matrix(theta);
  endif
  v=v(1:3);
  x=euler_matrix(theta+h*v)-euler_matrix(theta-h*v);
  x/=2*h;
  if skew
    x=x*(g');
    x=0.5*(x-x');
  endif
endfunction
%!test
%! tvexp=zeros(3,3); tvexp(2,1)=1; tvexp(1,2)=-1;
%! tv=euler_tv([0,0,0],[1,0,0]);
%! assert(norm(tvexp-tv,2),0,1e-10);
%!test
%! tvexp=zeros(3,3); tvexp(3,1)=-1; tvexp(1,3)=1;
%! tv=euler_tv([0,0,0],[0,1,0]);
%! assert(norm(tvexp-tv,2),0,1e-10);
%!test
%! tvexp=zeros(3,3); tvexp(3,2)=1; tvexp(2,3)=-1;
%! tv=euler_tv([0,0,0],[0,0,1]);
%! assert(norm(tvexp-tv,2),0,1e-10);
%!test
%! tvexp=zeros(3,3); tvexp(3,1)=-1; tvexp(1,3)=1;
%! tv=euler_tv(eye(3),[0;1;0]);
%! assert(norm(tvexp-tv,2),0,1e-10);

#  end of euler_tv.m 
