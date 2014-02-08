# -*- Mode: octave; Package: OCTAVE -*-
#
# $Id$
#
# Author: Leo Butler (l.butler@cmich.edu)
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
source goniometer.m

function t = obj (alpha)
  ## usage:  t = obj (alpha)
  ##
  ## An affine plane P in R^3 is determined uniquely by a unit normal n
  ## and constant c. The pair (n,c) is determined by P up to +-1.
  ##
  ## P : <n,x>=c  <==> (n,c)
  ##
  ## obj(alpha) computes, with alpha=[n;c]=4x1 vector,
  ## 1/N\sum_i^N |<x_i,n>-c|^2
  ## where the x_i are rows of the global variable sample_data
  global sample_data;
  N=rows(sample_data);
  c=alpha(4);
  n=alpha(1:3);
  n=n/norm(n);
  t=norm(sample_data*n-c)^2/N;
endfunction
%!test
%! global sample_data;
%! epsilon=1e-8;
%! sample_data=[1,0,0;0,1,0;2,1,0];
%! assert(obj([0;0;1;0]),0)
%! assert(obj([0;1;0;0]),2/3,epsilon)

function t = norm_constraint (alpha)
  ## usage:  t = norm_constraint (alpha)
  ## 
  ## alpha = [n;c]
  ## t = |n|-1.
  t=norm(alpha(1:3))-1;
endfunction
%!test
%! assert(norm_constraint([1;1;1;0]),sqrt(3)-1)

function error = plane_obj (x,v,use_constant=1)
  ## usage:  error = plane_obj (x,v)
  ##
  ## x=estimate
  ## v=[n;c]=[true normal;true constant]
  ## both are column vectors
  if rows(x)==3 && use_constant
    x=[x/norm(x);1/norm(x)];
  endif
  if use_constant==0
    x=x(1:3);
    v=v(1:3);
  endif
  error=min(norm(x-v),norm(x+v));
endfunction
%!test
%! assert(plane_obj([1;1;3],[1;0;1;sqrt(2)]/sqrt(2)),0.88447,1e-5)
%! assert(plane_obj([1;1;3]/sqrt(11),[1;0;1;1]/sqrt(2),0),0.54258,1e-5)
%! assert(plane_obj([1;0;1;1],[1;0;1;1]),0)
%! assert(plane_obj([-1;0;-1;-1],[1;0;1;1]),0)

function [P,obj,info,iter,nf,lambda,cons] = plane_goniometer (filename,niter=45,epsilon=1e-8)
  ## usage:  plane_goniometer (filename,niter=45,epsilon=1e-8)
  ##
  ## Compute least squares planes from data in filename.
  global objectivefn_data objectivefn_partition sample_data;
  goniometer_data=read_goniometer_data(filename);
  [objectivefn_data,objectivefn_partition]=gpartition(goniometer_data);
  goniometer_rebase_zdata();
  [P,obj,info,iter,nf,lambda,cons] = __planes();
endfunction
%!test
%! epsilon=1e-6;
%! filename="goniometer_test.dat";
%! P=[0,0,1,0;1,0,0,0;0,1,0,0]';
%! [Q,obj,info,iter,nf,lambda,cons]=plane_goniometer(filename);
%! s=0; for i=1:3 s+=plane_obj(P(:,i),Q(:,i)); endfor;
%! assert(s,0,epsilon);
%! assert(norm(info-101),0);
%! assert(norm(obj),0,epsilon);
%! assert(norm(cons),0,epsilon);

