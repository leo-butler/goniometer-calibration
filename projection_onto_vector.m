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
## usage:  v = projection_onto_vector (x,y)
##
## v = the projection of the vector y onto the unit vector x
##
function w = projection_onto_vector (x,y)
  w = (x'*y)*x ;
endfunction
%!test
%! assert(projection_onto_vector([1;0;0],[3;1;-3]),[3;0;0]);
%! assert(projection_onto_vector([1;-1;1]/sqrt(3),[3;1;3]),[1;-1;1]/3*5,1e-8);

#  end of projection_onto_vector.m 
