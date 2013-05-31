## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id$
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

source objectivefn.m

function t = line_plot ()
  ## usage:  t = line_plot ()
  ##
  ## 
  global objectivefn_data objectivefn_partition;
  symbols='+*ox^';
  len=objectivefn_partition(1,:);
  b=1;
  f=0;
  hold off;
  for i=1:length(len)
    f=f+len(i);
    plot3(objectivefn_data(b:f,1),objectivefn_data(b:f,2),objectivefn_data(b:f,3),symbols(i));
    hold on;
    b=f+1;
  endfor
  hold off;
  t=1;
endfunction

## end of line_plot.m

