
### call
# octave ~/publications/rot_axis_eval/blender_vis/octave2blender_01.m ~/publications/rot_axis_eval/rep_svn_121119/goniometer-calibration/data/mc+gc5.dat 


out_fn="pool_estimate";

quiet= 0;
arg_list = argv ();
if nargin != 1
  printf("Usage: %s <mc+gc5.dat> [-q]\n", program_name);
  exit(1)
else
  printf("Evaluating data from %s...\n", arg_list{1});
  load(arg_list{1}); #octave_test02.txt;
  if nargin == 2
    if (arg_list{2} == "-q")
      quiet= 1;
    endif
  endif 
endif

##create a dat file for the blender vis script for each pool-estimate

poolN=size(gc5,2); # # of pools

for i=1:1:poolN; #iterate over all pool combinations

fn=sprintf("%s_%.2d.bdat", out_fn, i);
[fid, msg]= fopen(fn, "w");

planeN=size(gc5{i}.planar_line_data_str,2); # # of planes?
pi=0; #restet point index

for j=1:1:planeN; #iterate over all planes

e= diag(gc5{i}.planar_line_data_str{j}.sigma);

fprintf(fid, "##plane measures: %d\n", j);

lpPN=size(gc5{i}.planar_line_data_str{j}.lines,2); # # of lines per plane
for k=1:1:lpPN; #k might not be the same index as in the measurement dat-file
t=gc5{i}.planar_line_data_str{j}.lines{k};

fprintf(fid, "##line measures: %d\n", k);

pN=size(t,1); # # of points per line 
for l=1:1:pN #iterate over all points
pi+=1;
#t(l,:)
fprintf(fid, "%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n", pi, t(l,:), -1*e', e');
endfor #l, pN

endfor #k, lpPN

endfor #j, planeN

EplaneN= size(gc5{i}.estimate.P,2); # # of estimated planes (always == planeN???)

for j=1:1:EplaneN; #iterate over all estimated planes
n=gc5{i}.estimate.P(1:3,j); #plane normal
d=gc5{i}.estimate.P(4,j);   #plane displacement
fprintf(fid, "#fplane\t%d\t%f\t%f\t%f\t%f\t%f\t%f\n", j, n, d*n);
endfor #j, EplaneN

#not used for drawing so far:
#ELN= size(gc5{i}.estimate.L,2) # # of estimated intersections of planes
#fprintf(fid, "#ioplane\t%d\t%f\t%f\t%f\t%f\t%f\t%f\n", i, n, d*n);

#fprintf(fid, "#iline\t%d\t%f\t%f\t%f\t%f\t%f\t%f\n", i, gc5{i}.estimate.l);
fprintf(fid, "#iline\t%d\t%f\t%f\t%f\t%f\t%f\t%f\n", i, gc5{i}.estimate.l(4:6), gc5{i}.estimate.l(1:3));



#####additions for viz of estimate-error

###extract data needed for oriented error ellipsoid
##first extract a,b,c for ellipsoid
##second extract alpha,beta,gamma for ellipsoid orientation
##move ellipsoid to p (closest point 0) or to avg of all t???

###extract data needed for oriented elliptic-error-cone
##first extract a,b for ellipse
##second extract alpha,beta for ellipse orientation
##move double-cone to same pos as error-ellipsoid

fclose(fid);
printf("Creating file %s done.\n", fn)

endfor #i, poolN
