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
function gcfiles = gc_sim (globs,draws=10,choices=false)
  ## utilities
  add_noise_to_lines=@(plds,sigma) cellfun(@(line_data) line_data+randn(rows(line_data),columns(line_data))*sigma, plds, 'UniformOutput', false);

  ## globs==gcfiles?
  if ischar(globs{1})
    bdraws=1; edraws=draws;
    ## read in data file information
    for i=1:length(globs)
      gcfiles{i}.files=glob(globs{i});
    endfor
    if isscalar(choices)
      choices=cellfun(@(x) choices,gcfiles,'UniformOutput',false);
    endif
    for j=1:length(gcfiles)
      ## read in data from each file
      files=gcfiles{j}.files;
      gcfiles{j}.choices=choices{j};
      clear planar_line_data_str;
      for i=1:length(files)
	file=files{i};
	line_data=read_goniometer_data_as_lines(file);
	planar_line_data_str{i}=line_data;
	sigma=diag(csvread(strcat(substr(file,1,length(file)-3),"sigma")));
	planar_line_data_str{i}.sigma=sigma;
      endfor
      gcfiles{j}.planar_line_data_str=planar_line_data_str;
      ## l = best fit line
      ## L = pairwise intersections of best fit planes
      ## P = best fit planes
      ## G = best fit frames of planes
      [l,L,P,G,Lbar,d] = estimator_closed_form(planar_line_data_str,[0;0;1],1e-9,1,choices{j});
      gcfiles{j}.estimate=struct("l",l,"L",L,"P",P,"G",G,"Lbar",Lbar,"d",d);
    endfor
  else
    gcfiles=globs;
    bdraws=length(gcfiles{1}.est)+1;
    edraws=bdraws+draws-1;
  endif
  for j=1:length(gcfiles)
    for i=bdraws:edraws
      gcdata=gcfiles{j};
      for k=1:length(gcdata.planar_line_data_str)
	gcdata.planar_line_data_str{k}.lines=add_noise_to_lines(gcdata.planar_line_data_str{k}.lines, gcdata.planar_line_data_str{k}.sigma);
      endfor
      [l,L,P,G] = estimator_closed_form(gcdata.planar_line_data_str,[0;0;1],-1e-9,1,gcdata.choices);
      gcfiles{j}.est{i}=struct("l",l,"L",L,"P",P,"G",G);
    endfor
    gcfiles{j}.lest=lest=cell2mat(cellfun(@(estimate) estimate.l, gcfiles{j}.est, 'UniformOutput', false));
    gcfiles{j}.mean=mean(lest,2);
    gcfiles{j}.cov=cov(lest');
  endfor
endfunction

#  end of gc_sim.m 
