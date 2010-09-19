## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id:$
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

function plane = plane2lines (p)
  ## usage:  plane = lines (p)
  ##
  ## p = n x 3 data vector segregated by z values
  zvals=unique(p(:,3));
  clear plane;
  plane.z=zvals;
  n=length(zvals);
  (plane.lines){n}=[];
  for r=p'
    z=r(3);
    i=find(plane.z == z);
    (plane.lines){i}=[(plane.lines){i},r];
  endfor
  for i=1:length(plane.lines)
    (plane.lines){i}=(plane.lines){i}';
  endfor
endfunction
%!test
%! p=[1,1,1;1,2,1; 1,1,3; 2,4,5;2,3,5 ];
%! pl=plane2lines(p);
%! pl_exp.z=[1;3;5];
%! (pl_exp.lines){1}=[1,1,1;1,2,1];
%! (pl_exp.lines){2}=[1,1,3];
%! (pl_exp.lines){3}=[2,4,5;2,3,5];
%! assert(pl,pl_exp);


function plane = read_goniometer_data_as_lines (filename)
  ## usage:  plane = read_goniometer_data_as_lines (filename)
  ##
  ## plane = struct containing z-values and array of matrices
  ##         with points on lines
  p=read_goniometer_data(filename,"csv");
  plane=plane2lines(p);
  plane.filename=filename;
endfunction
%!test
%! filename="~/svn-ecdf/goniometer-calibration/dir+/deg-45-zyx.csv";
%! filename="gtest.csv";
%! plane=read_goniometer_data_as_lines(filename);
%! plane_exp.filename=filename;
%! plane_exp.z=[85019];
%! (plane_exp.lines){1}=[
%! 362.800,1.900,85019;
%! 468.278,1.056,85019;
%! 1239.917,3.708,85019;
%! 724,3,85019;
%! 1725.133,6.533,85019;
%! 2040.667,5.167,85019;
%! 1877.426,7.944,85019;
%! 522.750,6.750,85019;
%! 662,9.318,85019;
%! 1274.660,11.180,85019];
%! assert(plane,plane_exp);


