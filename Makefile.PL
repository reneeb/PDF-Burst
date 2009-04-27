use ExtUtils::MakeMaker;

WriteMakefile(
   NAME => 'PDF::Burst',
   VERSION_FROM => 'lib/PDF/Burst.pm',
   

   # gen /usr/bin/pmused by Mon Apr 27 15:36:40 EDT 2009 
   PREREQ_PM => {
      'CAM::PDF'                          => '1.52',
      'Carp'                              => '1',
      'Cwd'                               => '3',
      'Exporter'                          => '5',
      'File::Copy'                        => '2.09',
      'File::Which'                       => '0.05',
      'LEOCHARRE::CLI'                    => '1.19',
      'LEOCHARRE::DEBUG'                  => '1.13',
      'LEOCHARRE::Dir'                    => '1.07',
      'PDF::API2'                         => '2.015',
      'Test::Simple'                      => '0',
   },

   
   LICENSE => 'perl',
   
   
   
   EXE_FILES => [qw(bin/pdfburst)],
);


