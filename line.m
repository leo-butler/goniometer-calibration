## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id$
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

function v=xp(a,b)
  ## vector product
  v=[a(2)*b(3)-a(3)*b(2);-a(1)*b(3)+a(3)*b(1);a(1)*b(2)-a(2)*b(1)];
endfunction
%!test
%! assert(xp([1;0;0],[0;1;0]),[0;0;1])
%! assert(xp([0;1;0],[0;0;1]),[1;0;0])
%! assert(xp([0;0;1],[1;0;0]),[0;1;0])

function y = rowdiff (a,i)
  ## usage:  y = rowdiff (a,i)
  ##
  ## given a matrix a with r rows, removes the i-th row
  if size(a)==0
    y = a;
  endif
  r = rows(a);
  if i<0 || i>r
    error("rowdiff(a,i): i < 0 or i > rows(a).");
  elseif i==1
    y = a(2:r,:);
  elseif i==r
    y = a(1:r-1,:);
  else
    y = [a(1:i-1,:); a(i+1:r,:)];
  endif
endfunction
%!test
%!shared x
%! x=reshape(1:20,4,5);
%! assert(rowdiff(x,1),x(2:4,:))
%!test
%! assert(rowdiff(x,4),x(1:3,:))
%!test
%! assert(rowdiff(x,2),[x(1,:);x(3:4,:)])

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
    if opt=="rows"
      S=unique(S,"rows");
    endif
  else
    S=[];
  endif
  S;
endfunction

function f=binomial(n,c=0)
 if size(n)==[1,1]
   f=factorial(n)/factorial(n-c)/factorial(c);
 else
   f=[];
   for i=1:columns(n)
     f=[f,binomial(n(1,i),n(2,i))];
   endfor
 endif
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


function s = getsset (S,i,j,opt="rows")
  ## usage:  s = getsset (S,i,j,opt="rows")
  ##
  ## S = cell structure with cells `partition' and `data'
  ##     S.partition is a cell structure with n partitions
  ## i<= n is the partition number
  ## j = the particular subset
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
endfunction

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

function L = intersection_line (P,Q)
  ## usage:  L = intersection_line (P,Q)
  ##
  ## P,Q = planes in R^3
  ## L   = the intersection line of P and Q
  ## 
  ## * a plane is represented by [a,b,c,d] where n=[a,b,c] is a
  ## unit normal and P: <n,x>=d;
  ## * a line is represented by a 3 x 2 matrix, the first column
  ## is the point closest to 0 and the second is a unit direction
  ## vector
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
    n=xp(p,q)';
    b=[P(4);Q(4);0];
    pt=([p;q;n] \ b)';
    v=n/norm(n);
    L=[pt;v];
  end_try_catch
endfunction
function d = line_obj (L,M,W=1)
  ## usage:  d = line_obj (L,M,W=1)
  ##
  ## 
  yp=L-M;
  d=trace(yp * yp');
  L(2,:)=-L(2,:);
  ym=L-M;
  d=min([d,trace(ym * ym')]);
endfunction
## 
%!test 'exact-zero'
%! a=0;
%! P=[1,a,a,4];
%! Q=[0,1,a,1];
%! L=[4,1,0;0,0,-1];
%! M=intersection_line(P,Q);
%! assert(line_obj(M,L),0)
##
%!test 'approx-zero'
%!shared a, P, Q, L, M
%! a=1e-10;
%! P=[1,a,a,4];
%! Q=[0,1,a,1];
%! L=[4,1,0;0,0,-1];
%! M=intersection_line(P,Q);
%! assert(M,L,10*a)
%!test
%! assert(line_obj(L,M),0,a)
%!test
%! N=[5,2,1;0,0,1];
%! assert(line_obj(N,M),3,10*a)



function P = plane (x,y=1,z=1)
  ## usage:  P = plane (x,y,z)
  ##
  ## P = [n;c] = unit normal to plane <n,x>=c
  ## x,y,z = points on P
  if y==1 && (size(x)==[9,1] || size(x)==[1,9])
    z=x(7:9);
    y=x(4:6);
    x=x(1:3);
  endif
  n=xp(y-x,z-x);
  n=n/norm(n);
  c=n' * x;
  P=[n;c];
endfunction
%!test
%!shared x,y,z,P
%! x=[1;0;0];
%! y=[1;1;0];
%! z=[1;0;1];
%! P=[1;0;0;1];
%! assert(plane(x,y,z),P)
%! assert(plane(reshape([x;y;z],9,1)),P)
%! assert(plane([x;y;z]),P)

global iolop_state
iolop_state=[];
function t = iterate_over_lists_of_points (fnh,P,partition,opt="rows",is_str=0)
  ## usage:  t = iterate_over_lists_of_points (fnh,P,partition)
  ##
  ## fnh = a function handle
  ## P   = 3 x n matrix
  ## partition = a partition of P into distinct planes
  ## 
  ## the function fnh should take columns(partition) arguments
  ## e.g.
  ## P = [1,1,1,1;3,1,4,2;1,2,4,5]; partition=[2;2]
  global iolop_state
  if is_str==0
    P=powersets(P,partition,opt);
    t=iterate_over_lists_of_points(fnh,P,partition,opt,1);
  elseif is_str==length(P.partition)+1
    t=fnh(iolop_state);
    iolop_state=[];
  else
    c=columns(partition);
    rs=cellfun(@rows,P.partition);
    i=is_str;
    t=0;
    for j=1:rs(i)
      iolop_state=[iolop_state,getsset(P,i,j)];
      t=t+iterate_over_lists_of_points(fnh,P,partition,opt,i+1);
    endfor
  endif
endfunction

global rec_state
rec_state=[];
function t = rec (fnh,x)
  ## usage:  t = rec (fnh,x)
  ##
  ## 
  global rec_state;
  if length(x)==0
    t=fnh(rec_state);
    rec_state=[];
  else
    rec_state=[rec_state;x(:,1)];
    t=rec(fnh,x(:,2:columns(x)));
  endif
endfunction
# P = reshape(1:39,3,13);
# partition=[4;4;5];
# iterate_over_lists_of_points(P,partition)

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
