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

function [gc,draws] = gc_adaptive_sim (globs,tol=1e-8,mdraws=[1e2,1e5,1e2],choices=false)
  rel_diff=@(y,x) norm(y-x,2)/(1+norm(x,2));
  rel_err=1;
  cov0=eye(6);
  total_draws=draws=mdraws(1);maxdraws=mdraws(2);incdraws=mdraws(3);
  gc=gc_sim(globs,draws,choices);
  while rel_err>tol && total_draws<=maxdraws
    cov0=gc{1}.cov;
    gc=gc_sim(gc,incdraws,choices);
    cov1=gc{1}.cov;
    rel_err=rel_diff(cov1,cov0)
    total_draws+=incdraws;
  endwhile
  draws-=incdraws;
endfunction
#  end of gc_adaptive_sim.m 
