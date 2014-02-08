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

function L = intersection_lines (P, choices=false, unoriented=true)
  ## usage:  L = intersection_lines (P)
  ##
  ## P= 4 x c matrix whose columns are planes
  ## L= 6 x C matrix of lines which are the pairwise intersection of the planes in P
  ## C is c choose 2
  if unoriented
    uol=@(L) unoriented_line(L);
  else
    uol=@(L) L;
  endif
  c=columns(P);
  if isscalar(choices)
    choices=nchoosek(1:c,2);
  endif
  C=rows(choices);
  L=zeros(6,C);
  j=1;
  for i=choices'
    p=reshape(P(:,i(1,1)),4,1);
    q=reshape(P(:,i(2,1)),4,1);
    L(:,j)=uol(reshape(intersection_line(p,q)',6,1));
    j++;
  endfor
endfunction
%!test
%! P=eye(4);
%! P=P(:,1:3);
%! Lexp=[
%!	 0,   0,   0;
%!	 0,   0,   0;
%!	 0,   0,   0;
%!	 0,   0,   1;
%!	 0,  -1,   0;
%!	 1,   0,   0];
%! L=intersection_lines(P,false,false);
%! assert(norm(L-Lexp,2),0,1e-16);

#  end of intersection_lines.m 
