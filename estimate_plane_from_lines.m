## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id:$
##
## Author: Leo Butler (l.butler@ed.ac.uk)
##
## This file is OCTAVE code (http://www.octave.org/)
##
## It is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free
## Software Foundation; either version 3 of the License, or (at your
## option) any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file. If not, see http://www.gnu.org/licenses/.
##
## usage:  [P_hat,obj,info,iter,nf,lambda] = estimate_plane_from_lines (P0)
##
## Given data clustered around coplanar lines at varying depths,
## estimate the common plane containing these lines.
##
## Globals:
## planar_line_data	-> a cell structure of 3 x N_i matrices of points at focal depth lambda_i
## focal_plane_depths	-> a vector of focal depths lambda_i
## focal_plane_normal	-> normal to the focal plane
## focal_plane_normal_t -> transpose of previous

function [P_hat,obj,info,iter,nf,lambda] = estimate_plane_from_lines (P0,maxiter=150,tolerance=1e-6)
  # global planar_line_data;
  # global focal_plane_normal;
  # global focal_plane_normal_t;
  # global focal_plane_depths;
  unit_length=@(x) x(1)^2+x(2)^2+x(3)^2-1;
  fom=@(x) fom_plane_from_lines(x);
  [P_hat,obj,info,iter,nf,lambda]=sqp(P0,fom,unit_length,[],[],[],maxiter,tolerance);
endfunction

%!test
%! global focal_plane_depths;
%! global planar_line_data;
%! global focal_plane_normal;
%! focal_plane_normal=[0;0;1];
%! focal_plane_depths=[1;2;3];
%! P0=[1;1;1;4]/sqrt(3);
%! P=[1;0;0;1];
%! 
%! planar_line_data={
%! 		  ## alpha+t*rho+s*v
%! 		  ## t=lambda=focal_plane_depth
%! 		  [1,1,1;0,0,0;0,0,0]+1*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]
%! 		  [1,1,1;0,0,0;0,0,0]+2*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]
%! 		  [1,1,1;0,0,0;0,0,0]+3*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]
%! 		  };
%! [P_hat,obj,info,iter,nf,lambda]=estimate_plane_from_lines(P0);
%! assert(P_hat,[1;0;0;1],1e-6);
%!test
%! global focal_plane_depths;
%! global planar_line_data;
%! global focal_plane_normal;
%! focal_plane_normal=[0;0;1];
%! focal_plane_depths=[1;2;3];
%! load "randstate.m";
%! rand("state",randstate);
%! P0=[1;1;1;4]/sqrt(3);
%! P=[1;0;0;1];
%! epsilon=1e-3;
%! planar_line_data={
%! 		  ## alpha+t*rho+s*v
%! 		  ## t=lambda=focal_plane_depth
%! 		  [1,1,1;0,0,0;0,0,0]+1*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]+epsilon*randn(3,3)
%! 		  [1,1,1;0,0,0;0,0,0]+2*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]+epsilon*randn(3,3)
%! 		  [1,1,1;0,0,0;0,0,0]+3*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]+epsilon*randn(3,3)
%! 		  };
%! [P_hat,obj,info,iter,nf,lambda]=estimate_plane_from_lines(P0);
%! assert(P_hat,P,epsilon);

#  end of estimate_plane_from_lines.m 
