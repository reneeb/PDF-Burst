use ExtUtils::MakeMaker;

WriteMakefile(
   NAME => 'PDF::Burst',
   VERSION_FROM => 'lib/PDF/Burst.pm',


   # gen /usr/bin/pmused by Tue Dec 16 11:08:24 EST 2008 
   PREREQ_PM => {
      'CAM::PDF'                          => '1.21',
      'Carp'                              => '1',
      'Cwd'                               => '3',
      'Exporter'                          => '5',
      'File::Copy'                        => '2.09',
      'File::Which'                       => '0.05',
      'LEOCHARRE::CLI'                    => '1.18',
      'LEOCHARRE::DEBUG'                  => '1.11',
      'PDF::API2'                         => '2.015',
      'Test::Simple'                      => '0',
   },


   EXE_FILES => [qw(bin/pdfburst)],
);


