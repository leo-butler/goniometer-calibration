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

source line.m
source make_almost_planar_data.m

function [errors,Lests] = line_estimator_error (P,sigma,randstate,epsilon,Lactual,N=2,grid=1,niter=45)
  ## usage:  [errors,Lests] = line_estimator_error (P,sigma,randstate,epsilon,Lactual,N=2,grid=1,niter=45)
  ##
  ## P         = 4 x N matrix of planes (each column is a unit normal; const)
  ## randstate = seed for rng
  ## sigma   = std. dev. of noise
  ## N         = number of samples
  global sample_data objectivefn_data objectivefn_partition;
  L0=reshape(Lactual + sigma*randn(2,3),6,1);
  errors=zeros(N,1);
  Lests=zeros(N,6);
  for i=1:N
    make_objectivefn_data(P,sigma,randstate,grid);
    make_objectivefn_lines();
    Lest=line_estimator(L0,[],[],niter,epsilon);
    Lestr=reshape(Lest,3,2)';
    errors(i)=line_obj(Lactual,Lestr);
    Lests(i,:)=Lest';
  endfor
  [errors,Lests];
endfunction

function t = make_objectivefn_data (P,sigma,randstate,grid=1)
  ## usage:  t = make_objectivefn_data (P,sigma,grid=1)
  ##
  ## P = 4 x N matrix of planes (each column is a unit normal; const)
  ## 
  global objectivefn_data objectivefn_partition;
  objectivefn_data=[];
  lenp=columns(objectivefn_partition);
  if lenp!=columns(P)
    error("columns(P) != columns(objectivefn_partition)");
  endif
  for i=1:lenp
    p=P(:,i);
    q=point_on_plane(p);
    [x,y]=plane_basis(p);
    k=objectivefn_partition(1,i);
    objectivefn_data=[objectivefn_data;
		      make_almost_planar_data(x,y,q,k,sigma,grid)];
  endfor
  t=size(objectivefn_data);
endfunction


function [passes,tests] = __test_make_objectivefn_data ()
  ## usage:  [passes,tests] = __test_make_objectivefn_data ()
  ##
  ## 
  global objectivefn_data objectivefn_partition;
  load randstate.m
  randn("state",randstate);
  passed=0;tests=0;fails=[];
  massert=@(x,y,z=0) [passed=passed+(abs(x-y)<=z),tests=tests+1,fails=[fails,ifelse(abs(x-y)>z,tests)]];
  sigma=1e-1;
  objectivefn_data=[];
  objectivefn_partition=[3,3;3,3];
  planes=[1,0,0,1;0,1,0,3]';
  grid=0;
  s=make_objectivefn_data(planes,sigma,randstate,grid);
  pt=massert(s,[sum(objectivefn_partition(1,:)),3]);
  objectivefn_data_e=[1.029638,1.625995,2.027675;
		      1.145820,1.856540,1.525217;
		      1.142279,0.804958,1.425524;
		      0.703794,0.066098,0.370574;
		      0.940052,-0.094277,-0.343306;
		      -0.443985,0.056030,0.062162];
  pt=massert(norm(objectivefn_data-objectivefn_data_e),0,1e-8);
  ##
  grid=1;
  objectivefn_partition=[9,9;3,3];
  s=make_objectivefn_data(planes,sigma,randstate,grid);
  pt=massert(s,[sum(objectivefn_partition(1,:)),3]);
  objectivefn_data_e=[1.1050384,0.0437464,-1.3652189;
		      1.0274723,0.6754998,-0.7905142;
		      1.0825787,1.5074216,0.0979670;
		      1.0081138,-0.7746758,-0.8594979;
		      0.9980917,-0.0063265,-0.0932748;
		      0.8571794,0.6400182,0.7411083;
		      1.0310877,-1.3200993,-0.0641696;
		      0.8459808,-0.8546383,0.6668978;
		      1.0363867,0.0900712,1.5401248;
		      -0.2498744,0.0420659,0.4007926;
		      0.4596004,-0.1075565,0.8436256;
		      1.1968019,-0.1864067,1.5568657;
		      -0.0374446,0.1066739,-0.4810517;
		      1.0506292,0.0985603,-0.0854467;
		      1.8510865,-0.0177533,0.4006236;
		      0.7142547,-0.1340674,-1.4114715;
		      1.5230199,0.1012874,-0.8039618;
		      2.3901369,0.0314681,-0.3437618];
  pt=massert(norm(objectivefn_data-objectivefn_data_e),0,1e-8);
  ##
  randn("state",randstate);
  objectivefn_partition=[4,3;3,3];
  Lactual=intersection_line(planes(:,1),planes(:,2));
  epsilon=1e-5;
  N=10;
  grid=0;
  sigma=1e-10;
  errors=line_estimator_error(planes,sigma,randstate,epsilon,Lactual,N,grid)
  pt=massert(norm(errors)/N,0,1e3*sigma);
  ##
  randn("state",randstate);
  objectivefn_partition=[6,6;3,3];
  Lactual=intersection_line(planes(:,1),planes(:,2));
  epsilon=1e-5;
  N=10;
  grid=0;
  sigma=1e-1;
  errors=line_estimator_error(planes,sigma,randstate,epsilon,Lactual,N,grid)
  pt=massert(norm(errors)/N,0,sigma);
  ##
  passes=pt(1);
  tests=pt(2);
  fails=ifelse(passes==tests,"none",pt(3:length(pt)))
  [passes,tests];
endfunction
%!test
%! [passes,tests]=__test_make_objectivefn_data();
%! assert(passes,tests)

function p = point_on_plane (P,rowv=0)
  ## usage:  p = point_on_plane (P)
  ##
  ## returns closest point p on P to 0.
  p=P(1:3) * P(4);
  if rowv
    p=reshape(p,1,3);
  else
    p=reshape(p,3,1);
  endif
endfunction
%!test
%! epsilon=1e-8;
%! P=[1;0;0;3];
%! p=point_on_plane(P);
%! q=[3;0;0];
%! assert(p,q,epsilon)

function [x,y] = plane_basis (P)
  ## usage:  [x,y] = plane_basis (P)
  ##
  ## P is a plane, [x,y] is an o.n. basis of plane P'
  ## through 0 parallel to P.
  n=P(1:3);
  a=[n,normrnd(0,1,3,2)];
  [q,r]=qr(a);
  x=q(:,2);
  y=q(:,3);
endfunction
%!test
%! epsilon=1e-8;
%! n=[1;0;0];
%! P=[n;1];
%! [x,y]=plane_basis(P);
%! q=[n,x,y];
%! assert( norm(q' * q - eye(3)), 0, epsilon)
%!test
%! epsilon=1e-8;
%! n=normrnd(0,1,3,1);
%! n=n/norm(n);
%! P=[n;1];
%! [x,y]=plane_basis(P);
%! q=[n,x,y];
%! assert( norm(q' * q - eye(3)), 0, epsilon)

## end of line_estimator_error.m

