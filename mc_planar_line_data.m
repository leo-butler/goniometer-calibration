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
function pld = mc_planar_line_data (planes,focal_depths,focal_plane_normal,N=10,sigma=1,debug=1)
  ## planes = 4 x n matrix, each column is a plane
  ## focal_depths = cellstructure of length n focal depths (1 for each plane) (=lambda)
  ## focal_plane_normal = 3 x 1 normal to focal plane (=delta)
  ##
  assert(columns(planes)==length(focal_depths));
  for c=1:length(focal_depths)
    focaldepths=focal_depths{c};
    normal=planes(1:3,c);
    kappa=planes(4,c);
    pld{c}=mc_planar_line_data_str(kappa,normal,focaldepths,focal_plane_normal,N,sigma,debug);
  endfor
endfunction
%!test
%! test "mc_planar_line_data_str.m"
%!shared sigma, N, epsilon, planes, focal_depth, focal_plane_normal
%!test
%! N=1;
%! planes=[1,0,0,2;0,1,0,5]';
%! focal_depths={[10,20], [10,20]};
%! focal_plane_normal=[0;0;1];
%! pld=mc_planar_line_data(planes,focal_depths,focal_plane_normal,N,0,1)

#  end of mc_planar_line_data.m 
