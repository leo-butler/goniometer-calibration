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

function t = fom_line_from_lines  (L,normalise_direction=1)
  ## usage:  t = fom_line_from_lines (L,normalise_direction=1)
  ##
  ## Given the lines stored in the global variable objectivefn_lines
  ## this function computes \sum_M d(L,M)^2 
  global objectivefn_lines;
  r=rows(objectivefn_lines);
  t=0;
  if size(L)!=[2,3]
    L=reshape(L,3,2)';
  endif
  if normalise_direction
    L(2,:)=L(2,:)/norm(L(2,:));
  endif
  for i=1:2:r
    M=objectivefn_lines(i:i+1,:);
    t=t+dl2l(L,M);
  endfor
endfunction
%!test
%! global objectivefn_lines;
%! objectivefn_lines=[1,0,0;0,1,0];
%! L=[1,0,0;0,1,0];
%! assert(fom_line_from_lines(L),0);
%! objectivefn_lines=[1,0,1;0,1,0];
%! assert(fom_line_from_lines(L),1);
%! objectivefn_lines=[1,0,0;0,0,1];
%! fom_line_from_lines(L)

#  end of fom_line_from_lines.m 
