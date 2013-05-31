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
## usage:  s = fom_plane_from_lines (P)
##
## P  = [n;c] is a plane in R^3 = {x | <n,x> = c}
##  n = 3x1 unit column vector
##  c = scalar
## 
## 
## Globals:
## 
function s = fom_plane_from_lines (P)
  global focal_plane_depths;
  global planar_line_data;
  global focal_plane_normal;
  global focal_plane_normal_t;
  s = 0;
  ## decompose P
  n = P(1:3); n/=norm(n,2);
  c = P(4);
  ## determine the common direction vector v of the parallel lines
  v = vector_product(n,focal_plane_normal);
  v /= norm(v,2);
  ## determine the direction vector of the line orthogonal to the
  ## parallels
  rho = focal_plane_normal - projection_onto_vector(n,focal_plane_normal);
  rho /= norm(rho,2);

  l=length(focal_plane_depths);
  for i=1:l
    f=focal_plane_depths(i);
    ## determine scalar
    t = f - c*(focal_plane_normal_t*n);
    t /= focal_plane_normal_t*rho;
    ## determine point of line; p is orthogonal to v
    p = c*n + t*rho;
    N = columns(planar_line_data{i});
    new = 1;
    r = 0;
    for x=planar_line_data{i}
      r += dp2l(x,p,v,new)^2;
      new = 0;
    endfor
    r /= N;
    s += r;
  endfor
  s /= l;
endfunction
%!test
%! global focal_plane_depths;
%! global planar_line_data;
%! global focal_plane_normal;
%! focal_plane_depths=[1;1];
%! planar_line_data={[1,1;0,1;0,0],[1,1;0,1;0,0]};
%! focal_plane_normal=[0;0;1];
%! P=[0;1;0;0];
%! assert(fom_plane_from_lines(P),1.5,1e-8);
%!test
%! global focal_plane_depths;
%! global planar_line_data;
%! global focal_plane_normal;
%! focal_plane_depths=[1];
%! planar_line_data{1}=[1,2;1,2;1,2];
%! focal_plane_normal=[0;0;1];
%! P=[1;0;0;0];
%! assert(fom_plane_from_lines(P),3,1e-8)
%!test
%! global focal_plane_depths;
%! global planar_line_data;
%! global focal_plane_normal;
%! focal_plane_normal=[0;0;1];
%! focal_plane_depths=[1;2;3];
%! P=[1;0;0;1];
%! planar_line_data={
%! 		  ## alpha+t*rho+s*v
%! 		  ## t=lambda=focal_plane_depth
%! 		  [1,1,1;0,0,0;0,0,0]+1*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]
%! 		  [1,1,1;0,0,0;0,0,0]+2*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]
%! 		  [1,1,1;0,0,0;0,0,0]+3*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]
%! 		  };
%! assert(fom_plane_from_lines(P),0)
%!test
%! global focal_plane_depths;
%! global planar_line_data;
%! global focal_plane_normal;
%! focal_plane_normal=[0;0;1];
%! focal_plane_depths=[1;2;3];
%! P=[1;0;0;1];
%! planar_line_data={
%! 		  ## alpha+t*rho+s*v
%! 		  ## t=lambda=focal_plane_depth
%! 		  [1,1,1;0,0,0;0,0,0]+1*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]+eye(3)
%! 		  [1,1,1;0,0,0;0,0,0]+2*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]+eye(3)
%! 		  [1,1,1;0,0,0;0,0,0]+3*[0,0,0;0,0,0;1,1,1]+[0;-1;0]*[-1,2,3]+eye(3)
%! 		  };
%! # distance computed by hand:
%! assert(fom_plane_from_lines(P),2/3,1e-8)



global planar_line_data;
global focal_plane_normal;
global focal_plane_normal_t;
global focal_plane_depths;
focal_plane_normal=[0;0;1];
focal_plane_normal_t=focal_plane_normal';

#  end of fom_plane_from_lines.m 
