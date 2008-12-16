package PDF::Burst;
use strict;
use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS $errstr);
@ISA = qw/Exporter/;
@EXPORT_OK = qw/pdf_burst pdf_burst_CAM_PDF pdf_burst_PDF_API2 pdf_burst_pdftk/;
$VERSION = sprintf "%d.%02d", q$Revision: 1.11 $ =~ /(\d+)/g;
%EXPORT_TAGS  = ( all => \@EXPORT_OK );
use Exporter;
use Carp;
use LEOCHARRE::DEBUG;
sub errstr;
sub errstr { $errstr =$_[0]; 1 }

  *pdf_burst = \&pdf_burst_CAM_PDF;
# *pdf_burst = \&pdf_burst_PDF_API2;

sub _args {
   my ($_path, $groupname, $_abs_loc)= @_;
   $_path or croak('missing args');

   my($abs, $abs_loc, $filename, $filename_only, $ext ) = _path_segments($_path)
      or return;
   
   if ($_abs_loc){
      -d $_abs_loc 
         or errstr "argument $_abs_loc abs loc not on disk" 
         and return;
      $abs_loc = $_abs_loc;
   }
   

   $groupname ||= $filename_only;
   $groupname=~/\w/ or warn("groupname '$groupname' makes no sense.")
      and return;

   $ext=~/\.pdf$/i or warn("$abs not pdf?") and return;
   
   ### $abs
   ### $abs_loc
   ### $filename
   ### $filename_only
   ### $ext
   
   return ($abs,$abs_loc,$filename,$filename_only, $ext, $groupname);
}



# there HAS to be a more effective way of using CAM::PDF than to instance
# each time for each page from original doc!!1
sub pdf_burst_CAM_PDF {

   my ($abs,$abs_loc,$filename,$filename_only, $ext, $groupname) = _args(@_)
      or return;


   my @abs_page_files;

   require CAM::PDF;
   my $pdfold = CAM::PDF->new($abs)
      or errstr "could not open $abs" 
      and return;

   my $pagecount = $pdfold->numPages;
   debug("pagecount $pagecount");
   undef $pdfold;


   if ( $pagecount == 1 ){
      my $abs_page = "$abs_loc/$groupname\_page_0001$ext";
      require File::Copy;
      unlink $abs_page;
      File::Copy::cp($abs, $abs_page) 
         or errstr "cant copy $abs to $abs_page, $!" 
         and return;
      return ($abs_page);
   }
   elsif( $pagecount == 0 ){
      errstr "file $abs has no pages ?!";
      return ();
   }


   for my $index ( 0 .. ( $pagecount - 1 ) ){ 

      my $index_human = sprintf '%04d', ($index + 1);
      ### $index_human
      ### $index

      my $abs_page = "$abs_loc/$groupname\_page_$index_human$ext";
      debug($abs_page);



      my $pdf = CAM::PDF->new($abs);
      $pdf->extractPages($index + 1); # discard all put page x
      $pdf->cleansave; # rebuild pdf data
      $pdf->output($abs_page);

      -f $abs_page 
         or errstr "could not save? !-f $abs_page"
         and return;

      push @abs_page_files, $abs_page;
      
   }
   
   return @abs_page_files;
}

sub _path_segments {
   my $_abs = shift;
   $_abs or croak('missing arg');

   require Cwd;
   my $abs = Cwd::abs_path($_abs) 
      or errstr "$_abs not on disk? cant resolve with Cwd::abs_path"
      and return;
   
   -f $abs or errstr "Path $abs not on disk." and return;

   $abs=~/^(.+)\/+([^\/]+)(\.\w{1,5})$/i 
      or errstr "cant match abs loc and filename into '$abs'"
      and return;
      
   my ($abs_loc, $filename_only, $ext, $filename) = ( $1, $2, $3, $2.$3 );

   return($abs, $abs_loc,$filename,$filename_only,$ext);
}


sub pdf_burst_PDF_API2 {
   my ($abs,$abs_loc,$filename,$filename_only, $ext, $groupname) = _args(@_)
      or return;

   my @abs_pages;

   require PDF::API2;
   my $pdf_src = PDF::API2->open($abs);
   my $pagecount = $pdf_src->pages;
 
   if ( $pagecount == 1 ){
      my $abs_page = "$abs_loc/$groupname\_page_0001$ext";
      require File::Copy;
      unlink $abs_page;
      File::Copy::cp($abs, $abs_page)
         or $errstr ="cant copy $abs to $abs_page, $!"
         and return;
      return ($abs_page);
   }
   elsif( $pagecount == 0 ){
      errstr "file $abs has no pages ?!";
      return ();
   }  

   for my $i ( 1 .. $pagecount ){
      my $pdf_out = sprintf "$abs_loc/$groupname\_page_%04d$ext", $i;
      debug($pdf_out);

      my $pdf = PDF::API2->new 
         or ( errstr "cant instance PDF::API" )
         and return;
      $pdf->importpage( $pdf_src, $i ) 
         or errstr "cannot import page, pdf error?"
         and return;
      $pdf->saveas( $pdf_out );
      push @abs_pages, $pdf_out;

   }
   return @abs_pages;
}

