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

function L = unoriented_line (L)
  p=L(1:3);
  v=L(4:6);
  vabs=abs(v);
  vmax=max(vabs);
  [i,j]=find(vabs==vmax);
  s=sign(v(i,j));
  v=s*v;
  L=[p;v];
endfunction
%!test
%! L=[0;0;0;1;-2;1];
%! Lexp=-L;
%! N=unoriented_line(L);
%! assert(norm(Lexp-N,2),0)

#  end of unoriented_line.m 
