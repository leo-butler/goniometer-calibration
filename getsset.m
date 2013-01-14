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

function s = getsset (S,i,j,opt="rows")
  ## usage:  s = getsset (S,i,j,opt="rows")
  ##
  ## S = cell structure with cells `partition' and `data'
  ##     S.partition is a cell structure with n partitions
  ## i<= n is the partition number
  ## j = the particular subset
  ## Used in powersets
  p=S.partition{i};
  r=p(j,:);
  d=S.data;
  s=[];
  for k=1:columns(r)
    s=[s;d(r(k),:)];
  endfor
  if opt=="rows"
    s=reshape(s,1,rows(s)*columns(s));
  endif
  s;
endfunction

#  end of getsset.m 
