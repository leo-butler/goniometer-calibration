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

function [fd,v,rho,plambda,t,w,costheta,sintheta] = frame_data (kappa,normal,focal_depth,focal_plane_normal)
  if iscell(focal_depth)
    ## Degenerate case when the focal_plane_normal and normal coincide, and there is a 
    ## single focal_depth. In this case, focal_depths should be a 2-element cell {kappa, v}.
    v=focal_depth{2};
    kappa=focal_depth{1};
    w=rho=vector_product(normal,v);
    plambda=kappa*normal;
    t=NaN;
    costheta=1; sintheta=0;
    fd=struct(
	      "focal_depth"		,focal_depth{1},
	      "focal_plane_normal"	,focal_plane_normal,
	      "kappa"			,kappa,
	      "normal"			,normal,
	      "v"			,v,
	      "rho"			,rho,
	      "plambda"			,plambda,
	      "t"			,t,
	      "w"			,w,
	      "costheta"		,costheta,
	      "sintheta"		,sintheta
	      );
  elseif isstruct(kappa)
    ## in this case, only the value of t and plambda are recomputed
    ## only when sintheta is not 0
    fd=kappa;
    if fd.sintheta!=0
      v=fd.v; rho=fd.rho; w=fd.w; costheta=fd.costheta; sintheta=fd.sintheta;
      fd.t=t=(fd.focal_depth - fd.kappa*costheta)/sintheta;
      fd.plambda=plambda=fd.kappa*fd.normal+t*rho;
    endif
  else
    normalize=@(x) x/norm(x,2);
    v=normalize(vector_product(focal_plane_normal,normal));
    rho=normalize(vector_product(normal,v));
    ##
    costheta=focal_plane_normal'*normal;
    sintheta=focal_plane_normal'*rho;
    t=(focal_depth - kappa*costheta)/sintheta;
    w=-normal*sintheta+rho*costheta;
    plambda=kappa*normal+t*rho;
    fd=struct(
	      "focal_depth"		,focal_depth,
	      "focal_plane_normal"	,focal_plane_normal,
	      "kappa"			,kappa,
	      "normal"			,normal,
	      "v"			,v,
	      "rho"			,rho,
	      "plambda"			,plambda,
	      "t"			,t,
	      "w"			,w,
	      "costheta"		,costheta,
	      "sintheta"		,sintheta
	      );
  endif
endfunction
%!shared epsilon, fd, normal, focal_plane_normal
%!test
%! epsilon=1e-10; normal=[0;1;1]/sqrt(2); focal_plane_normal=[0;0;1];
%! [fd,v,rho,plambda,t,w]=frame_data(0,normal,1,focal_plane_normal);
%! assert(norm(v-[-1;0;0],2),0)
%! assert(norm(rho-[0;-1;1]/sqrt(2),2),0,epsilon)
%! assert(abs(t-sqrt(2)),0,epsilon)
%! assert(norm(plambda-t*rho,2),0,epsilon)
%! assert(norm(w-[0;-1;0],2),0,epsilon)
%!xtest
%! fd.focal_depth=2;
%! [fd,v,rho,plambda,t,w]=frame_data(fd,normal,1,focal_plane_normal);
%! assert(norm(v-[-1;0;0],2),0)
%! assert(norm(rho-[0;-1;1]/sqrt(2),2),0,epsilon)
%! assert(abs(t-2*sqrt(2)),0,epsilon)
%! assert(norm(plambda-t*rho,2),0,epsilon)
%! assert(norm(w-[0;-1;0],2),0,epsilon)
%!test
%! focal_depth={pi,[-1;0;0]};
%! [fd,v,rho,plambda,t,w]=frame_data(fd,focal_plane_normal,focal_depth,focal_plane_normal);
%! assert(norm(v-[-1;0;0],2),0)
%! assert(norm(rho-[0;-1;0],2),0,epsilon)
%! assert(isnan(t))
%! assert(norm(plambda-pi*focal_plane_normal,2),0,epsilon)
%! assert(norm(w-[0;-1;0],2),0,epsilon)


#  end of frame_data.m 
