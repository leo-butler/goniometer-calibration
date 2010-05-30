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

global objectivefn_partition objectivefn_data;
function t = objectivefn (L,normalise_direction=1)
  ## usage:  t = objectivefn (L,normalise_direction=1)
  ##
  ## Given the lines stored in the global variable objectivefn_lines
  ## this function computes \sum_M d(L,M)^2 
  global objectivefn_lines;
  r=rows(objectivefn_lines);
  t=0;
  if size(L)!=[2,3]
    L=reshape(L,3,2)';
  endif
  if normalise_direction
    L(2,:)=L(2,:)/norm(L(2,:));
  endif
  for i=1:2:r
    M=objectivefn_lines(i:i+1,:);
    t=t+line_obj(L,M);
  endfor
endfunction


function v=vector_product(a,b)
  ## vector product
  v=[a(2)*b(3)-a(3)*b(2);-a(1)*b(3)+a(3)*b(1);a(1)*b(2)-a(2)*b(1)];
endfunction
%!test
%! assert(vector_product([1;0;0],[0;1;0]),[0;0;1])
%! assert(vector_product([0;1;0],[0;0;1]),[1;0;0])
%! assert(vector_product([0;0;1],[1;0;0]),[0;1;0])

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
  s;
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
    if rows(p)==3
      p=p';
    endif
    if rows(q)==3
      q=q';
    endif
    n=vector_product(p,q)';
    b=[P(4);Q(4);0];
    pt=([p;q;n] \ b)';
    v=n/norm(n);
    L=[pt;v];
  end_try_catch
endfunction