sub pdf_burst_pdftk {
   my ($abs,$abs_loc,$filename,$filename_only, $ext, $groupname) = _args(@_)
      or return;
   
   my @abs_pages;
   
   require File::Which;
   my $bin = File::Which::which('pdftk')
      or errstr "Can't find which pdftk."
      and return;

   my @args = ( $bin, $abs, 'burst', 'output', "$abs_loc/$groupname\_page_%04d.pdf");
   system(@args) == 0 
      or errstr "fails: '@args'"
      and return;

   opendir(DIR, $abs_loc) 
      or errstr "can't open $abs_loc, $!" 
      and return;
   @abs_pages = map { "$abs_loc/$_" } 
      sort grep { m/$groupname\_page\_\d+\.pdf$/i } readdir DIR;
   closedir DIR;
   
   debug($_) for @abs_pages;

   return @abs_pages;
}



1;





__END__

=pod

=head1 NAME

PDF::Burst - create one pdf doc for each page in existing pdf document

=head1 SYNOPSIS

   use PDF::Burst ':all';

   my $abs_pdf = '/home/myself/file.pdf';
   
   my @abs_pdf_pagefiles = pdf_burst_CAM_PDF($abs_pdf);
   my @abs_pdf_pagefiles = pdf_burst_PDF_API2($abs_pdf);
   my @abs_pdf_pagefiles = pdf_burst_pdftk($abs_pdf);
   my @abs_pdf_pagefiles = pdf_burst($abs_pdf);
   
   
   my @new_filenames = pdf_burst($abs_pdf) or die($PDF::Burst::errstr);
   # we get 
   #     /home/myself/file_page_0001.pdf, 
   #     /home/myself/file_page_0002.pdf, 
   #     ..
   
   
   my $abs_pdf = '/home/myself/ogre.pdf';
   
   my @new_filenames = pdf_burst($abs_pdf, 'hi' );
   # we get 
   #     /home/myself/hi_page_0001.pdf, 
   #     /home/myself/hi_page_0002.pdf, 
   #     ..
   
   my @new_filenames = pdf_burst($abs_pdf, 'hi', '/home/stuff' )
      or die($PDF::Burst::errstr);
   # we get 
   #     /home/stuff/hi_page_0001.pdf, 
   #     /home/stuff/hi_page_0002.pdf, 
   #     ..


=head1 DESCRIPTION

Bursting a pdf means if you have  a pdf doc with 10 pages, you want to have 10 docs,
each representing one page.

I just need to burst a pdf into many, so here is the module.

We provide three different ways to get out pdf pages.

=head2 pdftk

I was using the excellent pdftk, but the present version will not 
compile with the new gcc compiler. I get a missing libgcj.so.7rh error. 
Can only install libgcj.so.8rh on fc8 so far.

=head2 PDF::API2 vs. CAM::PDF

There are two options for bursting. CAM::PDF, slower but apparently more stable.
And PDF::API2, quicker but not supported on all architectures.


=head1 SUBROUTINES

None are exported by default.

=head2 pdf_burst()

Argument is abs path to pdf document to split up. Original is unchanged.
Optional arguments are the 'groupname', and the abs location (dir) you want
to output the files to.

Any individual page files pre existing are written over. 

Returns array list of abs paths to the files created.

=head2 pdf_burst_CAM_PDF()

Same as pdf_burst.
Used by default.
Requires CAM::PDF.

=head2 pdf_burst_PDF_API2()

Same as pdf_burst.
Obviously requires PDF::API2.

=head2 pdf_burst_pdftk()

Same as pdf_burst.
Requires that pdftk be installed.

=head1 DEBUG

To turn on debug..

   $PDF::Burst::DEBUG = 1;

To get last fail message..

   $PDF::Burst::errstr

=head1 BUGS

Please contact the AUTHOR.

=head1 CAVEATS

pdftk is wonderful. If it doesn't work, use this.
PDF::API2 2.015 will not properly split up docs on some architectures.
Note that this module is not for working with the innards of pdfs, it's to quickly split up
a pdf into pages, each its own document on disk.

=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=head1 LICENSE

This package is free software; you can redistribute it and/or modify it under the same terms as Perl itself, i.e., under the terms of the "Artistic License" or the "GNU General Public License".

=head1 DISCLAIMER

This package is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the "GNU General Public License" for more details.


=head1 SEE ALSO

L<PDF::API2>
L<CAM::PDF>
pdftk
L<PDF::Extract>

=cut

