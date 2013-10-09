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
## See http://octave.1599824.n4.nabble.com/pdflatex-gnuplot-td4644672.html
function f = cairolatex (output,terminal="cairolatex pdf",sed_cmds="")
  tmpfile="/tmp/octave.gnuplot";
  dot=strfind(output,".");
  ndot=length(dot);
  switch ndot
    case {0}
      dot=strlen(output);
    case {1}
      ##dot=dot;
    otherwise
      dot=dot(ndot);
  endswitch
  tmpfileout=strcat(substr(output,1,dot),"gnuplot");
  drawnow("dumb","/dev/null",false,tmpfile);
  sleep(1);
  term=sprintf("set terminal %s;",terminal);
  out=sprintf("set output \"%s\";",output);
  system(f=sprintf("sed -r -e 's$^set terminal .+$%s;$; s$set output .+$%s;$; %s;' %s | tee %s | gnuplot",term,out,sed_cmds,tmpfile,tmpfileout));
endfunction

#  end of cairolatex.m 
