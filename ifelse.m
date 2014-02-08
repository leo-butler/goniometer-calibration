## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id$
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

function b = ifelse (varargin)
  ## usage:  b = ifelse (varargin)
  ##
  ## varargin = Prop1,Consequence1,...,PropN,ConsequenceN,DefaultConsequence
  ## We evaluate each proposition in turn, until a true (!=0) one is found
  ## at which point the consequence is returned. If unspecified, the
  ## DefaultConsequence ('else') is 0.
  #varargin
  lenp=length(varargin);
  if lenp==1
    b=varargin{1};
  elseif varargin{1}
    b=varargin{2};
  elseif lenp>2
    b=ifelse(varargin{3:lenp});
  else
    b=0;
  endif
endfunction
%!test
%! assert(ifelse(1,2),2)
%! assert(ifelse(1,2,3),2)
%! assert(ifelse(0,2,3),3)
%! assert(ifelse(0,2,0,3,1,4),4)
%! assert(ifelse(0,2,0,3,1),1)

## end of ifelse.m
