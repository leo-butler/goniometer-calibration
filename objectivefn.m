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
  elseif y==1 && size(x)==[3,3]
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
%! assert(plane([x';y';z']),P);

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
  [L,obj,info,iter,nf,lambda]=sqp(L0,@objectivefn,@constraintfn,[],LUP,LOW,maxiter,epsilon);
endfunction

#####################################################################



##
##
## end of objectivefn.m
