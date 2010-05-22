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


function y = rowdiff (a,i)
  ## usage:  y = rowdiff (a,i)
  ##
  ## given a matrix a with r rows, removes the i-th row
  if size(a)==0
    y = a;
  endif
  r = rows(a);
  if i<0 || i>r
    error("rowdiff(a,i): i < 0 or i > rows(a).")
  elseif i==1
    y = a(2:r,:);
  elseif i==r
    y = a(1:r-1,:);
  else
    y = [a(1:i-1,:); a(i+1:r,:)];
  endif
endfunction


function S = powerset (s,n,opt="rows")
  ## usage:  S = powerset (s,n,opt="rows")
  ##
  ## s = r x c matrix = set of r vectors of length c, r>=n
  ## n = number of rows to be retained
  ## opt = if "rows" then each collection of n rows is output as
  ##       a single row; otherwise, the rows are stacked
  ## S = collection of all collections of n distinct rows in s
  r=rows(s);
  S=[];
  if r==n
    c=columns(s);
    if opt=="rows"
      S=reshape(s,1,r*c);
    else
      S=s;
    endif
  elseif r>n
    for i=1:r
      Sd=rowdiff(s,i);
      S=[S;powerset(Sd,n,opt)];
    endfor
  else
    S=[];
  endif
  S;
endfunction


function t=obj(alpha)
  ## An affine plane P in R^3 is determined uniquely by a unit normal n
  ## and constant c. The pair (n,c) is determined by P up to +-1.
  ##
  ## P : <n,x>=c  <==> (n,c)
  ##
  ## Objective function alpha[n;c]:
  ## 1/N\sum_i^N |<x_i,n>-c|^2
  global sample_data;
  x=feval(sample_data);
  N=rows(x);
  c=alpha(4);
  n=alpha(1:3);
  n=n/norm(n);
  t=norm(x*n-c)^2/N;
endfunction

function t=norm_constraint(alpha)
  ## alpha=[n;c]
  ## return |n|-1
  t=norm(alpha(1:3))-1;
endfunction

function v=xp(a,b)
  ## vector product
  v=[a(2)*b(3)-a(3)*b(2);-a(1)*b(3)+a(3)*b(1);a(1)*b(2)-a(2)*b(1)];
endfunction
