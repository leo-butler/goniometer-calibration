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

source objectivefn.m

function [y,z] = gpartition (x)
  ## usage:  [y,z] = gpartition (x)
  ##
  ## 
  r=rows(x);
  c=columns(x);
  z=[r*ones(1,c/3);3*ones(1,c/3)];
  y=[];
  for i=1:3:c
    y=[y;x(:,i:i+2)];
  endfor
endfunction


function [L,obj,info,iter,nf,lambda,cons] = goniometer (filename,niter=45,epsilon=1e-8)
  ## usage:  goniometer ()
  ##
  ## goniometer_file="goniometer.dat";
  global objectivefn_data objectivefn_lines objectivefn_partition;
  goniometer_data=read_goniometer_data(filename)
  [objectivefn_data,objectivefn_partition]=gpartition(goniometer_data);
  goniometer_rebase_zdata()
  make_objectivefn_lines();
  L0=reshape(objectivefn_lines(1:2,:)',6,1)
  L0=L0 + 1e-2*norm(L0)*randn(6,1)
  [L,obj,info,iter,nf,lambda]=line_estimator(L0,[],[],niter,epsilon)
  cons=constraintfn(L)
endfunction
## from Octave manual page on `sqp':
%!test
%! epsilon=1e-7;
%! x_e   = [-1.717143501952599;
%!           1.595709610928535;
%!           1.827245880097156;
%!          -0.763643103133572;
%!          -0.763643068453300];
%!
%! obj_e = 0.0539498477702739;
%! info_e=101;
%! iter_e=8;
%! nf_e=10;
%! lambda_e=[-0.0401627;0.0379578;-0.0052227];
%! g=@(x) [ sumsq(x)-10;x(2)*x(3)-5*x(4)*x(5);x(1)^3+x(2)^3+1 ];
%! phi=@(x) exp(prod(x)) - 0.5*(x(1)^3+x(2)^3+1)^2;
%! x0=[-1.8; 1.7; 1.9; -0.8; -0.8];
%! [x, obj, info, iter, nf, lambda] = sqp (x0, phi, g, []);
%! assert(norm(x - x_e),0,epsilon)
%! assert(norm(obj - obj_e),0,epsilon)
## bugs in sqp.m:
%! assert((info==info_e || info==0),1==1)
%! assert((iter==iter_e || iter==iter_e+1),1==1)
%! assert((nf==nf_e || nf==nf_e-1),1==1)
%! assert(norm(lambda - lambda_e),0,epsilon)
####from /usr/local/share/octave/3.2.4/m/optimization/sqp.m
%!function r = g (x)
%!  r = [sumsq(x)-10;
%!       x(2)*x(3)-5*x(4)*x(5);
%!       x(1)^3+x(2)^3+1 ];
%!
%!function obj = phi (x)
%!  obj = exp(prod(x)) - 0.5*(x(1)^3+x(2)^3+1)^2;
%!
%!test
%! x0 = [-1.8; 1.7; 1.9; -0.8; -0.8];
%!
%! [x, obj, info, iter, nf, lambda] = sqp (x0, @phi, @g, []);
%!
%! x_opt = [-1.717143501952599;
%!           1.595709610928535;
%!           1.827245880097156;
%!          -0.763643103133572;
%!          -0.763643068453300];
%!
%! obj_opt = 0.0539498477702739;
%!
%! assert (all (abs (x-x_opt) < 5*sqrt (eps)) && abs (obj-obj_opt) < sqrt (eps));

function goniometer_rebase_zdata ()
  ## usage:  goniometer_rebase_zdata ()
  ##
  ## 
  global objectivefn_data;
  r=rows(objectivefn_data);
  c=columns(objectivefn_data);
  for i=1:r
    for j=1:c
      x=objectivefn_data(i,j);
      x=ifelse(x>1e6,mod(x,10000),x) * 1e-3;
      objectivefn_data(i,j)=x;
    endfor
  endfor
endfunction

## end of goniometer.m
