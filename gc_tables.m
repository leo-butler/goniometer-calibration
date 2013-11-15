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
1;


function y = radians2degrees (x)
  y = x*180/pi;
endfunction

for i=1:length(gc5)
  gc5{i}.euler_coordinates_angles(1:3,:)=radians2degrees(gc5{i}.euler_coordinates(1:3,:));
  gc5{i}.euler_coordinates_angles(4,:)=gc5{i}.euler_coordinates(4,:);
endfor
for i=1:length(mc)
  mc{i}.euler_coordinates_angles(1:3,:)=radians2degrees(mc{i}.euler_coordinates(1:3,:));
  mc{i}.euler_coordinates_angles(4,:)=mc{i}.euler_coordinates(4,:);
endfor

function s = printflt (x,p=4)
  if abs(x)<10.0 && abs(x)>1.0
    s=sprintf(sprintf("%%.%gf",p),x);
  else
    s=sprintf("%s",regexprep(sprintf(sprintf("%%.%ge",p),x),'e[+]?(-)?0?([0-9]+)',' \ttime{10^{$1$2}}'));
  endif
endfunction

function s = print_cell_array(c,printer=@(a,b) sprintf("%s%s",a,b),inter=' & ',ender=" \\\\\n")
  s='';
  if ismatrix(c)
    c=num2cell(c);
  endif
  for i=1:(length(c)-1)
    if iscell(c{i})
      s=strcat(s,print_cell_array(c{i},printer,inter,ender));
    else
      s=strcat(s, printer(c{i},inter));
    endif
  endfor
  i=length(c);
  if iscell(c{i})
    s=strcat(s,print_cell_array(c{i},printer,inter,ender));
  else
    s=strcat(s, printer(c{i},ender));
  endif
endfunction
mat2fullcell=@(mat) cellfun(@(x) mat2cell(x,[1],ones(columns(mat),1)), mat2cell(mat,ones(rows(mat),1),[columns(mat)]), 'UniformOutput',false);

print_cell_array(map(@(x) printflt(x), gc5{1}.estimate.l,'UniformOutput',false))
print_cell_array(gc5{1}.estimate.l,@(x,y) sprintf("%s%s",printflt(x),y))

print_cell_array(gc5,@(gc) print_cell_array(gc.estimate.l,@(x,y) sprintf("%s%s",printflt(x),y),' & '," \\\\\n"))
print_cell_array(gc5,@(gc) print_cell_array(euler_coordinates(gc.estimate.l,true),@(x,y) sprintf("%s%s",printflt(x),y),' & '," \\\\\n"))

print_cell_array(mc,@(gc) print_cell_array(gc.estimate.l,@(x,y) sprintf("%s%s",printflt(x),y),' & '," \\\\\n"))
print_cell_array(mc,@(gc) print_cell_array(euler_coordinates(gc.estimate.l,true),@(x,y) sprintf("%s%s",printflt(x),y),' & '," \\\\\n"))

print_cell_array(mat2fullcell(mc{1}.cov), @(a,b) sprintf("%s%s",printflt(a),b))
print_cell_array(mat2fullcell(cov(mc{1}.euler_coordinates_angles')), @(a,b) sprintf("%s%s",printflt(a,0),b))

cellfun(@(gc) print_cell_array(mat2fullcell(cov(gc.euler_coordinates_angles')), @(a,b) sprintf("%s%s",printflt(a,2),b)), gc5,'UniformOutput', false)


function s = printdiag (x,printer,inter='&',ender="\\\\\n")
  s='& ';
  r=rows(x);
  for i=1:(r-1)
    s=strcat(s, printer(x(i,i)), inter);
  endfor
  s=strcat(s, printer(x(r,r)), ender);
endfunction
function s = printmat (x,printer,sym=1,inter='&',ender="\\\\\n")
  s='';
  r=rows(x);
  for i=1:r
    for j=1:(i*sym)
      s=strcat(s, inter);
    endfor
    for j=((1-sym)+i*sym):(r-1)
      s=strcat(s, printer(x(i,j)), inter);
    endfor
    s=strcat(s, printer(x(i,r)), ender);  
  endfor
endfunction
[u,v]=eig(cov(mc{1}.euler_coordinates_angles'));
v=sqrt(v);
printdiag(v,@(x) printflt(x+0,1))
printmat(round(100*u')/100,@(x) sprintf("%.1f",x+0),0)
for i=1:length(gc5)
  [u,v]=eig(cov(gc5{i}.euler_coordinates_angles'));
  v=sqrt(v);
  printdiag(v,@(x) printflt(x+0,1))
  printmat(round(100*u')/100,@(x) sprintf("%.1f",x+0),0)
endfor

%!test
%! printflt(5.26257e+04,4)
%! printflt(-5.26257e-04,5)

#  end of gc_tables.m 
