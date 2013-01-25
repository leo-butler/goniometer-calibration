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

function [l,L,P,G] = estimator_closed_form (planar_line_data_str,focal_plane_normal,max_assert_error=1e-15,trans=1)
  ## usage:  [L,P,G] = estimator_closed_form (planar_line_data_str,focal_plane_normal,max_assert_error=1e-15,trans=1)
  ##
  ## see estimate_plane_from_lines_closed_form.m
  ## trans = 1 => transpose data in planar_line_data_str
  ## L = best fit line
  ## P = best fit planes
  ## G = best fit frames
  L=zeros(6,1);
  n=length(planar_line_data_str);
  P=zeros(4,n);
  g=zeros(3,3*n);
  for i=1:n
    x=planar_line_data_str{i}.lines;
    z=planar_line_data_str{i}.z;   ## focal depths
    if trans==1
      x=cellfun(@(t) t',x,"UniformOutput",false);
    endif
    if length(z)==1
      [p,g]=estimate_plane_from_line_closed_form(x,z,focal_plane_normal,max_assert_error);
    else
      [p,g]=estimate_plane_from_lines_closed_form(x,z,focal_plane_normal,max_assert_error);
    endif
    P(:,i)=p;
    G(:,((3*i-2):(3*i)))=g;
  endfor
  L=intersection_lines(P);
  l=estimate_line_from_lines_closed_form(L);
endfunction
%!test
%! planar_line_data_str=

#  end of estimator_closed_form.m 
