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

function d = dptp (p,q)
  ## usage:  d = dptp (p,q)
  ##
  ## p, q = planes in R^3
  ## d = distance between p and q
  d=min([norm(p-q,2),norm(p+q,2)]);
endfunction
%!test
%! assert(dptp([1;0;0;2],[-1;0;0;-2]),0)

#  end of dptp.m 
