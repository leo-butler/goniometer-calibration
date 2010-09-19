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

global planes_objectivefn_data planes_objectivefn_partition;
function t = fom (X,W=[1,1,1])
  ## usage:  t = fom (X,W=[1,1,1])
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
  global planes_objectivefn_data planes_objectivefn_partition;
  n=length(planes_objectivefn_partition);
  pwl=find(planes_objectivefn_partition>1)
  pwol=setdiff(1:n,pwl);
  m=sum(planes_objectivefn_partition(pwl));
  k=4*n+6*m+6;
  l=length(X);
  if l!=k
    error ("fom(X): input X should have length ",k);
  endif
  pp=4*n+6;
  L=X(1:6);
  PP=reshape(X(7:pp),4,n);
  LL=reshape(X(pp+1:l),6,m);
  S=powersets(PP',[columns(PP);2])

  ## compute penalty for lines
  t=0;
  c=0;
  for i=pwl'
    for j=1:length(planes_objectivefn_data{i}.lines)
      ++c;
      s=0;
      M=LL(:,c);
      for x=(planes_objectivefn_data{i}.lines{j})'
	s+=dpoint2line(x',M)^2;
      endfor
      N=length((planes_objectivefn_data{i}.lines{j}));
      s/=N;
      s*=W(1);
      t+=s;
    endfor
  endfor

  ## compute penalty for planes
  s=0;
  L=reshape(L,3,2)'
  for p=(S.partition){1}'
    A=PP(:,p(1))
    B=PP(:,p(2))
    M=intersection_line(A,B)
    s+=line_obj(L,M);
  endfor
  s*=W(2);
  t+=s;

  ## finally, compute the penalty for the 0 inclination plane
  s=0;
  for i=pwol'
    P=PP(:,i)';
    for x=(planes_objectivefn_data{i}.lines{1})'
      s+=dpoint2plane(x',P)^2;
    endfor
    N=length(planes_objectivefn_data{i}.lines{1});
    s/=N;
    t+=s;
  endfor

endfunction
%!test
%! global planes_data_directory planes_objectivefn_partition;
%! planes_data_directory="~/svn-ecdf/goniometer-calibration/dir+/";
%! planes=get_planes(planes_data_directory);
%! l=6+4*length(planes_objectivefn_partition)+6*sum(planes_objectivefn_partition(find(planes_objectivefn_partition>1)));
%! X=1:l;
%! fom(X)

function planes = get_planes (
			      directory="",
			      file_glob="*.csv",
			      save_in_globals=1
			      )
  ## usage:  planes = get_planes (directory="",file_glob="*.csv",save_in_globals=1)
  ##
  ## 
  global planes_objectivefn_data planes_objectivefn_partition;
  fn=filenames(directory,file_glob);
  planes=cellfun(@read_goniometer_data_as_lines,fn,"UniformOutput",false);
  if save_in_globals
    planes_objectivefn_data=planes;
    planes_objectivefn_partition=cellfun(@(x) length(x.lines),planes);
  endif
endfunction
%!test
%! file="gtest.csv";
%! pl_exp={read_goniometer_data_as_lines(file)};
%! pl=get_planes("",file);
%! assert(pl,pl_exp);

#  end of fom.m 
