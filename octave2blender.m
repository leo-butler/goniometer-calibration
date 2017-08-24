
#### call
## octave octave2blender.m data/mc+gc5.dat 

##02: export data for error-ellipsoid (error in p)
##todo: calc pos and scale factor for the planes

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

fn=sprintf("res/data/%s_%.2d.bdat", out_fn, i);
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

###extract data needed for oriented error ellipsoid (error in p)
##first extract a,b,c for ellipsoid
##second extract alpha,beta,gamma for ellipsoid orientation
##move ellipsoid to p (closest point 0)

pcov=gc5{i}.cov(1:3,1:3); ##same as cov(gc5{i}.lest(1:3,:)')
[u,w]=eig(pcov);
u= u * diag([sign(dot(cross(u(:,1),u(:,2)),u(:,3))),1,1]); ##make u right-handed https://math.stackexchange.com/questions/327841/test-of-handedness # det not good: https://stackoverflow.com/a/13146750
##print a, b, c, rot-mat, transl vector
fprintf(fid, "##eell:\ti\ta\tb\tc\tr11\tr12\tr13\tr21\tr22\tr23\tr31\tr32\tr33\td1\td2\td3\n");
#fprintf(fid, "#eell\t%d\t%f\t%f\t%f\t%f\t%f\t%f\n", i, diag(sqrt(w)), reshape(u,1,9), gc5{i}.estimate.l(1:3));
fprintf(fid, "#eell\t%d", i);
fprintf(fid, "\t%f", diag(sqrt(w)), reshape(u,1,9), gc5{i}.estimate.l(1:3));
fprintf(fid, "\n");

###extract data needed for oriented elliptic-error-cone (error in v)
##first extract a,b for ellipse
##second extract alpha,beta,gamma for ellipse orientation
##move double-cone to same pos as error-ellipsoid

#vest=cellfun(@(gc) gc.lest(4:6,:), gc5, 'UniformOutput', false);
#cov_vest=cellfun(@(v) cov(v'), vest, 'UniformOutput', false);
#[u,w]=eig(cov_vest{1});
vest=gc5{i}.lest(4:6,:);
cov_vest=cov(vest'); ##same as gc5{i}.cov(4:6,4:6)
[u,w]=eig(cov_vest);
u= u * diag([sign(dot(cross(u(:,1),u(:,2)),u(:,3))),1,1]); ##make u right-handed (not the case for e.g. i==4)
##print a, b of ellipse rot-mat of EDC, transl vector
fprintf(fid, "##eEDC:\ti\ta\tb\tr11\tr12\tr13\tr21\tr22\tr23\tr31\tr32\tr33\td1\td2\td3\n");
#fprintf(fid, "#eEDC\t%d\t%f\t%f\t%f\t%f\t%f\t%f\n", i, diag(sqrt(w))(2:3), reshape(u,1,9), gc5{i}.estimate.l(1:3));
fprintf(fid, "#eEDC\t%d", i);
fprintf(fid, "\t%f", diag(sqrt(w))(2:3), reshape(u,1,9), gc5{i}.estimate.l(1:3));
fprintf(fid, "\n");


fclose(fid);
printf("Creating file %s done.\n", fn)

endfor #i, poolN
