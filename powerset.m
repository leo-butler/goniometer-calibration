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
      S=reshape(s',1,r*c);
    else
      S=s;
    endif
  elseif r>n
    for i=1:r
      Sd=rowdiff(s,i);
      S=[S;powerset(Sd,n,opt)];
    endfor
    if opt=="rows"
      S=unique(S,"rows");
    endif
  else
    S=[];
  endif
  S;
endfunction
%!test
%!shared x, p
%! x=(1:3)';
%! p=[1,2;1,3;2,3];
%! assert(powerset(x,2),p)
%!test
%! assert(powerset(x,2,0),[2;3;1;3;1;2])
%!test
%! x=(1:6)';
%! assert(size(powerset(x,5)),[6,5])
%!test
%! assert(size(powerset(x,3)),[binomial(6,3),3])
%!test
%! P=[0,0,1,0; 0,2,0,0; 3,0,0,0];
%! Ps=[0,0,1,0,0,2,0,0; 0,0,1,0,3,0,0,0; 0,2,0,0,3,0,0,0];
%! assert(powerset(P,2),Ps);


#  end of powerset.m 
