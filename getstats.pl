#!/usr/bin/perl

use strict;

use PDL::LiteF;        # loads less modules
use PDL::NiceSlice;    # preprocessor for easier pdl indexing syntax 
use PDL::Stats;
use PDL::Ufunc;

($#ARGV+2) ==3 || die 
"Usage: get_stats.pl file.txt(header) colX
       Output: xName min max mean std\n";

my $filename=$ARGV[0];
open(INFILE, "$filename") || die "Couldn't open $filename: $!\n";

my $colX=$ARGV[1];

my @xs;
my $xName;
my @line;
my $count=0;
while(<INFILE>)
{
    chomp($_);
    @line =split;
    my $str=$_;

    $count++;
    if($count==1)
    {
      $xName=$line[$colX-1];
      next;
    }

    my $x=$line[$colX-1];
    push(@xs,$x);
}
close(INFILE);

my $pdlRef = pdl @xs;

my $mean = $pdlRef->average ;
my $std = $pdlRef->stdv_unbiased ;
my $min = $pdlRef->min ;
my $max = $pdlRef->max ;
my $count2=$#xs+1;

print "colName min max mean std count\n";
printf "$xName $min $max %.7f %.7f $count2\n",$mean,$std;


__END__


my @y = 0..5;
print join(' ',@y),"\n";
my $y = pdl @y;
# a simple function
my $stdv = $y->stdv_unbiased ;
print "std=$stdv\n";

see here:

http://pdl-stats.sourceforge.net/Basic.htm#stdv