global line_obj_use_acos;
function d = line_obj (L,M,normalise_directions=1,W=1)
  ## usage:  d = line_obj (L,M,normalise_directions=1,W=1)
  ##
  ## L,M are lines in R^3 = [p;v] where p is a point in R^3 closest to 0
  ## and v is a unit direction vector = 2 x 3 matrix
  ## W=3x3 weight matrix
  ## normalise_directions=1 ==> make sure |v|=1.
  global line_obj_use_acos;
  if normalise_directions==1
    L(2,:)/=norm(L(2,:));
    M(2,:)/=norm(M(2,:));
  endif
  if line_obj_use_acos==1 && normalise_directions==1
    yp=L-M;
    d=yp(1,:) * yp(1,:)';
    s=acos(L(2,:) * M(2,:)');
    d=d+s;
  else
    yp=L-M;
    d=trace(yp * W * yp');
    L(2,:)=-L(2,:);
    ym=L-M;
    d=min([d,trace(ym * W * ym')]);
  endif
   
endfunction
## 
%!test 'exact-zero'
%! a=0;
%! P=[1,a,a,4];
%! Q=[0,1,a,1];
%! L=[4,1,0;0,0,-1];
%! M=intersection_line(P,Q);
%! assert(line_obj(M,L),0)
%! M=intersection_line(P',Q);
%! assert(line_obj(M,L),0)
%! M=intersection_line(P',Q);
%! assert(line_obj(M,L),0)
%! M=intersection_line(P',Q');
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
%! M=intersection_line(P,Q);
%! assert(line_obj(M,L),0,10*a)
%! M=intersection_line(P',Q);
%! assert(line_obj(M,L),0,10*a)
%! M=intersection_line(P',Q);
%! assert(line_obj(M,L),0,10*a)
%! M=intersection_line(P',Q');
%! assert(line_obj(M,L),0,10*a)
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
  if y==1 && size(x)==[9,1]
    ## we assume vectors are 3x1 stacked
    z=x(7:9);
    y=x(4:6);
    x=x(1:3);
  elseif y==1 && size(x)==[1,9]
    ## in this case, we want rows of reshaped x
    x=reshape(x,3,3);
    z=x(3,:);
    y=x(2,:);
    x=x(1,:);
  endif
  n=vector_product(y-x,z-x);
  try
    n=n/norm(n);
  catch
    x
    y
    z
    error("plane: the normal n=vector_product(y-x,z-x) is zero.");
  end_try_catch
  if rows(x)==3
    c=n' * x;
  else
    c=x * n;
  endif
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

global show_iolop_state
show_iolop_state=0;
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
function t=ssq(x)
  t=x*x';
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
%! assert(iterate_over_lists_of_points(@ssq,data,partition), 2 * 5^2 * 3^2)
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



function t = rec (fnh,x,rec_state=[])
  ## usage:  t = rec (fnh,x)
  ##
  ## a stupid way to copy x into rec_state
  t=0;
  if length(x)==0
    t=fnh(rec_state);
  else
    rec_state=[rec_state,x(:,1)];
    t=t+rec(fnh,x(:,2:columns(x)),rec_state);
  endif
endfunction
%!test
%! x=1:5;
%! assert(rec(@length,x),5)
%! assert(norm(rec(@(y) y,x)-x),0)


function y = at (x,s)
  ## usage:  y = at (x,s)
  ##
  ## 
  l=length(s);
  m=length(x);
  y=zeros(l,1);
  for i=1:l
    y(i)=ifelse(1<=s(i) && s(i)<=m, x(s(i)), NaN);
  endfor
endfunction

global __powersets;
function P = __objectivefn_lines_powersets (r)
  ## usage:  P = __objectivefn_lines_powersets (r)
  ##
  ## A lookup function that saves the powersets
  global __powersets;
  P=[];
  if iscell(__powersets) && length(__powersets)>=r
    P=__powersets{r};
  endif
  if isempty(P)
    P=powersets(1:r,[r;2]);
    __powersets{r}=P;
  endif
endfunction

global objectivefn_lines;
function t = __objectivefn_lines(x)
  ## usage:  t = __objectivefn_lines (x)
  ##
  ## x = a 1 x 18 row vector, the first 9 (last 9) defining
  ##     a plane P (Q).
  ##
  ## This function puts the line L in P \cap Q into
  ## the global variable objectivefn_lines.
  global objectivefn_lines;
  t=0;
  if size(x)==[1,18]
    P=plane(x(1:9));
    Q=plane(x(10:18));
    objectivefn_lines=[objectivefn_lines;intersection_line(P,Q)];
    t=1;
  else
    ## we have r>2 planes, so we must construct all 2 subsets of
    ## of these r planes, and compute their intersection
    r=columns(x)/9;
    x=reshape(x,9,r)';
    P=__objectivefn_lines_powersets(r);
    for p=P.partition{1}'
      t=t+__objectivefn_lines([x(p(1),:),x(p(2),:)]);
    endfor
  endif
endfunction
%!test
%! global objectivefn_lines;
%! objectivefn_lines=[];
%! N=4;
%! P=(1:(N*9)).^3;
%! assert(__objectivefn_lines(P),binomial(N,2));
%! objectivefn_lines=[];
%! N=5;
%! P=(1:(N*9)).^3;
%! assert(__objectivefn_lines(P),binomial(N,2));

function t = make_objectivefn_lines()
  ## usage:  t = objectivefn_lines ()
  ##
  ## This function puts the line L in P \cap Q into
  ## the global variable objectivefn_lines.
  global objectivefn_partition objectivefn_data objectivefn_lines;
  objectivefn_lines=[];
  r=columns(objectivefn_partition);
  if r==2
    t=iterate_over_lists_of_points(@__objectivefn_lines,objectivefn_data,objectivefn_partition);
  else
    ## construct begin/finish locations of partition
    f=cumsum(objectivefn_partition(1,:));
    b=[1,f+1];
    ## construct all 2-subsets of 1:r and iterate over them
    p2sets=__objectivefn_lines_powersets(r);
    t=0;
    for s=p2sets.partition{1}'
      d=[objectivefn_data(b(s(1)):f(s(1)),:);objectivefn_data(b(s(2)):f(s(2)),:)];
      p=[objectivefn_partition(:,s(1))';objectivefn_partition(:,s(2))']';
      t=t+iterate_over_lists_of_points(@__objectivefn_lines,d,p);
    endfor
  endif
endfunction


function [passes,tests] = __test_objectivefn ()
  ## usage:  [passes,tests] = __test_objectivefn ()
  ##
  ## We use this to workaround the test function's handling of
  ## global variables.
  global objectivefn_partition objectivefn_data objectivefn_lines;
  ## create a closure with passed,tests,fails
  ## at the end of the tests, we will see if passed=tests
  passed=0;
  tests=0;
  fails=[];
  massert=@(x,y,z=0) [passed=passed+(abs(x-y)<=z),tests=tests+1,fails=[fails,ifelse(abs(x-y)>z,tests)]];
  ## T1
  a=0;
  objectivefn_partition=[3,3;3,3];
  objectivefn_data=[1,0,0;0,1,0;2,1,0; a,0,1;0,1,1;a,2,3];
  make_objectivefn_lines();
  pt=massert(make_objectivefn_lines(),1);;
  L=[0,0,0;0,1,0];
  pt=massert(objectivefn(L), 0);
  ## T2
  objectivefn_data=[4,5.1,0;1,0,0;0,1,0;2,3,0;  1,0,1;3,0,2;4.3,0,-1];
  objectivefn_partition=[4,3;3,3];
  make_objectivefn_lines();
  pt=massert(make_objectivefn_lines(),4);;
  L=[0,0,0;1,0,0];
  pt=massert(objectivefn(L), 0);
  L=[0,0,0,1,0,0];
  pt=massert(objectivefn(L), 0);
  L=[0;0;0;1;0;0];
  pt=massert(objectivefn(L), 0);
  ## T3
  a=0;
  objectivefn_data=[6.1,7.1,a;4,5.1,0;1,0,0;0,1,0;2,5,0;  1,0,1;3,0,2;4.3,0,-1];
  objectivefn_partition=[5,3;3,3];
  pt=massert(make_objectivefn_lines(),binomial(5,3)*binomial(3,3));
  L=[0,0,0;1,0,0];
  pt=massert(objectivefn(L), 0, 10*a);
  ## T3-1
  a=0;
  objectivefn_data=[6.1,7.1,a;4,5.1,0;1,0,0;
		    0,1,1;0,5,11;0,9,7;
		    1,0,1;3,0,2;4.3,0,-1];
  objectivefn_partition=[3,3,3;3,3,3];
  pt=massert(make_objectivefn_lines(),3*binomial(3,3)*binomial(3,3));
  L=[0,0,0;0,1,0;
     0,0,0;1,0,0;
     0,0,0;0,0,1];
  pt=massert(objectivefn(L(1:2,:)), 4, 10*a);
  pt=massert(objectivefn(L(3:4,:)), 4, 10*a);
  pt=massert(objectivefn(L(5:6,:)), 4, 10*a);
  ## T3-2
  a=0;
  objectivefn_data=[6.1,7.1,a;4,5.1,0;1,0,0;21.1,2,0;
		    0,1,1;0,5,11;0,9,7;0,13,17;
		    1,0,1;3,0,2;4.3,0,-1;43,0,51];
  objectivefn_partition=[4,4,4;3,3,3];
  Nlines=3*binomial(4,3)^2;
  pt=massert(make_objectivefn_lines(),Nlines);
  L=[0,0,0;0,1,0;
     0,0,0;1,0,0;
     0,0,0;0,0,1];
  ## each line occurs in 1/3 of objectivefn_lines
  ## while the other 2/3 have distance=2
  pt=massert(objectivefn(L(1:2,:)), 2*Nlines*2/3, 10*a);
  pt=massert(objectivefn(L(3:4,:)), 2*Nlines*2/3, 10*a);
  pt=massert(objectivefn(L(5:6,:)), 2*Nlines*2/3, 10*a);

  ## T4 test line_estimator
  epsilon=1e-8;
  objectivefn_partition=[3,3;3,3];
  objectivefn_data=[1,0,0;0,1,0;2,1,0; a,0,1;0,1,1;a,2,3];
  make_objectivefn_lines();
  pt=massert(make_objectivefn_lines(),1);;
  L=[0,0,0;0,1,0];
  L0=[1;2;-1;1/sqrt(2);1/sqrt(2);0];
  Lest=line_estimator(L0,[],[],35,epsilon);
  Lest=reshape(Lest,3,2)';
  pt=massert(norm(L-Lest),0,10*epsilon);
  ## T5
  a=0;
  epsilon=1e-8;
  objectivefn_data=[6.1,7.1,a;4,5.1,0;1,0,0;0,1,0;2,5,0;  1,0,1;3,0,2;4.3,0,-1];
  objectivefn_partition=[5,3;3,3];
  pt=massert(make_objectivefn_lines(),binomial(5,3)*binomial(3,3));
  L=[0,0,0;1,0,0];
  L0=[1;2;-1;1/sqrt(2);1/sqrt(2);0];
  Lest=line_estimator(L0,[],[],35,epsilon);
  Lest=reshape(Lest,3,2)';
  pt=massert(line_obj(L,Lest,0),0,10*epsilon);
  ## T6
  a=0;
  epsilon=1e-8;
  objectivefn_data=[6.1,7.1,a;4,5.1,0;1,0,0;0,1,0;2,5,0;  1,0,1;3,0,2;4.3,0,-1] + 3;
  objectivefn_partition=[5,3;3,3];
  pt=massert(make_objectivefn_lines(),binomial(5,3)*binomial(3,3));
  L=[0,3,3;1,0,0];
  L0=[1;2;-1;1/sqrt(2);1/sqrt(2);0];
  Lest=line_estimator(L0,[],[],35,epsilon);
  Lest=reshape(Lest,3,2)';
  pt=massert(line_obj(L,Lest,0),0,1e3*epsilon);
  ##
  passes=pt(1);
  tests=pt(2);
  fails=ifelse(passes==tests,"none",pt(3:length(pt)))
  [passes,tests];
endfunction
%!xtest
%! global scalar_constraint;
%! scalar_constraint=1;
%! [passes,tests]=__test_objectivefn();
%! assert(passes,tests)

global scalar_constraint;
function C = constraintfn (L)
  ## usage:  C = constraintfn (L)
  ##
  ## The line L=[p;v] where p & v are 1x3 row vectors
  ## and |v|=1, <p,v>=0.
  ## C = [ <v,v>-1, <p,v> ]
  if size(L)!=[2,3]
    L=reshape(L,3,2)';
  endif
  ##Surprisingly, the estimator works better with the
  ##scalar constraint. Maybe this is worth investigating?
  global scalar_constraint;
  if scalar_constraint
    C = [ (norm(L(2,:))^2-1)^2 + (L(1,:) * L(2,:)')^2 ];
  else
    C = [ (norm(L(2,:))^2-1)^2 ; L(1,:) * L(2,:)' ];
  endif
endfunction
%!test
%! L=[1,2,3; 4,5,6];
%! global scalar_constraint;
%! scalar_constraint=0;
%! c=ifelse(scalar_constraint,[(4^2+5^2+6^2-1)^2 + (1*4+2*5+3*6)^2],[(4^2+5^2+6^2-1)^2 ;  1*4+2*5+3*6]);
%! epsilon=1e-10;
%! assert(constraintfn(L), c, epsilon);
%! L=[1;2;3; 4;5;6];
%! assert(constraintfn(L), c, epsilon);
%! L=[1,2,3, 4,5,6];
%! assert(constraintfn(L), c, epsilon);
%! scalar_constraint=1;
%! c=ifelse(scalar_constraint,[(4^2+5^2+6^2-1)^2 + (1*4+2*5+3*6)^2],[(4^2+5^2+6^2-1)^2 ;  1*4+2*5+3*6]);
%! epsilon=1e-10;
%! assert(constraintfn(L), c, epsilon);
%! L=[1;2;3; 4;5;6];
%! assert(constraintfn(L), c, epsilon);
%! L=[1,2,3, 4,5,6];
%! assert(constraintfn(L), c, epsilon);

function [L,obj,info,iter,nf,lambda] = line_estimator (L0,LUP=[],LOW=[],maxiter=25,epsilon=1e-6)
  ## usage:  [L,obj,info,iter,nf,lambda] = line_estimator (L0,LUP,LOW,maxiter,epsilon)
  ##
  ## estimates L given L0 (a 6x1 column vector)
  make_objectivefn_lines();
  [L,obj,info,iter,nf,lambda]=sqp(L0,@objectivefn,@constraintfn,[],LUP,LOW,maxiter,epsilon);
endfunction

#####################################################################



##
##
## end of objectivefn.m
