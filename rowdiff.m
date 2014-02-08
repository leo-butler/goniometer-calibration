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
function y = rowdiff (a,i)
  ## usage:  y = rowdiff (a,i)
  ##
  ## given a matrix a with r rows, removes the i-th row
  if size(a)==0
    y = a;
  endif
  r = rows(a);
  if i<0 || i>r
    error("rowdiff(a,i): i < 0 or i > rows(a).");
  elseif i==1
    y = a(2:r,:);
  elseif i==r
    y = a(1:r-1,:);
  else
    y = [a(1:i-1,:); a(i+1:r,:)];
  endif
endfunction
%!test
%!shared x
%! x=reshape(1:20,4,5);
%! assert(rowdiff(x,1),x(2:4,:))
%!test
%! assert(rowdiff(x,4),x(1:3,:))
%!test
%! assert(rowdiff(x,2),[x(1,:);x(3:4,:)])

#  end of rowdiff.m 
