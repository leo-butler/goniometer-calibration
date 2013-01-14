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

function [s,c] = covariance (x,y=x,use_full_sample_mean=1)
  ## usage:  [s,c] = covariance (x,y=x,use_full_sample_mean=1)
  ##
  ## x,y = cell structure of n x m_i, m_i x s matrices
  ## s = sum_i (x{i}-xbar{i})*(y{i}-ybar{i})'
  ## if use_full_sample_mean=1, then xbar,ybar is the mean of the means of x{i},y{i};
  ## otherwise, we use the individual sample means
  s = 0;
  n = length(x);
  xbar=cellfun(@(t) mean(t,2),x,"UniformOutput",false);
  ybar=cellfun(@(t) mean(t,2),y,"UniformOutput",false);
  if use_full_sample_mean==1
    xm = 0;
    ym = 0;
    for i=1:n
      xm += xbar{i};
      ym += ybar{i};
    endfor
    xm/=n;
    ym/=n;
    xbar=cellfun(@(t) xm*ones(1,columns(t)),x,"UniformOutput",false);
    ybar=cellfun(@(t) ym*ones(1,columns(t)),y,"UniformOutput",false);
  else
    for i=1:n
      xbar{i}*=ones(1,columns(x{i}));
      ybar{i}*=ones(1,columns(y{i}));
    endfor
  endif
  for i=1:n
    m = columns(x{i});
    c{i} = (x{i}-xbar{i})*(y{i}-ybar{i})';
    c{i} /= m;
    s += c{i};
  endfor
  s /= n;
endfunction
%!test
%! n=1e6
%! A=diag([1,2,4]);A=randn(3,3); A=A'*A; A*A
%! m=cellfun(@(x) randn(3,1)*ones(1,n),{1,2,3},"UniformOutput",false);
%! x=cellfun(@(x) A*randn(3,n)+m{x},{1,2,3},"UniformOutput",false);
%! [s,c]=covariance(x,x,0)
%! assert(norm(s-A*A,2),0,10*norm(A,2)/sqrt(n))
%! m=randn(3,1)*ones(1,n);
%! x=cellfun(@(x) A*randn(3,n)+m,{1,2,3},"UniformOutput",false);
%! [s,c]=covariance(x)
%! assert(norm(s-A*A,2),0,10*norm(A,2)/sqrt(n))
## end of covariance.m