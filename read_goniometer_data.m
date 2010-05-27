## -*- Mode: octave; Package: OCTAVE -*-
##
## $Id$
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

function t = read_goniometer_data (filename)
  ## usage:  t = read_goniometer_data (filename)
  ##
  ## 
  t=[];
  unwind_protect
    fid=fopen(filename);
    if fid>0
      while (line=fgetl(fid))
	switch line(1)
	  case '#'
	    1;
	  otherwise
	    [v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,c]=sscanf(line,"%d\t%d\t%d\t%d\t%d\t%d%d\t%d\t%d\t%d","C");
	    t=[t;v2,v3,v4,v5,v6,v7,v8,v9,v10];
	endswitch
      endwhile
    else
      "Error reading file."
    endif
  unwind_protect_cleanup
    fclose(fid);
  end_unwind_protect
endfunction
## end of read_goniometer_data.m
