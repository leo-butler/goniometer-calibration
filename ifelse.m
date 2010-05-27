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

