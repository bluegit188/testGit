#!/usr/bin/perl

use strict;

($#ARGV+2)==2 || die 
"Usage: myMean.pl colX\n";

my $n=$ARGV[0];

my $sum=0;
my $count=0;
my @line; 
while(<STDIN>)
{
    #chomp the new line at the end
    chomp($_);
    @line =split;
    my $x = $line[$n-1];

    $sum+=$x;
    $count++;
}
close(INFILE);

my $mean=$sum/$count;

print "mean= $mean count= $count\n";
