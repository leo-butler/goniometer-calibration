## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id:$
##
## Author: Leo Butler (l.butler@ed.ac.uk)
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

function v = vector_product (a,b)
  ## usage: v = vector_product (a,b)
  ##
  ## v = the vector (cross) product of the 3-vectors a and b.
  ## a,b may be row or column vectors.
  v=[a(2)*b(3)-a(3)*b(2);-a(1)*b(3)+a(3)*b(1);a(1)*b(2)-a(2)*b(1)];
  if rows(a)==1 && rows(b)==1
    v=[a(2)*b(3)-a(3)*b(2), -a(1)*b(3)+a(3)*b(1), a(1)*b(2)-a(2)*b(1)];
  elseif rows(a)==3 && rows(b)==3
    v=[a(2,:).*b(3,:)-a(3,:).*b(2,:);-a(1,:).*b(3,:)+a(3,:).*b(1,:);a(1,:).*b(2,:)-a(2,:).*b(1,:)];
  else
    "a=",a,"b=",b
    error("vector_product(a,b)");
  endif
endfunction
%!test
%! assert(vector_product([1;0;0],[0;1;0]),[0;0;1])
%! assert(vector_product([0;1;0],[0;0;1]),[1;0;0])
%! assert(vector_product([0;0;1],[1;0;0]),[0;1;0])
%! assert(vector_product([1,0,0],[0,1,0]),[0,0,1])
%! assert(vector_product([0,1,0],[0,0,1]),[1,0,0])
%! assert(vector_product([0,0,1],[1,0,0]),[0,1,0])
%! g=eye(3); h=[g(2,:); g(3,:); g(1,:)]'; k=[g(3,:); g(1,:); g(2,:)]';
%! assert(vector_product(g,h),k)

#  end of vector_product.m 
