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

function sc1 = sc1 (N=500,sigma=1,d0=40,s=1,samples=4)
  focal_plane_normal=[0;0;1];
  c=sqrt(2);
  planes=[1/c,0,1/c,c; 0,1,0,3]';
  focal_depths={d0+s*(1:samples),d0+s*(1:samples)};
  sc1=mc_planar_line_estimate(planes,focal_depths,focal_plane_normal,N,sigma);
endfunction

function y = sc2 (n=20,N=500,sigma=1)
  sc=sc1(N,sigma);
  y=reshape(cell2mat(cellfun(@(x) sc.estimate.l,num2cell(ones(n,1)),'UniformOutput',false)),6,n);
  plot3(y(4,:),y(5,:),y(6,:),'*');
endfunction

function plot_planar_line_data (pld,T=10)
  hold;
  cellfun(@(x) cellfun(@(y) plot3(y(:,1), y(:,2), y(:,3), 'x'), x.lines, 'UniformOutput', false), pld.planar_line_data_str, 'UniformOutput', false);
  line=(pld.estimate.l)(1:3) + (-T:T).*(pld.estimate.l)(4:6); line=line';
  plot3(line(:,1),line(:,2),line(:,3),'*');
  hold;
endfunction

function mplot_planar_line_data (pld,T=10,filename="mc_scratch")
  clf("reset");
  subplot(2,2,1);
  plot_planar_line_data(pld,T); view(290,90-65);
  subplot(2,2,2); plot_planar_line_data(pld,T); view(2,0);
  subplot(2,2,3); plot_planar_line_data(pld,T); view(270.5,0);
  subplot(2,2,4); plot_planar_line_data(pld,T); view(279.5,90-42);
  saveas(1,strcat(filename,".png"));
  save(strcat(filename,".dat"),"pld");
endfunction

function p = projection_onto_plane (pld)
  ## inputs to project are 1x3 row vectors!
  projection=@(x,xbar,n,c) (x-xbar) - n.*((x-xbar)*n') + xbar;
  ##
  planes=pld.estimate.P;
  planar_data=cellfun(@(x) x.lines, pld.planar_line_data_str,'UniformOutput',false);
  N=length(planar_data);
  p=pld;
  for i=1:N
    n=planes(1:3,i)'; c=planes(4,i);
    xbar=c*n
    planar_data{i}=cellfun(@(x) projection(x,xbar,n,c), planar_data{i}, 'UniformOutput', false);
    p.planar_line_data_str{i}.lines=planar_data{i};
  end
endfunction

sc=sc1(3,0.25,0,1); mplot_planar_line_data(sc,5);

#  end of mc_scratch.m 
