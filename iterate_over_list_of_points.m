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

function t = iterate_over_lists_of_points (fnh,P,partition,opt="rows",is_str=0,rs=0,c=0,iolop_state=[])
  ## usage:  t = iterate_over_lists_of_points (fnh,P,partition)
  ##
  ## fnh = a function handle
  ## P   = 3 x n matrix
  ## partition = a partition of P into distinct planes
  ## 
  ## the function fnh should take columns(partition) arguments
  ## e.g.
  ## P = [1,1,1,1;3,1,4,2;1,2,4,5]; partition=[2;2]
  global show_iolop_state
  if is_str==0
    P=powersets(P,partition,opt);
    rs=cellfun(@rows,P.partition);
    c=columns(partition);
    t=iterate_over_lists_of_points(fnh,P,partition,opt,1,rs,c,iolop_state);
  elseif is_str==c+1
    if show_iolop_state
      iolop_state
    endif
    t=fnh(iolop_state);
    iolop_state=[];
  else
    i=is_str;
    t=0;
    for j=1:rs(i)
      s=getsset(P,i,j);
      t=t+iterate_over_lists_of_points(fnh,P,partition,opt,i+1,rs,c,[iolop_state,s]);
    endfor
  endif
endfunction
%!test
%! partition=[2,2,4;1,2,2];
%! data=reshape(1:32,8,4);
%! assert(iterate_over_lists_of_points(@(x) 1,data,partition), 12) #count #elements
%!test
%! partition=[1,1;1,1];
%! data=ones(2,1);
%! assert(iterate_over_lists_of_points(@(x) x*x',data,partition), 2) #count #elements
%!test
%! partition=[3,3;1,1];
%! data=5*ones(6,1);
%! assert(iterate_over_lists_of_points(@(x) x*x',data,partition), 2 * 5^2 * 3^2) #count #elements
%! f=@(x) x*x';
%! assert(iterate_over_lists_of_points(f,data,partition), 2 * 5^2 * 3^2)
## WARNING! SLOW
%!test
%! partition=[2,3,4;2,2,2];
%! data=[ones(2,4);ones(3,4)*2;ones(4,4)*5];
%! N=binomial(2,2)*binomial(3,2)*binomial(4,2);
%! assert(iterate_over_lists_of_points(@(x) 1,data,partition), N) #count #elements
%! assert(iterate_over_lists_of_points(@ssq,data,partition), 2*(1^2*4 + 2^2*4 + 5^2*4)*N)
%!test
%! partition=[3,3;3,3];
%! a=0;
%! data=[1,0,0;0,1,0;2,1,0; a,0,1;0,1,1;a,2,3];
%! L=[1,0,0;0,1,0];
%! assert(iterate_over_lists_of_points(@(x) 1,data,partition), 1)
%! assert(iterate_over_lists_of_points(@(x) x,data,partition), [reshape(data(1:3,:),1,9),reshape(data(4:6,:),1,9)])
%! assert(iterate_over_lists_of_points(@(x) x(1:9),data,partition), reshape(data(1:3,:),1,9))
%! assert(iterate_over_lists_of_points(@(x) plane(x(1:9)),data,partition), plane(data(1,:),data(2,:),data(3,:)))
%! assert(iterate_over_lists_of_points(@(x) [plane(x(1:9)),plane(x(10:18))],data,partition), [plane(data(1,:),data(2,:),data(3,:)),plane(data(4,:),data(5,:),data(6,:))], 1e-8)
%! assert(iterate_over_lists_of_points(@(x) line_obj(intersection_line(plane(x(1:9)),plane(x(10:18))),L),data,partition), 1)
%!xtest
%! data=reshape(1:18,6,3) .^3;
%! partition=[3,3;3,3];
%! assert(iterate_over_lists_of_points(@(x) [plane(x(1:9)),plane(x(10:18))],data,partition), [plane(data(1,:),data(2,:),data(3,:)),plane(data(4,:),data(5,:),data(6,:))], 1e-8)

#  end of iterate_over_list_of_points.m 
