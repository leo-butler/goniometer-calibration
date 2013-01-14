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


function [P,g] = estimate_plane_from_lines_closed_form \
      (planar_line_data,focal_plane_depths,focal_plane_normal,max_assert_error=1e-16)
  ## usage:  [P,g] = estimate_plane_from_lines_closed_form
  ##  (planar_line_data,focal_plane_depths,focal_plane_normal)
  ##
  ## estimate a least-squares plane P from data organized along
  ## parallel, co-planar lines, g is an orthonormal frame with columns
  ## pi (=normal to P), v (=direction vector of lines), rho (=direction
  ## vector of points on lines)

  ## compute mean focal depth
  mean_focal_depth=mean(focal_plane_depths);

  ## compute covariance between focal depths and mean of planar line data
  planar_line_data_means=cellfun(@(x) mean(x,2),planar_line_data,"UniformOutput",false);
  mean_planar_line_data=0;
  cov_pld_fd=0;
  cov_fd_fd=0;
  n=length(planar_line_data);
  for i=1:n
    mean_planar_line_data+=planar_line_data_means{i};
    cov_fd_fd+=(focal_plane_depths(i)-mean_focal_depth)^2;
  endfor
  mean_planar_line_data/=n;
  cov_fd_fd/=n;
  for i=1:n
    cov_pld_fd += (focal_plane_depths(i)-mean_focal_depth)*(planar_line_data_means{i}-mean_planar_line_data);
  endfor
  cov_pld_fd/=n;

  ## B is the covariance matrix, weighted by focal depths
  B=covariance(planar_line_data);
  ## the covariances computed above should be obtainable from B and the focal_plane_normal:
  assert(norm(B*focal_plane_normal - cov_pld_fd,2),0,max_assert_error);
  assert(norm(focal_plane_normal'*B*focal_plane_normal - cov_fd_fd,2),0,max_assert_error);

  ## compute "covariance" matrix C
  ## Cperp is the covariance restricted to the focal plane
  C=B - cov_pld_fd*cov_pld_fd'/cov_fd_fd;
  focal_plane_projection=eye(3)-focal_plane_normal*focal_plane_normal';
  Cperp=focal_plane_projection*C*focal_plane_projection;
  ## C should already equal Cperp!
  assert(norm(C-Cperp,2),0,max_assert_error);

  ## compute the eigenvalues/vectors
  [q,alpha]=eig(Cperp);
  [alphas,idx]=sort([alpha(1,1);alpha(2,2);alpha(3,3)],"descend");

  ## v is the direction vector of the lsq line
  v=q(:,idx(1));
  w=vector_product(focal_plane_normal,v);

  ## cot(theta) where 0 <= theta < pi, so sin(theta) >= 0.
  cotheta=-cov_pld_fd'*w/cov_fd_fd;
  sintheta=1/sqrt(1+cotheta^2);
  costheta=cotheta*sintheta;

  ## pi and rho
  p=costheta*focal_plane_normal - sintheta*w;
  r=sintheta*focal_plane_normal + costheta*w;

  ## frame g
  g=[p,v,r]';

  ## plane P
  kappa=p'*mean_planar_line_data;
  assert(kappa-(-sintheta*w'*mean_planar_line_data + costheta*mean_focal_depth),0,max_assert_error);

  P=[p;kappa];
endfunction
%!test
%! focal_plane_normal=[0;0;1];
%! focal_plane_depths=[1;2;3];
%! planar_line_data={
%! 		  ## alpha+t*rho+s*v
%! 		  ## t=lambda=focal_plane_depth
%! 		  [1,1,1;0,0,0;0,0,0]+1*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]
%! 		  [1,1,1;0,0,0;0,0,0]+2*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]
%! 		  [1,1,1;0,0,0;0,0,0]+3*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]
%! 		  };
%! P0=[1;0;0;1];
%! g0=eye(3);
%! [Phat,ghat]=estimate_plane_from_lines_closed_form(planar_line_data,focal_plane_depths,focal_plane_normal);
%! assert(norm(Phat-P0,2),0,1e-8);
%! assert(norm(ghat-g0,2),0,1e-8);
%! epsilon=1e-1;
%! projection=eye(3)-focal_plane_normal*focal_plane_normal';
%! planar_line_data=cellfun(@(x) x+epsilon*projection*randn(rows(x),columns(x)),planar_line_data,"UniformOutput",false);
%! [Phat,ghat]=estimate_plane_from_lines_closed_form(planar_line_data,focal_plane_depths,focal_plane_normal)
%! assert(norm(Phat-P0,2),0,3*epsilon);
%! assert(norm(ghat-g0,2),0,3*epsilon);
%! assert(norm(ghat'*ghat-eye(3),2),0,3*epsilon);


## end of estimate_plane_from_lines_closed_form.m