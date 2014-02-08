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


function focal_depths = get_focal_depths (p,tolerance=1e-6)

  ## usage:  focal_depths = get_focal_depths (p)
  ##
  ## p = n x 3 data vector segregated by focal plane depth
  ## focal_depths = vector of focal depths
  global focal_plane_normal_t;
  focal_depths=unique(focal_plane_normal_t*p);
endfunction

#  end of get_focal_depths.m 
