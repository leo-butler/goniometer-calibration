function b = ifelse (P)
  ## usage:  b = ifelse (P)
  ##
  ## P = [Prop1,Consequence1,...,PropN,ConsequenceN,DefaultConsequence]
  ## We evaluate each proposition in turn, until a true (!=0) one is found
  ## at which point the consequence is returned. If unspecified, the
  ## DefaultConsequence ('else') is 0.
  lenp=length(P);
  if lenp==1
    b=P(1);
  elseif P(1)
    b=P(2);
  elseif lenp>2
    b=ifelse(P(3:lenp));
  else
    b=0;
  endif
endfunction