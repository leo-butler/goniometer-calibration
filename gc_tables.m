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

function s = printflt (x,p=9)
  s=sprintf(sprintf("%%.%ge",p),x);
endfunction

function s = print_cell_array(c,printer=@(a,b) sprintf("%s%s",a,b),inter=' & ',ender=" \\\\\n") # '
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

function print_to_file(s, fn)
  fid= fopen(fn, 'w');
  fputs(fid, s);
  fclose(fid);
endfunction


# print_cell_array(map(@(x) printflt(x), gc5{1}.estimate.l,'UniformOutput',false))
# print_cell_array(gc5{1}.estimate.l,@(x,y) sprintf("%s%s",printflt(x),y)),

print_to_file(
  print_cell_array(gc5,@(gc) print_cell_array(gc.estimate.l,@(x,y) sprintf("%s%s",printflt(x),y),' & '," \n")),
  "res/tables/gc-est_Euclid.tab");

print_to_file(
  print_cell_array(gc5,@(gc) print_cell_array(euler_coordinates(gc.estimate.l,true),@(x,y) sprintf("%s%s",printflt(x),y),' & '," \n")),
  "res/tables/gc-est_Euler.tab");

print_to_file(
  print_cell_array(mc,@(gc) print_cell_array(gc.estimate.l,@(x,y) sprintf("%s%s",printflt(x),y),' & '," \n")),
  "res/tables/ec-est_1.tab");

print_to_file(
  print_cell_array(mc,@(gc) print_cell_array(euler_coordinates(gc.estimate.l,true),@(x,y) sprintf("%s%s",printflt(x),y),' & '," \n")),
  "res/tables/ec-est_2.tab");

# print_cell_array(mat2fullcell(mc{1}.cov), @(a,b) sprintf("%s%s",printflt(a),b))

print_to_file(
  print_cell_array(mat2fullcell(cov(mc{1}.euler_coordinates_angles')), @(a,b) sprintf("%s%s",printflt(a,0),b),' & '," \n"),
  "res/tables/ec-est_3.tab");

# cellfun(@(gc) print_cell_array(mat2fullcell(cov(gc.euler_coordinates_angles')), @(a,b) sprintf("%s%s",printflt(a,2),b)), gc5,'UniformOutput', false)


function s = printdiag (x,printer,inter='&',ender="\n") # '
  s=''; # '
  r=rows(x);
  for i=1:(r)
    s=strcat(s, printer(x(i,i)), ender);
  endfor
endfunction

function s = printmat (x,printer,sym=1,inter='&',ender="\n")
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
print_to_file(
  printdiag(v,@(x) printflt(x+0,1)),
  "res/tables/ec-est_4D.tab");
print_to_file(
  printmat(round(100*u')/100,@(x) sprintf("%.1f",x+0),0),
  "res/tables/ec-est_4.tab");

for i=1:length(gc5)
  [u,v]=eig(cov(gc5{i}.euler_coordinates_angles'));
  v=sqrt(v);
  print_to_file(
      printdiag(v,@(x) printflt(x+0,1)),
      sprintf("res/tables/gc-est-pc_%dD.tab", i));
  print_to_file(
      printmat(round(100*u')/100,@(x) sprintf("%.1f",x+0),0),
      sprintf("res/tables/gc-est-pc_%d.tab", i));
endfor

%!test
%! printflt(5.26257e+04,4)
%! printflt(-5.26257e-04,5)

#  end of gc_tables.m 
