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


function P = plane_basis (V)
  ## usage:  P = plane_basis (V)
  ##
  ## V = 9x1 pair of 3x1 orthogonal unit vectors and a point 3x1
  n=vector_product(V(1:3),V(4:6));
  n=n/norm(n,2);
  c=V(7:9)'*n;
  P=[n;c];
endfunction

#  end of plane_basis.m 
