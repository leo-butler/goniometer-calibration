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

source plane2lines.m
source filenames.m

global plane_data_directory;
plane_data_directory="~/svn-ecdf/goniometer-calibration/dir+/";
global planes_objectivefn_data;
global planes_objectivefn_partition;
global planes_objectivefn_weights;
global planes_objectivefn_scores;
global planes_objectivefn_lengths;
global planes_objectivefn_intersections;
planes_objectivefn_weights=[1e-10;1;1e-10];
planes_objectivefn_scores=[];

function d = dp2l (q,p,v,new)
  ## usage:  d = dp2l (q,p,v,new)
  ##
  ## compute the distance of the point q from the line [p;v]
  persistent P;
  if new
    P=eye(3)-v*v';
  endif
  d=norm(P*q-p,2);
endfunction
%!test
%! eps=1e-8;
%! d=dp2l([0;0;0],[1;0;-1],[1;1;1]/sqrt(3),1);
%! assert(d,sqrt(2),eps);

function d = dp2p (q,alpha,new)
  ## usage:  d = dp2p (q,alpha,new)
  ##
  ## compute the distance of the point q from the plane alpha=[n;c]
  persistent n w;
  if new
    n=alpha(1:3)';
    w=alpha(4)*n;
  endif
  d=norm((n*q)*n-w,2);
endfunction
%!test
%! eps=1e-8;
%! d=dp2p([1;0;0],[1;0;0;1],1);
%! assert(d,0,eps);


function t = fom (X)
  ## usage:  t = fom (X)
  ##
  ## X = [L;PP;LL] where
  ##  L = 6x1 column vector (a line)
  ##  PP = n 4x1 column vectors (= n planes)
  ##  LL = n m_i 6x1 column vectors (= m_i lines in plane i)
  ## W = vector of weights on data
  ##
  ## * planes_objectivefn_data contains the needed data clustered
  ## along the lines in LL
  ## * planes_objectivefn_partition contains the information about m_i
  ##
  ## * the first element in planes_objectivefn_data is the plane at 0.
  ##
  global planes_objectivefn_data;
  global planes_objectivefn_partition;
  global planes_objectivefn_lengths;
  global planes_objectivefn_weights;
  global planes_objectivefn_scores;
  global planes_objectivefn_intersections;
  [L,PP,S,LL,pwl,pwol] = extract_components (X);
  W=planes_objectivefn_weights;
  scores=zeros(1,3);

  ## transpose lines so that points are column vectors
  try
    planes_objectivefn_data{1}.columns;
  catch
    planes_objectivefn_data{1}.columns=1;
    for i=union(pwl,pwol)
      for j=1:planes_objectivefn_partition(i)
	planes_objectivefn_data{i}.lines{j}=(planes_objectivefn_data{i}.lines{j})';
      endfor
    endfor
  end_try_catch

  ## compute penalty for lines
  t=0;
  c=0;
  for i=pwl'
    a=planes_objectivefn_data{i}.scalars(1);
    v=planes_objectivefn_data{i}.dirvec;
    w=planes_objectivefn_data{i}.tdirvec;
    n=planes_objectivefn_data{i}.normal;
    p=a*n;
    for j=1:planes_objectivefn_partition(i)
      ++c;
      s=0;
      b=planes_objectivefn_data{i}.scalars(j+1);
      M=[p+b*w;v];
      pw=p+b*w;
      new=1;
      for x=(planes_objectivefn_data{i}.lines{j})
	s+=dp2l(x,pw,v,new)^2;
	new=0;
      endfor
      N=planes_objectivefn_lengths{i}(j);
      s/=N;
      s*=W(1);
      t+=s;
    endfor
  endfor
  scores(1)=t;

  ## compute penalty for planes
  s=0;
  L=reshape(L,3,2)';
  for p=(planes_objectivefn_intersections.partition){1}
    A=PP(:,p(1));
    B=PP(:,p(2));
    M=intersection_line(A,B);
    s+=line_obj(L,M);
  endfor
  s*=W(2);
  t+=s;
  scores(2)=s;

  ## finally, compute the penalty for the 0 inclination plane
  s=0;
  for i=pwol'
    P=PP(:,i);
    new=1;
    for x=(planes_objectivefn_data{i}.lines{1})
      s+=dp2p(x,P,new);
      new=0;
    endfor
    N=planes_objectivefn_lengths{i}(1);
    s/=N;
    s*=W(3);
    t+=s;
  endfor
  scores(3)=s;
  planes_objectivefn_scores=[planes_objectivefn_scores;scores];
endfunction

%!test
%! global planes_data_directory planes_objectivefn_partition;
%! planes_data_directory="~/svn-ecdf/goniometer-calibration/dir+/";
%! planes=get_planes(planes_data_directory);
%! l=6+4*1+6*2+9+2;
%! X=randn(l,1);
%! tic
%! fom(X);
%! toc

