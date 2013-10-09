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

function fig = gc_plot_distance (gcdata,figre,normalize=false,yl=false,mean_position=false,two_sd=true)
  function [x,y,buttons] = getposn (message)
    t=title(sprintf("%s, then press RTN.",message));
    [x,y,buttons]=ginput(1);
    delete(t);
  endfunction

  if isfigure(figre)
    fig=figre;
  else
    fig=figure();
  endif
  estec=euler_coordinates(gcdata.estimate.l);
  ec=gcdata.euler_coordinates;
  if normalize
    ec=100*(ec - estec) ./ estec;
    estec*=0;
  endif
  sd=sqrt(cov(ec(4,:)'));
  mec=mean(ec,2);
  hold on;
  hist(ec(4,:),25,1,"facecolor","white","linewidth",3);
  line([estec(4),estec(4)],[0,1],"linewidth",3);
  line([mec(4),mec(4)],[0,1],"linewidth",3,"color","red");
  if normalize
    xlabel("radius (\\% deviation from true)");
  else
    xlabel("radius");
  endif
  if !yl
    [x,yl,buttons]=getposn("click at height");
  endif
  ylim([0 yl]);
  if !mean_position
    [x0,y0,buttons]=getposn("Position of label for mean");
    mean_position=[x0 y0];
  endif
  if two_sd
    line([mec(4)-2*sd,mec(4)-2*sd],[0,1]);
    line([mec(4)+2*sd,mec(4)+2*sd],[0,1]);
  endif
  q=quiver([mean_position(1)],[mean_position(2)],[-mean_position(1)]+mec(4),[0],"linewidth",3,"showarrowhead","off");
  text(mean_position(1),mean_position(2),"mean ","horizontalalignment","right");
  hold off;
endfunction
#  end of gc_plot_distance.m 
