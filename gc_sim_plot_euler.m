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

function fig = gc_sim_plot_euler (gcdata,f=0,with_projections=true,demean=false)
  ## get figure
  if !isfigure(f)
    fig=figure();
  else
    fig=f;
  endif

  ## compute Euler angles and radii
  if isfield(gcdata,"euler_coordinates")
    ec=gcdata.euler_coordinates;
  else
    ec=mapv(@euler_coordinates,gcdata.lest,4);
  endif
  angles=mapv(@(x) x(1:3),ec,3);
  mec=euler_coordinates(gcdata.mean);
  estec=euler_coordinates(gcdata.estimate.l);
  if demean
    angles=mapv(@(x) x(1:3)-mec(1:3),ec,3);
    estec-=mec;
    mec*=0;
  endif
  covec=cov(ec');
  [cec,eec]=eig(covec);

  ##
  plotit=@() \
      [plot3(angles(1,:),angles(2,:),angles(3,:),'.',"markersize",5), \
       text(mec(1),mec(2),mec(3),'o',"color","red","fontsize",12,"horizontalalignment","center"), \
       text(estec(1),estec(2),estec(3),'x',"color","black","fontsize",12,"horizontalalignment","center"), \
				#set(gca,"fontsize",6), \
       xlabel("$&alpha$"), \
       ylabel("$&beta$"), \
       zlabel("$&gamma$")]; 

  if with_projections
    subplot(2,2,1);
    ## plot estimates
    plotit();
    for i=1:3
      subplot(2,2,i+1);
      plotit();
      view(cec(1:3,i));
    endfor
  else
    plotit();
  endif
endfunction

#  end of gc_sim_plot_euler.m 
