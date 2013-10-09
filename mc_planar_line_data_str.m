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

function plds = mc_planar_line_data_str (kappa,normal,focal_depths,focal_plane_normal,N=10,sigma=1,debug=0)
  ## L = [p;v] = point & direction vector of focal axis
  ## normal = 3 x 1 matrix of unit columns (=pi)
  ## focal_depth = focal depths (1 for each plane) (=lambda)
  ## focal_plane_normal = 3 x 1 normal to focal plane (=delta)
  plds.normal=normal;
  plds.focal_plane_normal=focal_plane_normal;
  plds.sigma=sigma;
  ## Degenerate case when the focal_plane_normal and normal coincide, and there is a 
  ## single focal_depth. In this case, focal_depths should be a 2-element cell {kappa, v}.
  if iscell(focal_depths)
    plds.fd=fd=frame_data(kappa,normal,focal_depths,focal_plane_normal);
    plds.z=focal_depths{1};
  else
    plds.z=focal_depths;
    plds.fd=fd=frame_data(kappa,normal,1,focal_plane_normal);
  endif
  for c=1:length(focal_depths)
    fd.focal_depth=focal_depths(c);
    [pldss,kappa,v,rho,plambda]=mc_planar_line_data_str_slice(fd,N,sigma);
    (plds.lines){c}=pldss;
    if debug
      (plds.t){c}=fd.t;
      (plds.plambda){c}=plambda;
    endif
  endfor
  plds.filename="mc_planar_line_data_str.m";
endfunction
%!test
%! test "mc_planar_line_data_str_slice.m"
%!shared sigma, N, epsilon, normal, focal_depth, focal_plane_normal, lineexp
%!test
%! N=2; sigma=0;
%! kappa=1;
%! normal=[0;1;0];
%! focal_depths=[10;20];
%! focal_plane_normal=[0;0;1];
%! lineexp=@(z) [(N:-1:-N)',ones(2*N+1,1),z*ones(2*N+1,1)];
%! pld=mc_planar_line_data_str(kappa,normal,focal_depths,focal_plane_normal,N,sigma);
%! assert(norm((pld.lines){1}-lineexp(10),2),0)
%! assert(norm((pld.lines){2}-lineexp(20),2),0)
%!test
%! N=2; sigma=1e-1;
%! kappa=1;
%! normal=[0;1;0];
%! focal_depths=[10;20];
%! focal_plane_normal=[0;0;1];
%! pld=mc_planar_line_data_str(kappa,normal,focal_depths,focal_plane_normal,N,sigma);
%! assert(norm((pld.lines){1}-lineexp(10),2),0,4*sigma)
%! assert(norm((pld.lines){2}-lineexp(20),2),0,4*sigma)

#  end of mc_planar_line_data_str.m 
