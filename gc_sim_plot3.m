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
function gc_sim_plot3 (gcdata,dx_dy_dz_scale=[2,3,3],conf_scale=1.7)
  ## helper functions
  pline=@(A,B) line([A(1),B(1)],[A(2),B(2)],[A(3),B(3)],"color","black");
  invnormcdf=@(p) norminv(0.5*(1+p));
  onesidepercentage=@(x,y) sum(sum(x<=abs(y)),2)/columns(x)/rows(x);
  problevel=@(p,x,w) fzero(@(y) onesidepercentage(x,y)-p,w);
  text=@(x) 0;

  ## convert data
  pts=gcdata.lest(1:3,:);
  m_pts=gcdata.mean(1:3);
  est=gcdata.estimate.l(1:3);
  [cov_pts,eig_pts]=eig(cov(pts'));
  c_pts(1)=sqrt(eig_pts(1,1)); c_pts(2)=sqrt(eig_pts(2,2)); c_pts(3)=sqrt(eig_pts(3,3));
  dx=dx_dy_dz_scale(1)*csc(1); dy=dx_dy_dz_scale(2)*c_pts(2); dz=dx_dy_dz_scale(3)*c_pts(3);

  ##
  ## clf("reset");
  hold on;
  plot3(pts(1,:)',pts(2,:)',pts(3,:)','.');
  text(est(1)+dx,est(2)+dy,est(3)+dz,sprintf("Draws=%g\nEstimate=(%.1f,%.1f,%.1f)\nMean=(%.1f,%.1f,%.1f)\nStDev=(%.1f,%.1f,%.1f)\n",columns(pts),est(1),est(2),est(3),m_pts(1),m_pts(2),m_pts(3),c_pts(1),c_pts(2),c_pts(3)));

  ## axes of 2 stdev ellipse
  n5c=invnormcdf(0.95);
  n5c=problevel(0.95,sqrt(sum((pts-est).*(inv(cov(pts'))*(pts-est)))),[0,10]);
  delta1=c_pts(1)*cov_pts*[1;0;0];
  axis1_x=est-n5c*delta1;
  axis1_y=est+n5c*delta1;
  fig=pline(axis1_x,axis1_y);
  set(fig,"linewidth",3);
  delta2=c_pts(2)*cov_pts*[0;1;0];
  axis2_x=est-n5c*delta2;
  axis2_y=est+n5c*delta2;
  fig=pline(axis2_x,axis2_y);
  set(fig,"linewidth",3);
  delta3=c_pts(3)*cov_pts*[0;0;1];
  axis3_x=est-n5c*delta3;
  axis3_y=est+n5c*delta3;
  fig=pline(axis3_x,axis3_y);
  set(fig,"linewidth",3);

  ##
  t=0:1/16:2;
  s=0:1/8:1;
  for r=s
    x=est+n5c*(sin(pi*r)*(cos(pi*t).*delta1+sin(pi*t).*delta2) + cos(pi*r)*delta3);
    plot3(x(1,:),x(2,:),x(3,:),"color","red","linewidth",3);
  endfor

  ##
  # text(m_pts(1),m_pts(2),'o',"color","red","fontsize",12,"horizontalalignment","center");
  # text(est(1),est(2),'x',"color","black","fontsize",12,"horizontalalignment","center");
  # if conf_scale
  #   text(est(1)+conf_scale*n5c*delta1(1),est(2)+conf_scale*n5c*delta1(2),"95% confidence\nellipse","fontsize",12);
  # endif
  hold off;

endfunction

#  end of gc_plots.m 
