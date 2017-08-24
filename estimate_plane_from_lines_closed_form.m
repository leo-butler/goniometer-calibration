# -*- Mode: octave; Package: OCTAVE -*-
#
# $Id$
#
# Author: Leo Butler (l.butler@cmich.edu)
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


function [P,g] = estimate_plane_from_lines_closed_form ...
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
  try_assert(norm(B*focal_plane_normal - cov_pld_fd,2),0,max_assert_error);
  try_assert(norm(focal_plane_normal'*B*focal_plane_normal - cov_fd_fd,2),0,max_assert_error);

  ## compute "covariance" matrix C
  ## Cperp is the covariance restricted to the focal plane
  C=B - cov_pld_fd*cov_pld_fd'/cov_fd_fd;
  focal_plane_projection=eye(3)-focal_plane_normal*focal_plane_normal';
  Cperp=focal_plane_projection*C*focal_plane_projection;
  ## C should already equal Cperp!
  try_assert(norm(C-Cperp,2),0,max_assert_error);

  ## compute the eigenvalues/vectors
  [q,alpha]=eig(Cperp);
  [alphas,idx]=sort([alpha(1,1);alpha(2,2);alpha(3,3)],"descend");

  ## v is the direction vector of the lsq line
  v=q(:,idx(1));
  w=vector_product(focal_plane_normal,v); w/=norm(w,2);
  try_assert(abs(v'*focal_plane_normal),0,max_assert_error);

  ## cot(theta) where 0 <= theta < pi, so sin(theta) >= 0.
  cotheta= cov_pld_fd'*w/cov_fd_fd;
  sintheta=1/sqrt(1+cotheta^2);
  costheta=cotheta*sintheta;

  ## pi and rho
  p=costheta*focal_plane_normal - sintheta*w;
  r=sintheta*focal_plane_normal + costheta*w;

  ## frame g
  g=[p,v,r]';

  ## plane P
  kappa=p'*mean_planar_line_data;
  try_assert(kappa-(-sintheta*w'*mean_planar_line_data + costheta*mean_focal_depth),0,max_assert_error);
  try_assert(norm(mean_planar_line_data,2)^2 - kappa^2 - (mean_focal_depth-kappa*costheta)^2/sintheta^2>0,true);

  P=[p;kappa];
endfunction
%!shared focal_plane_normal, projection, epsilon, pld, v, w, rho, kappa, n, N, P
%! focal_plane_normal=[0;0;1];
%! projection=eye(3)-focal_plane_normal*focal_plane_normal';
%! pld=@(kappa,n,rho,v,N,s) cellfun(@(x) (kappa*n + rho*(x') + 10*v*randn(1,N) + s*projection*randn(3,N)), num2cell(ones(N,1)*(1:N),1), 'UniformOutput',false);
%!test
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
%! epsilon=1e-10;
%! planar_line_data=cellfun(@(x) x+epsilon*projection*randn(rows(x),columns(x)),planar_line_data,"UniformOutput",false);
%! [Phat,ghat]=estimate_plane_from_lines_closed_form(planar_line_data,focal_plane_depths,focal_plane_normal,epsilon);
%! assert(norm(Phat-P0,2),0,3*epsilon);
%! assert(norm(ghat-g0,2),0,3*epsilon);
%! assert(norm(ghat'*ghat-eye(3),2),0,3*epsilon);
%!test
%! rho=[0;1;-1]; rho/=norm(rho,2);
%! v=[1;0;0];  v/=norm(v,2);
%! n=vector_product(v,rho);
%! kappa=400;
%! P=[n;kappa]; N=50;
%! planar_line_data=pld(kappa,n,rho,v,N,0);
%! focal_plane_depths=cell2mat(cellfun(@(x) x(:,1)'*focal_plane_normal,planar_line_data,'UniformOutput',false));
%! [Phat,ghat]=estimate_plane_from_lines_closed_form(planar_line_data,focal_plane_depths,focal_plane_normal,epsilon)
%! assert(min(norm(P-Phat,2),norm(P+Phat,2)),0,epsilon)
## Randomized test
## we choose v perp to π, w=π ^ v, then choose cos(θ) in [0,1] and
## ρ = cos(θ) w + sin(θ) π.
## This determines the plane's normal vector n=π, then we choose the distance of the plane from
## 0, κ.
## Data is generated by increasing the coefficient on ρ, and choosing the coefficient on v randomly.
## Note that because the focal plane depth is constant (the coefficient on ρ is not randomized), the assertions in the octave function estimate_plane_from_lines_closed_form
## should hold.
%!xtest
%! v=[randn(2,1);0];  v/=norm(v,2);
%! w=vector_product(focal_plane_normal,v); w/=norm(w,2);
%! c=rand(1); s=sqrt(1-c^2);
%! rho=s*focal_plane_normal+c*w;
%! n=vector_product(v,rho);
%! kappa=100*randn(1);
%! P=[n;kappa]
%! N=50;
%! planar_line_data=pld(kappa,n,rho,v,N,0);
%! focal_plane_depths=cell2mat(cellfun(@(x) x(:,1)'*focal_plane_normal,planar_line_data,'UniformOutput',false));
%! [Phat,ghat]=estimate_plane_from_lines_closed_form(planar_line_data,focal_plane_depths,focal_plane_normal,epsilon)
%! assert(min(norm(P-Phat,2),norm(P+Phat,2)),0,epsilon)
## In this test, we add extra noise to the data so it does not lie exactly on the plane P
## We expect failure at the error level of epsilon.
%!xtest
%! planar_line_data=pld(kappa,n,rho,v,N,1);
%! focal_plane_depths=cell2mat(cellfun(@(x) x(:,1)'*focal_plane_normal,planar_line_data,'UniformOutput',false));
%! [Phat,ghat]=estimate_plane_from_lines_closed_form(planar_line_data,focal_plane_depths,focal_plane_normal,epsilon)
%! try
%!  assert(min(norm(P-Phat,2),norm(P+Phat,2)),0,epsilon)
%! catch
%!  "Error: distance is", min(norm(P-Phat,2),norm(P+Phat,2))
%!  P
%!  Phat
%! end_try_catch

## end of estimate_plane_from_lines_closed_form.m
