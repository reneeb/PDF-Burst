use ExtUtils::MakeMaker;

WriteMakefile(
   NAME => 'PDF::Burst',
   VERSION_FROM => 'lib/PDF/Burst.pm',


   # gen /usr/bin/pmused by Thu Aug  7 10:35:32 EDT 2008 
   PREREQ_PM => {
      'CAM::PDF'                          => '1',
      'Carp'                              => '1',
      'Cwd'                               => '3',
      'Exporter'                          => '5',
      'File::Copy'                        => '2',
      'LEOCHARRE::DEBUG'                  => '1',
      'PDF::API2'                         => '2',
      'Test::Simple'                      => '0',
   },


   EXE_FILES => [],
);


