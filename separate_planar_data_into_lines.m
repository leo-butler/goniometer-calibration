# -*- Mode: octave; Package: OCTAVE -*-
#
# $Id$
#
# Author: Leo Butler (l.butler@ed.ac.uk)
#
# This file is OCTAVE code (http://www.octave.org/)
# 
# It is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or (at your
# option) any later version.
# 
# This software is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
# License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this file. If not, see http://www.gnu.org/licenses/. 
#

function plane = separate_planar_data_into_lines (p)
  ## usage:  plane = lines (p)
  ##
  ## p = n x 3 data vector segregated by z values
  ## plane = cell structure of matrices with the same z values
  zvals=unique(p(:,3));
  clear plane;
  plane.z=zvals;
  n=length(zvals);
  (plane.lines){n}=[];
  for r=p'
    z=r(3);
    i=find(plane.z == z);
    (plane.lines){i}=[(plane.lines){i},r];
  endfor
  for i=1:length(plane.lines)
    (plane.lines){i}=(plane.lines){i}';
  endfor
endfunction
%!test
%! p=[1,1,1;1,2,1; 1,1,3; 2,4,5;2,3,5 ];
%! pl=separate_planar_data_into_lines(p);
%! pl_exp.z=[1;3;5];
%! (pl_exp.lines){1}=[1,1,1;1,2,1];
%! (pl_exp.lines){2}=[1,1,3];
%! (pl_exp.lines){3}=[2,4,5;2,3,5];
%! assert(pl,pl_exp);
# end of separate_planar_data_into_lines.m
