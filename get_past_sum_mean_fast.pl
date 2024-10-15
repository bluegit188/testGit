#!/usr/bin/perl

use strict;

use lib "/home/jgeng/bin";
use JunfeiUtil;


($#ARGV+2) ==4 || die 
"Usage: get_past_sum_fast.pl file.txt(header) colX N
        Compute rolling N-day sum
        Input: SYM DATE.. x(t)..
        Output(:  .. sum\n";

my $filename=$ARGV[0];
open(INFILE, "$filename") || die "Couldn't open $filename: $!\n";

my $colX=$ARGV[1];
my $n=$ARGV[2];


my @syms;
my @dates;
my @xs;
my @lines;

my $header;
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
      $header=$str;
      next;
    }

    #chomp the new line at the end
    chomp($_);
    @line =split;

    my $sym=$line[0];
    my $date=$line[1];
    my $x=$line[$colX-1];

    push(@syms,$sym);
    push(@dates,$date);
    push(@xs,$x);
    push(@lines,$str);

}
close(INFILE);


# header
print "$header sumP${n}D avgP${n}D\n";

my $xsum=0;


foreach my $i (($n-1)..$#xs)
{
    my $curSym=$syms[$i];
    my $curDate=$dates[$i];
    my $curStr=$lines[$i];
    my $curX=$xs[$i];

    my $startLoc=$i+1-$n;

    if($startLoc <0)
    {
      $xsum=0;
      next;
    }

    my $startSym=$syms[$startLoc];
    my $starDate=$dates[$startLoc];

    if($startSym ne $curSym )
    {
      next;
    }

    ### for below, valid std can be computed; but some case can reuse previous calculations
    #print "$curStr";
    # get std
    if($startLoc-1 >=0 && $syms[$startLoc-1] eq $curSym) # can use 
    {
       my $oldX=$xs[$startLoc-1];

       $xsum=$xsum+$curX-$oldX;
    }
    else # need to compute std bruteforece
    {
      $xsum=0;
      for (my $j=$startLoc;$j<=$i;$j++)
      {
	my $x=$xs[$j];
	$xsum+=$x;
      }
    }
    #my $std=sqrt( ($x2sum-$xsum*$xsum/$n)/($n-1) );

    #my $mean=get_mean(\@tmpXs);
    #my $std=get_std(\@tmpXs);
    
    my $mean=$xsum/$n;

    printf "$curStr %.7f %.7f\n",$xsum,$mean;



}


__END__


my @y = 0..5;
print join(' ',@y),"\n";
my $y = pdl @y;
# a simple function
my $stdv = $y->stdv_unbiased ;
print "std=$stdv\n";

see here:

http://pdl-stats.sourceforge.net/Basic.htm#stdv
