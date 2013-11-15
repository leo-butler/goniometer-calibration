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
function y = to_spherical_coordinates (x,degrees=false)
  y=zeros(2,columns(x));
  # polar angle
  y(2,:)=acos(x(3,:));
  # azimuthal angle
  y(1,:)=atan2(x(2,:),x(1,:));
  if degrees
    y=y*180/pi;
  endif
endfunction
#  end of to_spherical_coordinates.m 
