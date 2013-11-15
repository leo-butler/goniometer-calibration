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

## this gives the correct euler angles for cos(b)#0 or -%pi<2*b<%pi
function [y,a,b,c] = euler_angles (x,degrees=false)
  a=atan2( x(2,1),x(1,1) );
  b=atan2( -x(3,1),sqrt(x(3,2)^2+x(3,3)^2) );
  c=atan2( x(3,2),x(3,3) );
  y=[a;b;c];
  if degrees
    y=y*180/pi;
  endif
endfunction
## for tests, see euler_matrix.m

#  end of euler_angles.m 
