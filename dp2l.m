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
function d = dp2l (q,p,v,new)
  ## usage:  d = dp2l (q,p,v,new)
  ##
  ## compute the distance of the point q from the line [p;v]
  persistent P;
  if new
    P=eye(3)-v*v';
  endif
  d=norm(P*(q-p),2);
endfunction
%!test
%! eps=1e-8;
%! d=dp2l([0;0;0],[1;0;-1],[1;1;1]/sqrt(3),1);
%! assert(d,sqrt(2),eps);

#  end of dp2l.m 
