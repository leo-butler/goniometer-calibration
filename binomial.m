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

function f=binomial(n,c=0)
  if size(n)==[1,1]
    f=factorial(n)/factorial(n-c)/factorial(c);
  else
    f=[];
    for i=1:columns(n)
      f=[f,binomial(n(1,i),n(2,i))];
    endfor
  endif
endfunction
%!test
%! assert(3,binomial(3,2));
%! assert([3,6],binomial([3,4;2,2]));

#  end of binomial.m 
