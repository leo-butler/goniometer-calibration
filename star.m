# -*- Mode: octave; Package: OCTAVE -*-
#
# $Id$
#
# Author: Leo Butler (l.butler@ed.ac.uk)
#
# This file is OCTAVE code (http://www.octave.org/)
# 
# It is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or (at your
# option) any later version.
# 
# This software is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
# License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this file. If not, see http://www.gnu.org/licenses/. 
#

function y = star (x)
  ## usage:  y = star (x)
  ##
  ## return the 3x3 matrix y s.t. y*t = vector_product(x,t)
  y = -[0,x(3),-x(2);-x(3),0,x(1);x(2),-x(1),0];
endfunction
%!test
%! e1=[1;0;0];e2=[0;1;0];e3=[0;0;1];
%! t=randn(3,1);
%! y1=star(e1);
%! y2=star(e2);
%! y3=star(e3);
%! assert(norm(vector_product(e1,t)-y1*t,2),0,1e-8);
%! assert(norm(vector_product(e2,t)-y2*t,2),0,1e-8);
%! assert(norm(vector_product(e3,t)-y3*t,2),0,1e-8);

## end of star.m
