## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id: emacs-octave.el,v 1.3 2010-05-28 16:50:15 lbutler Exp $
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

source objectivefn.m

function t = acos_plot (dx=0.1)
  ## usage:  t = acos_plot ()
  ##
  ## 
  subplot(2,1,1);
  x=-pi:dx:pi;
  cosx=cos(x);
  plot(cosx,sin(x));
  subplot(2,1,2);
  l=zeros(1,length(x));
  i=1;
  for y=cosx
    l(i)=arclengthsq(y);
    i=i+1;
  endfor
  plot(x,l);
  t=1;
endfunction

#  end of acos_plot.m 
