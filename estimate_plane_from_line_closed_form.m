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

function [P,g] = estimate_plane_from_line_closed_form ...
      (planar_line_data,focal_plane_depths,focal_plane_normal,max_assert_error=1e-16)
  ## usage:  [P,g] = estimate_plane_from_line_closed_form
  ## (planar_line_data,focal_plane_depths,focal_plane_normal)
  ##
  ## estimate a least-squares plane P from data organized along
  ## parallel, co-planar lines, g is an orthonormal frame with columns
  ## pi (=normal to P), v (=direction vector of lines), rho (=direction
  ## vector of points on lines)
  ##
  ## This function handles the degenerate case where the
  ## focal_plane_normal lies in the plane, so the plane appears to be a
  ## single line

  ## compute mean focal depth
  mean_focal_depth=mean(focal_plane_depths);

  ## B is the covariance matrix, weighted by focal depths
  B=covariance(planar_line_data);
  
  ## 
  [v,alpha]=eigs(B,1,'lm');
  v/=norm(v,2);

  p=vector_product(v,focal_plane_normal);
  p/=norm(p,2);

  r=focal_plane_normal;
  g=[p,v,r];

  kappa=mean_focal_depth;
  P=[p;kappa];
endfunction
%!test
%! error_tol=1e-8;
%! focal_depths=10; s=2;
%! pld=diag([s,1,0])*randn(3,30); pld(3,:)=focal_depths;
%! planar_line_data{1}=pld;
%! focal_plane_normal=[0;0;1];
%! [P,g]=estimate_plane_from_line_closed_form(planar_line_data,[focal_depths],focal_plane_normal)
%! assert(abs(det(g)-1),0,error_tol)
%! assert(norm(g'*g-eye(3),"fro"),0,error_tol)
%! assert(abs(P(4)-focal_depths),0,error_tol)
%! assert(abs(P(1:3)'*focal_plane_normal),0,error_tol)
%! hold on; clf();
%! v=g(:,2); p=mean(pld')'; #p=p-v*(v'*p)
%! pv=p+v*(-s:s)*2; pv=pv';
%! plot(pld(1,:),pld(2,:),"+",pv(:,1),pv(:,2))
%! hold off

#  end of estimate_plane_from_line_closed_form.m 
