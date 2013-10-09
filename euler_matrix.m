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

function g = euler_matrix (theta,axes=[3,2,1],d=3)
  ## usage:  g = euler_matrix (theta,axes=[3,2,1])
  n=length(axes);
  g=eye(d);
  for i=1:n
    g=g*elementary_rotation(theta(i),axes(i),d);
  endfor
endfunction
%!test
%! gexp=eye(3);
%! g=euler_matrix(zeros(3,1));
%! assert(norm(gexp-g,2),0);
%!test
%! rndu=@(r) 2*r.*rand(rows(r),columns(r))-r;
%! gexp=euler_matrix(rndu(pi*[1,0.5,1]));
%! g=euler_matrix(euler_angles(gexp));
%! assert(norm(gexp-g,2),0,1e-9)
%!test
%! gexp=euler_matrix([2,1,3]);
%! e1=[1;0;0]; e2=[0;1;0];
%! l=reshape( (gexp*[e2,e1]),6,1 );
%! ga=euler_coordinates(l);
%! g=euler_matrix(ga(1:3));
%! assert(norm(gexp-g,2),0,1e-9);
#  end of euler_matrix.m 