function [y,a,b] = projection_onto_line (x,L,normalise=1)
  ## usage:  y = projection_onto_line (x,L,normalise=1)
  ##
  ## x = point = 1x3 vector
  ## L = line  = 2x3 vector = [p;v]
  ##     where p = point closest to 0 on L,
  ##           v = unit direction vector
  ## y = projection of x onto L
  ## a = x-p, b = y-p
  if size(L)==[6,1]
    p=L(1:3)';
    v=L(4:6)';
  elseif size(L)==[1,6]
    p=L(1:3);
    v=L(4:6);
  elseif size(L)==[2,3]
    p=L(1,:);
    v=L(2,:);
  endif
  #normalise v and p if needed
  if normalise
    v/=norm(v);
    p=p-(v*p')*v;
  endif
  a=x-p;
  b=(v*a')*v;
  y=p+b;
endfunction
%!test
%! eps=1e-8;
%! x=[1,2,4];
%! L=[1,1,-1;1/sqrt(2),0,1/sqrt(2)];
%! [y,a,b]=projection_onto_line(x,L);
%! p=L(1,:);
%! a_exp=x-p;
%! b_exp=L(2,:)*5/sqrt(2);
%! y_exp=p+b_exp;
%! assert(y_exp,y,eps);
%! assert(a_exp,a,eps);
%! assert(b_exp,b,eps);

function d = dpoint2line (x,L,normalise=1)
  ## usage:  d = dpoint2line (x,L,normalise=1)
  ##
  [y,a,b]=projection_onto_line(x,L,normalise);
  d=norm(a-b,2);
endfunction
%!test
%! x=[1,1,-4];
%! L=[1,1,-1;1/sqrt(2),0,1/sqrt(2)];
%! d=dpoint2line(x,L);
%! d_exp=3/sqrt(2);
%! assert(d,d_exp,1e-10);
%! L=[1,1,-1,1/sqrt(2),0,1/sqrt(2)];
%! d=dpoint2line(x,L);
%! d_exp=3/sqrt(2);
%! assert(d,d_exp,1e-10);
%! L=[1,1,-1,1/sqrt(2),0,1/sqrt(2)];
%! d=dpoint2line(x,L,0);
%! d_exp=3/sqrt(2);
%! assert(d,d_exp,1e-10);
function d = dpoint2plane (x,P,normalise=1)
  ## usage:  d = dpoint2plane (x,P,normalise=1)
  ##
  n=P(1:3);
  c=P(4);
  if normalise
    n/=norm(n,2);
  endif
  d=abs(x*n'-c);
endfunction
%!test
%! x=[1,1,-1];
%! P=[1,1,-1,3]/sqrt(3);
%! d=dpoint2plane(x,P);
%! d_exp=0;
%! assert(d,d_exp,1e-10);
%! x=[-1,1,0];
%! d=dpoint2plane(x,P);
%! d_exp=sqrt(3);
%! assert(d,d_exp,1e-10);
%! P=[1,1,-1,4];
%! d=dpoint2plane(x,P,0);
%! d_exp=4;
%! assert(d,d_exp,1e-10);

global line_objectivefn_data;
function t = line_objectivefn (L,normalise=1)
  ## usage:  t = line_objectivefn (L,normalise=1)
  ##
  ## 
  global line_objectivefn_data;
  if size(L)==[6,1]
    p=L(1:3)';
    v=L(4:6)';
  elseif size(L)==[1,6]
    p=L(1:3);
    v=L(4:6);
  elseif size(L)==[2,3]
    p=L(1,:);
    v=L(2,:);
  endif
  #normalise v and p if needed
  if normalise
    v/=norm(v);
    p=p-(v*p')*v;
  endif
  t=0;
  # we never normalise in dpoint2line, because if we wanted
  # to do so, we would have done so already
  normalise=0;
  for x=line_objectivefn_data'
    t+=dpoint2line(x',L,normalise)^2;
  endfor
endfunction
%!test
%! global line_objectivefn_data;
%! line_objectivefn_data=[1,1,1; 2,2,2; 3,3,3];
%! L=[0,0,0; 1,1,1]/sqrt(3);
%! t=line_objectivefn(L);
%! assert(t,0,1e-12);
%! line_objectivefn_data=[1,1,1; 2,2,2; 3,3,4];
%! t=line_objectivefn(L);
%! d=dpoint2line([3,3,4],L)^2;
%! assert(t,d,1e-12);

global line_scalar_constraint line_planar_constraint;
function C = line_constraintfn (L)
  ## usage:  C = line_constrainfn (L)
  ##
  ## 
  global line_scalar_constraint line_planar_constraint;
  if size(L)==[6,1]
    p=L(1:3)';
    v=L(4:6)';
  elseif size(L)==[1,6]
    p=L(1:3);
    v=L(4:6);
  elseif size(L)==[2,3]
    p=L(1,:);
    v=L(2,:);
  endif
  if line_scalar_constraint && line_planar_constraint
    C = [ (norm(v)^2-1)^2 + (p * v')^2 + p(3)^2 + v(3)^2  ];
  elseif (!line_scalar_constraint) && line_planar_constraint
    C = [ (norm(v)^2-1)^2 ; (p * v')^2 ; p(3)^2 ; v(3)^2  ];
  elseif line_scalar_constraint && (!line_planar_constraint)
    C = [ (norm(v)^2-1)^2 + (p * v')^2 ];
  else
    C = [ (norm(v)^2-1)^2 ; (p * v')^2 ];
  endif
endfunction
%!test
%! L=[1,2,3; 4,5,6];
%! global line_scalar_constraint line_planar_constraint;
%! line_scalar_constraint=0;
%! line_planar_constraint=1;
%! c=ifelse(line_scalar_constraint,[(4^2+5^2+6^2-1)^2 + (1*4+2*5+3*6)^2 + 3^2 + 6^2],[(4^2+5^2+6^2-1)^2 ;  (1*4+2*5+3*6)^2;  3^2;  6^2]);
%! epsilon=1e-10;
%! assert(line_constraintfn(L), c, epsilon);
%! L=[1;2;3; 4;5;6];
%! assert(line_constraintfn(L), c, epsilon);
%! L=[1,2,3, 4,5,6];
%! assert(line_constraintfn(L), c, epsilon);
%! line_scalar_constraint=1;
%! c=ifelse(line_scalar_constraint,[(4^2+5^2+6^2-1)^2 + (1*4+2*5+3*6)^2 + 3^2 + 6^2],[(4^2+5^2+6^2-1)^2 ;  (1*4+2*5+3*6)^2;  3^2;  6^2]);
%! epsilon=1e-10;
%! assert(line_constraintfn(L), c, epsilon);
%! L=[1;2;3; 4;5;6];
%! assert(line_constraintfn(L), c, epsilon);
%! L=[1,2,3, 4,5,6];
%! assert(line_constraintfn(L), c, epsilon);
%! line_scalar_constraint=0;
%! line_planar_constraint=0;
%! c=ifelse(line_scalar_constraint,[(4^2+5^2+6^2-1)^2 + (1*4+2*5+3*6)^2 ],[(4^2+5^2+6^2-1)^2 ;  (1*4+2*5+3*6)^2 ]);
%! epsilon=1e-10;
%! assert(line_constraintfn(L), c, epsilon);
%! L=[1;2;3; 4;5;6];
%! assert(line_constraintfn(L), c, epsilon);
%! L=[1,2,3, 4,5,6];
%! assert(line_constraintfn(L), c, epsilon);
%! line_scalar_constraint=1;
%! c=ifelse(line_scalar_constraint,[(4^2+5^2+6^2-1)^2 + (1*4+2*5+3*6)^2 ],[(4^2+5^2+6^2-1)^2 ;  (1*4+2*5+3*6)^2 ]);
%! epsilon=1e-10;
%! assert(line_constraintfn(L), c, epsilon);
%! L=[1;2;3; 4;5;6];
%! assert(line_constraintfn(L), c, epsilon);
%! L=[1,2,3, 4,5,6];
%! assert(line_constraintfn(L), c, epsilon);

## note this name clashes with function in objectivefn.m
function [L,obj,info,iter,nf,lambda] = line_estimator (L0,LUP=[],LOW=[],maxiter=125,epsilon=1e-6)
  ## usage:  [L,obj,info,iter,nf,lambda] = line_estimator (L0,LUP,LOW,maxiter,epsilon)
  ##
  ## estimates L given L0 (a 6x1 column vector)
  [L,obj,info,iter,nf,lambda]=sqp(L0,@line_objectivefn,@line_constraintfn,[],LUP,LOW,maxiter,epsilon);
endfunction
%!test
%! leps=1e-5;
%! global line_objectivefn_data line_planar_constraint;
%! line_planar_constraint=0;
%! line_objectivefn_data=[1,1,1; 2,2,2; 3,3,3];
%! L0=[0;0;0; 0;0;1];
%! [L,obj,info,iter,nf,lambda]=line_estimator(L0);
%! L_exp=[0;0;0;1;1;1]/sqrt(3);
%! con=constraintfn(L);
%! assert(norm(L-L_exp),0,leps);
%! assert(con,[0;0],leps);
%! line_objectivefn_data=4+[1,1,-2; 2,2,-4; 3,3,-6];
%! L0=[0;0;0; 0;0;1];
%! [L,obj,info,iter,nf,lambda]=line_estimator(L0);
%! c=1/sqrt(1+1+2^2);
%! L_exp=[4;4;4;-c;-c;2*c];
%! con=constraintfn(L);
%! assert(line_obj(L,L_exp),0,leps);
%! assert(con,[0;0],leps*2);
%!test
%! leps=1e-5;
%! global line_objectivefn_data line_planar_constraint line_scalar_constraint;
%! line_planar_constraint=1;
%! line_scalar_constraint=0;
%! line_objectivefn_data=[1,1,0; 2,2,0; 3,3,0];
%! L0=[0;0;0; 0;1;0];
%! [L,obj,info,iter,nf,lambda]=line_estimator(L0);
%! L_exp=[0;0;0;1;1;0]/sqrt(2);
%! con=line_constraintfn(L);
%! assert(norm(L-L_exp),0,leps);
%! assert(con,[0;0;0;0],leps);
%! line_objectivefn_data=4+[1,-1,-4; 2,-2,-4; 3,-3,-4];
%! L0=[0;0;0; 1;0;0];
%! [L,obj,info,iter,nf,lambda]=line_estimator(L0);
%! c=1/sqrt(1+1);
%! L_exp=[4;4;0;c;-c;0];
%! con=line_constraintfn(L);
%! assert(line_obj(L,L_exp),0,leps);
%! assert(con,[0;0;0;0],leps*2);


#  end of plane2lines.m 
