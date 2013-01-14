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

function S = powersets (s,partition,opt="rows")
  ## usage:  S = powersets (s,partition,opt="rows")
  ##
  ## s         = r x c matrix = set of r vectors of length c
  ## partition = 2 x s matrix of partition + choices
  ## S         = cell array of powersets of s given partition
  npartitions=columns(partition);
  Q=(1:sum(partition(1,:)))';
  b=1;
  f=0;
  for i=1:npartitions
    f=f+partition(1,i);
    S.partition{i}=powerset(Q(b:f),partition(2,i));
    b=f+1;
  endfor
  S.data=s;
endfunction
%!test
%! S=powersets((1:6)' , [6;3]);
%! assert(rows(S.partition{1}),binomial(6,3))
%!test
%! partition=[2,2,4;1,2,2];
%! data=(9:16)';
%! S=powersets(data , partition);
%! assert(cellfun(@rows,S.partition),binomial(partition))
%! assert(S.data,data)
%! assert(getsset(S,1,1),[9]);
%! assert(getsset(S,2,1),[11,12]);
%! assert(getsset(S,3,4),[14,15]);
%!test
%! partition=[2,2,4;1,2,2];
%! data=reshape(1:32,8,4);
%! S=powersets(data , partition);
%! assert(cellfun(@rows,S.partition),binomial(partition))
%! assert(S.data,data)
%! assert(getsset(S,1,1),data(1,:))
%! assert(getsset(S,2,1),reshape(data(3:4,:),1,8))
%! assert(getsset(S,3,3),reshape([data(5,:);data(8,:)],1,8))
%! assert(getsset(S,3,3,0),[data(5,:);data(8,:)])

#  end of powersets.m 
