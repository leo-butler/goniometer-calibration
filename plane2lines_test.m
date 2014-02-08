## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id:$
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

source plane2lines.m

filename="~/svn-ecdf/goniometer-calibration/dir+/deg+45-xyz.csv";
tpe="csv";


function plane = compute_lines (filename)
  ## usage:  plane = compute_lines (filename)
  ##
  ## 
  plane=read_goniometer_data_as_lines(filename);
  plane.filename=filename;
  global line_objectivefn_data line_planar_constraint;
  line_planar_constraint=1;
  for i=1:length(plane.lines)
    z=(plane.z)(i)
    line_objectivefn_data=(plane.lines){i};
    line_objectivefn_data(:,3)-=z;
    line_objectivefn_data/=1;
    y=line_objectivefn_data(:,2);
    x=[line_objectivefn_data(:,1),0*y+1];
    params=ols(y,x)
    (plane.ols_params){i}=params;
    m=params(1);
    b=params(2);
    p=[0,b,0];
    v=[1,m,0]/sqrt(1+m^2);
    p=p-(v*p')*v;
    L0=[p,v];
    [L,obj,info,iter,nf,lambda]=line_estimator(L0)
    con=line_constraintfn(L)
    (plane.L){i}=L;
    (plane.obj){i}=obj;
    (plane.info){i}=info;
    (plane.iter){i}=iter;
    (plane.nf){i}=nf;
    (plane.lambda){i}=lambda;
  endfor
endfunction

function x = vprojection_onto_line (x,L,normalise=1)
  ## usage:  x = vprojection_onto_line (x,L,normalise=1)
  ##
  ## 
  for i=1:rows(x)
    x(i,:)=projection_onto_line(x(i,:),L,normalise);
  endfor
endfunction

function t = olsplot (plane)
  ## usage:  t = olsplot (plane)
  ##
  ## plane should be a cellstructure
  ## generated by compute_lines
  n=length(plane.lines);
  for i=1:n
    L=(plane.L){i};
    line_objectivefn_data=(plane.lines){i};
    y=line_objectivefn_data(:,2);
    x=line_objectivefn_data(:,1);
    x1=[x,0*x+1];
    params=(plane.ols_params){i};
    ols_line=x1*params;
    cls_x=vprojection_onto_line(line_objectivefn_data,L);
    x_cls=cls_x(:,1);
    y_cls=cls_x(:,2);
    subplot(n,1,i);
    hold on;
    z=(plane.z)(i);
    legend(strcat("z=",num2str(z)),"green=ols","red=cls");
    plot(x,y,'+',x,ols_line,"g",x_cls,y_cls,"r");
  endfor
endfunction



#save -text "~/svn-ecdf/goniometer-calibration/dir+/deg+45-xyz.dat" plane

				#  end of plane2lines_test.m 
