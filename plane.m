# -*- Mode: octave; Package: OCTAVE -*-
#
# $Id$
#
# Author: Leo Butler (l.butler@ed.ac.uk)
#
# This file is OCTAVE code (http://www.octave.org/)
#
# It is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or (at your
# option) any later version.
#
# This software is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
# License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this file. If not, see http://www.gnu.org/licenses/.
#

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
  t=(x*n-c)' * (x*n-c)/N;
endfunction

function t=norm_constraint(alpha)
  ## alpha=[n;c]
  ## return |n|-1
  t=norm(alpha(1:3))-1;
endfunction

function v=vector_product(a,b)
  ## vector product
  v=[a(2)*b(3)-a(3)*b(2);-a(1)*b(3)+a(3)*b(1);a(1)*b(2)-a(2)*b(1)];
endfunction


function error = estimator_error (x,v,use_constant=1)
  ## usage:  error = estimator_error (x,v)
  ##
  ## x=estimate
  ## v=[n,c]=[true normal,true constant]
  if rows(x)==3
    x=[x/norm(x);1/norm(x)];
  endif
  if use_constant==0
    x=x(1:3);
    v=v(1:3);
  endif
  a=norm(x-v);
  b=norm(x+v);
  if a<b
    error=a;
  else
    error=b;
  endif
  error;
endfunction


function errors = estimator_error_in_sample_s (randstate,a,b,steps,v1,v2,p,epsilon,use_constant=1,grid=1)
  ## usage:  errors = estimator_error_in_sample_s (randstate,a,b,steps,v1,v2,p,epsilon,use_constant=1,grid=1)
  ##
  ## randstate = seed for rng
  ## a,b,steps = iterate from a..b by steps
  ## v1,v2     = linearly independent vectors in plane P
  ## p         = point on plane P
  ## epsilon   = std. dev. of noise
  ## use_constant = if 1, compute error including constant term
  global sample_data;
  rand("state",randstate);
  [x,n]=make_almost_planar_data(v1,v2,p,b,epsilon,grid);
  c=p'*n;
  n=[n;c];
  if grid==1
    a=(2*a+1)^2;
    b=rows(x);
    steps=steps^2;
  endif;
  y=ones(b,1);
  N=linspace(a,b,steps);
  errors=zeros(steps,3);
  j=1;
  for i=N
    sample_data=@() x(1:i,1:3);
    ## Ordinary Least Squares:
    ## estimate w of the normal vector n
    ## 1/norm(w) estimates constant c
    w=ols(y(1:i,1),feval(sample_data));
    ## Constrained Least Squares
    ## estimate v -> [n;c] is a joint estimate
    v=sqp([1;2;0;3],@obj,@norm_constraint,[]);
    errors(j,1:3)=[i,
		   estimator_error(v,n,use_constant),
 		   estimator_error(w,n,use_constant)];
    ++j;
  endfor
  errors;
endfunction


 ##
 ## A simple example
 ##
 global sample_data;
 load "randstate.m";
 rand("state",randstate);
 ## Data for problem
 v1=[1;0;0]; v2=[0;1;0]; p=[0;1;-1]; epsilon=1; N=10;
 [x,n]=make_almost_planar_data(v1,v2,p,N,epsilon,1);
 sample_data=@() x;
 y=ones(rows(x),1);
 w=ols(y,x)                                #least squares
 v=sqp([1;2;1;4],@obj,@norm_constraint,[]) #non-linear constrained least-squares
 estimator_error(v,[n;p'*n],1)
 estimator_error(w,[n;p'*n],1)
 plot3(x(:,1),x(:,2),x(:,3),"+")

## 
## a=100; b=2000; steps=11; use_constant=1;
## errors = estimator_error_in_sample_s (randstate,a,b,steps,v1,v2,p,epsilon,use_constant);
## loglog(errors(:,1),errors(:,3),"*;ols;",errors(:,1),errors(:,2),"+;constrained lsq;")
## loglog(errors(:,1),errors(:,2),"+;constrained lsq;")
## plot(errors(:,1),errors(:,3),"*;ols;",errors(:,1),errors(:,2),"+;constrained lsq;")
## plot(errors(:,1),errors(:,2),"+;constrained lsq;")
## 


##
## Compute the mean estimate over N draws
##
load randstate.m;
draws=5;
a=5; b=10; steps=5; use_constant=1; grid=1;
errors = estimator_error_in_sample_s (randstate,a,b,steps,v1,v2,p,epsilon,use_constant,grid);
for j=1:--draws
  error=estimator_error_in_sample_s (rand("state"),a,b,steps,v1,v2,p,epsilon,use_constant,grid);
  #errors=[errors;error];
  errors+=error;
endfor
++draws;

lerrors=[log(errors)';ones(1,rows(errors))]';
coeff_cls=ols(lerrors(:,2),[lerrors(:,1),lerrors(:,4)]);
clsr=@(x) exp(coeff_cls(2)).*x.^coeff_cls(1);
coeff_ols=ols(lerrors(:,3),[lerrors(:,1),lerrors(:,4)]);
olsr=@(x) exp(coeff_ols(2)).*x.^coeff_ols(1);
e_cls=reshape(errors(:,2),rows(errors)/draws,draws)';
e_ols=reshape(errors(:,3),rows(errors)/draws,draws)';
e_n=errors(1:length(e_cls),1);

fplot(clsr,[(2*a+1)^2,(2*b+1)^2],100); hold;
fplot(olsr,[(2*a+1)^2,(2*b+1)^2],100);
plot(errors(:,1),errors(:,3),"*;ols;",errors(:,1),errors(:,2),"+;constrained lsq;")
plot(e_n,mean(e_cls),"+",e_n,mean(e_ols),"*")
hold off;
print -deps errors.eps

## end of plane.m

