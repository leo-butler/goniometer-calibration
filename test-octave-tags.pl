#!/usr/bin/perl -w -0777
use Data::Dumper;
use diagnostics;
use strict;
use warnings;
use IO::Handle;
use File::Temp;
#use POSIX;

my $data=<DATA>;
my $tmp=File::Temp->new( TEMPLATE => 'tempXXXXX',
			DIR => '.',
			SUFFIX => '.m',
			UNLINK => 0);
my $TAGS=File::Temp::mktemp('TAGS-XXXXX');
my $etags_cmd="etags --language=none --regex=\@octave.tags -o $TAGS $tmp";
open my $fh, '>>', $tmp;
print $fh $data;
close $fh;
system($etags_cmd);


__DATA__
function [errors,Lests] = line_estimator_error (P,sigma,randstate,epsilon,Lactual,N=2,grid=1,niter=45)
end function
function [errors,Lests]=  line_estimator_error (P,sigma,randstate,epsilon,Lactual,N=2,grid=1,niter=45)
end function
function [errors,Lests]=line_estimator_error (P,sigma,randstate,epsilon,Lactual,N=2,grid=1,niter=45)
end function
function [errors,Lests] =line_estimator_error (P,sigma,randstate,epsilon,Lactual,N=2,grid=1,niter=45)
end function
function [errors,Lests] =line_estimator_error (P,sigma,randstate,epsilon,Lactual,N=2,grid=1,niter=45)
end function
function line_estimator_error()
#key BMK0
end function
  global sample_data objectivefn_data objectivefn_partition;
(search-forward-regexp "^[ \t]*global\\(\\(?:\\(?:[ \t]+\\|\\(?:[ \t]*\\\\\\(?:\n\\|\r\\|\f\\|\r\f\\|\f\r\\)[ \t]*\\)\\)[[:alnum:]_]+\\)+\\)[ \t]*;*")
global sample_data objectivefn_data \
  objectivefn_partition;
function [passes,tests] = __test_make_objectivefn_data ()
endfunction
function [ x , y ] = plane_basis (P)
endfunction
##key BMK1
