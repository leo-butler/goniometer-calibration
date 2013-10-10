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

function mc=mc_show_sim (draws=10,N=10,outputfile="mc_show_sim.pdf")
  ## planes=[
  ##         7.722791119015323e-01   7.432524879698396e-01  7.671600679359990e-01   7.740787097018144e-01
  ##         1.293143839128205e-01   1.476227758699384e-01  1.495409925282991e-01   1.361551966058006e-01
  ##         6.219829285710566e-01  -6.525206932895672e-01  6.237811488960568e-01  -6.182749498593729e-01
  ##         5.242428822736285e+04  -5.597573885161478e+04  5.262569366336065e+04  -5.300135529719507e+04
  ## 	  ];
  c=1/sqrt(2); kappa=5e4;
  planes=[c,0,c,kappa; c,0,-c,-kappa; c,0,c,kappa; c,0,-c,-kappa]';
  focal_plane_normal=[0;0;1];
  focal_depths={
		[81659   82411   82811   83467   83851],
		[86267   86283   87131   88027],
		[81915   83179   83867   83899],
		[86155   86219   87131   88091]
		};
  sigmas={
	  diag([15 15 130]),
	  diag([15 15 130]),
	  diag([17 17 130]),
	  diag([5  5  130])
	  };
  choices=[1,2; 1,4; 3,2; 3,4];
  plds=mc_planar_line_data(planes,focal_depths,focal_plane_normal,N,0);
  for i=1:length(sigmas)
    plds{i}.sigma=sigmas{i};
  endfor
  [l,L,P,G,Lbar,d] = estimator_closed_form(plds,focal_plane_normal,1e-9,1,choices);
  gc{1}.planar_line_data_str=plds;
  gc{1}.estimate=struct("l",l,"L",L,"P",P,"G",G,"Lbar",Lbar,"d",d);
  gc{1}.est={};
  gc{1}.choices=choices;
  mc=gc_sim(gc,draws,choices);
  ## plot results
  clf("reset");
  gc_sim_plot(mc{1});
  text(1.573,1.5725,sprintf("Actual=(%.5f,%.5f)",pi/2,pi/2));
  print(outputfile);
endfunction

#  end of mc_show_sim.m 
