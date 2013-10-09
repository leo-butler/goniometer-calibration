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

function estimate = mc_planar_line_estimate (planes,focal_depths,focal_plane_normal,N=10,sigma=1)
  pld=mc_planar_line_data(planes,focal_depths,focal_plane_normal,N,sigma);
  estimate.planar_line_data_str=pld;
  ## l = best fit line
  ## L = pairwise intersections of best fit planes
  ## P = best fit planes
  ## G = best fit frames of planes
  [l,L,P,G] = estimator_closed_form(pld,focal_plane_normal,1e-9,1);
  estimate.estimate=struct("l",l,"L",L,"P",P,"G",G);
endfunction
%!shared planes, focal_depths, focal_plane_normal, epsilon, sigma, N
%!test
%! N=2; sigma=1e-1; epsilon=5*sigma;
%! planes=[1,0,0,1; 0,1,0,3]';
%! focal_depths={[0,1], [0,1]};
%! focal_plane_normal=[0;0;1];
%! estimate=mc_planar_line_estimate(planes,focal_depths,focal_plane_normal,N,sigma)
%! Pexp=planes;
%! P=estimate.estimate.P;
%! assert(dptp(P(:,1),Pexp(:,1)) + dptp(P(:,2),Pexp(:,2)),0,epsilon)
%! lexp=[1;3;0;0;0;-1]; l=estimate.estimate.l;
%! assert(norm(l-lexp,2),0,epsilon);
%!test
%! N=2; sigma=1e-1*diag([1,100]);
%! planes=[[1,1,1,sqrt(3)]/sqrt(3); [1,-2,1,2*sqrt(6)]/sqrt(6)]';
%! s=500; focal_depths=cellfun(@(x) s*(1:4), {1,2}, 'UniformOutput', false);
%! focal_plane_normal=[0;0;1];
%! estimate=mc_planar_line_estimate(planes,focal_depths,focal_plane_normal,N,sigma)
%! Pexp=planes;
%! P=estimate.estimate.P;
%! try
%! assert(dptp(P(:,1),Pexp(:,1)) + dptp(P(:,2),Pexp(:,2)),0,1e-2)
%! catch
%!  "Error: in planes", P, Pexp
%! end_try_catch
## from Maxima
%! lexp=[[(sqrt(6)+sqrt(3))/3;(sqrt(3)-2*sqrt(6))/3;(sqrt(6)+sqrt(3))/3]; -[-1;0;1]/sqrt(2)];
%! l=estimate.estimate.l;
%! try
%! assert(norm(l-lexp,2),0)
%! catch
%!  "Error: in lines", l, lexp, norm(l-lexp,2)
%! end_try_catch

#  end of mc_planar_line_estimate.m 
