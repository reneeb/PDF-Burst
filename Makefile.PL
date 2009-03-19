$^O=~/win32|mswin/i and die("OS not supported.\n");
use ExtUtils::MakeMaker;

WriteMakefile(
   NAME => 'PDF::Burst',
   VERSION_FROM => 'lib/PDF/Burst.pm',
   

   # gen /usr/bin/pmused by Thu Mar 19 12:39:30 EDT 2009 
   PREREQ_PM => {
      'CAM::PDF'                          => '1.21',
      'Carp'                              => '1',
      'Cwd'                               => '3',
      'Exporter'                          => '5',
      'File::Copy'                        => '2.09',
      'File::Which'                       => '0.05',
      'LEOCHARRE::CLI'                    => '1.18',
      'LEOCHARRE::DEBUG'                  => '1.12',
      'LEOCHARRE::Dir'                    => '1.06',
      'PDF::API2'                         => '2.015',
      'Test::Simple'                      => '0',
   },

   
   LICENSE => 'perl',
   
   
   
   EXE_FILES => [qw(bin/pdfburst)],
);


