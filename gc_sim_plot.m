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
## [gc2,draws]=gc_adaptive_sim(cellfun(@(x) sprintf("/home/work/svn-ecdf/goniometer-calibration/%s",x), {"dir-/deg[+-]*.csv","dir+/deg[+-]*.csv","dir/deg[+-]*.csv"},'UniformOutput',false),1e-2,[2900,5000,100]);

function fig = gc_sim_plot (gcdata,dx_dy_scale=[2,3],conf_scale=1.7)
  ## helper functions
  pline=@(A,B) line([A(1),B(1)],[A(2),B(2)]);
  invnormcdf=@(p) norminv(0.5*(1+p));
  twosidepercentage=@(x,y) sum(sum(x<=abs(y))+sum(x>=-abs(y)),2)/columns(x)/rows(x);
  onesidepercentage=@(x,y) sum(sum(x<=abs(y)),2)/columns(x)/rows(x);
  problevel=@(p,x,w) fzero(@(y) onesidepercentage(x,y)-p,w);
  text=@(x) 0;

  ## convert data
  sc=to_spherical_coordinates(gcdata.lest(4:6,:),true);
  msc=to_spherical_coordinates(gcdata.mean(4:6),true);
  estsc=to_spherical_coordinates(gcdata.estimate.l(4:6),true);
  [covsc,eigsc]=eig(cov(sc'));
  csc(1)=sqrt(eigsc(1,1)); csc(2)=sqrt(eigsc(2,2));
  dx=dx_dy_scale(1)*csc(1); dy=dx_dy_scale(2)*csc(2);

  ##
  ## clf("reset");
  hold on;
  xlabel("azimuthal angle");
  ylabel("polar angle");
  text(estsc(1)+dx,estsc(2)+dy,sprintf("Draws=%g\nEstimate=(%.5f,%.5f)\nMean=(%.5f,%.5f)\nStDev=(%.5f,%.5f)\n",columns(sc),estsc(1),estsc(2),msc(1),msc(2),csc(1),csc(2)));
  plot(sc(1,:)',sc(2,:)','.',"markersize",5);

  ## axes of 2 stdev ellipse
  try
    n5c=problevel(0.95,sqrt(sum((sc-estsc).*(inv(cov(sc'))*(sc-estsc)))),[0,10]);
  catch
    n5c=invnormcdf(0.95);
  end_try_catch
  delta1=csc(1)*covsc*[1;0];
  axis1_x=estsc-n5c*delta1;
  axis1_y=estsc+n5c*delta1;
  fig=pline(axis1_x,axis1_y);
  set(fig,"linewidth",3);
  delta2=csc(2)*covsc*[0;1];
  axis2_x=estsc-n5c*delta2;
  axis2_y=estsc+n5c*delta2;
  fig=pline(axis2_x,axis2_y);
  set(fig,"linewidth",3);

  ##
  t=0:0.1:(2*pi+0.1);
  x=estsc+n5c*(cos(t).*delta1+sin(t).*delta2);
  plot(x(1,:),x(2,:),"color","red","linewidth",3);

  ##
  text(msc(1),msc(2),'o',"color","red","fontsize",12,"horizontalalignment","center");
  text(estsc(1),estsc(2),'x',"color","black","fontsize",12,"horizontalalignment","center");
  if conf_scale
    text(estsc(1)+conf_scale*n5c*delta1(1),estsc(2)+conf_scale*n5c*delta1(2),"95\\% confidence\nellipse","fontsize",12);
  endif
  hold off;

  fig=gcf();
endfunction

#  end of gc_plots.m 
