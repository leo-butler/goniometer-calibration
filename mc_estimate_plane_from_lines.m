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
## usage:  mc = mc_estimate_plane_from_lines (n,sigma,)
##
## n			-> a structure array containing the fields:
##  ndraws		-> number of draws in m/c
##  ndraws_per_line	-> number of draws/sample around each line
##  plane		-> fixed plane (if false, this will be selected at random)
##  sigma		-> standard deviation of 3-d gaussian
##  tsigma		-> standard deviation of 1-d gaussian along line
##  focal_depths	-> 1xK row vector of focal depths
## 
##
## mc		-> a structure array containing the information about the Monte Carlo

function mc = mc_estimate_plane_from_lines (n,sigma,tsigma)
  global planar_line_data;
  global focal_plane_normal;
  global focal_plane_normal_t;
  global focal_plane_depths;
  mc.focal_plane_normal=focal_plane_normal=[0;0;1];
  focal_plane_normal_t=focal_plane_normal';
  mc.focal_plane_depths=focal_plane_depths=n.focal_depths;
  mc.ndraws=ndraws=n.ndraws;
  mc.ndraws_per_line=ndraws_per_line=n.ndraws_per_line;
  nlines=columns(focal_plane_depths);
  mc.plane=plane=n.plane;

  mc.P_hat=zeros(4,ndraws);
  mc.obj=zeros(1,ndraws);
  mc.info=zeros(1,ndraws);
  mc.iter=zeros(1,ndraws);
  mc.nf=zeros(1,ndraws);
  mc.lambda=zeros(9,ndraws);

  i=1;
  while i<=ndraws
    try
      lines=__lines (plane,focal_plane_depths,focal_plane_normal);
      planar_line_data=__planar_line_data  (lines,ndraws_per_line,focal_plane_depths,focal_plane_normal,sigma,tsigma);
      (mc.planar_line_data){i}=planar_line_data;
      P0=__planes(1,1);
      [P_hat,obj,info,iter,nf,lambda] = estimate_plane_from_lines (P0);
      if info==101
	(mc.P_hat)(:,i)=P_hat;
	(mc.obj)(i)=obj;
	(mc.info)(i)=info;
	(mc.iter)(i)=iter;
	(mc.nf)(i)=nf;
	(mc.lambda)(:,i)=lambda;
	++i;
      else
	(mc.warning_or_error){i}=sprintf("%s\nestimate_plane_from_lines returned info=%d. Redoing step=%d...\n",(mc.warning_or_error){i},info,i);
      endif
    catch
      (mc.warning_or_error){i}=lasterror();
    end_try_catch
  endwhile
endfunction

%!test
%! global oriented_plane;
%! epsilon=1e-1;
%! oriented_plane=0;
%! plane=[1;-1;5;3]/sqrt(1+1+25);
%! sigma0=epsilon*eye(3);
%! sigma={sigma0,sigma0,sigma0};
%! tsigma=[1,1,1];
%! focal_depths=10:10:20;
%! ndraws=20;
%! ndraws_per_line=5*ones(1,3);
%! n=struct("ndraws",ndraws,"ndraws_per_line",ndraws_per_line,"focal_depths",focal_depths,"plane",plane,"sigma",sigma,"tsigma",tsigma);
%! mc=mc_estimate_plane_from_lines(n,sigma,tsigma);
%! assert(plane,(mc.P_hat)(:,1),10*epsilon);
%! assert(plane,(mc.P_hat)(:,2),10*epsilon);
%! assert((mc.info)(1),101);
%! assert((mc.info)(2),101);
%! plot3((mc.P_hat')(:,1),(mc.P_hat')(:,2),(mc.P_hat')(:,3),'+');

function planes = __planes (nplanes,sigma=1)
  ## usage:  planes = __planes (nplanes,sigma)
  ##
  ## nplanes	-> number of planes
  ## sigma	-> st.dev. of contstants
  ##
  ## planes	-> 4 x nplanes matrix of planes
  normals=randn(3,nplanes);
  constants=sigma*randn(1,nplanes);
  for i=1:nplanes
    normals(:,i)/=norm(normals(:,i),2);
  endfor
  planes(1:3,:)=normals;
  planes(4,:)=constants;
endfunction
%!test
%! p=__planes(1);
%! assert(norm(p(1:3,1),2),1,1e-8);


function lines = __lines (plane,focal_depths,focal_normal)
  ## usage:  lines = __lines (plane,focal_depths,focal_normal)
  ##
  ## plane		-> a 4x1 plane vector
  ## focal_depths	-> 1xK vector of focal depths
  ## focal_normal	-> the normal to focal plane
  ## 
  ## lines		-> 6xK matrix of lines where the plane intersects the focal_plane at focal_depths.
  P=plane;
  n=columns(focal_depths);
  lines=zeros(6,n);
  for i=1:n
    f=focal_depths(i);
    Q=[focal_normal;f];
    L=intersection_line(P,Q);
    L=reshape(L',6,1);
    lines(:,i)=L;
  endfor
endfunction
%!test
%! plane=[1;2;3;4]/sqrt(14);
%! focal_depths=0:5;
%! focal_normal=[0;0;1];
%! __lines(plane,focal_depths,focal_normal)


function pld = __planar_line_data (lines,ndraws_per_line,focal_depths,focal_normal,sigma,tsigma)
  ## usage:  pld = __planar_line_data  (lines,ndraws_per_line,focal_depths,focal_normal,sigma,tsigma)
  ##
  ## lines		-> 6xK matrix of coplanar lines
  ## ndraws_per_line		-> 1xK matrix of draws for each line
  ## focal_depths	-> 1xK matrix of focal depths
  ## focal_normal	-> unit normal of the focal plane (column vector)
  ## sigma		-> cell array of 3x3 covariance matrices
  ## tsigma		-> 1xK st. devns
  ##
  ## pld		-> a cell array containing 3 x ndraws_per_line(i) matrix of data
  k=columns(lines);
  normal=lines(4:6,1);
  focal_normal_t=focal_normal';
  for i=1:k
    n=ndraws_per_line(i);
    p=lines(1:3,i)*ones(1,n);
    tv=normal*tsigma(i)*randn(1,n);
    l=p+tv;
    r=sigma{i}*randn(3,n);
    d=l+r;
    fd=focal_normal_t*d;
    d=d+focal_normal*(-fd+focal_depths(i)*ones(1,n));
    pld{i}=d;
  endfor
endfunction
%!test
%! lines=[1,2;2,2;3,2;0,0;0,0;1,1];
%! ndraws=5;
%! ndraws_per_line=[5,5];
%! focal_depths=[-1,1];
%! focal_normal=[0;0;1];
%! sigma={eye(3),eye(3)};
%! tsigma=[1,1];
%! __planar_line_data(lines,ndraws_per_line,focal_depths,focal_normal,sigma,tsigma)

                                #  end of mc_estimate_plane_from_lines.m 
