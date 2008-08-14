use Test::Simple 'no_plan';

ok(1,'started');
opendir(D, './t') or die;
map { unlink "./t/$_" } grep { /_page_/ } readdir D;
closedir D;

system('rm ./t/alt/*pdf');
system('rmdir ./t/alt');

ok(1,"cleaned");


