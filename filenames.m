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


function fn = filenames (
			 directory="",
			 file_glob=""
			 )
  ## usage:  fn = filenames (directory,file_glob)
  ##
  ## `the correct ls function for Octave'
  ##
  ## fn = cell array with the filenames in directory
  ## directory must have a trailing separator
  ## Examples:
  ##           filenames("","*") #list all files in PWD and subdirs
  ##           filenames("","")  #list all files in PWD
  f=ls([directory,file_glob]);
  fn=mat2cell(f,ones(1,rows(f)),columns(f));
  fn=cellfun(@deblank,fn,"UniformOutput",false);
endfunction

#  end of filenames.m 