function [L,obj,info,iter,nf,lambda] = line_plane_goniometer (filename,niter=125,epsilon=1e-8)
  ## usage:  [L,obj,info,iter,nf,lambda] = line_plane_goniometer (filename)
  ##
  ## reads data in file 'filename', computes CLSQ planes through
  ## these points, then the CLSQ line fitting those planes
  global objectivefn_data objectivefn_partition;
  P=plane_goniometer(filename,niter,epsilon);
  objectivefn_lines=__lines(P);
  L0=reshape(objectivefn_lines(1:2,:)',6,1);
  [L,obj,info,iter,nf,lambda]=line_estimator(L0,[],[],niter,epsilon);
endfunction

function [P,obj,info,iter,nf,lambda,cons] = __planes (niter=125,epsilon=1e-8)
  ## usage:  [P,obj,info,iter,nf,lambda,cons] = __planes (niter=125,epsilon=1e-8)
  ##
  ## given data in objectivefn_data/partition, computes CLSQ planes
  ## through these points
  global objectivefn_data objectivefn_partition sample_data;
  n=columns(objectivefn_partition);
  P=zeros(4,n);
  obj=zeros(n,1);
  info=zeros(n,1);
  iter=zeros(n,1);
  nf=zeros(n,1);
  lambda=zeros(n,1);
  cons=zeros(n,1);
  b=0;
  f=0;
  for i=1:n
    b=f+1;
    f=b-1+objectivefn_partition(1,i);
    sample_data=objectivefn_data(b:f,:);
    P0=plane(sample_data(1:3,:)) + randn(4,1)*1e-2;
    P0(1:3)/=norm(P0(1:3));
    [P(:,i),obj(i),info(i),iter(i),nf(i),lambda(i)]=plane_estimator(P0,[],[],niter,epsilon);
    cons(i)=norm_constraint(P(:,i));
  endfor  
endfunction
%!test
%! epsilon=1e-6;
%! global objectivefn_data objectivefn_partition objectivefn_lines;
%! objectivefn_data=[1,0,0;0,1,0;2,3,0; 1,0,0;0,0,1;2,0,3; 0,1,0;0,0,1;0,2,5];
%! objectivefn_partition=[3,3,3;3,3,3];
%! P=[0,0,1,0; 0,1,0,0; 1,0,0,0]';
%! [Q,obj,info,iter,nf,lambda,cons] = __planes();
%! s=0; for i=1:3 s+=plane_obj(P(:,i),Q(:,i)); endfor;
%! assert(s,0,epsilon);
%! assert(norm(info-101),0);
%! assert(norm(obj),0,epsilon);
%! assert(norm(cons),0,epsilon);

function L = __lines (P,niter=125,epsilon=1e-8)
  ## usage:  L = __lines (P,niter=125,epsilon=1e-8)
  ##
  ## Computes intersections of planes defined by columns of P
  Ps=powerset(P',2,"rows")';
  L=zeros(2*columns(Ps),3);
  i=1;
  for l=Ps
    P0=l(1:4);
    P1=l(5:8);
    L(i:i+1,:)=intersection_line(P0,P1);
    i+=2;
  endfor
endfunction
%!test
%! epsilon=1e-8;
%! P=[0,0,1,0; 0,1,0,0; 1,0,0,0]';
%! L=[0,0,0; 1,0,0; 0,0,0; 0,1,0; 0,0,0; 0,0,-1 ];
%! M=__lines(P);
%! s=0; for i=1:2:6 s+=dl2l(L(i:i+1,:),M(i:i+1,:)); endfor;
%! assert(s,0,epsilon);

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

function [P,obj,info,iter,nf,lambda] = plane_estimator (P0,PUP=[],POW=[],maxiter=125,epsilon=1e-8)
  ## usage:  [P,obj,info,iter,nf,lambda] = plane_estimator (P0,PUP,POW,maxiter=125,epsilon=1e-8)
  ##
  ## estimates P given P0 (a 4x1 column vector)
  [P,obj,info,iter,nf,lambda]=sqp(P0,@obj,@norm_constraint,[],PUP,POW,maxiter,epsilon);
endfunction
%!test
%! global sample_data;
%! sample_data=[1,0,0;0,1,0;2,1,0;4,3,0];
%! P0=[0;0;1;0];
%! [P,obj,info,iter,nf,lambda] = plane_estimator (P0);
%! assert(plane_obj(P,P0),0)
%! assert(obj,0)
%! assert(info,101)
%! assert(iter,1)
%! assert(norm(lambda),0)
%!test
%! global sample_data;
%! sample_data=[1,0,4;0,1,4;2,1,4;4,3,4];
%! epsilon=1e-5;
%! P0=[0;0;1;4];
%! [P,obj,info,iter,nf,lambda] = plane_estimator (P0);
%! assert(norm_constraint(P),0,epsilon);
%! assert(plane_obj(P,P0),0)
%! assert(obj,0)
%! assert(info,101)
%! assert(iter,1)
%! assert(norm(lambda),0)
%! P0=[2;1;1;0]/sqrt(6);
%! [P,obj,info,iter,nf,lambda] = plane_estimator (P0);
%! assert(norm_constraint(P),0,epsilon);
%! assert(plane_obj(P,[0;0;1;4]),0,epsilon)

 ##
 ## A simple example
 ##
function __plane_simple_example()
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
endfunction
## end of plane.m

