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
function r = euler_coordinates (L)
  x=zeros(3,3);
  x(:,1)=L(4:6);
  x(:,2)=L(1:3);
  s=norm(L(1:3),2);
  x(:,2)/=s;
  x(:,3)=vector_product(x(:,1),x(:,2));
  r=[euler_angles(x);s];
endfunction
#  end of euler_coordinates.m 
