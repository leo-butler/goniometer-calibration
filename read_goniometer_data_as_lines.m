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

function plane = read_goniometer_data_as_lines (filename)
  ## usage:  plane = read_goniometer_data_as_lines (filename)
  ##
  ## plane = struct containing z-values and array of matrices
  ##         with points on lines
  p=read_goniometer_data(filename,"csv");
  plane=separate_planar_data_into_lines(p);
  plane.filename=filename;
endfunction
%!test
%! filename="~/svn-ecdf/goniometer-calibration/dir+/deg-45-zyx.csv";
%! filename="gtest.csv";
%! plane=read_goniometer_data_as_lines(filename);
%! plane_exp.filename=filename;
%! plane_exp.z=[85019];
%! (plane_exp.lines){1}=[
%!			  362.800,1.900,85019;
%!			  468.278,1.056,85019;
%!			  1239.917,3.708,85019;
%!			  724,3,85019;
%!			  1725.133,6.533,85019;
%!			  2040.667,5.167,85019;
%!			  1877.426,7.944,85019;
%!			  522.750,6.750,85019;
%!			  662,9.318,85019;
%!			  1274.660,11.180,85019];
%! assert(plane,plane_exp);

##  end of read_goniometer_data_as_lines.m 
