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

niter=25;
epsilon=1e-8;

goniometer_file="goniometer.dat";
goniometer_data=read_goniometer_data(goniometer_file)
[objectivefn_data,objectivefn_partition]=gpartition(goniometer_data)
make_objectivefn_lines();
L0=reshape(objectivefn_lines(1:2,:)',6,1);
[L,obj,info,iter,nf,lambda]=line_estimator(L0,[],[],niter,epsilon)


## end of goniometer.m
