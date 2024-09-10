#!/usr/bin/perl

use strict;

($#ARGV+2) ==4 || die 
"Usage: get_past_n_lags.pl file.txt(header) colX n
        Input: SYM DATE.. x(t)..
        Output(if lag=3): SYM DATE x(t) x(t-1) x(t-2)\n";



my $filename=$ARGV[0];
open(INFILE, "$filename") || die "Couldn't open $filename: $!\n";

my $colX=$ARGV[1];
my $n=$ARGV[2];


my @syms;
my @dates;
my @xs;

my @line;
my $count=0;
while(<INFILE>)
{
    $count++;
    if($count==1){next;}

    #chomp the new line at the end
    chomp($_);
    @line =split;

    my $sym=$line[0];
    my $date=$line[1];
    my $x=$line[$colX-1];

    push(@syms,$sym);
    push(@dates,$date);
    push(@xs,$x);

}
close(INFILE);

# header
print "SYM DATE";
for my $j (1..$n)
{
   #my $curX=$xs[$j];
   print " RET.$j";
}
print "\n";



foreach my $i (($n-1)..$#xs)
{
    my $curSym=$syms[$i];
    my $curDate=$dates[$i];

    my $startLoc=$i+1-$n;

    if($startLoc <0){next;}

    my $startSym=$syms[$startLoc];
    my $starDate=$dates[$startLoc];

    if($startSym ne $curSym ){next;}

    print "$curSym $curDate";
    for (my $j=$i;$j>=$startLoc;$j--)
    {
       my $curX=$xs[$j];
       print " $curX";
    }
    print "\n";
}
