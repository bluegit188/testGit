#!/usr/bin/perl

use strict;
use Statistics::R;


($#ARGV+2) ==5 || die 
"Usage: auto_corr.pl file.txt(noheader) colX lagMax demean=TRUE/FALSE
       Compute ARs
       demean= TRUE by default, can be set to FALSE
       Example cmd: auto_corr.pl AOOF1.txt 3 63 TRUE|mygetcols.pl 2 3 4|fgrep -v \"[\"|more
       Output: lag cor R=cor^2\n";

my $filename=$ARGV[0];
open(INFILE, "$filename") || die "Couldn't open $filename: $!\n";

my $colX=$ARGV[1];
my $colXStr="V$colX";

my $lag=$ARGV[2];

my $demean=$ARGV[3];

# Here-doc with multiple R commands:
my $cmd1 = <<EOF;
#for fread fast read
library(data.table)
#fast read
regdata<-read.table(file="$filename",header=F)
#summary(regdata)
acf=acf(regdata\$$colXStr,lag.max=$lag,plot=FALSE, demean=$demean)
c<-cbind(acf\$lag,acf\$acf,(acf\$acf)^2)
print(c)
EOF

#print "cmd1=$cmd1\n";
#save cmd to a temp file
open(OUTFILE, ">tmp_R_file") || die "Couldn't open tmp_R_file\n";
printf OUTFILE $cmd1,"\n";
close(OUTFILE);

# Create a communication bridge with R and start R
my $R = Statistics::R->new();
my $out2 = $R->run($cmd1);
print "$out2\n";


__END__

auto_corr.pl AOOF1.txt 3 63 TRUE|mygetcols.pl 2 3 4|fgrep -v "["|more




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
