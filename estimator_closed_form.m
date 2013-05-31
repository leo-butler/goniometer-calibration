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

function [l,L,P,G] = estimator_closed_form (planar_line_data_str,focal_plane_normal,max_assert_error=1e-15,trans=1)
  ## usage:  [L,P,G] = estimator_closed_form (planar_line_data_str,focal_plane_normal,max_assert_error=1e-15,trans=1)
  ##
  ## see estimate_plane_from_lines_closed_form.m
  ## trans = 1 => transpose data in planar_line_data_str
  ## L = best fit line
  ## P = best fit planes
  ## G = best fit frames
  L=zeros(6,1);
  n=length(planar_line_data_str);
  P=zeros(4,n);
  g=zeros(3,3*n);
  for i=1:n
    x=planar_line_data_str{i}.lines;
    z=planar_line_data_str{i}.z;   ## focal depths
    if trans==1
      x=cellfun(@(t) t',x,"UniformOutput",false);
    endif
    if length(z)==1
      [p,g]=estimate_plane_from_line_closed_form(x,z,focal_plane_normal,max_assert_error);
    else
      [p,g]=estimate_plane_from_lines_closed_form(x,z,focal_plane_normal,max_assert_error);
    endif
    P(:,i)=p;
    G(:,((3*i-2):(3*i)))=g;
  endfor
  L=intersection_lines(P);
  l=estimate_line_from_lines_closed_form(L);
endfunction
%!shared epsilon, dist
%!test
%! epsilon=1e-9;
%! dist=@(x,y) min([norm(x-y,2);norm(x+y,2)]);
%! focal_plane_normal=[0;0;1];
%! planar_line_data_str{1}.z=planar_line_data_str{2}.z=[0;1];
%! planar_line_data_str{1}.lines={[0,0,0;0,1,0],[0,0,1;0,1,1]};  #y-z plane
%! planar_line_data_str{2}.lines={[0,0,0;1,0,0],[1,0,1;1,0,1]};  #x-z plane
%! [l,L,P,G]=estimator_closed_form(planar_line_data_str,focal_plane_normal);
%! lexp=[0;0;0;0;0;1]; # z-axis
%! Lexp=lexp;
%! Pexp=[1,0,0,0; 0,-1,0,0]'; # y-z plane and x-z plane
%! assert(dist(l,lexp),0,epsilon);
%! assert(dist(L,Lexp),0,epsilon);
%! assert(dist(P,Pexp),0,epsilon);
%! [g,~]=qr(randn(3,3)); g=g*g;
%! timesg=@(x) cellfun(@(y) y*g',x,'UniformOutput',false);
%! focal_plane_normal=g*focal_plane_normal;
%! planar_line_data_str{1}.lines=timesg({[0,0,0;0,1,0],[0,0,1;0,1,1]});
%! planar_line_data_str{2}.lines=timesg({[0,0,0;1,0,0], [1,0,1;1,0,1]});
%! [l,L,P,G]=estimator_closed_form(planar_line_data_str,focal_plane_normal);
%! lexp=[0;0;0;g(:,3)]; # z-axis
%! Lexp=lexp;
%! Pexp=[g,zeros(3,1);zeros(1,4)]*[1,0,0,0; 0,-1,0,0]';
%! assert(dist(l,lexp),0,epsilon);
%! assert(dist(L,Lexp),0,epsilon);
%! assert(dist(P,Pexp)*dist(P,Pexp*diag([1,-1])),0,epsilon);
%!test
%! focal_plane_normal=[0;0;1];
%! planar_line_data_str{1}.z=planar_line_data_str{2}.z=planar_line_data_str{3}.z=[0;1];
%! planar_line_data_str{1}.lines={[0,0,0;0,1,0],[0,0,1;0,1,1]};  #y-z plane x=0
%! planar_line_data_str{2}.lines={[0,0,0;1,0,0],[1,0,1;1,0,1]};  #x-z plane y=0
%! planar_line_data_str{3}.lines={[0,0,0;1,-1,0],[1,-1,1;2,-2,1]};  # plane x+y=0
%! [l,L,P,G]=estimator_closed_form(planar_line_data_str,focal_plane_normal);
%! lexp=[0;0;0;0;0;1]; # z-axis
%! Lexp=[zeros(5,3);-1,1,1];
%! Pexp=[1,0,0,0; 0,-1,0,0; 1/sqrt(2),1/sqrt(2),0,0]'; # y-z plane and x-z plane
%! assert(dist(l,lexp),0,epsilon);
%! assert(dist(L,Lexp),0,epsilon);
%! assert(dist(P,Pexp),0,epsilon);
%!test
%! focal_plane_normal=[0;0;1];
%! planar_line_data_str{1}.z=planar_line_data_str{2}.z=planar_line_data_str{3}.z=[0;1];
%! planar_line_data_str{1}.lines={[1,0,0;1,1,0],[1,0,1;1,1,1]};  #plane x=1
%! planar_line_data_str{2}.lines={[0,1,0;1,1,0],[1,1,1;1,1,1]};  #plane y=1
%! planar_line_data_str{3}.lines={[0,0,0;1,1,0],[1,1,1;2,2,1]};  # plane x-y=0
%! [l,L,P,G]=estimator_closed_form(planar_line_data_str,focal_plane_normal);
%! lexp=[1;1;0;0;0;-1]; # z-axis
%! Lexp=[ones(2,3);zeros(3,3);-1,-1,1];
%! Pexp=[1,0,0,1; 0,-1,0,-1; 1/sqrt(2),-1/sqrt(2),0,0]'; # y-z plane and x-z plane
%! assert(dist(l,lexp),0,epsilon);
%! assert(dist(L,Lexp),0,epsilon);
%! assert(dist(P,Pexp),0,epsilon);
%!test
%! focal_plane_normal=[0;0;1];
%! planar_line_data_str{1}.z=planar_line_data_str{2}.z=planar_line_data_str{3}.z=(0:5)';
%! planar_line_data_str{1}.lines=cellfun(@(z) [1,0,z;1,1,z], num2cell(0:5), 'UniformOutput', false);  #plane x=1
%! planar_line_data_str{2}.lines=cellfun(@(z) [0,1,z;2,1,z], num2cell(0:5), 'UniformOutput', false);  #plane y=1
%! planar_line_data_str{3}.lines=cellfun(@(z) [0,0,z;3,3,z], num2cell(0:5), 'UniformOutput', false);  # plane x-y=0
%! [l,L,P,G]=estimator_closed_form(planar_line_data_str,focal_plane_normal);
%! lexp=[1;1;0;0;0;-1]; # z-axis
%! Lexp=[ones(2,3);zeros(3,3);-1,-1,1];
%! Pexp=[1,0,0,1; 0,-1,0,-1; 1/sqrt(2),-1/sqrt(2),0,0]'; # y-z plane and x-z plane
%! assert(dist(l,lexp),0,epsilon);
%! assert(dist(L,Lexp),0,epsilon);
%! assert(dist(P,Pexp),0,epsilon);
%!test
%! focal_plane_normal=[0;0;1]; sigma=1e-1; epsilon=5*sigma;
%! rndmat=@(m,z) m(z)+sigma*[rand(2,2),zeros(2,1)];
%! planar_line_data_str{1}.z=planar_line_data_str{2}.z=planar_line_data_str{3}.z=(0:5)';
%! planar_line_data_str{1}.lines=cellfun(@(z) rndmat(@(z) [1,0,z;1,1,z],z), num2cell(0:5), 'UniformOutput', false);  #plane x=1
%! planar_line_data_str{2}.lines=cellfun(@(z) rndmat(@(z) [0,1,z;2,1,z],z), num2cell(0:5), 'UniformOutput', false);  #plane y=1
%! planar_line_data_str{3}.lines=cellfun(@(z) rndmat(@(z) [0,0,z;3,3,z],z), num2cell(0:5), 'UniformOutput', false);  # plane x-y=0
%! [l,L,P,G]=estimator_closed_form(planar_line_data_str,focal_plane_normal);
%! lexp=[1;1;0;0;0;-1]; # z-axis
%! Lexp=[ones(2,3);zeros(3,3);-1,-1,1];
%! Pexp=[1,0,0,1; 0,-1,0,-1; 1/sqrt(2),-1/sqrt(2),0,0]'; # y-z plane and x-z plane
%! assert(dist(l(1:3),lexp(1:3)),0,epsilon);
%! assert(dist(l(4:6),lexp(4:6)),0,epsilon);
%! assert(dist(L(1:3,:),Lexp(1:3,:)),0,epsilon);
%! assert(dist(L(4:6,1),Lexp(4:6,1)),0,epsilon);
%! assert(dist(L(4:6,2),Lexp(4:6,2)),0,epsilon);
%! assert(dist(L(4:6,3),Lexp(4:6,3)),0,epsilon);
%! assert(dist(P(:,1),Pexp(:,1)),0,epsilon);
%! assert(dist(P(:,2),Pexp(:,2)),0,epsilon);
%! assert(dist(P(:,3),Pexp(:,3)),0,epsilon);
##
%!xtest
%! focal_plane_normal=[0;0;1]; sigma=1e-2; epsilon=5*sigma+1e-8;
%! rndmat=@(m,z) m(z)+sigma*[rand(2,2),zeros(2,1)];
%! planar_line_data_str{1}.z=planar_line_data_str{2}.z=(0:5)'; planar_line_data_str{3}.z=0;
%! planar_line_data_str{1}.lines=cellfun(@(z) rndmat(@(z) [1,0,z;1,1,z],z), num2cell(0:5), 'UniformOutput', false);  #plane x=1
%! planar_line_data_str{2}.lines=cellfun(@(z) rndmat(@(z) [0,1,z;2,1,z],z), num2cell(0:5), 'UniformOutput', false);  #plane y=1
%! planar_line_data_str{3}.lines=cellfun(@(z) rndmat(@(z) [0,0,z;3,3,z],z), num2cell(1  ), 'UniformOutput', false);  # plane x-y=0
%! [l,L,P,G]=estimator_closed_form(planar_line_data_str,focal_plane_normal)
%! lexp=[1;1;0;0;0;-1]; # z-axis
%! Lexp=[ones(2,3);zeros(3,3);-1,-1,1];
%! Pexp=[1,0,0,1; 0,-1,0,-1; 1/sqrt(2),-1/sqrt(2),0,0]'; # y-z plane and x-z plane
%! assert(dist(l(1:3),lexp(1:3)),0,epsilon);
%! assert(dist(l(4:6),lexp(4:6)),0,epsilon);
%! assert(dist(L(1:3,:),Lexp(1:3,:)),0,epsilon);
%! assert(dist(L(4:6,1),Lexp(4:6,1)),0,epsilon);
%! assert(dist(L(4:6,2),Lexp(4:6,2)),0,epsilon);
%! assert(dist(L(4:6,3),Lexp(4:6,3)),0,epsilon);
%! assert(dist(P(:,1),Pexp(:,1)),0,epsilon);
%! assert(dist(P(:,2),Pexp(:,2)),0,epsilon);
%! assert(dist(P(:,3),Pexp(:,3)),0,epsilon);



#  end of estimator_closed_form.m 
