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

function [pldss,kappa,v,rho,plambda] = mc_planar_line_data_str_slice (fd,N=10,sigma=1)
  ## L = [p;v] = point & direction vector of focal axis
  ## normal = 3 x 1 matrix of unit columns (=pi)
  ## focal_depth = focal depths (1 for each plane) (=lambda)
  ## focal_plane_normal = 3 x 1 normal to focal plane (=delta)
  ## N = number of points
  ## sigma = covariance matrix (either scalar or 2x2 matrix)
  ## introduce drift in the line's direction
  fd=frame_data(fd,N,sigma);
  pld=sigma*randn(2,2*N+1) + [0;1]*(-N:N);
  focal_plane_normal=fd.focal_plane_normal; rho=fd.rho; v=fd.v; plambda=fd.plambda; kappa=fd.kappa;
  pldss=((eye(3)-focal_plane_normal*focal_plane_normal')*[rho,v]*pld+plambda)';
endfunction
%!shared sigma, N, epsilon, L, normal, focal_depth, focal_plane_normal, fd
%!test
%! normal=[0;1;0];
%! focal_depth=10;
%! focal_plane_normal=[0;1;1]/sqrt(2);
%! kappa=0;
%! fd=frame_data(kappa,normal,focal_depth,focal_plane_normal);
%! [pldss,kappa,v,rho,plambda]=mc_planar_line_data_str_slice(fd,1,0);
%! assert(kappa,0);
%! assert(v,[-1;0;0])
%! assert(rho,[0;0;1])
%! assert(plambda,rho*focal_depth/(rho'*focal_plane_normal))
%!test
%! sigma=1e-2; N=10;
%! epsilon=5*sigma;
%! [pldss,kappa,v,rho,plambda]=mc_planar_line_data_str_slice(fd,N,sigma);
%! assert(kappa,0,epsilon);
%! assert(v,[-1;0;0;],epsilon)
%! assert(rho,[0;0;1],epsilon)
%! assert(plambda,rho*focal_depth/(rho'*focal_plane_normal),epsilon)
%! assert(norm(mean(pldss)'-plambda,2)/sqrt(N),0,epsilon)
%!test
%! sigma=1e0; N=20;
%! epsilon=5*sigma+1e-8;
%! [pldss,kappa,v,rho,plambda]=mc_planar_line_data_str_slice(fd,N,sigma);
%! assert(kappa,2,epsilon);
%! assert(v,[-1;0;0;],epsilon)
%! assert(rho,[0;0;1],epsilon)
%! assert(plambda,normal*kappa+rho*(focal_depth-kappa*(focal_plane_normal'*normal))/(rho'*focal_plane_normal),epsilon)
%! assert(norm(mean(pldss)'-plambda,2)/sqrt(N),0,epsilon)
%! assert(norm(pldss*focal_plane_normal-focal_depth,2),0,1e-8)

#  end of mc_planar_line_data_str_slice.m 
