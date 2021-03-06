## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id$
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

#source objectivefn.m
source goniometer.m

global sample_data objectivefn_data objectivefn_partition objectivefn_lines;
function [Lest_mc,obj_mc,info_mc,iter_mc,nf_mc,lambda_mc,cons_mc] = goniometer_error (filename,sigma,randstate,epsilon,N=2,niter=45)
  ## usage:  [Lest_mc,obj_mc,info_mc,iter_mc,nf_mc,lambda_mc,cons_mc] = goniometer_error (P,sigma,randstate,epsilon,N=2,niter=45)
  ##
  ## filename  = string-name of goniometer data file
  ## randstate = seed for rng
  ## sigma   = 3-vector of st. dev.
  ## N         = number of monte carlo draws
  global sample_data objectivefn_data objectivefn_partition objectivefn_lines scalar_constraint;
  ## read data and estimate line
  goniometer_data=read_goniometer_data(filename);
  [tdata,tpartition]=gpartition(goniometer_data);
  objectivefn_data=tdata;
  objectivefn_partition=tpartition;
  goniometer_rebase_zdata();
  tdata=objectivefn_data;
  make_objectivefn_lines();
  L0=reshape(objectivefn_lines(1:2,:)',6,1);
  [Lest,obj,info,iter,nf,lambda]=line_estimator(L0,[],[],niter,epsilon);
  cons=constraintfn(Lest);
  ## create arrays holding data
  Lest_mc=zeros(rows(Lest),N+1);
  Lest_mc(:,1)=Lest;
  obj_mc=zeros(1,N+1);
  obj_mc(:,1)=obj;
  info_mc=zeros(1,N+1);
  info_mc(:,1)=info;
  iter_mc=zeros(1,N+1);
  iter_mc(:,1)=iter;
  nf_mc=zeros(1,N+1);
  nf_mc(:,1)=nf;
  lambda_mc=zeros(rows(lambda),N+1);
  lambda_mc(:,1)=lambda;
  cons_mc=zeros(ifelse(scalar_constraint==1,1,2),N+1);
  cons_mc(:,1)=cons;
  randn("state",randstate);
  [r,c]=size(objectivefn_data);
  noise=zeros(r,c);
  L0=Lest;
  for i=2:N+1
    noise(:,1)=sigma(1)*randn(r,1);
    noise(:,2)=sigma(2)*randn(r,1);
    noise(:,3)=sigma(3)*randn(r,1);
    objectivefn_data=tdata + noise;
    make_objectivefn_lines();
    [Lest,obj,info,iter,nf,lambda]=line_estimator(L0,[],[],niter,epsilon);
    cons=constraintfn(Lest);
    Lest_mc(:,i)=Lest;
    obj_mc(:,i)=obj;
    info_mc(:,i)=info;
    iter_mc(:,i)=iter;
    nf_mc(:,i)=nf;
    lambda_mc(:,i)=lambda;
    cons_mc(:,i)=cons;
  endfor
  #[Lest_mc,obj_mc,info_mc,iter_mc,nf_mc,lambda_mc];
endfunction


function [passes,tests] = __test_goniometer_error ()
  ## usage:  [passes,tests] = __test_make_objectivefn_data ()
  ##
  ## 
  global objectivefn_data objectivefn_partition objectivefn_lines line_obj_use_acos;
  load randstate.m
  randn("state",randstate);
  passed=0;tests=0;fails=[];
  massert=@(x,y,z=0) [passed=passed+(abs(x-y)<=z),tests=tests+1,fails=[fails,ifelse(abs(x-y)>z,tests)]];
  ## T1
  filename="goniometer_test.dat";
  epsilon=1e-8;
  niter=35;
  N=2;
  sigma=zeros(1,3);
  [Lest_mc,obj_mc,info_mc,iter_mc,nf_mc,lambda_mc,cons_mc] = goniometer_error (filename,sigma,randstate,epsilon,N,niter);
  Lactual=repmat(ifelse(0*line_obj_use_acos==1,[0;0;0;1;1;-1]/sqrt(3),[0;0;0;1;1;1]/sqrt(3)), 1,N+1);
  objactual=ifelse(line_obj_use_acos==1, 3*acos(1/sqrt(3))^2, 3*(2/3+(1-1/sqrt(3))^2));
  pt=massert(norm(obj_mc-objactual),0,epsilon);
  pt=massert(norm(Lest_mc-Lactual),0,10*epsilon);
  pt=massert(norm(cons_mc),0,epsilon);
  pt=massert(min(norm(info_mc-101),norm(info_mc)),0,epsilon); 
  ## T2
  sigma0=1e-2;
  sigma=sigma0*ones(1,3);
  [Lest_mc,obj_mc,info_mc,iter_mc,nf_mc,lambda_mc,cons_mc] = goniometer_error (filename,sigma,randstate,epsilon,N,niter);
  pt=massert(norm(obj_mc-objactual),0,20*sigma0);
  pt=massert(norm(Lest_mc-Lactual),0,10*sigma0);
  pt=massert(norm(cons_mc),0,sigma0);
  pt=massert(min(norm(info_mc-101),norm(info_mc)),0,sigma0);
  ##
  passes=pt(1);
  tests=pt(2);
  fails=ifelse(passes==tests,"none",pt(3:length(pt)))
  [passes,tests];
endfunction
%!test
%! global scalar_constraint line_obj_use_acos;
%! line_obj_use_acos=0
%! scalar_constraint=0
%! [passes,tests]=__test_goniometer_error();
%! assert(passes,tests)
%! line_obj_use_acos=1
%! [passes,tests]=__test_goniometer_error();
%! assert(passes,tests)

## end of goniometer_error.m
