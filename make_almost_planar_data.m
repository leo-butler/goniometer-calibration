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

function [y,n]=make_almost_planar_data(v1,v2,p,k,sigma,grid=1,rows=1)
  ## [y,n]=make_almost_planar_data(v1,v2,p,k,sigma,grid=1,rows=1)
  ##
  ## v1, v2 are independent 3-vectors parallel to plane P
  ## p is a 3-vector in P
  ## k is number of points
  ## sigma is std. dev. of errors
  ## grid, if 1 makes points gaussian plus grid
  ## row, if 1 makes the 3 vectors row vectors
  ##
  ## y is k x 3 (row=1) vector of points close to P
  ## n is a unit normal to P
  n=xp(v1,v2);
  n=n/norm(n);
  if grid==1
    c=1;
    if mod(k,2)==0 || k<3
      "warning: With grid==1, k must be odd, >2."
      k=max(2,k)+1;
    endif
    if !(ismember(k, (2*(1:k)+1).^2))
      error("k must be of the form (2*j+1)^2.")
    else
      k=(sqrt(k)-1)/2;
    endif
    for i=-k:k
      for j=-k:k
	y(c,1:3)=p+i*v1+j*v2+sigma*randn(3,1);
	++c;
      endfor;
    endfor;
  else
    for i=1:k
      y(i,1:3)=p+randn(1,1)*v1+randn(1,1)*v2+sigma*randn(3,1);
    endfor;
  endif;
  if rows==1
    n=n';
    [y;n];
  else
    y=y';
    [y,n];
  endif
endfunction
%!test
%! load randstate.m
%! randn("state",randstate);
%! v1=[1;0;0];v2=[0;1;0];p=[1;2;3];k=9;sigma=1e-10;grid=1;rows=1;
%! [y,n]=make_almost_planar_data(v1,v2,p,k,sigma,grid,rows);
%! assert(size(y),[k,3])
%! assert(norm(y-round(y)),0,1e3*sigma)  #this test should succeed with prob=1
%!test
%! load randstate.m
%! randn("state",randstate);
%! v1=[1;0;0];v2=[0;1;0];p=[1;2;3];k=2;sigma=1e-1;grid=0;rows=1;
%! [y,n]=make_almost_planar_data(v1,v2,p,k,sigma,grid,rows);
%! ye=[0.269090,1.104408,2.928171;   1.146020,-0.092854,3.008971];
%! assert(size(y),[k,3])
#%1 assert(norm(y-ye),0,1e-6)


##
##
## end of make_almost_planar_data.m
