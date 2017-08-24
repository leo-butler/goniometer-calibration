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

## generate dir-, dir+ and a 'pooled' estimates
## [gc2,draws]=gc_adaptive_sim({"dir-/deg[+-]*.csv","dir+/deg[+-]*.csv","dir/deg[+-]*.csv"},1e-2,[2900,3000,100]);
## [gc5,draws]=gc_adaptive_sim({"dir-/deg[+-]*.csv","dir+/deg[+-]*.csv","dir[-+]/deg[+-]*.csv","dir/deg[+-]*.csv"},1e-2,[2900,3000,100],{false,false,[1,2;1,4;2,3;3,4],false});

1;

function printplot (filename,pdflatex=false,directory="res/figures")
  if pdflatex
    print(sprintf("%s/%s.pdf",directory,filename));
    cairolatex(sprintf("%s/%s-cltx.ltx",directory,filename));
  else
##  print("-depslatex","-tight",sprintf("%s/%s.tex",directory,filename));
    print("-dsvg","-tight",sprintf("%s/%s.svg",directory,filename));
  endif
endfunction

## plot 3 distributions on one sheet - direction vectors
clf("reset");
cellfun(@(x) gc_sim_plot(x,[3,5],0),gc5,'UniformOutput',false);
hold on;
C=180/pi;
text(1.754*C,(pi/2+0.0025)*C,"P");	#pooled data
text(1.756*C,(pi-1.585)*C,"C");		#dir+ data - clockwise
text((pi-1.393)*C,(pi/2+0.015)*C,"A");	#dir- data - anti-clockwise
set(gca,"fontsize",5);
set(gca,
    "xtick",C*(1.748+1e-3*(0:4:8)),"xticklabel",{'2', '4', '6'},
    "xlabel","${10(&alpha-100)}$",	#azimuthal angle
    "ytick",88:1:91,"yticklabel",{'-2', '-1', '0', '1'},
    "ylabel","${&beta} - 90$"		#polar angle
    );
hold off;
if extraPlots
printplot("direction-vector-dist-pooled");
axis("square");
printplot("direction-vector-dist-pooled-square");
endif
axis("equal");
printplot("direction-vector-dist-pooled-equal");


if extraPlots
## plot 3 distributions on one sheet - points
clf("reset");
cellfun(@(x) gc_sim_plot3(x,[-1,1,1.2]*0.3), gc5, 'UniformOutput', false);
hold on;
view(324.5,90-64)
text(-700,0,85020,"dir- data");
text(-400,-1500,85020,"dir+ data");
text(-400,1000,85020,"pooled data");
hold off;
printplot("point-dist-pooled");
endif

if true
  mc=mc_show_sim(3000,300);
  for i=1:length(gc5)
    gc5{i}.euler_coordinates=mapv(@euler_coordinates, gc5{i}.lest, 4);
  endfor
  for i=1:length(mc)
    mc{i}.euler_coordinates=mapv(@euler_coordinates, mc{i}.lest, 4);
  endfor
endif

if extraPlots
clf("reset");
gc_sim_plot(mc{1});
axis("square");
printplot("mc_sim");

clf("reset");
gc_sim_plot3(mc{1});
view(308.5,90-47);
printplot("mc_sim_points");
endif

fig=clf("reset");
hold on;
cellfun(@(gcdata) gc_sim_plot_euler(gcdata,fig,false,false,true),gc5,'UniformOutput',false);
#view(275,90-50);
set(gca,"fontsize",5);
set(gca,
    "xtick",100+1e-1*(1:2:7),"xticklabel",{'1', '3', '5', '7'},
    "xlabel","$10({&alpha}-100)$",	#azimuthal angle
    "ytick",-1:0.5:0.5,
    "ylabel","${&beta}$",
    "ztick",89.5+1e-2*(2:2:8),"zticklabel",{'2', '4', '6', '8'},
    "zlabel","$100({&gamma}-89.5)$"
    );
axis("square");
view(65,90-35)
lbl={"anti-clockwise","clockwise","pooled-a","pooled-b"};
for l=1:length(gc5)
  gc5{l}.label=lbl{l};
  p=euler_coordinates(gc5{l}.estimate.l,true)+C*4e-3*[1;0;0;0];
  text(p(1),p(2),p(3),gc5{l}.label);
endfor
hold off;
printplot("euler-angle-dist");

if extraPlots
fig=clf("reset");
hold on;
gc_sim_plot_euler(mc{1},fig);
cellfun(@(x) set(x,"fontsize",5),num2cell(get(fig,"children")),'UniformOutput',false)
hold off;
printplot("mc-euler-angle-dist4");
endif

fig=clf("reset");
hold on;
gc_sim_plot_euler(mc{1},fig,false,true,true);
cellfun(@(x) set(x,"fontsize",5),num2cell(get(fig,"children")),'UniformOutput',false)
set(gca,
    "xtick",1e-1*((-2):1:2),"xticklabel",{'-2', '-1', '0', '1', '2'},
    "xlabel","$10({&alpha}-90)$",
    "ytick",1e-1*((-2):1:2),"yticklabel",{'-2', '-1', '0', '1', '2'},
    "ylabel","$10{&beta}$",
    "ztick",5e-3*((-1):1:2),"zticklabel",{      '-1', '0', '1', '2'},
    "zlabel","$200({&gamma}-90)$"
    );
axis("square");
view(65,90-35)
hold off;
printplot("mc-euler-angle-dist");

if extraPlots
fig=clf("reset");
subplot(2,1,1);
gc_plot_distance(mc{1},fig,true,0.15,[-0.005 0.14]);
subplot(2,1,2);
gc_plot_distance(mc{1},fig,false,0.15,[70707 0.14]);
xlim([70700 70721]);
printplot("mc-radius2");
endif

fig=clf("reset");
gc_plot_distance(mc{1},fig,false,0.15,[70707 0.14]);
xlim([70700 70721]);
printplot("mc-radius");

if extraPlots
fig=clf("reset");
subplot(2,1,1);
gc_plot_distance(gc5{1},fig,true,0.15,[-0.005 0.14]);
subplot(2,1,2);
gc_plot_distance(gc5{1},fig,false,0.15,[85030 0.14]);
printplot("gc51-radius");

fig=clf("reset");
subplot(2,1,1);
gc_plot_distance(gc5{2},fig,true,0.15,[-0.005 0.14]);
subplot(2,1,2);
gc_plot_distance(gc5{2},fig,false,0.15,[85055 0.14]);
printplot("gc52-radius");

fig=clf("reset");
subplot(2,1,1);
gc_plot_distance(gc5{3},fig,true,0.13,[-0.005 0.125]);
subplot(2,1,2);
gc_plot_distance(gc5{3},fig,false,0.13,[85040 0.125]);
xlim([85032.5 85055]);
printplot("gc53-radius");
endif

fig=clf("reset");
hold on;
subplot(2,2,1);gc_plot_distance(gc5{1},fig,false,0.15,[85036 0.14]);title("anti-clockwise");
subplot(2,2,2);gc_plot_distance(gc5{2},fig,false,0.15,[85050 0.14]);title("clockwise");
subplot(2,2,3);gc_plot_distance(gc5{3},fig,false,0.13,[85042 0.125]);title("pooled-a");
subplot(2,2,4);gc_plot_distance(gc5{4},fig,false,0.15,[85058 0.125]);title("pooled-b");
hold off;
printplot("gc-radius");

#  end of gc_plots.m 
