use Test::Simple 'no_plan';
use strict;
use lib './lib';
use PDF::Burst 'pdf_burst';

$PDF::Burst::DEBUG = 1;



my @outfiles = pdf_burst('./t/trees14pgs.pdf');
ok @outfiles;

my $count2 =  scalar @outfiles;
ok($count2 == 14,"got $count2 == 14 pages");