function [L,PP,LL,S,pwl,pwol] = extract_components (X)
  ## usage:  extract_components (X)
  ##
  ## X = [L;PP;LL] where
  ##  L = 6x1 column vector (a line)
  ##  PP = n 4x1 column vectors (= n planes)
  ##  LL = n m_i 6x1 column vectors (~ m_i lines in plane i) and m_i+1 scalars
  ## W = vector of weights on data
  ##
  ## * planes_objectivefn_data contains the needed data clustered
  ## along the lines in LL
  ## * planes_objectivefn_partition contains the information about m_i
  ##
  ## * the first element in planes_objectivefn_data is the plane at 0.
  ##
  global planes_objectivefn_data;
  global planes_objectivefn_partition;
  global planes_objectivefn_intersections;
  persistent not_done=true S;
  n=length(planes_objectivefn_partition);
  pwl=find(planes_objectivefn_partition>1);
  pwol=setdiff(1:n,pwl);
  nwol=length(pwol);
  nwl=length(pwl);
  mwl=sum(planes_objectivefn_partition(pwl));
  ## the lead input is L a 6x1 vector
  ## each plane requires a 4x1 vector
  ## each plane with s lines requires 2 3x1 vectors and s+1 scalars
  k=6+4*nwol+6*nwl+mwl+nwl;
  l=length(X);
  if l!=k
    error ("fom(X): input X should have length ",k);
  endif
  pp=4*nwol+6;
  L=X(1:6);
  PP=reshape(X(7:pp),4,nwol);
  d=pp;
  for i=pwl'
    c=d+1;
    d=c+planes_objectivefn_partition(i);
    planes_objectivefn_data{i}.scalars=X(c:d);
    c=d+1;
    d=c+2;
    w=planes_objectivefn_data{i}.tdirvec=X(c:d);
    c=d+1;
    d=c+2;
    v=planes_objectivefn_data{i}.dirvec=X(c:d);
    ## N = normal to plane
    N=planes_objectivefn_data{i}.normal=vector_product(v,w);
    ## the first scalar determines C:
    C=(planes_objectivefn_data{i}.scalars)(1);
    P=planes_objectivefn_data{i}.point=N*C;
    planes_objectivefn_data{i}.plane=[N;C];
    PP=[PP,[N;C]];
  endfor
  LL=[];
  if not_done
    S=planes_objectivefn_intersections=powersets(1:columns(PP)',[columns(PP);2]);
    planes_objectivefn_intersections.partition{1}=planes_objectivefn_intersections.partition{1}';
    not_done=false;
  endif
endfunction

%!test
%! global planes_data_directory planes_objectivefn_partition;
%! planes_data_directory="~/svn-ecdf/goniometer-calibration/dir+/";
%! planes=get_planes(planes_data_directory);
%! l=6+4*1+6*2+9+2;
%! X=(1:l)'; X=X .* X .* X; 
%! [L,PP,LL,S,pwl,pwol] = extract_components (X);

function C = fomc (X)
  ## usage:  C = fomc (X)
  ##
  ## 
  global planes_objectivefn_data planes_objectivefn_partition;
  [L,PP,LL,S,pwl,pwol] = extract_components (X);
  C=line_constraintfn(L);
  for i=pwl'
    w=planes_objectivefn_data{i}.tdirvec;
    v=planes_objectivefn_data{i}.dirvec;
    C=[C;unit_constraint(v);unit_constraint(w);orthogonal_constraint(v,w)];
  endfor
  for p=PP
    pc=plane_constraint(p);
    C=[C;pc];
  endfor
endfunction

%!test
%! global planes_data_directory planes_objectivefn_partition;
%! planes_data_directory="~/svn-ecdf/goniometer-calibration/dir+/";
%! planes=get_planes(planes_data_directory);
%! l=6+4*1+6*2+9+2;
%! X=(1:l)';
%! tic
%! fomc(X);
%! toc

function t = unit_constraint (x)
  ## usage:  t = unit_constraint (x)
  ##
  ## 
  t=(norm(x,2)-1)^2;
endfunction

function t = orthogonal_constraint (x,y)
  ## usage:  t = orthogonal_constraint (x,y)
  ##
  ## 
  t=[ (x'*y)^2 ];
endfunction

function C = gline_constraint (L)
  ## usage:  C = gline_constraint (L)
  ##
  ## 
  p=L(1:3,1);
  v=L(4:6,1);
  w=L(7:10);
  C=[ (v' * p)^2 ; (w' * p)^2 ; (w' * v1)^2 ; (w'*w - 1)^2 ; (v'*v - 1)^2 ];
endfunction
				%!test
				%! L=(1:6)';
				%! Cexp=[ ((4:6)*(1:3)')^2 ; ((4:6)*(4:6)' - 1)^2 ];
				%! C=gline_constraint(L);
				%! assert(C,Cexp);
function C = plane_constraint (P)
  ## usage:  C = plane_constraint (P)
  ##
  ## 
  v=P(1:3);
  C=unit_constraint(v);
endfunction
				%!test
				%! P=(1:4)';
				%! Cexp=[ ((1:3)*(1:3)' - 1)^2 ];
				%! C=plane_constraint(P);
				%! assert(C,Cexp);


function planes = get_planes (
			      directory="",
			      file_glob="*.csv",
			      save_in_globals=1
			      )
  ## usage:  planes = get_planes (directory="",file_glob="*.csv",save_in_globals=1)
  ##
  ## 
  global planes_objectivefn_data planes_objectivefn_partition planes_objectivefn_lengths;
  fn=filenames(directory,file_glob);
  planes=cellfun(@read_goniometer_data_as_lines,fn,"UniformOutput",false);
  if save_in_globals
    planes_objectivefn_data=planes;
    planes_objectivefn_partition=cellfun(@(x) length(x.lines),planes);
    planes_objectivefn_lengths=cellfun(@(x) cellfun(@(y) length(y),x.lines),planes,"UniformOutput",false);
  endif
endfunction
				%!test
				%! file="gtest.csv";
				%! pl_exp={read_goniometer_data_as_lines(file)};
				%! pl=get_planes("",file);
				%! assert(pl,pl_exp);

##  end of fom.m 
