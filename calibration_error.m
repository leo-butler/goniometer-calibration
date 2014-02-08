## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id: emacs-octave.el,v 1.3 2010-05-28 16:50:15 lbutler Exp $
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

source goniometer_error.m
load randstate.m

line_obj_use_acos=0;
filename="goniometer.dat";
sigma=[150,150,100] * deflation_factor;
epsilon=1e-8;
N=20;
niter=100;
[Lest_mc,obj_mc,info_mc,iter_mc,nf_mc,lambda_mc,cons_mc] = \
    goniometer_error (filename,sigma,randstate,epsilon,N,niter)

function y = fobjectivefn(Lest)
  y=zeros(1,columns(Lest));
  i=1;
  for L=Lest
    L=reshape(L,3,2)';
    y(i)=objectivefn(L);
    i=i+1;
  endfor
endfunction

obj_real_mc=fobjectivefn(Lest_mc);


clf();
hold on;
scatter3(Lest_mc(4:4,2:N+1)', Lest_mc(5:5,2:N+1)' , Lest_mc(6:6,2:N+1)','*')
scatter3(Lest_mc(4:4,1)', Lest_mc(5:5,1)' , Lest_mc(6:6,1)',"@12")
hold off;
clf();
hold on;
scatter3(Lest_mc(1:1,2:N+1)', Lest_mc(2:2,2:N+1)' , Lest_mc(3:3,2:N+1)','*')
scatter3(Lest_mc(1:1,1)', Lest_mc(2:2,1)' , Lest_mc(3:3,1)',"@12")
hold off;

"Summary stats for the objective function:"
cov(obj_real_mc ,obj_real_mc )
mean( obj_real_mc  )

"Summary stats for the estimator:"
Lest=Lest_mc(:,1)'
Lest_mean=mean(Lest_mc')
(Lest-Lest_mean)
(Lest-Lest_mean)./Lest*100
Lest_cov=cov(Lest_mc',Lest_mc')
[u,s,v]=svd(Lest_cov)

#  end of calibration_error.m 
