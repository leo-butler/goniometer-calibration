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

function g = elementary_rotation (theta,axis,n=3)
  ## usage:  g = elementary_rotation (theta,axis,n=3)
  if n==3
    axes=[2,3;3,1;1,2];
  else
    axes=powerset((1:n)',2);
  endif
  g=eye(n,n);
  i=axes(axis,1); j=axes(axis,2);
  g(i,i)=g(j,j)=cos(theta);
  g(i,j)=g(j,i)=sin(theta); g(i,j)*=-1;
endfunction
%!test
%! gexp=eye(3);
%! g=elementary_rotation(0,1);
%! assert(norm(gexp-g,2),0);
%!test
%! theta=0.5;
%! gexp=[cos(theta),-sin(theta),0;sin(theta),cos(theta),0;0,0,1];
%! g=elementary_rotation(theta,3);
%! assert(norm(gexp-g,2),0,1e-10);

#  end of elementary_rotation.m 
