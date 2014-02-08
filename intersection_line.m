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
## usage:  L = intersection_line (P,Q)
##
## P,Q = planes in R^3
## L   = the intersection line of P and Q
## 
## * a plane is represented by [a,b,c,d] where n=[a,b,c] is a
## unit normal and P: <n,x>=d;
## * a line is represented by a 2 x 3 matrix, the first row
## is the point closest to 0 and the second is a unit direction
## vector
function L = intersection_line (P,Q)
  warning("on","Octave:divide-by-zero");
  warning("error","Octave:divide-by-zero");
  try
    L = [-((P(1)*P(3)*Q(3)+P(1)*P(2)*Q(2)+(-P(3)^2-P(2)^2)*Q(1))*Q(4)-P(1)*P(4)*Q(3)^2+P(3)*P(4)*Q(1)*Q(3)-P(1)*P(4)*Q(2)^2+P(2)*P(4)*Q(1)*Q(2)) \
	 /((P(2)^2+P(1)^2)*Q(3)^2+(-2*P(2)*P(3)*Q(2)-2*P(1)*P(3)*Q(1))*Q(3)+(P(3)^2+P(1)^2)*Q(2)^2-2*P(1)*P(2)*Q(1)*Q(2) \
           +(P(3)^2+P(2)^2)*Q(1)^2), \
	 -((P(2)*P(3)*Q(3)+(-P(3)^2-P(1)^2)*Q(2)+P(1)*P(2)*Q(1))*Q(4)-P(2)*P(4)*Q(3)^2+P(3)*P(4)*Q(2)*Q(3)+P(1)*P(4)*Q(1)*Q(2)-P(2)*P(4)*Q(1)^2) \
	 /((P(2)^2+P(1)^2)*Q(3)^2+(-2*P(2)*P(3)*Q(2)-2*P(1)*P(3)*Q(1))*Q(3)+(P(3)^2+P(1)^2)*Q(2)^2-2*P(1)*P(2)*Q(1)*Q(2) \
           +(P(3)^2+P(2)^2)*Q(1)^2), \
	 (((P(2)^2+P(1)^2)*Q(3)-P(2)*P(3)*Q(2)-P(1)*P(3)*Q(1))*Q(4)+(-P(2)*P(4)*Q(2)-P(1)*P(4)*Q(1))*Q(3)+P(3)*P(4)*Q(2)^2+P(3)*P(4)*Q(1)^2) \
	 /((P(2)^2+P(1)^2)*Q(3)^2+(-2*P(2)*P(3)*Q(2)-2*P(1)*P(3)*Q(1))*Q(3)+(P(3)^2+P(1)^2)*Q(2)^2-2*P(1)*P(2)*Q(1)*Q(2) \
           +(P(3)^2+P(2)^2)*Q(1)^2) ; \
	 1/sqrt((P(1)*Q(3)-P(3)*Q(1))^2/(P(2)*Q(3)-P(3)*Q(2))^2+(P(1)*Q(2)-P(2)*Q(1))^2/(P(2)*Q(3)-P(3)*Q(2))^2+1), \
	 -(P(1)*Q(3)-P(3)*Q(1))/((P(2)*Q(3)-P(3)*Q(2))*sqrt((P(1)*Q(3)-P(3)*Q(1))^2/(P(2)*Q(3)-P(3)*Q(2))^2 \
							    +(P(1)*Q(2)-P(2)*Q(1))^2/(P(2)*Q(3)-P(3)*Q(2))^2+1)), \
	 (P(1)*Q(2)-P(2)*Q(1))/((P(2)*Q(3)-P(3)*Q(2))*sqrt((P(1)*Q(3)-P(3)*Q(1))^2/(P(2)*Q(3)-P(3)*Q(2))^2 \
							   +(P(1)*Q(2)-P(2)*Q(1))^2/(P(2)*Q(3)-P(3)*Q(2))^2+1))];
  catch
    p=P(1:3);
    q=Q(1:3);
    if rows(p)==3
      p=p';
    endif
    if rows(q)==3
      q=q';
    endif
    n=vector_product(p,q);
    b=[P(4);Q(4);0];
    pt=([p;q;n] \ b)';
    v=n/norm(n);
    L=[pt;v];
  end_try_catch
endfunction
%!test 'exact-zero'
%! a=0;
%! P=[1,a,a,4];
%! Q=[0,1,a,1];
%! L=[4,1,0;0,0,1];
%! M=intersection_line(P,Q);
%! assert(dl2l(M,L),0)
%! M=intersection_line(P',Q);
%! assert(dl2l(M,L),0)
%! M=intersection_line(P',Q);
%! assert(dl2l(M,L),0)
%! M=intersection_line(P',Q');
%! assert(dl2l(M,L),0)
##
%!test 'approx-zero'
%!shared a, P, Q, L, M
%! a=1e-10;
%! P=[1,a,a,4];
%! Q=[0,1,a,1];
%! L=[4,1,0;0,0,-1];
%! M=intersection_line(P,Q);
%! assert(M,L,10*a)
%! M=intersection_line(P,Q);
%! assert(dl2l(M,L),0,10*a)
%! M=intersection_line(P',Q);
%! assert(dl2l(M,L),0,10*a)
%! M=intersection_line(P',Q);
%! assert(dl2l(M,L),0,10*a)
%! M=intersection_line(P',Q');
%! assert(dl2l(M,L),0,10*a)
%!test
%! assert(dl2l(L,M),0,a)

#  end of intersection_line.m 
