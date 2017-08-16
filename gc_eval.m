### octave script to use argv to run CLS-evaluation, plots, simulated data (mc)
1;

arg_list = argv ();
if nargin <= 1
  printf("Usage: %s <CSV patterns of measurements>\n", program_name);
  printf('   CSV pattern of example data:  "dir-/deg[+-]*.csv","dir+/deg[+-]*.csv","dir[-+]/deg[+-]*.csv","dir/deg[+-]*.csv"');
  exit(1)
endif


addpath ("goniometer-calibration/")

## deterministic RNG for reproducibility
load randstate.m
rand("state",randstate);
randn("state",randstate);

tic;
[gc5,draws]= gc_adaptive_sim(arg_list',1e-2,[2900,3000,100],{false,false,[1,2;1,4;2,3;3,4],false});  # does the CLS-evaluation
toc

extraPlots= false
gc_plots;  # creates plots, mc

save -text "res/data/mc+gc5.dat" mc gc5
