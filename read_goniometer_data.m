## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id$
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

function [t,p] = read_goniometer_data (filenames,style="standard")
  ## usage:  [t,p] = read_goniometer_data (filenames,style="standard")
  ## style => "standard" == rows of 3
  ##          "csv"      == comma separated rows
  ## t = data
  ## p = length of data in each file
  ## 
  t=[];
  p=[];
  if ischar(filenames)
    [t,p]=read_goniometer_data(cellstr(filenames),style);
  else
    for i=1:length(filenames)
      filename=filenames{i};
      unwind_protect
	switch style
	  case "standard"
	    fid=fopen(filename);
	    if fid>0
	      r=0;
	      while ((line=fgetl(fid)))
		switch line(1)
		  case '#'
		    1;
		  otherwise
		    [v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,c]=sscanf(line,"%d\t%d\t%d\t%d\t%d\t%d%d\t%d\t%d\t%d","C");
		    t=[t;v2,v3,v4,v5,v6,v7,v8,v9,v10];
		    r++;
		endswitch
	      endwhile
	      # the partition is implicit in the above
	      # hard-coded pattern
	      p=[r*ones(1,3);3*ones(1,3)];
	    else
	      error("reading file.");
	    endif
	  case "csv"
	    t0=csvread(filename);
	    r=find(t0(:,1));
	    c=4;
	    t0=t0(r,2:c);
	    p=[p,rows(r)];
	    t=[t;t0];
	  otherwise
	    error("style option not understood.");
	endswitch
      unwind_protect_cleanup
	if strcmp(style,"standard")
	  fclose(fid);
	endif
      end_unwind_protect
    endfor
  endif
endfunction
%!test
%! f="gtest.csv"; type="csv";
%! [t,p]=read_goniometer_data(f,type);
%! assert(size(t),[10,3]);
%! assert(p,[10]);
%! [t,p]=read_goniometer_data([f;f;f;f;f],type);
%! assert(size(t),[5*10,3]);
%! assert(p,10*ones(1,5));

## end of read_goniometer_data.m
